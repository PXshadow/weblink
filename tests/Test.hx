package;

class Test
{
    public static function main()
    {
        Sys.println("start test");
        var app = new weblink.Weblink();
        app.get(function(request,response)
        {
            trace("request " + request.headers);
        });
        app.listen(2000);
    }
}