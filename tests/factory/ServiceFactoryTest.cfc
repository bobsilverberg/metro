<!--- 
	Copyright 2008 Paul Marcotte
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

 --->
<cfcomponent displayname="SecurityServiceTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
		var csPath = '/metro/tests/config/beans.xml';
		var params = Structnew();
		params.datasourcePath = '/metro/tests/config/Datasource.xml';		
		params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
		params.definitionsPath = '/metro/config/definitions';
		setBeanFactory(coldspringXML: csPath, params: params);
		variables.ServiceFactory = getBeanFactory().getBean("ServiceFactory");
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
	</cffunction>

	<!--- private --->

	<!--- Begin Specific Test Cases --->
	
	<cffunction name="getPackageInfoReturnsStruct" access="public" returntype="void">
		<cfscript>
		var rtn = variables.ServiceFactory.getPackageInfo("security");
		debug(rtn);
		assertTrue(IsStruct(rtn));
		</cfscript>
	</cffunction>
	
	<cffunction name="getWorkServiceReturnsCoreComponent" access="public" returntype="void">
		<cfscript>
		var testService = variables.ServiceFactory.getService("work");
		assertTrue(GetMetadata(testService).name is "metro.core.Service");
		</cfscript>
	</cffunction>
	
	<cffunction name="getSecurityServiceReturnsSecurityService" access="public" returntype="void">
		<cfscript>
		var testService = variables.ServiceFactory.getService("security");
		assertTrue(GetMetadata(testService).name is "metro.model.security.SecurityService");
		</cfscript>
	</cffunction>
	
	<cffunction name="getUserServiceReturnsUserService" access="public" returntype="void">
		<cfscript>
		var testService = variables.ServiceFactory.getService("user");
		debug(GetMetadata(testService).name);
		assertTrue(GetMetadata(testService).name is "metro.model.user.UserService");
		</cfscript>
	</cffunction>
	
	<cffunction name="getServiceReturnsCoreComponents" access="public" returntype="void">
		<cfscript>
		var testService = variables.ServiceFactory.getService("test");
		var testGateway = testService.getGateway("Test");
		assertTrue(GetMetadata(testService).name is "metro.core.Service");
		assertTrue(GetMetadata(testGateway).name is "metro.core.Gateway");
		assertTrue(testGateway.getClassName() is "test.Test");
		</cfscript>
	</cffunction>

	<cffunction name="getServiceThrowsErrorForBogusPackage"  returntype="void" hint="tests error path">		
		<cfset var rtn = "">
		<cftry>			
			<!--- do something here to cause an error --->
			<cfset rtn = variables.ServiceFactory.getService("bogus")>
			<cfset fail("did not throw expected error")>
		<cfcatch type="mxunit.exception.AssertionFailedError">
			<cfrethrow>
		</cfcatch>
		<cfcatch type="any"></cfcatch>
		</cftry>
	</cffunction>
	
	<!--- End Specific Test Cases --->

</cfcomponent>