package weblink._internal;

import haxe.MainLoop;
import haxe.http.HttpMethod;
import haxe.io.Bytes;
import hl.uv.Loop.LoopRunMode;
import hl.uv.Stream;
import sys.net.Host;
import weblink._internal.Socket;

class Server extends SocketServer {
	// var sockets:Array<Socket>;
	var parent:Weblink;
	var stream:Stream;
	public var running:Bool = true;
	var loop:hl.uv.Loop;

	public function new(port:Int, parent:Weblink) {
		// sockets = [];
		loop = hl.uv.Loop.getDefault();
		super(loop);
		bind(new Host("0.0.0.0"), port);
		noDelay(true);
		listen(100, function() {
			stream = accept();
			var socket:Socket = cast stream;
			var request:Request = null;
			var done:Bool = false;
			stream.readStart(function(data:Bytes) @:privateAccess {
				if (done || data == null) {
					// sockets.remove(socket);
					stream.close();
					return;
				}

				if (request == null) {
					var lines = data.toString().split("\r\n");
					request = new Request(lines);

					if (request.pos >= request.length) {
						done = true;
						complete(request, socket);
						return;
					}
				} else if (!done) {
					var length = request.length - request.pos < data.length ? request.length - request.pos : data.length;
					request.data.blit(request.pos, data, 0, length);
					request.pos += length;

					if (request.pos >= request.length) {
						done = true;
						complete(request, socket);
						return;
					}
				}

				if (request.chunked) {
					request.chunk(data.toString());
					if (request.chunkSize == 0) {
						done = true;
						complete(request, socket);
						return;
					}
				}

				if (request.method != Post && request.method != Put) {
					done = true;
					complete(request, socket);
				}
			});
			// sockets.push(socket);
		});
		this.parent = parent;
	}

	private function complete(request:Request, socket:Socket) {
		@:privateAccess var response = request.response(this, socket);

		if (request.method == Get
			&& @:privateAccess parent._serve
			&& response.status == OK
			&& request.path.indexOf(@:privateAccess parent._path) == 0) {
			if (@:privateAccess parent._serveEvent(request, response)) {
				return;
			}
		}

		switch (parent.routeTree.tryGet(request.basePath, request.method)) {
			case Found(handler, params):
				request.routeParams = params;
				handler(request, response);
			case _:
				switch (parent.routeTree.tryGet(request.path, request.method)) {
					case Found(handler, params):
						request.routeParams = params;
						handler(request, response);
					case _:
						@:privateAccess parent.pathNotFound(request, response);
				}
		}
	}

	public function update(blocking:Bool = true) {
		do {
			@:privateAccess MainLoop.tick(); // for timers
			loop.run(Default);
		} while (running && blocking);
	}

	override function close(?callb:() -> Void) {
		super.close(callb);
		loop.stop();
		running = false;
	}
}
