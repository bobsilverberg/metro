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
<cfcomponent displayname="Permission" extends="metro.core.Decorator" output="false" hint="I am the Permission object decorator.">

	<!--- public --->

	<cffunction name="delete" hint="Deletes the current instance" returntype="void" output="false" access="public">
		
		<cfscript>
			getUserService().removeRolePermission(this);
			getGateway().delete(this);
		</cfscript>
	</cffunction>
	
	<!--- dependencies --->
	
	<cffunction name="getUserService" hint="Retrieves the UserService property" returntype="any" output="false" access="public">
		<cfreturn variables.properties.UserService />
	</cffunction>
	
	<cffunction name="setUserService" hint="Sets the UserService property" returntype="void" output="false" access="public">
		<cfargument name="UserService" hint="The UserService property" required="yes" type="any" />
		
		<cfset variables.properties.UserService = arguments.UserService />
	</cffunction>

	<!--- private --->
	
	<cffunction name="loadRules" access="private" output="false" returntype="void" hint="I set metadata rules and contexts for validation.">
		
		<cfscript>
			addRule(property: "Name",
					label: "Name",
					testtype: "string",
					contexts: "edit,new",
					low: 1,
					high: 50
			);
			addRule(property: "Description",
					label: "Description",
					testtype: "string",
					contexts: "edit,new",
					low: 1,
					high: 50
			);
		</cfscript>
	</cffunction>
	
</cfcomponent>
