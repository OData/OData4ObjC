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


#import "QueryOperationResponse.h"
#import "constants.h"
#import "ODataObject.h"
#import "DataServiceRequestException.h"
#import "ODataServiceException.h"

@implementation QueryOperationResponse
@synthesize m_innerException , m_statusCode , m_query , m_countValue ,m_inlineCountValue;
@synthesize m_objectIDToNextLinkUrl;
@synthesize m_result;

- (void) dealloc
{
	[m_innerException release];
	m_innerException = nil;
	
	[m_query release];
	m_query = nil;
	
	[m_headers release];
	m_headers = nil;
	
	[m_result release];
	m_result = nil;
	
	[m_objectIDToNextLinkUrl release];
	m_objectIDToNextLinkUrl = nil;
	
	[super dealloc];
}

/**
 * @param <array> m_headers
 * @param <string> m_innerException
 * @param <Integer> m_statusCode
 * @param <Uri> m_query
 */
- (id) initWithValues:(NSDictionary*) aHeaders innerException:(NSString*)anInnerException statusCode:(NSInteger) aStatusCode query:(NSString*) aQuery
{
	if(self = [super init])
	{
		if(aHeaders)			
			m_headers			= [[NSMutableDictionary alloc] initWithDictionary:aHeaders];
		else
			m_headers			= [[NSMutableDictionary alloc] init];
		
		if(anInnerException)	
			[self setInnerException:[NSString stringWithString:anInnerException]];
		else
			[self setInnerException:[NSString stringWithString:@""]];
			
		if(aQuery)
			[self setQuery:[NSString stringWithString:aQuery]];
		else
			[self setQuery:[NSString stringWithString:@""]];
		
		[self setObjectIDToNextLinkUrl:[[[NSMutableDictionary alloc] init]autorelease]];
		self.m_statusCode								= aStatusCode;
		self.m_countValue								= 0;
		self.m_inlineCountValue							= -1;
	}
	return self;
}

- (NSDictionary*) getHeaders
{
	return m_headers;
}


- (NSInteger) totalCount
{
	if(m_inlineCountValue == -1)
	{
		@throw [[[ODataServiceException alloc]initWithError:Resource_CountNotPresent contentType:nil headers:m_headers statusCode:m_statusCode]autorelease];
	}
    return m_inlineCountValue;
}

/**
 *
 * @param <EntitySetCollection> collection
 * @return <DataServiceQueryContinuation>
 */
- (DataServiceQueryContinuation*) getContinuation:(NSArray*)collection
{
	if(collection == nil)
    {
		if( [m_objectIDToNextLinkUrl count] == 0)
		{
			return nil;
		}
		else
			return [[[DataServiceQueryContinuation alloc] initWithNextLinkURI:[m_objectIDToNextLinkUrl objectForKey:@"0"]]autorelease];
		
	}
	
	ODataObject* obj = [collection objectAtIndex:0];
	if(obj == nil)
	{
		return nil;
	}
	
    NSString *key = [obj getObjectID];
	NSString *value = nil;
	
	if(key != nil )
	{
		value = [m_objectIDToNextLinkUrl objectForKey:key];
		
		if(value == nil)
		{
			QueryOperationResponse *queryOperationResponse = [[[QueryOperationResponse alloc] initWithValues:nil innerException:Resource_CollectionNotBelongsToQueryResponse statusCode:0 query:nil] autorelease];
			@throw [[[DataServiceRequestException alloc] initWithResponse:queryOperationResponse]autorelease];
		}
		else
		{
			return [[[DataServiceQueryContinuation alloc]initWithNextLinkURI:value] autorelease];
		}
	}      
	return nil;
	
}

@end
