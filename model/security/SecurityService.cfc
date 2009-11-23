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
<cfcomponent displayname="SecurityService" extends="metro.core.Service" output="false" hint="I am the concrete Metro Security Service.">
	
	<cffunction name="getCurrentUser" access="public" output="false" returntype="any" hint="I return a User object.  Either by Id in Session or a new user.">
		<cfif userInSession()>
			<cfreturn getUserService().get("User",getUserSession())>
		<cfelse>
			<cfreturn getUserService().new("User")>
		</cfif>
	</cffunction>

	<cffunction name="userInSession" access="public" output="false" returntype="boolean" hint="I return boolean result of whether a UserId is in Session scope or not.">
		<cflock scope="Session" type="readonly" timeout="20">
			<cfreturn StructKeyExists(session,"userId")>
		</cflock>
	</cffunction>

	<cffunction name="setUserSession" access="public" output="false" returntype="void" hint="I set the UserId in Session.">
		<cfargument name="UserId" type="numeric" required="true" hint="The UserId.">		
		<cflock scope="Session" type="exclusive" timeout="20">
			<cfset session.UserId = arguments.UserId>
		</cflock>
	</cffunction>

	<cffunction name="getUserSession" access="public" output="false" returntype="any">
		<cflock scope="Session" type="readonly" timeout="20">
			<cfreturn session.UserId />
		</cflock>
	</cffunction>

	<cffunction name="endUserSession" access="public" output="false" returntype="boolean" hint="I return a boolean result of whether a userId was removed from session scope.">
		<cfset var ended = false>
		<cfif userInSession()>
			<cflock scope="Session" type="exclusive" timeout="20">
				<cfset ended = StructDelete(session,"UserId")>
			</cflock>
		</cfif>
		<cfreturn ended>
	</cffunction>
	
	<cffunction name="loginUser" access="public" output="false" returntype="any" hint="I return a result for a User login attempt and set the user session if successful.">
		<cfargument name="Username" hint="The Username property" required="yes" type="string" />
		<cfargument name="Password" hint="The password property" required="yes" type="string" />
		<cfset var user = getUserService().newUser()>
		<cfset user.login(argumentCollection: arguments)>
		<cfreturn user>
	</cffunction>
	
	<cffunction name="logoutUser" access="public" output="false" returntype="boolean" hint="I return a boolean result of whether a userId was removed from session scope.">
		<cfset var ended = false>
		<cfif userInSession()>
			<cflock scope="Session" type="exclusive" timeout="20">
				<cfset ended = StructDelete(session,"UserId")>
			</cflock>
		</cfif>
		<cfreturn ended>
	</cffunction>
	
	<!--- dependency --->
	
	<cffunction name="setUserService" access="public" returntype="void" output="false" hint="I set the UserService property.">
		<cfargument name="UserService" type="any" required="true">
		<cfset variables.UserService = arguments.UserService >
	</cffunction>
	
	<cffunction name="getUserService" access="public" returntype="any" output="false" hint="I return the UserService property.">
		<cfreturn variables.UserService />
	</cffunction>
	
</cfcomponent>