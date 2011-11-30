/*
 Copyright 2010 Microsoft Corp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ODataRTTI.h"
#import "ODataBool.h"
#include <objc/message.h>
#import "TableEntry.h"
#import "XMLGenerator.h"
#import "Utility.h"

@implementation ODataRTTI


/**
 * Retrives datatype of member variable for give object
 * @param id class object
 * @param NSString name of member variable
 * return NSString
 */
+(NSString *)getObjectClassName:(id)object
{
	if(object == nil)
		return nil;
	else
		return [NSString stringWithFormat:@"%s",class_getName([object class])];
}
+(NSString *)getVariableDataType:(id) object varname:(NSString *)variablename
{
	if(object == nil || variablename == nil)
		return nil;
	
	Ivar var = class_getInstanceVariable([object class],[variablename UTF8String]);
	
	if(var == nil)
		return nil;
	
	NSString *vartype = [NSString stringWithFormat:@"%s",ivar_getTypeEncoding(var)];
	return vartype;
}

/**
 * Set value of member variable for give object
 * @param id class object
 * @param NSString name of member variable
 * @param id value to be set
 * return NULL
 */
+(void)setObjectInstanceVariable:(id)object varname:(NSString *)variablename value:(id)classvalue 
{
	object_setInstanceVariable(object, [variablename UTF8String],classvalue);
}


/**
 * Set value of member variable for give object
 * @param id class object
 * @param NSString name of member variable
 * @param NSString value to be set
 * return NULL
 */
