package weblink._internal;

import haxe.io.Bytes;
private typedef Basic = #if hl hl.uv.Stream #else sys.net.Socket #end
abstract Socket(Basic)
{
    inline public function new(i:Basic)
    {
        this = i;
    }
    public function writeString(string:String)
    {
        #if hl
        this.write(Bytes.ofString(string));
        #else
        this.output.writeString(string);
        #end
    }
    #if !hl
    public inline function set()
    {
        this.setBlocking(false);
        this.setFastSend(true);
    }
    public inline function readLine():String
    {
        return this.input.readLine();
    }
    #end
    public function close()
    {
        this.close();
    }
}