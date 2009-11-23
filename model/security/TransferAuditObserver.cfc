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
<cfcomponent displayname="TransferAuditObserver" output="false"  hint="I am a Transfer AfterCreate, AfterUpdate and BeforeDelete observer.">

	<cffunction name="init" access="public" output="false" returntype="any" hint="I return the TransferAuditObserver">
		<cfargument name="transfer" type="transfer.com.Transfer" required="true">
		<cfargument name="auditMap" type="struct" required="true">
		<cfset setTransfer(arguments.transfer)>
		<cfif StructKeyExists(arguments.auditMap,"create")>
			<cfset setCreateMap(arguments.auditMap['create'])>
			<cfset getTransfer().addAfterCreateObserver(this)>
		</cfif>
		<cfif StructKeyExists(arguments.auditMap,"update")>
			<cfset setUpdateMap(arguments.auditMap['update'])>
			<cfset getTransfer().addAfterUpdateObserver(this)>
		</cfif>
		<cfif StructKeyExists(arguments.auditMap,"delete")>
			<cfset setDeleteMap(arguments.auditMap['delete'])>
			<cfset getTransfer().addBeforeDeleteObserver(this)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="actionAfterCreateTransferEvent" access="public" output="false" returntype="void" hint="I determine if the event object class name is present in getCreateList(), if found, I invoke createAuditRecord().">
		<cfargument name="event" hint="The event object" type="transfer.com.events.TransferEvent" required="true">
		<cfset var obj = arguments.event.getTransferObject()>
		<cfset var createMap = getCreateMap()>
		<cfset var className = obj.getClassName()>
		<cfif StructKeyExists(createMap,className)>
			<cfif len(createMap[className]) gt 0>
				<cfinvoke method="#createMap[className]#">
					<cfinvokeargument name="obj" value="#obj#">
					<cfinvokeargument name="action" value="create">
				</cfinvoke>
			</cfif>			
		</cfif>
	</cffunction>

	<cffunction name="actionAfterUpdateTransferEvent" access="public" output="false" returntype="void" hint="I determine if the event object class name is present in getUpdateMap(), if found, I invoke createAuditRecord().">
		<cfargument name="event" hint="The event object" type="transfer.com.events.TransferEvent" required="true">
		<cfset var obj = arguments.event.getTransferObject()>
		<cfset var updateMap = getUpdateMap()>
		<cfset var className = obj.getClassName()>
		<cfif StructKeyExists(updateMap,className)>
			<cfif len(updateMap[className]) gt 0>
				<cfinvoke method="#updateMap[className]#">
					<cfinvokeargument name="obj" value="#obj#">
					<cfinvokeargument name="action" value="update">
				</cfinvoke>
			</cfif>			
		</cfif>
	</cffunction>

	<cffunction name="actionBeforeDeleteTransferEvent" access="public" returntype="void" output="false" hint="I determine if the event object class name is present in getDeleteMap(), if found, I invoke createAuditRecord().">
	 	<cfargument name="event" hint="The event object" type="transfer.com.events.TransferEvent" required="Yes">
		<cfset var obj = arguments.event.getTransferObject()>
		<cfset var deleteMap = getDeleteMap()>
		<cfset var className = obj.getClassName()>
		<cfif StructKeyExists(deleteMap,className)>
			<cfif len(deleteMap[className]) gt 0>
				<cfinvoke method="#deleteMap[className]#">
					<cfinvokeargument name="obj" value="#obj#">
					<cfinvokeargument name="action" value="delete">
				</cfinvoke>
			</cfif>			
		</cfif>
	</cffunction>
	
	<!--- private --->

	<cffunction name="createAuditRecord" access="private" output="true" returntype="void" hint="I create an Audit Record.">
		<cfargument name="obj" type="transfer.com.TransferObject" required="true"  hint="The event object">
		<cfargument name="action" type="string" required="true" hint="The action that occurred (create|update).">
		<cfset var pkValue = "">
		<cfset var pkName = getTransfer().getTransferMetadata(arguments.obj.getClassName()).getPrimaryKey().getName()>
		<cfset var audit = getTransfer().new("security.Audit")>
		<cfinvoke component="#arguments.obj#" method="get#pkName#" returnvariable="pkValue"></cfinvoke>
			<cfset audit.setObjectClass(arguments.obj.getClassname())>
			<cfset audit.setPrimaryKey(pkValue)>
			<cfset audit.setAction(arguments.action)>
			<cfset audit.setAuditDate(now())>
			<cfset audit.setJsonMemento(arguments.obj.toJSON())>
			<cfif (getSecurityService().userInSession())>
				<cfset audit.setUser(getSecurityService().getCurrentUser())>
			</cfif>
			<cfset getTransfer().save(audit)>
	</cffunction>

	<cffunction name="setCreateMap" access="private" returntype="void" output="false" hint="I set the createMap property.">
		<cfargument name="CreateMap" type="struct" required="true">
		<cfset variables.CreateMap = arguments.CreateMap >
	</cffunction>
	
	<cffunction name="getCreateMap" access="private" returntype="struct" output="false" hint="I return the createMap property.">
		<cfreturn variables.CreateMap />
	</cffunction>

	<cffunction name="setUpdateMap" access="private" returntype="void" output="false" hint="I set the updateMap property.">
	<cfargument name="UpdateMap" type="struct" required="true">
		<cfset variables.UpdateMap = arguments.UpdateMap >
	</cffunction>
	
	<cffunction name="getUpdateMap" access="private" returntype="struct" output="false" hint="I return the updateMap property.">
		<cfreturn variables.UpdateMap />
	</cffunction>
	
	<cffunction name="setDeleteMap" access="private" returntype="void" output="false" hint="I set the deleteMap property.">
	<cfargument name="DeleteMap" type="struct" required="true">
		<cfset variables.DeleteMap = arguments.DeleteMap >
	</cffunction>
	
	<cffunction name="getDeleteMap" access="private" returntype="struct" output="false" hint="I return the deleteMap property.">
		<cfreturn variables.DeleteMap />
	</cffunction>

	<!--- dependencies --->

	<cffunction name="setTransfer" access="public" returntype="void" output="false" hint="I set a reference to Transfer.">
		<cfargument name="Transfer" type="transfer.com.Transfer" required="true">
		<cfset variables.Transfer = arguments.Transfer >
	</cffunction>
	
	<cffunction name="getTransfer" access="public" returntype="transfer.com.Transfer" output="false" hint="I return Transfer.">
		<cfreturn variables.Transfer />
	</cffunction>

	<cffunction name="setSecurityService" access="public" returntype="void" output="false" hint="I set a reference to the SecurityService.">
		<cfargument name="SecurityService" type="any" required="true">
		<cfset variables.SecurityService = arguments.SecurityService >
	</cffunction>
	
	<cffunction name="getSecurityService" access="public" returntype="any" output="false" hint="I return the SecurityService.">
		<cfreturn variables.SecurityService />
	</cffunction>

</cfcomponent>