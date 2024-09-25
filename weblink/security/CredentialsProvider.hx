package weblink.security;

import weblink.security.OAuth.User;
import weblink.security.OAuth.UserInDB;

/*
	Provides in memory user credentials
 */
class CredentialsProvider {
	// Username: johndoe, Password: secret
	public var in_memory_users_db:Map<String, UserInDB> = [];

	public function new() {
		var user = new UserInDB();
		user.username = "johndoe";
		user.full_name = "John Doe";
		user.email = "johndoe@example.com";
		user.hashed_password = "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW";
		user.disabled = false;
		this.in_memory_users_db.set(user.username, user);
	}

	public function getUsersEndpoint(request:Request, response:Response):Void {
		response.headers.add({key: 'Content-Type', value: 'application/json'});
		var data = {
			users: getUserList()
		};
		var jsonString = haxe.Json.stringify(data);
		response.send(jsonString);
	}

	private function getUserList() {
		var userList = [];
		for (user in this.in_memory_users_db) {
			userList.push(Projection.convert(user, User));
		}
		return userList;
	}

	public function postUsersEndpoint(request:Request, response:Response):Void {
		var post_data:String = request.data.toString();
		var data:Map<String, String> = PostData.parse(post_data);
		var username:String = data.get("username");
		var full_name:String = data.get("full_name");
		var email:String = data.get("email");
		var password:String = data.get("password");
		var hashed_password:String = BCryptPassword.get_password_hash(password);
		var disabled:Bool = data.get("disabled") == "true" ? true : false;

		if (username == "")
			throw "POST user: username is empty";
		if (full_name == "")
			throw "POST user: full name is empty";
		if (email.lastIndexOf("@") == -1)
			throw "POST user: email is malformed";
		if (password == "")
			throw "POST user: password is empty";

		var user = new UserInDB();
		user.username = username;
		user.full_name = full_name;
		user.email = email;
		user.hashed_password = hashed_password;
		user.disabled = disabled;

		this.in_memory_users_db.set(username, user);
	}
}
