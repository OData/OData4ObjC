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
#import "ACSUtil.h"
#import "CredentialBase.h"

@interface ACSCredential : CredentialBase {
	ACSUtil *m_acsUtil;
}

@property(nonatomic,retain,getter=getACSUtil,setter=setACSUtil) ACSUtil *m_acsUtil;


- (id) initWithServiceName:(NSString*) aServiceName wrapName:(NSString*)aWrapName wrapPassword:(NSString*)aWrapPassword 
				 wrapScope:(NSString*)aWrapScope claims:(NSMutableDictionary*)aClaims proxy:(HttpProxy*)aProxy;

- (void) setProxy:(HttpProxy*) aProxy;
- (NSDictionary*) getSignedHeaders:(NSString*)aRequestUrl;

@end
