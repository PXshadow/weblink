package tests.security;

import weblink.Weblink;
import weblink.security.CredentialsProvider;

using TestingTools;

class TestCredentialsProvider {
	public static function main() {
		trace("Starting Credentials Provider Test");
		var app = new Weblink();
		var credentialsProvider = new CredentialsProvider();
		app.users(credentialsProvider);
		app.listenBackground(2000);

		var response = "http://localhost:2000/users".GET();
		var testValue = '{"users":[{"username":"johndoe","email":"johndoe@example.com","full_name":"John Doe","disabled":false}]}';
		if (response != testValue)
			trace("/users: response data does not match: " + response + " data: " + testValue);

		app.close();
		trace("done");
	}
}
