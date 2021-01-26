import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:api/services/auth-service.dart';
import 'package:api/services/image-service.dart';
import 'package:api/services/post-service.dart';
import 'package:api/services/room-service.dart';
import 'package:api/services/user-service.dart';
import 'package:api/social-client-api.dart';
import 'package:api_sdk/api-sdk.dart';
import 'package:api_sdk/types/reflector.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() async {

	try {
		String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
		List<ServiceBase> services = [
			TestService(),
			AuthService(),
			RoomService(),
			PostService(),
			UserService(),
			ImageService()
		];

	 	ClientAPITest tester = ClientAPITest(env, services);
		await tester.run();
	}
	catch(e) {
		print(e);
	}
}

class ClientAPITest extends SDKTestBase {

	static String _rstr(int len) => SDKTestBase.rstr(len);
	static String get _ruser => _rstr(10) + '@' + _rstr(10) + '.' + _rstr(3);
	static String get _rpass => _rstr(16);
	static String get _rname => _rstr(16);

	static final NewUser randuser = NewUser.create(email: _ruser, password: _rpass, first_name: _rname, last_name: _rname);
	static final AuthRequest auth = AuthRequest(email: randuser.email, hashp: randuser.hashp);

	AuthenticatedUser user;
	UserImage image;
	List<String> postIds = [];
	Post post;
	String roomId;
	Room room;

	ClientAPITest(String env, List<ServiceBase> services) : super(env, services);

	@override
	Future<void> run() async {
		
		test('create', create);
		test('startup', startup);
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

	void userCreateTest() async => 
		postRequest('/users', randuser.data, verify: (String data) => 
			expect(dec.convert(data)['create_user'], isNotEmpty));

	void authTest() async =>
		postRequest('/auth', auth.data, verify: (String data) async =>
			(saveUser(data)).then((_) => expect(user is AuthenticatedUser, true)));
	
	void findUserTest() async =>
		getRequest('/users/' + user.id, token: user.token, verify: (String data) => 
			expect(Reflector.of<User>(dec.convert(data)) is User, true));

	void findMeTest() async =>
		getRequest('/users/me', token: user.token, verify: (String data) => 
			expect(Reflector.of<User>(dec.convert(data)) is User, true));

	Future<void> saveUser(String data) async { 
		user = Reflector.of<AuthenticatedUser>(dec.convert(data));
		try { await File('test/logs/' + user.id + '.json').writeAsString(enc.convert(user)); }
		catch(e) { print(e); }
	}

	void createImageTest() async {

		File file = File('test/test-image.png');
		String ext = file.uri.pathSegments.last.split('.').last.toUpperCase();
		image = UserImage(user_id: user.id, format: ext, is_profile: true);
		await postRequest('/images', image.data, token: user.token, verify: (String data) {
			image.id = dec.convert(data)['add_image'];
			expect(image.id, isNotNull);
		});

		List<int> bytes = await file.readAsBytes();
		File x = File('test/rewrite-test-image.png');
		await x.writeAsBytes(bytes);
		await putRequest('/images/' + image.id, bytes, token: user.token, verify: (String data) {
			expect(dec.convert(data), equals(image.id));
		});
	}

	void getProfileImageTest() async {

		UserImage testimage;
		await getRequest('/images/profile/' + user.id, token: user.token, verify: (String data) {	
			testimage = Reflector.of<UserImage>(dec.convert(data));
			expect(testimage.user_id, equals(user.id));
		});

		try {
			await getRequest('/images/' + testimage.id + '/content', token: user.token, verify: (dynamic data) {
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

	void getUserImagesTest() async {

		UserImage testimage;
		await getRequest('/images/user/' + user.id, token: user.token, verify: (String data) {	
			testimage = Reflector.of<UserImage>(dec.convert(data)[0]);
			expect(testimage.user_id, equals(user.id));
		});
	}

	void createPostTest() async {

		NewPost newpost = NewPost(user_id: user.id, image_id: image.id, content: _rstr(2048));
		await postRequest('/posts', newpost.data, token: user.token, verify: (String data) {
			postIds.add(dec.convert(data)['create_post']);
			expect(postIds.last, isNotNull);
		});
	}

	void getPostTest() async {

		await getRequest('/posts/' + postIds.last, token: user.token, verify: (dynamic data) {
			post = Reflector.of<Post>(dec.convert(data));
			expect(post.id, equals(postIds.last));
		});
	}

	void getUserPostsTest() async {

		await getRequest('/posts/user/' + user.id, token: user.token, verify: (dynamic data) {
			List<dynamic> items = dec.convert(data);
			List<Post> posts = items.map((item) => Reflector.of<Post>(item)).toList();
			posts.forEach((post) => expect(post.user_id, equals(user.id)));
		});
	}

	void createRoomTest() async {

		NewRoom room = NewRoom(owner_id: user.id, title: _rstr(32), about: _rstr(1024), image_id: image.id);
		await postRequest('/rooms', room.data, token: user.token, verify: (String data) {
			roomId = dec.convert(data)['create_room'];
			expect(roomId, isNotNull);
		});
	}

	void joinRoomTest() async {

		String url = 'ws://' + server.host + ':' + server.port.toString() + '/rooms/chat/' + roomId;
		Map<String, dynamic> headers = { 'Authorization': 'Bearer ' + user.token };
		WebSocket sock = await WebSocket.connect(url, headers: headers);
		
		sock.listen((event) { print(event); });
		sock.add(json.encode({ 'a': 1 }));
		print(sock);
	}

	void deletePostTest() async {
		await deleteRequest('/posts/' + postIds.removeLast(), token: user.token, expected: {'delete_post': true});
	}

	void deleteImageTest() async {
		await deleteRequest('/images/' + image.id, token: user.token, expected: {'delete_image': true});
	}
}