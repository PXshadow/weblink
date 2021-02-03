package weblink._internal;

class SocketServer extends #if (hl && !nolibuv) hl.uv.Tcp #else sys.net.Socket #end
{}
