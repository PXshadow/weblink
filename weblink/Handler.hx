package weblink;

/**
	A Handler is a function that operates on an incoming HTTP request.

	Example of a simple Handler:

	```haxe
	function handler(request:Request, response:Response) {
		response.send("Hello world!");
	}
	```
**/
typedef Handler = (request:Request, response:Response) -> Void;
