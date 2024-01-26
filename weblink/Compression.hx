package weblink;

import haxe.io.Bytes;
import haxe.zip.Compress;

class Compression {
	public static function deflateCompressionMiddleware(request:Request, response:Response):Void {
		if (response.headers == null)
			response.headers = new List<Header>();
		response.headers.add({key: 'Content-Encoding', value: 'deflate'});
		response.write = function(bytes:Bytes):Bytes {
			return Compress.run(bytes, 9);
		}
	}
}
