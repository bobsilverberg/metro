<cfcomponent displayname="CacheTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
		var csPath = '/metro/tests/config/beans.xml';
		var params = Structnew();
		params.datasourcePath = '/metro/tests/config/Datasource.xml';		
		params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
		params.definitionsPath = '/metro/config/definitions';
		setBeanFactory(coldspringXML: csPath, params: params);
		variables.Cache = getBeanFactory().getBean("TransientFactory").newCache(cacheMinutes=60,hashKeys=true);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
	 <!--- Place tearDown/clean up code here --->
	</cffunction>

<!--- Begin Specific Test Cases --->
	
	<cffunction name="getTimeoutGreaterThanNow" access="public" returntype="void">
		<cfscript>
		var string1 = "Hello World!";
		variables.Cache.put("string1",string1);
		assertTrue(variables.Cache.getTimeout("string1") gt now());
		</cfscript>
	</cffunction>
	
	<cffunction name="getCacheMinutesEqualsConfigSetting" access="public" returntype="void">
		<cfscript>
		assertTrue(variables.Cache.getCacheMinutes() eq 60);
		</cfscript>
	</cffunction>
	
	<cffunction name="getCacheReturnsStruct" access="public" returntype="void">
		<cfscript>
		assertTrue(isStruct(variables.Cache.getCache()));
		</cfscript>
	</cffunction>
	
	<cffunction name="putReturnsTrue" access="public" returntype="void">
		<cfscript>
		var myString = "Hello World!";
		assertTrue(variables.Cache.put("myString",myString));
		</cfscript>
	</cffunction>
	
	<cffunction name="existsReturnsTrueWhenItemInCache" access="public" returntype="void">
		<cfscript>
		var myString = "Hello World!";
		variables.Cache.put("myString",myString);
		assertTrue(variables.Cache.exists("myString"));
		</cfscript>
	</cffunction>
	
	<cffunction name="existsReturnsFalseWhenItemNotInCache" access="public" returntype="void">
		<cfscript>
		assertFalse(variables.Cache.exists("myString"));
		</cfscript>
	</cffunction>
	
	<cffunction name="removeReturnsTrueWhenItemInCache" access="public" returntype="void">
		<cfscript>
		var myString = "Hello World!";
		variables.Cache.put("myString",myString);
		assertTrue(variables.Cache.remove("myString"));
		</cfscript>
	</cffunction>
	
	<cffunction name="testGetValue" access="public" returntype="void">
		<cfscript>
		var myString = "Hello World!";
		variables.Cache.put("myString",myString);
		assertTrue(myString is variables.Cache.getValue("myString"));
		</cfscript>
	</cffunction>
	
	<cffunction name="testPurge" access="public" returntype="void">
		<cfscript>
		var myString = "Hello World!";
		variables.Cache.put("myString",myString);
		variables.Cache.purge();
		assertTrue(structCount(variables.Cache.getCache()) eq 0);
		</cfscript>
	</cffunction>
	

<!--- End Specific Test Cases --->

</cfcomponent>