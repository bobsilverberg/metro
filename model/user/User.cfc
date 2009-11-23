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
<cfcomponent displayname="User" extends="metro.core.Decorator" output="false" hint="I am the User object decorator.">

	<!--- public --->

		<!--- BEGIN delete() method --->
	<cffunction name="delete" hint="Deletes the current instance" returntype="void" output="false" access="public">
		
		<cfscript>
			getGateway().delete(this);
		</cfscript>
	</cffunction>
	<!--- END delete() method --->
	


	<cffunction name="setRoleId" access="public" returntype="void" output="false" hint="I set the Role by RoleId">
		<cfargument name="RoleId" type="numeric" required="true" hint="The RoleId.">
		<cfset setRole(getUserService().getRole(arguments.RoleId)) >
	</cffunction>
	
	<cffunction name="getRoleId" access="public" returntype="numeric" output="false" hint=" I return the RoleId from Role">
		
		<cfscript>
			if (hasRole()) {
				return getRole().getId();
			} else {
				return 0;
			}
		</cfscript>
	</cffunction>
	
	<!--- 	methods to store and retrieve form input for password confirmation
			added to simplify the validation process --->
	<cffunction name="getConfirmPassword" access="public" output="false" returntype="string" hint="I return the ConfirmPassword property.">
		<cfreturn variables.properties.ConfirmPassword>
	</cffunction>
	
	<cffunction name="setConfirmPassword" access="public" output="false" returntype="void" hint="I set the ConfirmPassword property.">
		<cfargument name="ConfirmPassword" type="string" required="true" hint="The ConfirmPassword property.">
		<cfset variables.properties.ConfirmPassword = hash(arguments.ConfirmPassword) />
	</cffunction>

	<!---	these methods are overridden in order to encrypt and decrypt the user
			password within the decorated transfer object --->
	<cffunction name="setPassword" access="public" output="false" returntype="void" hint="I override the TO method so the property is hashed prior to being set.">
		<cfargument name="Password" type="string" required="true" hint="The unhashed Password property.">
		<cfset var hashpass = "">
		<cfif Len(arguments.Password)>
			<cfset hashpass = hash(arguments.Password)>
		</cfif>
		<cfset getTransferObject().setPassword(hashpass) />
	</cffunction>
	

	<cffunction name="getFullName" access="public" output="false" returntype="string" hint="I return the full user name.">
		<cfreturn getFirstName() & " " & getLastName() />
	</cffunction>
	
	<cffunction name="getCredentials" access="public" output="false" returntype="struct" hint="I return the username and password as a struct.">
		<cfset var credentials = StructNew()>
		<cfset credentials.username = getUserName()>
		<cfset credentials.password = getPassword()>
		<cfreturn credentials>
	</cffunction>
	
	<cffunction name="hasPermission" access="public" output="false" returntype="boolean" hint="I return a boolean indicator of whether the user has the proper permission by name.">
		<cfargument name="permission" type="string" required="true" hint="The permission name.">
		<cfset var result = false>
		<cfset var permissions = "">
		<cfset var i = 0>
		<cfif hasRole()>
			<cfset permissions = getRole().getPermissionArray()>
			<cfloop from="1" to="#ArrayLen(permissions)#" index="i">
				<cfif ListFindNocase(arguments.permission,permissions[i].getName())>
					<cfset result = true>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="login" access="public" output="false" returntype="boolean">
		<cfargument name="Username" hint="The Username property" required="yes" type="string" />
		<cfargument name="Password" hint="The password property" required="yes" type="string" />
		<cfset var user = "">
		<cfif (populate(args: arguments)) and (validate(context: "login"))>
			<cfset user = getGateway().getByPropertyMap(propertyMap: getCredentials()).clone() />
			<cfif user.isLoginValid()>
				<cfset getSecurityService().setUserSession(user.getId())>
			<cfelse>
				<cfset addErrors(user.getErrors())>
			</cfif>
		</cfif>		
		<cfreturn not hasErrors()>
	</cffunction>
	
	<cffunction name="logout" access="public" output="false" returntype="boolean" hint="I return a boolean result of whether a userId was removed from session scope.">
		<cfreturn getSecurityService().endUserSession()>
	</cffunction>
	
	<cffunction name="isLoginValid" access="public" output="false" returntype="boolean">
		<cfif (not getIsPersisted())>
			<cfset addError(property: "login", message: "Invalid credentials.  Please try again.")>
		<cfelseif (not getIsEnabled())>		
			<cfset addError(property: "login", message: "User account is inactive. Please contact customer service.")>
		<cfelseif (getIsDeleted())>		
			<cfset addError(property: "login", message: "User account deleted. Please contact customer service.")>
		</cfif>
		<cfreturn not hasErrors()>
	</cffunction>
	
	<cffunction name="isLoggedIn" access="public" output="false" returntype="boolean">
		<cfreturn getSecurityService().getUserSession() eq getId()>
	</cffunction>
	
	<!--- dependencies --->
	
	<cffunction name="setUserService" access="public" returntype="void" output="false" hint="I set a reference to the UserService.">
		<cfargument name="UserService" type="any" required="true" hint="The UserService object.">
		<cfset variables.properties.UserService = arguments.UserService >
	</cffunction>
	 
	<cffunction name="getUserService" access="public" returntype="any" output="false" hint="I return the UserService.">
		<cfreturn variables.properties.UserService />
	</cffunction>	

	<cffunction name="getSecurityService" hint="Retrieves the SecurityService property" returntype="any" output="false" access="public">
		<cfreturn variables.properties.SecurityService />
	</cffunction>

	<cffunction name="setSecurityService" hint="Sets the SecurityService property" returntype="void" output="false" access="public">
		<cfargument name="SecurityService" hint="The SecurityService property" required="yes" type="any" />
		
		<cfset variables.properties.SecurityService = arguments.SecurityService />
	</cffunction>

	<!--- private --->
	
	<cffunction name="isUniqueEmail" hint="Returns a boolean indication of whether or not the EmailAddress is unique" returntype="boolean" output="no" access="public">
		<cfscript>
			return getUserService().isUniqueUserEmail(this);
		</cfscript>
	</cffunction>
	
	<cffunction name="configure" access="private" output="false" returntype="void" hint="I configure the transfer object.">
		
		<cfscript>
			// set a default value for non-persisted property
			variables.properties.ConfirmPassword = "";
		</cfscript>
	</cffunction>
	
	<cffunction name="loadRules" access="private" output="false" returntype="void" hint="I set metadata rules and contexts for validation.">
		
		<cfscript>
			addRule(property: "Role",
					testtype: "method",
					contexts: "save",
					method: "hasRole"
					);
			
			addRule(property: "FirstName",
					label: "First Name",
					testtype: "string",
					contexts: "edit,new",
					low: 1,
					high: 50);
			
			addRule(property: "LastName",
					label: "Last Name",
					testtype: "string",
					contexts: "edit,new",
					low: 2,
					high: 50);

			addRule(property: "Email",
					label: "Email Address",
					testtype: "email",
					contexts: "edit,new");

			addRule(property: "Email",
					label: "Email Address",
					testtype: "method", 
					method: "isUniqueEmail", 
					message: "The email address you have entered has already been registered.",
					contexts: "edit,new",
					low: 8,
					high: 50);
													
			addRule(property: "Username",
					label: "Username",
					testtype: "string",
					contexts: "edit,new,login",
					low: 6,
					high: 16);
													
			addRule(property: "Password",
					label: "Password",
					testtype: "string",
					contexts: "edit,new,login",
					low: 6,
					high: 32);	
			
			addRule(property: "ConfirmPassword",
					label: "Confirm Password",
					testtype: "isMatch",
					contexts: "new,changePassword",
					low: 6,
					high: 32,
					compareProperty: "Password");
		</cfscript>		
	</cffunction>
	
</cfcomponent>
