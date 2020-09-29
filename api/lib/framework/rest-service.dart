import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:api/framework/rest-route.dart';
import 'package:core/types/serializable.dart';
import 'package:shelf/shelf.dart';
import 'package:api/framework/rest-method.dart';
import 'dart:mirrors';

abstract class ServiceBase {
	
	InstanceMirror _self;
	ServiceBase() { _self = reflect(this); }
}

class RESTSession {

	Response response;
	final Request request;
	RESTSession(this.request);
}

abstract class RESTService extends ServiceBase {

	static final List<RESTService> _instances = [];

	static final List<RESTRoute> _routes = [];

	RoutePath _route = RoutePath('/');
	
	RESTService(): super() {

		_instances.add(this);
		_self.type.metadata.forEach((m) => (m.reflectee is RoutePath) ? (_route = _route + m.reflectee) : null);
		_self.type.declarations.forEach((Symbol s, DeclarationMirror m) { if (m is MethodMirror) (_load(s, m)); });

		
	}

	static FutureOr<Response> forward(Request request) async {

		RESTSession session = RESTSession(request);
		RESTRoute route = await _routes.firstWhere((route) => route.check(session), orElse: () => null);
		if (route == null) return Response.notFound('Not Found');
		
		try {
			dynamic body = await route.handle(session);
			return Response.ok(body, headers: route.headers);
		} catch(e) {
			return Response.internalServerError();
		}
	}

	void _load(Symbol s, MethodMirror m) {
		
		if (m.metadata.isEmpty) return;
		
		String _verb;
		RoutePath _path;
		bool _json;
		
		m.metadata.forEach((InstanceMirror i) {

			if (i.reflectee == JSON) { _json = true; }
			else if (i.reflectee is RESTMethod) {
				_verb = MirrorSystem.getName(i.type.simpleName);
				_path = _route + RoutePath(i.reflectee.route);
			}
		});
		
		// TODO: fix this
		
		_routes.add(RESTRoute(this, _verb, _path, m, json: _json));
	}
}