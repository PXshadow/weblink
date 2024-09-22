package security;

import haxe.Http;
import haxe.Json;
import weblink.Request;
import weblink.Response;
import weblink.security.CredentialsProvider;
import weblink.security.OAuth;

using TestingTools;

class EndpointExample {
	var oAuth:OAuth;

	public function new(tokenUrl:String, secret_key:String, credentialsProvider:CredentialsProvider) {
		this.oAuth = new OAuth(tokenUrl, secret_key, credentialsProvider);
	}

	public function read_users_me(request:Request, response:Response) {
		var current_user:User = this.oAuth.get_current_active_user(request);
		response.send(haxe.Json.stringify(current_user));
	}

	public function read_own_items(request:Request, response:Response) {
		var current_user:User = this.oAuth.get_current_active_user(request);
		var data = [{"item_id": "Foo", "owner": current_user.username}];
		response.send(haxe.Json.stringify(data));
	}
}

class TestEndpointExample {
	// to get a string like this run: openssl rand -hex 32
	private static var SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7";

	public static function main() {
		trace("Starting Test Endpoint Example Test");
		var app = new weblink.Weblink();
		var credentialsProvider = new CredentialsProvider();
		app.oauth2(SECRET_KEY, credentialsProvider);
		var oauth2 = new EndpointExample("/token", SECRET_KEY, credentialsProvider);
		app.get("/users/me/", oauth2.read_users_me);
		app.get("/users/me/items/", oauth2.read_own_items);
		app.listenBackground(2000);

		var grant_type = "";
		var username = "johndoe";
		var password = "secret";
		var scope = "";

		var http = new Http("http://localhost:2000/token");
		http.setPostData('grant_type=${grant_type}&username=${username}&password=${password}&scope=${scope}');
		http.request(false); // FIXME: On Node.js this does not block

		var data:{access_token:String, token_type:String} = Json.parse(http.responseData);
		if (data.token_type != "bearer") {
			throw 'bad token_type ${data.token_type}';
		}
		if (data.access_token.length == 0) {
			throw 'empty access token';
		}

		var usersMeRequest = new Http("http://localhost:2000/users/me/");
		usersMeRequest.setHeader("Authorization", 'bearer ${data.access_token}');
		usersMeRequest.request(false); // FIXME: On Node.js this does not block
		var testValueGet = '{"username":"johndoe","email":"johndoe@example.com","full_name":"John Doe","disabled":false}';
		if (usersMeRequest.responseData != testValueGet)
			throw "/users/me/: response data does not match: " + usersMeRequest.responseData + " data: " + testValueGet;

		var usersMeItemsRequest = new Http("http://localhost:2000/users/me/items/");
		usersMeItemsRequest.setHeader("Authorization", 'bearer ${data.access_token}');
		usersMeItemsRequest.request(false); // FIXME: On Node.js this does not block
		var testItemsGet = '[{"item_id":"Foo","owner":"johndoe"}]';
		if (usersMeItemsRequest.responseData != testItemsGet)
			throw "/users/me/: response data does not match: " + usersMeItemsRequest.responseData + " data: " + testItemsGet;

		app.close();

		trace("done");
	}
}
