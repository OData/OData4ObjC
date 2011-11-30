
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


#import "HttpResponse.h"

@implementation HttpResponse

@synthesize m_HttpBody;
@synthesize m_HttpHeaders;
@synthesize m_HttpCode;
@synthesize m_HttpMessage;
@synthesize m_Httperror;


- (void) dealloc
{
	[m_HttpBody release];
	m_HttpBody = nil;
	[m_HttpHeaders release];
	m_HttpHeaders = nil;
	[m_HttpMessage release];
	m_HttpMessage = nil;
	[super dealloc];
}

- (id) initWithHTTP:(NSData *)aBody headers:(NSMutableDictionary *)aHeader httpCode:(NSInteger)aCode httpMessage:(NSString *)message
{
	if(self = [super init])
	{
		[self setHttpBody:aBody];
		[self setHttpHeaders:aHeader];
		[self setHttpCode:aCode];
		if(message)
			[self setHttpMessage:message];
		else
		{
			NSString* tmpCode = [NSString stringWithFormat:@"%d",aCode];
			[self setHttpMessage:[self retriveStatusMessage:tmpCode]];
		}
	}
	return self;
}

- (NSData *) getBody
{
	return [self getHttpBody];
}

- (NSString *) getHTMLFriendlyBody
{
	NSString *htmlBody = nil;
	
	if([self getBody])
		htmlBody = [[NSString alloc] initWithData:[self getBody] encoding:NSUTF8StringEncoding];
	return [htmlBody autorelease];
}


- (NSMutableDictionary *) getHeaders
{
	return [self getHttpHeaders];
}


- (NSString *) getMessage
{
	return [self getHttpMessage];
}

- (NSInteger) getCode
{
	return [self getHttpCode];
}

-(NSString *) retriveStatusMessage:(NSString *)tmpCode
{
	NSMutableDictionary *gStatusMessage = [NSMutableDictionary dictionaryWithCapacity:41];
	
	// Informational 1xx
	[gStatusMessage setObject:@"Continue" forKey:@"100"];
	[gStatusMessage setObject:@"Switching Protocols" forKey:@"101"];
	
	// Success 2xx
	[gStatusMessage setObject:@"OK" forKey:@"200"];
	[gStatusMessage setObject:@"Created" forKey:@"201"];
	[gStatusMessage setObject:@"Accepted" forKey:@"202"];
	[gStatusMessage setObject:@"Non-Authoritative Information" forKey:@"203"];
	[gStatusMessage setObject:@"No Content" forKey:@"204"];
	[gStatusMessage setObject:@"Reset Content" forKey:@"205"];
	[gStatusMessage setObject:@"Partial Content" forKey:@"206"];
	
	// Redirection 3xx
	[gStatusMessage setObject:@"Multiple Choices" forKey:@"300"];
	[gStatusMessage setObject:@"Moved Permanently" forKey:@"301"];
	[gStatusMessage setObject:@"Found" forKey:@"302"]; //1.1
	[gStatusMessage setObject:@"See Other" forKey:@"303"];
	[gStatusMessage setObject:@"Not Modified" forKey:@"304"];
	[gStatusMessage setObject:@"Use Proxy" forKey:@"305"];
	[gStatusMessage setObject:@"" forKey:@"306"];// // 306 is deprecated but reserved
	[gStatusMessage setObject:@"Temporary Redirect" forKey:@"307"];
	
	// Client Error 4xx
	[gStatusMessage setObject:@"Bad Request" forKey:@"400"];
	[gStatusMessage setObject:@"Unauthorized" forKey:@"401"];
	[gStatusMessage setObject:@"Payment Required" forKey:@"402"];
	[gStatusMessage setObject:@"Forbidden" forKey:@"403"];
	[gStatusMessage setObject:@"Not Found" forKey:@"404"];
	[gStatusMessage setObject:@"Method Not Allowed" forKey:@"405"];
	[gStatusMessage setObject:@"Not Acceptable" forKey:@"406"];
	[gStatusMessage setObject:@"Proxy Authentication Required" forKey:@"407"];
	[gStatusMessage setObject:@"Request Timeout" forKey:@"408"];
	[gStatusMessage setObject:@"Conflict" forKey:@"409"];
	[gStatusMessage setObject:@"Gone" forKey:@"410"];
	[gStatusMessage setObject:@"Length Required" forKey:@"411"];
	[gStatusMessage setObject:@"Precondition Failed" forKey:@"412"];
	[gStatusMessage setObject:@"Request Entity Too Large" forKey:@"413"];
	[gStatusMessage setObject:@"Request-URI Too Long" forKey:@"414"];
	[gStatusMessage setObject:@"Unsupported Media Type" forKey:@"415"];
	[gStatusMessage setObject:@"Requested Range Not Satisfiable" forKey:@"416"];
	[gStatusMessage setObject:@"Expectation Failed" forKey:@"417"];
	
	// Server Error 5xx
	[gStatusMessage setObject:@"Internal Server Error" forKey:@"500"];
	[gStatusMessage setObject:@"Not Implemented" forKey:@"501"];
	[gStatusMessage setObject:@"Bad Gateway" forKey:@"502"];
	[gStatusMessage setObject:@"Service Unavailable" forKey:@"503"];
	[gStatusMessage setObject:@"Gateway Timeout" forKey:@"504"];
	[gStatusMessage setObject:@"HTTP m_version Not Supported" forKey:@"505"];
	[gStatusMessage setObject:@"Bandwidth Limit Exceeded" forKey:@"509"];
	
	return [gStatusMessage objectForKey:tmpCode];
}

@end
