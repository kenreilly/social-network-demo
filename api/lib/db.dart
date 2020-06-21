import 'package:postgres/postgres.dart';

class DB {

	PostgreSQLConnection _connection;

	static Future<DB> connect(Map<String, dynamic> env) async {

		int _port = 5432;
		String _host = env['DB_HOST'];
		String _user = env['DB_USER'];
		String _pass = env['DB_PASS'];
		String _name = env['DB_NAME'];

		DB db = DB();
		db._connection = PostgreSQLConnection(_host, _port, _name, username: _user, password: _pass);
		await db._connection.open();
		return db;
	}

	Future<List<dynamic>> query(String sql, { Map<String, dynamic> values }) async {

		try { 
			return await _connection.mappedResultsQuery(sql, substitutionValues: values); 
		}
		catch(e) {
			return Future<List<dynamic>>.value(List<dynamic>(0)); 
		}
	}

	Future<void> flush() async {

		try { return await _connection.query('select flush();'); }
		catch(e) { return Future<void>.value(null); }
	}
}