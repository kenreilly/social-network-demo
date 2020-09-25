import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:api/framework/api-environment.dart';
import 'package:api/social-client-api.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() async {
	
	String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
	await APIEnvironment.load(env);
	await ClientAPITest.run();
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

	static Future<void> run() async {
		
		test('startup', startup);
		test('GET: /', echoTest);
		test('GET: /check/:a', paramTest);
		test('POST: /test-model', modelTest);
		test('POST: /users', userCreateTest);
		test('POST: /auth', authTest);
		test('POST: /users/:id', findUserTest);
		test('shutdown', shutdown);
	}

	static void startup() async { await server.start(); expect(server.host, isNotNull); }
	static void shutdown() async { await server.stop(); expect(server.host, isNull); }

	static dynamic _getRequest(String url, { dynamic expected, String token, Function verify }) async {
		
		HttpClientRequest req = await client.get(server.host, server.port, url);
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(expected)) : verify;
		return await req.close()..transform(utf8.decoder).listen((x) => callback(x));
	}

	static dynamic _postRequest(String url, dynamic content, { String token, Function verify }) async {

		HttpClientRequest req = await client.post(server.host, server.port, url);
		req.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(content)) : verify;
		return await (req..write(enc.convert(content))).close()..transform(utf8.decoder).listen((x) => callback(x));
	}

	static void echoTest() async => _getRequest('/', expected: 'echo');
	static void paramTest() async => _getRequest('/check/123', expected: 123); 
	static void modelTest() async => _postRequest('/test-model', tmodel.data);

	static void userCreateTest() async => 
		_postRequest('/users', randuser.data, verify: (String data) => 
			expect(dec.convert(data)['create_user'].isNotEmpty, equals(true)));

	static void authTest() async =>
		_postRequest('/auth', auth.data, verify: (String data) {
			saveUser(data); expect(user is AuthenticatedUser, true); });
	
	static void findUserTest() async =>
		_getRequest('/users/' + user.id, token: user.token, verify: (String data) => 
			expect(Serializable.of<User>(dec.convert(data)) is User, true));

	static void saveUser(String data) { 
		user = Serializable.of<AuthenticatedUser>(dec.convert(data));
		try { File('logs/' + user.id + '.json').writeAsString(enc.convert(user)); }
		catch(e) { print(e); }
	}
}