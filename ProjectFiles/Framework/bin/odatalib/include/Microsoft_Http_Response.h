
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

#import <Foundation/Foundation.h>


@interface Microsoft_Http_Response : NSObject 
{
	NSString *m_version;
    NSInteger m_code;
    NSString *m_message;
    NSMutableDictionary *m_headers;
    NSString *m_body;
}

@property (nonatomic, retain,getter=getVersion,setter=setVersion)NSString *m_version;
@property (nonatomic, retain,getter=getMessage,setter=setMessage)NSString *m_message;
@property (nonatomic, retain,getter=getHeaders,setter=setHeaders)NSMutableDictionary *m_headers;
@property (nonatomic, retain,getter=getBody,setter=setBody) NSString *m_body;
@property (nonatomic, assign,getter=getCode,setter=setCode) NSInteger m_code;


-(id)initWithCode:(NSInteger)code responseheaders:(NSMutableDictionary *)headers responseBody:(NSString *)body responseVersion:(NSString *)version responseMessage:(NSString *)mesage;
+ (Microsoft_Http_Response *) fromString:(NSString *)response_str;
+ (NSInteger)extractCode:(NSString *)response_str;
+ (NSMutableDictionary *)extractHeaders:(NSString *)response_str;
+ (NSString *)extractBody:(NSString *)response_str;
+ (NSString *)extractVersion:(NSString *)response_str;
+ (NSString *)extractMessage:(NSString *)response_str;

@end
