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

		sys.thread.Thread.createWithEventLoop(() -> {
			var response = Http.requestUrl("http://localhost:2000/users");
			var testValue = '{"users":[{"username":"johndoe","email":"johndoe@example.com","full_name":"John Doe","disabled":false}]}';
			if (response != testValue)
				throw("/users: response data does not match: " + response + " data: " + testValue);

			app.close();
		});

		app.server.update();
		trace("done");
	}
}
