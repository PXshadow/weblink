package tests.security;

import weblink.security.BCryptPassword;

class TestBCryptPassword {
	public static function main() {
		trace("Starting TestBCryptPassword password hash Test");
		var password = "secret";
		var hashed_password = BCryptPassword.get_password_hash(password);
		var isOk = BCryptPassword.verify_password(password, hashed_password);
		if (!isOk) {
			trace('Bad hashed_password ${hashed_password}');
		}
		trace("done");
	}
}
