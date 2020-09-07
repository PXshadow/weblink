WebLink
======
Linking [Hashlink](https://github.com/HaxeFoundation/hashlink) and other [targets](#targets) to the role of a webserver.

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

# Targets 
*require sys and threading*
* hashlink (uses libuv) **hl**
* c++ **hxcpp**
* c# **hxcs**
* neko **n**

Features
====
* Uses [libuv](https://github.com/libuv/libuv)(fast c async sockets) on hashlink
* Minimal and concise with expressjs in mind
* No dependencies, and easy integration


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

Supported
====
- [methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
    - [x] GET
    - [ ] POST
    - [ ] OPTIONS
    - [ ] HEAD
    - [ ] PUT
- [encoding](https://developer.mozilla.org/en-US/docs/Web/HTTP/Compression)
    - [ ] gzip
    - [ ] compress
    - [ ] deflate
    - [ ] br
- caching
    - [ ] age
    - [ ] expires
- extra
    - [ ] [content type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)
    - [ ] [cors](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
    - [ ] bytes
    - [ ] [redirects](https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections)
    - [ ] [cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
    - [ ] ssl
    - [ ] [cert bot](https://certbot.eff.org/) easy integration
    - [ ] serve web content (files ex: html/images/sounds)
