import sys.io.File;
import haxe.io.Bytes;
class Chunk
{
    public static function main()
    {
        @:privateAccess var request = new weblink.Request([]);
        trace("create chunk");
        @:privateAccess request.chunkSize = null;
        @:privateAccess request.pos = 0;
        @:privateAccess request.data = Bytes.alloc(0);
        @:privateAccess request.length = 0;
        @:privateAccess request.chunk(
            "4\r\n" +
            "Wiki\r\n" + 
            "5\r\n" + 
            "pedia\r\n" +
            "E\r\n" +
            " in\r\n" + 
            "\r\n" + 
            "chunks.\r\n" + 
            "0\r\n" + 
            "\r\n"
        );
    }
    static var chunkSize:Null<Int> = null;
    static var pos = 0;
    static var length = 0;
    static var data = Bytes.alloc(0);
    static function chunk(string:String)
    {
        var index = 0;
        var buffer = new StringBuf();
        pos = 0;
        while (chunkSize != 0)
        {
            if (chunkSize > 0)
            {
                var s = string.substr(pos,chunkSize);
                buffer.add(s);
                pos += s.length;
                if (s.length < chunkSize)
                    break; //append later
                pos += 2;
            }
            index = string.indexOf("\r\n",pos);
            var num = string.substring(pos,index);
            //trace("num " + num);
            pos = index + 2;
            chunkSize = Std.parseInt(num);
            if (chunkSize == null)
                chunkSize = Std.parseInt('0x$num');
            if (chunkSize == null)
                chunkSize = 0;
        }
        var bytes = Bytes.ofString(buffer.toString());
        length = data.length + bytes.length;
        var tmp =  Bytes.alloc(length);
        tmp.blit(0,data,0,data.length);
        tmp.blit(data.length,bytes,0,bytes.length);
        data = tmp;
    }
}