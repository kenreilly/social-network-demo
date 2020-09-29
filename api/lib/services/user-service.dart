import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/models/user.dart';
import 'package:api/framework/data-provider.dart';
import 'package:core/types/serializable.dart';

abstract class UserQuery {

	static final String list = 'SELECT id, first_name, last_name FROM users';
	static final String find = 'SELECT id, first_name, last_name FROM users WHERE id = @id';
	static final String create = 'SELECT create_user((@email, @hashp, @first_name, @last_name)::new_user)';
}

@RoutePath('/users')
class UserService extends RESTService {

	UserService(): super();

	@JSON
	@GET('/')
	@authenticate
	Future<List<User>>list() async =>
		await DataProvider.query(UserQuery.list);

	@JSON
	@GET('/:id')
	@authenticate
	Future<User>find(String id) async =>
		Serializable.of<User>((await DataProvider.query(UserQuery.find, values: {'id':id})).first.values.first);

	@JSON
	@POST('/')
	Future<Map<String, dynamic>>create(NewUser info) async =>
		(await DataProvider.query(UserQuery.create, values: info.data)).first.values.first;
}