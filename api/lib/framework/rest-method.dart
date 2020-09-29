
import 'package:core/core.dart';

class _JSON { const _JSON(); }
const JSON = _JSON();

class RoutePath extends Decorator {
	
	final String path;
	const RoutePath(this.path);

	RoutePath operator + (RoutePath r) => 
		RoutePath(path + (path.endsWith('/') ? r.path.replaceFirst('/', '') : r.path));
}

abstract class RouteComponent<T> {
	
	RouteComponent();

	bool check(String part) => _test(part);
	bool _test(String part);

	static List<RouteComponent> generate(String path) =>
		(path == '/') ? [] : (path.split('/')..retainWhere((s) => s.isNotEmpty)).map((String p) => _create(p)).toList();

	static RouteComponent _create(String part) => 
		(part.contains(':')) ? RouteParameter(part.substring(1)) : RoutePoint(part);
}

class RoutePoint extends RouteComponent {

	final String path;
	RoutePoint(this.path): super();
	
	@override
	bool _test(String part) => part == path;
}

class RouteParameter extends RouteComponent {

	final String field;
	RouteParameter(this.field): super();

	@override
	bool _test(String part) => part.isNotEmpty;
}

enum HTTPMethodType {
	GET,
	HEAD,
	POST,
	PUT,
	DELETE,
	CONNECT,
	OPTIONS,
	TRACE,
	PATCH
}

extension HTTPMethodString on HTTPMethodType {

	String get name => toString().split('.').last;
}

abstract class RESTMethod extends Decorator {

	final HTTPMethodType method;
	final String route;
	const RESTMethod(this.method, this.route);
}

class GET extends RESTMethod {

	const GET(route): super(HTTPMethodType.GET, route);
}

class HEAD extends RESTMethod {

	const HEAD(route): super(HTTPMethodType.HEAD, route);
}

class POST extends RESTMethod {
	
	const POST(route): super(HTTPMethodType.POST, route);
}

class PUT extends RESTMethod {
	
	const PUT(route): super(HTTPMethodType.PUT, route);
}