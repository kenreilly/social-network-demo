import 'package:core/types/serializable.dart';

class ImageFormat extends Serializable {

	final String name;
	ImageFormat(this.name);

	@override
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

// extension DateTimeSerializer on DateTime {
// 	String toJson() => toString().split('.').last;
// }

class UserImage extends Serializable {

	UserImage({ this.id, this.user_id, format, this.is_profile, create_timestamp }) : super() {
		this.format = (format is ImageFormat) ? format : ImageFormat.from(format);
		this.create_timestamp = (create_timestamp is DateTime) ? create_timestamp 
			: (create_timestamp == null ? null : DateTime.parse(create_timestamp));
	}

	@serialize
	String id;

	@serialize 
	String user_id;

	@serialize
	ImageFormat format;
	
	@serialize
	bool is_profile;

	@serialize
	DateTime create_timestamp;

	String get ext => format.name.toLowerCase();

	@override
	Map<String, dynamic> get data => 
		super.data..update('create_timestamp', (_) => create_timestamp == null ? null : create_timestamp.toIso8601String());
}
