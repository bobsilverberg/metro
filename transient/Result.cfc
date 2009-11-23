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
<cfcomponent displayname="Result" output="false" hint="I am a simple result object returned by service method invocation.">

	<cffunction name="init" access="public" output="false" returntype="any" hint="I return the result object.">
		<cfset variables.result = "">
		<cfset variables.errors = ArrayNew(1)>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setErrors" access="public" returntype="void" output="false" hint="I set the result errors.">
		<cfargument name="errors" type="array" required="true" hint="The errors as a map of key/value pair.">
		<cfset variables.errors = arguments.errors >
	</cffunction>
	
	<cffunction name="getErrors" access="public" returntype="struct" output="false" hint="I return the result errors.">
		<cfreturn variables.errors />
	</cffunction>

	<cffunction name="setResult" access="public" returntype="void" output="false" hint="I set the result subject usually a business object.">
		<cfargument name="result" type="any" required="true" hint="The result subject.">
		<cfset variables.result = arguments.result >
	</cffunction>
	
	<cffunction name="getResult" access="public" returntype="any" output="false" hint="I return the result subject.">
		<cfreturn variables.result />
	</cffunction>

	<cffunction name="getSuccess" access="public" output="false" returntype="boolean" hint="I return a boolean result of whether the result contains no errors.">
		<cfset var success = true>
		<cfif ArrayLen(variables.errors) gt 0>
			<cfset success = false>
		</cfif>
		<cfreturn success>
	</cffunction>

</cfcomponent>