package weblink._internal.hashlink;

#if hl
import haxe.io.Bytes;
import weblink._internal.TcpClient;
import weblink._internal.hashlink.UvStreamHandle;

final class HashlinkTcpClient extends TcpClient {
	private var inner:UvStreamHandle;

	public inline function new(handle:UvStreamHandle) {
		this.inner = handle;
	}

	public function startReading(callback:(chunk:ReadChunk) -> Void):Void {
		this.inner.readStart(callback);
	}

	public function writeBytes(bytes:Bytes) {
		this.inner.writeBytes(bytes);
	}

	public function closeAsync(?callback:() -> Void) {
		final inner = this.inner;
		@:nullSafety(Off) this.inner = null;
		if (inner != null) {
			this.inner.closeAsync(callback);
		}
	}
}
#end
