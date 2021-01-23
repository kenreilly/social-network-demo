import 'package:core/hash.dart';
import 'package:core/types/serializable.dart';

class User extends Serializable {

	User({ this.id, this.first_name, this.last_name }) : super();

	String id;
	String first_name;
	String last_name;

	static User fromMap(Map<String, dynamic> map) => User(
		id: map['id'], 
		first_name: map['first_name'], 
		last_name: map['last_name']
	);

	@override
	Map<String, dynamic> toMap() => { 
		'id': id, 
		'first_name': first_name, 
		'last_name': last_name 
	};
}

class AuthenticatedUser extends User {

	AuthenticatedUser({ id, first_name, last_name, this.auth_timestamp, this.token }) 
		: super(id: id, first_name: first_name, last_name: last_name);

	String auth_timestamp;
	String token;

	static AuthenticatedUser fromMap(Map<String, dynamic> map) => AuthenticatedUser(
		id: map['id'], 
		first_name: map['first_name'], 
		last_name: map['last_name'],
		auth_timestamp: map['auth_timestamp']
	);

	@override
  	Map<String, dynamic> toMap() => {
		'id': id, 
		'first_name': first_name, 
		'last_name': last_name,
		'auth_timestamp': auth_timestamp,
		'token': token
	};
}

class NewUser extends Serializable {

	NewUser({ this.email, this.hashp, this.first_name, this.last_name }) : super();

	String email;
	String hashp;
	String first_name;
	String last_name;

	static NewUser create({ String email, String password, String first_name, String last_name}) =>
		NewUser(email: email, hashp: Hash.create(password), first_name: first_name, last_name: last_name);

	static NewUser fromMap(Map<String, dynamic> map) => NewUser(
		email: map['email'],
		hashp: map['hashp'],
		first_name: map['first_name'],
		last_name: map['last_name']
	);

	@override
	Map<String, dynamic> toMap() => {
		'email': email,
		'hashp': hashp,
		'first_name': first_name, 
		'last_name': last_name
	};
}
