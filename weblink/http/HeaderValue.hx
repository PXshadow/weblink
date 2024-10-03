package weblink.http;

using StringTools;
using weblink._internal.CharTools;

/**
	A field value of an HTTP header.
**/
@:forward
enum abstract HeaderValue(String) to String {
	/**
		Checks if the given string would be a valid header value.
		@param str The string to validate.
		@param strict If false, uses RFC 2616 rules (allows Latin1 and folding).
		If true, uses non-obsolete RFC 7230 rules (allows ASCII only).
	**/
	@:pure
	public static function validateString(str:String, strict:Bool):ValidateResult {
		final len = str.length;

		var i = 0;
		while (i < len) {
			final char = str.fastCodeAt(i);

			// Hashlink uses UCS2 string encoding, which is a superset of ISO-8859-1.
			// Other platforms may use UTF-16 or UTF-8 which complicates the latin1 check
			if #if hl (strict && !char.isAscii()) #else (!char.isAscii()) #end {
				return NotAscii(char);
			}
			#if hl
			else if (!char.isLatin1()) {
				return NotLatin1(char);
			}
			#end

			if (char.isControl() && char != "\t".code) {
				if (!strict && char == "\r".code) {
					i++;
					if (i < len) {
						final nextChar = str.fastCodeAt(i);
						if (nextChar == "\n".code) {
							i++;
							continue;
						} else {
							return ForbiddenChar(char);
						}
					}
				}
				return ForbiddenChar(char);
			}

			i++;
		}

		return Valid(cast str);
	}

	/**
		Strictly validates a string as a header value and throws if it is not.
	**/
	@:from
	public static function validateStringOrThrow(str:String):HeaderValue {
		switch (validateString(str, true)) {
			case Valid(value):
				return value;
			case other:
				throw 'string "$str" cannot be used as a header value: $other';
		}
	}
}

enum ValidateResult {
	Valid(value:HeaderValue);
	NotAscii(codeUnit:Int);
	NotLatin1(codeUnit:Int);
	ForbiddenChar(codeUnit:Int);
}
