import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:api_sdk/types/reflector.dart';
import 'package:core/core.dart';
import 'package:http_server/http_server.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class Authenticate extends Decorator { const Authenticate(); }
const authenticate = Authenticate();

abstract class AuthProvider {

	static String _secret;
	static final String _issuer = 'Social Network Demo';
	static final String _audience = 'localhost';

	static final JsonEncoder _encoder = const JsonEncoder();
	static final JsonDecoder _decoder = const JsonDecoder();

	static void init(Map<String, String> env) => _secret = env['JWT_AUTH_SECRET'];

	static JwtClaim claim(Map<String, dynamic> data) =>
		JwtClaim(subject: _encoder.convert(data), issuer: _issuer, audience: [_audience]);

	static void tokenize(AuthenticatedUser user) =>
		(user.token = issueJwtHS256(claim(user.data), _secret));

	static Future<AuthenticatedUser> verify(HttpRequestBody reqbody) async {

		try {
			String token = reqbody.request.headers['Authorization'].first.replaceAll('Bearer ', '');
			JwtClaim claim = verifyJwtHS256Signature(token, _secret);
			claim.validate(issuer: _issuer, audience: _audience);
			return Reflector.of<AuthenticatedUser>(_decoder.convert(claim.subject));
		}
		catch(e) {
			throw Exception('Not Authorized');
		}
	}
}