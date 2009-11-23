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
<cfcomponent displayname="Employee" extends="metro.core.Decorator" output="false" hint="I am the Employee object decorator.">

	<cffunction name="loadRules" hint="Loads the object's validation rules" returntype="void" output="no" access="public">
		<cfscript>
			
		</cfscript>
	</cffunction>

	
	<cffunction name="setEmployeeTypeId" access="public" returntype="void" output="false" hint="I set the EmployeeType by EmployeeTypeId">
		<cfargument name="EmployeeTypeId" type="numeric" required="true" hint="The EmployeeTypeId.">
		<cfset setEmployeeType(getWorkService().getEmployeeType(arguments.EmployeeTypeId)) >
	</cffunction>
	
	<cffunction name="getEmployeeTypeId" access="public" returntype="numeric" output="false" hint=" I return the EmployeeTypeId from EmployeeType">
		<cfreturn getEmployeeType().getEmployeeTypeId() />
	</cffunction>
	
	<cffunction name="setDepartmentId" access="public" returntype="void" output="false" hint="I set the Department by DepartmentId">
		<cfargument name="DepartmentId" type="numeric" required="true" hint="The DepartmentId.">
		<cfset setParentDepartment(getWorkService().getDepartment(arguments.DepartmentId)) >
	</cffunction>
	
	<!--- TODO: This won't work --->
	<cffunction name="getDepartmentId" access="public" returntype="numeric" output="false" hint=" I return the DepartmentId from Department">
		<cfreturn getDepartment().getDepartmentId() />
	</cffunction>
	
	<!--- convenience methods --->
	<cffunction name="getFullName" access="public" output="false" returntype="string" hint="I return the full user name.">
		<cfreturn getFirstName() & " " & getLastName() />
	</cffunction>
	
	<!--- dependencies --->
	
	<cffunction name="setWorkService" access="public" returntype="void" output="false" hint="I set a reference to the WorkService.">
		<cfargument name="WorkService" type="any" required="true" hint="The WorkService object.">
		<cfset variables.WorkService = arguments.WorkService >
	</cffunction>
	 
	<cffunction name="getWorkService" access="public" returntype="any" output="false" hint="I return the WorkService.">
		<cfreturn variables.WorkService />
	</cffunction>
	
</cfcomponent>
