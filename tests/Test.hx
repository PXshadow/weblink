package;

import security.TestEndpointExample;
import security.TestJwt;
import tests.security.TestBCryptPassword;
import tests.security.TestCredentialsProvider;
import tests.security.TestJwks;
import tests.security.TestOAuth2;
import tests.security.TestSign;

class Test {
	public static function main() {
		final index = Std.parseInt(Sys.args()[0]);
		trace("index:", index);
		if (index == null)
			throw "index not set";
		switch index {
			case 0: TestRequest.main();
			case 1: TestBCryptPassword.main();
			case 2: TestCookie.main();
			case 3: TestCredentialsProvider.main();
			case 4: TestEndpointExample.main();
			case 5: TestJwks.main();
			case 6: TestJwt.main();
			case 7: TestOAuth2.main();
			case 8: TestPath.main();
			case 9: TestPostData.main();
			case 10: TestProjection.main();
			case 11: TestSign.main();
		}
		Sys.println("EXIT");
		Sys.exit(0);
	}
}
