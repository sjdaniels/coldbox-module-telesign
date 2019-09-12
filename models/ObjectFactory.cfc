component {

	function getSettings() inject="coldbox:setting:telesign" {}

	function get(required string class) {
		var libs = [
			 expandpath("/telesign/lib/TeleSign.jar")
			,expandpath("/telesign/lib/gson-2.3.1.jar")
			,expandpath("/telesign/lib/hamcrest-core-1.3.jar")
			,expandpath("/telesign/lib/commons-codec-1.7.jar")
		]
		return createObject("java", arguments.class, libs).init( getSettings().customerID, getSettings().apiKey );
	}
}