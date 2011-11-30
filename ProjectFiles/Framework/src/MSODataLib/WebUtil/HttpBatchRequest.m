
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

#import "HttpBatchRequest.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "ObjectContext.h"
#import "HttpBatchResponse.h"
#import "HTTPHeaders.h"
#import "HTTPHandler.h"

@implementation HttpBatchRequest

@synthesize m_httpRequest,m_context;

-(void)dealloc
{
	[m_httpRequest release];
	m_httpRequest = nil;
	
	[super dealloc];
}

-(id)initWithUri:(NSString *)uri batchBoundary:(NSString *)batchBounds batchRequestBody:(NSString *)body 
	   credentials:(id)credential batchHeaders:(NSMutableDictionary *)headers 
credentialsInHeaders:(BOOL)isCredentialInHeaders context:(ObjectContext *)objContext
{
	if(self = [super init])
	{
		NSString *batchBoundary = [NSString stringWithFormat:@"multipart/mixed; boundary=%@",batchBounds];
		NSData *postBody = [NSData dataWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
		NSMutableDictionary *requestHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
											    @"application/atom+xml,application/xml", @"Accept",
											    batchBoundary, @"Content-Type", 
											    @"1.0",@"DataServiceVersion", nil];
		
		
		NSArray *arrKeys = [headers allKeys];
		NSArray *arrValues = [headers allValues];
		for(int i = 0; i < [arrKeys count];i++)
		{
			[requestHeaders setObject:[arrValues objectAtIndex:i] forKey:[arrKeys objectAtIndex:i]];
		}
		
		HttpRequest *request = [[HttpRequest alloc] initWithUrl:uri 
											  httpMethod:@"BATCH" 
											  credential:credential 
											  header:requestHeaders 
									          postBody:postBody];
		[self setHTTPRequest:request];
		[self setContext:objContext];
		
		[request release];
	}
	return self;
}

-(HttpBatchResponse *) GetResponse
{
	HTTPHandler *httpHandle = [m_context executeHTTPRequest:[m_httpRequest getUri] httpmethod:[m_httpRequest getMethod] httpbodydata:[m_httpRequest getBody] etag:nil 
											 customHeaders:[[m_httpRequest getHeaders] getHttpHeaders]];
	
	if(httpHandle.http_status_code == 200 || httpHandle.http_status_code == 202)
		return [HttpBatchResponse CreateBatchResponse:[httpHandle getHTMLFriendlyBody]];
	else
		return nil;

}

@end
