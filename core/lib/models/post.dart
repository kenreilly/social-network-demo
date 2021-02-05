import 'package:core/types/serializable.dart';

class Post extends Serializable {

	Post({ this.id, this.user_id, this.image_id, this.content, this.create_timestamp });

	String id;
	String user_id;
	String image_id;
	String content;
	DateTime create_timestamp;

	static Post fromMap(Map<String, dynamic> map) => Post(
		id: map['id'],
		user_id: map['user_id'],
		image_id: map['image_id'],
		content: map['content'],
		create_timestamp: DateTime.parse(map['create_timestamp'])
	);

	@override
	Map<String, dynamic> toMap() => {
		'id': id,
		'user_id': user_id,
		'image_id': image_id,
		'content': content,
		'create_timestamp': create_timestamp == null ? null : create_timestamp.toIso8601String()
	};
}

class NewPost extends Serializable {

	NewPost({ this.user_id, this.image_id, this.content });

	String user_id;
	String image_id;
	String content;

  	static NewPost fromMap(Map<String, dynamic> map) => NewPost(
		user_id: map['user_id'],
		image_id: map['image_id'],
		content: map['content'],
	);

	@override
	Map<String, dynamic> toMap() => {
		'user_id': user_id,
		'image_id': image_id,
		'content': content
	};
}