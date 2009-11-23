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
<cfcomponent displayname="Gateway" output="false" hint="I provide base methods for Gateways.">
	
	<cffunction name="init" access="public" output="false" returntype="metro.core.Gateway" hint="I return the core Gateway">
		<cfargument name="className" type="string" required="true" hint="The full object class name.">
		<cfset setClassName(arguments.className) />
		<cfreturn this>
	</cffunction>		

	<cffunction name="setup" access="public" output="false" returntype="void">
		<cfset setPrimaryKey()>
	</cffunction>

	<!--- generic methods --->

	<cffunction name="new" access="public" output="false" returntype="any" hint="I return a new Transfer object.">
		<cfreturn getTransfer().new(getClassName())>
	</cffunction>

	<cffunction name="get" access="public" output="false" returntype="any" hint="I return a Transfer object by key.">
		<cfargument name="key" type="any" required="true" hint="The key used to retrieve a Transfer object. Can be a simple value for objects with a single Primary key, or a struct for object with a composite id.">
		<cfreturn getTransfer().get(getClassName(),arguments.key)>
	</cffunction>

	<cffunction name="getByProperty" access="public" output="false" returntype="any" hint="I return a Transfer object by property.">
		<cfargument name="property" type="string" required="true" hint="The object property name.">
		<cfargument name="value" type="any" required="true" hint="The object property value.">
		<cfreturn getTransfer().readByProperty(getClassName(),arguments.property,arguments.value)>
	</cffunction>

	<cffunction name="getByPropertyMap" access="public" output="false" returntype="any" hint="I return a transfer object by property map (struct).">
		<cfargument name="propertyMap" type="struct" required="true" hint="The property map conatining key/value pairs.">
		<cfreturn getTransfer().readByPropertyMap(getClassName(),arguments.propertyMap)>
	</cffunction>

	<cffunction name="save" access="public" output="false" returntype="void" hint="I save the Transfer object.">
		<cfargument name="obj" type="transfer.com.TransferDecorator" required="true" hint="The Transfer object to save.">
		<cfset getTransfer().save(obj)>		
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" returntype="void" hint="I delete the Transfer object.">
		<cfargument name="obj" type="transfer.com.TransferObject" required="true" hint="The Transfer object to delete.">
		<cfset getTransfer().delete(obj)>		
	</cffunction>
	
	<cffunction name="list" access="public" output="false" returntype="query" hint="I return a query that can be filtered.">
		<cfargument name="filter" type="struct" required="false" default="#structNew()#" hint="The filter struct of key/vale pairs.">
		<cfargument name="orderBy" type="string" required="false" default="" hint="The optional property name to order by.">
		<cfargument name="asc" type="boolean" required="false" default="true" hint="The boolean flag to specify whether to sort ascending or descending.">
		<cfset var qList = "" />
		<cfset var key = "" />
		<cfset var i = 0>
		<cfset var pk = getPrimaryKey()>
		<cfset var propertyMap = StructNew()>
		<cfset var listMethod = "list" />
		<cfif (len(arguments.orderBy) eq 0)>
			<cfif (not isArray(pk))>
				<cfset arguments.orderBy = pk>
			<cfelse>
				<cfloop from="1" to="#ArrayLen(pk)#" index="i">
					<cfif (pk[i].type is "Property")>
						<cfset arguments.orderBy = ListAppend(arguments.orderBy,pk[i].name)>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfloop item="key" collection="#arguments.filter#">
			<cfif Len(arguments.filter[key])>
				<cfset StructInsert(propertyMap,key,arguments.filter[key])>
			</cfif>
		</cfloop>
		<cfif NOT StructIsEmpty(propertyMap)>
			<cfset listMethod = "listByPropertyMap" />
		</cfif>
		<cfinvoke component="#getTransfer()#" method="#listMethod#" returnvariable="qList">
			<cfinvokeargument name="className" value="#getClassName()#" />
			<cfif Len(arguments.orderBy)>
				<cfinvokeargument name="orderProperty" value="#arguments.orderBy#" />
				<cfinvokeargument name="orderASC" value="#arguments.asc#" />
			</cfif>
			<cfif NOT StructIsEmpty(propertyMap)>
				<cfinvokeargument name="propertyMap" value="#propertyMap#" />
			</cfif>
		</cfinvoke>
				
		<cfreturn qList />
	</cffunction>

	<cffunction name="getClassName" access="public" returntype="string" output="false" hint="I return the Transfer class name for this Gateway.">
		<cfreturn variables.ClassName />
	</cffunction>
	
	<cffunction name="getIsComposite" access="public" returntype="string" output="false" hint="I return the Transfer class name for this Gateway.">
		<cfreturn variables.isComposite />
	</cffunction>
	
	<cffunction name="getPrimaryKey" access="public" returntype="any" output="false" hint="I return info about the primary key of the object realted to this Gateway.">
		<cfreturn variables.primaryKey />
	</cffunction>

	<cffunction name="createKey" access="public" output="false" returntype="any" hint="I return a populated key for the class (simple value or map).">
		<cfargument name="input" type="any" required="true">
		<cfset var pk = getPrimaryKey()>
		<cfset var key = StructNew()>
		<cfset var i = 0>
		<cfif isArray(pk)>
			<cfloop from="1" to="#ArrayLen(pk)#" index="i">
				<cfif NOT structkeyexists(arguments.input,pk[i].link)>
					<cfthrow type="metro.core.Gateway.createKey.exception" message="#pk[i].link# must exist in provided input.">
				</cfif>
				<cfset key[pk[i].name] = arguments.input[pk[i].link]>
			</cfloop>
			<cfreturn key>
		<cfelse>
			<cfreturn input>
		</cfif>
	</cffunction>

	<cffunction name="reap" access="public" output="false" returntype="void" hint="I remove all cached instances for the class.">
		<cfargument name="key" hint="The object key." required="false" type="any" />
		
		<cfif (not getIsComposite())>
			<cfif (structKeyexists(arguments,"key"))>
				<cfset getTransfer().discardByClassAndKey(className: getClassName(), key: arguments.key)>
			<cfelse>
				<cfset getTransfer().discardByClassAndKeyQuery(className: getClassName(), keyQuery: list(), columnName: getPrimaryKey())>
			</cfif>
		</cfif>
	</cffunction>

	<!--- dependencies --->

	<cffunction name="setTransfer" access="public" output="false" returntype="void">
		<cfargument name="transfer" type="transfer.com.Transfer" required="true" hint="The Transfer object factory.">
		<cfset variables.transfer = arguments.transfer />
	</cffunction>

	<cffunction name="getTransfer" access="public" output="false" returntype="transfer.com.Transfer">
		<cfreturn variables.transfer />
	</cffunction>
	
	<cffunction name="setDatasource" access="public" returntype="void" output="false">
		<cfargument name="Datasource" type="transfer.com.sql.Datasource" required="true" hint="The transfer Datasource object.">
		<cfset variables.Datasource = arguments.Datasource >
	</cffunction>
	
	<cffunction name="getDatasource" access="public" returntype="transfer.com.sql.Datasource" output="false">
		<cfreturn variables.Datasource />
	</cffunction>
	
	<!--- private --->
	
	<cffunction name="setClassName" access="public" returntype="void" output="false" hint="I set the Transfer class name for this Gateway.">
		<cfargument name="ClassName" type="string" required="true" hint="The full object class name.">
		<cfset variables.ClassName = arguments.ClassName >
	</cffunction>
	
	<cffunction name="setPrimaryKey" access="private" output="false" returntype="void" hint="I use Transfer metadata to set the properties of the primary key.">
		<cfset var pk = getTransfer().getTransferMetadata(getClassName()).getPrimaryKey() />
		<cfset var iterator = "">
		<cfset var item = "">
		<cfset var compositeKeyArray = ArrayNew(1)>
		<cfset var compositeKeyItem = "">
		<cfif pk.getIsComposite()>
			<cfset variables.isComposite = true>
			<cfset iterator = pk.getPropertyIterator() />
			<cfloop condition="#iterator.hasnext()#">
				<cfset item = iterator.next() />
				<cfset compositeKeyItem = StructNew()>
				<cfset compositeKeyItem["type"] =  "Property" />
				<cfset compositeKeyItem["name"] = item.getName() />
				<cfset compositeKeyItem["link"] = item.getName() />
				<cfset ArrayAppend(compositeKeyArray,compositeKeyItem)>
			</cfloop>
			<cfset iterator = pk.getManyToOneIterator() />
			<cfloop condition="#iterator.hasnext()#">
				<cfset item = iterator.next() />
				<cfset compositeKeyItem = StructNew()>
				<cfset compositeKeyItem["type"] =  "ManyToOne" />
				<cfset compositeKeyItem["name"] = item.getName() />
				<cfset compositeKeyItem["link"] = item.getLink().getColumn() />
				<cfset ArrayAppend(compositeKeyArray,compositeKeyItem)>
			</cfloop>
			<cfset iterator = pk.getParentOneToManyIterator() />
			<cfloop condition="#iterator.hasnext()#">
				<cfset item = iterator.next() />
				<cfset compositeKeyItem = StructNew()>
				<cfset compositeKeyItem["type"] =  "ParentOneToMany" />
				<cfset compositeKeyItem["name"] = "parent" & item.getLink().getToObject().getObjectName() />
				<cfset compositeKeyItem["link"] = item.getLink().getColumn() />
				<cfset ArrayAppend(compositeKeyArray,compositeKeyItem)>
			</cfloop>
			<cfset variables.primaryKey = compositeKeyArray>
		<cfelse>
			<cfset variables.isComposite = false>
			<cfset variables.primaryKey = pk.getName() />
		</cfif>
	</cffunction>
	
</cfcomponent>