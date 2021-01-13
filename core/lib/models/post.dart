import 'package:core/types/serializable.dart';

class Post extends Serializable {

	Post({ this.id, this.user_id, this.image_id, this.content, this.create_timestamp });

	@serialize
	String id;
	
	@serialize
	String user_id; 
	
	@serialize
	String image_id;
	
	@serialize
	String content;
	
	@serialize
	String create_timestamp;
}

class NewPost extends Serializable {

	NewPost({ this.user_id, this.image_id, this.content });

	@serialize
	String user_id;

	@serialize
	String image_id;

	@serialize
	String content;
}
