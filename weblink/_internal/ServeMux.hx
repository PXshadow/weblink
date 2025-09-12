package weblink._internal;

@:follow
typedef ServeMux = go.net.http.Http.ServeMux;


function newServeMux()
    return go.net.http.Http.newServeMux();

function listenAndServe(port, mux)
    go.net.http.Http.listenAndServe(port, mux);

function redirect(w, r, url) {
    go.net.http.Http.redirect(w, r, url, 302);
}

private var server:go.net.http.Http.Server = null;
function update(port, mux:go.net.http.Http.ServeMux) {
    server = new go.net.http.Http.Server(":" + port, go.Go.asInterface(mux));
    server.listenAndServe();
}

function close() {
    server.shutdown(go.context.Context.tODO());
}