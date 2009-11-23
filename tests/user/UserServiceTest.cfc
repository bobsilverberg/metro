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
		variables.UserService = getBeanFactory().getBean("UserService");
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
			var user = "";
			var args = structNew();
			args.Id = 0;
			args.RoleId = 1;
			args.FirstName = "Test";
			args.LastName = "Account";
			args.Username = "tester";
			args.Password = "tester";
			args.ConfirmPassword = "tester";
			args.Email = "paul@fancybread.com";
			user = variables.UserService.createUser(argumentCollection=args);
			this.userId = user.getId();
			debug(this.userId);
		</cfscript>
		
	</cffunction>

	<cffunction name="deleteUser" access="private" returntype="void">
		<cfscript>
			variables.UserService.deleteUser(this.userId);
		</cfscript>
	</cffunction>


<!--- Begin Specific Test Cases --->
	
	<cffunction name="getUserReturnsPersistedUser" access="public" returntype="void">
		<cfscript>
		var user = variables.UserService.getUser(this.userId);
		assertTrue(user.getIsPersisted());
		</cfscript>
	</cffunction>
	
	<cffunction name="newUserReturnsUnpersistedUser" access="public" returntype="void">
		<cfscript>
		var user = variables.UserService.newUser();
		assertFalse(user.getIsPersisted());
		</cfscript>
	</cffunction>

	<cffunction name="listUserReutrnsQueryWithOneRecord" access="public" returntype="void">
		<cfscript>
		var userList = variables.UserService.listUser();
		assertTrue(isQuery(userList));
		assertTrue(userList.recordcount eq 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="listRoleReutrnsQueryWithFourRecords" access="public" returntype="void">
		<cfscript>
		var list = variables.UserService.listRole();
		assertTrue(isQuery(list));
		assertTrue(list.recordcount eq 4);
		</cfscript>
	</cffunction>
		
	<cffunction name="listRoleReutrnsQueryWithOneRecord" access="public" returntype="void">
		<cfscript>
		var list = variables.UserService.listRole(Name="Master");
		assertTrue(isQuery(list));
		assertTrue(list.recordcount eq 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="listPermissionReutrnsQuery" access="public" returntype="void">
		<cfscript>
		var list = variables.UserService.listPermission();
		assertTrue(isQuery(list));
		debug(list);
		</cfscript>
	</cffunction>
	
	<cffunction name="isUniqueUserEmailReturnsTrueForUnique" returntype="void" hint="">
		
		<cfscript>
		var user = variables.UserService.getUser(this.userId);
		assertTrue(variables.UserService.isUniqueUserEmail(user));
		</cfscript>
	</cffunction>
	
	<cffunction name="removeRolePermissionRemovesPermissionFromAllRoles" returntype="void" hint="">
		
		<cfscript>
		var role = variables.UserService.getByProperty("Role","Name","Guest");
		var perm = "";
		var args = {Id=0, Name="foo", Description="bar"};
		assertTrue(role.getIsPersisted());
		perm = variables.UserService.createPermission(argumentCollection: args);
		assertFalse(perm.hasErrors());
		role.addPermission(perm);
		assertTrue(role.containsPermission(perm));
		variables.UserService.removeRolePermission(perm);
		assertFalse(role.containsPermission(perm));
		perm.delete();
		</cfscript>
	</cffunction>
	<!--- 
	<cffunction name="reapByKeyDoesNotRemoveItemFromTransferCacheForWrongKey" access="public" returntype="void">
		<cfscript>
		var role = variables.UserService.getRole(1);
		assertTrue(getBeanFactory().getBean("transfer").getCacheMonitor().getCalculatedSize("user.Role") eq 1);
		variables.UserService.reap("Role",2);
		assertTrue(getBeanFactory().getBean("transfer").getCacheMonitor().getCalculatedSize("user.Role") eq 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="reapByKeyRemovesItemFromTransferCache" access="public" returntype="void">
		<cfscript>
		var role = variables.UserService.get("Role",1);
		assertTrue(getBeanFactory().getBean("transfer").getCacheMonitor().getCalculatedSize("user.Role") eq 1);
		variables.UserService.reap("Role",1);
		//assertTrue(getBeanFactory().getBean("transfer").getCacheMonitor().getCalculatedSize("user.Role") eq 0);
		</cfscript>
	</cffunction>
	 --->
<!--- End Specific Test Cases --->



</cfcomponent>