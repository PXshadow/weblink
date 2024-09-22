import haxe.Http;
import haxe.io.Bytes;
import weblink.Weblink;

using TestingTools;

class TestMiddlewareCorrectOrder {
	static var v1:String = "";
	static var v2:String = "";
	static var v3:String = "";

	public static function main() {
		trace("Starting Middleware Correct Order Test");

		final app = new Weblink();

		app.use((_, _) -> {
			v1 = "foo";
			v2 = "foo";
			v3 = "foo";
		});

		app.use((_, _) -> {
			v1 = "bar";
			v2 = "bar";
		});

		app.use((_, _) -> {
			v1 = "baz";
		});

		app.get("/", (_, res) -> res.send('$v1$v2$v3'));
		app.listenBackground(2000);

		final http = new Http("http://localhost:2000");
		var response:Null<Bytes> = null;
		http.onBytes = bytes -> response = bytes;
		http.onError = e -> throw e;
		http.request(false); // FIXME: On Node.js this does not block
		if (response.toString() != "bazbarfoo")
			throw "not the response we expected";
		app.close();

		trace("done");
	}
}
