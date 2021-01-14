import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:api_sdk/framework/auth-provider.dart';
import 'package:api_sdk/framework/data-provider.dart';
import 'package:api_sdk/framework/api-method.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:core/types/serializable.dart';
import 'package:core/core.dart';

abstract class RoomQuery {

	static final String list = 'SELECT title, about FROM rooms LIMIT 256';
	static final String find = 'SELECT id, first_name, last_name FROM users WHERE id = @id';
	static final String create = 'SELECT create_room((@owner_id, @image_id, @title, @about)::new_room)';
}

@RoutePath('/rooms')
class RoomService extends APIService {

	static Map<String, List<WebSocket>> rooms = {};
	static Map<User, StreamSubscription> streams = {};

	static JsonDecoder _decoder = JsonDecoder();

	RoomService(): super();

	@JSON
	@GET('/')
	@authenticate
	Future<List<User>>list() async =>
		await DataProvider.query(RoomQuery.list);

	@JSON
	@GET('/mine')
	@authenticate
	Future<User>mine({ AuthenticatedUser user }) async =>
		Serializable.of<User>(await DataProvider.queryOne(RoomQuery.find, values: {'user_id': user.id}));

	@JSON
	@GET('/:id')
	@authenticate
	Future<User>find(String id) async =>
		Serializable.of<User>(await DataProvider.queryOne(RoomQuery.find, values: {'id':id}));

	@JSON
	@POST('/')
	Future<Map<String, dynamic>>create(NewRoom info) async =>
		await DataProvider.queryOne(RoomQuery.create, values: info.data);

	@WS('/chat/:id')
	@authenticate
	Future<void> chat(String id, { AuthenticatedUser user, WebSocket socket }) {

		if (!rooms.containsKey(id)) rooms[id] = [];
		streams[user] = socket.listen((event) => incoming(id, user, event));
		rooms[id].add(socket);
		return null;
	}

	Future<void> incoming(String id, AuthenticatedUser user, dynamic event) async {
		
		dynamic data = _decoder.convert(event);
		print(id);
		print(user);
		print(event);
	}
}