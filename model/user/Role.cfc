<!--- 
	Copyright 2009 Paul Marcotte
	
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
<cfcomponent displayname="Role" extends="metro.core.Decorator" output="false" hint="I am the Role object decorator.">

	<!--- public --->

	<!--- BEGIN setPermissions() method --->
	<cffunction name="setPermissions" hint="Clears current permissions and adds new ones from list." returntype="void" output="false" access="public">
		<cfargument name="permissions" hint="A comma separated list of permission ids." required="yes" type="string" />
		
		<cfscript>
			var i = 1;
			var permArray = ListToArray(permissions);
			clearPermission();
			for (i = 1; i <= ArrayLen(permArray); i++) {
				addPermission(getUserService().getPermission(permArray[i]));
			}
		</cfscript>
	</cffunction>
	<!--- END setPermissions() method --->

	<!--- BEGIN delete() method --->
	<cffunction name="delete" hint="Deletes the current instance" returntype="void" output="false" access="public">
		
		<cfscript>
			getGateway().delete(this);
		</cfscript>
	</cffunction>
	<!--- END delete() method --->
	
	<!--- BEGIN hasPermission() method --->
	<cffunction name="hasPermission" hint="Returns boolean for existance of Permission by id" returntype="boolean" output="false" access="public">
		<cfargument name="name" hint="The permission name" required="yes" type="string" />
		
		<cfscript>
			var rtn = false;
			var perms = getPermissionArray();
			var i = 0;
			for (i = 1; i <=ArrayLen(perms); i++) {
				if (perms[i].getName() IS name) {
					rtn = true;
				}
			}
			return rtn;
		</cfscript>
	</cffunction>
	<!--- END hasPermission() method --->

	<!--- BEGIN getUserService() method --->
	<cffunction name="getUserService" hint="Retrieves the UserService property" returntype="any" output="false" access="public">
		<cfreturn variables.properties.UserService />
	</cffunction>
	<!--- END getUserService() method --->
	
	<!--- BEGIN setUserService() method --->
	<cffunction name="setUserService" hint="Sets the UserService property" returntype="void" output="false" access="public">
		<cfargument name="UserService" hint="The UserService property" required="yes" type="any" />
		
		<cfset variables.properties.UserService = arguments.UserService />
	</cffunction>
	<!--- END setUserService() method --->
	
	<!--- private --->
	
	<cffunction name="loadRules" access="private" output="false" returntype="void" hint="I set metadata rules and contexts for validation.">
		
		<cfscript>
			
			addRule(property: "Name",
					label: "Name",
					testtype: "string",
					contexts: "edit,new",
					low: 1,
					high: 50);
			
			addRule(property: "Description",
					label: "Description",
					testtype: "string",
					contexts: "edit,new",
					low: 1,
					high: 50);
		</cfscript>		
	</cffunction>
	
</cfcomponent>
