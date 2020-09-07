package weblink._internal;

import sys.thread.Mutex;
import haxe.io.Bytes;
import sys.thread.Thread;
import haxe.http.HttpMethod;
import sys.net.Host;
import weblink._internal.Socket;

class Server extends SocketServer
{
    var sockets:Array<Socket>;
    var parent:Weblink;
    #if hl var loop:hl.uv.Loop; #end
    public function new(port:Int,parent:Weblink)
    {
        sockets = [];
        #if hl
        loop = hl.uv.Loop.getDefault();
        super(loop);
        #else
        super();
        #end
        bind(new Host(#if cs "127.0.0.1" #else "0.0.0.0" #end),port);
        #if hl
        listen(100,function()
        {
            var stream = accept();
            var socket:Socket = cast stream;
            stream.readStart(function(data:Bytes)
            {
                if (data == null)
                {
                    sockets.remove(socket);
                    stream.close();
                    return;
                }
                var lines = data.toString().split("\r\n");
                //go through lines
                @:privateAccess var request = new Request(lines);
                @:privateAccess var response = request.response(this,socket);
                @:privateAccess parent.func(request,response);
            });
            sockets.push(socket);
        });
        #else
        listen(100); //queue up 100 connection sockets
        Thread.create(function()
        {
            while (true)
            {
                //new connection
                trace("accept!");
                var socket:Socket = cast accept();
                socket.set();
                sockets.push(socket);
            }
        });
        #end
        this.parent = parent;
    }
    public function update()
    {
        #if !hl
        while (true)
        {
            for (socket in sockets)
            {
                //existing connections run through
                var lines:Array<String> = [];
                while (true)
                {
                    try {
                        var line = socket.readLine();
                        lines.push(line);
                    }catch(e:Dynamic)
                    {
                        if (e != haxe.io.Error.Blocked)
                        {
                            trace("error " + e);
                            socket.close();
                            sockets.remove(socket);
                        }
                        break;
                    }
                }
                if (lines.length > 0)
                {
                    //go through lines
                    @:privateAccess var request = new Request(lines);
                    @:privateAccess var response = request.response(this,socket);
                    @:privateAccess parent.func(request,response);
                }
            }
            Sys.sleep(1/15);
        }
        #else
        while (true)
        {
            loop.run(Default);
        }
        #end
    }
    override function close(#if hl ?callb:() -> Void #end) 
    {
        //remove sockets array as well
        for (socket in sockets)
        {
            socket.close();
        }
        sockets = [];
        super.close();
    }
}