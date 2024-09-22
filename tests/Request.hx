import haxe.Http;

using TestingTools;

class Request {
	public static function main() {
		Sys.println("start test");
		var app = new weblink.Weblink();
		var data = haxe.io.Bytes.ofString(Std.string(Std.random(10 * 1000))).toHex();
		app.get("/", function(request, response) {
			response.send(data);
		});
		app.post("/", function(request, response) {
			response.send(data + request.data);
		});
		app.put("/", function(request, response) {
			response.send(data + request.data);
		});
		app.listenBackground(2000);

		var response = Http.requestUrl("http://localhost:2000"); // FIXME: Does not compile on Node.js
		if (response != data)
			throw "post response data does not match: " + response + " data: " + data;
		var http = new Http("http://localhost:2000");
		http.setPostData(data);
		http.request(false); // FIXME: On Node.js this does not block
		if (http.responseData != data + data)
			throw "post response data does not match: " + http.responseData + " data: " + data + data;
		app.close();

		trace("done");
	}
}
