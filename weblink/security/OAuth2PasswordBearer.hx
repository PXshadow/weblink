package weblink.security;

import weblink.HTTPException;

class OAuth2 {
	var scheme_name:Null<String>;
	var auth_error:Null<Bool>;

	public function new(scheme_name:Null<String> = null, description:Null<String> = null, auth_error:Null<Bool> = true) {
		this.scheme_name = scheme_name;
		this.auth_error = auth_error;
	}

	public function call(request:Request):Null<String> {
		var authorization:String = request.header.get("Authorization");
		if (authorization == null) {
			if (this.auth_error) {
				throw new HTTPException("403 Not authenticated");
			} else {
				return null;
			}
		}
		return authorization;
	}
}

class OAuth2PasswordBearer extends OAuth2 {
	var flows:{tokenUrl:String, scopes:Map<String, String>};

	public function new(tokenUrl:String, ?scheme_name:Null<String> = null, ?scopes:Null<Map<String, String>> = null, ?description:Null<String> = null,
			?auth_error:Bool = true) {
		if (scopes == null) {
			scopes = new Map<String, String>();
		}
		this.flows = {tokenUrl: tokenUrl, scopes: scopes};
		super(scheme_name, description, auth_error);
	}

	public override function call(request:Request):Null<String> {
		var authorization:String = request.header.get("Authorization");
		var authSplit = authorization.split(" ");
		var scheme = authSplit[0];
		var param = authSplit[1];
		if (authorization == null || scheme.toLowerCase() != "bearer") {
			if (this.auth_error) {
				throw new HTTPException('401 Not authenticated {"WWW-Authenticate": "Bearer"}');
			} else {
				return null;
			}
		}
		return param;
	}
}
