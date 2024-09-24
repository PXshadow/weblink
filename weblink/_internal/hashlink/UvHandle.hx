package weblink._internal.hashlink;

#if hl
import hl.uv.Handle;

private typedef RawHandle = hl.Abstract<"uv_handle">;

/**
	Base libuv handle.
**/
abstract UvHandle(RawHandle) from RawHandle to RawHandle {
	/**
		Requests this resource to be closed.

		Note: This call is non-blocking.
		@param callback Optional callback that is executed when the handle is closed.
	**/
	public inline function closeAsync(?callback:() -> Void) {
		@:privateAccess Handle.close_handle(this, cast callback);
	}
}
#end
