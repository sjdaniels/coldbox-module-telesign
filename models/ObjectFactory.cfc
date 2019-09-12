component {

	function getSettings() provider="coldbox:setting:telesign" {}

	function get(required string class) {
		var libs = expandpath("/telesign/lib/");
		return createObject("java", arguments.class, libs).init( getSettings().customerID, getSettings().apiKey );
	}
}