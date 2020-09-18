import 'dart:io';
import 'dart:convert';
import 'package:api/framework/api-environment.dart';
import 'package:api/social-client-api.dart';
import 'package:test/test.dart';

void main() async {
	
	String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
	await APIEnvironment.load(env);
	await ClientAPITest.run();
}

abstract class ClientAPITest {

	static HttpClient client = HttpClient();

	static Future<void> run() async {

		SocialClientAPI server = SocialClientAPI(APIEnvironment.env);
		await server.start();

		test('GET: /', () async {

			HttpClientResponse res = await (await client.get(server.host, server.port, '/')).close();
			res.transform(utf8.decoder).listen((contents) => expect(contents, equals('echo')));
		});

		test('GET: /check/:a', () async {

			HttpClientResponse res = await (await client.get(server.host, server.port, '/check/1')).close();
			res.transform(utf8.decoder).listen((contents) => expect(contents, equals('1')));
		});
	}
}