package weblink._internal.nodejs;

#if nodejs
import haxe.io.Bytes;
import js.node.Buffer;
import js.node.net.Socket;
import weblink._internal.TcpClient;

final class NodeTcpClient extends TcpClient {
	private var socket:Socket;

	public inline function new(socket:Socket) {
		this.socket = socket;
	}

	public function startReading(callback:(chunk:ReadChunk) -> Void):Void {
		final socket = this.socket;
		socket.on(SocketEvent.End, () -> callback(Eof));
		socket.on(SocketEvent.Error, error -> throw error);
		socket.on(SocketEvent.Timeout, () -> this.socket.destroy());
		socket.on(SocketEvent.Data, data -> {
			final buffer:Buffer = cast data;
			final bytes = buffer.hxToBytes();
			callback(Data(bytes));
		});
	}

	public function writeBytes(bytes:Bytes) {
		this.socket.write(Buffer.hxFromBytes(bytes));
	}

	public function closeAsync(?callback:() -> Void) {
		final socket = this.socket;
		@:nullSafety(Off) this.socket = null;
		if (socket != null) {
			socket.end(untyped undefined, untyped undefined, callback);
		}
	}
}
#end
