import haxe.Http;

class TestPath {
	public static function main() {
		trace("Starting Path Test");
		var app = new weblink.Weblink();

		//simply reimplement the route not found to confirm that doing this doesn't kill everything.
		app.set_pathNotFound(function(request, response){
			response.writeHeader(404);
			response.send("Error 404, Route Not found.");
		});


		var data = haxe.io.Bytes.ofString(Std.string(Std.random(10 * 1000))).toHex();
		app.get("/path", function(request, response) {
			response.send(data);
		});
		app.post("/path", function(request, response) {
			response.send(data + request.data());
		});
		app.put("/path", function(request, response) {
			response.send(data + request.data());
		});
		app.get("/another", function(request, response) {
			response.send(data);
		});
		app.listen(2000, false);

		sys.thread.Thread.createWithEventLoop(() -> {
			var response = Http.requestUrl("http://localhost:2000/path");
			if (response != data)
				throw "/path: post response data does not match0: " + response + " data: " + data;
			var http = new Http("http://localhost:2000/path");
			http.setPostData(data);
			http.request(false);
			if (http.responseData != data + data)
				throw "/path: post response data does not match1: " + http.responseData + " data: " + data + data;
			var response = Http.requestUrl("http://localhost:2000/another");
			if (response != data)
				throw "/another: post response data does not match: " + response + " data: " + data;

			try {
				var nopath = Http.requestUrl("http://localhost:2000/notapath");
			} catch (e) {
				if(e.message != "Http Error #404"){
					throw "/notapath should return a Status 404.";
				}
			}
			app.close();
		});
		app.server.update();
		trace("done");
	}
}
