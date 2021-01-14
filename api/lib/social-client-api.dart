import 'dart:io';
import 'package:api_sdk/api-server.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:api_sdk/services/test-service.dart';
import 'package:api/services/auth-service.dart';
import 'package:api/services/room-service.dart';
import 'package:api/services/post-service.dart';
import 'package:api/services/user-service.dart';
import 'package:api/services/image-service.dart';

class SocialClientAPIServer extends APIServer {

	static final List<ServiceBase> services = [
		TestService(),
		AuthService(),
		RoomService(),
		PostService(),
		UserService(),
		ImageService()
	];

	SocialClientAPIServer(Map<String, String> env, List<ServiceBase> services): super(env, services);

	static Future<SocialClientAPIServer> create(String envars) async =>
		APIServer.create<SocialClientAPIServer>(envars, services);
}