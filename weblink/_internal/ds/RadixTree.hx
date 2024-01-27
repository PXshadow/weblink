package weblink._internal.ds;

import haxe.http.HttpMethod;
import weblink._internal.ds.RadixTreeUtils.*;

using Lambda;
using StringTools;

/**
	A modified version of a radix tree, suitable for HTTP request routing.

	Note: This class is generic to make testing easier.
	Out of testing, the T parameter will always be weblink.Func.
**/
class RadixTree<T> {
	public var root:Node<T>;

	public function new() {
		this.root = new Node(Literal(""));
	}

	public function put(path:String, method:HttpMethod, value:T) {
		this.root.put(path, method, value);
	}

	public function tryGet(path:String, method:HttpMethod):TreeGetResult<T> {
		final params = [];
		final node = this.root.tryMatch(path, params);
		if (node == null) {
			return MissingRoute;
		}

		final handler = node.handlers.get(method);
		if (handler == null) {
			return (node.handlers.count() > 0) ? MissingMethod : MissingRoute;
		}

		return Found(handler, params.fold((pair, map:Map<String, String>) -> {
			map.set(pair.left, pair.right);
			return map;
		}, []));
	}
}

enum TreeGetResult<T> {
	MissingRoute;
	MissingMethod;
	Found(handler:T, params:Map<String, String>);
}

/**
	Edge describes what kind of path segment this node represents.

	A Literal(\_) edge is a static string. Match means the request path 
	literally contained contents of the edge as a substring.

	A NamedParam(\_) edge matches anything up to a slash character.
	Match means no matching Literal(_) edges exist.
	The name of the param, and the substring it matched, are then injected into the request.
**/
enum Edge {
	/** Static part of the path; matches on exact equality. **/
	Literal(path:String);

	/** Named, dynamic part of the path; matches anything. **/
	NamedParam(name:String);
}

/**
	A node in our modified radix tree.

	Warning: A node should only ever be added to a single tree
	as it stores a reference to its parent.

	Note: This class is generic to make testing easier.
	Out of testing, the T parameter will always be weblink.Func.
**/
@:allow(weblink._internal.ds.RadixTree)
final class Node<T> {
	/**
		A reference to the node's parent, if one exists,
		or null, if this node is a root.
	**/
	private var parent:Null<Node<T>>;

	/**
		Describes what kind of path segment this node represents.
		See the type documentation for more.
	**/
	private var edge:Edge;

	/**
		Stores values (handlers) for each HTTP method separately.
	**/
	private var handlers:Map<String, T>;

	/**
		Children of this node; that is other nodes appearing deeper in the router tree.

		If this node does not exhaust the request path,
		it is redirected to its children.
	**/
	private var children:Array<Node<T>>;

	/**
		Creates a new, empty, leaf Node with a specified Edge directing to it.
	**/
	public function new(edge:Edge) {
		this.edge = edge;
		this.parent = null;
		this.handlers = [];
		this.children = [];
	}

	/**
		Registers a provided Node as a child of this Node.
	**/
	private function addChild(child:Node<T>) {
		child.parent = this;
		this.children.push(child);
		this.children.sort((a, b) -> switch [a.edge, b.edge] {
			case [Literal(pa), Literal(pb)]: pa < pb ? -1 : (pa > pb ? 1 : 0);
			case [Literal(_), NamedParam(_)]: -1;
			case [NamedParam(_), Literal(_)]: 1;
			case _: 0;
		});
	}

	/**
		Reconstructs the absolute path this node resides at.
	**/
	public function reconstructPath():String {
		final sb = new StringBuf();
		this.reconstructPathInner(sb);
		return sb.toString();
	}

	private function reconstructPathInner(sb:StringBuf) {
		final parent = this.parent;
		if (parent != null) {
			parent.reconstructPathInner(sb);
		}
		switch (this.edge) {
			case Literal(path):
				sb.add(path);
			case NamedParam(name):
				sb.addChar(":".code);
				sb.add(name);
		}
	}

	private function putHere(httpMethod:String, value:T) {
		final handlers = this.handlers;
		if (handlers.exists(httpMethod)) {
			throw 'path "${this.reconstructPath()}" already has a registered handler for method $httpMethod';
		}
		handlers.set(httpMethod, value);
	}

