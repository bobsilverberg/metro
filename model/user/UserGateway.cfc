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
<cfcomponent displayname="UserGateway" objectName="User" extends="metro.core.Gateway" output="false" hint="I am a concrete Gateway example.">

	<cffunction name="loginUser" access="public" returntype="any" output="false" hint="I return a User object after trying to retrieve it by login credentials.">
		<cfargument name="user" type="any" required="true" hint="The user object to verify login for.">
		<cfreturn getByPropertyMap(propertyMap=arguments.user.getCredentials())>
	</cffunction>

</cfcomponent>