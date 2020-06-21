enum ImageFormat { JPG, PNG, GIF }

class UserImage {

	UserImage({ this.id, this.format, this.is_profile });

	String id;
	ImageFormat format;
	bool is_profile;

	String get path => id + '.' + format.toString().toLowerCase();

	static UserImage fromJSON(Map<String, dynamic> map) {

		return UserImage(
			id: map['id'], 
			format: map['format'], 
			is_profile: map['is_profile']
		);
	}
}