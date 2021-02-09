import 'dart:mirrors';
import 'package:core/types/serializable.dart';

abstract class Reflector {

	static MapEntry<Symbol, dynamic> _parse(VariableMirror d, Map<dynamic, dynamic> map) =>
		MapEntry(d.simpleName, map[MirrorSystem.getName(d.simpleName)]);

  	static bool isSerializable(ClassMirror d) =>
      	(d.superclass != null && d.superclass.reflectedType != Object)
        	? isSerializable(d.superclass)
        	: d.reflectedType == Serializable;

  	static bool isSerializedProperty(DeclarationMirror d) => d is VariableMirror;

	static Serializable cast(Type t, Map<dynamic, dynamic> map) {

		ClassMirror c = reflectType(t);
		List<DeclarationMirror> fields = traverse(c);
		Map<Symbol, dynamic> items = Map.fromEntries(fields.map((d) => _parse(d as VariableMirror, map)));
		
		return c.newInstance(Symbol(''), [], items).reflectee as Serializable;
	}

	static T of<T>(Map<dynamic, dynamic> map) => cast(T, map) as T;

	static List<DeclarationMirror> traverse(ClassMirror c) {

		List<DeclarationMirror> _fields = [];
			_fields.addAll(c.declarations.values.where((d) => isSerializedProperty(d)));

		if (c.superclass == null || c.superclass.reflectedType == Serializable) return _fields;
			_fields.addAll(traverse(c.superclass));

		return _fields;
	}
}
