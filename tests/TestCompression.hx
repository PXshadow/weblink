import haxe.Http;
import haxe.io.Bytes;
import haxe.zip.Compress;
import weblink.Compression;
import weblink.Weblink;

using TestingTools;

class TestCompression {
	public static function main() {
		trace("Starting Content-Encoding Test");
		var app = new weblink.Weblink();
		var data = "test";
		var bytes = haxe.io.Bytes.ofString(data);
		var compressedData = Compress.run(bytes, 9);
		app.get("/", function(request, response) {
			response.sendBytes(bytes);
		}, Compression.deflateCompressionMiddleware);
		app.listenBackground(2000);

		var done = false;
		var http = new Http("http://localhost:2000");
		http.onBytes = function(response) {
			if (response.compare(compressedData) != 0)
				throw "get response compressed data does not match: " + response + " compressedData: " + compressedData;
			done = true;
		}
		http.onError = e -> throw e;
		http.request(false);
		#if nodejs
		sys.NodeSync.wait(() -> done);
		#end

		app.close();
		trace("done");
	}
}
