import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:api/framework/data-provider.dart';
import 'package:core/core.dart';
import 'package:shelf/shelf.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:core/hash.dart';

class AuthProvider {

	AuthProvider({ String secret, DB db }) { _secret = secret; _db = db; }

	String _secret;
	DB _db;

	static final JsonEncoder _encoder = const JsonEncoder();
	static final JsonDecoder _decoder = const JsonDecoder();

	static bool _check(Map<String, String> user, Map<String, String> creds) =>
		(user['username'] == creds['username'] && user['password'] == creds['password']);

	FutureOr<Response> handle(Request request) async =>
		(request.url.toString() == 'login')
			? auth(request)
			: verify(request);

	FutureOr<Response> auth(Request request) async {

		try {
			dynamic data = _decoder.convert(await request.readAsString());
			AuthRequest auth = AuthRequest.fromMap(data);

			dynamic result = await _db.query('select authenticate_user(@email, @hashp);', values: auth.data);
			if (result == null) { throw Exception(); }

			AuthenticatedUser user = Serializable.of<AuthenticatedUser>(result[0]);

			JwtClaim claim = JwtClaim(
				subject: _encoder.convert(user.data),
				issuer: 'Social Network Demo',
				audience: ['localhost'],
			);

			String token = issueJwtHS256(claim, _secret);
			return Response.ok(token);
		}
		catch (e) {
			return Response(401, body: 'Incorrect username/password');
		}
	}

	FutureOr<Response> verify(Request request) async {

		try {
			String token = request.headers['Authorization'].replaceAll('Bearer ', '');
			JwtClaim claim = verifyJwtHS256Signature(token, _secret);
			claim.validate(issuer: 'ACME Widgets Corp', audience: 'example.com');
			return null;
		}
		catch(e) {
			return Response.forbidden('Authorization rejected');
		}
	}
}