+(void)setObjectInstanceVariable:(id) object varname:(NSString *)variablename varval:(NSString *)value 
{
	if(object == nil || variablename == nil)
		return;
	
	id objectValue = nil;
	
	NSString *vartype = [ODataRTTI getVariableDataType:object varname:variablename];
	const char *type = [vartype UTF8String];
	ODataBool  *booleanval = [[ODataBool alloc] init];
	
	if(vartype == nil)
		return;
	if(value == nil)
	{
		objectValue = nil;
	}
	else if(strcmp(type,"@\"NSString\"") == 0 )
	{
		objectValue = [NSString stringWithFormat:@"%@",value];
	}
	else if(strcmp(type,"@\"NSNumber\"") == 0 )
	{
		NSNumber  *number = [NSNumber numberWithInt:[value intValue]];
		objectValue = number;
	}
	else if(strcmp(type,"@\"ODataBool\"") == 0 )
	{
		
		if([value isEqualToString:@"true"])
		{
			booleanval.booleanvalue = YES;
		}
		else if([value isEqualToString:@"false"])
		{
			booleanval.booleanvalue = NO;
		}
		objectValue = booleanval;
	}
	else if(strcmp(type,"@\"NSDecimalNumber\"") == 0 )
	{
		NSDecimalNumber  *decimal = [NSDecimalNumber decimalNumberWithString:value];
		objectValue = decimal;
	}
	else if(strcmp(type,"@\"NSDate\"") == 0 )
	{
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
		[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		NSRange range = [value rangeOfString:@"."];
		if (range.location != NSNotFound) {
			[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
		}else {
			NSArray *array = [value componentsSeparatedByString:@"T"];
			int cnt = [[[array objectAtIndex:1] componentsSeparatedByString:@":"] count];
			if(cnt == 2)
				[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm'Z'"];
			else if(cnt == 3)
				[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		}
		
		NSDate *date = [dateFormat dateFromString:value]; 
		
		[dateFormat release];
		objectValue = date;	
		
	}
	else if(strcmp(type,"@\"NSData\"") == 0)
	{
		NSData *data=[Utility dataWithBase64EncodedString:value];
		objectValue = data;
	}
	object_setInstanceVariable(object, [variablename UTF8String],[objectValue retain]);
	[booleanval release];
}

/**
 * get member variables for give object
 * @param in- id class object
 * @param out- array of member variable
 * return void
 */
+(void)getAllVariableNames:(id) object variableNamesArray:(NSMutableArray *)variablenames
{
	if(object == nil)
		return;
	
	NSUInteger count;
	Ivar *vars	= class_copyIvarList([object class], &count);
	
	for (int i=0; i<count; i++) 
	{
		Ivar var	= vars[i];
		const char *varname = ivar_getName(var);
		
		NSString *name = [NSString stringWithFormat:@"%s",varname];
		[variablenames addObject:name];
	}
	
	//Azure
	if( [object isKindOfClass:[TableEntry class]] )
	{
		vars	= class_copyIvarList([TableEntry class], &count);
		
		if((vars == nil) || (count == 0))
			return;
		
		for (int i=0; i<count; i++) 
		{
			Ivar var	= vars[i];
			const char *varname = ivar_getName(var);
			NSString *name = [NSString stringWithFormat:@"%s",varname];
			[variablenames addObject:name];
		}
	}
	if(([object superclass] != [ODataObject class]) && ([object superclass] != [NSObject class]))
	{
		[self getAllVariableNames:[object superclass] variableNamesArray:variablenames];
	}
	
	free(vars);
}

/**
 * Retrives member variable for give object
 * @param id class object
 * @param NSString name of member variable
 * return id
 */
+(id)getObjectInstanceVariable:(id)object variablename:(NSString *)varname 
{
	if(object == nil || varname == nil)
		return nil;
	
	Ivar var = class_getInstanceVariable([object class],[varname UTF8String]);	
	if(var == nil)
		return nil;
	
	return object_getIvar(object,var);
}


/**
 * Retrives value of member variable for give object
 * @param id class object
 * @param NSString name of member variable
 * @param ODataBool value for identifying complex type
 * return NSString
 */
+(NSString *)getObjectInstanceVariableValue:(id)object variablename:(NSString *)varname isComplex:(ODataBool *)complex 
{
	complex.booleanvalue = NO;
	if(object == nil || varname == nil)
		return nil;
	
	Ivar var = class_getInstanceVariable([object class],[varname UTF8String]);	
	if(var == nil)
		return nil;
	
	const char *type = ivar_getTypeEncoding(var);
	NSString *value = nil;
	if(strcmp(type,"@\"NSString\"") == 0)
	{
		NSString *strvalue = object_getIvar(object,var);
		if(strvalue)
			value = strvalue;
	}
	else if(strcmp(type,"@\"NSNumber\"") == 0 )
	{
		NSNumber  *number = object_getIvar(object,var);
		if(number)
			value = [number stringValue];
	}
	else if(strcmp(type,"@\"NSDecimalNumber\"") == 0 )
	{
		NSDecimalNumber  *decimal = object_getIvar(object,var);
		if(decimal)
			value = [decimal stringValue];
	}
	else if(strcmp(type,"@\"NSDate\"") == 0)
	{
		NSDate *dateTime = object_getIvar(object,var);
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		
		NSString *stringFromDate = [dateFormat stringFromDate:dateTime];
		[dateFormat release];
		if(stringFromDate)
			value = stringFromDate;
	}
	else if(strcmp(type,"@\"NSData\"") == 0)
	{
		NSData *data = object_getIvar(object,var);
		if(data)
		{
			NSString *strvalue =[Utility base64Encoding:data];
			if(strvalue)
				value = strvalue;
		}
	}
	else if(strcmp(type,"@\"ODataBool\"") == 0 )
	{
		ODataBool  *booleanval = object_getIvar(object,var);
		if(booleanval && booleanval.booleanvalue == YES)
		{
			value = @"true";
		}
		else 
		{
			value = @"false";
		}
	}
	else if(strcmp(type,"@\"NSArray\"") == 0 )
	{
	}
	else if(strcmp(type,"@\"NSMutableArray\"") == 0 ) 
	{
		NSMutableArray *arr=object_getIvar(object,var);
		if(arr)
			value=@"";
		else 
			value=@"NavigationProperty";
	}
	else if(strcmp(type,"@\"NSDictionary\"") == 0 ) 
	{
	}
	else if(strcmp(type,"@\"NSMutableDictionary\"") == 0 ) 
	{
	}		
	else
	{
		complex.booleanvalue = YES;
		value = nil;
	}
	return value;
}


@end
