package weblink._internal.hashlink;

#if hl
import hl.uv.Loop;
import hl.uv.Tcp;
import sys.net.Host;

/**
	Libuv handle to a TCP stream or server.
**/
@:forward
abstract UvTcpHandle(UvStreamHandle) to UvStreamHandle {
	/**
		Initializes a new handle.
	**/
	public inline function new(loop:Loop) {
		this = cast @:privateAccess Tcp.tcp_init_wrap(loop);
		if (this == null) {
			// Hashlink bindings do not expose libuv error codes for this operation
			throw "libuv TCP handle could not be initialized";
		}
	}

	/**
		Enables TCP_NODELAY by disabling Nagle's algorithm, or vice versa.
	**/
	public inline function setNodelay(value:Bool) {
		@:privateAccess Tcp.tcp_nodelay_wrap(cast this, value);
	}

	/**
		If a client connection is initiated,
		tries to set up a handle for the TCP client socket.
	**/
	public inline function accept():UvTcpHandle {
		final client:Null<UvTcpHandle> = cast @:privateAccess Tcp.tcp_accept_wrap(cast this);
		if (client == null) {
			// Hashlink bindings do not expose libuv error codes for this operation
			throw "could not accept incoming TCP connection";
		}

		return client;
	}

	/**
		Tries to bind the handle to an address and port.
	**/
	public inline function bind(host:Host, port:Int) {
		final success = @:privateAccess Tcp.tcp_bind_wrap(cast this, host.ip, port);
		if (!success) {
			// Hashlink bindings do not expose libuv error codes for this operation
			throw 'failed to bind libuv TCP socket to $host:$port" (is the port already in use?)';
		}
	}
}
#end
