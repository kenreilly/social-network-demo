import 'dart:mirrors';
import 'package:core/core.dart';
import 'package:core/types/decorator.dart';

abstract class Serializable<T> {

	InstanceMirror _instance;

	final Map<Symbol, Type> _fields = {};

	Serializable() {
		
		if (MirrorSystem == null) return;
		_instance = reflect(this);

		List<DeclarationMirror> props = traverse(reflectClass(runtimeType));
		props.forEach((m) => _fields[m.simpleName] = (m as VariableMirror).type.reflectedType);
	}

	Iterable<DeclarationMirror> get _properties =>
		_instance.type.declarations.values.where((d) =>_isSerialized(d));

	Map<String, dynamic> toJson() => data;

	Map<String, dynamic> get data =>
		_fields.map((Symbol s, Type t) => MapEntry(MirrorSystem.getName(s), _val(s, t)));

	dynamic _val(Symbol s, Type t) =>
		_instance.getField(s).reflectee;
		
	static bool _isSerialized(DeclarationMirror d) =>
		(d.metadata.where((InstanceMirror i) => i.reflectee is Serialize).isNotEmpty);

	static MapEntry<Symbol, dynamic> _parse(VariableMirror d, Map<dynamic, dynamic> map) =>
		MapEntry(d.simpleName, map[MirrorSystem.getName(d.simpleName)]);

	static T of<T>(Map<dynamic, dynamic> map) => cast(T, map) as T;

	static List<DeclarationMirror> traverse(ClassMirror c) {

		List<DeclarationMirror> _fields = [];
		_fields.addAll(c.declarations.values.where((d) => isSerializedProperty(d)));

		if (c.superclass == null || c.superclass.reflectedType == Serializable) return _fields;
		_fields.addAll(traverse(c.superclass));
		return _fields;
	}

	static Serializable cast(Type t, Map<dynamic, dynamic> map) {

		ClassMirror c = reflectType(t);
		List<DeclarationMirror> fields = traverse(c);

		Map<Symbol, dynamic> items = Map.fromEntries(fields.map((d) {

			dynamic x = _parse(d as VariableMirror, map);
			return x;
		}));

		// if (c.reflectedType == AuthenticatedUser) {

		// 	return AuthenticatedUser(
		// 		id: items[Symbol('id')], 
		// 		auth_timestamp: items[Symbol('auth_timestamp')], 
		// 		first_name: items[Symbol('first_name')],
		// 		last_name: items[Symbol('last_name')]);
		// }

		return c.newInstance(Symbol(''), [], items).reflectee as Serializable;
	}

	static bool isSerializedProperty(DeclarationMirror d) => 
		(d.metadata.isNotEmpty ? d.metadata.first.reflectee is Serialize : false);

	static bool isSerializable(ClassMirror d) => 
		(d.superclass != null && d.superclass.reflectedType != Object) 
			? isSerializable(d.superclass) 
			: d.reflectedType == Serializable;
}

class Serialize extends Decorator { const Serialize(); }
const serialize = Serialize();