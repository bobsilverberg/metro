<cfsetting requesttimeout="300">

<cfparam name="url.output" default="html">
<cfparam name="url.debug" default="false">
<cfparam name="url.quiet" default="false">

<cfset dir = expandPath(".")>
<cfset DTS = createObject("component","mxunit.runner.DirectoryTestSuite")>

<cfset excludes = "">

<cfinvoke component="#DTS#" 
	method="run"
	directory="#dir#"
	componentpath="metro.tests" 
	recurse="true" 
	excludes="#excludes#"	
	returnvariable="Results">
	
<cfif not url.quiet>
	
	<cfif NOT StructIsEmpty(DTS.getCatastrophicErrors())>
		<cfdump var="#DTS.getCatastrophicErrors()#" expand="false" label="#StructCount(DTS.getCatastrophicErrors())# Catastrophic Errors">
	</cfif>
	
	<cfsetting showdebugoutput="true">
	<cfoutput>#results.getResultsOutput(url.output)#</cfoutput>
	
	<cfif isBoolean(url.debug) AND url.debug>
		<div class="bodypad">
			<cfdump var="#results.getResults()#" label="Debug">
		</div>
	</cfif>

</cfif>