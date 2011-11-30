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

#import "ACSCredential.h"
#import "ACSUtilException.h"


@implementation ACSCredential
@synthesize m_acsUtil;

-(void) dealloc
{
	[m_acsUtil release];
	m_acsUtil = nil;
	
	[super dealloc];
}


- (id) initWithServiceName:(NSString*) aServiceName wrapName:(NSString*)aWrapName wrapPassword:(NSString*)aWrapPassword 
							wrapScope:(NSString*)aWrapScope claims:(NSMutableDictionary*)aClaims proxy:(HttpProxy*)aProxy
{
	if(self=[super init])
	{
		if(!aWrapName || !aWrapPassword)
		{
			NSException *anException = [NSException exceptionWithName:@"Invalid Input" reason:@"UserName/Password should not be nil" userInfo:nil];
			[anException raise];
			
		}
		self.m_acsUtil=[[ACSUtil alloc] initWithServiceName:aServiceName wrapName:aWrapName wrapPassword:aWrapPassword 
											 wrapScope:aWrapScope claims:aClaims proxy:aProxy];
	}
	return self;
}

/**
 * Set the proxy
 */
-  (void) setProxy:(HttpProxy*) aProxy
{
	[m_acsUtil setProxy:aProxy];
}

/**
 *  Get the signed headers
 */
- (NSDictionary*) getSignedHeaders:(NSString*)aRequestUrl
{
	@try 
	{
		return [m_acsUtil getSignedHeaders];
	}
	@catch (ACSUtilException *e)
	{
		@throw e;
	}
	@catch (NSException * e)
	{
		@throw e;
	}
	@finally 
	{
	
	}
	return nil;
}

/**
 * Get credential type.
 */
- (NSString *) getCredentialType
{
	return [CredentialType ACS];
}


@end
