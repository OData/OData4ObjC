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


#import "DataServiceResponse.h"

@implementation DataServiceResponse
@synthesize m_batchResponse, m_headers , m_operationResponse , m_statusCode;

- (void) dealloc
{
	[m_headers release];
	m_headers = nil;
	
	[m_operationResponse release];
	m_operationResponse = nil;
	
	[super dealloc];
}

- (id) initWithHeader:(NSString*)aHeader statusCode:(NSInteger)aStatusCode operationResponse:(NSMutableArray*)anOperationResponse batchResponse:(BOOL)aBatchResponse;
{
	if(self = [super init])
	{
		if(aHeader)
		{
			[self setHeaders:[NSString stringWithString:aHeader]];
		}
		self.m_statusCode			=	aStatusCode;
		[self setOperationResponse:anOperationResponse];
		self.m_batchResponse		=	aBatchResponse;
    }
	return self;
}

@end