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
<cfcomponent displayname="metro.tests.security.UserTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
		var csPath = '/metro/tests/config/beans.xml';
		var params = Structnew();
		params.datasourcePath = '/metro/tests/config/Datasource.xml';		
		params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
		params.definitionsPath = '/metro/config/definitions';
		setBeanFactory(coldspringXML: csPath, params: params);
		variables.properties.Transfer = getBeanFactory().getBean("transfer");
		</cfscript>
	</cffunction>


<!--- Begin Specific Test Cases --->
	
	<cffunction name="getValidatorReturnsValidator" access="public" returntype="void">
		<cfscript>
		var user = getBeanFactory().getBean("transfer").new("user.User");
		var validator = user.getValidator();
		assertTrue(getmetadata(validator).name eq "metro.transient.Validator");
		</cfscript>
	</cffunction>
	
	<cffunction name="userMetadataNameReturnsDecoratorName" access="public" returntype="void">
		<cfscript>
		var user = getBeanFactory().getBean("transfer").new("user.User");
		assertTrue(getmetadata(user).name eq "metro.model.user.User");
		</cfscript>
	</cffunction>
	
	<cffunction name="userPkNameisString" access="public" returntype="void">
		<cfscript>
		var transfer = getBeanFactory().getBean("transfer");
		var user = transfer.new("user.User");
		var pk = transfer.getTransferMetadata(user.getClassName()).getPrimaryKey();
		debug(pk.getIsComposite());
		assertTrue(user.getClassName() eq "user.User");
		</cfscript>
	</cffunction>
	
	<cffunction name="validateReturnsTrueForGoodData" hint="test validate behaviour" returntype="void" output="false" access="public">
		
		<cfscript>
			var user = getTranser().new("user.User");
			var args = structnew();
			args.Username = "foobar";
			args.Password = "barfoo";
			user.populate(args: args);
			assertTrue(user.validate(context: "login"));
		</cfscript>
	</cffunction>
	
	<cffunction name="validaterReturnsFalseForBadData" hint="test validate for bad data" returntype="void" output="false" access="public">
		
		<cfscript>
			var user = getTranser().new("user.User");
			var args = structnew();
			args.Username = "foo";
			args.Password = "bar";
			user.populate(args: args);
			assertFalse(user.validate(context: "login"));
			debug(user.getErrors());
		</cfscript>
	</cffunction>
	
	<cffunction name="hasRoleReturnsFalseForNewUser" hint="test validate for bad data" returntype="void" output="false" access="public">
		
		<cfscript>
			var user = getTranser().new("user.User");
			assertFalse(user.hasRole());
		</cfscript>
	</cffunction>
	
	<cffunction name="getRoleIdReturnsZeroForNewUser" hint="test validate for bad data" returntype="void" output="false" access="public">
		
		<cfscript>
			var user = getTranser().new("user.User");
			assertTrue(user.getRoleId() eq 0);
		</cfscript>
	</cffunction>
	
	<cffunction name="getGatewayReturnsUserGateway" hint="test validate for bad data" returntype="void" output="false" access="public">
		
		<cfscript>
			var user = getTranser().new("user.User");
			makePublic(user,"getGateway");
			assertTrue(getmetadata(user.getGateway()).name IS "metro.model.user.UserGateway");
		</cfscript>
	</cffunction>
	
<!--- End Specific Test Cases --->

	<cffunction name="getTranser" hint="Returns transfer" returntype="any" output="false" access="private">
		<cfreturn variables.properties.Transfer>
	</cffunction>

</cfcomponent>