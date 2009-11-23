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
<cfcomponent displayname="TransferConfigReader" output="false" hint="I translate transfer xml to a collection for package names.">

	<cfset variables.packageMap = StructNew()>

	<cffunction name="init" access="public" output="false" returntype="any" hint="I return the TransferConfigReader.">
		<cfargument name="transferConfig" type="transfer.com.config.Configuration" required="true" hint="The Transfer configuration object.">
		<cfset readConfigXML(arguments.transferConfig.getConfigPath())>
		<cfreturn this>
	</cffunction>

	<cffunction name="getPackageMap" access="public" returntype="struct" output="false" hint="I return a struct a key for each package in teh transfer xml config.">
		<cfreturn variables.packageMap />
	</cffunction>

	<!--- private --->

	<cffunction name="readConfigXML" access="private" returntype="void" output="false" hint="I recursively set the package information from the transfer xml.">
		<cfargument name="transferConfigPath" type="string" required="true" hint="The path to the Transfer xml configuration file.">
		<cfset var xml = XMLParse(expandPath(arguments.transferConfigPath))>
		<cfset var includes = xmlSearch(xml, "//include/@path")>
		<cfset var i = 1>
		<cfset var len = ArrayLen(includes)>
		<cfset setPackageInfo(xml)>
		<cfloop from="1" to="#len#" index="i">
			<cfset readConfigXML(includes[i].XmlValue)>
		</cfloop>
	</cffunction>

	<cffunction name="setPackageInfo" access="private" returntype="void" output="false" hint="I add a key/value pair to the package struct.">
		<cfargument name="xml" type="XML" required="true" hint="The parsed transfer XML.">
		<cfset var xmlArray = XMLSearch(arguments.xml,"//package/@name")>
		<cfset var i = "">
		<cfloop from="1" to="#ArrayLen(xmlArray)#" index="i">
			<cfset variables.packageMap[xmlArray[i].XmlValue] = getObjectList(arguments.xml,xmlArray[i].XmlValue)>
		</cfloop>
	</cffunction>

	<cffunction name="getObjectList" access="private" returntype="string" output="false" hint="I return a list of object for a given package in the transfer xml.">
		<cfargument name="xml" type="XML" required="true" hint="The parsed Transfer XML.">
		<cfargument name="packageName" type="string" required="true" hint="The package name to search.">
		<cfset var xmlArray = XMLSearch(arguments.xml,"//package[@name='#lcase(arguments.packageName)#']/object/@name")>
		<cfset var objectList = "">
		<cfset var i = "">
		<cfloop from="1" to="#ArrayLen(xmlArray)#" index="i">
			<cfset objectList = ListAppend(objectList,xmlArray[i].XmlValue)>
		</cfloop>
		<cfreturn objectList>
	</cffunction>

</cfcomponent>