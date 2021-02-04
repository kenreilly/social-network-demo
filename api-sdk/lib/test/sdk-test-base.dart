import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:api_sdk/api-sdk.dart';
import 'package:core/models/test/test-model.dart';
import 'package:test/test.dart';
import 'package:core/core.dart';

abstract class SDKTestBase extends CoreTestBase {

	APIServer server;
	final HttpClient client = HttpClient();
	final String env;
	final List<ServiceBase> services;

	SDKTestBase(this.env, this.services);

	Future<void> run();

	void create() async { server = await APIServer.create(env, services); }
	void startup() async { await server.start(); expect(server.host, isNotNull); }
	void shutdown() async { await server.stop(); expect(server.host, isNull); }

	Future<dynamic> getRequest(String url, { dynamic expected, String token, Function verify }) async {
		
		HttpClientRequest req = await client.get(server.host, server.port, url);
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(expected)) : verify;
		HttpClientResponse res = await req.close();
		return await res.transform(utf8.decoder).listen((x) => callback(x));
	}

	Future<dynamic> postRequest(String url, dynamic content, { String token, Function verify }) async {

		HttpClientRequest req = await client.post(server.host, server.port, url);
		req.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
		return process(req, enc.convert(content), token: token, verify: verify);
	}

	Future<dynamic> putRequest(String url, dynamic content, { String token, Function verify }) async {

		HttpClientRequest req = await client.put(server.host, server.port, url);
		// req.headers.contentType = ContentType('application', 'octet-stream', charset: 'utf-8');
		req.headers.contentType = ContentType('text', 'plain');
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(content)) : verify;
		return await (req..write(base64.encode(content))).close()..transform(utf8.decoder).listen((x) => callback(x));
	}

	Future<dynamic> deleteRequest(String url, { dynamic expected, String token, Function verify }) async {
		
		HttpClientRequest req = await client.delete(server.host, server.port, url);
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(expected)) : verify;
		HttpClientResponse res = await req.close();
		return await res.transform(utf8.decoder).listen((x) => callback(x));
	}

	Future<dynamic> process(HttpClientRequest req, dynamic content, { String token, Function verify }) async {
		
		if (token != null) req.headers.add('Authorization', 'Bearer ' + token);
		Function callback = (verify == null) ? (data) => expect(dec.convert(data), equals(content)) : verify;
		return await (req..write(content)).close()..transform(utf8.decoder).listen((x) => callback(x));
	}
}