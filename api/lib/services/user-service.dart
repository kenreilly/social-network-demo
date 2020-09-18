import 'package:shelf_router/shelf_router.dart';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/models/user.dart';
import 'package:api/framework/data-provider.dart';

// @RoutePath('/users')
class UserService extends RESTService {

	UserService(): super();

	@GET('/')
	Future<List<User>>list() async => 
		await DataProvider.query('SELECT id, email FROM users');

	@GET('/:id')
	Future<User>getByID(int id) async =>
		(await DataProvider.query('SELECT id, email FROM users WHERE id = @id', values: { 'id': id })).first as User;

	@POST('/')
	Future<int>create(NewUser info) async => 
		(await DataProvider.query('SELECT create_user((@email, @password, @firstname, @lastname)::new_user)', values: info.data)) as int;
}