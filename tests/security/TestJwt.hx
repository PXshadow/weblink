package security;

import weblink.security.Jwt;

class TestJwt {
	private static function badAlgorithm() {
		trace("Starting TestJwt bad Algorithm Test");
		var username = "alice";
		var secret = "secret";
		var access_token_expire_minutes = 30;
		try {
			Jwt.create_access_token({sub: username}, secret, "bad algorithm", access_token_expire_minutes);
		} catch (e) {
			trace("done");
			return;
		}
		trace("Error: Jwt create should throw on bad algorithm");
	}

	private static function jwtDecodeBadSecret() {
		trace("Starting TestJwt jwt Decode Bad Secret Test");
		var username = "alice";
		var secret = "secret";
		var algorithm = "HS256";
		var access_token_expire_minutes = 30;
		var access_token = Jwt.create_access_token({sub: username}, secret, algorithm, access_token_expire_minutes);
		try {
			Jwt.decode(access_token, "bad secret", algorithm);
		} catch (e) {
			trace("done");
			return;
		}
		trace("Error: Jwt decode should throw on bad secret");
	}

	private static function jwtDecodeBadAlgorithm() {
		trace("Starting TestJwt jwt Decode Bad Algorithm Test");
		var username = "alice";
		var secret = "secret";
		var algorithm = "HS256";
		var access_token_expire_minutes = 30;
		var access_token = Jwt.create_access_token({sub: username}, secret, algorithm, access_token_expire_minutes);
		try {
			Jwt.decode(access_token, secret, "bad algorithm");
		} catch (e) {
			trace("done");
			return;
		}
		trace("Error: Jwt decode should throw on bad algorithm");
	}

	public static function ok() {
		trace("Starting TestJwt ok Test");
		var username = "alice";
		var secret = "secret";
		var algorithm = "HS256";
		var access_token_expire_minutes = 30;
		var access_token = Jwt.create_access_token({sub: username}, secret, algorithm, access_token_expire_minutes);
		if (access_token.split(".").length != 3) {
			trace('malformed access token: $access_token');
		}
		var token = Jwt.decode(access_token, secret, algorithm);
		if (token.sub != username)
			trace("Error: bad token sub");
		// arbitrary date: 2022-08-20T10:22:04+00:00 (UTC)
		if (token.exp <= 1660986830)
			trace("Error: bad token exp");

		trace("done");
	}

	public static function main() {
		badAlgorithm();
		jwtDecodeBadSecret();
		jwtDecodeBadAlgorithm();
		ok();
	}
}
