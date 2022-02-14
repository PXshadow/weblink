package weblink;

import haxe.ds.Either;
import haxe.io.Bytes;
import haxe.http.HttpStatus;
import weblink.Cookie;
import weblink._internal.Socket;
import weblink._internal.Server;
import weblink._internal.HttpStatusMessage;

class Response {
	public var status:HttpStatus;
	public var contentType:String;
	public var headers:List<Header>;
	
	public var cookies:List<Cookie>;

	var socket:Socket;
	var server:Server;
	var close:Bool = true;

	private function new(socket:Socket, server:Server) {
		this.socket = socket;
		this.server = server;
		contentType = "text/html";
		status = OK;
	}

	public inline function sendBytes(bytes:Bytes) {
		socket.writeString(sendHeaders(bytes.length).toString());
		socket.writeBytes(bytes);
		end();
	}

	public inline function redirect(path:String) {
		status = MovedPermanently;
		headers = new List<Header>();
		var string = initLine();
		string += 'Location: $path\r\n\r\n';
		socket.writeString(string);
		end();
	}

	public inline function send(data:String) {
		var buff = sendHeaders(data.length);
		buff.add(data);
		socket.writeString(buff.toString());
		end();
	}

	private function end() {
		if (close) {
			server.closeSocket(socket);
		}
		socket = null;
		server = null;
	}

	private inline function initLine():String {
		return 'HTTP/1.1 $status ${HttpStatusMessage.fromCode(status)}\r\n';
	}

	public inline function sendHeaders(length:Int):StringBuf {
		var string = new StringBuf();
		string.add(initLine()
			+ // 'Acess-Control-Allow-Origin: *\r\n' +
			'Connection: ${close ? "close" : "keep-alive"}\r\n'
			+ 'Content-type: $contentType\r\n'
			+ 'Content-length: $length\r\n');
		if (cookies != null) {
			for (cookie in cookies) {
				string.add("Set-Cookie: " + cookie.resolveToResponseString() + "\r\n");
			}
		}
		if (headers != null) {
			for (header in headers) {
				string.add(header.key + ": " + header.value + "\r\n");
			}
			headers = null;
		}
		string.add("\r\n");
		return string;
	}
}
