package weblink.middleware;

import haxe.Exception;
import haxe.http.HttpStatus;
import weblink.Handler;
import weblink.Request;
import weblink.Response;
import weblink._internal.HttpStatusMessage;
import weblink.exceptions.HttpException;

/**
	A collection of standard middlewares.
**/
@:nullSafety(StrictThreaded)
final class DefaultMiddleware {
	private function new() {}

	/**
		Creates a middleware that recovers from exceptions called down the chain.

		If an exception is caught, the response will try to be sent
		with the appropriate status code and message.
		@param configure (Optional) A function that can be used to configure the middleware.
	**/
	public static function recoverFromExceptions(?configure:(options:RecoverOptions) -> Void):Middleware {
		final options = RecoverOptions.defaults();
		if (configure != null) {
			configure(options);
		}

		return (next:Handler) -> {
			return (request:Request, response:Response) -> {
				try {
					next(request, response);
				} catch (e:Exception) {
					final ex:Null<HttpException> = Std.downcast(e, HttpException);
					final status:HttpStatus = ex != null ? ex.statusCode : InternalServerError;
					final statusMessage = HttpStatusMessage.fromCode(status);
					if (options.log) {
						trace(e.details());
					}
					try {
						response.status = status;
						response.contentType = "text/plain";
						if (options.includeStackTrace) {
							response.send('$statusMessage\n\n${e.details()}');
						} else {
							response.send(statusMessage);
						}
					} catch (_) {
						// Either parts or the entire response might have been already sent
						final client = @:privateAccess response.socket;
						if (client != null) {
							client.close(); // try to close if not closed already
						}
					}
				}
			};
		};
	}
}

@:structInit
private final class RecoverOptions {
	/**
		Should the exception response include a stack trace? Defaults to `false`.

		This should be set to `false` in production deployments.
	**/
	public var includeStackTrace:Bool;

	/**
		Should the exception be `trace()`d? Defaults to `false`.
	**/
	public var log:Bool;

	public static function defaults():RecoverOptions {
		return {
			includeStackTrace: false,
			log: false,
		};
	}
}
