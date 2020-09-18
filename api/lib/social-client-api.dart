import 'dart:async';
import 'dart:io';
import 'dart:mirrors';
import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:api/services/echo-service.dart';
import 'package:api/services/user-service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:api/framework/data-provider.dart';

class SocialClientAPI {

	String get host => _server != null ? _server.address.host : null;
	int get port => _server != null ? _server.port : null;

	final Map<String, String> _env; 
	// final Router _router = Router();

	HttpServer _server;
	AuthProvider _authProvider;
	final List<ServiceBase> _services = [];

	SocialClientAPI(this._env);

	void start() async {

		await DataProvider.create(_env);
		
		// _services.add(UserService(_router));
		_services.add(EchoService());

		_authProvider = AuthProvider(secret: _env['JWT_AUTH_TOKEN']);
		_server = await io.serve(RESTService.forward, 'localhost', int.parse(_env['PORT']));

		Timer.periodic(Duration(minutes: 10), (Timer t) => DataProvider.flush());
	}
}