package weblink.middleware;

private typedef MiddlewareFunc = (next:Func) -> Func;

@:callable
abstract Middleware(MiddlewareFunc) {
	public inline function new(fn:MiddlewareFunc) {
		this = fn;
	}

	@:from
	private static function fromMiddleware(fn:MiddlewareFunc):Middleware {
		return new Middleware(fn);
	}

	@:from
	private static function fromFunc(fn:Func):Middleware {
		return new Middleware((next) -> {
			return (req, res) -> {
				fn(req, res);
				next(req, res);
			};
		});
	}
}
