package tests.security;

import haxe.Http;
import weblink.security.Jwks;

using StringTools;

class TestJwks {
	private static var jsonWebKey = '{
		"e": "AQAB",
		"n": "iwlNcEM5m5Dy7bm_X1ZTJthzD_KIWpJ3gD79U-lt6fhO3Dyt9lqo447RyseEc1ZCUBDlpr7jTqlb3ZAeQb-sVw",
		"kid": "47ce2098-311c-436d-ad1d-7379db3ac2d5",
		"kty": "RSA"
	}';

	public static function main() {
		trace("Starting Jwks Test");
		var app = new weblink.Weblink();
		var jwks = new Jwks();
		app.jwks(jwks);
		app.listen(2000, false);

		sys.thread.Thread.create(() -> {
			var response = Http.requestUrl("http://localhost:2000/jwks");
			var testValue = '{"keys":[]}';
			if (response != testValue)
				throw "/jwks: response data does not match: " + response + " data: " + testValue;

			var http = new Http("http://localhost:2000/jwks");
			http.setPostData(jsonWebKey);
			http.request(false);

			var responseAfterPost = Http.requestUrl("http://localhost:2000/jwks");
			var testValueGet = '{"keys":[' + removeSpaces(jsonWebKey) + ']}';
			if (responseAfterPost != testValueGet)
				throw "/jwks: response data does not match: " + responseAfterPost + " data: " + testValueGet;

			app.close();
		});

		while (app.server.running) {
			app.server.update(false);
			Sys.sleep(0.2);
		}
		trace("done");
	}

	private static function removeSpaces(str:String):String {
		var buf = new List<String>();
		var charPos = 0;
		while (charPos < str.length) {
			if (!str.isSpace(charPos))
				buf.add(str.charAt(charPos));
			charPos++;
		}
		return buf.join("");
	}
}
