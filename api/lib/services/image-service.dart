import 'dart:io';

import 'package:api/framework/auth-provider.dart';
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/models/image.dart';
import 'package:core/models/user.dart';
import 'package:api/framework/data-provider.dart';
import 'package:core/types/serializable.dart';

abstract class ImageQuery {

	// static final String list = 'SELECT id, first_name, last_name FROM users';
	static final String find = 'SELECT id, user_id, format, create_timestamp FROM images WHERE id = @id';
	static final String create = 'SELECT add_image((@user_id, @format, @is_profile)::new_image)';
	static final String profile = 'SELECT id, user_id, format, create_timestamp FROM images WHERE user_id = @user_id AND is_profile = true';
}

@RoutePath('/images')
class ImageService extends RESTService {

	final dir = Uri.directory( '../userdata/images');

	ImageService(): super();

	@JSON
	@POST('/')
	@authenticate
	Future<dynamic> create(UserImage image) async => 
		(await DataProvider.query(ImageQuery.create, values: image.data)).first.values.first;

	@JSON
	@PUT('/:id')
	@authenticate
	Future<dynamic> upload(String id, List<int> data) async => 
		await File(dir.path + '/' + id).writeAsBytes(data).then((value) => id);

	@JSON
	@GET('/:id')
	@authenticate
	Future<List<User>> find(String id) async =>
		(await DataProvider.query(ImageQuery.find, values: {'id': id })).first.values.first;

	@JSON
	@GET('/profile/:user_id')
	@authenticate
	Future<UserImage> profile(String user_id) async {
		dynamic res = (await DataProvider.query(ImageQuery.profile, values: {'user_id': user_id }));
		return Serializable.of<UserImage>(res.first.values.first);
	}
	
	@GET('/:id/content')
	@authenticate
	Future<Stream<List<int>>> content(String id) async => 
		await File(dir.path + '/' + id).openRead();
}