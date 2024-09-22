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

		var response = "http://localhost:2000/path".GET();
		if (response != data)
			throw "/path: post response data does not match: " + response + " data: " + data;

		var response = "http://localhost:2000/path".POST(data);
		if (response != data + data)
			throw "/path: post response data does not match: " + response + " data: " + data + data;

		var response = "http://localhost:2000/another".GET();
		if (response != data)
			throw "/another: post response data does not match: " + response + " data: " + data;

		try {
			final _ = "http://localhost:2000/notapath".GET();
		} catch (e) {
			if (!StringTools.contains(e.toString(), "404")) {
				throw "/notapath should return a Status 404.";
			}
		}
		app.close();

		trace("done");
	}
}
