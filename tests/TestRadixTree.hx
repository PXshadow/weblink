import weblink._internal.ds.RadixTree;

function assertTrue<T>(value:Bool) {
	if (!value) {
		throw "assert failed: value was false";
	}
}

function assertEquals<T>(expected:Null<T>, actual:Null<T>) {
	if (expected != actual) {
		throw 'assert failed: expected "${expected}", actual "${actual}"';
	}
}

function assertNull<T>(value:Null<T>) {
	if (value != null) {
		throw "assert failed: value is not null";
	}
}

class TestRadixTree {
	@:privateAccess
	public static function main() {
		trace("Starting Radix Tree Test");

		final tree = new RadixTree<String>();
		tree.put("/", Get, "got index");
		tree.put("/food/fruit/apple", Get, "got apple");
		tree.put("/food/fruit/banana", Get, "got banana");
		tree.put("/food/fruit/banana", Post, "posted banana");
		tree.put("/food/:foodCategory/che", Get, "got che");
		tree.put("/blog/article/:slug", Get, "got article");

		assertTrue(tree.tryGet("/", Get).match(Found("got index", _)));

		assertTrue(tree.tryGet("/food/fruit/banana", Get).match(Found("got banana", _)));
		assertTrue(tree.tryGet("/food/fruit/banana", Post).match(Found("posted banana", _)));
		assertTrue(tree.tryGet("/food/fruit/banana", Patch).match(MissingMethod));
		assertTrue(tree.tryGet("/food/fruit/orange", Get).match(MissingRoute));

		assertTrue(tree.tryGet("/food/soup/che", Get).match(Found("got che", _)));
		assertTrue(tree.tryGet("/food/dessert/che", Get).match(Found("got che", _)));
		switch tree.tryGet("/food/fruit/che", Get) {
			case Found("got che", params):
				assertEquals("fruit", params.get("foodCategory"));
				assertNull(params.get("foobar"));
			case _:
				throw "bad lookup result";
		}

		assertTrue(tree.tryGet("/blog/article/my-manifesto", Delete).match(MissingMethod));
		switch tree.tryGet("/blog/article/my-manifesto", Get) {
			case Found("got article", params):
				assertEquals("my-manifesto", params.get("slug"));
				assertNull(params.get("foodCategory"));
			case _:
				throw "bad lookup result";
		}
		assertTrue(tree.tryGet("/blog/article/my-manifesto/comments", Get).match(MissingRoute));

		trace("done");
	}
}
