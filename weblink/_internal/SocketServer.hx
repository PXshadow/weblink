package weblink._internal;

import sys.thread.Thread;
import sys.net.Host;
import weblink._internal.Socket.Stream;
#if js
class SocketServer

#elseif cs
class SocketServer {
	public var socket:sys.net.Socket;
	public var cons = new Array<Socket.Stream>();
	public function new(loop:Server.Loop) {
		socket=new sys.net.Socket();
	};
	public function close(?callb:() -> Void) {
		socket.close();
		callb();
	}

	
	public dynamic function on_connect(con) {
		trace("connected", con);
	}

	public function bind(host:Host, port:Int) {
		socket.bind(host,port);
	}

	public function listen(backlog:Int, cb:Void->Void) {
		socket.listen(backlog);
		Thread.create(()->{
			while(true){
				var next=socket.accept();
				cons.push(new Stream(next));
				cb();
			}
		});
	}

	public function accept() {
		return cons.shift();
	}

	public function noDelay(yn:Bool) {}
	public function noWait(yn:Bool) {}
}
#else
class SocketServer extends #if (hl && !nolibuv) hl.uv.Tcp #else sys.net.Socket #end
#end
#if !cs
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
			cons.push(con);
			cb();
		});
	}

	public function accept() {
		return cons.shift();
	}

	public function noDelay(yn:Bool) {}

	public function close(?callb:Null<() -> Void>) {
		node_socket.close(callb);
	}
	#end
}
#end