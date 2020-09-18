import 'dart:async';
import 'dart:convert';
import 'package:api/framework/rest-route.dart';
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

	JsonEncoder _encoder = JsonEncoder();

	RoutePath _route = RoutePath('/');
	
	RESTService(): super() {

		_instances.add(this);
		// class and function metadata
		_self.type.metadata.forEach((m) => (m.reflectee is RoutePath) ? (_route = _route + m.reflectee) : null); 
		_self.type.declarations.forEach((Symbol s, DeclarationMirror m) => (_load(s, m as MethodMirror)));
	}

	static FutureOr<Response> forward(Request request) async {

		RESTSession session = RESTSession(request);
		RESTRoute route = await _routes.firstWhere((route) => route.check(session), orElse: () => null);
		
		if (route == null) return Response.notFound('Not Found');

		dynamic result = await route.handle(session);
		return Response.ok(result.toString());
	}

	void _load(Symbol s, MethodMirror m) {
		
		if (m.metadata.isEmpty) return;
		
		String _verb = MirrorSystem.getName(m.metadata.first.type.simpleName);
		RoutePath _path = _route + RoutePath(m.metadata.single.reflectee.route);
		_routes.add(RESTRoute(this, _verb, _path, m));
	}
}