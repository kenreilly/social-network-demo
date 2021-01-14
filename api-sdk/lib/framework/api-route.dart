import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'package:core/core.dart';
import 'package:http_server/http_server.dart';
import 'package:api_sdk/framework/auth-provider.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:api_sdk/framework/api-method.dart';

class APIRoute {
	
	final String verb;
	final RoutePath route;
	final MethodMirror method;
	final APIService service;
	
	bool json = false;
	bool auth = false;

	List<RouteComponent> components;
	Type get format => method.parameters.last.type.reflectedType;

	Map<String, String> get headers => 
		{ 'content-type': (json == true ? 'application/json' : 'multipart/byteranges') };

	static final JsonEncoder _encoder = const JsonEncoder();
	static final JsonDecoder _decoder = const JsonDecoder();
	static final Utf8Decoder _utfdecoder = const Utf8Decoder();

	APIRoute(this.service, this.verb, this.route, this.method, { this.json = false }) {
		components = RouteComponent.generate(route.path);
		auth = method.metadata.where((InstanceMirror i) { 
			return (i.reflectee is Authenticate);
		}).isNotEmpty;
	}

	bool check(HttpRequest request) {
		
		if (request.method != verb && verb != 'WS') return false;
		if (request.uri.pathSegments.length + components.length == 0) return true;
		if (request.uri.pathSegments.length != components.length) return false;

		for (var i = 0; i != components.length; ++i) {
			if (components[i].check(request.uri.pathSegments[i]) == false) return false;
		}

		return true;
	}

	Future<dynamic> handle(HttpRequestBody session, { WebSocket socket }) async {

		if (verb == 'WS') {
			print(verb);
		}

		Map<Symbol, dynamic> params = {};
		if (auth && method.parameters.where((p) => p.type.reflectedType == AuthenticatedUser).isNotEmpty) { 
			params[Symbol('user')] = await AuthProvider.verify(session);
		}

		if (socket != null) { params[Symbol('socket')] = socket; }
		return await _format(await _invoke(session, params));
	}

	Future<dynamic> upgrade(HttpRequestBody session) async =>
		handle(session, socket: await WebSocketTransformer.upgrade(session.request));
	
	Future<dynamic> _invoke(HttpRequestBody session, Map<Symbol, dynamic> params) async {
		dynamic args = await _args(session);
		return (await reflect(service).invoke(method.simpleName, args, params).reflectee);
	}

	dynamic _format(dynamic result) => 
		(json == true) ? _encoder.convert(result) : result;

	Future<List<dynamic>> _args(HttpRequestBody session) async {

		List<dynamic> params = [];
		List<String> paths = session.request.uri.pathSegments;
		
		for (var i = 0, p = 0; i != components.length; ++i) {
			if (components[i] is RouteParameter) {
				Type t = method.parameters[p].type.reflectedType;
				params.add(_parse(t, paths[i]));
				++p;
			}
		}

		switch (verb) {
			case 'POST':
				return Future.value(params..add(_parse(format, session.body)));
			case 'PUT':
				return Future.value(params..add(base64.decode(session.body)));
			case 'GET':
			default:
				return Future.value(params);
		}
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