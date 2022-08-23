package weblink;

import Type;

class Projection {
	/*
		Return input data with outputClass type
	 */
	public static function convert(input, outputClass) {
		var output = Type.createInstance(outputClass, []);
		for (field in Type.getInstanceFields(outputClass)) {
			Reflect.setField(output, field, Reflect.field(input, field));
		}
		return output;
	}
}
