<!--- 
	Copyright 2007 Paul Marcotte, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	TransientFactory.cfc (.1)
	[2009-09-25]	Initial Release.

	Usage :
	
	Setup Colspring XML
	===================
	<beans>
    <bean id="beanInjector" class="model.BeanInjector" singleton="true" />

    <bean id="TransientFactory" class="model.TransientFactory" singleton="true">
        <constructor-arg name="classes">
            <map>
                <entry key="ServiceResult">
                    <value>model.util.ServiceResult</value>
                </entry>
                <entry key="Timer">
                    <value>model.util.Timer</value>
                </entry>
            </map>
        </constructor-arg>
        <constructor-arg name="afterCreateMethod">
            <value>setup</value>
        </constructor-arg>
        <property name="beanInjector">
            <ref bean="beanInjector" />
        </property>
    </bean>
	</beans>
	
	Create a simple transient
	==================
	<cfset result = TransientFactory.create("Result")>
	
	
	Pass constructor arguments
	==========================

	<cfset initArgs = StructNew()>
    <cfset initArgs.myprop = "myvalue">
    <cfset result = TransientFactory.create("Result",initArgs)>
	
	Using the virtual method new{objectName}
	========================================
	
	<cfset result = TransientFactory.newResult(myprop="myvalue")>
	
 --->
<cfcomponent displayname="TransientFactory" output="false" hint="I create Transient objects.">

	<!--- public --->

	<cffunction name="init" access="public" output="false" returntype="metro.factory.TransientFactory" hint="I return the configured TransientFactory">
		<cfargument name="classes" type="struct" required="false" default="#StructNew()#" hint="The map of class names and paths as key/value pairs.">
		<cfargument name="afterCreateMethod" type="string" required="false" default="">
		<cfset variables.classes = arguments.classes>
		<cfset variables.afterCreateMethod = arguments.afterCreateMethod>
		<cfreturn this />
	</cffunction>

	<cffunction name="create" access="public" output="false" returntype="any" hint="I return a configured, autowired transient object.">
		<cfargument name="transientName" type="string" required="true" hint="The name of the transient to create.">
		<cfargument name="initArgs" type="struct" required="false" default="#structNew()#" hint="The optional init arguments for the transient.">
		<cfset var obj = createObject("component",getClassPath(arguments.transientName))>
		<cfif StructKeyExists(obj,"init")>
			<cfinvoke component="#obj#" method="init" argumentcollection="#initArgs#" />
		</cfif>
		<cfset getBeanInjector().autowire(targetComponent=obj, targetComponentTypeName=arguments.transientName) />
		<cfif (len(variables.afterCreateMethod)) and (StructKeyExists(obj,variables.afterCreateMethod))>
			<cfinvoke component="#obj#" method="#variables.afterCreateMethod#" />
		</cfif>
		<cfreturn obj>
	</cffunction>

	<cffunction name="getClasses" access="public" output="false" returntype="struct" hint="I return the map of classes that can be created.">
		<cfreturn variables.classes>
	</cffunction>

	<cffunction name="onMissingMethod" access="public" output="false" returntype="any" hint="I provide a virtual api [new{transientName}] for any registered transient.">
		<cfargument name="MissingMethodName" type="string" required="true" />
		<cfargument name="MissingMethodArguments" type="struct" required="true" />
		<cfif (len(arguments.MissingMethodName) gt 3) and (Left(arguments.MissingMethodName,3) is "new")>
			<cfreturn create(Right(arguments.MissingMethodName,Len(arguments.MissingMethodName)-3),arguments.MissingMethodArguments)>
		</cfif>
	</cffunction>

	<!--- private --->
	
	<cffunction name="getClassPath" access="private" output="false" returntype="string" hint="I return the transient class path by name.">
		<cfargument name="transientName" type="string" required="true" hint="The name of the transient to create.">
		<cfreturn variables.classes[arguments.transientName]>
	</cffunction>

	<!--- dependencies --->

	<cffunction name="setBeanInjector" access="public" returntype="void" output="false" hint="I set a reference to the BeanInjector.">
		<cfargument name="BeanInjector" type="any" required="true" hint="The BeanInjector object.">
		<cfset variables.BeanInjector = arguments.BeanInjector >
	</cffunction>
	
	<cffunction name="getBeanInjector" access="public" returntype="any" output="false" hint="I return the BeanInjector.">
		<cfreturn variables.BeanInjector />
	</cffunction>

</cfcomponent>