package weblink;

/*
	Handle Post Data in HTTP Request
	When Content Type is application/x-www-form-urlencoded
 */
class PostData {
	/*
		post_data has the following form: toto=1&tata=plop
	 */
	public static function parse(post_data:String):Map<String, String> {
		var parameters:Array<String> = post_data.split("&");
		var data:Map<String, String> = [];
		for (param in parameters) {
			var pair:Array<String> = param.split("=");
			if (pair[0] != null && pair[1] != null)
				data.set(pair[0], pair[1]);
		}
		return data;
	}
}
