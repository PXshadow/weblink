package weblink._internal.ds;

import haxe.exceptions.ArgumentException;

final class RadixTreeUtils {
	/**
		Returns the smaller of two integers.
	**/
	public static inline function minInt(a:Int, b:Int):Int {
		if (a < b)
			return a;
		return b;
	}

	/**
		Given two strings `a` and `b`, returns how many consecutive characters,
		counting from the string start, do they have in common.

		For example, for strings "hello" and "help" this function should return 3. ("hel".length)
	**/
	public static function commonPrefixLength(a:String, b:String):Int {
		final max = minInt(a.length, b.length);
		for (i in 0...max) {
			if (a.charAt(i) != b.charAt(i)) {
				return i;
			}
		}
		return max;
	}

	public static inline function isCharNonLiteralStart(ch:String):Bool {
		return ch == ":";
	}

	public static inline function isNonLiteralStart(ch:String):Bool {
		return isCharNonLiteralStart(ch.charAt(0));
	}

	public static inline function isCharNonLiteralEnd(ch:String):Bool {
		return ch == "/";
	}

	/**
		Cuts the string into two parts on the first character
		that would become a non-literal node edge.

		For example, string "/a/b/:c/d" should return ("/a/b/", ":c/d").

		If the string begins with such character, returns ("", s).

		If no such character exists, returns (s, "").
	**/
	public static function takeUntilNonLiteral(s:String, start:Int = 0):Pair<String, String> {
		var pos:Int = s.length;
		for (i in start...s.length) {
			if (isCharNonLiteralStart(s.charAt(i))) {
				pos = i;
				break;
			}
		}

		return {left: s.substring(start, pos), right: s.substring(pos)};
	}

	/**
		Cuts the string into two parts on the first character
		that would become a literal node edge.

		For example, string ":foo/bar" should return (":foo", "/bar").

		If the string begins with such character, returns ("", s).

		If no such character exists, returns (s, "").
	**/
	public static function takeUntilLiteral(s:String, start:Int = 0):Pair<String, String> {
		var pos:Int = s.length;
		for (i in start...s.length) {
			if (isCharNonLiteralEnd(s.charAt(i))) {
				pos = i;
				break;
			}
		}

		return {left: s.substring(start, pos), right: s.substring(pos)};
	}

	public static function parseEdgeUntilTypeChange(s:String):Pair<RadixTree.Edge, String> {
		if (s.length == 0)
			throw new ArgumentException("s", "s must not be empty");
		return switch (s.charAt(0)) {
			case ":":
				final pair = takeUntilLiteral(s, 1);
				{left: NamedParam(pair.left), right: pair.right};
			case _:
				final pair = takeUntilNonLiteral(s);
				{left: Literal(pair.left), right: pair.right};
		};
	}
}

@:structInit
final class Pair<L, R> {
	public var left:L;
	public var right:R;
}
