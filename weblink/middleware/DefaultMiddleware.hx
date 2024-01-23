package weblink.middleware;

import haxe.zip.Compress;

final class DefaultMiddleware {
	public static function compressDeflate(next:Func):Func {
		return (request:Request, response:Response) -> {
			if (response.headers == null) {
				response.headers = new List<Header>();
			}
			response.headers.add({key: 'Content-Encoding', value: 'deflate'});
			response.write = bytes -> Compress.run(bytes, 9);
			next(request, response);
		};
	}
}
