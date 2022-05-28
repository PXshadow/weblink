import haxe.Http;

class TestPath {
	public static function main() {
		trace("Starting Path Test");
		var app = new weblink.Weblink();
		var data = haxe.io.Bytes.ofString(Std.string(Std.random(10 * 1000))).toHex();
		app.get("/path", function(request, response) {
			response.send(data);
		});
		app.post("/path", function(request, response) {
			response.send(data + request.data);
		});
		app.put("/path", function(request, response) {
			response.send(data + request.data);
		});
		app.get("/another", function(request, response) {
			response.send(data);
		});
		app.listen(2000, false);

		sys.thread.Thread.create(() -> {
			var response = Http.requestUrl("http://localhost:2000/path");
			if (response != data)
				throw "/path: post response data does not match: " + response + " data: " + data;
			var http = new Http("http://localhost:2000/path");
			http.setPostData(data);
			http.request(false);
			if (http.responseData != data + data)
				throw "/path: post response data does not match: " + http.responseData + " data: " + data + data;
			var response = Http.requestUrl("http://localhost:2000/another");
			if (response != data)
				throw "/another: post response data does not match: " + response + " data: " + data;
			app.close();
		});

		while (app.server.running) {
			app.server.update(false);
			Sys.sleep(0.2);
		}
		trace("done");
	}
}
