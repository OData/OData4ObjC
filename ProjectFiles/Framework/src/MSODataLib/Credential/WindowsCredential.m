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

#import "WindowsCredential.h"


@implementation WindowsCredential

@synthesize m_userName, m_password;

-(void) dealloc
{
	[m_userName release];
	m_userName = nil;
	
	[m_password release];
	m_password = nil;
	
	[super dealloc];
}


- (id) initWithUserName:(NSString *)anUserName password:(NSString *)aPassword
{
	if(self=[super init])
	{
		if(!anUserName || !aPassword)
		{
			NSException *anException = [NSException exceptionWithName:@"Invalid Input" reason:@"UserName/Password should not be nil" userInfo:nil];
			[anException raise];
			
		}
		[self setUserName:anUserName];
		[self setPassword:aPassword];
	}
	return self;
}

/**Dummy function*/
-(void)setProxy:(HttpProxy*)aProxy
{
	//dummy
}

- (NSDictionary*) getSignedHeaders:(NSString*)aRequestUrl
{
	//dummy
	return nil;
}

/**
 * Get credential type.
 */
- (NSString *) getCredentialType
{
	return [CredentialType WINDOWS];
}

@end
