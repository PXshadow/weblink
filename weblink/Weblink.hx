package weblink;

import haxe.http.HttpMethod;
import weblink._internal.Server;
import weblink._internal.Mime;

using haxe.io.Path;

private typedef Func = (request:Request, response:Response) -> Void;

class Weblink {
	public var server:Server;

	var _get:Func;
	var _post:Func;
	var _put:Func;
	var _head:Func;
	var _serve:Bool = false;
	var _path:String;
	var _dir:String;
	var _cors:String = "*";

	public function new() {}

	public function get(func:Func) {
		this._get = func;
	}

	public function post(func:Func) {
		this._post = func;
	}

	public function put(func:Func) {
		this._put = func;
	}

	public function head(func:Func) {
		this._head = func;
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
		if (_post != null)
			_post(request, response);
	}

	private inline function _putEvent(request:Request, response:Response) {
		if (_put != null)
			_put(request, response);
	}

	private function _getEvent(request:Request, response:Response) {
		if (_serve && response.status == OK && request.path.indexOf(_path) == 0) {
			if (_serveEvent(request, response))
				return;
		}
		if (_get != null)
			_get(request, response);
	}

	private inline function _serveEvent(request:Request, response:Response):Bool {
		var ext = request.path.extension();
		var mime = weblink._internal.Mime.types.get(ext);
		response.headers = new List<Header>();
		if (_cors.length > 0)
			response.headers.add({key: "Access-Control-Allow-Origin", value: _cors});
		response.contentType = mime == null ? "text/plain" : mime;
		var path = Path.join([_dir, request.path.substr(_path.length)]).normalize();
		if (sys.FileSystem.exists(path)) {
			if (sys.FileSystem.isDirectory(path)) {
				response.contentType = "text/html";
				path = Path.join([path, "index.html"]);
				if (sys.FileSystem.exists(path)) {
					response.sendBytes(sys.io.File.getBytes(path));
					return true;
				}
				return false;
			} else {
				response.sendBytes(sys.io.File.getBytes(path));
				return true;
			}
		} else {
			// trace('file not found $path');
			return false;
		}
	}

	private inline function _headEvent(request:Request, response:Response) {
		if (_head != null)
			_head(request, response);
	}
}
