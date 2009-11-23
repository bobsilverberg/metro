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
<cfcomponent displayname="TransientFactoryTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
		var csPath = '/metro/tests/config/beans.xml';
		var params = Structnew();
		params.datasourcePath = '/metro/tests/config/Datasource.xml';		
		params.transferConfigPath = '/metro/tests/config/Transfer.xml';		
		params.definitionsPath = '/metro/config/definitions';
		setBeanFactory(coldspringXML: csPath, params: params);
		variables.TransientFactory = getBeanFactory().getBean("TransientFactory");
		</cfscript>
	</cffunction>
	

	<cffunction name="tearDown" access="public" returntype="void">
	<!--- Place tearDown/clean up code here --->
	</cffunction>

	<!--- Begin Specific Test Cases --->
	
	<cffunction name="createResultReturnsResult" access="public" returntype="void">
		<cfscript>
		var result = variables.TransientFactory.create("Result");
		assertTrue(GetMetadata(result).name is "metro.transient.Result");
		</cfscript>
	</cffunction>
	
	<cffunction name="newTimerReturnsTimer" access="public" returntype="void">
		<cfscript>
		var timer = variables.TransientFactory.newTimer();
		assertTrue(GetMetadata(timer).name eq "metro.transient.Timer");
		</cfscript>
	</cffunction>
	
	<cffunction name="newTimerHasZeroDuration" access="public" returntype="void">
		<cfscript>
		var timer = variables.TransientFactory.newTimer();
		assertTrue(timer.duration() eq 0);
		</cfscript>
	</cffunction>
	
	<cffunction name="getClassesReturnsStruct" access="public" returntype="void">
		<cfscript>
		assertTrue(isStruct(variables.TransientFactory.getClasses()));
		</cfscript>
	</cffunction>
	
	<!--- End Specific Test Cases --->

</cfcomponent>