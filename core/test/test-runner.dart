import 'dart:convert';
import 'package:test/test.dart';
import 'package:core/models/test/test-model.dart';

void main() async => CoreSDKTest.run();

abstract class CoreSDKTest {

	JsonEncoder enc = JsonEncoder();
	JsonDecoder dec = JsonDecoder();

	static Future<void> run() async {
	
		test('Serializable test model a == b == c', () async {

			TestModel tm1 = TestModel(b: true, i: 1, s: 'hi');
			TestModel tm2 = TestModel(b: tm1.b, i: tm1.i, s: tm1.s);
			TestModel tm3 = TestModel.fromMap(tm2.data);

			expect(tm1, equals(tm2));
			expect(tm2, equals(tm3));
		});
	}
}