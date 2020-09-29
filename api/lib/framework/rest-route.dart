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
	
	bool json = false;

	List<RouteComponent> components;

	Map<String, String> get headers => 
		// { 'content-type': 'application/' + ((json == true) ? 'json' : 'octet-stream') };
		{ 'content-type': (json == true ? 'application/json' : 'multipart/byteranges') };
		// (json == true) ? { 'content-type': 'application/json' } : { };

	static final JsonEncoder _encoder = const JsonEncoder();
	static final JsonDecoder _decoder = const JsonDecoder();

	static final Utf8Decoder _utfdecoder = const Utf8Decoder();

	RESTRoute(this.service, this.verb, this.route, this.method, { this.json = false }) {
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
		await _authorize(session).then((_) async => _format(await _invoke(session)));

	Future<dynamic> _authorize(RESTSession session) async => true;

	Future<dynamic> _invoke(RESTSession session) async => 
		(await reflect(service).invoke(method.simpleName, await _args(session)).reflectee);

	dynamic _format(dynamic result) => 
		(json == true) ? _encoder.convert(result) : result;

	Future<List<dynamic>> _args(RESTSession session) async {

		List<dynamic> params = [];
		List<String> paths = session.request.url.pathSegments;
		
		for (var i = 0, p = 0; i != components.length; ++i) {
			
			if (components[i] is RouteParameter) {
				Type t = method.parameters[p].type.reflectedType;
				params.add(_parse(t, paths[i]));
				++p;
			}
		}
		
		if (verb == 'POST') {
			Type t = method.parameters.last.type.reflectedType;
			String body = await session.request.readAsString();
			params.add(_parse(t, _decoder.convert(body)));
			
		}

		if (verb == 'PUT') {
			await session.request.read().listen((x) => params.add(x));
		}
		
		return Future.value(params);
	}

	dynamic _parse(Type t, dynamic val) {

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