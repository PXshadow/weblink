package weblink;

enum SameSite {
    Strict;
    Lax;
    None;
}

@:keep
class Cookie {
    @:notNull
    public var id:String;
    public var value:String;
    public var sameSite:SameSite;
    public var httpOnly:Bool;
    public var secure:Bool = false;
    public var domain:String;
    public var expiry:Date;
    public var maxAge:Int;


    public var path:String;
    
    public function new(id:String, value:String, ?path:String, ?sameSite:SameSite, ?maxAge:Int, ?expiry:Date, ?httpOnly:Bool, ?domain:String) {
        this.id = id;
        this.value = value;
        this.path = path;
        this.sameSite = sameSite;
        this.maxAge = maxAge;
        this.expiry = expiry;
        this.httpOnly = httpOnly;
        this.domain = domain;
    }
    /**
     * Resolve this cookie to a correctly formatted string to be added to the header.
     * @return String the string to be added.
     */
    public function resolveToResponseString():String {
        var cookieStrBuff:StringBuf;

        cookieStrBuff.add("id="+this.id+"; ");
        if(this.domain != null){
            cookieStrBuff.add("Domain=" + this.domain + "; ");
        }
        //Max Age has Precidence, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie however, both can be set.
        //Probably should try to place a compiler warning (or something else similar) to warn users of this
        if(this.maxAge != null) {
            cookieStrBuff.add("Max-Age=" + this.maxAge + "; ");
        }
        if(this.expiry != null){
            //expiry is always expressed in GMT
            cookieStrBuff.add("Expires=" + DateTools.format(this.expiry, "%a, %d $b %Y %H:%M:%S GMT") + "; ");
        }
        if(this.path != null) {
            cookieStrBuff.add("Path=" + this.path + "; ");
        }
        if(this.secure == true) {
            cookieStrBuff.add("Secure; ");
        }
        if(this.httpOnly == true) {
            cookieStrBuff.add("HttpOnly; ");
        }
        if(this.sameSite != null) {
            cookieStrBuff.add("Same-Site="+ this.sameSite.getName() + "; ");
        }
        return cookieStrBuff.toString();
    }

}