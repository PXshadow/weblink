import haxe.Timer;
import sys.io.Process;
import haxe.Http;

class Request {
	public static function main() {
		Sys.println("start test");
		var app = new weblink.Weblink();
		app.get(function(request, response) {
			response.send("HELLO WORLD " + Date.now());
		});
		app.post(function(request, response) {
			trace("POST DATA: " + request.data);
			response.send('HELLO POST WORLD: ${request.data} ' + Date.now());
		});
		Timer.delay(function() {
			trace("START!");
			#if (target.threaded)
			sys.thread.Thread.create(function() {
				#if http
				// var stamp = Timer.stamp();
				var http = new Http("localhost:2000");
				var post:Bool = false;
				http.onData = function(text:String) {
					trace('${post ? "1" : "0"}: data: $text');
					// trace('time ${Timer.stamp() - stamp}');
					if (post)
						return;
					post = true;
					http.setPostData("NEW POST DATA HTTP");
					http.request(true);
				}
				http.onError = function(error:String) {
					trace("error: " + error);
				}
				http.request(false);
				#end
				#if curl
				trace("CURL");
				var curl = new Process("curl localhost:2000");
				trace("2: " + curl.stdout.readLine());
				var curl = new Process('curl --data "NEW POST DATA" localhost:2000');
				trace("3: " + curl.stdout.readLine());
				#end
			});
			#end
		}, 1000);
		Timer.delay(function() {
			trace("set listen");
			app.listen(2000);
		}, 0);
	}
}
