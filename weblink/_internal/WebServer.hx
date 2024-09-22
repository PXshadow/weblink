package weblink._internal;

import haxe.MainLoop;
import sys.net.Host;

class WebServer {
	private var tcpServer:TcpServer;
	private var parent:Weblink;

	public var running:Bool = true;

	public function new(app:Weblink, host:String, port:Int) {
		this.parent = app;

		#if (hl && !nolibuv)
		this.tcpServer = new weblink._internal.hashlink.HashlinkTcpServer();
		#elseif nodejs
		this.tcpServer = new weblink._internal.nodejs.NodeTcpServer();
		#else
		#error "Weblink does not support your target yet"
		#end

		this.tcpServer.startListening(new Host(host), port, this.onConnection);
	}

	private function onConnection(client:TcpClient):Void {
		var request:Null<Request> = null;
		var done:Bool = false;

		client.startReading(chunk -> @:privateAccess {
			if (done) {
				client.closeAsync();
				return;
			}

			final data = switch chunk {
				case Data(bytes): bytes;
				case Eof:
					client.closeAsync();
					return;
			}

			if (request == null) {
				final lines = data.toString().split("\r\n");
				request = new Request(lines);

				if (request.pos >= request.length) {
					done = true;
					this.completeRequest(request, client);
					return;
				}
			} else if (!done) {
				final length = request.length - request.pos < data.length ? request.length - request.pos : data.length;
				request.data.blit(request.pos, data, 0, length);
				request.pos += length;

				if (request.pos >= request.length) {
					done = true;
					this.completeRequest(request, client);
					return;
				}
			}

			if (request.chunked) {
				request.chunk(data.toString());
				if (request.chunkSize == 0) {
					done = true;
					this.completeRequest(request, client);
					return;
				}
			}

			if (request.method != Post && request.method != Put) {
				done = true;
				this.completeRequest(request, client);
			}
		});
	}

	private function completeRequest(request:Request, client:TcpClient) {
		@:privateAccess var response = request.response(this, client);

		if (request.method == Get
			&& @:privateAccess this.parent._serve
			&& response.status == OK
			&& request.path.indexOf(@:privateAccess this.parent._path) == 0) {
			if (@:privateAccess this.parent._serveEvent(request, response)) {
				return;
			}
		}

		switch (this.parent.routeTree.tryGet(request.basePath, request.method)) {
			case Found(handler, params):
				request.routeParams = params;
				handler(request, response);
			case _:
				switch (this.parent.routeTree.tryGet(request.path, request.method)) {
					case Found(handler, params):
						request.routeParams = params;
						handler(request, response);
					case _:
						@:privateAccess this.parent.pathNotFound(request, response);
				}
		}
	}

	public function runBlocking() {
		this.pollOnce();
		while (this.running) {
			this.pollOnce();
		}
	}

	public function pollOnce() {
		@:privateAccess MainLoop.tick(); // progress e.g. timers
		final server = this.tcpServer;
		if (server != null) {
			server.tryPollOnce();
		}
	}

	public inline function update(blocking:Bool = true) {
		if (blocking) {
			this.runBlocking();
		} else {
			this.pollOnce();
		}
	}

	public function closeSync() {
		this.tcpServer.closeSync();
		this.tcpServer = null;
		this.running = false;
	}
}
