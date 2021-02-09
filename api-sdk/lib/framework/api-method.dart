import 'package:core/core.dart';

class RoutePath extends Decorator {

	final String path;
	const RoutePath(this.path);

	RoutePath operator +(RoutePath r) => 
		RoutePath(path + (path.endsWith('/') ? r.path.replaceFirst('/', '') : r.path));
}

class _JSON { const _JSON(); }
const JSON = _JSON();

enum APIMethodType {
	GET,
	HEAD,
	POST,
	PUT,
	DELETE,
	CONNECT,
	OPTIONS,
	TRACE,
	PATCH,
	WS
}

extension HTTPMethodString on APIMethodType {
	String get name => toString().split('.').last;
}

abstract class APIMethod extends Decorator {
	final APIMethodType method;
	final String route;
	const APIMethod(this.method, this.route);
}

class GET extends APIMethod {
	const GET(route): super(APIMethodType.GET, route);
}

class HEAD extends APIMethod {
	const HEAD(route): super(APIMethodType.HEAD, route);
}

class POST extends APIMethod {	
	const POST(route): super(APIMethodType.POST, route);
}

class PUT extends APIMethod {
	const PUT(route): super(APIMethodType.PUT, route);
}

class DELETE extends APIMethod {
	const DELETE(route): super(APIMethodType.DELETE, route);
}

class WS extends APIMethod {
	const WS(route): super(APIMethodType.WS, route);
}