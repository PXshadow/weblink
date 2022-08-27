package weblink.security;

import haxe.Json;

typedef JWT_TO_COMPLETE = {
	sub:String
};

typedef JWT_TOKEN = {
	exp:Float,
	sub:String
};

/*
	Json Web Token
	See: https://www.rfc-editor.org/rfc/rfc7519
 */
class Jwt {
	private static var SECONDS_IN_MINUTE = 60;

	private static function encode(to_encode:JWT_TOKEN, secret_key:String, algorithm:String):String {
		var header = {"typ": "JWT", "alg": Sign.HASH_METHOD};
		var b64_json_header = Base64Url.encodeString(Json.stringify(header));
		var b64_json_payload = Base64Url.encodeString(Json.stringify(to_encode));
		var header_and_payload = b64_json_header + "." + b64_json_payload;
		var signature = Sign.sign(header_and_payload, secret_key, algorithm);
		return header_and_payload + "." + signature;
	}

	public static function decode(token:String, secret_key:String, algorithm:String):JWT_TOKEN {
		var jwt_segments = token.split(".");
		if (jwt_segments.length != 3)
			throw "Malformed JWT: bad number of segments";
		var header_data = jwt_segments[0];
		var header = Json.parse(Base64Url.decode(header_data).toString());
		if (!Reflect.hasField(header, "typ") || !Reflect.hasField(header, "alg"))
			throw "Makformed JWT: bad header";
		var payload_data = jwt_segments[1];
		var signing_input = header_data + "." + payload_data;
		var signature = jwt_segments[2];
		if (!Sign.verify(signing_input, signature, secret_key, algorithm))
			throw "Malformed JWT: bad signature";
		var jwt_token:JWT_TOKEN = Json.parse(Base64Url.decode(payload_data).toString());
		return jwt_token;
	};

	public static function create_access_token(to_complete:JWT_TO_COMPLETE, secret_key:String, algorithm:String, ?expires_delta:Int = 15):String {
		var nowUtcTimestamp = Math.ffloor(Date.now().getTime() / 1000);
		var expire = nowUtcTimestamp + expires_delta * SECONDS_IN_MINUTE;
		var to_encode:JWT_TOKEN = {
			sub: to_complete.sub,
			exp: expire
		};
		return encode(to_encode, secret_key, algorithm);
	}
}
