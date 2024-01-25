package weblink._internal.ds;

import weblink._internal.ds.RadixTreeUtils.*;

using StringTools;

class RadixTree<V> {
	public var root:Node<V>;

	public function new() {
		this.root = new Node();
	}

	public function put(key:String, value:V) {
		this.root.put(key, value);
	}
}

enum Edge {
	Literal(path:String);
	NamedParam(name:String);
}

@:allow(weblink._internal.ds.RadixTree)
class Node<V> {
	public var parent:Null<Node<V>>;
	public var edge:Edge;
	public var value:Null<V>;
	public var children:Null<Array<Node<V>>>;

	public function new(?edge:Edge, ?value:V) {
		this.parent = null;
		if (edge == null) {
			edge = Literal("");
		}
		this.edge = edge;
		this.value = value;
		this.children = null;
	}

	/**
		Creates a new, default/empty node.

		(Subclasses should override this method if they have custom state.)
	**/
	private function create(?edge:Edge, ?value:V):Node<V> {
		return new Node(edge, value);
	}

	private function addChild(child:Node<V>) {
		if (this.children == null) {
			this.children = [];
		}

		child.parent = this;
		this.children.push(child);
		this.children.sort((a, b) -> switch [a.edge, b.edge] {
			case [Literal(pa), Literal(pb)]: pa < pb ? -1 : (pa > pb ? 1 : 0);
			case [Literal(_), NamedParam(_)]: -1;
			case [NamedParam(_), Literal(_)]: 1;
			case _: 0;
		});
	}

	private function describeEdge():String {
		return switch (this.edge) {
			case Literal(l): l;
			case NamedParam(n): ':$n';
		};
	}

	private function getPath():String {
		var path = (this.parent != null) ? parent.getPath() : "";
		path += this.describeEdge();
		return path;
	}

	private function getLiteralPrefixOrThrow():String {
		return switch this.edge {
			case Literal(p): p;
			case _: throw "node is not a Literal";
		};
	}

	private function putHere(value:V) {
		this.value = value;
	}

	private function put(prefix:String, value:V) {
		// Are we done by any chance?
		if (prefix == "") {
			this.putHere(value);
			return;
		}

		switch (this.edge) {
			case Literal(""):
				if (this.isLeaf()) {
					if (this.value != null) {
						throw 'invalid state, node with no path nor children somehow has value "${this.value}"';
					}
					final pair = parseEdgeUntilTypeChange(prefix);
					this.edge = pair.left;
					this.put(pair.right, value);
				} else {
					this.putIntoChildren(prefix, value);
				}
			case Literal(nodePath):
				if (isNonLiteralStart(prefix)) {
					// If the next path segment will not be a literal,
					// checking common prefix will have no use
					this.putIntoChildren(prefix, value);
					return;
				}

				final divergePos = commonPrefixLength(nodePath, prefix);
				if (divergePos < nodePath.length) {
					this.splitEdge(divergePos);
				}

				if (divergePos == prefix.length) {
					this.putHere(value);
				} else {
					this.putIntoChildren(prefix.substring(divergePos), value);
				}
			case NamedParam(paramName):
				final pair = parseEdgeUntilTypeChange(prefix);
				switch (pair.left) {
					case NamedParam(newName):
						if (newName != paramName) {
							throw 'param named "$newName" conflicts with param "$paramName" on the same route';
						}
						if (pair.right == "") {
							this.putHere(value);
						} else {
							this.putIntoChildren(pair.right, value);
						}
					case _:
						this.putIntoChildren(prefix, value);
				}
		}
	}

	/**
		Tries to find a child that can house our new value.
		If no suitable child exists, creates a new one.
	**/
	private function putIntoChildren(prefix:String, value:V) {
		final pair = parseEdgeUntilTypeChange(prefix);

		// Are there any children that can take our value?
		if (!this.isLeaf()) {
			switch (pair.left) {
				case Literal(path):
					final nextChar = path.charAt(0);
					for (child in this.children) {
						switch (child.edge) {
							case Literal(childPath):
								if (nextChar == childPath.charAt(0)) {
									child.put(prefix, value);
									return;
								}
							case _:
						}
					}
				case NamedParam(_):
					for (child in this.children) {
						if (child.edge.match(NamedParam(_))) {
							child.put(pair.right, value);
							return;
						}
					}
			}
		}

		// No? Well, we tried everything. Just add a new child to the tree
		final child = this.create(pair.left);
		this.addChild(child);
		child.put(pair.right, value);
	}

	public function splitEdge(pos:Int) {
		final prefix = getLiteralPrefixOrThrow();

		// Ensure pos is in range to prevent substring() failure
		if (pos >= prefix.length || pos < 0) {
			return;
		}

		final child = this.clone();
		child.edge = Literal(prefix.substring(pos));
		child.parent = this;
		if (!child.isLeaf()) {
			for (grandchild in child.children) {
				grandchild.parent = child;
			}
		}

		this.reset();
		this.children = [child];
		this.edge = Literal(prefix.substring(0, pos));
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
		final other = this.create(this.edge, this.value);
		other.children = this.children;
		return other;
	}

	/**
		Resets the state of this node.

		(Subclasses should override this method if they have custom state.)
	**/
	private function reset() {
		this.edge = Literal("");
		this.value = null;
		this.children = null;
	}
}
