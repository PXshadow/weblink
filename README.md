<p align="center">
    <img alt="weblink" src="weblink.svg" height="180px" align="center" />
</p>

WebLink Version 2
======
Linking [Hashlink](https://github.com/HaxeFoundation/hashlink) and other [targets](#targets) to the role of a webserver.

```haxe
function main() {
    var app = new weblink.Weblink();
    app.get(function(request,response)
    {
        response.send("HELLO WORLD");
    });
    app.listen(2000);
}
```

Features
====
* Uses [net/http](https://pkg.go.dev/net/http) from Go's stdlib, compiled into Haxe code using [go2hx](https://github.com/go2hx/go2hx).
* Minimal and concise with express library in mind.
* No dependencies, and easy integration.


Getting Started
====

Requires Haxe 5.0 preview 1, no other version works (better forwards compatibility hopefully for the next Haxe preview edition)

Install dev version:
```
haxelib git weblink https://github.com/PXshadow/weblink v2
```
Include in build.hxml
```
-lib weblink
```

# Targets
* Hashlink
* Interp (untested but may work?)

# Benchmark

Supported
====
- [methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
    - [x] GET
    - [x] POST
    - [ ] OPTIONS
    - [x] HEAD
    - [x] PUT
- [encoding](https://developer.mozilla.org/en-US/docs/Web/HTTP/Compression)
    - automatically handled
- caching
    - automatically handled by last modified using file server
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
    - [ ] ssl (Haxe 4.2)
    - [ ] [cert bot](https://certbot.eff.org/) easy integration
- extra
    - [x] [content type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type)
    - [x] bytes (png image for instance)
    - [x] [redirects](https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections)
    - [x] serve web content (files ex: html/images/sounds)
    - [x] projection (a type with certain attributes of another type, useful to send only some data)
    - [ ] [hxcoro](https://github.com/haxeFoundation/hxcoro) usage

# Contributing

1. Fork
2. Clone and setup
4. Make changes and run, tests.hxml and hl test.hl
5. Pull request
