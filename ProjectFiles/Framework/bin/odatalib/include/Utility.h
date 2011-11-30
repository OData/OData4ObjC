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

#import "ODataObject.h"

@interface Utility: NSObject
{
}

+ (NSString*) getAcceptType;
+ (NSString*) getContentType;
+ (NSString*) getRequestGet;

+ (NSString*) getEntityNameFromType:(NSString*) aType;
+ (NSString*) getPropertyName:(NSString*) aRawProperty;
+ (NSInteger) reverseFind:(NSString*) aSourceString findString:(NSString*)aFindString;
+ (NSString*) getEntitySetFromUrl:(NSString*) anUri;
//+ (NSDictionary*) getAttributes($typeInstance);
+ (void) WriteLine:(NSString*)aLine inStream:(NSMutableString*) aStream;
+ (NSString*) getUri:(ODataObject*)anObject;
+ (BOOL) HttpSuccessCode:(NSNumber*)aHttpCode;
+ (NSString*) CreateUri:(NSString*)aBaseUri requestUri:(NSString*)aRequestUri;
+ (NSString*) TimeInISO8601;
+ (BOOL) IsAbsoluteUrl:(NSString*)anUrl;
+ (NSMutableDictionary*)CreateHeaders:(NSString*)aMethodType eTag:(NSString*)aETag ODataServiceVersion:(NSString *)dataserviceversion;
+ (NSString*) getEntitySetFromUrl:(NSString*) anUri;

+ (NSString *) URLEncode:(NSString *) aString;
+ (NSString *) URLDecode:(NSString *) aString;

+ (NSString*) Base64Encode:(NSData*) anInputData onSeparateLines:(BOOL)separateLines;
+ (NSData*) Base64Decode:(NSString*) anInputString;

+ (NSString*) getEntityNameFromUrl:(NSString*) anUri;

@end
