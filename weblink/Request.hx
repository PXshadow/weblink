package weblink;

import haxe.ds.StringMap;
import haxe.http.HttpMethod;
import haxe.io.Bytes;
import weblink._internal.TcpClient;
import weblink._internal.WebServer;

class Request {
	public var cookies:List<Cookie>;
	public var path:String;
	public var basePath:String;

	/** Contains values for parameters declared in the route matched, if there are any. **/
	public var routeParams:Map<String, String>;

	public var ip:String;
	public var baseUrl:String;
	public var headers:StringMap<String>;
	public var text:String;
	public var method:HttpMethod;
	public var data:Bytes;
	public var length:Int;
	public var chunked:Bool = false;

	var chunkSize:Null<Int>;

	public var encoding:Array<String> = [];

	var pos:Int;

	private function new(lines:Array<String>) {
		headers = new StringMap<String>();
		data = null;
		// for (line in lines)
		//    Sys.println(line);
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
		// trace(basePath);
		// trace(path);
		// trace(first.substring(0, index - 1).toUpperCase());
		method = first.substring(0, index - 1).toUpperCase();
		for (i in 0...lines.length - 1) {
			if (lines[i] == "") {
				lines = lines.slice(i + 1);
				break;
			}
			index = lines[i].indexOf(":");
			headers.set(lines[i].substring(0, index), lines[i].substring(index + 2));
		}
		baseUrl = headers.get("Host");

		if (headers.exists("Cookie")) {
			cookies = new List<Cookie>();
			var string = headers.get("Cookie");

			for (sub in string.split(";")) {
				string = StringTools.trim(sub);
				// Split into the component Keyvalue pair for the cookie.
				var keyVal = string.split("=");
				cookies.add(new Cookie(keyVal[0], keyVal[1]));
			}
		}

		if (headers.exists("Transfer-Encoding")) {
			encoding = headers.get("Transfer-Encoding").split(",");
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

	private function response(server:WebServer, client:TcpClient):Response {
		@:privateAccess var rep = new Response(server, client);
		var connection = headers.get("Connection");
		if (connection != null)
			@:privateAccess rep.close = connection == "close"; // assume keep alive HTTP 1.1
		return rep;
	}
}
