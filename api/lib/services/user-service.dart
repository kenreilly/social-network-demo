import 'package:api_sdk/framework/auth-provider.dart';
import 'package:api_sdk/framework/api-method.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:api_sdk/framework/data-provider.dart';
import 'package:api_sdk/types/reflector.dart';
import 'package:core/models/user.dart';

abstract class UserQuery {

	static final String list = 'SELECT id, first_name, last_name FROM users';
	static final String find = 'SELECT id, first_name, last_name FROM users WHERE id = @id';
	static final String create = 'SELECT create_user((@email, @hashp, @first_name, @last_name)::new_user)';
}

@RoutePath('/users')
class UserService extends APIService {

	UserService(): super();

	@JSON
	@GET('/')
	@authenticate
	Future<List<User>>list() async =>
		await DataProvider.query(UserQuery.list);

	@JSON
	@GET('/me')
	@authenticate
	Future<User>me({ AuthenticatedUser user }) async =>
		Reflector.of<User>(await DataProvider.queryOne(UserQuery.find, values: {'id': user.id}));

	@JSON
	@GET('/:id')
	@authenticate
	Future<User>find(String id) async =>
		Reflector.of<User>(await DataProvider.queryOne(UserQuery.find, values: {'id':id}));

	@JSON
	@POST('/')
	Future<Map<String, dynamic>>create(NewUser info) async =>
		await DataProvider.queryOne(UserQuery.create, values: info.data);
}