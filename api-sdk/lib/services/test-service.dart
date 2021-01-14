import 'package:api_sdk/framework/api-method.dart';
import 'package:api_sdk/framework/api-service.dart';
import 'package:core/models/test/test-model.dart';

@RoutePath('/')
class TestService extends APIService {

	TestService(): super();

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