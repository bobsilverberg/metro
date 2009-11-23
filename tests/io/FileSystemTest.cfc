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
		
		variables.FileSystem = CreateObject("component","metro.io.FileSystem");
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
	</cffunction>

	<!--- private --->

	<!--- Begin Specific Test Cases --->
	
	<cffunction name="existsReturnsFalseForBogusPath" access="public" returntype="void">
		<cfscript>
		var path = "/bogus";
		assertFalse(variables.FileSystem.pathExists(path));
		</cfscript>
	</cffunction>

	<cffunction name="existsReturnsTrueForCorrectPath" access="public" returntype="void">
		<cfscript>
		var path = "/metro/model/security";
		assertTrue(variables.FileSystem.pathExists(path));
		</cfscript>
	</cffunction>

	<cffunction name="listFilesFromDirReturnsList" access="public" returntype="void">
		<cfscript>
		var list = variables.FileSystem.listFilesFromDir("/metro/employee");
		debug(list);
		assertTrue(isSimpleValue(list));
		</cfscript>
	</cffunction>
	

	
	<!--- End Specific Test Cases --->



</cfcomponent>