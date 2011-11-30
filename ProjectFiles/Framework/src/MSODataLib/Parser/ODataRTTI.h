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

#import <Foundation/Foundation.h>

@class ODataBool;

@interface ODataRTTI : NSObject {
	
}

+(NSString *)getVariableDataType:(id) object varname:(NSString *)variablename;
+(void)setObjectInstanceVariable:(id)object varname:(NSString *)variablename value:(id)classvalue;
+(void)setObjectInstanceVariable:(id) object varname:(NSString *)variablename varval:(NSString *)value;
+(void)getAllVariableNames:(id) object variableNamesArray:(NSMutableArray *)variablenames;
+(id)getObjectInstanceVariable:(id)object variablename:(NSString *)varname; 
+(NSString *)getObjectInstanceVariableValue:(id)object variablename:(NSString *)varname isComplex:(ODataBool *)complex;
+(NSString *)getObjectClassName:(id)object;

@end
