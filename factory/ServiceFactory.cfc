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
<cfcomponent displayname="ServiceFactory" output="false" hint="I am an abstract Factory for creating services and gateways">

	<cfset variables.objectCache = StructNew()>
	<cfset variables.componentMap = StructNew()>
	
	<cffunction name="init" access="public" output="false" returntype="metro.factory.ServiceFactory" hint="I return the ServiceFactory.">
		<cfargument name="TransferConfig" type="transfer.com.config.Configuration" required="true" hint="The Transfer config object.">
		<cfargument name="componentPath" type="string" required="false" default="" hint="The root path to concrete component class packages.">
		<cfargument name="libPath" type="string" required="false" default="" hint="The root path to a custom component library class packages.">
		<cfargument name="afterCreateMethod" type="string" required="false" default="" hint="The name of a method to invoke upon service or gateway instantiation.">
		
		<cfset setComponentPath(arguments.componentPath)>
		<cfset setAfterCreateMethod(arguments.afterCreateMethod)>
		<cfset setLibPath(arguments.libPath)>
		<cfset variables.FileSystem = CreateObject("component","metro.io.FileSystem").init()>
		<cfset variables.ConfigReader = CreateObject("component","metro.util.TransferConfigReader").init(arguments.TransferConfig)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setComponentPath" access="public" returntype="void" output="false" hint="I set the root component path.">
		<cfargument name="ComponentPath" type="any" required="true" hint="The root path to concrete component class packages.">
		<cfset variables.ComponentPath = arguments.ComponentPath >
	</cffunction>
	
	<cffunction name="getComponentPath" access="public" returntype="any" output="false" hint="I return the root component path.">
		<cfreturn variables.ComponentPath />
	</cffunction>
	
	<cffunction name="setAfterCreateMethod" access="public" returntype="void" output="false">
		<cfargument name="AfterCreateMethod" type="string" required="true">
		<cfset variables.AfterCreateMethod = arguments.AfterCreateMethod >
	</cffunction>
	
	<cffunction name="getAfterCreateMethod" access="public" returntype="string" output="false">
		<cfreturn variables.AfterCreateMethod />
	</cffunction>
	
	<cffunction name="setLibPath" access="public" returntype="void" output="false" hint="I set the root component path.">
		<cfargument name="LibPath" type="any" required="true" hint="The root path to concrete component class packages.">
		<cfset variables.LibPath = arguments.LibPath >
	</cffunction>
	
	<cffunction name="getLibPath" access="public" returntype="any" output="false" hint="I return the root component path.">
		<cfreturn variables.LibPath />
	</cffunction>
	
	<cffunction name="getTransferPackageMap" access="public" returntype="any" output="false" hint="I return the Transfer package map.">
		<cfreturn variables.ConfigReader.getPackageMap()>
	</cffunction>
	
	<cffunction name="getService" access="public" output="false" returntype="any" hint="I return a generic or concrete service fully composed with a gateway for each object the specified package.">
		<cfargument name="packageName" type="string" required="true" hint="The Transfer package name.">
		<cfset var serviceName = arguments.packageName & "Service">
		<cfset var service = "">
		<cfset var gateway = "">
		<cfset var objectName ="">
		<cfset var className ="">
		<cfset var transferPackageMap = getTransferPackageMap()>
		<cfif not StructKeyExists(variables.componentMap,arguments.packageName)>
			<cfset variables.componentMap[arguments.packageName] = getPackageInfo(arguments.packageName)>
		</cfif>
		<cfif StructKeyExists(transferPackageMap,arguments.packageName)>
			<cfif structKeyExists(variables.objectCache,serviceName)>
				<cfset service = variables.objectCache[serviceName]>
			<cfelse>
				<cfif StructKeyExists(variables.componentMap,arguments.packageName) and StructKeyExists(variables.componentMap[arguments.packageName],ServiceName)>
					<cfset service = CreateObject("component",variables.componentMap[arguments.packageName][serviceName]).init(packageName=arguments.packageName)>
				<cfelse>
					<cfset service = CreateObject("component","metro.core.Service").init(packageName=arguments.packageName)>
				</cfif>
				<cfloop list="#transferPackageMap[arguments.packageName]#" index="objectName">
					<cfset className = arguments.packageName&"."&objectName>
					<cfif StructKeyExists(variables.componentMap,arguments.packageName) and StructKeyExists(variables.componentMap[arguments.packageName],objectName)>
						<cfset gateway = CreateObject("component",variables.componentMap[arguments.packageName][objectName]).init(className=className)>
					<cfelse>
						<cfset gateway = CreateObject("component","metro.core.Gateway").init(className=className)>
					</cfif>
					<cfset getBeanInjector().autowire(targetComponent=gateway, stopRecursionAt="WEB-INF.cftags.component")>
					<cfif (len(getAfterCreateMethod()) gt 0) and (getMetadataInspector().hasPublicMethod(getMetadata(gateway),getAfterCreateMethod()))>
						<cfinvoke component="#gateway#" method="#getAfterCreateMethod()#" />
					</cfif>
					<cfset service.addGateway(name=objectName,gateway=gateway)>
				</cfloop>
				<cfif (len(getAfterCreateMethod()) gt 0) and (getMetadataInspector().hasPublicMethod(getMetadata(service),getAfterCreateMethod()))>
						<cfinvoke component="#service#" method="#getAfterCreateMethod()#" />
					</cfif>
				<cfset variables.objectCache[serviceName] = service>
			</cfif>
		<cfelse>
			<cfthrow message="No package found for #arguments.packageName#!">
		</cfif>
		<cfreturn service>
	</cffunction>

	<cffunction name="getPackageInfo" access="public" output="false" returntype="any" hint="I return a struct representing the objects to create and their full class paths.">
		<cfargument name="packageName" type="string" required="true" hint="The Transfer package name.">
		<cfset var packagePath = buildPath(packageName:arguments.packageName,rootPath:getComponentPath())>
		<cfset var libPath = buildPath(packageName:arguments.packageName,rootPath:getLibPath())>
		<cfset var metroPath = buildPath(packageName:arguments.packageName,rootPath:"metro/model")>
		<cfset var packageMap = structNew()>
		<cfif variables.fileSystem.pathExists(packagePath)>
			<cfset StructAppend(packageMap,getPackageMap(packagePath),false)>
		</cfif>
		<cfif variables.fileSystem.pathExists(libPath)>
			<cfset StructAppend(packageMap,getPackageMap(libPath),false)>
		</cfif>
		<cfif variables.fileSystem.pathExists(metroPath)>
			<cfset StructAppend(packageMap,getPackageMap(metroPath),false)>
		</cfif>
		<cfreturn packageMap>
	</cffunction>

	<!--- dependencies --->

	<cffunction name="setBeanInjector" access="public" returntype="void" output="false">
		<cfargument name="BeanInjector" type="any" required="true">
		<cfset variables.BeanInjector = arguments.BeanInjector >
	</cffunction>
	
	<cffunction name="getBeanInjector" access="public" returntype="any" output="false">
		<cfreturn variables.BeanInjector />
	</cffunction>
	
	<cffunction name="getMetadataInspector" access="public" returntype="any" output="false" hint="I return the MetadataInspector.">
		<cfreturn variables.MetadataInspector />
	</cffunction>

	<cffunction name="setMetadataInspector" access="public" returntype="void" output="false" hint="I set the MetadataInspector.">
		<cfargument name="MetadataInspector" type="any" required="true">
		<cfset variables.MetadataInspector = arguments.MetadataInspector >
	</cffunction>

	<!--- private --->

	<cffunction name="buildPath" access="private" returntype="string" output="false" hint="I return a relative path to components by type (component|lib|metro).">
		<cfargument name="packageName" type="string" required="true" hint="The Transfer package name.">
		<cfargument name="rootPath" type="string" required="true" hint="The root path.">
		<cfset var fullPath = "/" & arguments.packageName>
		<cfif len(arguments.rootPath)>
			<cfset fullPath = "/" & arguments.rootPath & fullPath>
		</cfif>
		<cfreturn fullPath>
	</cffunction>

	<cffunction name="getPackageMap" access="private" output="false" returntype="struct"  hint="I return a struct representing the objects to create and their full class paths.">
		<cfargument name="packagePath" type="string" required="true">
		<cfset var componentList = variables.fileSystem.listFilesFromDir(arguments.packagePath)>
		<cfset var dotPath = Replace(Right(arguments.packagePath,len(arguments.packagePath)-1),"/",".","all")>
		<cfset var packageDataMap = structNew()>
		<cfset var componentMetaData = StructNew()>
		<cfset var componentName = "">
		<cfset var i = "">
		<cfloop list="#componentList#" index="i">
			<cfif Right(i,4) is ".cfc">
				<cfset componentName = Replace(i,'.cfc','')>
				<cfset componentMetaData = getComponentMetaData(dotPath&'.'&componentName)>
				<cfif getMetadataInspector().inheritsFrom(componentMetaData,"metro.core.Service")>
					<cfset packageDataMap[componentName] = componentMetaData.name>
				<cfelseif getMetadataInspector().inheritsFrom(componentMetaData,"metro.core.Gateway")>
					<cfset packageDataMap[componentMetaData.objectName] = componentMetaData.name>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn packageDataMap>
	</cffunction>

</cfcomponent>