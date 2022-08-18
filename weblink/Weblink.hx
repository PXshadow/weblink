package weblink;

import weblink._internal.Server;

using haxe.io.Path;

private typedef Func = (request:Request, response:Response) -> Void;

class Weblink {
	public var server:Server;
	public var routes:Map<String, Map<String, Array<Func>>> = [];

	/**
	Default anonymous function defining the behavior should a requested route not exist.
	Suggested that application implementers use set_pathNotFound() to define custom 404 status behavior/pages
	**/
	public var pathNotFound(null,set):Func = function(request:Request, response:Response):Void{
		response.status = 404;
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

	private inline function _postEvent(request:Request, response:Response) {
		var route = this.routes[request.path];
		route.get("POST")[0](request, response);
	}

	private inline function _putEvent(request:Request, response:Response) {
		var route = this.routes[request.path];
		route.get("PUT")[0](request, response);
	}



	
	private function _getEvent(request:Request, response:Response) {
		if (_serve && response.status == OK && request.path.indexOf(_path) == 0) {
			if (_serveEvent(request, response))
				return;
		}
		var routeList = [];
		if(this.routes.exists(request.path)){
			routeList = this.routes[request.path].get("GET");
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
		if (request.path.charAt(0) == "/")
			request.path = request.path.substr(1);
		var ext = request.path.extension();
		var mime = weblink._internal.Mime.types.get(ext);
		response.headers = new List<Header>();
		if (_cors.length > 0)
			response.headers.add({key: "Access-Control-Allow-Origin", value: _cors});
		response.contentType = mime == null ? "text/plain" : mime;
		var path = Path.join([_dir, request.path.substr(_path.length)]).normalize();
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

	private inline function _headEvent(request:Request, response:Response) {
		var route = this.routes[request.path];
		route.get("HEAD")[0](request, response);
	}

	public function set_pathNotFound(value:Func):Func {
		this.pathNotFound = value;
		return this.pathNotFound;
	}
}
