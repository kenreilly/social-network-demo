import 'dart:typed_data';

import 'package:core/types/serializable.dart';

enum ImageFormat { JPG, PNG, GIF }

class UserImage extends Serializable {

	UserImage({ this.id, this.format, this.is_profile, this.image_data });

	@serialize
	String id;

	@serialize
	ImageFormat format;
	
	@serialize
	bool is_profile;
	
	@serialize
	ByteData image_data;

	// String get path => id + '.' + format.toString().toLowerCase();

	@override
	Map<String, dynamic> get data => {
		'id': id,
		'format': format,
		'is_profile': is_profile,
		// 'image_data': 
	};

	static UserImage fromMap(Map<String, dynamic> map) {

		return UserImage(
			id: map['id'], 
			format: map['format'], 
			is_profile: map['is_profile']
		);
	}
}
