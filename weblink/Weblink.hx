package weblink;
import haxe.http.HttpMethod;
import weblink._internal.Server;

class Weblink
{
    var server:Server;
    var func:(request:Request,response:Response)->Void;
    public function new()
    {

    }
    public function get(func:(request:Request,response:Response)->Void)
    {
        this.func = func;
    }
    public function listen(port:Int)
    {
        server = new Server(port,this);
        //blocking forever
        server.update();
    }
    public function close()
    {
        server.close();
    }
}