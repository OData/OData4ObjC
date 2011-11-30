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


#import "DataServiceQueryContinuation.h"

@implementation DataServiceQueryContinuation
@synthesize m_nextLinkUri;

- (void) dealloc
{
	[m_nextLinkUri release];
	m_nextLinkUri = nil;
	[super dealloc];
}

- (id) initWithNextLinkURI:(NSString*) aNextLinkUri
{
	if(self = [super init])
	{
		[self setNextLinkUri:[NSString stringWithString:aNextLinkUri]]; 
		
	}
	return self;
}

- (NSString*) toString 
{
	return m_nextLinkUri;
}


/**
 *
 * @return <QueryComponents>
 * Create QueryComponent from _nextLinkUri and return it.
 */
- (QueryComponents*) createQueryComponents
{
	return [[QueryComponents alloc] initWithUri:m_nextLinkUri version:nil];
}

@end
