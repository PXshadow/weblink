using TestingTools;

class Request {
	public static function main() {
		trace("Starting Request Test");
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

		var responseGet = "http://localhost:2000".GET();
		if (responseGet != data)
			throw "post response data does not match: " + responseGet + " data: " + data;

		var responsePost = "http://localhost:2000".POST(data);
		if (responsePost != data + data)
			throw "post response data does not match: " + responsePost + " data: " + data + data;

		app.close();
		trace("done");
	}
}
