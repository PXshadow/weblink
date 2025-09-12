package weblink._internal;

import hl.uv.Stream;
import hl.uv.Loop.LoopRunMode;
import haxe.MainLoop;
import haxe.io.Bytes;
import haxe.http.HttpMethod;
import sys.net.Host;
import weblink._internal.Socket;

class Server {
	// var sockets:Array<Socket>;
	var parent:Weblink;
	var mux:ServeMux = null;
	var port = 0;
	public var running:Bool = true;

	public function new(port:Int, parent:Weblink) {
		this.port = port;
		mux = ServeMux.newServeMux();
		mux.handleFunc("/", (response, request) -> complete(request, response));
		this.parent = parent;
	}

	private inline function complete(request:Request, response:Response) {
		// TODO
		//@:privateAccess var response = request.response(this, socket);
		switch ((request.method : String)) {
			case Get, "ET":
				@:privateAccess parent._getEvent(request, response);
			case Post, "OST":
				@:privateAccess parent._postEvent(request, response);
			case Put, "UT":
				@:privateAccess parent._putEvent(request, response);
			case Head, "EAD":
				@:privateAccess parent._headEvent(request, response);
			default:
				trace('Request method: ${request.method} Not supported yet');
		}
	}

	public function update() {
		// DONE
		ServeMux.update(port, mux);
	}

	public function close(?callb:() -> Void) {
		running = false;
		ServeMux.close();
		if (callb != null)
			callb();
	}
}
