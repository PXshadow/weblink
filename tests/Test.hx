package;

import haxe.Timer;
import sys.io.Process;
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
            response.send("HELLO WORLD\n");
        });
        function data(text:String)
        {
            text = StringTools.replace(text,"\n","");
            if (text != "HELLO WORLD") throw 'Invalid data: $text';
            trace('Data retrieved: $text');
        }
        Thread.create(function()
        {
            Sys.sleep(1);
            #if curl
            trace("CURL");
            var curl = new Process("curl localhost:2000");
            data(curl.stdout.readLine());
            #end
            trace("HTTP");
            var stamp = Timer.stamp();
            var http = new Http("localhost:2000");
            http.onData = function(text:String)
            {
                app.close();
                data(text);
                trace('time ${Timer.stamp() - stamp}');
                Sys.exit(0);
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