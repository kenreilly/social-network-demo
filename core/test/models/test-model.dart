import 'package:core/core.dart';

class TestModel extends Serializable {

	TestModel({this.s, this.i, this.b}): super();

	@serialize
	String s;

	@serialize
	int i;

	@serialize
	bool b;
	
	@override // todo: move to superclass
	bool operator ==(Object o) =>
		(o is TestModel) && (s == o.s && i == o.i && b == o.b);
}