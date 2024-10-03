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
		TestCompression.main();
		TestCookie.main();
		TestCredentialsProvider.main();
		TestEndpointExample.main();
		TestHeaders.main();
		TestJwks.main();
		TestJwt.main();
		TestOAuth2.main();
		TestMiddlewareCorrectOrder.main();
		TestMiddlewareShortCircuit.main();
		TestPath.main();
		TestPostData.main();
		TestProjection.main();
		TestRadixTree.main();
		TestSign.main();
		Sys.exit(0);
	}
}
