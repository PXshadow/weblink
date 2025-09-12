package weblink;

import go.net.http.Http.Cookie;

@:using(Response.ResponseStaticExtension)
typedef Response = go.net.http.Http.ResponseWriter;


class ResponseStaticExtension {
    public static function send(response:Response, data:String) {
        response.write(data);
    }
    public static function contentType(response:Response, contentType:String) {
       // DONE
       response.header().set("Content-Type", contentType);
    }
    public static function addCookie(response:Response, path:String, value:String) {
        go.net.http.Http.setCookie(response, new Cookie(path, value));
    }
}