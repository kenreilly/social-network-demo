import 'dart:convert';
import 'package:crypto/crypto.dart';

abstract class Hash {

	static final Utf8Encoder _encoder = const Utf8Encoder();

	static List<int> _convert(String x) => _encoder.convert(x);

	static String create(String str) => sha256.convert(_convert(str)).toString();
}