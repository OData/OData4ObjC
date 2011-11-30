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

#import "ODataServiceException.h"


@implementation ODataServiceException
@synthesize m_error,m_detailedError;
@synthesize m_headers;
@synthesize m_statusCode;

-(id) init
{
	self=[super initWithName:@"ODataServiceException" reason:nil userInfo:nil];
	return self;
}

-(id) initWithError:(NSString *)anError contentType:(NSString *)aContentType headers:(NSDictionary *)aHeaders statusCode:(NSInteger)aStatusCode
{
	if(self=[super initWithName:@"ODataServiceException" reason:anError userInfo:nil])
	{
		self.m_error=anError;
		self.m_headers=[[NSDictionary alloc]initWithDictionary:aHeaders];
		self.m_statusCode=aStatusCode;
	}
	return self;
}

- (void) dealloc
{
	[m_error release];
	m_error = nil;
	[m_detailedError release];
	m_detailedError = nil;
	[m_headers release];
	m_headers = nil;
	[super dealloc];
}

@end
