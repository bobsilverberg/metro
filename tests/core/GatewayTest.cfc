<cfcomponent displayname="metro.tests.core.GatewayTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		
		<cfscript>
			var csPath = '/metro/tests/config/beans.xml';
			var additionalPath =  '/' & Replace(GetMetadata(this).displayname,'.','/','all') & '.xml';
			var params = Structnew();
			params.datasourcePath = '/metro/tests/config/Datasource.xml';		
			params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
			params.definitionsPath = '/metro/config/definitions';
			setBeanFactory(coldspringXML: csPath, params: params, additionalXML: additionalPath);
			variables.Gateway = getbeanFactory().getBean("EmployeeGateway");
			</cfscript>
		</cffunction>
	
		<cffunction name="tearDown" access="public" returntype="void">
		 <!--- Place tearDown/clean up code here --->
		</cffunction>
	
	<!--- Begin Specific Test Cases --->
		
		<cffunction name="newReturnsCorrectClass" returntype="void">
			<cfscript>
			var obj = getGateway().new();
			assertTrue(obj.getClassName() is "work.Employee");
			assertFalse(obj.getIsPersisted());
			</cfscript>
		</cffunction>
		
		<cffunction name="getClassNameReturnsCorrectClassName" returntype="void">
			<cfscript>
			assertTrue(getGateway().getClassName() is "work.Employee");
			</cfscript>
		</cffunction>
	
		<cffunction name="getPrimaryKeyReturnsCorrectPKType" returntype="void">
			<cfscript>
			var obj = getGateway();
			obj.setup();
			if (obj.getIsComposite()) {
				assertTrue(IsArray(obj.getPrimaryKey()));
			} else {
				assertTrue(IsSimpleValue(obj.getPrimaryKey()));
			}
			debug(obj.getPrimaryKey());
			</cfscript>
		</cffunction>
	
		<cffunction name="createKeyThrowsErrorFromBadInput" returntype="void" hint="tests error path">		
			
			<cftry>			
				<!--- do something here to cause an error --->
				<cfset getGateway().createKey(structNew())>
		
				<cfset fail("create should throw an error.")>
			<cfcatch type="mxunit.exception.AssertionFailedError">
				<cfrethrow>
			</cfcatch>
			<cfcatch type="any"></cfcatch>
			</cftry>
		</cffunction>
	
		
	
	<!--- End Specific Test Cases --->
	
	<!--- private --->
	
	<cffunction name="getGateway" access="private" output="false" returntype="any">
		<cfreturn variables.Gateway>
	</cffunction>
	</cfcomponent>
