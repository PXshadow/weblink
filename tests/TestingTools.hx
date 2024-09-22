package;

import weblink.Weblink;
#if nodejs
import haxe.Constraints.Function;
import js.html.RequestInit;
import js.html.Response;
import js.lib.Promise;
import js.node.events.EventEmitter;
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
}
