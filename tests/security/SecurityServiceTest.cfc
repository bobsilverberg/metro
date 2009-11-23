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
		variables.SecurityService = getBeanFactory().getBean("SecurityService");
		this.userId = 0;
		createUser();
		</cfscript>
	</cffunction>
 
	<cffunction name="tearDown" access="public" returntype="void">
		<cfset deleteUser()>
	</cffunction>

	<!--- private --->

	<cffunction name="createUser" access="private" returntype="void">
		<cfscript>
			var userService = getBeanFactory().getBean("UserService");
			var args = structNew();
			var user = "";
			args.Id = 0;
			args.RoleId = 1;
			args.FirstName = "Test";
			args.LastName = "Account";
			args.Username = "tester";
			args.Password = "tester";
			args.ConfirmPassword = "tester";
			args.Email = "paul@fancybread.com";
			args.IsEnabled = true;
			args.IsDeleted = false;
			user = userService.createUser(argumentCollection: args);
			this.userId = user.getId();
			debug(this.userId);
		</cfscript>
		
	</cffunction>

	<cffunction name="deleteUser" access="private" returntype="void">
		<cfscript>
			getBeanFactory().getBean("UserService").deleteUser(this.userId);
		</cfscript>
	</cffunction>


	<!--- Begin Specific Test Cases --->
	
	<cffunction name="loginUserReturnsFailureForBadCredentials" access="public" returntype="void">
		<cfscript>
		var user = getBeanFactory().getBean("UserService").newUser();
		var args = structnew();
		args.Username = "unknown";
		args.Password = "unknown";
		user.login(argumentCollection=args);
		assertFalse(user.login(argumentCollection=args));
		</cfscript>
	</cffunction>
	
	<cffunction name="loginUserReturnsSuccessForGoodCredentials" access="public" returntype="void">
		<cfscript>
		var user = "";
		var args = structnew();
		args.Username = "tester";
		args.Password = "tester";
		user = variables.SecurityService.loginUser(argumentCollection=args);
		debug(user.getErrors());
		assertFalse(user.hasErrors());
		assertTrue(variables.SecurityService.userInSession());
		assertTrue(user.logout());
		</cfscript>
	</cffunction>
	

<!--- End Specific Test Cases --->

</cfcomponent>