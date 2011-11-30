
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

  
#import "HttpRequest.h"
#include "constants.h"
#include "AtomParser.h"

@implementation HttpRequest
@synthesize m_httpHeaders,m_httpBody,m_httpMethod,m_url,m_credential;


- (void) dealloc {

	[m_url release];
	m_url = nil;
	[m_httpMethod release];
	m_httpMethod = nil;
	[m_httpHeaders release];
	m_httpHeaders = nil;
	[m_httpBody release];
	m_httpBody = nil;
	[m_credential release];
	m_credential = nil;
	
	[super dealloc];
}
/**
 *
 * @param <string> m_httpMethod
 * @param <string> m_url
 * @param <Credentail> credential
 * @param <array> headers
 * @param <string> postBody
 * @return No return Value
 * Construct a HttpRequest object
 */

- (id) initWithUrl:(NSString*) anURL httpMethod:(NSString*) aHttpMethod credential:(id) aCredential header:(NSDictionary*)aHeader postBody:(NSData*)aPostBody  
{
	if(self = [super init])
	{
		
		if(anURL)		[self setUri:[NSString stringWithString:anURL]];
		else			[self setUri:[NSString stringWithString:@""]];
		
		if(aHttpMethod) [self setMethod:[NSString stringWithString:aHttpMethod]];
		else			[self setMethod:[NSString stringWithString:@""]];
		
		if(aCredential) [self setCredential:aCredential];
		else			[self setCredential:nil];
		
		[self setBody:aPostBody];		
		self.m_httpHeaders = [[HTTPHeaders alloc] initWithHeaders:aHeader];		
	}
	
	return self;
}

-(NSString *)getHTMLFriendlyBody
{
	NSString *htmlBody = [[NSString alloc] initWithData:[self getBody] encoding:NSUTF8StringEncoding];
	return [htmlBody autorelease];
}

@end
