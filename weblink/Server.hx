package weblink;

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
    }
    public function update()
    {
        while (true)
        {
            for (socket in sockets)
            {
                //existing connections run through
                var lines:Array<String> = [];
                try {
                    lines.push(socket.input.readLine());
                }catch(e:Exception)
                {
                    if (e.message != "Blocked")
                    {
                        trace("error " + e.details());
                    }
                    continue;
                }
                if (lines.length == 0) continue;
                //go through lines
                parent.get(new Request(lines),new Response(socket));
            }
            //new connection
            var socket = accept();
            trace("new connection!");
            socket.setBlocking(false);
            socket.setFastSend(true);
            sockets.push(socket);
        }
    }
    override function close() 
    {
        //remove sockets array as well
        super.close();
    }
}