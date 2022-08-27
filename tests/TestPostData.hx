import weblink.PostData;

class TestPostData {
	public static function main() {
		trace("Starting TestPostData Test");
		var validPostData = "toto=1&tata=plop";
		var validMap = PostData.parse(validPostData);
		var toto = validMap.get("toto");
		var tata = validMap.get("tata");
		if (toto != "1" || tata != "plop")
			trace('PostData parse KO: should have toto and tata, is $validMap');

		var invalidPostData = "alice&bob";
		var invalidMap = PostData.parse(invalidPostData);
		if (Lambda.count(invalidMap) != 0)
			trace('PostData parse KO: should be empty, is $invalidMap');

		var emptyPostData = "";
		var emptyMap = PostData.parse(emptyPostData);
		if (Lambda.count(emptyMap) != 0)
			trace('PostData parse KO: should be empty, is $emptyMap');

		trace("done");
	}
}
