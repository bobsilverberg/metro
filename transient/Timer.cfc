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
<cfcomponent displayname="Timer" hint="I provide methods for timing an event.">

	<cffunction name="init" access="public" output="false" returntype="any" hint="I return the timer.">
		<cfreturn this />
	</cffunction>

	<cffunction name="setup" access="public" output="false" returntype="void" hint="I set the started and stopped proerty to the same timestamp.">
		<cfset var tick = getTickCount()>
		<cfset variables.started = tick>
		<cfset variables.stopped = tick>
	</cffunction>

	<cffunction name="start" access="public" output="false" returntype="void" hint="I set the start time.">
		<cfset variables.started = getTickCount()>
	</cffunction>

	<cffunction name="stop" access="public" output="false" returntype="void" hint="I set the stop time.">
		<cfset variables.stopped = getTickCount()>
	</cffunction>

	<cffunction name="duration" access="public" output="false" returntype="numeric" hint="I return the duration in milliseconds between start() and stop().">
		<cfreturn (variables.stopped - variables.started)>
	</cffunction>

</cfcomponent>