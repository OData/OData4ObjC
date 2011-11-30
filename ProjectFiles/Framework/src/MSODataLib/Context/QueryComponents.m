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


#import "QueryComponents.h"


@implementation QueryComponents
@synthesize m_uri, m_version;

- (void) dealloc
{
	[m_uri release];
	m_uri = nil;
	
	[m_version release];
	m_version = nil;
	
	[super dealloc];
}

- (id) init 
{
	
	if(self = [super init])
	{
		[self setUri:[NSString stringWithString:@""]];
		[self setVersion:[NSString stringWithString:@""]];
	}
	return self;
}

- (id) initWithUri: (NSString*) aUri version: (NSString*)aVersion 
{
	
	if(self = [super init])
	{
		if(aUri)		[self setUri:[NSString stringWithString:aUri]];
		else			[self setUri:[NSString stringWithString:@""]];
	
		if(aVersion)	[self setVersion:[NSString stringWithString:aVersion]];
		else		 	[self setVersion:[NSString stringWithString:@""]];
	}
	
	return self;
}

@end