import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:api/framework/api-environment.dart';
import 'package:api/social-client-api.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() async {
	
	String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';

	try {
		await APIEnvironment.load(env);
		await ClientAPITest.run();
	}
	catch(e) {
		print(e);
	}
}

abstract class ClientAPITest {

	static final SocialClientAPI server = SocialClientAPI(APIEnvironment.env);
	static final HttpClient client = HttpClient();
	static final JsonEncoder enc = JsonEncoder();
	static final JsonDecoder dec = JsonDecoder();
	static final Random rnd = Random();

	static final List<int> _ascii = [97, 122]; // ascii charcode
	static int get _next => (_ascii[0] + rnd.nextInt(_ascii[1] - _ascii[0]));
	static String _rstr(int length) => String.fromCharCodes(List.generate(length, (_) => _next));
	
	static String get _ruser => _rstr(10) + '@' + _rstr(10) + '.' + _rstr(3);
	static String get _rpass => _rstr(16);
	static String get _rname => _rstr(16);

	static final TestModel tmodel = TestModel(b: true, i: 1024, s: _rstr(32));
	static final NewUser randuser = NewUser.create(email: _ruser, password: _rpass, first_name: _rname, last_name: _rname);
	static final AuthRequest auth = AuthRequest(email: randuser.email, hashp: randuser.hashp);
	static AuthenticatedUser user;
	static UserImage image;
	static List<String> postIds = [];
	static Post post;
	static String roomId;
	static Room room;

	static Future<void> run() async {
		
		test('startup', startup);
		test('GET: /', echoTest);
		test('GET: /check/:a', paramTest);
		test('POST: /test-model', modelTest);
		test('POST: /users', userCreateTest);
		test('POST: /auth', authTest);
		test('GET: /users/me', findMeTest);
		test('GET: /users/:id', findUserTest);
		test('POST: /images', createImageTest);
		test('GET: /images/profile/:user_id', getProfileImageTest);
		test('GET: /images/user/:user_id', getUserImagesTest);

		for (var i = 0; i < 3; ++i) {
			test('POST: /posts/', createPostTest);
			test('GET: /posts/:post_id', getPostTest);
			test('GET: /posts/user/:user_id', getUserPostsTest);
		}

		test('POST: /rooms', createRoomTest);
		test('WS: /rooms/join/:id', joinRoomTest);

		// for (var i = 0; i < 3; ++i) {
		// 	test('DELETE: /posts/:id', deletePostTest);
		// }

		// test('DELETE: /images/:id', deleteImageTest);

		test('shutdown', shutdown);
	}

	static void startup() async { await server.start(); expect(server.host, isNotNull); }
	static void shutdown() async { await server.stop(); expect(server.host, isNull); }

