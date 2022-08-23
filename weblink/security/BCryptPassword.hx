package weblink.security;

class BCryptPassword {
	private static var BCRYPT_SALT_LENGTH = 22;

	private static function gen_salt():String {
		var salt = "$2a$05$"; // $ prefix $ round $
		var chars = Alphanumericals.getChars();
		for (i in 0...BCRYPT_SALT_LENGTH) {
			var randInt = Std.random(chars.length);
			var selected_char = chars[randInt];
			salt = salt + String.fromCharCode(selected_char);
		}
		return salt;
	}

	public static function verify_password(plain_password, hashed_password) {
		return BCrypt.verify(plain_password, hashed_password);
	}

	public static function get_password_hash(password) {
		var salt = gen_salt();
		return BCrypt.encode(password, salt); // hash
	}
}
