package weblink;

import haxe.ds.Either;
import haxe.io.Bytes;
import haxe.http.HttpStatus;
import weblink._internal.Socket;
import weblink._internal.Server;

class Response
{
    public var status:HttpStatus;
    public var contentType:String;
    public var headers:List<Header>;
    var socket:Socket;
    var server:Server;
    var close:Bool = true;
    private function new(socket:Socket,server:Server)
    {
        this.socket = socket;
        this.server = server;
        contentType = "text/text";
        status = OK;
    }
    public inline function sendTextBytes(bytes:Bytes)
    {
        sendHeaders(bytes.length * 4);
        socket.writeBytes(bytes);
        end();
    }
    public inline function send(data:String)
    {
        sendHeaders(data.length);
        socket.writeString(data);
        end();
    }
    private function end()
    {
        if (close) 
        {
            socket.close();
            #if (!hl || nolibuv)
            @:privateAccess server.sockets.remove(socket);
            #end
        }
        socket = null;
        server = null;
    }
    public function sendHeaders(length:Int)
    {
        var string = 'HTTP/1.1 $status OK\r\n' +
        'Acess-Control-Allow-Origin: *\r\n' +
        'Content-type: $contentType\r\n' +
        'Content-length: $length\r\n';
        if (headers != null) 
        {
            for (header in headers)
            {
                string += header.key + ": " + header.value + "\r\n";
            }
            headers = null;
        }
        string += "\r\n";
        socket.writeString(string);
    }
}
private typedef Header = {key:String,value:String}