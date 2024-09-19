package weblink._internal.ds;

@:forward
@:arrayAccess
@:forwardStatics
abstract FieldMap<K, V>(Map<String, V>) {
	public function new(m) {
		this = m;
	}

	@:op(a.b)
	public function fieldRead(name:String)
		return this.get(name);

	@:op(a.b)
	public function fieldWrite(name:String, value:V)
		return this.set(name, value);
}
