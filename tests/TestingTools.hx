package;

import weblink.Weblink;
#if nodejs
import js.html.Headers;
import js.html.RequestInit;
import js.html.Response;
import js.lib.Promise;
import sys.NodeSync;
#elseif (target.threaded)
import sys.thread.Lock;
import sys.thread.Thread;
#end

final class TestingTools {
	/**
		If running on a threaded target (ie. Hashlink),
		creates the server in a separate thread and keeps polling it,
		so that our main testing thread can do HTTP requests.
		If running on a non-threaded target (ie. NodeJS),
		creates the server in the current thread and hopes for the best.
	**/
	public static function listenBackground(app:Weblink, port:Int) {
		#if (target.threaded)
		final lock = new Lock();
		Thread.create(() -> {
			app.listen(port, false);
			lock.release();
			while (app.server.running) {
				app.server.update(false);
				Sys.sleep(0.1);
			}
		});
		lock.wait();
		#else
		app.listen(port, false);
		#end
	}

	public inline static function GET(url:String, ?body:String = null):String {
		return request(url, {post: false, body: body});
	}

	public inline static function POST(url:String, body:String):String {
		return request(url, {post: true, body: body});
	}

	/**
		Performs a blocking HTTP request to the provided URL.
	**/
	public static function request(url:String, opts:RequestOptions):String {
		#if (hl)
		final http = new haxe.Http(url);
		var responseString:Null<String> = null;
		http.onError = e -> throw e;
		http.onData = s -> responseString = s;
		if (opts.headers != null) {
			for (key => value in opts.headers) {
				http.setHeader(key, value);
			}
		}
		if (opts.body != null) {
			http.setPostData(opts.body);
		}
		http.request(opts.post); // sys.Http#request reads sys.net.Sockets, which is blocking
		return responseString;
		#elseif (nodejs)
		var response:Null<Result> = null;

		final options:RequestInit = {
			method: opts.post ? "POST" : "GET",
			body: opts.body,
			headers: if (opts.headers != null) {
				final h = new Headers();
				for (key => value in opts.headers) {
					h.append(key, value);
				}
				h;
			} else {
				untyped undefined;
			}
		};

		// fetch is not behind a flag since Node 18 and stable since Node 21
		Global.fetch(url, options)
			.then(response -> if (response.status >= 400 && response.status <= 599) {
				throw 'Http Error #${response.status}'; // to mimic HL behavior
			} else {
				response.text();
			})
			.then(text -> response = Success(text))
			.catchError(e -> response = Failure(e.message));

		NodeSync.wait(() -> response != null);
		switch response {
			case Success(value):
				return value;
			case Failure(error):
				throw error;
		}
		#end
	}
}

typedef RequestOptions = {
	post:Bool,
	?body:String,
	?headers:Map<String, String>,
}

enum Result {
	Success(value:String);
	Failure(error:String);
}

#if (nodejs)
@:native("globalThis")
extern class Global {
	public static function fetch(url:String, options:RequestInit):Promise<Response>;
}
#end
