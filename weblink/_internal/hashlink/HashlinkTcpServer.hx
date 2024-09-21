package weblink._internal.hashlink;

import sys.thread.Lock;
#if hl
import hl.uv.Loop;
import sys.net.Host;
import weblink._internal.TcpServer;
import weblink._internal.hashlink.UvTcpHandle;

final class HashlinkTcpServer extends TcpServer {
	private var server:UvTcpHandle;
	private var loop:Loop;

	public function new() {
		final loop = Loop.getDefault();
		if (loop == null) {
			throw "cannot get or init a default loop";
		}
		this.loop = loop;
		this.server = new UvTcpHandle(loop);
		this.server.setNodelay(true);
	}

	public function startListening(host:Host, port:Int, callback:(client:TcpClient) -> Void) {
		this.server.bind(host, port);
		this.server.listen(100, () -> {
			final clientSocket = this.server.accept();
			final client = new HashlinkTcpClient(clientSocket);
			callback(client);
		});
	}

	public override function tryPollOnce():Bool {
		this.loop.run(NoWait);
		return true;
	}

	public function closeSync() {
		final server = this.server;
		if (server == null) {
			return; // already closed
		}

		@:nullSafety(Off) this.server = null;
		final lock = new Lock();
		server.closeAsync(() -> {
			this.loop.stop();
			lock.release();
		});

		if (!lock.wait(5)) {
			throw "timed out waiting for server to close";
		}
	}
}
#end
