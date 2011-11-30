
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

#import "AtomEntry.h"


@implementation AtomEntry
@synthesize m_mediaLinkEntry , m_mediaContentUri , m_editMediaLink , m_streamETag,  m_entityETag , m_identity;

- (void) dealloc
{
	[m_mediaContentUri release];
	m_mediaContentUri = nil;
	
	[m_editMediaLink release];
	m_editMediaLink = nil;
	
	[m_streamETag release];
	m_streamETag = nil;
	
	[m_entityETag release];
	m_entityETag = nil;
	
	[m_identity release];
	m_identity = nil;
	
	[super dealloc];
}

- (id) init
{
	if(self = [super init])
	{
		self.m_mediaLinkEntry = NO;
	}
	return self;
}
@end
