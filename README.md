<p align="center">
    <img alt="weblink" src="weblink.svg" height="180px" align="center" />
</p>

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

Features
====
* Uses [libuv](https://github.com/libuv/libuv)
* Minimal and concise with express lib in mind
* No dependencies, and easy integration
* Extremely fast, roughly 4x faster than Fastify with big data, and 2x with small [Benchmark](#benchmark)


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

# Targets
* requires libuv
* hashlink (uses libuv)

# Benchmark

[<p align="left"><img src ="benchmark.png"></p>](https://github.com/PXshadow/weblinkBenchmark)

Supported
====
- [methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
    - [x] GET
    - [x] POST
    - [ ] OPTIONS
    - [x] HEAD
    - [x] PUT
- [encoding](https://developer.mozilla.org/en-US/docs/Web/HTTP/Compression)
    - [ ] gzip
    - [ ] compress
    - [x] deflate
    - [ ] br
- caching
    - [ ] age
    - [ ] expires
- security
    - [x] [cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
    - [ ] [cors](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
    - [x] [JWT](https://www.rfc-editor.org/rfc/rfc7519)
    - [x] [JWKS](https://www.rfc-editor.org/rfc/rfc7517#section-5)
    - [ ] OAuth2
        - [x] JWT Token endpoint
        - [x] [HS256](https://www.rfc-editor.org/rfc/rfc2104.html)
        - [ ] [Token revocation](https://oauth.net/2/token-revocation/)
        - [ ] [Metadata](https://oauth.net/2/authorization-server-metadata/)
    - [x] Bcrypt Passwords
    - [ ] ssl (haxe 4.2)
    - [ ] [cert bot](https://certbot.eff.org/) easy integration
- extra
    - [x] [content type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)
    - [x] bytes (png image for instance)
    - [x] [redirects](https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections)
    - [x] serve web content (files ex: html/images/sounds)
    - [ ] connection public ip (haxe 4.2)
    - [x] projection (a type with certain attributes of another type, useful to send only some data)

# Contributing

1. Fork
2. Clone and setup
5. Create a pull request with your changes
