import 'package:core/types/serializable.dart';

class Room extends Serializable {

	Room({ this.id, this.owner_id, this.image_id, this.title, this.about, this.create_timestamp });

	@serialize
	String id;
	
	@serialize
	String owner_id; 
	
	@serialize
	String image_id;
	
	@serialize
	String title;
	
	@serialize
	String about;
	
	@serialize
	String create_timestamp;
}

class NewRoom extends Serializable {

	NewRoom({ this.owner_id, this.image_id, this.title, this.about });

	@serialize
	String owner_id;

	@serialize
	String image_id;

	@serialize
	String title;
	
	@serialize
	String about;
}