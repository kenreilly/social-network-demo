import 'dart:io';
import 'dart:async';
import 'package:http_server/http_server.dart';
import 'package:api_sdk/framework/auth-provider.dart';
import 'package:api_sdk/framework/data-provider.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

class APIServer {

	String get host => (_server != null && _server.address != null) ? _server.address.host : null;
	int get port => _server != null ? _server.port : null;

	final Map<String, String> env;
	final List<ServiceBase> _services;
	HttpServer _server;

	APIServer(this.env, this._services);

	static Future<T> create<T>(String _envpath, List<ServiceBase> services) async {

		await dotenv.load(_envpath);
		await DataProvider.create(dotenv.env);
		AuthProvider.init(dotenv.env);
		return APIServer(dotenv.env, services) as T;
	}

	Future<void> start() async {

		_server = await HttpServer.bind('localhost', int.parse(env['PORT']));
		_server.transform(HttpBodyHandler()).listen(APIService.onRequest);
		Timer.periodic(Duration(minutes: 10), (Timer t) => DataProvider.flush());
	}

	Future<void> stop() async {
		
		await _server.close();
		_server = null;
		_services.forEach((service) => service.dispose());
		_services.clear();
	}
}