	private function put(path:String, httpMethod:String, value:T) {
		// Are we done by any chance?
		if (path == "") {
			this.putHere(httpMethod, value);
			return;
		}

		switch (this.edge) {
			case Literal(""):
				if (this.isLeaf()) {
					// Sanity check
					if (this.handlers.count() > 0) {
						throw 'invalid state: node at path "${this.reconstructPath()}" with no children somehow has values';
					}
					final pair = parseEdgeUntilTypeChange(path);
					this.edge = pair.left;
					this.put(pair.right, httpMethod, value);
				} else {
					this.putIntoChildren(path, httpMethod, value);
				}
			case Literal(nodePath):
				if (isNonLiteralStart(path)) {
					// If the next path segment will not be a literal,
					// checking common prefix will have no use
					this.putIntoChildren(path, httpMethod, value);
					return;
				}

				final divergePos = commonPrefixLength(nodePath, path);
				if (divergePos < nodePath.length) {
					this.splitEdge(divergePos);
				}

				if (divergePos == path.length) {
					this.putHere(httpMethod, value);
				} else {
					this.putIntoChildren(path.substring(divergePos), httpMethod, value);
				}
			case NamedParam(paramName):
				final pair = parseEdgeUntilTypeChange(path);
				switch (pair.left) {
					case NamedParam(newName):
						if (newName != paramName) {
							throw 'param named "$newName" conflicts with param "$paramName" on the same route "${this.reconstructPath()}"';
						}
						if (pair.right == "") {
							this.putHere(httpMethod, value);
						} else {
							this.putIntoChildren(pair.right, httpMethod, value);
						}
					case _:
						this.putIntoChildren(path, httpMethod, value);
				}
		}
	}

	/**
		Tries to find a child that can house our new value.
		If no suitable child exists, creates a new one.
	**/
	private function putIntoChildren(path:String, httpMethod:String, value:T) {
		final pair = parseEdgeUntilTypeChange(path);

		// Are there any children that can take our value?
		switch (pair.left) {
			case Literal(pathSegment):
				final nextChar = pathSegment.charAt(0);
				for (child in this.children) {
					switch (child.edge) {
						case Literal(childPath):
							if (nextChar == childPath.charAt(0)) {
								child.put(path, httpMethod, value);
								return;
							}
						case _:
					}
				}
			case NamedParam(_):
				for (child in this.children) {
					if (child.edge.match(NamedParam(_))) {
						child.put(pair.right, httpMethod, value);
						return;
					}
				}
		}

		// No? Well, we tried everything. Just add a new child to the tree
		final child = new Node<T>(pair.left);
		this.addChild(child);
		child.put(pair.right, httpMethod, value);
	}

	public function splitEdge(pos:Int) {
		// Splitting can only be done on Literal nodes
		final segment = switch this.edge {
			case Literal(p): p;
			case _: return;
		};

		// Ensure pos is in range to prevent substring() failure
		if (pos >= segment.length || pos < 0) {
			return;
		}

		final child = new Node(Literal(segment.substring(pos)));
		child.handlers = this.handlers;
		child.parent = this;
		child.children = this.children;
		for (grandchild in child.children) {
			grandchild.parent = child;
		}

		this.handlers = [];
		this.children = [child];
		this.edge = Literal(segment.substring(0, pos));
	}

	/**
		Traverses down the tree, finding a node that would match the provided path.
		If it finds one, returns it, otherwise returns null.
		@param path The request path.
		@param outParams Optional: a collection where the matched named parameters will be stored.
	**/
	public function tryMatch(path:String, ?outParams:Array<RadixTreeUtils.Pair<String, String>>):Null<Node<T>> {
		if (path == "") {
			return this;
		}

		switch (this.edge) {
			case Literal(prefix):
				final divergePos = commonPrefixLength(path, prefix);
				if (divergePos != prefix.length) {
					return null;
				} else if (divergePos == path.length) {
					return this;
				}
				path = path.substring(divergePos);
			case NamedParam(name):
				var endPos = path.indexOf("/");
				if (endPos < 0) {
					if (outParams != null) {
						outParams.push({left: name, right: path});
					}
					return this;
				}
				if (outParams != null) {
					outParams.push({left: name, right: path.substring(0, endPos)});
				}
				path = path.substring(endPos);
		}

		// See #addChild(): children are guaranteed to be sorted in a way
		// where an iteration starts with Literal(_) children
		// and moves to wildcards by the end
		final nextChar = path.charAt(0);
		for (child in this.children) {
			switch (child.edge) {
				case Literal(prefix):
					if (nextChar == prefix.charAt(0)) {
						final len = (outParams != null) ? outParams.length : 0;
						final maybeResult = child.tryMatch(path, outParams);
						if (maybeResult != null) {
							return maybeResult;
						}
						// Welp, we did not find anything!
						// However, the route can still match some wildcard (like named param).
						// To do this, roll back the context to before child.tryMatch was called
						if (outParams != null) {
							outParams.resize(len);
						}
					}
				case NamedParam(_):
					return child.tryMatch(path, outParams);
			}
		}

		return null;
	}

	/**
		Returns true if this node has no children.
	**/
	public inline function isLeaf():Bool {
		return children.length == 0;
	}
}
