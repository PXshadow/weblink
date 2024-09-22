package weblink.security;

import haxe.io.Bytes;

typedef Jwk = {n:String, e:String, kid:String, kty:String};

/*
	Json Web Key Set
	See: https://www.rfc-editor.org/rfc/rfc7517#section-5
 */
class Jwks {
	private var keys = new Array<Jwk>();

	public function new() {}

	public function jwksGetEndpoint(request:Request, response:Response):Void {
		response.headers = new List<Header>();
		response.headers.add({key: 'Content-Type', value: 'application/json'});
		var data = {
			keys: this.keys
		};
		var jsonString = haxe.Json.stringify(data);
		response.send(jsonString);
	}

	public function jwksPostEndpoint(request:Request, response:Response):Void {
		var jsonWebKey:Jwk = haxe.Json.parse(request.data.toString()); // potential improvement: fast json parse
		if (jsonWebKey.n != null && jsonWebKey.e != null && jsonWebKey.kid != null && jsonWebKey.kty != null) {
			this.keys.push(jsonWebKey);
		}
		response.send("");
	}
}
