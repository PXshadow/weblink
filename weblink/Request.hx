package weblink;
import haxe.io.Bytes;
import haxe.http.HttpMethod;
import haxe.ds.StringMap;
import weblink._internal.Server;

class Request
{
    public var cookies:StringMap<String>;
    public var path:String;
    public var ip:String;
    public var baseUrl:String;
    public var headers:StringMap<String>;
    public var text:String;
    public var method:HttpMethod;
    public var data:Bytes;
    public var length:Int;
    var pos:Int;
    private function new(lines:Array<String>)
    {
        headers = new StringMap<String>();
        data = null;
        
        var index = 0;
        var first = lines[0];
        var index = first.indexOf("/");
        path = first.substring(index,first.indexOf(" ",index + 1));
        method = first.substring(0,index - 1);
        for (i in 0...lines.length - 1)
        {
            if (lines[i] == "") break;
            index = lines[i].indexOf(":");
            headers.set(lines[i].substring(0,index),lines[i].substring(index + 2));
        }
        baseUrl = headers.get("Host");
        if (headers.exists("Cookie"))
        {
            cookies = new StringMap<String>();
            var string = headers.get("Cookie");
            for (sub in string.split(";"))
            {
                string = StringTools.trim(sub);
                index = string.indexOf("=");
                cookies.set(string.substring(0,index),string.substring(index + 1));
            }
        }
        if (method == Post) 
        {
            length = Std.parseInt(headers.get("Content-Length"));
            pos = 0;
            data = Bytes.alloc(length);
        }
    }
    /*private inline function read(lines:Array<String>)
    {
        
    }*/
    public function query():Any
    {
        final r = ~/(?:\?|&|;)([^=]+)=([^&|;]+)/;
        var obj = {};
        var init:Bool = true;
        var string:String = path;
        while (r.match(string))
        {
            if (init)
            {
                var pos = r.matchedPos().pos;
                path = path.substring(0,pos);
                init = false;
            }
            //0 entire, 1 name, 2 value
            Reflect.setField(obj,r.matched(1),r.matched(2));
            string = r.matchedRight();
        }
        return obj;
    }
    private function response(parent:Server,socket):Response
    {
        @:privateAccess var rep = new Response(socket,parent);
        var connection = headers.get("Connection");
        if (connection != null) @:privateAccess rep.close = connection == "close"; //assume keep alive HTTP 1.1
        return rep;
    }
}