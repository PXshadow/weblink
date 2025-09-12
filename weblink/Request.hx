package weblink;

@:using(Request.RequestStaticExtension)
typedef Request = go.net.http.Http.Request;


class RequestStaticExtension {
    public static function data(request:Request):String {
        // TODO
        final obj = go.io.Io.readAll(request.body);
        if (obj._1 != null)
            throw obj._1.error();
        return obj._0.toBytes().toString();
        return "testing";
    }
}

