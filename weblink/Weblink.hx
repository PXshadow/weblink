package weblink;

import haxe.http.HttpMethod;
import weblink._internal.Server;
import weblink._internal.ds.RadixTree;
import weblink.security.CredentialsProvider;
import weblink.security.Jwks;
import weblink.security.OAuth.OAuthEndpoints;

using haxe.io.Path;

private typedef Func = (request:Request, response:Response) -> Void;

class Weblink {
	public var server:Server;
	public var routeTree:RadixTree<Func>;

	/**
		Default anonymous function defining the behavior should a requested route not exist.
		Suggested that application implementers use set_pathNotFound() to define custom 404 status behavior/pages
	**/
	public var pathNotFound(null, set):Func = function(request:Request, response:Response):Void {
		response.status = 404;
		response.send("Error 404, Route Not found.");
	}

	var _serve:Bool = false;
	var _path:String;
	var _dir:String;
	var _cors:String = "*";

	public function new() {
		this.routeTree = new RadixTree();
	}

	private function _updateRoute(path:String, method:HttpMethod, handler:Func) {
		this.routeTree.put(path, method, handler);
	}

	public function get(path:String, func:Func, ?middleware:Func) {
		if (middleware != null) {
			final oldFunc = func;
			func = (req, res) -> {
				middleware(req, res);
				oldFunc(req, res);
			};
		}
		_updateRoute(path, Get, func);
	}

	public function post(path:String, func:Func) {
		_updateRoute(path, Post, func);
	}

	public function put(path:String, func:Func) {
		_updateRoute(path, Put, func);
	}

	public function head(path:String, func:Func) {
		_updateRoute(path, Head, func);
	}

	public function listen(port:Int, blocking:Bool = true) {
		server = new Server(port, this);
		server.update(blocking);
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

	private inline function _serveEvent(request:Request, response:Response):Bool {
		if (request.path.charAt(0) == "/")
			request.path = request.basePath.substr(1);
		var ext = request.path.extension();
		var mime = weblink._internal.Mime.types.get(ext);
		response.headers = new List<Header>();
		if (_cors.length > 0)
			response.headers.add({key: "Access-Control-Allow-Origin", value: _cors});
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

	public function set_pathNotFound(value:Func):Func {
		this.pathNotFound = value;
		return this.pathNotFound;
	}
}
