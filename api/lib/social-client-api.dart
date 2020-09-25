import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/rest-service.dart';
import 'package:api/services/auth-service.dart';
import 'package:api/services/echo-service.dart';
import 'package:api/services/user-service.dart';
import 'package:api/framework/data-provider.dart';

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

		_server = await io.serve(RESTService.forward, 'localhost', int.parse(_env['PORT']));
		Timer.periodic(Duration(minutes: 10), (Timer t) => DataProvider.flush());
	}

	Future<void> stop() async {
		
		await _server.close();
		_server = null;
	}
}