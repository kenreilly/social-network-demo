import 'dart:io';
import 'package:api_sdk/framework/auth-provider.dart';
import 'package:api_sdk/framework/data-provider.dart';
import 'package:api_sdk/framework/api-method.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:core/types/serializable.dart';
import 'package:core/models/image.dart';
import 'package:core/models/user.dart';

abstract class ImageQuery {

	// static final String list = 'SELECT id, first_name, last_name FROM users';
	static final String find = 'SELECT id, user_id, format, create_timestamp FROM images WHERE id = @id';
	static final String user = 'SELECT id, user_id, format, create_timestamp FROM images WHERE user_id = @user_id';
	static final String create = 'SELECT add_image((@user_id, @format, @is_profile)::new_image)';
	static final String profile = 'SELECT id, user_id, format, create_timestamp, is_profile FROM images WHERE user_id = @user_id AND is_profile = true';
	static final String delete = 'SELECT delete_image(@id)';
}

@RoutePath('/images')
class ImageService extends APIService {

	static final dir = Uri.directory('../userdata/images');

	ImageService(): super();

	@JSON
	@POST('/')
	@authenticate
	Future<dynamic> create(UserImage image) async => 
		DataProvider.queryOne(ImageQuery.create, values: image.data);

	@JSON
	@GET('/:id')
	@authenticate
	Future<UserImage> find(String id) async =>
		Serializable.of<UserImage>(await DataProvider.queryOne(ImageQuery.find, values: { 'id': id }));

	@JSON
	@GET('/profile/:user_id')
	@authenticate
	Future<UserImage> profile(String user_id) async =>
		Serializable.of<UserImage>(await DataProvider.queryOne(ImageQuery.profile, values: { 'user_id': user_id }));

	@JSON
	@GET('/user/:user_id')
	@authenticate
	Future<List<UserImage>>user(String user_id) async {
		List<UserImage> images = [];
		List<dynamic> result = (await DataProvider.query(ImageQuery.user, values: { 'user_id': user_id }));
		await result.forEach((element) => images.add(Serializable.of<UserImage>(element.values.first)));
		return images;
	}

	@GET('/:id/content')
	@authenticate
	Future<File> content(String id) async =>
		File(dir.path + '/' + id + '.' + (await find(id)).ext);

	@JSON
	@PUT('/:id')
	@authenticate
	Future<dynamic> upload(String id, List<int> data, { AuthenticatedUser user }) async {
		UserImage img = await find(id);
		if (img.user_id != user.id) throw Exception('Not authorized');
		return await File(dir.path + '/' + id + '.' + img.ext).writeAsBytes(data).then((value) => id);
	}	
	
	@JSON
	@DELETE('/:id')
	@authenticate
	Future<dynamic> delete(String id, { AuthenticatedUser user }) async {
		UserImage img = await find(id);
		if (img.user_id != user.id) throw Exception('Not authorized');
		await File(dir.path + '/' + id + '.' + img.ext).delete();
		return DataProvider.queryOne(ImageQuery.delete, values: { 'id': id });
	}
}