import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/models/user.dart';
import 'package:api/framework/data-provider.dart';
import 'package:core/types/serializable.dart';

abstract class PostQuery {

	// static final String newImage = 'SELECT id, first_name, last_name FROM users';
	// static final String find = 'SELECT id, first_name, last_name FROM users WHERE id = @id';
	// static final String create = 'SELECT create_user((@email, @hashp, @first_name, @last_name)::new_user)';
}

@RoutePath('/posts')
class PostService extends RESTService {

	PostService(): super();

	// @GET('/')
	// @authenticate
	// Future<List<User>>list() async =>
	// 	await DataProvider.query(UserQuery.list);

	// @GET('/:id')
	// @authenticate
	// Future<User>find(String id) async =>
	// 	Serializable.of<User>((await DataProvider.query(UserQuery.find, values: {'id':id})).first.values.first);

	// @POST('/')
	// Future<Map<String, dynamic>>create(NewUser info) async =>
	// 	(await DataProvider.query(UserQuery.create, values: info.data)).first.values.first;
}