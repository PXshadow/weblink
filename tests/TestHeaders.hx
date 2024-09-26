import weblink.http.HeaderMap;

class TestHeaders {
	public static function main() {
		trace("Starting Headers Test");

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
