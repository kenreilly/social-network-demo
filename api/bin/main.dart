import 'dart:io';
import 'package:api/social-client-api.dart';

void main(List<String> args) async {

	
	String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
	SocialClientAPIServer server = await SocialClientAPIServer.create(env);
	await server.start();
	
	print('Serving at http://${server.host}:${server.port}');
}