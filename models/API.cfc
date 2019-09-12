component {

	property name="Factory" inject="ObjectFactory@telesign";

	public API function init() {
		endpoint 	= "https://rest-ww.telesign.com";
		version 	= "v1";

		return this;
	}

	struct function score(required string phone, required string ucid) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var Phone = Factory.get("com.telesign.phoneid.PhoneId");
		var result = Phone.score( arguments.phone, arguments.ucid );
		return deserializeJSON(result);
	}

	struct function contact(required string phone, required string ucid) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var Phone = Factory.get("com.telesign.phoneid.PhoneId");
		var result = Phone.contact( arguments.phone, arguments.ucid );
		return deserializeJSON(result);
	}

	struct function verifySMS(required string phone, string lang, string code, string template="Your confirmation code is $$CODE$$") {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var Verify = Factory.get("com.telesign.verify.Verify");
		var result = Verify.sms( arguments.phone, arguments.lang ?: nullValue(), arguments.code ?: nullValue(), arguments.template );
		return deserializeJSON(result);
	}

	struct function verifyCall(required string phone, string lang, string code) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var Verify = Factory.get("com.telesign.verify.Verify");
		var result = Verify.call( arguments.phone, arguments.lang ?: nullValue(), arguments.code ?: nullValue(), nullValue(), 0, nullValue(), false );
		return deserializeJSON(result);
	}

	struct function verifyStatus(required string referenceID, required string verification) {
		var Verify = Factory.get("com.telesign.verify.Verify");
		var result = Verify.status( arguments.referenceID, arguments.verification );
		return deserializeJSON(result);
	}
}