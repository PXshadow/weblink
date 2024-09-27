package weblink._internal;

using Lambda;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
#else
@:build(weblink._internal.CharTools.populate())
#end
final class CharTools {
	/**
		Returns true if the given character fits in the US-ASCII charset.
	**/
	@:pure
	public static inline function isAscii(char:Int):Bool {
		return char >= 0 && char <= 127;
	}

	/**
		Returns true if the given character fits in the ISO-8859-1 charset.
	**/
	@:pure
	public static inline function isLatin1(char:Int):Bool {
		return char >= 0 && char <= 255;
	}

	/**
		Returns true if the given character is a control character.
	**/
	@:pure
	public static inline function isControl(char:Int):Bool {
		return (char >= 0 && char < 32) || (char >= 127 && char <= 159);
	}

	/**
		Returns true if the given character is a capital letter.
	**/
	@:pure
	public static inline function isUpperCase(char:Int):Bool {
		return (char >= 65 && char <= 90) || (char >= 192 && char <= 222 && char != 215);
	}

	/**
		Converts an ASCII character to lowercase, if possible.
	**/
	@:pure
	public static inline function toLowerCase(char:Int):Int {
		final offset = isUpperCase(char) ? 32 : 0;
		return char + offset;
	}

	#if macro
	/**
		Creates an array of the given length, prepopulated with the given value.
	**/
	@:pure
	private static function makeArray<T>(len:Int, value:T):Array<T> {
		final arr = new Array<T>();
		arr.resize(len);
		for (i in 0...len) {
			arr[i] = value;
		}
		return arr;
	}

	public static function populate():Array<Field> {
		final pos = Context.currentPos();
		final fields = Context.getBuildFields();

		final digits = makeArray(128, false);
		for (i in "0".code...("9".code + 1)) {
			digits[i] = true;
		}

		final letters = makeArray(128, false);
		for (i in "A".code...("Z".code + 1)) {
			letters[i] = true;
		}
		for (i in "a".code...("z".code + 1)) {
			letters[i] = true;
		}

		final allowed = makeArray(128, false);
		allowed["!".code] = true;
		allowed["#".code] = true;
		allowed["$".code] = true;
		allowed["%".code] = true;
		allowed["&".code] = true;
		allowed["'".code] = true;
		allowed["*".code] = true;
		allowed["+".code] = true;
		allowed["-".code] = true;
		allowed[".".code] = true;
		allowed["^".code] = true;
		allowed["_".code] = true;
		allowed["`".code] = true;
		allowed["|".code] = true;
		allowed["~".code] = true;
		for (i in 0...128) {
			if (digits[i] || letters[i]) {
				allowed[i] = true;
			}
		}

		fields.push({
			pos: pos,
			name: "CHARS_ALLOWED_IN_TOKENS",
			doc: "Lookup table for US_ASCII chars allowed in tokens (according to RFC 7230)",
			access: [APrivate, AStatic, AFinal],
			kind: FVar((macro :Array<Bool>), {
				final exprs = [for (v in allowed) macro $v{v}];
				macro $a{exprs};
			}),
		});

		return fields;
	}
	#else

	/**
		Returns true if the given ASCII character is allowed in HTTP header names.
	**/
	@:pure
	public static inline function isAllowedInHeaderName(char:Int):Bool {
		return CharTools.CHARS_ALLOWED_IN_TOKENS[char];
	}
	#end
}
