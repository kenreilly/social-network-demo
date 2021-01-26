import 'package:core/core.dart';

class TestModel extends Serializable {

	TestModel({this.s, this.i, this.b}) : super();

	String s;
	int i;
	bool b;
	
	@override
	bool operator ==(Object o) =>
		(o is TestModel) && (s == o.s && i == o.i && b == o.b);

	static TestModel fromMap(Map<String, dynamic> map) => TestModel(
		s: map['s'],
		i: map['i'],
		b: map['b']
	);

	@override
	Map<String, dynamic> toMap() => {
		's': s,
		'i': i,
		'b': b
	};
}