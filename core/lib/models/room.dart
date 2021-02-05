import 'package:core/types/serializable.dart';

class Room extends Serializable {

	Room({ this.id, this.owner_id, this.image_id, this.title, this.about, this.create_timestamp });

	String id;
	String owner_id;
	String image_id;
	String title;
	String about;
	DateTime create_timestamp;

	static Room fromMap(Map<String, dynamic> map) => Room(
		id: map['id'],
		owner_id: map['owner_id'],
		image_id: map['image_id'],
		title: map['title'],
		about: map['about'],
		create_timestamp: DateTime.parse(map['create_timestamp'])
	);

	@override
	Map<String, dynamic> toMap() => {
		'id': id,
		'owner_id': owner_id,
		'image_id': image_id,
		'title': title,
		'about': about,
		'create_timestamp': create_timestamp == null ? null : create_timestamp.toIso8601String()
	};
}

class NewRoom extends Serializable {

	NewRoom({ this.owner_id, this.image_id, this.title, this.about });

	String owner_id;
	String image_id;
	String title;
	String about;

	static NewRoom fromMap(Map<String, dynamic> map) => NewRoom(
		owner_id: map['owner_id'],
		image_id: map['image_id'],
		title: map['title'],
		about: map['about'],
	);

	@override
	Map<String, dynamic> toMap() => {
		'owner_id': owner_id,
		'image_id': image_id,
		'title': title,
		'about': about
	};
}