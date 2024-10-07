package weblink.security;

import weblink.exceptions.HttpException;
import weblink.security.BCryptPassword;
import weblink.security.Jwt;
import weblink.security.OAuth2PasswordBearer;

class Token {
	var access_token:String;
	var token_type:String;
}

class TokenData {
	public var username:String;

	public function new(username:String) {
		this.username = username;
	}
}

class User {
	public function new() {}

	public var username:String;
	public var email:String;
	public var full_name:String;
	public var disabled:Bool;
}

class UserInDB extends User {
	public var hashed_password:String;
}

class OAuth {
	public static var ALGORITHM = "HS256";

	var schemes = ["bcrypt"];
	var deprecated = "auto";

	public var secret_key:String;
	public var oauth2_scheme:OAuth2PasswordBearer;

	private var credentialsProvider:CredentialsProvider;

	public function new(tokenUrl:String, secret_key:String, credentialsProvider:CredentialsProvider) {
		this.oauth2_scheme = new OAuth2PasswordBearer(tokenUrl);
		this.secret_key = secret_key;
		this.credentialsProvider = credentialsProvider;
	}

	function get_user(db:Map<String, UserInDB>, username:String):UserInDB {
		return db.get(username);
	}

	public function authenticate_user(username:String, password:String):UserInDB {
		var user = get_user(this.credentialsProvider.in_memory_users_db, username);
		if (user == null) {
			return null;
		}
		if (!BCryptPassword.verify_password(password, user.hashed_password)) {
			return null;
		}
		return user;
	}

	private function get_current_user(token:String):UserInDB {
		var credentials_exception = new HttpException(401, 'Could not validate credentials {"WWW-Authenticate": "Bearer"}');
		var token_data;
		try {
			var payload = Jwt.decode(token, this.secret_key, ALGORITHM);
			var username:String = payload.sub;
			if (username == null) {
				throw credentials_exception;
			}
			token_data = new TokenData(username);
		} catch (e) {
			throw credentials_exception;
		}
		var user = get_user(this.credentialsProvider.in_memory_users_db, token_data.username);
		if (user == null) {
			throw credentials_exception;
		}
		return user;
	}

	public function get_current_active_user(request):User {
		var token = this.oauth2_scheme.call(request);
		if (token == null) {
			throw new HttpException(401, 'Bad Token {"WWW-Authenticate": "Bearer"}');
		}
		var current_user:UserInDB = this.get_current_user(token);
		if (current_user.disabled) {
			throw new HttpException(400, "Inactive user");
		}
		// We don't want to return hashed_password for security reasons
		return Projection.convert(current_user, User);
	}
}

class OAuth2PasswordRequestForm {
	public var grant_type:String;
	public var username:String;
	public var password:String;
	public var scopes:Array<String>;
	public var client_id:String;
	public var client_secret:String;

	public function new(grant_type:String, username:String, password:String, ?scope:String, ?client_id:String, ?client_secret:String) {
		this.grant_type = grant_type;
		this.username = username;
		this.password = password;
		if (scope != null) {
			this.scopes = scope.split(",");
		} else {
			this.scopes = [];
		}
		this.client_id = client_id;
		this.client_secret = client_secret;
	}

	public static function validate(post_data:Map<String, String>):OAuth2PasswordRequestForm {
		var grant_type = post_data.get("grant_type");
		var username = post_data.get("username");
		if (username == "")
			throw "OAuth2 Password Request: username is empty";
		var password = post_data.get("password");
		if (password == "")
			throw "OAuth2 Password Request: password is empty";
		var scope = post_data.get("scope");
		return new OAuth2PasswordRequestForm(grant_type, username, password, scope);
	}
}

class OAuthEndpoints {
	var ACCESS_TOKEN_EXPIRE_MINUTES = 30;

	public var oAuth:OAuth;

	public function new(tokenUrl:String, secret_key:String, credentialsProvider:CredentialsProvider) {
		this.oAuth = new OAuth(tokenUrl, secret_key, credentialsProvider);
	}

	public function login_for_access_token(request:Request, response:Response) {
		var post_data:String = request.data.toString();
		var access_token = user_data_for_access_token(post_data);
		var data = {"access_token": access_token, "token_type": "bearer"};
		var jsonString = haxe.Json.stringify(data);
		response.send(jsonString);
	}

	private function user_data_for_access_token(post_data:String):String {
		var data = PostData.parse(post_data);
		var form_data = OAuth2PasswordRequestForm.validate(data);
		var user = this.oAuth.authenticate_user(form_data.username, form_data.password);
		if (user == null) {
			throw new HttpException(401, 'Incorrect username or password {"WWW-Authenticate": "Bearer"}');
		}
		return Jwt.create_access_token({sub: user.username}, this.oAuth.secret_key, OAuth.ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES);
	}
}
