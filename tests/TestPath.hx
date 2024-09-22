import haxe.Http;

using TestingTools;

class TestPath {
	public static function main() {
		trace("Starting Path Test");
		var app = new weblink.Weblink();

		// simply reimplement the route not found to confirm that doing this doesn't kill everything.
		app.set_pathNotFound(function(request, response) {
			response.status = 404;
			response.send("Error 404, Route Not found.");
		});

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
		app.listenBackground(2000);

		var response = Http.requestUrl("http://localhost:2000/path"); // FIXME: Does not compile on Node.js
		if (response != data)
			throw "/path: post response data does not match: " + response + " data: " + data;
		var http = new Http("http://localhost:2000/path");
		http.setPostData(data);
		http.request(false); // FIXME: On Node.js this does not block
		if (http.responseData != data + data)
			throw "/path: post response data does not match: " + http.responseData + " data: " + data + data;
		var response = Http.requestUrl("http://localhost:2000/another"); // FIXME: Does not compile on Node.js
		if (response != data)
			throw "/another: post response data does not match: " + response + " data: " + data;

		try {
			var nopath = Http.requestUrl("http://localhost:2000/notapath"); // FIXME: Does not compile on Node.js
		} catch (e) {
			if (e.message != "Http Error #404") {
				throw "/notapath should return a Status 404.";
			}
		}
		app.close();

		trace("done");
	}
}
