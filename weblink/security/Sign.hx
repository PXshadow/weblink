package weblink.security;

import haxe.Exception;
import haxe.crypto.Hmac;
import haxe.io.Bytes;

using StringTools;

/*
	HS256 signature
 */
class Sign {
	public static var HASH_METHOD = "HS256";

	public static function sign(message:String, priv_key:String, hash_method:String):String {
		if (hash_method != HASH_METHOD) {
			throw new Exception('$HASH_METHOD is the only supported algorithm for now (input was $hash_method)');
		}
		return sign_hash(message, priv_key, hash_method); // HMAC(key, SHA256(message))
	}

	private static function sign_hash(message:String, priv_key:String, hash_method:String):String {
		// https://www.rfc-editor.org/rfc/rfc2104.html
		var hmac:Hmac = new Hmac(HashMethod.SHA256);
		var sb:Bytes = hmac.make(Bytes.ofString(priv_key), Bytes.ofString(message));
		return Base64Url.encode(sb);
	}

	public static function verify(header_and_payload:String, signature:String, SECRET_KEY:String, ALGORITHM:String) {
		var ok_signature = sign(header_and_payload, SECRET_KEY, ALGORITHM);
		return fast_string_compare(ok_signature, signature);
	}

	// See: https://github.com/HaxeFoundation/hashlink/issues/176
	public static function fast_string_compare(string1:String, string2:String):Bool {
		if (string1.length != string2.length) {
			return false;
		}
		#if hl
		var v = @:privateAccess string1.bytes.compare16(string2.bytes, string1.length);
		return v == 0;
		#else
		return string1 == string2;
		#end
	}
}
