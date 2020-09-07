package;

import haxe.Timer;
import sys.io.Process;
import haxe.Http;

class Test
{
    public static function main()
    {
        Sys.println("start test");
        var app = new weblink.Weblink();
        app.get(function(request,response)
        {
            response.send("HELLO WORLD\n");
        });
        function data(text:String)
        {
            text = StringTools.replace(text,"\n","");
            if (text != "HELLO WORLD") 
            {
                app.close();
                throw 'Invalid data: $text';
            }
            trace('Data retrieved: $text');
            app.close();
        }
        Timer.delay(function()
        {
            trace("START!");
            #if curl
            trace("CURL");
            var curl = new Process("curl localhost:2000");
            data(curl.stdout.readLine());
            #end
            #if (http && (target.threaded))
            sys.thread.Thread.create(function()
            {
                var stamp = Timer.stamp();
                var http = new Http("localhost:2000");
                http.onData = function(text:String)
                {
                    trace('time ${Timer.stamp() - stamp}');
                    data(text);
                }
                http.onError = function(error:String)
                {
                    trace("error: " + error);
                }
                http.request(false);
            });
            #end
        },1000);
        Timer.delay(function()
        {
            trace("set listen");
            app.listen(2000);
        },0);
    }
}