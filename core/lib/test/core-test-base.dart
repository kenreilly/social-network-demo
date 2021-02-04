import 'dart:math';
import 'dart:convert';
import 'package:core/models/test/test-model.dart';

abstract class CoreTestBase {

	CoreTestBase();

	final JsonEncoder enc = const JsonEncoder();
  	final JsonDecoder dec = const JsonDecoder();

	static final Random rnd = Random();
	static final List<int> _ascii = [97, 122]; // ascii charcode
	static int get _next => (_ascii[0] + rnd.nextInt(_ascii[1] - _ascii[0]));

	static String rstr(int len) =>
		String.fromCharCodes(List.generate(len, (_) => _next));
	
	final TestModel tmodel = TestModel(b: true, i: 1024, s: rstr(32));
}