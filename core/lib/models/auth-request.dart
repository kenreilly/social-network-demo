import 'dart:core';
import 'package:core/hash.dart';
import 'package:core/types/serializable.dart';

class AuthRequest extends Serializable {

	AuthRequest({ this.email, this.hashp }) : super();

	@serialize
	String email;

	@serialize
	String hashp;

	static AuthRequest create({String email, String password}) => 
		AuthRequest(email: email, hashp: Hash.create(password));
}
