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
<cfcomponent displayname="MetadataInspector" output="false" hint="I provide methods to recursively inspect ColdFusion metadata.">

	<cffunction name="init" access="public" returntype="metro.util.MetadataInspector" output="false" hint="I return the MetadataInspector.">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="inheritsFrom" access="public" output="false" returntype="boolean" hint="I return a boolean result of whether the component metadata extends the given class recursively.">
		<cfargument name="metadata" type="struct" required="true" hint="The component metadata.">
		<cfargument name="classPath" type="string" required="true" hint="The class that it should extend.">
		<cfset var result = false>
		<cfif structkeyexists(arguments.metadata,"extends")>
			<cfif arguments.metadata.extends.name is arguments.classPath>
				<cfset result = true>
			<cfelse>
				<cfset result = inheritsFrom(arguments.metadata.extends,arguments.classPath)>
			</cfif>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="hasPublicMethod" access="public" output="false" returntype="boolean" hint="I return a boolean result of whether the component metadata extends the given class recursively.">
		<cfargument name="metadata" type="struct" required="true" hint="The component metadata.">
		<cfargument name="methodName" type="string" required="true" hint="The class that it should extend.">
		<cfset var result = false>
		<cfset var i = 0>
		<cfif structkeyexists(arguments.metadata,"functions")>
			<cfloop from="1" to="#arraylen(arguments.metadata.functions)#" index="i">
				<cfif (arguments.metadata.functions[i].access is "public") and (arguments.metadata.functions[i].name is arguments.methodName)>
					<cfreturn true>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfif structkeyexists(arguments.metadata,"extends")>
			<cfset result = hasPublicMethod(arguments.metadata.extends,arguments.methodName)>
		</cfif>				
		<cfreturn result>
	</cffunction>

</cfcomponent>