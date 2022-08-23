package weblink;

import haxe.macro.Expr;

// A macro to generate a list of alphanumerical chars
class Alphanumericals {
	// See: https://code.haxe.org/category/macros/build-arrays.html
	public static macro function getChars() {
		// make expressions with chars
		var exprs:Array<Expr> = [];
		// See: https://en.wikipedia.org/wiki/List_of_Unicode_characters
		for (i in 48...58) {
			exprs.push(macro $v{i});
		}
		for (i in 65...91) {
			exprs.push(macro $v{i});
		}
		for (i in 97...123) {
			exprs.push(macro $v{i});
		}

		return macro $a{exprs};
	}
}
