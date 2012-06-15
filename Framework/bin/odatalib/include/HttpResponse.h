
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


@interface HttpResponse: NSObject
{
	NSData *m_HttpBody;
	NSMutableDictionary *m_HttpHeaders;
	NSInteger m_HttpCode;
	NSString *m_HttpMessage;
	//change for issue no. 61
	NSError	*m_Httperror;
}


@property ( nonatomic , retain , getter=getHttpBody    , setter=setHttpBody:     ) NSData *m_HttpBody;
@property ( nonatomic , retain , getter=getHttpHeaders , setter=setHttpHeaders:	) NSMutableDictionary *m_HttpHeaders;
@property ( nonatomic , getter=getHttpCode             , setter=setHttpCode:		) NSInteger m_HttpCode;
@property ( nonatomic , retain , getter=getHttpMessage , setter=setHttpMessage:	) NSString *m_HttpMessage;
//change for issue no. 61
@property ( nonatomic , retain , getter=getHttpError   , setter=setHttpError:	) NSError *m_Httperror;


- (id) initWithHTTP:(NSData *)aBody headers:(NSMutableDictionary *)aHeader httpCode:(NSInteger)aCode httpMessage:(NSString *)message;
- (NSData *) getBody;
- (NSString *) getHTMLFriendlyBody;
- (NSMutableDictionary *) getHeaders;
- (NSString *) getMessage;
- (NSInteger) getCode;
-(NSString *) retriveStatusMessage:(NSString *)tmpCode;

@end
