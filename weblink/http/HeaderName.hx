package weblink.http;

import haxe.io.Bytes;

using StringTools;
using weblink._internal.CharTools;

/**
	A field name of an HTTP header.
**/
@:notNull
enum abstract HeaderName(String) to String {
	private static final ALLOW_RAW_COMMA_SEPARATED_VALUES = [
		AIM => true,
		Accept => true,
		AcceptCharset => true,
		AcceptEncoding => true,
		AcceptLanguage => true,
		AccessControlRequestHeaders => true,
		CacheControl => true,
		Connection => true,
		ContentEncoding => true,
		Expect => true,
		Forwarded => true,
		IfMatch => true,
		IfNoneMatch => true,
		Range => true,
		TE => true,
		Trailer => true,
		TransferEncoding => true,
		Upgrade => true,
		Via => true,
		Warning => true,
	];

	private static final ALLOW_RAW_SEMICOLON_SEPARATED_VALUES = [ContentType => true, Cookie => true, Prefer => true];

	private static final DO_NOT_ALLOW_REPEATS = [
		AcceptDatetime => true,
		AccessControlRequestMethod => true,
		Authorization => true,
		ContentLength => true,
		ContentMD5 => true,
		Date => true,
		From => true,
		Host => true,
		Http2Settings => true,
		IfModifiedSince => true,
		IfRange => true,
		IfUnmodifiedSince => true,
		MaxForwards => true,
		Origin => true,
		Pragma => true,
		ProxyAuthorization => true,
		Referer => true,
		UserAgent => true,
	];

	public var Accept = "accept";
	public var AcceptCH = "accept-ch";
	public var AcceptCharset = "accept-charset";
	public var AcceptDatetime = "accept-datetime";
	public var AcceptEncoding = "accept-encoding";
	public var AcceptLanguage = "accept-language";
	public var AcceptPatch = "accept-patch";
	public var AcceptRanges = "accept-ranges";
	public var AccessControlAllowCredentials = "access-control-allow-credentials";
	public var AccessControlAllowHeaders = "access-control-allow-headers";
	public var AccessControlAllowMethods = "access-control-allow-methods";
	public var AccessControlAllowOrigin = "access-control-allow-origin";
	public var AccessControlExposeHeaders = "access-control-expose-headers";
	public var AccessControlRequestHeaders = "access-control-request-headers";
	public var AccessControlRequestMethod = "access-control-request-method";
	public var Age = "age";
	public var AIM = "aim";
	public var Allow = "allow";
	public var AltSvc = "alt-svc";
	public var Authorization = "authorization";
	public var CacheControl = "cache-control";
	public var Connection = "connection";
	public var ContentDisposition = "content-disposition";
	public var ContentEncoding = "content-encoding";
	public var ContentLanguage = "content-language";
	public var ContentLength = "content-length";
	public var ContentLocation = "content-location";
	public var ContentMD5 = "content-md5";
	public var ContentRange = "content-range";
	public var ContentSecurityPolicy = "content-security-policy";
	public var ContentType = "content-type";
	public var Cookie = "cookie";
	public var Date = "date";
	public var DeltaBase = "delta-base";
	public var DNT = "dnt";
	public var ETag = "etag";
	public var Expect = "expect";
	public var Expires = "expires";
	public var Forwarded = "forwarded";
	public var From = "from";
	public var FrontEndHttps = "front-end-https";
	public var Host = "host";
	public var Http2Settings = "http2-settings";
	public var IfMatch = "if-match";
	public var IfModifiedSince = "if-modified-since";
	public var IfNoneMatch = "if-none-match";
	public var IfRange = "if-range";
	public var IfUnmodifiedSince = "if-unmodified-since";
	public var IM = "im";
	public var LastModified = "last-modified";
	public var Link = "link";
	public var Location = "location";
	public var MaxForwards = "max-forwards";
	public var NEL = "nel";
	public var Origin = "origin";
	public var Pragma = "pragma";
	public var Prefer = "prefer";
	public var PreferenceApplied = "preference-applied";
	public var ProxyAuthenticate = "proxy-authenticate";
	public var ProxyAuthorization = "proxy-authorization";
	public var PublicKeyPins = "public-key-pins";
	public var Range = "range";
	public var Referer = "referer";
	public var Refresh = "refresh";
	public var ReportTo = "report-to";
	public var RetryAfter = "retry-after";
	public var SaveData = "save-data";
	public var SecFetchDest = "sec-fetch-dest";
	public var SecFetchMode = "sec-fetch-mode";
	public var SecFetchSite = "sec-fetch-site";
	public var SecFetchUser = "sec-fetch-user";
	public var SecGPC = "sec-gpc";
	public var Server = "server";
	public var SetCookie = "set-cookie";
	public var StrictTransportSecurity = "strict-transport-security";
	public var TE = "te";
	public var Tk = "tk";
	public var Trailer = "trailer";
	public var TransferEncoding = "transfer-encoding";
	public var Upgrade = "upgrade";
	public var UpgradeInsecureRequests = "upgrade-insecure-requests";
	public var UserAgent = "user-agent";
	public var Vary = "vary";
	public var Via = "via";
	public var Warning = "warning";
	public var WWWAuthenticate = "www-authenticate";
	public var XContentTypeOptions = "x-content-type-options";
	public var XForwardedFor = "x-forwarded-for";
	public var XForwardedHost = "x-forwarded-host";
	public var XForwardedProto = "x-forwarded-proto";
	public var XFrameOptions = "x-frame-options";
	public var XHttpMethodOverride = "x-http-method-override";
	public var XPoweredBy = "x-powered-by";
	public var XRedirectBy = "x-redirect-by";
	public var XRequestedWith = "x-requested-with";
	public var XRequestId = "x-request-id";
	public var XUACompatible = "x-ua-compatible";
	public var XXSSProtection = "x-xss-protection";

