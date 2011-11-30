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



#import "DataServiceSaveStream.h"

@implementation DataServiceSaveStream
@synthesize m_stream, m_args;

- (void) dealloc
{
	[m_stream release];
	m_stream = nil;
	
	[m_args release];
	m_args = nil;
	
	[super dealloc];
}

- (id) initWithStream:(ContentStream*)aStream dataServiceRequestArgs:(DataServiceRequestArgs*)aDataServiceRequestArgs
{
	if(self = [super init])
	{
		if(aStream) 
			[self setStream:aStream];
		
		[self setArgs:aDataServiceRequestArgs];
	}
	return self;
}

@end
