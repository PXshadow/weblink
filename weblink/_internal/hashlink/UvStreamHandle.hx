package weblink._internal.hashlink;

#if hl
import haxe.io.Bytes;
import hl.uv.Stream;
import weblink._internal.TcpClient.ReadChunk;

/**
	Libuv handle to a "duplex communication channel".
**/
@:forward
abstract UvStreamHandle(UvHandle) to UvHandle {
	/**
		Starts listening for incoming connections.
		@param backlog The maximum number of queued connections.
		@param callback A callback that is executed on an incoming connection.
	**/
	public inline function listen(backlog:Int, callback:() -> Void) {
		final success = @:privateAccess Stream.stream_listen(this, backlog, callback);
		if (!success) {
			// Hashlink bindings do not expose libuv error codes for this operation
			throw "listening to libuv stream did not succeed";
		}
	}

	/**
		Writes binary data to this stream.
	**/
	public inline function writeBytes(bytes:Bytes) {
		final data = (bytes : hl.Bytes).offset(0);
		final success = @:privateAccess Stream.stream_write(this, data, bytes.length, cast null);
		if (!success) {
			// Hashlink bindings do not expose libuv error codes for this operation
			throw "failed to write to libuv stream";
		}
	}

	/**
		Writes a string to this stream.
	**/
	public inline function writeString(string:String) {
		(cast this : UvStreamHandle).writeBytes(Bytes.ofString(string, UTF8));
	}

	/**
		Starts reading data from this stream.
		The callback will be made many times until there is no more data to read.
	**/
	public function readStart(callback:(chunk:ReadChunk) -> Void) {
		final success = @:privateAccess Stream.stream_read_start(this, (buffer, nRead) -> {
			if (nRead > 0) {
				// Data is available
				callback(Data(buffer.toBytes(nRead)));
			} else if (nRead == 0) {
				// Read would block or there is no data available, ignore
			} else {
				final errorCode = nRead;
				switch (errorCode) {
					case -4095:
						callback(Eof);
					case _:
						throw 'read from stream failed with libuv error code $errorCode';
				}
			}
		});

		if (!success) {
			// Hashlink bindings do not expose libuv error codes for this operation
			throw "failed to start reading from libuv stream";
		}
	}
}
#end
