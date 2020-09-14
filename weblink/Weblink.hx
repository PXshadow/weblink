package weblink;
import haxe.http.HttpMethod;
import weblink._internal.Server;
private typedef Func = (request:Request,response:Response)->Void;
class Weblink
{
    var server:Server;
    var _get:Func;
    var _post:Func;
    var _head:Func;
    public function new()
    {

    }
    public function get(func:Func)
    {
        this._get = func;
    }
    public function post(func:Func)
    {
        this._post = func;
    }
    public function head(func:Func)
    {
        this._head = func;
    }
    public function listen(port:Int)
    {
        server = new Server(port,this);
        //blocking forever
        server.update();
    }
    public function serve(path:String,dir:String)
    {

    }
    public function close()
    {
        server.close();
    }
    private inline function _postEvent(request:Request,response:Response)
    {

    }
    private inline function _getEvent(request:Request,response:Response)
    {

    }
    private inline function _headEvent(request:Request,response:Response)
    {

    }
}