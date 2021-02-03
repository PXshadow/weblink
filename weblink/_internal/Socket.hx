package weblink._internal;

import haxe.io.Bytes;

private typedef Basic = hl.uv.Stream

abstract Socket(Basic) {
	inline public function new(i:Basic) {
		this = i;
	}

	public inline function writeString(string:String) {
		this.write(Bytes.ofString(string, UTF8));
	}

	public inline function writeBytes(bytes:Bytes) {
		this.write(bytes);
	}

	public function close() {
		this.close();
	}
}
