import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/types/serializable.dart';
import 'package:shelf/shelf.dart';

class RESTRoute {
	
	final String verb;
	final RoutePath route;
	final MethodMirror method;
	final RESTService service;

	List<RouteComponent> components;

	final JsonDecoder _decoder = JsonDecoder();

	RESTRoute(this.service, this.verb, this.route, this.method) {
		components = RouteComponent.generate(route.path);
	}

	bool check(RESTSession session) {
		
		if (session.request.method != verb) return false;
		if (session.request.url.pathSegments.length + components.length == 0) return true;
		if (session.request.url.pathSegments.length != components.length) return false;

		for (var i = 0; i != components.length; ++i) {
			if (components[i].check(session.request.url.pathSegments[i]) == false) return false;
		}

		return true;
	}

	Future<dynamic> handle(RESTSession session) async => 
		await authorize(session).then((_) async => invoke(session));

	Future<dynamic> authorize(RESTSession session) async => true;

	Future<dynamic> invoke(RESTSession session) async => 
		(await reflect(service).invoke(method.simpleName, await _args(session)).reflectee);

	Future<List<dynamic>> _args(RESTSession session) async {

		List<dynamic> params = [];

		if (verb == 'POST') {
			Type t = method.parameters.first.type.reflectedType;
			String body = await session.request.readAsString();
			params.add(parse(t, _decoder.convert(body)));
			return Future.value(params);
		}
		
		if (components.isEmpty) return [];
		List<String> paths = session.request.url.pathSegments;
		
		for (var i = 0, p = 0; i != components.length; ++i) {
			
			if (components[i] is RouteParameter) {
				Type t = method.parameters[p].type.reflectedType;
				params.add(parse(t, paths[i]));
				++p;
			}
		}

		return Future.value(params);
	}

	dynamic parse(Type t, dynamic val) {

		if (Serializable.isSerializable(reflectClass(t))) return Serializable.cast(t, val);

		switch (t) {
			
			case (bool):
				return val.toLowerCase() == 'true';
			case (int):
				return int.parse(val);
			case (String):
				return val;
			default:
				return val.toString();
		}
	}
}