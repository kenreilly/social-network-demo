import 'package:core/types/serializable.dart';

class ImageFormat {

	final String name;
	ImageFormat(this.name);

	String get data => name;

	static ImageFormat from(String ext) {

		switch (ext) {

			case 'JPG':
			case 'JPEG': 
				return ImageFormat.JPG;
			case 'PNG': 
				return ImageFormat.PNG;
			case 'GIF': 
				return ImageFormat.GIF;
		}
		return null;
	}

	static final ImageFormat JPG = ImageFormat('JPG');
	static final ImageFormat PNG = ImageFormat('PNG');
	static final ImageFormat GIF = ImageFormat('GIF');
}

extension ImageFormatSerializer on ImageFormat {
	String toJson() => toString().split('.').last;
}

class UserImage extends Serializable {

	UserImage({ this.id, this.user_id, format, this.is_profile, create_timestamp }) : super() {
		this.format = (format is ImageFormat) ? format : ImageFormat.from(format);
		this.create_timestamp = (create_timestamp is DateTime) ? create_timestamp 
			: (create_timestamp == null ? null : DateTime.parse(create_timestamp));
	}

	String id; 
	String user_id;
	ImageFormat format;
	bool is_profile;
	DateTime create_timestamp;
	String get ext => format.name.toLowerCase();

	static UserImage fromMap(Map<String, dynamic> map) => UserImage(
		id: map['id'],
		user_id: map['user_id'],
		format: map['image_format'],
		is_profile: map['is_profile'],
		create_timestamp: DateTime.parse(map['create_timestamp'])
	);

	@override
	Map<String, dynamic> toMap() => {
		'id': id,
		'user_id': user_id,
		'format': format.data,
		'is_profile': is_profile,
		'create_timestamp': create_timestamp == null ? null : create_timestamp.toIso8601String()
	};
}
