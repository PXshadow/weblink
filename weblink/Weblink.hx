package weblink;

import haxe.http.HttpMethod;

class Weblink
{
    var server:Server;
    public function new()
    {

    }
    public function get(request:Request,response:Response)
    {
        
    }
    public function listen(port:Int)
    {
        server = new Server(port);
        //blocking forever
        while (true) server.update();
    }
}