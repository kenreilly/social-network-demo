import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:core/core.dart';
import 'package:api/db.dart';

abstract class Server {

	static DB _db;

	static final Router _router = Router();

	static Timer _timer;

	static Future<Response> _handle(Request request) async {

		return Response.ok('asdf');
	}

	static void _onTimer(Timer _timer) => _db.flush();

	static Future<void> start() async {

		String filename = (await File.fromUri(Uri.parse('.env')).exists()) ? '.env' : '.env.example';
		dotenv.load(filename);

		_db = await DB.connect(dotenv.env);
		_timer = Timer.periodic(Duration(minutes: 10), _onTimer);

		int port = int.parse(dotenv.env['PORT']);
		HttpServer server = await io.serve(_router.handler, 'localhost', port);
		print('Serving at http://${server.address.host}:${server.port}');
	}
}

void main(List<String> args) async => Server.start();
