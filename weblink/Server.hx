package weblink;

import sys.thread.Thread;
import haxe.http.HttpMethod;
import haxe.Exception;
import sys.net.Host;
import sys.net.Socket;

class Server extends Socket
{
    var sockets:Array<Socket>;
    var parent:Weblink;
    public function new(port:Int,parent:Weblink)
    {
        super();
        this.parent = parent;
        sockets = [];
        bind(new Host("0.0.0.0"),port);
        listen(100); //queue up 100 connection sockets
        Thread.create(function()
        {
            while (true)
            {
                //new connection
                var socket = accept();
                trace("new connection!");
                socket.setBlocking(false);
                socket.setFastSend(true);
                sockets.push(socket);
            }
        });
    }
    public function update()
    {
        while (true)
        {
            for (socket in sockets)
            {
                //existing connections run through
                var lines = new List<String>();
                while (true)
                {
                    try {
                        var line = socket.input.readLine();
                        lines.add(line);
                    }catch(e:Exception)
                    {
                        if (e.message != "Blocked")
                        {
                            trace("error " + e.details());
                            socket.close();
                            sockets.remove(socket);
                        }
                        break;
                    }
                }
                if (lines.length == 0) continue;
                //go through lines
                @:privateAccess var request = new Request(lines);
                @:privateAccess var response = request.response(this,socket);
                @:privateAccess parent.func(request,response);
            }
            Sys.sleep(1/15);
        }
    }
    override function close() 
    {
        //remove sockets array as well
        super.close();
    }
}