import haxe.Http;

class TestRequest {
	public static function main() {
		Sys.println("start test");
		var app = new weblink.Weblink();
		var data = haxe.io.Bytes.ofString(Std.string(Std.random(10 * 1000))).toHex();
		app.get("/", function(request, response) {
			response.send(data);
		});
		app.post("/", function(request, response) {
			response.send(data + request.data());
		});
		app.put("/", function(request, response) {
			response.send(data + request.data());
		});
		trace("listen");
		app.listen(2000, false);
		trace("after listen");

		sys.thread.Thread.createWithEventLoop(() -> {
			Sys.sleep(1);
			var response = Http.requestUrl("http://localhost:2000");
			if (response != data)
				throw "post response data does not match: " + response + " data: " + data;
			var http = new Http("http://localhost:2000");
			http.setPostData(data);
			http.request(false);
			if (http.responseData != data + data) {
				trace("post response data does not match2: " + http.responseData + " data: " + data + data);
				Sys.exit(1);
			}
			trace("close!");
			Sys.exit(0);
		});
		trace("start update");
		app.server.update();
		trace("done");
	}
}
