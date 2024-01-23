package weblink._internal.ds;

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
	public static function commonPrefixLength(a:String, b:String) {
		final max = minInt(a.length, b.length);
		for (i in 0...max) {
			if (a.charAt(i) != b.charAt(i)) {
				return i;
			}
		}
		return max;
	}
}
