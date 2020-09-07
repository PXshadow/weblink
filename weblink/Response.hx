package weblink;

import haxe.http.HttpStatus;
import weblink._internal.Socket;

class Response
{
    public var status:HttpStatus;
    public var contentType:String;
    public var headers:List<Header>;
    var socket:Socket;
    var close:Bool = true;
    private function new(socket:Socket)
    {
        this.socket = socket;
        contentType = "text/text";
        status = OK;
    }
    public function send(text:String)
    {
        var string = 'HTTP/1.1 $status OK\r\n' +
        'Acess-Control-Allow-Origin: *\r\n' +
        'Content-type: $contentType\r\n' +
        'Content-length: ${text.length}\r\n';
        if (headers != null) for (header in headers)
        {
            string += header.key + ": " + header.value + "\r\n";
        }
        string += '\r\n$text';
        socket.writeString(string);
        //if (close) socket.close();
    }
}
private typedef Header = {key:String,value:String}