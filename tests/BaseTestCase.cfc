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
<cfcomponent displayname="metro.tests.BaseTestCase"  extends="mxunit.framework.TestCase">
	
	<cfset variables.beansXML = "">
	
	<cffunction name="setBeanFactory" access="private" output="false" returntype="void">
		<cfargument name="coldspringXML" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">
		<cfargument name="additionalXML" type="string" required="false" default="">
		<cfscript>
		var beanDefs = expandPath(arguments.coldspringXML);
		
		if (not structkeyExists(request,"beanFactory"))
		{
			request.beanFactory = createObject("component" ,"coldspring.beans.DefaultXmlBeanFactory").init(StructNew(),arguments.params);
			request.beanFactory.loadBeans(beanDefs);
		}
		if (len(arguments.additionalXML))
		{
		request.beanFactory.loadBeans(arguments.additionalXML);
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="getBeanFactory" access="private" output="false" returntype="any">
		<cfreturn request.beanFactory>
	</cffunction>
	
	<!--- mock methods --->
	
	<cffunction name="returnsTrue" access="private" output="false" returntype="boolean">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="returnsFalse" access="private" output="false" returntype="boolean">
		<cfreturn false>
	</cffunction>
	
	<cffunction name="returnsVoid" access="private" output="false" returntype="void">
	</cffunction>
	
</cfcomponent>
