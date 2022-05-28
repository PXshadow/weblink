import haxe.Http;
import weblink.Cookie;
import weblink.Weblink;

class TestCookie {
	public static function main() {
		Sys.println("Starting cookie Response Test");
		var app:Weblink;
		var data:String;

		data = haxe.io.Bytes.ofString(Std.string(Std.random(10 * 1000))).toHex();
		app = new Weblink();

		app.get("/", function(request, response) {
			response.cookies.add(new Cookie("foo", "bar"));
			response.send(data);
		});
		app.listen(2000, false);

		sys.thread.Thread.create(() -> {
			var http = new Http("http://localhost:2000");
			http.onStatus = function(status) {
				if (status == 200) {
					var headers = http.responseHeaders;
					if (headers.get("Set-Cookie") != "foo=bar") {
						throw 'Set-Cookie not foo=bar. got ${headers.get("Set-Cookie")}';
					}
				}
			};
			http.request(false);

			app.close();
		});

		while (app.server.running) {
			app.server.update(false);
			Sys.sleep(0.2);
		}
		trace("done");
	}
}
