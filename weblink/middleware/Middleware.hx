package weblink.middleware;

import weblink.Handler;

private typedef MiddlewareFunc = (next:Handler) -> Handler;

/**
	Middleware is a piece of code that acts on the HTTP request
	before your route handler does.

	A Middleware can be one of two things:

	- A Handler. This is a function that takes a request and a response, and always succeeds.
	  Behind the scenes, Weblink makes sure it always calls the next handler.

	  Example:

	  ```haxe
	  function myLoggingMiddleware(request:Request, response:Response) {
		  trace('${request.method} ${request.path}');
	  }
	  ```

	- A function that takes a Handler and returns another Handler.
	  This new Handler can then decide for itself
	  whether to short-circuit or to continue the request.

	  Example:

	  ```haxe
	  function myAuthMiddleware(next:Handler): Handler {
		  final credentials = Base64.encode(Bytes.ofString("admin:1234"));
		  return (request:Request, response:Response) -> {
			  if (request.headers.get("Authorization") == "Basic " + credentials) {
				  next(request, response);
			  } else {
				  response.status = Unauthorized;
				  response.headers = new List();
				  response.headers.add({key: "WWW-Authenticate", value: 'Basic realm="Cool Site"'});
				  response.send("Sorry, cannot let you in!");
			  }
		  };
	  }
	  ```

	Invoke a Middleware object to chain handlers, like this:

	```haxe
	handler = middleware(handler); // same type
	```

	If you have multiple middlewares to chain, remember it is right-associative:

	```haxe
	handler = first(second(third(fourth(handler))));
	```

	This specific implemention is inspired by many routers in the Golang ecosystem.
**/
@:callable
abstract Middleware(MiddlewareFunc) {
	private inline function new(func:MiddlewareFunc) {
		this = func;
	}

	/**
		Creates a new middleware from a function that folds the handlers.
		That function has the ability to short-circuit.
	**/
	@:from
	private static inline function fromFolding(func:MiddlewareFunc):Middleware {
		return new Middleware(func);
	}

	/**
		Creates a new middleware from a function that always falls through, to the next handler.
	**/
	@:from
	private static inline function fromHandler(func:Handler):Middleware {
		return new Middleware(next -> {
			return (req, res) -> {
				func(req, res);
				next(req, res);
			};
		});
	}
}
