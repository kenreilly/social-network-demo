
import 'package:dotenv/dotenv.dart' as dotenv;

abstract class APIEnvironment {

	static Map<String, String> get env => dotenv.env ?? Map<String, String>.identity();

	static Future<void> load(String _config) async => await dotenv.load(await _config);
}