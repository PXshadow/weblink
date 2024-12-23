package weblink._internal;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
#if js
import js.node.Buffer;
#end
#if hl
import hl.uv.Stream;
#elseif js
// typedef Stream = js.node.net.Socket;

abstract Stream(js.node.net.Socket) {
	// public extern function write(b:Bytes):Void;
	// public extern function close(?callb:() -> Void):Void;
	public function new(s:js.node.net.Socket) {
		this = s;
	}

	public function readStart(callb:(data:Bytes) -> Void) {
		// var bb = new BytesBuffer();
		this.on("data", function(d:Buffer) {
			// bb.add(d.hxToBytes());
			callb(d.hxToBytes());
		});
		/*
			this.on("end", function(d:Buffer) {
				callb(bb.getBytes());
		});*/
	}

	public function close() {
		this.end();
	}

	// TODO we really want a js buffer
	public function write(b:Bytes) {
		this.write(b.toString());
	}
}
#elseif cs
abstract Stream(sys.net.Socket) {
	public function new(s) {
		trace("creating new socket");
		this = s;
	}

	public function readStart(callb:(data:Bytes) -> Void) {
		// var bb = new BytesBuffer();
		this.setTimeout(3);
		while (true) {
			trace("waiting for read");
			try {
				this.waitForRead();
				trace('done reading ');
				var bufsize = (1 << 14); // 16 Ko

				var buf = Bytes.alloc(bufsize);
				trace('going to read bytes');
				var len = this.input.readBytes(buf, 0, bufsize);
				trace('done reading $len');
				var text = buf.toString();
				callb(Bytes.ofString(text));
			} catch (ex) {
				trace(ex);
				break;
			}
		}
		/*
			this.on("data", function(d:Buffer) {
				// bb.add(d.hxToBytes());
				callb(d.hxToBytes());
			});
		 */
		/*
			this.on("end", function(d:Buffer) {
				callb(bb.getBytes());
		});*/
	}

	public function close() {
		this.close();
	}

	// TODO we really want a js buffer
	public function write(b:Bytes) {
		this.write(b.toString());
	}
}
#end

private typedef Basic = Stream

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
