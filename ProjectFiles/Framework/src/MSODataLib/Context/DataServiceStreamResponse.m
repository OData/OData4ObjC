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



#import "DataServiceStreamResponse.h"

#import "constants.h"
#import "ODataServiceException.h"

@implementation DataServiceStreamResponse
@synthesize m_httpResponse;

- (void) dealloc
{
	[m_headers release];
	m_headers = nil;
	
	[m_httpResponse release];
	m_httpResponse = nil;
		
	[super dealloc];
}

- (id) initWithHttpResponse:(HttpResponse*)aHttpResponse
{
	if(self = [super init])
	{
		if(aHttpResponse)
			[self setHttpResponse:aHttpResponse];
		
		if([m_httpResponse getHeaders] != nil)
		{
			m_headers = [[NSMutableDictionary alloc] initWithDictionary:[m_httpResponse getHeaders]];
		}
		else
		{
			m_headers = [[NSMutableArray alloc] init];
		}
		
    }
	return self;
}

/**     
 * @return <array>
 * Returns all m_headers
 */
- (NSMutableDictionary*) getHeaders
{
	return m_headers;
}

/**     
 * @return <string>
 * Returns value of HTTP Content Disposition header
 */
- (NSString*) getContentDisposition
{
	NSString *value = [m_headers objectForKey:HttpRequestHeader_ContentDisposition];
	return value;
}

/**     
 * @return <string>
 * Returns value of HTTP Content Type header
 */
- (NSString*) getContentType
{
	NSString *value = [m_headers objectForKey:HttpRequestHeader_ContentType];
	return value;
}

/**     
 * @return <binaryStream>
 * Retruns associated binary stream
 */
- (NSString *) getStream
{
	return [m_httpResponse getHTMLFriendlyBody];
}

@end
