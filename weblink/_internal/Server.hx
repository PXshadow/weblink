package weblink._internal;

import haxe.MainLoop;
import haxe.io.Bytes;
import hl.uv.Stream;
import sys.net.Host;
import weblink._internal.Socket;

class Server extends SocketServer {

	var parent:Weblink;
	public var running:Bool = true;
	var loop:hl.uv.Loop;

	public function new(port:Int, parent:Weblink) {
		// sockets = [];
		loop = hl.uv.Loop.getDefault();
		super(loop);
		bind(new Host("0.0.0.0"), port);
		noDelay(true);
		listen(100, function() {
			final stream = accept();
			final socket:Socket = cast stream;
			var request:Null<Request> = null;

			stream.readStart(function(data:Null<Bytes>) @:privateAccess {
				if (data == null) { // EOF
					request = null;
					stream.close();
					return;
				}

				if (request == null) {
					var lines = data.toString().split("\r\n");
					request = new Request(lines);

					if (request.pos >= request.length) {
						complete(request, socket);
						request = null;
						return;
					}
				} else {
					var length = request.length - request.pos < data.length ? request.length - request.pos : data.length;
					request.data.blit(request.pos, data, 0, length);
					request.pos += length;

					if (request.pos >= request.length) {
						complete(request, socket);
						request = null;
						return;
					}
				}

				if (request.chunked) {
					request.chunk(data.toString());
					if (request.chunkSize == 0) {
						complete(request, socket);
						request = null;
						return;
					}
				}

				if (request.method != Post && request.method != Put) {
					complete(request, socket);
					request = null;
				}
			});
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
