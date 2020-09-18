import 'package:core/types/serializable.dart';

class Post extends Serializable {

	Post({ this.id, this.user_id, this.image_id, this.content, this.create_timestamp });

	String id;
	String user_id; 
	String image_id;
	String content;
	String create_timestamp;

	Map<String, dynamic> get data => {
		'id': id,
		'user_id': user_id,
		'image_id': image_id,
		'content': content,
		'create_timestamp': create_timestamp,
	};

	static Post fromMap(Map<String, dynamic> map) {

		return Post(
			id: map['id'], 
			user_id: map['user_id'], 
			image_id: map['image_id'],
			content: map['content'],
			create_timestamp: map['create_timestamp']
		);
	}
}

class NewPost {

	NewPost({ this.user_id, this.image_id, this.content });

	String user_id;
	String image_id;
	String content;
}
