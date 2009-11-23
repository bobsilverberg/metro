/* 
 *	Copyright 2008 Paul Marcotte
 *	
 *	Licensed under the Apache License, Version 2.0 (the "License");
 *	you may not use this file except in compliance with the License.
 *	You may obtain a copy of the License at
 *	
 *		http://www.apache.org/licenses/LICENSE-2.0
 *	
 *	Unless required by applicable law or agreed to in writing, software
 *	distributed under the License is distributed on an "AS IS" BASIS,
 *	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *	See the License for the specific language governing permissions and
 *	limitations under the License.
 *
 *
 * a simple rules based form validator for forms designed
 * to provide both blur and submit validation
 */

jQuery.fn.formrules = function(rules) {
	var theForm = this;
	// regex rules
	var emailRegxp = /^([\w]+)(.[\w]+)*@([\w]+)(.[\w]{2,3}){1,2}$/;
	// methods
	var clearAll = function () {
		jQuery(theForm).find("input").each(function() {
			if (jQuery(this).attr("type") != "hidden")
			{
				var id = jQuery(this).attr("id");
				clear(this,rules[id].label);
			}			
		});
	
		jQuery(theForm).find("select").each(function() {
			var id = jQuery(this).attr("id");
			clear(this,rules[id].label);
		});
		
		jQuery(theForm).find("textarea").each(function() {
			var id = jQuery(this).attr("id");
			clear(this,rules[id].label);
		});
	
	}
	var clear = function (el,message) {
		jQuery(el).parent().removeClass("error").find("label").html(message);
	}
	var setInvalid = function (el,message) {
		jQuery(el).parent().addClass("error").find("label").html(message);
	}
	var setValid = function (el,message) {
		jQuery(el).parent().removeClass("error").find("label").html(message);
	}
	var validate = function (el) {
		var id="",message="",rule="",isValid=true,value="";
		id = jQuery(el).attr("id");
		if (typeof rules[id] != "undefined")
		{
			rule = rules[id];
			// apply required rule
			value = jQuery(el).val();
			if ((rule.required) && (value.length == 0))
			{
				message = rule.label + " is required!";				
			}
			// apply range rule
			if(message.length == 0)
			{
				if ((rule.datatype == "string") && ((typeof rule.range != "undefined") && (rule.required)))
				{
					if ((value.length < rule.range.min) || (value.length > rule.range.max))
					{
						message = rule.label + " must be between " + rule.range.min + " and " + rule.range.max + " characters.";
					}
				}
				else if ((rule.datatype == "numeric") && ((typeof rule.range != "undefined") && (rule.required)))
				{
					if ((Number(value) < rule.range.min) || (Number(value) > rule.range.max))
					{
						message = rule.label + " must be greater than or equal to " + rule.range.min + " and less than or equal to " + rule.range.max + ".";
					}
				}
				else if (rule.datatype == "email")
				{
					if (emailRegxp.test(value) != true)
					{
						message = rule.label + " is invalid";
					}
				}
				
			}
			// apply equalsProperty rule
			if (rule.equalsProperty != undefined)
			{
				if (value != jQuery("#"+rule.equalsProperty).val())
				{
					message = rule.label + " does not match " + rule.equalsProperty + ".";
				}
			}
			// if message is zero length string, field is valid
			isValid = (message.length == 0)?true:false;
		}
		if (!isValid)
		{
			setInvalid(el,message);
		}
		else
		{
			setValid(el,rule.label);
		}
		return isValid;
	}
	
	var addBlurValidation = function(target) {
		jQuery(target).blur(function(){
				validate(this);			
			});
	}
	
	/*
	 * attach onBlur validation to input fields that are not hidden
	 */
	jQuery(this).find("input").each(function() {
		var id = jQuery(this).attr("id");
		var rule = rules[id];
		if (jQuery(this).attr("type") != "hidden")
		{
			addBlurValidation(this);
		}
		
		if ((rules[id]) && (rules[id].datatype == "date"))
		{
			jQuery(this).datepicker();
		}			
	});
	
	/*
	 * attach onBlur validation to select fields that are not hidden
	 */
	jQuery(this).find("select").each(function() {
		addBlurValidation(this);
	});
	
	/*
	 * attach onBlur validation to textarea that are not hidden
	 */
	jQuery(this).find("textarea").each(function() {
		addBlurValidation(this);
	});
	
	/*
	 * attach onSubmit validation to to form for input fields that are not hidden
	 */
	jQuery(this).submit(function() {
		var valid = true;
		jQuery(this).find("input").each(function() {
			if (jQuery(this).attr("type") != "hidden")
			{
				if (!(validate(this)))
				{
					valid = false;
				}
			}
		});
		
		jQuery(this).find("select").each(function() {
			if (!(validate(this)))
			{
				valid = false;
			}
		});
		
		jQuery(this).find("textarea").each(function() {
			if (!(validate(this)))
			{
				valid = false;
			}
		});
		
		return valid;		
	});
	
	/*
	 * when reset button is clicked, remove prompt
	 */
	jQuery(this).find("button").each(function() {
		if (jQuery(this).attr("id") == "reset") {
			jQuery(this).click(function () {
				clearAll();
			});				
		}			
	});
}; 