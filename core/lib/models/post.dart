
class Post {

	Post({ this.id, this.user_id, this.image_id, this.content, this.create_timestamp });

    String id;
	String user_id; 
	String image_id;
	String content;
    String create_timestamp;

	static Post fromJSON(Map<String, dynamic> map) {

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