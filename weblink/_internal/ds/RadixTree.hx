package weblink._internal.ds;

import weblink._internal.ds.RadixTreeUtils.commonPrefixLength;

class RadixTree<V> {
	public var root:Node<V>;

	public function new() {
		this.root = new Node();
	}

	public function put(key:String, value:V) {
		this.root.put(key, value);
	}
}

@:allow(weblink._internal.ds.RadixTree)
class Node<V> {
	public var prefix:String;
	public var value:Null<V>;
	public var children:Null<Array<Node<V>>>;

	public function new(prefix:String = "", ?value:V) {
		this.prefix = prefix;
		this.value = value;
		this.children = null;
	}

	/**
		Creates a new, default/empty node.

		(Subclasses should override this method if they have custom state.)
	**/
	private function create(prefix:String = "", ?value:V):Node<V> {
		return new Node(prefix, value);
	}

	private function addChild(child:Node<V>) {
		if (this.children == null) {
			this.children = [];
		}

		this.children.push(child);
	}

	private function put(prefix:String, value:V) {
		if (this.prefix == "" && this.isLeaf()) {
			this.prefix = prefix;
			this.value = value;
			return;
		}

		final cpl = commonPrefixLength(prefix, this.prefix);
		if (cpl < this.prefix.length) {
			this.splitEdge(cpl);
		}

		if (cpl < prefix.length) {
			final nextPrefix = prefix.substring(cpl);
			final nextChar = nextPrefix.charAt(0);

			// Is there any existing child that we can share the prefix with?
			if (!this.isLeaf()) {
				for (child in this.children) {
					if (nextChar == child.prefix.charAt(0)) {
						// Yes, there is one! Push value recursively
						child.put(nextPrefix, value);
						return;
					}
				}
			}

			// No, there is not. Let's create a new one
			final child = this.create(nextPrefix, value);
			this.addChild(child);
			return;
		}

		this.value = value;
	}

	public function splitEdge(pos:Int):Bool {
		// Ensure pos is in range to prevent substring() failure
		final prefix = this.prefix;
		if (pos >= prefix.length || pos < 0) {
			return false;
		}

		// Move all data about self to a child node,
		final child = this.clone();
		// except the prefix, which is now the right side of the cut
		child.prefix = prefix.substring(pos);

		this.reset();
		this.children = [child];
		this.prefix = prefix.substring(0, pos);

		return true;
	}

	/**
		Returns true if this node has no children.
	**/
	public function isLeaf():Bool {
		final children = this.children;
		return children == null || children.length == 0;
	}

	/**
		Creates a shallow copy of this Node.

		(Subclasses should override this method if they have custom state.)
	**/
	private function clone():Node<V> {
		final other = this.create(this.prefix, this.value);
		other.children = this.children;
		return other;
	}

	/**
		Resets the state of this node.

		(Subclasses should override this method if they have custom state.)
	**/
	private function reset() {
		this.prefix = "";
		this.value = null;
		this.children = null;
	}
}
