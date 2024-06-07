package weblink._internal;

import sys.net.Host;

#if js
class SocketServer
#else
class SocketServer extends #if (hl && !nolibuv) hl.uv.Tcp #else sys.net.Socket #end
#end
{
	#if js
	public var node_socket:js.node.net.Server;
	public var cons = new Array<Socket.Stream>();
	public function new(loop:Server.Loop) {}

	public dynamic function on_connect(con) {
		trace("connected", con);
	}

	public function bind(host:Host, port:Int) {
		node_socket = new js.node.net.Server();
		node_socket.listen(port, host.host);
	}

	public function listen(backlog:Int, cb:Void->Void) {
		node_socket.on("connection", function(con) {
			trace("new con", con);
			cons.push(con);
			cb();
		});
	}

	public function accept() {
		trace("handling");
		return cons.shift();
	}

	public function noDelay(yn:Bool) {}

	public function close(?callb:Null<() -> Void>) {
		node_socket.close(callb);
	}
	#end
}
