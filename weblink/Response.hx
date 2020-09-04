package weblink;

import sys.net.Socket;
import haxe.http.HttpStatus;

class Response
{
    public var status:HttpStatus;
    var socket:Socket;
    public function new(socket:Socket)
    {
        this.socket = socket;
    }
    public function send(text:String)
    {

    }
}