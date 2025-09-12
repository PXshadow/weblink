package weblink;

import weblink._internal.Server;
import weblink.security.CredentialsProvider;
import weblink.security.Jwks;
import weblink.security.OAuth.OAuthEndpoints;
import haxe.io.Path;

#if !haxe5
#error "Version 2 requires Haxe 5"
#end

private typedef Func = (request:Request, response:Response) -> Void;

class Weblink {
	public var server:Server;
	public var routes:Map<String, Map<String, Array<Func>>> = [];
	
	public function redirect(request:Request, response:Response, path:String) {
		// DONE
		weblink._internal.ServeMux.redirect(response,request,path);
	}
	/**
		Default anonymous function defining the behavior should a requested route not exist.
		Suggested that application implementers use set_pathNotFound() to define custom 404 status behavior/pages
	**/
	public var pathNotFound(null, set):Func = function(request:Request, response:Response):Void {
		response.writeHeader(404);
		response.send("Error 404, Route Not found.");
	}

	var _serve:Bool = false;
	var _path:String;
	var _dir:String;
	var _cors:String = "*";

	public function new() {}

	private function _updateRoute(path:String, method:String, functionsList:Array<Func>) {
		if (this.routes[path] != null) {
			this.routes[path][method] = functionsList;
		} else {
			this.routes[path] = [method => functionsList];
		}
	}

	public function get(path:String, func:Func, ?middleware:Func) {
		_updateRoute(path, "GET", [func, middleware]);
	}

	public function post(path:String, func:Func) {
		_updateRoute(path, "POST", [func]);
	}

	public function put(path:String, func:Func) {
		_updateRoute(path, "PUT", [func]);
	}

	public function head(path:String, func:Func) {
		_updateRoute(path, "HEAD", [func]);
	}

	public function listen(port:Int, blocking:Bool = true) {
		server = new Server(port, this);
	}

	public function serve(path:String = "", dir:String = "", cors:String = "*") {
		_cors = cors;
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

	private inline function _postEvent(request:Request, response:Response) {
		var route = this.routes[request.uRL.path];
		route.get("POST")[0](request, response);
	}

	private inline function _putEvent(request:Request, response:Response) {
		var route = this.routes[request.uRL.path];
		route.get("PUT")[0](request, response);
	}

	private function _getEvent(request:Request, response:Response) {
		if (_serve && request.uRL.path.indexOf(_path) == 0) {
			if (_serveEvent(request, response))
				return;
		}
		var routeList = [];
		if (this.routes.exists(request.uRL.host)) {
			routeList = this.routes[request.uRL.host].get("GET");
		} else if (this.routes.exists(request.uRL.path)) {
			routeList = this.routes[request.uRL.path].get("GET");
		} else { // Don't have the route, don't process it and escape.
			this.pathNotFound(request, response);
			return;
		}

		var get = routeList[0];
		var middleware = routeList[1];
		if (middleware != null)
			middleware(request, response);
		get(request, response);
	}

	private inline function _serveEvent(request:Request, response:Response):Bool {
		//if (request.uRL.path.charAt(0) == "/")
		//	request.uRL.path = request.uRL.path.substr(1);
		var ext = Path.extension(request.uRL.path);
		var mime = weblink._internal.Mime.types.get(ext);
		//response.headers = new List<Header>();
		if (_cors.length > 0)
			response.header().add("Access-Control-Allow-Origin", _cors);
		response.contentType(mime == null ? "text/plain" : mime);
		var path = Path.normalize(Path.join([_dir, request.uRL.host.substr(_path.length)]));
		if (path == "")
			path = ".";
		if (sys.FileSystem.exists(path)) {
			if (sys.FileSystem.isDirectory(path)) {
				response.contentType("text/html");
				path = Path.join([path, "index.html"]);
				if (sys.FileSystem.exists(path)) {
					response.write(sys.io.File.getBytes(path));
					return true;
				}
				trace('file not found $path');
				return false;
			} else {
				response.write(sys.io.File.getBytes(path));
				return true;
			}
		} else {
			trace('file/folder not found $path');
			return false;
		}
	}

	private inline function _headEvent(request:Request, response:Response) {
		var route = this.routes[request.uRL.path];
		route.get("HEAD")[0](request, response);
	}

	public function set_pathNotFound(value:Func):Func {
		this.pathNotFound = value;
		return this.pathNotFound;
	}
}
