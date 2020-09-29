import 'dart:convert';

import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/data-provider.dart';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:core/models/test/test-model.dart';

@RoutePath('/')
class AuthService extends RESTService {

	static final String _query = 'select to_json(authenticate_user(@email, @hashp)) as user;';

	static final JsonEncoder _encoder = JsonEncoder();
	static final JsonDecoder _decoder = JsonDecoder();

	AuthService(): super();

	@JSON
	@POST('/auth')
	Future<dynamic> auth(AuthRequest req) =>
		DataProvider.query(_query, values: req.data).then((res) => _process(res.first.values.first['user'])); 

	dynamic _process(String json) {

		Map<String, dynamic> data = _decoder.convert(json);
		AuthenticatedUser user = Serializable.of<AuthenticatedUser>(data);
		AuthProvider.tokenize(user);
		return user.data;
	}
}