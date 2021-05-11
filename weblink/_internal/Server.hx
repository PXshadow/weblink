package weblink._internal;

import hl.uv.Stream;
import hl.uv.Loop.LoopRunMode;
import haxe.MainLoop;
import haxe.io.Bytes;
import haxe.http.HttpMethod;
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

	private inline function complete(request:Request, socket:Socket) {
		@:privateAccess var response = request.response(this, socket);
		switch (request.method) {
			case Get:
				@:privateAccess parent._getEvent(request, response);
			case Post:
				@:privateAccess parent._postEvent(request, response);
			case Put:
				@:privateAccess parent._putEvent(request, response);
			case Head:
				@:privateAccess parent._headEvent(request, response);
			default:
				trace('Request method: ${request.method} Not supported yet');
		}
	}

	public function update(blocking:Bool = true) {
		do {
			@:privateAccess MainLoop.tick(); // for timers
			loop.run(NoWait);
		} while (running && blocking);
	}

	public inline function closeSocket(socket:Socket) {
		// sockets.remove(socket);
		socket.close();
	}
	override function close(?callb:() -> Void) {
		super.close(callb);
		loop.stop();
		running = false;
	}
}
