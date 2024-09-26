package weblink.http;

/**
	A specialized map with case-insensitive keys and multiple values.
	Note: This implementation may not be thread-safe.
**/
@:nullSafety(StrictThreaded)
final class HeaderMap {
	private var inner:Map<HeaderName, Array<HeaderValue>>;

	/**
		Creates a new empty map.
	**/
	public inline function new() {
		this.inner = [];
	}

	/**
		Returns all values associated with the name, if there are any.
	**/
	public inline function getAll(key:HeaderName):Null<Array<HeaderValue>> {
		return this.inner.get(key);
	}

	/**
		Returns a single value associated with the name, if there is one.

		If multiple values are associated with the name, the first one is returned.
		Use `getAll()` to get all values.
	**/
	public function get(key:HeaderName):Null<HeaderValue> {
		final values = this.getAll(key);
		return values != null && values.length > 0 ? values[0] : null;
	}

	/**
		Gets an array of values for a given name.

		If the inner mapping for the key does not exist, it will be created.
	**/
	private function ensureHasValues(key:HeaderName):Array<HeaderValue> {
		var values = this.getAll(key);
		if (values == null) {
			values = [];
			this.inner.set(key, values);
		}
		return values;
	}

	/**
		Adds a header to the list of headers with this name.
	**/
	public inline function add(key:HeaderName, value:HeaderValue) {
		final values = this.ensureHasValues(key);
		values.push(value);
	}

	/**
		Sets a header as an only header with this name.
	**/
	public inline function set(key:HeaderName, value:HeaderValue) {
		final values = this.ensureHasValues(key);
		values.resize(0);
		values.push(value);
	}

	/**
		Checks if the given header name exists in the map.
	**/
	public function exists(key:HeaderName):Bool {
		final values = this.getAll(key);
		return values != null && values.length > 0;
	}

	/**
		Removes all headers with the given name from this map.
	**/
	public inline function remove(key:HeaderName):Bool {
		return this.inner.remove(key);
	}

	/**
		Returns an iterator over the header names in this map.
	**/
	public inline function keys():Iterator<HeaderName> {
		return this.inner.keys();
	}

	/**
		Returns an iterator over the value groups in this map.
	**/
	public inline function iterator():Iterator<Array<HeaderValue>> {
		return this.inner.iterator();
	}

	/**
		Returns an iterator over the headers in this map.
	**/
	public inline function keyValueIterator():KeyValueIterator<HeaderName, Array<HeaderValue>> {
		return this.inner.keyValueIterator();
	}

	/**
		Returns a string representation of this map.
	**/
	public inline function toString():String {
		return this.inner.toString();
	}

	/**
		Clears the map, removing all key-value pairs.
	**/
	public inline function clear() {
		this.inner.clear();
	}

	/**
		Copies the headers from a `Map<String, String>` source, like `haxe.Http#responseHeaders`.
		Useful when wanting to compare headers in an case-insensitive way.
	**/
	public static function copyFrom(source:Map<String, String>):HeaderMap {
		final target = new HeaderMap();
		for (key => value in source) {
			target.add(key, value);
		}
		return target;
	}
}
