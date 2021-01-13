import 'dart:io';
import 'dart:convert';
import 'dart:mirrors';
import 'package:api/framework/api-method.dart';
import 'package:api/framework/api-route.dart';
import 'package:http_server/http_server.dart';

abstract class ServiceBase {
	
	InstanceMirror _self;
	ServiceBase() { _self = reflect(this); }
}

class RESTSession {

	final HttpRequestBody body;
	RESTSession(this.body);
}

abstract class APIService extends ServiceBase {

	static final List<APIService> _instances = [];

	static final List<APIRoute> _routes = [];

	RoutePath _route = RoutePath('/');

	VirtualDirectory vd;
	
	APIService(): super() {

		_instances.add(this);
		_self.type.metadata.forEach((m) => (m.reflectee is RoutePath) ? (_route = _route + m.reflectee) : null);
		_self.type.declarations.forEach((Symbol s, DeclarationMirror m) { if (m is MethodMirror) (_load(s, m)); });
	}

	static void onRequest(HttpRequestBody reqbody) async {

		HttpResponse response = reqbody.request.response;

		APIRoute route = await _routes.firstWhere((route) => route.check(reqbody.request), orElse: () => null);
		if (route == null) {
			await (response..statusCode = 404)..write('NotFound');
			await response.close();
			return;
		}

		if (route.verb == 'WS') { return route.upgrade(reqbody); }
		
		try {
			dynamic data = await route.handle(reqbody);
			response.statusCode = 200;

			if (data is String) {
				response.write(data);
			}
			else if (data is File) {
				List<int> bytes = await data.readAsBytes();
				response.write(base64.encode(bytes));
			}
			else {
				await response.add(data);
			}
		} catch(e) {
			response.addError(e);
		}

		await response.close();
	}

	void _load(Symbol s, MethodMirror m) {
		
		if (m.metadata.isEmpty) return;
		
		String _verb;
		RoutePath _path;
		bool _json;
		
		m.metadata.forEach((InstanceMirror i) {

			if (i.reflectee == JSON) { _json = true; }
			else if (i.reflectee is APIMethod) {
				_verb = MirrorSystem.getName(i.type.simpleName);
				_path = _route + RoutePath(i.reflectee.route);
			}
		});
		
		_routes.add(APIRoute(this, _verb, _path, m, json: _json));
	}
}