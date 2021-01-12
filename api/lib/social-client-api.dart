import 'dart:io';
import 'dart:async';
import 'package:api/services/room-service.dart';
import 'package:http_server/http_server.dart';
import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/data-provider.dart';
import 'package:api/framework/api-service.dart';
import 'package:api/services/auth-service.dart';
import 'package:api/services/echo-service.dart';
import 'package:api/services/post-service.dart';
import 'package:api/services/user-service.dart';
import 'package:api/services/image-service.dart';

class SocialClientAPI {

	String get host => (_server != null && _server.address != null) ? _server.address.host : null;
	int get port => _server != null ? _server.port : null;

	final Map<String, String> _env;

	HttpServer _server;

	SocialClientAPI(this._env);

	Future<void> start() async {

		AuthProvider.init(_env);
		await DataProvider.create(_env);
		
		AuthService();
		EchoService();
		UserService();
		ImageService();
		PostService();
		RoomService();

		_server = await HttpServer.bind('localhost', int.parse(_env['PORT']));
		_server.transform(HttpBodyHandler()).listen(APIService.onRequest);
		Timer.periodic(Duration(minutes: 10), (Timer t) => DataProvider.flush());
	}

	Future<void> stop() async {
		
		await _server.close();
		_server = null;
	}
}