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
<cfcomponent displayname="Service" output="false" hint="I provide base methods for Services.">
	
	<cfset variables.gatewayCollection = structNew()>
	
	<cffunction name="init" access="public" output="false" returntype="metro.core.Service" hint="I return the core Service.">
		<cfargument name="packageName" type="string" required="true" hint="The Transfer package name.">
		<cfset setPackageName(arguments.packageName)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setPackageName" access="public" returntype="void" output="false" hint="I set the package name for this Service.">
		<cfargument name="PackageName" type="string" required="true" hint="The Transfer package name.">
		<cfset variables.PackageName = arguments.PackageName >
	</cffunction>
	
	<cffunction name="getPackageName" access="public" returntype="string" output="false" hint="I return the package name for this Service.">
		<cfreturn variables.PackageName />
	</cffunction>
	
	<cffunction name="addGateway" access="public" output="false" returntype="void" hint="I add a Gateway for object within the Transfer package.">
		<cfargument name="name" type="string" required="true" hint="The name for the Gateway.">
		<cfargument name="gateway" type="any" required="true" hint="The Gateway object.">
		<cfset variables.gatewayCollection[arguments.name] = arguments.gateway>
	</cffunction>
	
	<cffunction name="create" access="public" output="false" returntype="any" hint="I return a populated and validated Transfer object.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="input" type="struct" required="true" hint="The input struct of key/value pairs.">
		<cfargument name="context" type="string" required="false" hint="The validation context." default="all">
		<cfset var obj = new(objectName: arguments.objectName)>
		<cfset obj.populate(args: arguments.input)>
		<cfif obj.validate(context: arguments.context)>
			<cfset getGateway(arguments.objectName).save(obj)>
		</cfif>
		<cfreturn obj>
	</cffunction>
	
	<cffunction name="save" access="public" output="false" returntype="any" hint="I return a populated and validated Transfer object.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="input" type="struct" required="true" hint="The input struct of key/value pairs.">
		<cfargument name="context" type="string" required="false" hint="The validation context." default="all">
		<cfset var obj = get(objectName: arguments.objectName, key: arguments.input).clone()>
		<cfset obj.populate(args: arguments.input)>
		<cfif obj.validate(context: arguments.context)>
			<cfset getGateway(arguments.objectName).save(obj)>
		</cfif>
		<cfreturn obj>
	</cffunction>
	
	<cffunction name="new" access="public" output="false" returntype="any" hint="I return a new Transfer object by object name.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfreturn getGateway(arguments.objectName).new()>
	</cffunction>
	
	<cffunction name="get" access="public" output="false" returntype="any" hint="I return a Transfer object by object name and key.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="key" type="any" required="true" hint="The key to retrieve the object by.">
		<cfset var Gateway = getGateway(arguments.objectName)>
		<cfset var pk = Gateway.getPrimaryKey()>
		<cfif isArray(pk)>
			<cfreturn Gateway.get(key=Gateway.createKey(input:arguments.key))>
		<cfelseif isStruct(arguments.key)>
			<cfreturn Gateway.get(key:arguments.key[pk])>
		<cfelse>
			<cfreturn Gateway.get(key:arguments.key)>
		</cfif>
	</cffunction>
	
	<cffunction name="getByProperty" access="public" output="false" returntype="any" hint="I return a Transfer object by property.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="property" type="string" required="true" hint="The Transfer object property name.">
		<cfargument name="value" type="any" required="true" default="The property value.">
		<cfreturn getGateway(arguments.objectName).getByProperty(property:arguments.property,value:arguments.value)>
	</cffunction>
	
	<cffunction name="getByPropertyMap" access="public" output="false" returntype="any" hint="I return a Transfer object by property.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="propertyMap" type="struct" required="true" hint="The property map.">
		<cfreturn getGateway(arguments.objectName).getByPropertyMap(propertyMap:arguments.propertyMap)>
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="void" hint="I delete a Transfer object by object name and key.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="key" type="any" required="true" hint="The key for to retrieve the object by.">
		<cfset var obj = get(argumentCollection:arguments)>
		<cfset getGateway(arguments.objectName).delete(obj)>
	</cffunction>
	
	<cffunction name="list" access="public" output="false" returntype="query" hint="I return a query by object name and filter.">
		<cfargument name="objectName" type="string" required="true" hint="The Transfer object name.">
		<cfargument name="filter" type="struct" required="false" hint="The input filter of key/vlaue pairs.">
		<cfargument name="orderBy" type="string" required="false" default="" hint="The optional property name to order by.">
		<cfargument name="asc" type="boolean" required="false" default="true" hint="The boolean flag to specify whether to sort ascending or descending.">
		<cfargument name="page" hint="The page number; defaults to one (1)" required="no" type="numeric" default="1" />
		<cfargument name="pageLen" hint="The page length (e.g. the number of records to retrieve per page); defaults to 25" required="no" type="numeric" default="25" />
		<cfargument name="showAll" hint="Boolean indication of whether or not to show all; defaults to false" required="no" type="boolean" default="no" />
		
		<cfif not structKeyExists(arguments,"filter")>
			<cfset arguments.filter = structNew()>
		</cfif>
		<cfreturn getGateway(arguments.objectName).list(filter:arguments.filter, orderBy:arguments.orderBy, asc:arguments.asc, page:arguments.page, pageLen:arguments.pageLen, showAll: arguments.showAll)>
	</cffunction>
	
	<cffunction name="reap" hint="I remove an object from the transfer cache." returntype="void" output="false" access="public">
		<cfargument name="objectName" hint="The object name" required="yes" type="string" />
		<cfargument name="key" hint="The object key." required="false" type="any" />
		
		<cfif structKeyexists(arguments,"key")>
			<cfset getGateway(arguments.objectName).reap(key:arguments.key)>
		<cfelse>
			<cfset getGateway(arguments.objectName).reap()>
		</cfif>
	</cffunction>
	
	<cffunction name="getGateway" access="public" returntype="any" output="false" hint="I return the Gateway for an object by name.">
		<cfargument name="objectName" type="string" required="true">
		<cfif StructKeyExists(variables.gatewayCollection,arguments.objectName)>
			<cfreturn variables.gatewayCollection[arguments.objectName]>
		<cfelse>
			<cfthrow message="A Gateway for #arguments.objectName# is unavailable!">
		</cfif>
	</cffunction>
	
	<cffunction name="onMissingMethod" access="public" output="true" returntype="any" hint="I provide some syntactic sugar for invoking new, get, list, delete, and save without passing the object name as an argument.">
		<cfargument name="MissingMethodName" type="string" required="true" hint="The missing method name.">
		<cfargument name="MissingMethodArguments" type="struct" required="true" hint="The missing method arguments.">
		<cfset var objectName = "">
		<cfif REFind("^(create|delete|get|list|new|save)",arguments.MissingMethodName)>
			<cfif (Left(arguments.MissingMethodName,6) is "create")>
				<cfreturn create(objectName:getObjectName(arguments.MissingMethodName,6), input:arguments.MissingMethodArguments)>
			<cfelseif (Left(arguments.MissingMethodName,6) is "delete")>
				<cfif StructCount(arguments.MissingMethodArguments) eq 1>
					<cfreturn delete(objectName: getObjectName(arguments.MissingMethodName,6),key:arguments.MissingMethodArguments[1])>
				</cfif>
			<cfelseif (Left(arguments.MissingMethodName,3) is "get")>
				<cfif StructCount(arguments.MissingMethodArguments) eq 1>
					<cfreturn get(objectName: getObjectName(arguments.MissingMethodName,3),key:arguments.MissingMethodArguments[1])>
				</cfif>
			<cfelseif (Left(arguments.MissingMethodName,4) is "list")>
				<cfreturn list(objectName: getObjectName(arguments.MissingMethodName,4), filter:arguments.MissingMethodArguments)>
			<cfelseif (Left(arguments.MissingMethodName,3) is "new")>
				<cfreturn new(objectName: getObjectName(arguments.MissingMethodName,3))>
			<cfelseif (Left(arguments.MissingMethodName,4) is "save")>
				<cfreturn save(objectName: getObjectName(arguments.MissingMethodName,4), input: arguments.MissingMethodArguments)>
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- dependencies --->
	
	<cffunction name="setTransaction" access="public" output="false" returntype="void" hint="I setup the transfer transaction advice for save and delete methods.">
		<cfargument name="transaction" type="transfer.com.sql.transaction.Transaction" required="true" hint="The Transfer transaction object.">	
		<cfset arguments.transaction.advise(this,"^(create|delete|save)")>
	</cffunction>
	
	<!--- private --->
	
	<cffunction name="getObjectName" access="private" output="false" returntype="string">
		<cfargument name="MethodName" type="string" required="true" hint="The missing method name.">
		<cfargument name="length" type="string" required="true" hint="The missing method name.">
		<cfreturn reReplace(arguments.MethodName,"\A[A-Za-z]{#arguments.length#}","")>
	</cffunction>
	
</cfcomponent>