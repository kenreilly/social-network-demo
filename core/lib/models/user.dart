import 'package:core/types/serializable.dart';

class User extends Serializable {

	User({ this.id, this.first_name, this.last_name });

	@serialize
	String id;

	@serialize
	String first_name;

	@serialize
	String last_name;

	// static User fromJSON(Map<String, dynamic> map) {

	// 	return User(
	// 		id: map['id'], 
	// 		first_name: map['first_name'], 
	// 		last_name: map['last_name'],
	// 	);
	// }
}

class AuthenticatedUser extends User {

	AuthenticatedUser({ id, first_name, last_name, this.auth_timestamp }) 
		: super(id: id, first_name: first_name, last_name: last_name);

	String auth_timestamp;

	// static User fromJSON(Map<String, dynamic> map) {

	// 	return AuthenticatedUser(
	// 		id: map['id'],
	// 		first_name: map['first_name'],
	// 		last_name: map['last_name'],
	// 		auth_timestamp: map['auth_timestamp']
	// 	);
	// }

	// Map<String, dynamic> get data => { 
	// 	'id': id,
	// 	'first_name': first_name,
	// 	'last_nane': last_name,
	// 	'auth_timestamp': auth_timestamp
	// };
}

class NewUser {

	NewUser({ this.email, this.password, this.first_name, this.last_name });

	String email;
	String password;
	String first_name;
	String last_name;

	Map<String, dynamic> get data => { 
		'email': email,
		'password': password,
		'first_name': first_name,
		'last_nane': last_name,
	};
}
