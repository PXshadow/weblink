package tests.security;

import haxe.Http;
import haxe.Json;
import weblink.security.CredentialsProvider;
import weblink.security.OAuth;

using TestingTools;

class TestOAuth2 {
	private static var SALT_EXAMPLE = "$2a$05$bvIG6Nmid91Mu9RcmmWZfO";
	// to get a string like this run: openssl rand -hex 32
	private static var SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7";

	private static function serverTest() {
		trace("Starting TestOAuth2 server Test");
		var app = new weblink.Weblink();
		var credentialsProvider = new CredentialsProvider();
		app.oauth2(SECRET_KEY, credentialsProvider);
		app.listenBackground(2000);

		var grant_type = "";
		var username = "johndoe";
		var password = "secret";
		var scope = "";

		final body = 'grant_type=${grant_type}&username=${username}&password=${password}&scope=${scope}';
		final response = "http://localhost:2000/token".POST(body);

		var data:{access_token:String, token_type:String} = Json.parse(response);
		if (data.token_type != "bearer") {
			trace('bad token_type ${data.token_type}');
			throw 'bad token_type ${data.token_type}';
		}
		if (data.access_token.length == 0) {
			throw 'empty access token';
		}
		app.close();

		trace("done");
	}

	private static function directTest() {
		trace("Starting TestOAuth2 direct Test");
		var grant_type = "";
		var username = "johndoe";
		var password = "secret";
		var scope = "";

		var postData = 'grant_type=${grant_type}&username=${username}&password=${password}&scope=${scope}';

		var credentialsProvider = new CredentialsProvider();

		var endpoint = new OAuthEndpoints("/token", SECRET_KEY, credentialsProvider);
		@:privateAccess var token = endpoint.user_data_for_access_token(postData);

		if (token.split(".").length != 3) {
			throw "malformed access token: " + token;
		}

		trace("done");
	}

	private static function directBadUserTest() {
		trace("Starting TestOAuth2 direct bad user Test");
		var grant_type = "";
		var username = "eve";
		var password = "attack";
		var scope = "";

		var postData = 'grant_type=${grant_type}&username=${username}&password=${password}&scope=${scope}';

		var credentialsProvider = new CredentialsProvider();

		var endpoint = new OAuthEndpoints("/token", SECRET_KEY, credentialsProvider);
		try {
			@:privateAccess var token = endpoint.user_data_for_access_token(postData);
		} catch (e) {
			trace("done");
			return;
		}

		trace("Should have throw");
		trace("done");
	}

	public static function main() {
		directTest();
		directBadUserTest();
		serverTest();
	}
}
