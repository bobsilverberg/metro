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
<cfcomponent displayname="EmployeeServiceTest"  extends="metro.tests.BaseTestCase">
	
	<cfset variables.empArgs = StructNew() />

	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
		var csPath = '/metro/tests/config/beans.xml';
		var params = Structnew();
		params.datasourcePath = '/metro/tests/config/Datasource.xml';		
		params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
		params.definitionsPath = '/metro/config/definitions';
		setBeanFactory(coldspringXML: csPath, params: params);
		variables.WorkService = getBeanFactory().getBean("WorkService");
		createEmployee("Developer");
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
		<cfset deleteEmployee() />
	</cffunction>

	<!--- private --->

	<cffunction name="createEmployee" access="private" returntype="void">
		<cfargument name="EmployeeType" type="Any" required="true" />
		<cfscript>
			var employee = "";
			var result = "";
			empArgs.UserName = "tester";
			empArgs.FirstName = "Test";
			empArgs.LastName = "Account";
			empArgs.EmployeeTypeId = 1;
			empArgs.DepartmentId = 1;
			result = variables.WorkService.saveEmployee(argumentCollection=empArgs);
		</cfscript>
		
	</cffunction>

	<cffunction name="deleteEmployee" access="private" returntype="void">
		<cfscript>
			variables.WorkService.deleteEmployee(empArgs);
			debug(empArgs);
		</cfscript>
	</cffunction>


<!--- Begin Specific Test Cases --->
	
	<cffunction name="getEmployeeReturnsPersistedEmployee" access="public" returntype="void">
		<cfscript>
			var employee = variables.WorkService.getEmployee(empArgs);
			assertTrue(employee.getIsPersisted());
		</cfscript>
	</cffunction>
	
	<cffunction name="newEmployeeReturnsUnpersistedEmployee" access="public" returntype="void">
		<cfscript>
			var employee = variables.WorkService.newEmployee();
			assertFalse(employee.getIsPersisted());
		</cfscript>
	</cffunction>

	<cffunction name="listEmployeeReutrnsQueryWithOneRecord" access="public" returntype="void">
		<cfscript>
		var employeeList = variables.WorkService.listEmployee();
		assertTrue(isQuery(employeeList));
		assertTrue(employeeList.recordcount eq 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="listEmployeeTypeReutrnsQueryWithThreeRecords" access="public" returntype="void">
		<cfscript>
		var list = variables.WorkService.listEmployeeType();
		assertTrue(isQuery(list));
		assertTrue(list.recordcount eq 3);
		</cfscript>
	</cffunction>
		
	<cffunction name="listEmployeeTypeReutrnsQueryWithOneRecord" access="public" returntype="void">
		<cfscript>
		var list = variables.WorkService.listEmployeeType(Name="Manager");
		assertTrue(isQuery(list));
		assertTrue(list.recordcount eq 1);
		</cfscript>
	</cffunction>
	
</cfcomponent>