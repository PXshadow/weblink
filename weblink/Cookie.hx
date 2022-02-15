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
    public var sameSite:Null<SameSite>;
    public var httpOnly:Null<Bool>;
    public var secure:Bool = false;
    public var domain:Null<String>;
    public var expiry:Null<Date>;
    public var maxAge:Null<Int>;


    public var path:Null<String>;
    
    /**
     * The implementation of a Cookie for both Responses and Requests, following the implementation defined in https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies
     * 
     * A request sent from a client will use the most basic form of this object which is defined as "id=value".
     * @param id 
     * @param value 
     * @param path 
     * @param sameSite 
     * @param maxAge 
     * @param expiry 
     * @param httpOnly 
     * @param domain 
     */
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
        var cookieStrBuff:StringBuf = new StringBuf();

        cookieStrBuff.add('$id=$value');
        
        if(this.domain != null){
            cookieStrBuff.add('; Domain=$domain');
        }
        //Max Age has Precidence, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie however, both can be set.
        //Probably should try to place a compiler warning (or something else similar) to warn users of this.
        if(this.maxAge != null) {
            cookieStrBuff.add('; Max-Age=$maxAge');
        }
        if(this.expiry != null){
            //expiry is always expressed in GMT
            cookieStrBuff.add('; Expires=${DateTools.format(this.expiry, "%a, %d $b %Y %H:%M:%S GMT")}');
        }
        if(this.path != null) {
            cookieStrBuff.add('; Path=$path');
        }
        if(this.secure == true) {
            cookieStrBuff.add("; Secure; ");
        }
        if(this.httpOnly == true) {
            cookieStrBuff.add("; HttpOnly");
        }
        if(this.sameSite != null) {
            cookieStrBuff.add('; Same-Site=${sameSite.getName()}');
        }
        return cookieStrBuff.toString();
    }

}