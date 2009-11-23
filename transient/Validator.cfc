<!--- 
	Copyright 2009 Matt Quackenbush, Paul Marcotte
	
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

<cfcomponent hint="I am a generic Validator class" displayname="Validator" output="false">

	<cfscript>
		variables.properties.errors = [];
	</cfscript>

	<cffunction name="init" hint="Initializes the object" returntype="Validator" output="false" access="public">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="setup" hint="I setup the object" returntype="void" output="no" access="public">
		<cfscript>
			setInvalidEmailList(""); // default to an empty list
		</cfscript>
	</cffunction>

	<cffunction name="validate" hint="I validate the object" returntype="boolean" output="no" access="public">
		<cfargument name="obj" hint="The object to validate" required="yes" type="any" />
		<cfargument name="context" hint="The context for which to validate; e.g. 'register' or 'change password'" required="yes" type="string" />
		
		<cfscript>
			var rules = obj.getRules(context);
			var success = true;
			var theDependency = "";
			var compareTo = "";
			var value = "";
			var message = "";
			var rule = "";
			var r = 0;
			
			for ( r=1; r LTE arrayLen(rules); r=r+1 ) { // rules loop
				rule = rules[r];
				
				// reset 'success' for this rule
				success = true;
				// set a dummy message to use if one isn't provided
				message = rule.label & " failed " & rule.testtype & " validation.";
				
				// only grab the value if the testtype is not 'method'; 'method' will run its own custom test
				if ( rule.testtype IS NOT "method" ) {
					value = invokeGetter(
									obj: obj, 
									getter: rule.property
								);
				} else {
					value = "";
				}
				
				// only grab theDependency if this rule isDependent
				if ( rule.isDependent ) {
					theDependency = invokeGetter(
									obj: obj, 
									getter: rule.dependency
								);
				} else {
					theDependency = "";
				}
				
				/* 
				*	we only care about the rule if
				*		1) the rule *is not* dependent, and 
				*			a) it is 'required' or 
				*			b) it is not to be ignored on an empty value or 
				*			c) a value was supplied
				*	OR 
				*		2) the rule *is* dependent, and 
				*			a) a dependencyValue *was not* provided and 
				*			b) theDependency has a value 
				*	OR 
				*		3) the rule *is* dependent, and 
				*			a) a dependencyValue *was* provided and 
				*			b) theDependency's value matches the provided dependencyValue
				*/
				if ( ((NOT rule.isDependent) // 1
						AND 
							((rule.testtype IS "required") // 1a
						OR 
							(NOT rule.ignoreOnEmpty) // 1b
						OR 
							(hasValue(value)))) // 1c
					OR 
						((rule.isDependent) // 2
						AND 
							(NOT structKeyExists(rule, "dependencyValue")) // 2a
						AND 
							(hasValue(theDependency))) // 2b
					OR 
						 ((rule.isDependent) // 3
						 AND 
						 	(structKeyExists(rule, "dependencyValue")) // 3a
						 AND 
						 	(isMatchNoCase(rule.dependencyValue, theDependency))) // 3b
					) {
					
					// if the testtype is not one of our 'special' ones, pass it along to isValid()
					if ( reFindNoCase("(alpha|alphanum|bool|boolean|daterange|email|inList|inListNoCase|int|integer|isMatch|isMatchNoCase|isNot|isNotNoCase|method|notInList|notInListNoCase|range|regex|regular_expression|required)", rule.testtype) EQ 0 ) {
						
						success = isValid(rule.testtype, value);
						
					} else {
						
						// it's one of ours; check to see which one
						switch ( rule.testtype ) {
							case "alpha" : {
								success = isAlpha(value, rule.allowSpaces);
								message = rule.label & " contains non-alpha characters.";
								break;
							}
							case "alphaNum" : {
								success = isAlphaNum(value, rule.allowSpaces);
								message = rule.label & " contains non-alphanumeric characters.";
								break;
							}
							case "boolean" : case "bool" : {
								success = isBool(value);
								message = rule.label & " is not a boolean.";
								break;
							}
							case "daterange" : {
								
								if ( (NOT isDate(value)) 
										OR 
											((structKeyExists(rule, "low")) 
										AND 
											(dateCompare(value, rule.low) LT 0)) 
										OR 
											((structKeyExists(rule, "high")) 
										AND 
											(dateCompare(value, rule.high) GT 0)) ) {
									success = false;
									message = rule.label & " failed date range validation.";
									
								}
								
								break;
							}
							case "email" : {
								success = ((isValid("email", value)) AND (listFindNoCase(getInvalidEmailList(), value) EQ 0));
								message = rule.label & " is not a valid email address.";
								break;
							}
							case "inList" : {
								success = (listFind(rule.list, value) GT 0);
								message = rule.label & " is not a valid value.";
								break;
							}
							case "inListNoCase" : {
								success = (listFindNoCase(rule.list, value) GT 0);
								message = rule.label & " is not a valid value.";
								break;
							}
							case "integer" : case "int" : {
								success = isInteger(value);
								message = rule.label & " is not an integer.";
								break;
							}
							case "isMatch" : case "isMatchNoCase" : {
								if ( structKeyExists(rule, "compareProperty") ) {
									compareTo = invokeGetter(
														obj: obj, 
														getter: rule.compareProperty
													);
								} else {
									compareTo = rule.compareValue;
								}
								
								if ( rule.testtype IS "isMatch" ) {
									success = (isMatch(value, compareTo));
								} else {
									success = (isMatchNoCase(value, compareTo));
								}
								message = rule.label & " is not a valid value.";
								break;
							}
							case "isNot" : case "isNotNoCase" : {
								if ( structKeyExists(rule, "compareProperty") ) {
									compareTo = invokeGetter(
														obj: obj, 
														getter: rule.compareProperty
													);
								} else {
									compareTo = rule.compareValue;
								}
								
								if ( rule.testtype IS "isNot" ) {
									success = (NOT isMatch(value, compareTo));
								} else {
									success = (NOT isMatchNoCase(value, compareTo));
								}
								message = rule.label & " is not a valid value.";
								break;
							}
							case "method" : {
								success = invokeMethod(obj, rule.method);
								break;
							}
							case "notInList" : {
								success = (listFind(rule.list, value) EQ 0);
								message = rule.label & " is not a valid value.";
								break;
							}
							case "notInListNoCase" : {
								success = (listFindNoCase(rule.list, value) EQ 0);
								message = rule.label & " is not a valid value.";
								break;
							}
							case "range" : {
								success = isValid("range", value, rule.low, rule.high);
								break;
							}
							case "regex" : case "regular_expression" : {
								/* 
								*	7/14/08 MPQ - isValid() has a bug
								*	NOT isValid("regex", value, rule.pattern)
								*	http://www.quackfuzed.com/index.cfm/2008/7/15/isValid-Bug
								*	use reFind() instead
								*/
								success = (reFind(rule.pattern, value) GT 0);
								message = rule.label & " does not match the provided pattern.";
								break;
							}
							case "required" : {
								success = ((isSimpleValue(value) AND len(trim(value)) GT 0) OR (NOT isSimpleValue(value)));
								message = rule.label & " is required.";
								break;
							}
						} // END: special testtype switch
						
					} // END: check for 'special' testtype
					
					if ( NOT success ) {
						// overwrite the dummy message if one was provided
						if ( structKeyExists(rule, "message") ) {
							message = rule.message;
						}
						
						addError(
							property: rule.property, 
							message: message
						);
					} // END success check
					
					// run a character length test if low|high was provided and testtype is 'string' or 'regex'
					if ( (reFindNoCase("\A(string|regex|regular_expression)\Z", rule.testtype) GT 0) 
							AND 
								(isSimpleValue(value)) ) {
						
						if ( ((structKeyExists(rule, "low")) 
								AND 
									(rule.low GT 0) 
								AND 
									(len(value) LT rule.low)) 
								OR 
									((structKeyExists(rule, "high")) 
								AND 
									(rule.high GT 0) 
								AND 
									(len(value) GT rule.high)) ) {
							
							addError(
								property: rule.property, 
								message: rule.label & " failed character length validation."
							);
							
						}
						
					} // END: character length check
					
				} // END: run rule check
				
			} // end rules loop
			
			return (NOT hasErrors());
		</cfscript>
	</cffunction>

	<cffunction name="getErrors" hint="Returns an array of error messages; each index of the array contains a struct with two keys: .property is the property to which the error message refers; .message is the error message itself" returntype="array" output="no" access="public">
		<cfreturn variables.properties.errors />
	</cffunction>

	<cffunction name="hasErrors" hint="Returns a boolean indication of whether or not there were validation errors" returntype="boolean" output="no" access="public">
		<cfreturn (arrayLen(getErrors()) GT 0) />
	</cffunction>

	<cffunction name="addError" hint="I add an error message to the errors collection" returntype="void" output="no" access="public">
		<cfargument name="property" hint="Name of the property that is invalid" required="yes" type="string" />
		<cfargument name="message" hint="The error message to add" required="yes" type="string" />
		
		<cfscript>
			var st = {property=property,message=message};
			
			arrayAppend(getErrors(), st);
		</cfscript>
	</cffunction>

	<cffunction name="addErrors" hint="Appends an array of error structs to the errors array" returntype="void" output="false" access="public">
		<cfargument name="errors" hint="An array of error structs" required="yes" type="array" />
		
		<cfscript>
			var e = 0;
			
			for ( e=1; e <= arrayLen(errors); e++ ) {
				arrayAppend(getErrors(), errors[e]);
			}
		</cfscript>
	</cffunction>

	<cffunction name="getInvalidEmailList" hint="Retrieves the invalidEmailList property" returntype="string" output="false" access="public">
		<cfreturn variables.properties.invalidEmailList />
	</cffunction>

	<cffunction name="setInvalidEmailList" hint="Sets the invalidEmailList property" returntype="void" output="false" access="public">
		<cfargument name="invalidEmailList" hint="The invalidEmailList property" required="yes" type="string" />
		
		<cfset variables.properties.invalidEmailList = arguments.invalidEmailList />
	</cffunction>

	<!--- private --->

	<cffunction name="isAlpha" hint="Returns a boolean indication of whether or not the supplied string contains only alpha characters" returntype="boolean" output="false" access="private">
		<cfargument name="value" hint="The string to be validated" required="yes" type="string" />
		<cfargument name="allowSpaces" hint="Boolean indication of whether or not to allow spaces; defaults to false" required="no" type="boolean" default="no" />
		
		<cfscript>
			if ( allowSpaces ) {
				value = replace(value, " ", "", "all");
			}
			
			if ( reFindNoCase("[^[:alpha:]]+", value) EQ 0 ) {
				return true;
			}
			
			return false;
		</cfscript>
	</cffunction>

	<cffunction name="isAlphaNum" hint="Returns a boolean indication of whether or not the supplied string contains only alpha-numeric characters" returntype="boolean" output="false" access="private">
		<cfargument name="value" hint="The string to be validated" required="yes" type="string" />
		<cfargument name="allowSpaces" hint="Boolean indication of whether or not to allow spaces; defaults to false" required="no" type="boolean" default="no" />
		
		<cfscript>
			if ( arguments.allowSpaces ) {
				value = replaceNoCase(value, " ", "", "all");
			}
			
			if ( reFindNoCase("[^[:alnum:]]+", value) EQ 0 ) {
				return true;
			}
			
			return false;
		</cfscript>
	</cffunction>

	<cffunction name="isBit" hint="Returns a boolean indication of whether or not the provided string is valid for bit datatype entry" returntype="boolean" output="false" access="private">
		<cfargument name="value" hint="The string to be compared" required="yes" type="string" />
		
		<cfscript>
			return (value == 1) || (value == 0);
		</cfscript>
	</cffunction>

	<cffunction name="isBool" hint="Returns a boolean indication of whether or not the supplied string contains a boolean value; the built-in CF 'isBoolean()' method incorrectly returns true if a numeric value is passed in, even if it isn't 1 or 0" returntype="boolean" output="no" access="private">
		<cfargument name="value" hint="The string to be compared" required="yes" type="string" />
		
		<cfscript>
			return reFindNoCase("\A(yes|no|true|false|0|1)\Z", value) > 0;
		</cfscript>
	</cffunction>

	<cffunction name="isInteger" hint="Returns a boolean indication of whether or not the provided input is an integer (whole number)" returntype="boolean" output="false" access="private">
		<cfargument name="value" hint="The string to be validated" required="yes" type="string" />
		
		<cfscript>
			return (len(value) > 0) && (reFind("[\D]", value) == 0);
		</cfscript>
	</cffunction>

	<cffunction name="isMatch" hint="Returns a boolean indication of whether or not both of the supplied strings match (this is a CaSe SeNsItIvE check!)" returntype="boolean" output="false" access="private">
		<cfargument name="value1" hint="The first value to be compared" required="yes" type="string" />
		<cfargument name="value2" hint="The second value to be compared" required="yes" type="string" />
		
		<cfreturn (compare(value1, value2) EQ 0) />
	</cffunction>

	<cffunction name="isMatchNoCase" hint="Returns a boolean indication of whether or not both of the supplied strings match (this is a *NOT* a case sensitive check!)" returntype="boolean" output="false" access="private">
		<cfargument name="value1" hint="The first value to be compared" required="yes" type="string" />
		<cfargument name="value2" hint="The second value to be compared" required="yes" type="string" />
		
		<cfreturn (compareNoCase(value1, value2) EQ 0) />
	</cffunction>

	<cffunction name="hasValue" hint="I determine whether the provided value has a value (e.g. not an empty string); used internally" returntype="boolean" output="no" access="private">
		<cfargument name="value" hint="The value to check" required="yes" type="any" />
		
		<cfscript>
			return ((isSimpleValue(value) AND len(value) GT 0) OR (NOT isSimpleValue(value)));
		</cfscript>
	</cffunction>

	<cffunction name="invokeGetter" hint="A cfinvoke facade for running a getter" returntype="any" output="no" access="private">
		<cfargument name="obj" hint="The object to invoke" required="yes" type="any" />
		<cfargument name="getter" hint="The getter to invoke (e.g. to run getFoo(), supply 'Foo' to this argument)" required="yes" type="string" />
		
		<cfset var rtn = "" />
		
		<cfinvoke component="#obj#" method="get#arguments.getter#" returnvariable="rtn" />
		
		<cfreturn rtn />
	</cffunction>

	<cffunction name="invokeMethod" hint="A cfinvoke facade" returntype="any" output="no" access="private">
		<cfargument name="obj" hint="The object to invoke" required="yes" type="any" />
		<cfargument name="method" hint="The method to invoke" required="yes" type="string" />
		
		<cfset var rtn = "" />
		
		<cfinvoke component="#obj#" method="#method#" returnvariable="rtn" />
		
		<cfreturn rtn />
	</cffunction>

</cfcomponent>
