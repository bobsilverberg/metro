<cfcomponent displayname="metro.tests.transient.ValidatorTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		
		<cfscript>
		var csPath = '/metro/tests/config/beans.xml';
		var additionalPath =  '/' & Replace(GetMetadata(this).displayname,'.','/','all') & '.xml';
		var params = Structnew();
		params.datasourcePath = '/metro/tests/config/Datasource.xml';		
		params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
		params.definitionsPath = '/metro/config/definitions';
		setBeanFactory(coldspringXML: csPath, params: params, additionalXML: additionalPath);
		setValidator(getBeanFactory().getBean("TransientFactory").create("Validator"));
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
	 <!--- Place tearDown/clean up code here --->
	</cffunction>

	<!--- Begin Specific Test Cases --->
	
	<cffunction name="testValidateString" access="public" returntype="void">
		<cfscript>
		var rules = ArrayNew(1);
		var rule = newRule();
		var obj = getBeanFactory().getBean("MockBO");
		var validator = getValidator();
		rule.property = "String";
		rule.label = "String";
		rule.testtype = "string";
		ArrayAppend(rules,rule);
		obj.mockMethod('getRules').returns(rules);
		obj.mockMethod('getString',true).returns("My String");
		validator.validate(obj,'test');
		assertFalse(validator.hasErrors());
		</cfscript>
	</cffunction>
 
	<cffunction name="testValidateNumber" access="public" returntype="void">
		<cfscript>
		var rules = ArrayNew(1);
		var rule = newRule();
		var obj = getBeanFactory().getBean("MockBO");
		var validator = getValidator();
		rule.property = "Number";
		rule.label = "Number";
		rule.testtype = "numeric";
		ArrayAppend(rules,rule);
		obj.mockMethod('getRules').returns(rules);
		obj.mockMethod('getNumber',true).returns(10);
		validator.validate(obj,'test');
		assertFalse(validator.hasErrors());
		</cfscript>
	</cffunction>
	
	<cffunction name="testValidateDate" access="public" returntype="void">
		<cfscript>
		var rules = ArrayNew(1);
		var rule = newRule();
		var obj = getBeanFactory().getBean("MockBO");
		var validator = getValidator();
		rule.property = "Date";
		rule.label = "Date";
		rule.testtype = "date";
		ArrayAppend(rules,rule);
		obj.mockMethod('getRules').returns(rules);
		obj.mockMethod('getDate',true).returns(now());
		validator.validate(obj,'test');
		assertFalse(validator.hasErrors());
		</cfscript>
	</cffunction>
		<!---

	<cffunction name="testValidateEmail" access="public" returntype="void">
		<cfscript>
		var rules = ArrayNew(1);
		var rule = newRule();
		var obj = getBeanFactory().getBean("MockBO");
		var validator = getValidator();
		rule.property = "Email";
		rule.label = "Email Address";
		rule.testtype = "email";
		rule.required = true;
		rules["Email"] = rule;
		obj.mockMethod('getRules').returns(rules);
		obj.mockMethod('getEmail',true).returns("paul@fancybread.com");
		assertTrue(StructCount(getBeanFactory().getbean("Validator").validate(obj,'test')) eq 0);
		</cfscript>
	</cffunction>
		 --->
	<cffunction name="testValidateEqualsProperty" access="public" returntype="void">
		<cfscript>
		var rules = ArrayNew(1);
		var rule = newRule();
		var obj = getBeanFactory().getBean("MockBO");
		var validator = getValidator();
		rule.property = "ConfirmEmail";
		rule.label = "Email Address";
		rule.testtype="isMatch";
		rule.compareProperty="Email";		
		ArrayAppend(rules,rule);
		obj.mockMethod('getRules').returns(rules);
		obj.mockMethod('getEmail',true).returns("paul@fancybread.com");		
		obj.mockMethod('getConfirmEmail',true).returns("paul@fancybread.com");
		validator.validate(obj,'test');
		assertFalse(validator.hasErrors());
		</cfscript>
	</cffunction>

	<!--- End Specific Test Cases --->

	<!--- private --->

	<cffunction name="setValidator" access="private" returntype="void" output="false">
		<cfargument name="Validator" type="any" required="true">
		<cfset variables.Validator = arguments.Validator >
	</cffunction>
	
	<cffunction name="getValidator" access="private" returntype="any" output="false">
		<cfreturn variables.Validator />
	</cffunction>

	<cffunction name="newRule" access="private" returntype="struct" output="false">
		<cfscript>
			var rule = {ignoreOnEmpty=false,allowSpaces=true,isDependent=false};
			return rule;
		</cfscript>
	</cffunction>

</cfcomponent>

