// For a middleware that does not cut the request short, see TestCompression.
import haxe.Http;
import haxe.io.Bytes;
import weblink.Weblink;

using TestingTools;

class TestMiddlewareShortCircuit {
	public static function main() {
		trace("Starting Middleware Short Circuit Test");

		final app = new Weblink();
		app.get("/", (_, _) -> throw "should not be called", next -> {
			return (_, res) -> res.send("foo");
		});
		app.listenBackground(2000);

		final http = new Http("http://localhost:2000");
		var response:Null<Bytes> = null;
		http.onBytes = bytes -> response = bytes;
		http.onError = e -> throw e;
		http.request(false); // FIXME: On Node.js this does not block
		if (response.toString() != "foo")
			throw "not the response we expected";
		app.close();

		trace("done");
	}
}
