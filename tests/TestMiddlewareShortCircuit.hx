// For a middleware that does not cut the request short, see TestCompression.
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

		final response = "http://localhost:2000".GET();
		if (response != "foo")
			throw "not the response we expected";

		app.close();
		trace("done");
	}
}
