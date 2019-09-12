<cfscript>
	param name="args.placeholder" default="Full Phone Number";
	param name="args.button" default="Verify Phone";


</cfscript>
<cfoutput>
	<h1>Telesign Verification</h1>
	<form method="post" class="form-horizontal">
		<div class="form-group">
	    	<label for="countrycode" class="col-md-2">Country Code</label>
	    	<div class="col-md-4">
		    	<select name="countrycode" id="countrycode" class="form-control">
		    		<cfloop array="#getInstance('Codes@telesign').getCountryCodes()#" item="code">
		    			<option value="#code.num#"<cfif code.code=="US"> selected</cfif>>#code.name#: +#code.num#</option>
		    		</cfloop>
		    	</select>
	    	</div>
		</div>
		<div class="form-group">
	    	<label for="phone" class="col-md-2">Phone Number</label>
	    	<div class="col-md-4">
	    		<input type="text" name="phone" value="" class="form-control">
	    	</div>
		</div>
		<button class="btn btn-info" type="submit">#args.button#</button>
	</form>
</cfoutput>