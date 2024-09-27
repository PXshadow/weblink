import weblink.http.HeaderMap;
import weblink.http.HeaderName;

class TestHeaders {
	public static function main() {
		trace("Starting Headers Test");

		switch (HeaderName.tryNormalizeString("Foo")) {
			case Valid(_):
			case _:
				throw "Foo should be a valid header name";
		}

		switch (HeaderName.tryNormalizeString("hello world")) {
			case ForbiddenChar(_):
			case _:
				throw "'hello world' should not be a valid header name";
		}

		switch (HeaderName.tryNormalizeString("Øßą")) {
			case NotAscii(_):
			case _:
				throw "'Øßą' should not be a valid header name";
		}

		final map = new HeaderMap();
		if (Lambda.count(map) != 0)
			throw "fresh map should be empty";

		map.add("foo", "bar");
		if (Lambda.count(map) != 1)
			throw "map should have one entry";
		if (map.get("foo") != "bar")
			throw "map should have foo=bar";
		if (map.get("FOO") != "bar")
			throw "map treats keys case-sensitively";

		map.add("Foo", "baz");
		if (Lambda.count(map) != 1)
			throw "map should have one entry";
		if (map.getAll("fOo").length != 2)
			throw "map should have two values for foo";

		map.set("foo", "qux");
		if (map.getAll("fOo").length != 1)
			throw "the result of map#set should be a single value";

		map.set("stupid", "example");
		if (Lambda.count(map) != 2)
			throw "map should have two entries";

		map.clear();
		if (Lambda.count(map) != 0)
			throw "cleared map should be empty";

		trace("done");
	}
}
