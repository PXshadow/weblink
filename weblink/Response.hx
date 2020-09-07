package weblink;

import haxe.ds.List;
import sys.net.Socket;
import haxe.http.HttpStatus;

class Response
{
    public var status:HttpStatus;
    public var contentType:String;
    public var headers:List<Header>;
    var socket:Socket;
    public function new(socket:Socket)
    {
        this.socket = socket;
        contentType = "text/text";
        status = OK;
    }
    public function send(text:String)
    {
        var string = 'HTTP/1.1 $status OK\n' +
        'Acess-Control-Allow-Origin: *\n' +
        'Server: Custom\n' +
        'Date: Mon, 18 Jul 2016 16:06:00 GMT\n' +
        'Last-Modified: Mon, 18 Jul 2016 16:06:00 GMT\n' +
        'Content-type: $contentType\n' +
        'Content-length: ${text.length}\n';
        if (headers != null) for (header in headers)
        {
            string += header.key + ": " + header.value + "\n";
        }
        string += '\n$text';

        trace(text);
        socket.output.writeString(string);
    }
}
private typedef Header = {key:String,value:String}