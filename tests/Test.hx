package;

class Test
{
    public static function main()
    {
        Sys.println("start test");
        var app = new weblink.Weblink();
        app.get(function(request,response)
        {
            response.send("HELLO WORLD");
        });
        app.listen(2000);
    }
}