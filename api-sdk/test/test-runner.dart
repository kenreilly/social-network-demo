import 'dart:async';
import 'dart:io';
import 'package:api_sdk/api-sdk.dart';
import 'package:api_sdk/types/reflector.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

void main() async {

	try { 
		String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
		SDKTestRunner runner = SDKTestRunner(env, [ TestService() ]);
		await runner.run();
		exit(0); // todo: what is keeping this process alive?
	} 
	catch (e) { print(e); }
}

class SDKTestRunner extends SDKTestBase {

	SDKTestRunner(String env, List<ServiceBase> services) :super(env, services);

	@override
	Future<void> run() async {

		Completer completer = Completer();
		Map<String, Function> tests = {
			'create': create,
			'startup': startup,
			'GET: /': echoTest,
			'GET: /check/:a': paramTest,
			'POST: /test-model': modelTest,
			'shutdown': shutdown,
			'done': completer.complete,
		};

		group('API SDK - ', () => tests.forEach((k, v) => test(k, v)));
		return completer.future;
	}

	void echoTest() async => getRequest('/', expected: 'echo');
	void paramTest() async => getRequest('/check/123', expected: 123);
	
	void modelTest() async => 
		postRequest('/test-model', tmodel.data, verify: (dynamic data) =>
			expect(Reflector.of<TestModel>(dec.convert(data)), equals(tmodel)));
}