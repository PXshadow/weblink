package weblink;
import haxe.http.HttpMethod;
import weblink._internal.Server;
import weblink._internal.Mime;
using haxe.io.Path;
private typedef Func = (request:Request,response:Response)->Void;
class Weblink
{
    var server:Server;
    var _get:Func;
    var _post:Func;
    var _head:Func;
    var _serve:Bool = false;
    var _path:String;
    var _dir:String;
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
        try {
        server.update();
        }catch(e:Dynamic)
        {
            #if weblink_log
            trace(e); //main issue being Acess Violation
            #end
        }
    }
    public function serve(path:String="",dir:String="")
    {
        _path = path;
        _dir = dir;
        _serve = true;
    }
    public function close()
    {
        server.close();
    }
    private inline function _postEvent(request:Request,response:Response)
    {
        _post(request,response);
    }
    private function _getEvent(request:Request,response:Response)
    {
        if (_serve && response.status == OK && request.path.indexOf(_path) == 0)
        {
            if (_serveEvent(request,response)) return;
        }
        _get(request,response);
    }
    private inline function _serveEvent(request:Request,response:Response):Bool
    {
        var ext = request.path.extension();
        var mime = weblink._internal.Mime.types.get(ext);
        response.contentType = mime == null ? "text/plain" : mime;
        var path = Path.join([_dir,request.path.substr(_path.length)]).normalize();
        if (sys.FileSystem.exists(path))
        {
            if (sys.FileSystem.isDirectory(path))
            {
                response.contentType = "text/html";
                path = Path.join([path,"index.html"]);
                if (sys.FileSystem.exists(path))
                {
                    response.sendBytes(sys.io.File.getBytes(path));
                    return true;
                }
                return false;
            }else{
                response.sendBytes(sys.io.File.getBytes(path));
                return true;
            }
        }else{
            //trace('file not found $path');
            return false;
        }
    }
    private inline function _headEvent(request:Request,response:Response)
    {
        _head(request,response);
    }
}