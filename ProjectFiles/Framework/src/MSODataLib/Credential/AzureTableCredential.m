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

#import "AzureTableCredential.h"


@implementation AzureTableCredential
@synthesize m_azureTableUtil;

-(void) dealloc
{
	[m_azureTableUtil release];
	m_azureTableUtil = nil;
	
	[super dealloc];
}

- (id) initWithAccountName:(NSString *)anAccountName accountKey:(NSString *)anAccountKey userPathStyleUrl:(BOOL)anUserPathStyleUrl
{
	if(self=[super init])
	{
		self.m_azureTableUtil=[[AzureTableUtil alloc] initWithAccountName:anAccountName accountKey:anAccountKey usePathStyleUri:anUserPathStyleUrl];
	}
	return self;
}

/**
 *  Set the proxy
 */
- (void) setProxy:(HttpProxy*) aProxy;
{
	//dummy
}

/**
 * Get credential type.
 */
- (NSString *) getCredentialType
{
	return [CredentialType AZURE];
}


@end
