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
<cfcomponent displayname="Recordset" output="false" hint="I am a Recordset object.  Beans extend me to implement iterator methods.">
	
	<cfscript>
		variables.properties = {};
		variables.properties.records = [];		
		variables.properties.instance = {};
		variables.properties.currentRow = 1;
	</cfscript>
	
	<!--- public --->
	
	<cffunction name="init" access="public" output="false" returntype="metro.core.Recordset">
		<cfargument name="qry" type="query" required="true">
		<cfset loadQuery(qry)>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="currentRow" access="public" output="false" returntype="numeric">
    	<cfreturn variables.properties.currentRow />
    </cffunction>
	
	<cffunction name="next" access="public" output="false" returntype="boolean">
		<cfset var rtn = false>
		<cfif hasNext()>
			<cfset variables.properties.currentRow = currentRow() + 1 />
			<cfset variables.properties.instance = variables.properties.records[currentRow()] />
			<cfset rtn = true>
		</cfif>
		<cfreturn rtn />
	</cffunction>
	
	<cffunction name="previous" access="public" output="false" returntype="boolean">
		<cfset var rtn = false />
		<cfif hasPrevious()>
			<cfset variables.properties.currentRow = currentRow() - 1 />
			<cfset variables.instance = variables.properties.records[currentRow()] />
			<cfset rtn = true />
		</cfif>
		<cfreturn rtn />
	</cffunction>
	
	<cffunction name="reset" access="public" output="false" returntype="void">
		<cfset variables.properties.currentRow = 0 />
	</cffunction>

	<cffunction name="end" access="public" output="false" returntype="void">
		<cfset variables.properties.currentRow = ArrayLen(variables.properties.records) + 1 />
	</cffunction>
	
	<cffunction name="recordCount" access="public" output="false" returntype="numeric">
		<cfset var recordCount = 0 />
		<cfif structKeyExists(variables.properties,"records")>
			<cfset recordCount = ArrayLen(variables.properties.records) />
		</cfif>
		<cfreturn recordCount />
	</cffunction>
	
	<cffunction name="loadQuery" access="public" output="false" returntype="void">
		<cfargument name="qry" type="query" required="true">
		<cfset var i = 0 />
		<cfset var query = arguments.qry />
		<cfset variables.properties.records = [] />
		<cfloop index="i" from="1" to="#query.recordCount#">
			<cfset ArrayAppend(variables.properties.records,queryRowToStruct(query,i)) />
		</cfloop>
	</cffunction>
	
	<cffunction name="onMissingMethod" access="public" output="true" returntype="any" hint="I provide some syntactic sugar for invoking new, get, list, delete, and save without passing the object name as an argument.">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The missing method name.">
		<cfargument name="MissingMethodArguments" type="struct" required="true" hint="The missing method arguments.">
		<cfset var propName = getPropertyName(arguments.MissingMethodName,3)>
		<cfif REFind("^get",arguments.MissingMethodName)>
			<cfif arraylen(variables.properties.records) and structKeyExists(variables.properties.instance,propName)>
				<cfif structCount(missingMethodArguments) and (val(missingMethodArguments[1]) lte recordCount())>
					<cfreturn getTargetProperty(propName,val(missingMethodArguments[1]))>
				<cfelse>
					<cfreturn variables.properties.instance[propName]>
				</cfif>
			<cfelse>
				<cfthrow type="metro.core.Recordset" message="The property #propName# not found!">
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- BEGIN getTargetProperty() method --->
	<cffunction name="getTargetProperty" hint="returns the property form the specific index" returntype="any" output="false" access="public">
		<cfargument name="propName" type="string" required="true" hint="The property name.">
		<cfargument name="index" type="string" required="true" hint="The index.">
		<cfscript>
			var map = variables.properties.records[index];
			return map[propName];
		</cfscript>
	</cffunction>
	<!--- END getTargetProperty() method --->
			
	<!--- private --->
		
	<cffunction name="hasNext" access="private" output="false" returntype="boolean">
		<cfreturn (currentRow() lt recordCount()) />
	</cffunction>
	
	<cffunction name="hasPrevious" access="private" output="false" returntype="boolean">
		<cfreturn (currentRow() gt recordCount()) />
	</cffunction>
	
	<cffunction name="queryRowToStruct" access="private" output="false" returntype="struct">
		<cfargument name="qry" type="query" required="true">
		
		<cfscript>
			/**
			 * Makes a row of a query into a structure.
			 * 
			 * @param query 	 The query to work with. 
			 * @param row 	 Row number to check. Defaults to row 1. 
			 * @return Returns a structure. 
			 * @author Nathan Dintenfass (nathan@changemedia.com) 
			 * @version 1, December 11, 2001 
			 */
			//by default, do this to the first row of the query
			var row = 1;
			//a var for looping
			var ii = 1;
			//the cols to loop over
			var cols = listToArray(qry.columnList);
			//the struct to return
			var stReturn = structnew();
			//if there is a second argument, use that for the row number
			if(arrayLen(arguments) GT 1)
				row = arguments[2];
			//loop over the cols and build the struct from the query row
			for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
				stReturn[cols[ii]] = qry[cols[ii]][row];
			}		
			//return the struct
			return stReturn;
		</cfscript>
	</cffunction>
	
	<cffunction name="getPropertyName" access="private" output="false" returntype="string">
		<cfargument name="MethodName" type="string" required="true" hint="The missing method name.">
		<cfargument name="length" type="string" required="true" hint="The missing method name.">
		<cfreturn reReplace(arguments.MethodName,"\A[A-Za-z]{#arguments.length#}","")>
	</cffunction>
</cfcomponent>