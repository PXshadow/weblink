package weblink.http;

/**
	A field key of an HTTP header.
	Currently no validation is performed on the key.
**/
@:notNull
enum abstract HeaderName(String) to String {
	@:from
	public static function normalize(s:String):HeaderName {
		// TODO check if charset is valid (typically US-ASCII, rarely ISO-8859-1)
		// TODO check if name contains control, separator or other disallowed characters
		return cast s.toLowerCase();
	}
}
