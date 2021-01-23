import 'dart:core';
import 'package:core/hash.dart';
import 'package:core/types/serializable.dart';

class AuthRequest extends Serializable {

	AuthRequest({ this.email, this.hashp }) : super();
	
	String email;
	String hashp;

	static AuthRequest create({String email, String password}) => 
		AuthRequest(email: email, hashp: Hash.create(password));

	static AuthRequest fromMap(Map<String, dynamic> map) => AuthRequest(
		email: map['email'],
		hashp: map['hashp']
	);

	@override
	Map<String, dynamic> toMap() => {
		'email': email,
		'hashp': hashp
	};
}
