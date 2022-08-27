import weblink.Projection;
import weblink.security.OAuth.User;
import weblink.security.OAuth.UserInDB;

class TestProjection {
	public static function main() {
		var input = new UserInDB();

		input.username = 'String';
		input.email = 'String';
		input.full_name = 'String';
		input.disabled = false;
		input.hashed_password = 'pw';

		var output = Projection.convert(input, User);
		if (!Std.isOfType(output, User)) {
			trace("Ko: output is not of type User");
		}
		if (Std.isOfType(output, UserInDB)) {
			trace("Ko: user is of type UserInDb");
		}
	}
}
