package tests.security;

import haxe.Http;
import weblink.Weblink;
import weblink.security.CredentialsProvider;

class TestCredentialsProvider {
	public static function main() {
		trace("Starting Credentials Provider Test");
		var app = new Weblink();
		var credentialsProvider = new CredentialsProvider();
		app.users(credentialsProvider);
		app.listen(2000, false);

		sys.thread.Thread.create(() -> {
			var response = Http.requestUrl("http://localhost:2000/users");
			var testValue = '{"users":[{"username":"johndoe","email":"johndoe@example.com","full_name":"John Doe","disabled":false}]}';
			if (response != testValue)
				trace("/users: response data does not match: " + response + " data: " + testValue);

			app.close();
		});

		while (app.server.running) {
			app.server.update(false);
			Sys.sleep(0.2);
		}
		trace("done");
	}
}
