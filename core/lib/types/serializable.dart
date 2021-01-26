// import 'dart:mirrors';
import 'package:core/core.dart';
import 'package:core/types/decorator.dart';

class Serializable<T> {

	Serializable();
	
	static Serializable fromMap(Map<String, dynamic> map) => Serializable<dynamic>();
	Map<String, dynamic> toMap() => {};
	Map<String, dynamic> toJson() => toMap();
	Map<String, dynamic> get data => toMap();
}

class Serialize extends Decorator { const Serialize(); }
const serialize = Serialize();