component {
	processingdirective preserveCase=true;

	property name="settings" inject="coldbox:moduleSettings:telesign";

	public API function init() {
		endpoint 	= "https://rest-ww.telesign.com";
		version 	= "v1";

		return this;
	}

	private struct function call(required string path, required string method, struct params={}) {
		var cfhttp = {};
		var auth = toBase64("#settings.customerID#:#settings.apiKey#");
		http url="#endpoint##arguments.path#" method="#arguments.method#" result="cfhttp" {
			httpparam type="header" name="Authorization" value="Basic #auth#";
			for (local.arg in arguments.params) {
				httpparam type="#arguments.method=='post'?'formfield':'url'#" name="#local.arg#" value="#arguments.params[local.arg]#";
			}
		}

		return parseResponse(cfhttp);
	}

	private any function parseResponse(required struct response) {
		var exception = { type:"TeleSign" }
		
		try {
			var apiResult = deserializeJSON(arguments.response.filecontent);
		} catch (Any e) {
			exception.message = "Deserialization Error"
			exception.detail = serializeJSON(arguments.response);
			throw(argumentCollection:exception);
		}
									
		return apiResult;  
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

	struct function verifySMS(required string phone, string lang, string code, string template="Your confirmation code is $$CODE$$", string ucid) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var params = {
			  phone_number : arguments.phone
			 ,template : arguments.template
		}

		if (!isnull(arguments.lang))
			params.language = arguments.lang;

		if (!isnull(arguments.code))
			params.verify_code = arguments.code;

		if (!isnull(arguments.ucid))
			params.ucid = arguments.ucid;


		var result = call("/v1/verify/sms","POST",params);
		return result;
	}

	struct function verifyCall(required string phone, string lang, string code) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var Verify = Factory.get("com.telesign.verify.Verify");
		var result = Verify.call( arguments.phone, arguments.lang ?: nullValue(), arguments.code ?: nullValue(), nullValue(), 0, nullValue(), false );
		return deserializeJSON(result);
	}

	struct function verifyStatus(required string referenceID, required string verification) {
		var params = {
			  verify_code : arguments.verification
		}

		var result = call("/v1/verify/#arguments.referenceID#","GET",params);
		return result;
	}
}