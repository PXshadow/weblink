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
		Request.main();
		TestBCryptPassword.main();
		TestCookie.main();
		TestCredentialsProvider.main();
		TestEndpointExample.main();
		TestJwks.main();
		TestJwt.main();
		TestOAuth2.main();
		TestPath.main();
		TestPostData.main();
		TestProjection.main();
		TestSign.main();
		Sys.println("EXIT");
		Sys.exit(0);
	}
}
