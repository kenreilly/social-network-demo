import 'dart:core';
import 'package:core/hash.dart';

class AuthRequest {

	AuthRequest({ this.email, this.hashp });

	String email;
	String hashp;

	static AuthRequest create({ String email, String password}) => 
		AuthRequest(email: email, hashp: Hash.create(password));

	static AuthRequest fromJSON(Map<String, dynamic> map) =>
		AuthRequest(email: map['email'], hashp: map['hashp']);

	Map<String, dynamic> get data => { 'email': email, 'hashp': hashp };
}
