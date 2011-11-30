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


#import "DataServiceRequestArgs.h"
#import "constants.h"


@implementation DataServiceRequestArgs

- (void) dealloc
{
	[m_headers release];
	m_headers =nil;
	[super dealloc];
 }

- (id) init
{
	if(self = [super init])
	{
		m_headers = [[NSMutableDictionary alloc] init];
	}
	return self;
}

/**
 *
 * @param <HttpRequestHeader::*> header
 * @Return<string>
 * Get a specific HTTP Header
 */
- (NSString*) getHeaderValue:(NSString*)aheader
{
	NSString * headerValue = [m_headers objectForKey:aheader];
	
	return headerValue;
}

/**
 *
 * @param <HttpRequestHeader::*> header
 * @param <string> value
 * Set a specific HTTP Header
 */
- (void) setHeaderValue:(NSString*)aKey value:(NSString*) aValue
{
	NSString * headerValue = [m_headers objectForKey:aKey];
	
	if(headerValue)
	{
		[m_headers removeObjectForKey:aKey];
	}
	
	if(aValue != nil)
	{
		[m_headers setObject:aValue forKey:aKey];
	}
}

/**
 * @param <string> value
 * Get the Accept header of the request message.
 */
- (NSString*) getAcceptContentType
{
	return [m_headers objectForKey:HttpRequestHeader_Accept];
}

/**
 * @param <string> value
 * Sets the Accept header of the request message.
 */
- (void) setAcceptContentType:(NSString*)aContentType
{
	[self setHeaderValue:HttpRequestHeader_Accept value:aContentType];
}

/**
 * @param <string> value
 * Get the Content-Type header of the request message.
 */
- (NSString*) getContentType
{
	return [self getHeaderValue:HttpRequestHeader_ContentType];
}

/**
 * @param <string> value
 * Sets the Content-Type header of the request message.
 */
- (void) setContentType:(NSString*)aValue
{
	[self setHeaderValue:HttpRequestHeader_ContentType value:aValue];
}

/**
 *
 * @return <string>
 * Get the Slug header of the request message.
 */
- (NSString*) getSlug
{
	return [self getHeaderValue:HttpRequestHeader_Slug];
}

/**
 *
 * @param <string> value
 * Set the Slug header of the request message.
 */
- (void) setSlug:(NSString*)aValue
{
	[self setHeaderValue:HttpRequestHeader_Slug value:aValue];
}

/**
 *
 * @return <array>
 * Returns all m_headers
 */
- (NSMutableDictionary*) getHeaders
{
	return m_headers;
}

@end
