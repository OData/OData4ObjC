
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

 
#import "HTTPHeaders.h"
#import "HttpProxy.h"

@interface HttpRequest: NSObject 
{
	HTTPHeaders *m_httpHeaders;	
	NSData *m_httpBody;
	NSString *m_httpMethod;
	NSString *m_url;
	id m_credential;
}

@property ( nonatomic , retain , getter=getHeaders ) HTTPHeaders *m_httpHeaders;
@property ( nonatomic , retain , getter=getBody ,			setter=setBody				) NSData *m_httpBody;
@property ( nonatomic , retain , getter=getMethod ,			setter=setMethod				) NSString *m_httpMethod;
@property ( nonatomic , retain , getter=getUri ,			setter=setUri				) NSString *m_url;
@property ( nonatomic , retain , getter=getCredential ,			setter=setCredential				) id m_credential;

-(NSString *)getHTMLFriendlyBody;
- (id) initWithUrl:(NSString*) anURL httpMethod:(NSString*) aHttpMethod credential:(id) aCredential header:(NSDictionary*)aHeader postBody:(NSData*)aPostBody;

@end