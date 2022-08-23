package weblink;

import haxe.crypto.Base64;
import haxe.io.Bytes;

using StringTools;

// See: https://www.rfc-editor.org/rfc/rfc4648#section-5
class Base64Url {
	public static function encode(b:Bytes):String {
		var b64:String = Base64.encode(b);
		return b64.replace('+', '-').replace('/', '_').replace('=', '');
	}

	public static function encodeString(to_encode:String):String {
		return encode(Bytes.ofString(to_encode));
	}

	public static function decode(to_decode:String):Bytes {
		var s64 = to_decode.replace('-', '+').replace('_', '/');
		s64 += switch (s64.length % 4) {
			case 0: '';
			case 1: '===';
			case 2: '==';
			case 3: '=';
			case _: throw 'Illegal base64url string!';
		}
		return Base64.decode(s64);
	}
}
