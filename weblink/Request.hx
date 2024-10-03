package weblink;

import haxe.http.HttpMethod;
import haxe.io.Bytes;
import weblink._internal.Server;
import weblink.http.HeaderMap;
import weblink.http.HeaderName;
import weblink.http.HeaderValue;

using StringTools;

class Request {
	public var cookies:List<Cookie>;
	public var path:String;
	public var basePath:String;

	/** Contains values for parameters declared in the route matched, if there are any. **/
	public var routeParams:Map<String, String>;

	public var ip:String;
	public var baseUrl:String;
	public final headers:HeaderMap;
	public var text:String;
	public var method:HttpMethod;
	public var data:Bytes;
	public var length:Int;
	public var chunked:Bool = false;

	var chunkSize:Null<Int>;

	public final encoding:Array<String>;

	var pos:Int;

	private function new(lines:Array<String>) {
		data = null;

		if (lines.length == 0)
			return;
		var index = 0;
		var first = lines[0];
		var index = first.indexOf("/");
		path = first.substring(index, first.indexOf(" ", index + 1));
		var index2 = path.indexOf("/", 1);
		var index3 = path.indexOf("?", 1);
		if (index2 == -1)
			index2 = index3;
		if (index2 != -1) {
			basePath = path.substr(0, index2);
		} else {
			basePath = path;
		}

		method = first.substring(0, index - 1).toUpperCase();

		final headers = this.headers = new HeaderMap();
		for (i in 0...lines.length - 1) {
			if (lines[i] == "") {
				lines = lines.slice(i + 1);
				break;
			}
			index = lines[i].indexOf(":");

			final left = lines[i].substring(0, index);
			switch (HeaderName.tryNormalizeString(left)) {
				case Valid(name):
					final right = lines[i].substring(index + 2).trim();
					switch (HeaderValue.validateString(right, false)) {
						case Valid(value):
							if (name.allowsRawCommaSeparatedValues()) {
								for (subvalue in value.split(",").map(v -> v.trim())) {
									headers.add(name, cast subvalue);
								}
							} else if (name.allowsRawSemicolonSeparatedValues()) {
								for (subvalue in value.split(";").map(v -> v.trim())) {
									headers.add(name, cast subvalue);
								}
							} else if (name.doesNotAllowRepeats() && headers.exists(name)) {
								// Idea: respond with 400 Bad Request
								headers.set(name, value);
							} else {
								headers.add(name, value);
							}
						case _:
							// Silently ignore that the header value is invalid
							// Idea: respond with 400 Bad Request immediately
					}
				case _:
					// Silently ignore that the header name is invalid
					// Idea: respond with 400 Bad Request immediately
			}
		}

		this.baseUrl = headers.get(Host);

		this.cookies = new List<Cookie>();
		final cookieValues = headers.getAll(Cookie);
		if (cookieValues != null) {
			for (value in cookieValues) {
				final parts = value.split("=");
				this.cookies.add(new Cookie(parts[0], parts[1]));
			}
		}

		this.encoding = [];
		final encodingValues = headers.getAll(TransferEncoding);
		if (encodingValues != null) {
			for (value in encodingValues) {
				this.encoding.push(value);
			}
		}

		if (method == Post || method == Put) {
			chunked = false;
			if (encoding.indexOf("chunked") > -1) {
				data = Bytes.alloc(0);
				pos = 0;
				length = 0;
				chunkSize = null;
				chunked = true;
				chunk(lines.join("\r\n"));
				return;
			}
			if (encoding.indexOf("gzip") > -1) {
				trace("gzip not supported yet");
			}
			length = Std.parseInt(headers.get("Content-Length"));
			data = Bytes.alloc(length);
			pos = 0;
			// inital data
			if (lines.length > 0 && length > 0) {
				var bytes = Bytes.ofString(lines.join("\r\n"));
				var length = length < bytes.length ? length : bytes.length;
				data.blit(0, bytes, 0, length);
				pos = bytes.length;
			}
		}
	}

	function chunk(string:String) {
		var index = 0;
		var buffer = new StringBuf();
		pos = 0;
		while (chunkSize != 0) {
			if (chunkSize > 0) {
				var s = string.substr(pos, chunkSize);
				buffer.add(s);
				pos += s.length;
				if (s.length < chunkSize)
					break; // append later
				pos += 2;
			}
			index = string.indexOf("\r\n", pos);
			if (index == -1) {
				// error
				chunkSize = 0;
				break;
			}
			var num = string.substring(pos, index);
			pos = index + 2;
			chunkSize = Std.parseInt(num);
			if (chunkSize == null)
				chunkSize = Std.parseInt('0x$num');
			if (chunkSize == null)
				chunkSize = 0;
		}
		if (chunkSize == 0)
			chunked = false;
		var bytes = Bytes.ofString(buffer.toString());
		length = data.length + bytes.length;
		var tmp = Bytes.alloc(length);
		tmp.blit(0, data, 0, data.length);
		tmp.blit(data.length, bytes, 0, bytes.length);
		data = tmp;
	}

	public function query():Any {
		final r = ~/(?:\?|&|;)([^=]+)=([^&|;]+)/;
		var obj = {};
		var init:Bool = true;
		var string:String = path;
		while (r.match(string)) {
			if (init) {
				var pos = r.matchedPos().pos;
				path = path.substring(0, pos);
				init = false;
			}
			// 0 entire, 1 name, 2 value
			Reflect.setField(obj, r.matched(1), r.matched(2));
			string = r.matchedRight();
		}
		return obj;
	}

	private function response(parent:Server, socket):Response {
		@:privateAccess var rep = new Response(socket, parent);
		var connection = headers.get("Connection");
		if (connection != null)
			@:privateAccess rep.close = connection == "close"; // assume keep alive HTTP 1.1
		return rep;
	}
}
