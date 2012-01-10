/*
 Copyright 2010 OuterCurve Foundation
 
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

#import "HTTPHandler.h"


@interface HTTPHandler()

@property (nonatomic,retain, getter=getStringURL ,setter=setStringURL:) NSString *stringURL;	

@end

@implementation HTTPHandler

@synthesize http_response,http_error,http_status_code,http_response_headers,timeInterval;
@synthesize errDelegate,stringURL;

/**
 * Perform a HTTP request and store response 
 *
 * @param NSString user name required for HTTP request
 * @param NSString password required for HTTP request
 * @param NSMutableDictionary collections of HTTP request headers
 * @param NSData HTTP request body
 * @param NSString HTTP method 
 * @return NULL
 */
-(void)performHTTPRequest:(NSString *)url username:(NSString *)usr password:(NSString *)pwd headers:(NSMutableDictionary *)dict httpbody:(NSData *)body httpmethod:(NSString *)method 
{
	[self setStringURL:url];
	
	done = NO;
	user_name = usr;
	password = pwd;
	http_response = [[NSMutableData alloc]init];
	http_status_code = 0;
	http_response_headers = [[NSMutableDictionary alloc] init];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
									
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:[self getTimeInterval]];
	if(dict != nil)
	{
		id key, value;
		NSArray *keys = [dict allKeys];
		int count = [keys count];
		for (int i = 0; i < count; i++)
		{
			key = [keys objectAtIndex: i];
			value = [dict objectForKey: key];
			[theRequest setValue:value forHTTPHeaderField:key];
		}
		
	}
	if(body != nil)
		[theRequest setHTTPBody:body];
	
	if(method != nil)
		[theRequest setHTTPMethod:method];
	
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!done);
	
	[theConnection release];
}

/*
 * Delegate function for handling HTTP response
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse * httpResponse;
	    
    httpResponse = (NSHTTPURLResponse *) response;
    http_status_code = (ssize_t) httpResponse.statusCode;   
	NSDictionary *dict = [httpResponse allHeaderFields];
	
	if(dict != nil)
	{
		id key, value;
		NSArray *keys = [dict allKeys];
		int count = [keys count];
		for (int i = 0; i < count; i++)
		{
			key = [keys objectAtIndex: i];
			value = [dict objectForKey: key];
			[http_response_headers setValue:value forKey:key];
		}
	}
}


/*
 * Delegate functions for handling HTTP response
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	if ((http_status_code / 100) != 2) 
	 {
		 NSLog(@"status code : %@ ",[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) http_status_code]);
		 [errDelegate errorOccured:self andResourceUri:[self getStringURL]];
	 }
	 else 
	 {
		 NSLog(@"status code : %@ ",[NSString stringWithFormat:@"HTTP status code %zd", (ssize_t)http_status_code]);
	 }   
	done = YES;
}

/*
 * Delegate function for handling HTTP authentication
 */
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{	
	NSHTTPURLResponse * httpResponse;
	
    httpResponse = (NSHTTPURLResponse *) [challenge failureResponse];
	//Incase Usere is using sample aps behind some proxy it may fail and failuer count will increase 
	//hence this is additional condition for retrying the authentication 
	if (([challenge previousFailureCount]==0 || [challenge previousFailureCount]==1) && (user_name != nil) && (password != nil))
	{
		[[challenge sender] useCredential:[NSURLCredential credentialWithUser:user_name password:password persistence:NSURLCredentialPersistenceForSession] forAuthenticationChallenge:challenge];
	} 
	else 
	{
		[[challenge sender] cancelAuthenticationChallenge:challenge]; 		
	}
}

/*
 * Delegate function for handling HTTP connection
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

/*
 * Delegate functions for handling HTTP response error
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    http_error = [error retain];
	done = YES;
	http_status_code=[error code];
}

/*
 * Delegate function for handling HTTP data
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the downloaded chunk of data.
    [http_response appendData:[[data copy] autorelease]];
}

- (NSString *) getHTMLFriendlyBody
{
	NSString *htmlBody = nil;
	
	if([self http_response])
		htmlBody = [[NSString alloc] initWithData:[self http_response] encoding:NSUTF8StringEncoding];
	return [htmlBody autorelease];
}

- (void)dealloc 
{
	[http_response release];
	http_response = nil;
	
	[http_error release];
	http_error = nil;
	
	[http_response_headers release];
	http_response_headers = nil;
	
	[stringURL release];
	stringURL=nil;
	
    [super dealloc];
}
	

@end
