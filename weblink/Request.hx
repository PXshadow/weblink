package weblink;
import sys.net.Socket;
import haxe.http.HttpMethod;
import haxe.ds.StringMap;

class Request
{
    public var cookies:StringMap<String>;
    public var path:String;
    public var ip:String;
    public var baseUrl:String;
    public var headers:StringMap<String>;
    public var text:String;
    public var method:HttpMethod;
    private function new(lines:List<String>)
    {
        headers = new StringMap<String>();
        read(lines);
    }
    private function read(lines:List<String>)
    {
        var first = lines.pop();
        var index = first.indexOf("/");
        method = first.substring(0,index - 1);
        for (line in lines)
        {
            index = line.indexOf(":");
            headers.set(line.substring(0,index),line.substring(index + 2));
        }
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
    private function response(parent:Server,socket:Socket):Response
    {
        @:privateAccess var rep = new Response(socket);
        var connection = headers.get("Connection");
        if (connection != null) @:privateAccess rep.close = connection.toLowerCase() != "keep-alive";
        @:privateAccess parent.sockets.remove(socket);
        return rep;
    }
}