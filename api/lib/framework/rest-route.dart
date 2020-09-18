import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/types/serializable.dart';

class RESTRoute {
	
	final String verb;
	final RoutePath route;
	final MethodMirror method;
	final RESTService service;

	List<RouteComponent> components;

	RESTRoute(this.service, this.verb, this.route, this.method) {
		components = RouteComponent.generate(route.path);
	}

	bool check(RESTSession session) {

		if (session.request.url.pathSegments.length + components.length == 0) return true;
		if (session.request.url.pathSegments.length != components.length) return false;

		for (var i = 0; i != components.length; ++i) {
			if (components[i].check(session.request.url.pathSegments[i]) == false) return false;
		}

		return true;
	}

	FutureOr<dynamic> handle(RESTSession session) async => 
		await reflect(service).invoke(method.simpleName, _args(session)).reflectee;

	List<dynamic> _args(RESTSession session) {

		if (components.isEmpty) return [];
		List<String> paths = session.request.url.pathSegments;
		List<dynamic> params = [];
		
		for (var i = 0, p = 0; i != components.length; ++i) {
			
			if (components[i] is RouteParameter) {
				Type t = method.parameters[p].type.reflectedType;
				params.add(parse(t, paths[i]));
				++p;
			} 
		}

		return params;
	}
	
	dynamic parse(Type t, dynamic val) {

		switch (t) {
			
			case (bool):
				return val.toLowerCase() == 'true';
			case (int):
				return int.parse(val);
			case (String):
				return val;
			case (Serializable):
				return Serializable.cast(t, val);
			default:
				return val.toString();
		}
	}
}