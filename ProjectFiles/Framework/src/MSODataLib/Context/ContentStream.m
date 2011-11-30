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

#import "ContentStream.h"

@implementation ContentStream
@synthesize m_stream , m_knownMemoryStream;

- (void) dealloc
{
	[m_stream release];
	m_stream = nil;
	
	[super dealloc];
}

- (id) initWithStream:(NSData*)aStream isKnownMemoryStream:(BOOL) aKnownMemoryStream
{
	if(self = [super init])
	{
		[self setStream:aStream];
		self.m_knownMemoryStream = aKnownMemoryStream;
	}
	return self;
}

@end
