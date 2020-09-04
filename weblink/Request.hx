package weblink;
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
    public function new(lines:Array<String>)
    {
        read(lines);
    }
    public function read(lines:Array<String>)
    {
        var index = lines[0].indexOf("/");
        method = lines[0].substring(0,index - 1);
        trace('method: $method');
    }
}