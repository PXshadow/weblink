package;

import haxe.Http;
import sys.thread.Thread;

class Test
{
    public static function main()
    {
        Sys.println("start test");
        var app = new weblink.Weblink();
        app.get(function(request,response)
        {
            response.send("HELLO WORLD");
        });
        Thread.create(function()
        {
            Sys.sleep(1);
            var http = new Http("localhost:2000");
            http.onData = function(text:String)
            {
                trace("http: " + text);
            }
            http.onError = function(error:String)
            {
                trace("error: " + error);
            }
            http.request(false);
        });
        app.listen(2000);
    }
}