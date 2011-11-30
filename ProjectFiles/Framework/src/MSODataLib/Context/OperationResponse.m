
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

#import "OperationResponse.h"

@implementation OperationResponse
@synthesize m_innerException , m_statusCode;

- (void) dealloc
{
	[m_innerException release];
	m_innerException = nil;
	
	[m_headers release];
	m_headers = nil;
	
	[super dealloc];
}

- (id) initWithHeaders:(NSDictionary*)aHeaders errorMsg:(NSString*)anErrorMsg statusCode:(NSInteger)aStatusCode
{
	if(self = [super init])
	{
		if(aHeaders)	m_headers			= [[NSMutableDictionary alloc] initWithDictionary:aHeaders];
		else			m_headers			= [[NSMutableDictionary alloc] init];
		
		if(anErrorMsg)	[self setInnerException:[NSString stringWithString:anErrorMsg]];
		else			[self setInnerException:[NSString stringWithString:@""]];
		
		self.m_statusCode						= aStatusCode;
    }
	return self;
}

- (NSString*) getError
{
	return m_innerException;
}

- (NSDictionary*) getHeaders
{
	return m_headers;
}

- (NSInteger) getStatusCode
{
	return m_statusCode;
}

@end
