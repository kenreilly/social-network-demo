import 'dart:io';
import 'dart:convert';
import 'package:api_sdk/api-sdk.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() async {

	try { 
		String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
		SDKTestRunner runner = SDKTestRunner(env, [ TestService() ]);
		runner.run();
	} 
	catch (e) { print(e); }
}

class SDKTestRunner extends SDKTestBase {

	SDKTestRunner(String env, List<ServiceBase> services) :super(env, services);

	@override
	void run() {
		
		test('create', create);
		test('startup', startup);
		test('GET: /', echoTest);
		test('GET: /check/:a', paramTest);
		test('POST: /test-model', modelTest);
		test('shutdown', shutdown);
	}

	void echoTest() async => getRequest('/', expected: 'echo');
	void paramTest() async => getRequest('/check/123', expected: 123);
	
	void modelTest() async => 
		postRequest('/test-model', tmodel.data, verify: (dynamic data) =>
			expect(Serializable.of<TestModel>(dec.convert(data)), equals(tmodel)));
}