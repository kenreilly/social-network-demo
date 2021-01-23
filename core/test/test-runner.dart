// import 'dart:io';
import 'dart:convert';
import 'package:core/models/test/test-model.dart';
import 'package:core/types/serializable.dart';
import 'package:test/test.dart';

void main() async => CoreSDKTest.run();

abstract class CoreSDKTest {

	JsonEncoder enc = JsonEncoder();
	JsonDecoder dec = JsonDecoder();

	static Future<void> run() async {
	
		test('Serializable<T> test model a == b == c', () async {

			TestModel tm1 = TestModel(b: true, i: 1, s: 'hi');
			TestModel tm2 = TestModel.fromMap(tm1.data);
			expect(tm1, equals(tm2));
			
			// TestModel tm2 = Serializable.of<TestModel>(tm1.data);
			// TestModel tm3 = Serializable.cast(tm2.runtimeType, tm2.data);
			
			// expect(tm1, equals(tm2));
			// expect(tm2, equals(tm3));
			// expect(tm3, equals(tm1));
		});

		// test('JSON', () async {

		// 	Map<String, String> m = { 's': 'asdf' };
		// 	String j = enc.convert(m);
		// 	dynamic x = dec.convert(j);
		// 	// expect(string.split(','), equals(['foo', 'bar', 'baz']));
		// });
	
		// test('echo', () async {

		
		// 	// expect(string.split(','), equals(['foo', 'bar', 'baz']));
		// });
	}
}