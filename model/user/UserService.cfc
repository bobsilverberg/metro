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
<cfcomponent displayname="UserService" extends="metro.core.Service" output="false" hint="I am the concrete Metro User Service.">
	
	<cffunction name="isUniqueUserEmail" hint="returns boolean for email unique to user provided" returntype="boolean" output="false" access="public">
		<cfargument name="user" hint="the user to check" required="yes" type="any" />

		<cfscript>
			var rtn = true;
			var temp = getByProperty(objectName: "User", property: "Email", value: user.getEmail());
			if ((temp.getIsPersisted()) && (user.getId() != temp.getId())) {
				rtn = false;
			}
			return rtn;
		</cfscript>
	</cffunction>

	<cffunction name="removeRolePermission" hint="Removes permission from all roles." returntype="void" output="false" access="public">
		<cfargument name="permission" hint="The permission to remove" required="yes" type="any" />
		
		<cfscript>
			var roleList = getGateway(objectName: "Role").list();
			var i = 0;
			var role = "";
			for (i=1; i<=roleList.recordcount; i++) {
				role = get(objectName: "Role", key: roleList["id"][i]);
				if (role.containsPermission(permission)) {
					role.removePermission(permission);
				}				
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>