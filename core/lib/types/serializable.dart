import 'dart:mirrors';
import 'package:core/types/decorator.dart';

abstract class Serializable<T> {

	InstanceMirror _instance;

	final Map<Symbol, Type> _fields = {};

	Serializable() {
		
		if (MirrorSystem == null) return;
		_instance = reflect(this);
		_properties.forEach((m) => _fields[m.simpleName] = (m as VariableMirror).type.reflectedType);
	}

	Iterable<DeclarationMirror> get _properties =>
		_instance.type.declarations.values.where((d) =>_isSerialized(d));

	Map<dynamic, dynamic> get data =>
		_fields.map((Symbol s, Type t) => MapEntry(MirrorSystem.getName(s), _val(s, t)));

	dynamic _val(Symbol s, Type t) =>
		_instance.getField(s).reflectee;
		
	static bool _isSerialized(DeclarationMirror d) =>
		(d.metadata.where((InstanceMirror i) => i.reflectee is Serialize).isNotEmpty);

	static MapEntry<Symbol, dynamic> _parse(VariableMirror d, Map<dynamic, dynamic> map) =>
		MapEntry(d.simpleName, map[MirrorSystem.getName(d.simpleName)]);

	static T of<T>(Map<dynamic, dynamic> map) => cast(T, map) as T;

	static Serializable cast(Type t, Map<dynamic, dynamic> map) {

		ClassMirror c = reflectType(t);
		Iterable<DeclarationMirror> fields = c.declarations.values.where((d) => _isSerialized(d));
		Map<Symbol, dynamic> items = Map.fromEntries(fields.map((d) => _parse(d as VariableMirror, map)));
		return c.newInstance(Symbol(''), [], items).reflectee as Serializable;
	}

	// static final Map<Type, Function>castmap = {
	// 	String: (String s) => s,
	// 	int: (int i) => i,
	// };
}

class Serialize extends Decorator { const Serialize(); }
const serialize = Serialize();