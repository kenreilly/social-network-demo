
import 'package:api/framework/rest-method.dart';
import 'package:api/framework/meta/json-decorator.dart';
import 'package:api/framework/rest-service.dart';
import 'package:shelf_router/shelf_router.dart';

@RoutePath('/')
class EchoService extends RESTService {

	EchoService(): super();

	@GET('/')
	Future<dynamic> echo() => Future.value('echo');

	@GET('/check/:a')
	Future<dynamic> check(int a) => Future.value(a);
}