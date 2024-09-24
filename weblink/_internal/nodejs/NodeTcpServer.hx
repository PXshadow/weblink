package weblink._internal.nodejs;

#if nodejs
import js.node.Net;
import js.node.net.Server;
import sys.net.Host;
import weblink._internal.TcpServer;

final class NodeTcpServer extends TcpServer {
	private var nodeServer:Server;

	public function new() {
		this.nodeServer = Net.createServer(cast {noDelay: true}, null);
	}

	public function startListening(host:Host, port:Int, callback:(client:TcpClient) -> Void) {
		var started:Bool = false;
		this.nodeServer.on(Connection, socket -> {
			final client = new NodeTcpClient(socket);
			callback(client);
		});
		this.nodeServer.listen(port, host.host, 100, () -> {
			started = true;
		});
		Deasync.loopWhile(() -> !started);
	}

	public override function tryPollOnce():Bool {
		Deasync.runLoopOnce();
		return true;
	}

	public function closeSync() {
		final nodeServer = this.nodeServer;
		if (nodeServer == null) {
			return; // already closed
		}

		@:nullSafety(Off) this.nodeServer = null;
		var closed:Bool = false;
		nodeServer.close(() -> {
			nodeServer.unref();
			closed = true;
		});

		Deasync.loopWhile(() -> !closed);
	}
}

@:jsRequire('deasync')
private extern class Deasync {
	public static function loopWhile(fn:() -> Bool):Void;
	public static function runLoopOnce():Void;
}
#end