	/**
		Returns true if this header name allows raw comma-separated values.
	**/
	@:pure
	public inline function allowsRawCommaSeparatedValues():Bool {
		return HeaderName.ALLOW_RAW_COMMA_SEPARATED_VALUES.get(this) == true;
	}

	/**
		Returns true if this header name allows raw semicolon-separated values.
	**/
	@:pure
	public inline function allowsRawSemicolonSeparatedValues():Bool {
		return HeaderName.ALLOW_RAW_SEMICOLON_SEPARATED_VALUES.get(this) == true;
	}

	/**
		Returns true if this header name is known to not allow repeats.
	**/
	@:pure
	public inline function doesNotAllowRepeats():Bool {
		return HeaderName.DO_NOT_ALLOW_REPEATS.get(this) == true;
	}

	/**
		Tries to normalize a string into a header field name.
	**/
	public static function tryNormalizeString(str:String):NormalizeResult {
		final len = str.length;
		if (len == 0)
			return Empty;
		final bytes = Bytes.alloc(len); // 1 byte per character
		for (i in 0...len) {
			final char = str.fastCodeAt(i); // code unit, range [0, 65535]
			if (!char.isAscii()) // notably Latin1 was never allowed in names
				return NotAscii(char);
			if (!char.isAllowedInHeaderName()) // separator or control char
				return ForbiddenChar(char);
			bytes.set(i, char.toLowerCase());
		}
		return Valid(cast bytes.toString()); // UTF-8 is a superset of ASCII
	}

	/**
		Normalizes a string into a header field name or throws.
	**/
	@:from
	public static function normalizeOrThrow(str:String):HeaderName {
		switch (tryNormalizeString(str)) {
			case Valid(name):
				return name;
			case NotAscii(codeUnit):
				final ch = String.fromCharCode(codeUnit);
				throw '"$str" cannot be used as a header name because "$ch" cannot fit in US-ASCII';
			case ForbiddenChar(codeUnit):
				final ch = String.fromCharCode(codeUnit);
				throw 'char \'$ch\' of "$str" cannot be used in a header name';
			case Empty:
				throw "header names cannot be empty";
		}
	}
}

enum NormalizeResult {
	Valid(name:HeaderName);
	NotAscii(codeUnit:Int);
	ForbiddenChar(codeUnit:Int);
	Empty;
}
