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

#import "constants.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpProxy.h"
#import"HTTPHandler.h"

@interface ACSUtil : NSObject
{
    NSString			*m_serviceNamespace;
    NSString			*m_wrapName;
    NSString			*m_wrapPassword;
    NSString			*m_wrapScope;
    NSMutableDictionary *m_claims;
    HttpProxy			*m_proxy;
    NSString			*m_token;
}

@property ( nonatomic , retain , getter=getServiceNamespace ,	setter=setServiceNamespace	) NSString *m_serviceNamespace;
@property ( nonatomic , retain , getter=getWrapName ,			setter=setWrapName			) NSString *m_wrapName;
@property ( nonatomic , retain , getter=getWrapPassword ,		setter=setWrapPassword		) NSString *m_wrapPassword;
@property ( nonatomic , retain , getter=getWrapScope ,			setter=setWrapScope			) NSString *m_wrapScope;
@property ( nonatomic , retain , getter=getClaims ,				setter=setClaims			) NSMutableDictionary *m_claims;
@property ( nonatomic , retain , getter=getProxy ,				setter=setProxy				) HttpProxy *m_proxy;
@property ( nonatomic , retain , getter=getToken ,				setter=setToken				) NSString *m_token;

/**
 * Constructor. It will initialize the member variables.
 */
- (id) initWithServiceName:(NSString*) aServiceName wrapName:(NSString*)aWrapName wrapPassword:(NSString*)aWrapPassword wrapScope:(NSString*)aWrapScope claims:(NSMutableDictionary*)aClaims proxy:(HttpProxy*)aProxy;

/**
 * To create authorization header. It will call the function getACSToken for getting token, create an entry in dictionary for authorization and return the dictionary. 
 */
- (NSDictionary*) getSignedHeaders;

/**
 * To get token from ACS. Throws NSException if error occurred.
 */
- (NSString*) getACSToken;


@end

