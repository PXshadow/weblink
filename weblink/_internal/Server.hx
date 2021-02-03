package weblink._internal;
import hl.uv.Loop.LoopRunMode;
import haxe.MainLoop;
import haxe.io.Bytes;
import haxe.http.HttpMethod;
import sys.net.Host;
import weblink._internal.Socket;

class Server extends SocketServer
{
    //var sockets:Array<Socket>;
    var parent:Weblink;
    var running:Bool = true;
    var loop:hl.uv.Loop;
    public function new(port:Int,parent:Weblink)
    {
        //sockets = [];
        loop = hl.uv.Loop.getDefault();
        super(loop);
        bind(new Host("0.0.0.0"),port);
        noDelay(true);
        listen(100,function()
        {
            var stream = accept();
            var socket:Socket = cast stream;
            var request:Request = null;
            var done:Bool = false;
            stream.readStart(function(data:Bytes) @:privateAccess {
                if (done || data == null) {
                    //sockets.remove(socket);
                    stream.close();
                    return;
                }

				if (request == null) {
					var lines = data.toString().split("\r\n");
					request = new Request(lines);

					if (request.pos >= request.length) {
						done = true;
						complete(request,socket);
						return;
					}
				} else if (!done) {
					var length = request.length - request.pos < data.length ? request.length - request.pos : data.length;
					request.data.blit(request.pos,data,0,length);
					request.pos += length;

					if (request.pos >= request.length) {
						done = true;
						complete(request,socket);
						return;
					}
				}

				if (request.chunked) {
					request.chunk(data.toString());
					if (request.chunkSize == 0) {
						done = true;
						complete(request,socket);
						return;
					}
				}

				if (request.method != Post) {
					done = true;
					complete(request,socket);
				}
            });
            //sockets.push(socket);
        });
        this.parent = parent;
    }
    private inline function complete(request:Request,socket:Socket)
    {
        @:privateAccess var response = request.response(this,socket);
        switch (request.method)
        {
            case Get: @:privateAccess parent._getEvent(request,response);
            case Post: @:privateAccess parent._postEvent(request,response);
            case Head: @:privateAccess parent._headEvent(request,response);
            default: trace('Request method: ${request.method} Not supported yet');
        }
    }
    public function update(blocking:Bool=true)
    {
        do {
            @:privateAccess MainLoop.tick(); //for timers
            loop.run(NoWait);
        } while (running && blocking);
    }
    public inline function closeSocket(socket:Socket)
    {
        //sockets.remove(socket);
        socket.close();
    }
    override function close(#if (hl && !nolibuv) ?callb:() -> Void #end)
    {
        //remove sockets array as well
        /*for (socket in sockets)
        {
            socket.close();
        }*/
        //sockets = [];
        running = false;
        #if (hl && !nolibuv)
        loop.stop();
        #end
        super.close();
    }
}
