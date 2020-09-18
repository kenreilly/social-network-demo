import 'package:core/types/serializable.dart';

enum ImageFormat { JPG, PNG, GIF }

class UserImage extends Serializable {

	UserImage({ this.id, this.format, this.is_profile });

	String id;
	ImageFormat format;
	bool is_profile;

	String get path => id + '.' + format.toString().toLowerCase();

	@override
	Map<String, dynamic> get data => {
		'id': id,
		'format': format,
		'is_profile': is_profile
	};

	static UserImage fromMap(Map<String, dynamic> map) {

		return UserImage(
			id: map['id'], 
			format: map['format'], 
			is_profile: map['is_profile']
		);
	}
}
