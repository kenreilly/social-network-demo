import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:api/framework/data-provider.dart';
import 'package:core/core.dart';
import 'package:shelf/shelf.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:core/hash.dart';

class Authenticate extends Decorator { const Authenticate(); }
const authenticate = Authenticate();

abstract class AuthProvider {

	static String _secret;
	static final String _issuer = 'Social Network Demo';

	static final JsonEncoder _encoder = const JsonEncoder();
	static final JsonDecoder _decoder = const JsonDecoder();

	static void init(Map<String, String> env) => _secret = env['JWT_AUTH_SECRET'];

	static JwtClaim claim(Map<String, dynamic> data) =>
		JwtClaim(subject: _encoder.convert(data), issuer: _issuer, audience: ['localhost']);

	static void tokenize(AuthenticatedUser user) =>
		(user.token = issueJwtHS256(claim(user.data), _secret));

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