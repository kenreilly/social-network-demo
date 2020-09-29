import 'package:api/framework/rest-method.dart';
import 'package:api/framework/rest-service.dart';
import 'package:core/models/test/test-model.dart';

@RoutePath('/')
class EchoService extends RESTService {

	EchoService(): super();

	@JSON
	@GET('/')
	Future<dynamic> echo() => Future.value('echo');

	@JSON
	@GET('/check/:a')
	Future<dynamic> check(int a) => Future.value(a);

	@JSON
	@POST('/test-model')
	Future<dynamic> test(TestModel tm) => Future.value(tm.data);
}