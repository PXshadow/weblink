package weblink;
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
    private function new(lines:Array<String>)
    {
        headers = new StringMap<String>();
        read(lines);
    }
    private inline function read(lines:Array<String>)
    {
        var first = lines.shift();
        var index = first.indexOf("/");
        path = first.substring(index,first.indexOf(" ",index + 1));
        method = first.substring(0,index - 1);
        for (line in lines)
        {
            index = line.indexOf(":");
            headers.set(line.substring(0,index),line.substring(index + 2));
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
    }
    private function response(parent:Server,socket):Response
    {
        @:privateAccess var rep = new Response(socket,parent);
        var connection = headers.get("Connection");
        if (connection != null) @:privateAccess rep.close = connection == "close"; //assume keep alive HTTP 1.1
        return rep;
    }
}