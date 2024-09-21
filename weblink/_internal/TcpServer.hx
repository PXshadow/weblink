package weblink._internal;

import sys.net.Host;

/**
	An interface for platform-specific TCP server implementations.
**/
abstract class TcpServer {
	/**
		Binds this server to the given interface
		and starts listening for incoming TCP connections.

		Note: This method waits until the server is ready to accept connections,
		but does not block on the actual connections.

		@param host The interface to bind to.
		@param port The port to listen on.
		@param callback A callback that is executed when a client connects.
	**/
	public abstract function startListening(host:Host, port:Int, callback:(client:TcpClient) -> Void):Void;

	/**
		If applicable, polls the server for incoming connections.
	**/
	public function tryPollOnce():Bool {
		return false;
	}

	/**
		Shuts the server down and frees the underlying resources if necessary.

		Note: This call is blocking.
	**/
	public abstract function closeSync():Void;
}
