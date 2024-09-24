package weblink._internal;

import haxe.io.Bytes;

/**
	A target-independent handle for a connected TCP client.
**/
abstract class TcpClient {
	/**
		Starts reading data from the client.
		@param callback A callback that is executed when a chunk of data is received.
	**/
	public abstract function startReading(callback:(chunk:ReadChunk) -> Void):Void;

	/**
		Writes raw bytes to the client.
	**/
	public abstract function writeBytes(bytes:Bytes):Void;

	/**
		Writes a string to the client.
	**/
	public function writeString(string:String):Void {
		this.writeBytes(Bytes.ofString(string, UTF8));
	}

	/**
		Disconnects the client and frees the underlying resources if necessary.

		Note: This call is non-blocking.
	**/
	public abstract function closeAsync(?callback:() -> Void):Void;
}

enum ReadChunk {
	Data(bytes:Bytes);
	Eof;
}