	static Future<dynamic> _getRequest(String url, { dynamic expected, String token, Function verify }) async {
		
		HttpClientRequest req = await client.get(server.host, server.port, url);
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(expected)) : verify;
		HttpClientResponse res = await req.close();
		return await res.transform(utf8.decoder).listen((x) => callback(x));
	}

	static Future<dynamic> _postRequest(String url, dynamic content, { String token, Function verify }) async {

		HttpClientRequest req = await client.post(server.host, server.port, url);
		req.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
		return _process(req, enc.convert(content), token: token, verify: verify);
	}

	static Future<dynamic> _putRequest(String url, dynamic content, { String token, Function verify }) async {

		HttpClientRequest req = await client.put(server.host, server.port, url);
		// req.headers.contentType = ContentType('application', 'octet-stream', charset: 'utf-8');
		req.headers.contentType = ContentType('text', 'plain');
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(content)) : verify;
		return await (req..write(base64.encode(content))).close()..transform(utf8.decoder).listen((x) => callback(x));
	}

	static Future<dynamic> _deleteRequest(String url, { dynamic expected, String token, Function verify }) async {
		
		HttpClientRequest req = await client.delete(server.host, server.port, url);
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(expected)) : verify;
		HttpClientResponse res = await req.close();
		return await res.transform(utf8.decoder).listen((x) => callback(x));
	}

	static Future<dynamic> _process(HttpClientRequest req, dynamic content, { String token, Function verify }) async {
		
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(content)) : verify;
		return await (req..write(content)).close()..transform(utf8.decoder).listen((x) => callback(x));
	}

	static void echoTest() async => _getRequest('/', expected: 'echo');
	static void paramTest() async => _getRequest('/check/123', expected: 123);

	static void modelTest() async => 
		_postRequest('/test-model', tmodel.data, verify: (dynamic data) =>
			expect(Serializable.of<TestModel>(dec.convert(data)), equals(tmodel)));

	static void userCreateTest() async => 
		_postRequest('/users', randuser.data, verify: (String data) => 
			expect(dec.convert(data)['create_user'], isNotEmpty));

	static void authTest() async =>
		_postRequest('/auth', auth.data, verify: (String data) async =>
			(saveUser(data)).then((_) => expect(user is AuthenticatedUser, true)));
	
	static void findUserTest() async =>
		_getRequest('/users/' + user.id, token: user.token, verify: (String data) => 
			expect(Serializable.of<User>(dec.convert(data)) is User, true));

	static void findMeTest() async =>
		_getRequest('/users/me', token: user.token, verify: (String data) => 
			expect(Serializable.of<User>(dec.convert(data)) is User, true));

	static Future<void> saveUser(String data) async { 
		user = Serializable.of<AuthenticatedUser>(dec.convert(data));
		try { await File('test/logs/' + user.id + '.json').writeAsString(enc.convert(user)); }
		catch(e) { print(e); }
	}

	static void createImageTest() async {

		File file = File('test/test-image.png');
		String ext = file.uri.pathSegments.last.split('.').last.toUpperCase();
		image = UserImage(user_id: user.id, format: ext, is_profile: true);
		await _postRequest('/images', image.data, token: user.token, verify: (String data) {
			image.id = dec.convert(data)['add_image'];
			expect(image.id, isNotNull);
		});

		List<int> bytes = await file.readAsBytes();
		File x = File('test/rewrite-test-image.png');
		await x.writeAsBytes(bytes);
		await _putRequest('/images/' + image.id, bytes, token: user.token, verify: (String data) {
			expect(dec.convert(data), equals(image.id));
		});
	}

	static void getProfileImageTest() async {

		UserImage testimage;
		await _getRequest('/images/profile/' + user.id, token: user.token, verify: (String data) {	
			testimage = Serializable.of<UserImage>(dec.convert(data));
			expect(testimage.user_id, equals(user.id));
		});

		try {

			await _getRequest('/images/' + testimage.id + '/content', token: user.token, verify: (dynamic data) {

				List<int> bytes = base64.decode(data);
				File file = File('test/retrieved-test-image.' + testimage.ext);
				file.writeAsBytes(bytes);
				expect(testimage.id, equals(image.id));
			});
		}
		catch(e) {
			print(e);
		}
	}

	static void getUserImagesTest() async {

		UserImage testimage;
		await _getRequest('/images/user/' + user.id, token: user.token, verify: (String data) {	
			testimage = Serializable.of<UserImage>(dec.convert(data)[0]);
			expect(testimage.user_id, equals(user.id));
		});
	}

	static void createPostTest() async {

		NewPost newpost = NewPost(user_id: user.id, image_id: image.id, content: _rstr(2048));
		await _postRequest('/posts', newpost.data, token: user.token, verify: (String data) {
			postIds.add(dec.convert(data)['create_post']);
			expect(postIds.last, isNotNull);
		});
	}

	static void getPostTest() async {

		await _getRequest('/posts/' + postIds.last, token: user.token, verify: (dynamic data) {
			post = Serializable.of<Post>(dec.convert(data));
			expect(post.id, equals(postIds.last));
		});
	}

	static void getUserPostsTest() async {

		await _getRequest('/posts/user/' + user.id, token: user.token, verify: (dynamic data) {
			
			List<dynamic> items = dec.convert(data);
			List<Post> posts = items.map((item) => Serializable.of<Post>(item)).toList();
			posts.forEach((post) => expect(post.user_id, equals(user.id)));
		});
	}

	static void createRoomTest() async {

		NewRoom room = NewRoom(owner_id: user.id, title: _rstr(32), about: _rstr(1024), image_id: image.id);
		await _postRequest('/rooms', room.data, token: user.token, verify: (String data) {
			roomId = dec.convert(data)['create_room'];
			expect(roomId, isNotNull);
		});
	}

	static void joinRoomTest() async {

		String url = 'ws://' + server.host + ':' + server.port.toString() + '/rooms/chat/' + roomId;
		Map<String, dynamic> headers = { 'Authorization': 'Bearer ' + user.token };
		WebSocket sock = await WebSocket.connect(url, headers: headers);
		
		sock.listen((event) {
			print(event);
		});
		sock.add(json.encode({ 'a': 1 }));
		print(sock);
	}

	static void deletePostTest() async {
		await _deleteRequest('/posts/' + postIds.removeLast(), token: user.token, expected: {'delete_post': true});
	}

	static void deleteImageTest() async {
		await _deleteRequest('/images/' + image.id, token: user.token, expected: {'delete_image': true});
	}
}