component {
	processingdirective preserveCase=true;

	property name="settings" inject="coldbox:moduleSettings:telesign";

	public API function init() {
		endpoint 	= "https://rest-ww.telesign.com";
		version 	= "v1";

		return this;
	}

	private struct function call(required string path, required string method, struct params={}, struct body={}) {
		var cfhttp = {};
		var auth = toBase64("#settings.customerID#:#settings.apiKey#");
		http url="#endpoint##arguments.path#" method="#arguments.method#" result="cfhttp" {
			httpparam type="header" name="Authorization" value="Basic #auth#";
			for (local.arg in arguments.params) {
				httpparam type="#arguments.method=='post'?'formfield':'url'#" name="#local.arg#" value="#arguments.params[local.arg]#";
			}
			if (arguments.body.len()) {
				httpparam type="header" name="Content-Type" value="application/json";
				httpparam type="body" value="#serializeJSON(arguments.body)#";
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

    struct function phoneID(required string phone) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');
		
		var result = call(path:"/v1/phoneid/#arguments.phone#",method:"POST");
		return result;
	}

	struct function contactMatch(required string phone, required string ucid, required string first_name, required string last_name, string date_of_birth) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');
		
		var body = {
			 ucid:arguments.ucid
		}

		body.addons = {
			contact_match: {
				 first_name:arguments.first_name
				,last_name:arguments.last_name
			}
			,contact:{}
		}

		if (!isnull(arguments.date_of_birth))
			body.addons.contact_match.date_of_birth = arguments.date_of_birth;

		var result = call(path:"/v1/phoneid/#arguments.phone#",method:"POST",body:body);
		return result;
	}

	struct function verifySMS(required string phone, string lang, string code, string template="Your confirmation code is $$CODE$$", string ucid) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var params = {
			  phone_number : getPhoneNumber(arguments.phone)
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

	struct function verifyCall(required string phone, string lang, string code, string call_forward_action="Block", string ucid) {
		// strip non-numeric
		arguments.phone = rereplace(arguments.phone,'[^0-9]','','all');

		var params = {
			  phone_number : arguments.phone
			 ,call_forward_action : arguments.call_forward_action
		}

		if (!isnull(arguments.lang))
			params.language = arguments.lang;

		if (!isnull(arguments.code))
			params.verify_code = arguments.code;

		if (!isnull(arguments.ucid))
			params.ucid = arguments.ucid;

		var result = call("/v1/verify/call","POST",params);
		return result;
	}

	struct function verifyStatus(required string referenceID, required string verification) {
		var params = {
			  verify_code : arguments.verification
		}

		var result = call("/v1/verify/#arguments.referenceID#","GET",params);
		return result;
	}

	string function getPhoneNumber(required string phone) {
		if (controller.getSetting("isLocalDev", false)) {
			local.env=  new coldbox.system.core.delegates.Env();
			return local.env.getSystemSetting("TESTING_PHONE_INTERCEPT","+15125548702");
		}
		return arguments.phone;
	}
}