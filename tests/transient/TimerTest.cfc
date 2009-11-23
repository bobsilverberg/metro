<cfcomponent displayname="tests.util.TimerTest"  extends="metro.tests.BaseTestCase">

	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
		variables.timer = createObject("component" ,"metro.transient.Timer");
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" access="public" returntype="void">
	 <!--- Place tearDown/clean up code here --->
	</cffunction>

<!--- Begin Specific Test Cases --->
	
	<cffunction name="testDurationIsNumeric" access="public" returntype="void">
		<cfscript>
		variables.timer.start();
		variables.timer.stop();
		assertTrue(isNumeric(variables.timer.duration()));
		</cfscript>
	</cffunction>

<!--- End Specific Test Cases --->

</cfcomponent>
