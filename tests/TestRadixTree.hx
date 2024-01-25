import haxe.EnumTools.EnumValueTools;
import weblink._internal.ds.RadixTree;
import weblink._internal.ds.RadixTreeUtils.commonPrefixLength;

function assertEquals<T>(expected:T, actual:T) {
	if (expected != actual) {
		throw 'assert failed: expected "${expected}", actual "${actual}"';
	}
}

function assertEqualEnum<T:EnumValue>(expected:T, actual:T) {
	if (!EnumValueTools.equals(expected, actual)) {
		throw 'assert failed: expected "${expected}", actual "${actual}"';
	}
}

function assertNotNull<T>(value:Null<T>) {
	if (value == null) {
		throw "assert failed: value is null";
	}
}

class TestRadixTree {
	public static function main() {
		trace("Starting Radix Tree Test");

		{
			assertEquals(3, commonPrefixLength("help", "hello"));
			assertEquals(4, commonPrefixLength("dealer", "deals"));
			assertEquals(3, commonPrefixLength("apple", "app"));
			assertEquals(0, commonPrefixLength("", "banana"));
		}

		{
			final node = new Node(Literal("foobar"), 4);
			assertEqualEnum(Literal("foobar"), node.edge);
			assertEquals(4, node.value);
			assertEquals(true, node.isLeaf());

			node.splitEdge(3);
			assertEqualEnum(Literal("foo"), node.edge);
			assertEquals(null, node.value);
			assertEquals(false, node.isLeaf());

			final child = node.children[0];
			assertEqualEnum(Literal("bar"), child.edge);
			assertEquals(4, child.value);
			assertEquals(true, child.isLeaf());
		}

		{
			final node = new Node(Literal("foobar"), 4);
			node.splitEdge(0);
			assertEqualEnum(Literal(""), node.edge);
			assertEquals(null, node.value);
			assertEquals(false, node.isLeaf());

			final child = node.children[0];
			assertEqualEnum(Literal("foobar"), child.edge);
			assertEquals(4, child.value);
			assertEquals(true, child.isLeaf());
		}

		{
			final tree = new RadixTree<Int>();
			tree.put("apple", 1);
			tree.put("apps", 2);
			tree.put("app", 3);
			tree.put("ban", 4);
			tree.put("banana", 5);

			final root = tree.root;
			assertEqualEnum(Literal(""), root.edge);
			assertEquals(null, root.value);
			assertEquals(2, root.children.length);

			final app = root.children[0];
			assertEqualEnum(Literal("app"), app.edge);
			assertEquals(3, app.value);
			assertEquals(2, app.children.length);
			assertEquals(3, app.children[0].value + app.children[1].value);

			final ban = root.children[1];
			assertEqualEnum(Literal("ban"), ban.edge);
			assertEquals(4, ban.value);
			assertEquals(1, ban.children.length);
			assertEqualEnum(Literal("ana"), ban.children[0].edge);
		}

		{
			final tree = new RadixTree<Int>();
			tree.put("/a", 1);
			tree.put("/a/:foo", 2);
			tree.put("/b/:bar/:baz/quox", 3);
			tree.put("/b/:bar", 4);
			tree.put("/b/:bar/:baz/", 5);
		}

		trace("done");
	}
}
