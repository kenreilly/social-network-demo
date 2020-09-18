import 'dart:io';

import 'package:api/framework/api-environment.dart';
import 'package:api/social-client-api.dart';

void main(List<String> args) async {

	String env = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
	await APIEnvironment.load(env);

	SocialClientAPI server = SocialClientAPI(APIEnvironment.env);
	await server.start();

	print('Serving at http://${server.host}:${server.port}');
}