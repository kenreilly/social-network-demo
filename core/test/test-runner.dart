import 'package:test/test.dart';
import 'package:core/test/core-test-base.dart';
import 'package:core/models/test/test-model.dart';

void main() async {

	CoreTest runner = CoreTest();
	await runner.run();
}

class CoreTest extends CoreTestBase {

	CoreTest() :super();

	Future<void> run() async {
	
		test('Serializable test model a == b == c', () async {

			TestModel tm1 = TestModel(b: true, i: 1, s: 'hi');
			TestModel tm2 = TestModel(b: tm1.b, i: tm1.i, s: tm1.s);
			TestModel tm3 = TestModel.fromMap(tm2.data);
			TestModel tm4 = TestModel.fromMap(dec.convert(enc.convert(tm3)));

			expect(tm1, equals(tm2));
			expect(tm2, equals(tm3));
			expect(tm3, equals(tm4));
		});
	}
}