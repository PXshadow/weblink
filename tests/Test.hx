package;

class Test
{
    public static function main()
    {
        Sys.println("start test");
        var app = new weblink.Weblink();
        app.get("/");
        app.listen(8000);
    }
}