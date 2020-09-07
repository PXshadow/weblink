WebLink
======
Linking [Hashlink](https://github.com/HaxeFoundation/hashlink) to the role of a webserver.

```haxe
class Main {
    function main() {
        var app = new weblink.Weblink();
        app.get(function(request,response)
        {
            response.send("HELLO WORLD");
        });
        app.listen(2000);
    }
}
```

Getting Started
====

Install dev version:
```
haxelib git weblink https://github.com/PXshadow/weblink
```
Include in build.hxml
```
-lib weblink
```