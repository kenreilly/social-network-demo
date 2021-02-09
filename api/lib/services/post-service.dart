import 'package:core/core.dart';
import 'package:api_sdk/types/reflector.dart';
import 'package:api_sdk/framework/auth-provider.dart';
import 'package:api_sdk/framework/data-provider.dart';
import 'package:api_sdk/framework/api-route.dart';
import 'package:api_sdk/framework/api-method.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:core/models/user.dart';

abstract class PostQuery {

	// static final String newImage = 'SELECT id, first_name, last_name FROM users';
	static final String find = 'SELECT id, user_id, image_id, content FROM posts WHERE id = @id';
	static final String user = 'SELECT id, user_id, image_id, content FROM posts WHERE user_id = @user_id';
	static final String create = 'SELECT create_post((@user_id, @image_id, @content)::new_post)';
	static final String delete = 'SELECT delete_post(@id)';
}

@RoutePath('/posts')
class PostService extends APIService {

	PostService(): super();

	@JSON
	@POST('/')
	Future<dynamic>create(NewPost info) async =>
		DataProvider.queryOne(PostQuery.create, values: info.data);

	@JSON
	@GET('/:id')
	@authenticate
	Future<Post>find(String id) async =>
		Reflector.of<Post>(await DataProvider.queryOne(PostQuery.find, values: {'id':id}));

	@JSON
	@GET('/user/:user_id')
	@authenticate
	Future<List<Post>>user(String user_id) async {
		List<Post> posts = [];
		List<dynamic> result = (await DataProvider.query(PostQuery.user, values: {'user_id':user_id}));
		await result.forEach((element) => posts.add(Reflector.of<Post>(element.values.first)));
		return posts;
	}

	@JSON
	@DELETE('/:id')
	@authenticate
	Future<dynamic>delete(String id, { AuthenticatedUser user }) async {
		if ((await find(id)).user_id != user.id) throw Exception('Not authorized');
		return DataProvider.queryOne(PostQuery.delete, values: { 'id': id });
	}
}