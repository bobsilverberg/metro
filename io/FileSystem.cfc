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
<cfcomponent displayname="FileSystem" output="false" hint="I am a simple file system object.">

	<cffunction name="init" access="public" output="false" returntype="metro.io.FileSystem" hint="I return the FileSystem object.">
		<cfset variables.cache = StructNew()>
		<cfreturn this>
	</cffunction>

	<cffunction name="listFilesFromDir" access="public" output="false" returntype="string" hint="I return a list files for a given path.">
		<cfargument name="dirPath" type="string" required="true">
		<cfset var dirQuery = "">
		<cfdirectory directory="#expandPath(arguments.dirPath)#" name="dirQuery" action="list" type="file" />
		<cfreturn ValueList(dirQuery.name)>
	</cffunction>

	<cffunction name="pathExists" access="public" output="false" returntype="boolean" hint="I return a boolean flag of whether a relative path exists or not.">
		<cfargument name="dirPath" type="string" required="true">
		<cfset var dir = expandpath(arguments.dirPath)>
		<cfreturn DirectoryExists(dir)>
	</cffunction>

</cfcomponent>