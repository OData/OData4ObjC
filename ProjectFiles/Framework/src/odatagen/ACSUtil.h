
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

#import"HTTPHandler.h"

@interface ACSUtil : NSObject
{
    NSString *serviceNamespace;
    NSString *wrapName;
    NSString *wrapPassword;
    NSString *wrapScope;
    NSMutableDictionary *claims;
    NSString *token;
}

@property ( nonatomic , retain ) NSString *serviceNamespace;
@property ( nonatomic , retain ) NSString *wrapName;
@property ( nonatomic , retain ) NSString *wrapPassword;
@property ( nonatomic , retain ) NSString *wrapScope;
@property ( nonatomic , retain ) NSMutableDictionary *claims;
@property ( nonatomic , retain ) NSString *token;

- (id) initWithServiceName:(NSString*) aServiceName wrapName:(NSString*)aWrapName wrapPassword:(NSString*)aWrapPassword wrapScope:(NSString*)aWrapScope claims:(NSMutableDictionary*)aClaims;
- (NSMutableDictionary*) getSignedHeaders;
- (NSString*) getACSToken;
- (NSString *) encodeString:(NSString *) aString;
- (NSString *) decodeString:(NSString *) aString;

@end

