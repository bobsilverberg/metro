<!--- 
	Copyright 2008 Matt Quackenbush, Paul Marcotte
	
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
<cfcomponent displayname="Decorator" output="false" extends="transfer.com.TransferDecorator" hint="I am the core Metro Transfer object decorator.">
	
	<cfscript>
		variables.properties = structNew();
		variables.properties.rules = structNew();
		variables.properties.contexts = structNew();
		variables.properties.contexts.all = arrayNew(1);
	</cfscript>
	
	<cffunction name="setup" access="public" output="false" returntype="void">
		<cfset var service = getServiceFactory().getService(ListFirst(getClassName(),"."))>
		<cfset setGateway(service.getGateway(ListLast(getClassName(),".")))>
		<cfset loadRules()>
	</cffunction>
	
	<cffunction name="getRules" hint="Returns the validation rules array" returntype="array" output="no" access="public">
		<cfargument name="context" hint="The context for which to validate; e.g. 'save', 'update'" required="no" type="string" default="all" />
		
		<cfscript>
			var rtn = arrayNew(1);
			var rule = "";
			var i = 0;
			
			// add in any context-specific rules
			if ( structKeyExists(variables.properties.contexts, arguments.context) ) {
				for ( i=1; i LTE arrayLen(variables.properties.contexts[arguments.context]); i=i+1 ) {
					arrayAppend(rtn, variables.properties.rules[variables.properties.contexts[arguments.context][i]]);
				}
			}
			
			if ( arguments.context IS NOT "all" ) {
				// add in all-context rules
				for ( i=1; i LTE arrayLen(variables.properties.contexts.all); i=i+1 ) {
					arrayAppend(rtn, variables.properties.rules[variables.properties.contexts.all[i]]);
				}
			}
			
			return rtn;
		</cfscript>
	</cffunction>

	<cffunction name="validate" hint="Validates the object" returntype="boolean" output="no" access="public">
		<cfargument name="context" hint="The context for which to validate; e.g. 'save', 'update'" required="no" type="string" default="all" />
		<cfargument name="preserve" hint="Boolean indication of whether or not to preserve the existing Validator; defaults to false" required="no" type="boolean" default="no" />
		
		<cfscript>
			if ( !preserve && !hasErrors() ) {
				setValidator();
			}
			
			setObjectIsValid(getValidator().validate(
												obj: this, 
												context: context
											));
			
			return getObjectIsValid();
		</cfscript>
	</cffunction>

	<cffunction name="populate" hint="Populates the bean with values from the passed argumentCollection" returntype="boolean" output="no" access="public">
		<cfargument name="args" hint="The arguments struct to populate the bean from" required="yes" type="struct" />
		
		<cfscript>
			var key = "";
			
			for ( key IN args ) {
				if ( structKeyExists(this, "set" & key) ) {
					
					try {
						invokeSetter(
									setter: key, 
									value: args[key]
								);
					} catch (any e) {
						if ( findNoCase("is not of type", e.message) > 0 ) {
							addError(
										property: key, 
										message: "The value provided (" & args[key] & ") is invalid."
									);
						} else {
							throw(
								type: "metro.core.Decorator.populate.unknownException", 
								message: e.message, 
								detail: e.detail
							);
						}
					}						
				}
			}
			
			
			return !hasErrors();
		</cfscript>
	</cffunction>
	
	<cffunction name="hasErrors" hint="Returns a boolean indication of whether or not the object has validation errors" returntype="boolean" output="no" access="public">
		<cfreturn getValidator().hasErrors() />
	</cffunction>

	<cffunction name="getErrors" hint="Returns the validation errors as an array of structs or a struct" returntype="any" output="no" access="public">
		<cfargument name="type" hint="Indicates whether to return an array or a struct; defaults to array" required="no" type="string" default="array" />
		
		<cfscript>
			var errs = "";
			var e = 0;
			var e2 = 0;
			var st = "";
			var used = "";
			
			if ( type != "struct" ) {
				// return the default array of structs
				return getValidator().getErrors();
			} else {
				// build the struct to return
				st = {};
				errs = getValidator().getErrors();
				for ( e=1; e <= arrayLen(errs); e++ ) {
					if ( listFind(used, e) == 0 ) {
						st[errs[e].property] = errs[e].message;
						
						// check for additional messages for this property; append if found
						for ( e2=e+1; e2 <= arrayLen(errs); e2++ ) {
							if ( (listFind(used, e2) == 0) && (compareNoCase(errs[e].property,errs[e2].property) == 0) ) {
								used = listAppend(used, e2);
								st[errs[e].property] = st[errs[e].property] & "<br />" & errs[e2].message;
							}
						} // END: e2 loop
					} // END: e-used ck
				} // END: e loop
				
				return st;
			}
		</cfscript>
	</cffunction>
		
	<cffunction name="toJSON" access="public" output="false" returntype="string" hint="I Copy data from the TO into a Struct serialized as JSON">
    
	    <!--- Get the MetaData and Properties --->
	    <cfset var TransferMetadata = getTransfer().getTransferMetaData(getClassName()) />
	    <cfset var memento = StructNew()>
	    <cfset var Properties = TransferMetadata.getPropertyIterator() />
	    <cfset var PrimaryKey = TransferMetadata.getPrimaryKey() />
	    <cfset var theProperty = 0 />
	    <cfset var varName = 0 />
	    <cfset var varType = 0 />
	    <cfset var varValue = 0 />
	    <cfset var i = 0 />
	
	    <!--- Put the Id into the Struct --->
	    <cfset varName = PrimaryKey.getName() />
	    <cfinvoke component="#this#" method="get#varName#" returnvariable="varValue" />
	    <!--- Need cftry because if overwrite is false an error can be thrown --->
	    <cftry>
	        <cfset StructInsert(memento,varName,varValue,true) />
	        <cfcatch type="any"></cfcatch>
	    </cftry>
	    <!--- Put the properties into the theStruct --->
	    <cfloop condition="#Properties.hasnext()#">
	        <cfset theProperty = Properties.next() />
	        <cfset varName = theProperty.getName() />
	        <cfinvoke component="#this#" method="get#varName#" returnvariable="varValue" />
	        <cftry>
	            <cfset StructInsert(memento,varName,varValue,true) />
	            <cfcatch type="any"></cfcatch>
	        </cftry>
	    </cfloop>
		<cfreturn SerializeJSON(memento)>
	</cffunction>
	
	<cffunction name="getPKName" access="public" output="false" returntype="string" hint="I return the Primary Key name.">
		<cfreturn getTransfer().getTransferMetadata(getClassName()).getPrimaryKey().getName()>
	</cffunction>
	
	<!--- dependencies --->
	
	<cffunction name="setServiceFactory" access="public" returntype="void" output="false">
		<cfargument name="ServiceFactory" type="metro.factory.ServiceFactory" required="true">
		<cfset variables.ServiceFactory = arguments.ServiceFactory >
	</cffunction>
	
	<cffunction name="getServiceFactory" access="public" returntype="metro.factory.ServiceFactory" output="false">
		<cfreturn variables.ServiceFactory />
	</cffunction>

	<cffunction name="setTransientFactory" access="public" returntype="void" output="false">
		<cfargument name="TransientFactory" type="metro.factory.TransientFactory" required="true">
		<cfset variables.TransientFactory = arguments.TransientFactory >
	</cffunction>
	
	<cffunction name="getTransientFactory" access="public" returntype="metro.factory.TransientFactory" output="false">
		<cfreturn variables.TransientFactory />
	</cffunction>

	<cffunction name="setValidator" access="public" output="false" returntype="void" hint="I set a reference to the generic Validator.">
		<cfargument name="Validator" type="any" required="false" hint="The Validator.">
		<cfif (not structkeyExists(arguments,"Validator"))>
			<cfset arguments.Validator = getTransientFactory().create("Validator")>
		</cfif>
		<cfset variables.properties.Validator = arguments.Validator>
	</cffunction>

	<cffunction name="getValidator" access="public" output="false" returntype="any" hint="I return the generic Validator.">
		<cfif (not structkeyExists(variables.properties,"Validator"))>
			<cfset setValidator()>
		</cfif>
		<cfreturn variables.properties.Validator>
	</cffunction>

	<!--- private --->

	<cffunction name="loadRules" hint="Loads the object's validation rules" returntype="void" output="no" access="private">
		<cfscript>
			throw(
				type: "metro.core.Decorator.loadRules.exception", 
				message: "This is an abstract decorator method that must be overwritten.  It should be used to load the #getClassName()# validation rules."
			);
		</cfscript>
	</cffunction>

	<cffunction name="setGateway" access="private" returntype="void" output="false">
		<cfargument name="Gateway" type="metro.core.Gateway" required="true">
		<cfset variables.Gateway = arguments.Gateway >
	</cffunction>
	
	<cffunction name="getGateway" access="private" returntype="metro.core.Gateway" output="false">
		<cfreturn variables.Gateway />
	</cffunction>

	<cffunction name="getObjectIsValid" hint="Retrieves the objectIsValid property" returntype="boolean" output="false" access="private">
		<cfscript>
			if ( !structKeyExists(variables.properties, "objectIsValid") ) {
				variables.properties.objectIsValid = false;
			}
			
			return variables.properties.objectIsValid;
		</cfscript>
	</cffunction>

	<cffunction name="setObjectIsValid" hint="Sets the objectIsValid property" returntype="void" output="false" access="private">
		<cfargument name="objectIsValid" hint="The objectIsValid property" required="yes" type="boolean" />
		
		<cfset variables.properties.objectIsValid = arguments.objectIsValid />
	</cffunction>
		
	<cffunction name="addError" hint="Adds an error to the validator" returntype="void" output="no" access="private">
		<cfargument name="property" hint="The property for the error " required="yes" type="string" />
		<cfargument name="message" hint="The error message" required="true" type="string">
		<cfset getValidator().addError(argumentCollection: arguments) />
	</cffunction>
	
	<cffunction name="addErrors" hint="Appends an array of error structs to the validation errors array" returntype="void" output="false" access="private">
		<cfargument name="errors" hint="An array of error structs" required="yes" type="array" />
		
		<cfscript>
			getValidator().addErrors(argumentCollection: arguments);
		</cfscript>
	</cffunction>
	
	<cffunction name="addRule" hint="Adds a validation rule to the rules collection" returntype="void" output="no" access="private">
		<cfargument name="property" hint="The property this rule applies to" required="yes" type="string" />
		<cfargument name="testtype" hint="The type of test this rule should perform" required="yes" type="string" />
		<cfargument name="label" hint="I am the display label for the property to be validated" required="no" type="string" />
		<cfargument name="ignoreOnEmpty" hint="I indicate whether the rule should be ignored if the property has no value set; defaults to false" required="no" type="boolean" default="false" />
		<cfargument name="contexts" hint="A comma-delimited list of contexts this rule should be applied to; defaults to all" required="no" type="string" default="all" />
		<cfargument name="message" hint="The message to display if the rule test fails validation" required="no" type="string" />
		<cfargument name="low" hint="I am the lowest acceptable value; if testtype is 'range', 'string', or 'regex', must be numeric; if testtype='date', must be date" required="no" type="any" />
		<cfargument name="high" hint="I am the highest acceptable value; if testtype is 'range', 'string', or 'regex', must be numeric; if testtype='date', must be date" required="no" type="any" />
		<cfargument name="compareProperty" hint="I provide the property that this property should be compared to" required="no" type="string" />
		<cfargument name="compareValue" hint="I provide the value that this property should be compared to" required="no" type="string" />
		<cfargument name="list" hint="The list of values to compare" required="no" type="string" />
		<cfargument name="allowSpaces" hint="Indicates whether or not spaces are permitted in the value; used when type='alpha' or type='alphaNum'; ignored otherwise" required="no" type="boolean" default="false" />
		<cfargument name="pattern" hint="The regular expression pattern the value must match" required="no" type="string" />
		<cfargument name="method" hint="Name of the method to invoke to perform this rule's test" required="no" type="string" />
		<cfargument name="isDependent" hint="Boolean indication of whether or not this rule is dependent upon another property; defaults to false" required="no" type="boolean" default="false" />
		<cfargument name="dependency" hint="Name of the property this rule is dependent upon" required="no" type="string" />
		<cfargument name="dependencyValue" hint="Value that the dependency property must match for this rule to be invoked" required="no" type="any" />
		<cfargument name="isRemovable" hint="Boolean indication of whether or not this rule is removable by a decorator that extends the one that set it; defaults to false" required="no" type="boolean" default="false" />
		
		<cfscript>
			var rule = structNew();
			var ruleName = "";
			var contextArr = listToArray(contexts);
			var i = 0;
			
			// set the args that always exist
			rule.property = property;
			rule.testtype = testtype;
			rule.ignoreOnEmpty = ignoreOnEmpty;
			rule.allowSpaces = allowSpaces;
			rule.isDependent = isDependent;
			
			// NOTE: see config() method comments for details about the various required/optional rules
			switch ( testtype ) {
				case "range" : {
					if ( (NOT structKeyExists(arguments, "low")
							OR 
								NOT structKeyExists(arguments, "high")) ) {
						throw(
							type: "metro.core.Decorator.addRule.noHighLow", 
							message: "You have set a rule for the " & property & " property to testtype: 'range' but did provide both the 'low' and 'high' arguments."
						);
					} else if ( NOT isNumeric(low) 
									OR 
										NOT isNumeric(high) ) {
						throw(
							type: "metro.core.Decorator.addRule.invalidHighLow", 
							message: "You have set a rule for the " & property & " property to testtype: 'range' but did provide *numeric* 'low' and 'high' arguments."
						);
					}
					
					break;
				}
				case "method" : {
					if ( NOT structKeyExists(arguments, "method") ) {
						throw(
							type: "metro.core.Decorator.addRule.noMethod", 
							message: "You have set a rule for the " & property & " property to testtype: 'method' but did provide the 'method' argument."
						);
					}
					
					break;
				}
				case "isMatch" : case "isMatchNoCase" : case "isNot" : case "isNotNoCase" : {
					if ( NOT structKeyExists(arguments, "compareProperty") 
							AND 
								NOT structKeyExists(arguments, "compareValue") ) {
						throw(
							type: "metro.core.Decorator.addRule.noComparisonValue", 
							message: "You have set a rule for the " & property & " property to testtype: '" & testtype & "' but did provide the 'compareProperty' or 'compareValue' argument."
						);
					} else if ( structKeyExists(arguments, "compareProperty") 
									AND 
										NOT structKeyExists(this, "get" & compareProperty) ) {
						throw(
							type: "metro.core.Decorator.addRule.noComparisonGetter", 
							message: "You have set a rule for the " & property & " property to testtype: '" & testtype & "' and supplied a 'compareProperty', but the 'get#compareProperty#()' method does not exist."
						);
					}
					
					break;
				}
				case "inList" : case "inListNoCase" : case "notInList" : case "notInListNoCase" : {
					if ( NOT structKeyExists(arguments, "list") ) {
						throw(
							type: "metro.core.Decorator.addRule.noList", 
							message: "You have set a rule for the " & property & " property to testtype: '" & testtype & "' but did provide the 'list' argument."
						);
					}
					
					break;
				}
				case "regex" : case "regular_expression" : {
					if ( NOT structKeyExists(arguments, "pattern") ) {
						throw(
							type: "metro.core.Decorator.addRule.noPattern", 
							message: "You have set a rule for the " & property & " property to testtype: 'regex' but did provide the 'pattern' argument."
						);
					}
					
					if ( (structKeyExists(arguments, "high") 
							AND 
								NOT isNumeric(high)) 
							OR 
								(structKeyExists(arguments, "low") 
							AND 
								NOT isNumeric(low)) ) {
						throw(
							type: "metro.core.Decorator.addRule.regex.invalidHighLow", 
							message: "You have set a rule for the " & property & " property to testtype: 'regex' but the provided 'low' and/or 'high' argument is not numeric."
						);
					}
					
					break;
				}
				case "daterange" : {
					if ( (structKeyExists(arguments, "high") 
							AND 
								NOT isDate(high)) 
							OR 
								(structKeyExists(arguments, "low") 
							AND 
								NOT isDate(low)) ) {
						throw(
							type: "metro.core.Decorator.addRule.date.invalidHighLow", 
							message: "You have set a rule for the " & property & " property to testtype: 'date' but the provided 'low' and/or 'high' argument is not a date."
						);
					}
					
					break;
				}
				case "string" : {
					if ( (structKeyExists(arguments, "high") 
							AND 
								NOT isNumeric(high)) 
							OR 
								(structKeyExists(arguments, "low") 
							AND 
								NOT isNumeric(low)) ) {
						throw(
							type: "metro.core.Decorator.addRule.string.invalidHighLow", 
							message: "You have set a rule for the " & property & " property to testtype: 'string' but the provided 'low' and/or 'high' argument is not numeric."
						);
					}
					
					break;
				}
			}
			
			if ( isDependent ) {
				if ( NOT structKeyExists(arguments, "dependency") ) {
					throw(
						type: "metro.core.Decorator.addRule.noDependency", 
						message: "You have set a rule for the " & property & " property with isDependent set to 'true' but did provide the 'dependency' argument."
					);
				} else if ( NOT structKeyExists(this, "get" & dependency) ) {
					throw(
						type: "metro.core.Decorator.addRule.noDependencyGetter", 
						message: "You have set a rule for the " & property & " property with isDependent set to 'true' but the 'get#dependency#()' method does not exist."
					);
				}
			} // END checking required/optional arguments
			
			// check for label
			if ( structKeyExists(arguments, "label") ) {
				rule.label = label;
			} else {
				rule.label = property;
			}
			
			/* set the optionals */
			if ( structKeyExists(arguments, "high") ) {
				rule.high = high;
			}
			if ( structKeyExists(arguments, "low") ) {
				rule.low = low;
			}
			if ( structKeyExists(arguments, "dependency") ) {
				rule.dependency = dependency;
			}
			if ( structKeyExists(arguments, "dependencyValue") ) {
				rule.dependencyValue = dependencyValue;
			}
			if ( structKeyExists(arguments, "method") ) {
				rule.method = method;
			}
			if ( structKeyExists(arguments, "compareValue") ) {
				rule.compareValue = compareValue;
			}
			if ( structKeyExists(arguments, "compareProperty") ) {
				rule.compareProperty = compareProperty;
			}
			if ( structKeyExists(arguments, "list") ) {
				rule.list = list;
			}
			if ( structKeyExists(arguments, "allowSpaces") ) {
				rule.allowSpaces = allowSpaces;
			}
			if ( structKeyExists(arguments, "pattern") ) {
				rule.pattern = pattern;
			}
			if ( structKeyExists(arguments, "message") ) {
				rule.message = message;
			}
			/* END: set the optionals */
			
			// set the context/rule
			if ( testtype IS NOT "method" ) {
				ruleName = property & "_" & testtype;
			} else {
				ruleName = property & "_method_" & method;
			}
			
			variables.properties.rules[ruleName] = rule;
			
			for ( i=1; i LTE arrayLen(contextArr); i++ ) {
				if ( NOT structKeyExists(variables.properties.contexts, contextArr[i]) ) {
					variables.properties.contexts[contextArr[i]] = [ruleName];
				} else {
					arrayAppend(variables.properties.contexts[contextArr[i]], ruleName);
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="invokeSetter" hint="A cfinvoke/cfinvokeargument facade for invoking a setter on the object" returntype="void" output="no" access="private">
		<!--- set the method arguments --->
		<cfargument name="setter" hint="The setter to invoke (e.g. to invoke setFoo(), provide 'Foo' to this argument)" required="yes" type="string" />
		<cfargument name="value" hint="The value to set" required="yes" type="any" />
		
		<cfif isSimpleValue(value)>
			<cfinvoke method="set#setter#">
				<cfinvokeargument name="#setter#" value="#trim(value)#" />
			</cfinvoke>
		<cfelse>
			<cfinvoke method="set#setter#">
				<cfinvokeargument name="#setter#" value="#value#" />
			</cfinvoke>
		</cfif>
	</cffunction>

	<cffunction name="invokeMethod" hint="A cfinvoke facade" returntype="any" output="no" access="private">
		<cfargument name="method" hint="The method to invoke" required="yes" type="string" />
		<cfargument name="args" hint="The method arguments" required="no" type="struct" default="#structNew()#" />
		<cfset var rtn = "" />
		
		<cfinvoke method="#method#" argumentcollection="#args#" returnvariable="rtn" />
		
		<cfreturn rtn />
	</cffunction>
	
</cfcomponent>