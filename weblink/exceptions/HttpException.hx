package weblink.exceptions;

import haxe.Exception;
import haxe.http.HttpStatus;
import weblink._internal.HttpStatusMessage;

/**
	A base class for exceptions that occurred when handling HTTP requests.
**/
@:nullSafety(StrictThreaded)
class HttpException extends Exception {
	/**
		The HTTP status code that is associated with this exception.
	**/
	public var statusCode(default, null):HttpStatus;

	/**
		Creates a new HttpException instance.
		@param statusCode (Recommended) The HTTP status code that is associated with this exception.
		@param message (Optional) The message of this exception.
		@param previous (Optional) The previous exception that caused this exception.
	**/
	public function new(statusCode:HttpStatus = InternalServerError, ?message:String, ?previous:Exception) {
		super(message != null ? message : HttpStatusMessage.fromCode(statusCode), previous, null);
		this.statusCode = statusCode;
	}
}
