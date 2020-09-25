import 'package:core/hash.dart';
import 'package:core/types/serializable.dart';

class User extends Serializable {

	User({ this.id, this.first_name, this.last_name }) : super();

	@serialize
	String id;

	@serialize
	String first_name;

	@serialize
	String last_name;
}

class AuthenticatedUser extends User {

	AuthenticatedUser({ id, first_name, last_name, this.auth_timestamp, this.token }) 
		: super(id: id, first_name: first_name, last_name: last_name);

	@serialize
	String auth_timestamp;

	@serialize
	String token;
}

class NewUser extends Serializable {

	NewUser({ this.email, this.hashp, this.first_name, this.last_name }) : super();

	@serialize
	String email;

	@serialize
	String hashp;

	@serialize
	String first_name;

	@serialize
	String last_name;

	static NewUser create({ String email, String password, String first_name, String last_name}) =>
		NewUser(email: email, hashp: Hash.create(password), first_name: first_name, last_name: last_name);
}
