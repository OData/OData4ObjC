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
#import "ErrorDelegate.h"

@interface HTTPHandler : NSObject 
{
	
		/*
	 * The Http error message
	 */
	NSError * http_error;
	
	/*
	 * The Http response body
	 */
	NSMutableData *http_response;
	
	/*
	 * The User Name 
	 * required for HTTP request
	 */
	NSString *user_name;
	
	/*
	 * The User Password 
	 * required for HTTP request
	 */
	NSString *password;
	
	/*
	 * The Standard Http Code
	 * recieved after the HTTP 
	 * request is complete
	 */
	NSInteger http_status_code;
	
	/*
	 * The collection of HTTP Headers 
	 * recieved from HTTP response
	 */
	NSMutableDictionary *http_response_headers;
	
	/*
	 * Flag for HTTP Request complete
	 */
	BOOL done;
	
	NSTimeInterval timeInterval;
	
	id<ErrorDelegate> errDelegate;
}

@property (nonatomic, retain) NSMutableData *http_response;
@property (nonatomic, retain) NSError * http_error;
@property (nonatomic, assign) NSInteger http_status_code;
@property (copy) NSMutableDictionary *http_response_headers;
@property ( nonatomic, assign, getter=getTimeInterval, setter=setTimeInterval) NSTimeInterval timeInterval;

@property(nonatomic,assign, getter=getErrorDelegate ,setter=setErrorDelegate)id<ErrorDelegate> errDelegate;

-(void)performHTTPRequest:(NSString *)url username:(NSString *)usr password:(NSString *)pwd headers:(NSMutableDictionary *)dict httpbody:(NSData *)body httpmethod:(NSString *)method;
- (NSString *) getHTMLFriendlyBody;

@end
