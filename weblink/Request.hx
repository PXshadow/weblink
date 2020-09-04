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
        headers = new StringMap<String>();
        read(lines);
    }
    public function read(lines:Array<String>)
    {
        for (line in lines)
        {
            trace(line);
        }
        var index = lines[0].indexOf("/");
        method = lines[0].substring(0,index - 1);
        for (i in 1...lines.length - 1)
        {
            index = lines[i].indexOf(":");
            headers.set(lines[i].substring(0,index),lines[i].substring(index + 2));
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
}