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
<cfcomponent displayname="Cache" output="false" hint="I am a generic Cache object.">
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="I return the Cache object.">
		<cfargument name="cacheMinutes" type="numeric" required="true" hint="The number of minutes an item should be cached ">
		<cfargument name="hashKeys" type="boolean" required="false" default="false" hint="A boolean flag specifying whether the key for the cache item should be hashed.">
		<cfset variables.cache = StructNew()>
		<cfset variables.cacheMinutes = arguments.cacheMinutes>
		<cfset variables.hashKeys = arguments.hashKeys>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="put" access="public" returntype="boolean" output="false" hint="I return a boolean result of whether the item was put into cache.">
		<cfargument name="key" type="string" required="true" hint="The key for the cache item.">
		<cfargument name="value" type="any" required="true" hint="The value of the cache item.">
		<cfset var result = false>
		<cfset var item = StructNew()>
		<cfif not exists(arguments.key)>
			<cflock name="#keyHash(arguments.key)#" timeout="20">
				<cfif not exists(arguments.key)>
					<cfset item.value = arguments.value>
					<cfset item.timeout = DateAdd("n",getCacheMinutes(),now())>
					<cfset result = structInsert(getCache(),keyHash(arguments.key),item)>
				</cfif>
			</cflock>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="exists" access="public" returntype="boolean" output="false" hint="I return a boolean result of whether the item is cached by key.">
		<cfargument name="key" type="string" required="true" hint="The key to check.">
		<cfset reap()>
		<cfreturn structKeyExists(variables.cache,keyHash(arguments.key))>
	</cffunction>
	
	<cffunction name="getValue" access="public" returntype="any" output="false" hint="I return the value of the cached item by key.">
		<cfargument name="key" type="string" required="true" hint="The cached item key.">
		<cftry>
			<cflock name="#keyHash(arguments.key)#" timeout="5">
				<cfreturn getItem(arguments.key).value>
			</cflock>
			<cfcatch type="any">
				<cfthrow message="Item (#arguments.Key#) not found in cache.">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getTimeout" access="public" returntype="date" output="false" hint="I return the datetime that the cached item is set to expire by key.">
		<cfargument name="key" type="string" required="true" hint="The cached item key.">
		<cfreturn getItem(arguments.key).timeout>
	</cffunction>
	
	<cffunction name="remove" access="public" returntype="boolean" output="false" hint="I return a boolean result of whether the item was removed from cache.">
		<cfargument name="key" type="string" required="true" hint="The cached item key.">
		<cfset var result = false>
		<cflock name="#keyHash(arguments.key)#" timeout="20">
			<cfset result = structDelete(variables.cache,keyHash(arguments.key))>
		</cflock>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="reap" access="public" returntype="void" output="false" hint="I remove expired items from the cache.">
		<cfset var cache = variables.cache>
		<cfset var key = "">
		<cfset var reaped = false>
		<cfloop collection="#cache#" item="key">
			<cfif cache[key].timeout lt now()>
				<cflock name="metro_Cache_#key#" timeout="20">
					<cfset reaped = structDelete(cache,key)>
				</cflock>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="purge" access="public" returntype="void" output="false" hint="I purge the entire cache.">
		<cfset variables.cache = structNew()>
	</cffunction>
		
	<cffunction name="getCache" access="public" returntype="struct" output="false" hint="I return the cache.">
		<cfset reap()>
		<cfreturn variables.cache>
	</cffunction>
	
	<cffunction name="getCachedKeyArray" access="public" returntype="array" output="false" hint="I return an array of the keys in the cache.">
		<cfreturn StructKeyArray(getCache())>
	</cffunction>
	
	<cffunction name="getCacheMinutes" access="public" returntype="numeric" output="false" hint="I return the cache minutes.">
		<cfreturn variables.cacheMinutes>
	</cffunction>
	
	<!--- private --->
	
	<cffunction name="getItem" access="private" returntype="struct" output="false" hint="I return the cached item by key.">
		<cfargument name="key" type="string" required="true" hint="The cached item key.">
		<cfreturn variables.cache[keyHash(arguments.key)]>
	</cffunction>
	
	<cffunction name="keyHash" access="private" returntype="string" output="false" hint="I return a hash of the key.">
		<cfargument name="key" type="string" required="true" hint="The key to hash.">
		<cfset var rtn = arguments.key>
		<cfif variables.hashKeys>
			<cfset rtn = hash(lcase(arguments.key))>
		</cfif>
		<cfreturn rtn>
	</cffunction>
	
</cfcomponent>