import 'package:api/framework/api-method.dart';
import 'package:api/framework/api-service.dart';
import 'package:core/models/test/test-model.dart';

@RoutePath('/')
class EchoService extends APIService {

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