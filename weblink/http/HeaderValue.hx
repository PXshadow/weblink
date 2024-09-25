package weblink.http;

/**
	A field value of an HTTP header.
	Currently no validation is performed on the value.
**/
@:forward
enum abstract HeaderValue(String) from String to String {}
