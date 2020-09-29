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
	static String imageId;

	static Future<void> run() async {
		
		test('startup', startup);
		test('GET: /', echoTest);
		test('GET: /check/:a', paramTest);
		test('POST: /test-model', modelTest);
		test('POST: /users', userCreateTest);
		test('POST: /auth', authTest);
		test('POST: /users/:id', findUserTest);
		test('POST: /images', createImageTest);
		test('GET: /images/profile/:user_id', getProfileImageTest);
		// test('shutdown', shutdown);
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
		req.headers.contentType = ContentType('application', 'octet-stream', charset: 'utf-8');
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(content)) : verify;
		return await (req..add(content)).close()..transform(utf8.decoder).listen((x) => callback(x));
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

				File file = File('test/retrieved-test-image.' + testimage.format.data.toLowerCase());
				file.writeAsBytes(data);
				expect(testimage.data, equals(image.data));
			});
		}
		catch(e) {
			print(e);
		}
	}
}