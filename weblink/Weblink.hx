package weblink;

import haxe.http.HttpMethod;
import weblink.Handler;
import weblink._internal.Server;
import weblink._internal.ds.RadixTree;
import weblink.middleware.Middleware;
import weblink.security.CredentialsProvider;
import weblink.security.Jwks;
import weblink.security.OAuth.OAuthEndpoints;

using haxe.io.Path;

class Weblink {
	public var server:Null<Server>;
	public var routeTree:RadixTree<Handler>;
	public var allowed_methods = new Map<HttpMethod, Bool>();

	private var middlewareToChain:Array<Middleware> = [];

	/**
		Default anonymous function defining the behavior should a requested route not exist.
		Suggested that application implementers use set_pathNotFound() to define custom 404 status behavior/pages
	**/
	public var pathNotFound(null, set):Handler = function(request:Request, response:Response):Void {
		response.status = 404;
		response.send("Error 404, Route Not found.");
	}

	public function cors_middleware(request:Request, response:Response):Void {
		response.headers = new List<Header>();
		response.headers.add({key: "Access-Control-Allow-Origin", value: cors});
	}

	var _serve:Bool = false;
	var _path:String;
	var _dir:String;

	public var cors:String = "*";
	public var allowed_methods_string = "";

	public function new() {
		this.routeTree = new RadixTree();
	}

	/**
		Adds middleware to new routes. Does not affect already registered routes.

		Middleware is a function that intercepts incoming requests and takes action on them.
		Middleware can be used for logging, authentication and many more.
	**/
	public function use(middleware:Middleware) {
		// Idea: Should adding middleware be disallowed once some routes are defined?
		this.middlewareToChain.push(middleware);
	}

	/**
		"Flattens" the provided handler,
		so that we can avoid middleware lookup at runtime.
	**/
	private function chainMiddleware(handler:Handler):Handler {
		var i = this.middlewareToChain.length - 1;
		while (i >= 0) {
			final middleware = this.middlewareToChain[i];
			handler = middleware(handler);
			i -= 1;
		}
		return handler;
	}

	private function _updateRoute(path:String, method:HttpMethod, handler:Handler) {
		this.routeTree.put(path, method, chainMiddleware(handler));
	}

	public function get(path:String, func:Handler, ?middleware:Middleware) {
		if (middleware != null) {
			func = middleware(func);
		}
		allowed_methods[Get] = true;
		_updateRoute(path, Get, func);
	}

	public function post(path:String, func:Handler) {
		allowed_methods[Post] = true;
		_updateRoute(path, Post, func);
	}

	public function put(path:String, func:Handler) {
		allowed_methods[Put] = true;
		_updateRoute(path, Put, func);
	}

	public function head(path:String, func:Handler) {
		allowed_methods[Head] = true;
		_updateRoute(path, Head, func);
	}

	public function listen(port:Int, blocking:Bool = true) {
		if (cors.length > 0)
			this.middlewareToChain.push(cors_middleware);
		this.pathNotFound = chainMiddleware(this.pathNotFound);
		allowed_methods[Options] = true;
		var allowed_methods_array = new Array<String>();
		for (k => v in allowed_methods) {
			if (v) {
				allowed_methods_array.push(k);
			}
		}

		allowed_methods_string = allowed_methods_array.join(", ");
		server = new Server(port, this);
		server.update(blocking);
	}

	public function serve(path:String = "", dir:String = "", cors:String = "*") {
		this.cors = cors;
		_path = path;
		_dir = dir;
		_serve = true;
	}

	public function close() {
		server.close();
	}

	/**
	 * Add JSON Web Key Sets HTTP endpoint
	 */
	public function jwks(jwks:Jwks, ?path = "/jwks"):Weblink {
		get(path, (request:Request, response:Response) -> jwks.jwksGetEndpoint(request, response));
		post(path, (request:Request, response:Response) -> jwks.jwksPostEndpoint(request, response));
		return this;
	}

	public function users(credentialsProvider:CredentialsProvider, ?path = "/users"):Weblink {
		get(path, credentialsProvider.getUsersEndpoint);
		post(path, credentialsProvider.postUsersEndpoint);
		return this;
	}

	public function oauth2(secret_key:String, credentialsProvider:CredentialsProvider, ?path = "/token"):Weblink {
		var oauth2 = new OAuthEndpoints(path, secret_key, credentialsProvider);
		post(path, oauth2.login_for_access_token);
		return this;
	}

	private inline function _serveEvent(request:Request, response:Response):Bool {
		if (request.path.charAt(0) == "/")
			request.path = request.basePath.substr(1);
		var ext = request.path.extension();
		var mime = weblink._internal.Mime.types.get(ext);
		response.headers = new List<Header>();
		if (cors.length > 0)
			response.headers.add({key: "Access-Control-Allow-Origin", value: cors});
		response.contentType = mime == null ? "text/plain" : mime;
		var path = Path.join([_dir, request.basePath.substr(_path.length)]).normalize();
		if (path == "")
			path = ".";
		if (sys.FileSystem.exists(path)) {
			if (sys.FileSystem.isDirectory(path)) {
				response.contentType = "text/html";
				path = Path.join([path, "index.html"]);
				if (sys.FileSystem.exists(path)) {
					response.sendBytes(sys.io.File.getBytes(path));
					return true;
				}
				trace('file not found $path');
				return false;
			} else {
				response.sendBytes(sys.io.File.getBytes(path));
				return true;
			}
		} else {
			trace('file/folder not found $path');
			return false;
		}
	}

	public function set_pathNotFound(value:Handler):Handler {
		if (this.server != null) {
			throw "cannot change fallback handler at runtime";
		}

		this.pathNotFound = value;
		return this.pathNotFound;
	}
}
