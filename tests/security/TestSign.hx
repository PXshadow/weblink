package tests.security;

import weblink.security.Sign;

class TestSign {
	private static function testHMAC256() {
		var payload = "data";
		var signature = Sign.sign(payload, "secret", Sign.HASH_METHOD);
		var isOk = Sign.verify(payload, signature, "secret", Sign.HASH_METHOD);
		if (!isOk) {
			throw("Error");
		}
	}

	private static function test_wrong_key() {
		var payload = "data";
		var signature = Sign.sign(payload, "secret", Sign.HASH_METHOD);
		var isOk = Sign.verify(payload, signature, "another", Sign.HASH_METHOD);
		if (isOk) {
			throw("Error");
		}
	}

	private static function test_unsupported_alg() {
		var payload = "data";
		try {
			Sign.sign(payload, "secret", "SOMETHING");
		} catch (e) {
			return;
		}
		throw("Error");
	}

	public static function main() {
		testHMAC256();
		test_wrong_key();
		test_unsupported_alg();
	}
}
