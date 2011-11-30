
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

#import "Microsoft_Http_Response.h"


@implementation Microsoft_Http_Response

@synthesize m_version;
@synthesize m_code;
@synthesize m_message;
@synthesize m_headers;
@synthesize m_body;

-(void)dealloc
{
	[m_version release];
	m_version = nil;
    [m_message release];
	m_message = nil;
    [m_headers release];
	m_headers = nil;
    [m_body release];
	m_body = nil;
	[super dealloc];
}

-(id)initWithCode:(NSInteger)code responseheaders:(NSMutableDictionary  *)headers responseBody:(NSString *)body responseVersion:(NSString *)version responseMessage:(NSString *)message
{
	if(self = [super init])
	{
		[self setCode:code];
		[self setHeaders:headers];
		[self setBody:body];
		[self setVersion:version];
		[self setMessage:message];
	}
	return self;
}

+ (Microsoft_Http_Response *) fromString:(NSString *)response_str
{
	NSInteger code    = [self extractCode:response_str];
	NSMutableDictionary *headers = [self extractHeaders:response_str];
	NSString *body    = [self extractBody:response_str];
	NSString *version = [self extractVersion:response_str];
	NSString *message = [self extractMessage:response_str];
	
	Microsoft_Http_Response *response = [[Microsoft_Http_Response alloc] initWithCode:code responseheaders:headers responseBody:body responseVersion:version responseMessage:message];
	return [response autorelease];
}

+ (NSInteger)extractCode:(NSString *)response_str
{ 
	
	NSError *error = NULL; 
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=HTTP/[\\d\\.x]{3} )\\d+"
																		   options:NSRegularExpressionCaseInsensitive 
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:response_str options:0 range:NSMakeRange(0, [response_str length])];
	
	if ([matches count] < 1) {
		return 0;
	}
	
	NSTextCheckingResult *firstResult = [matches objectAtIndex:0]; 
	NSString *code = [response_str substringWithRange:firstResult.range];
	
	return [code intValue]; 
	
}

+ (NSMutableDictionary *)extractHeaders:(NSString *)response_str
{
	
	NSError *error = NULL; 
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:\\r?\\n){2}[\\w\\W]+?(?:\\r?\\n){2}"
																		   options:NSRegularExpressionCaseInsensitive 
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:response_str options:0 range:NSMakeRange(0, [response_str length])];
	
	NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:1];
	
	for (int i = 0; i <[matches count]; i++) {
		NSTextCheckingResult *textCheck = [matches objectAtIndex:i];
		NSString *match = [response_str substringWithRange:textCheck.range];
		NSArray *lines = [[match stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\r\n"];
		
		for(int j=0;j<[lines count];j++)
		{
			NSString *line = [lines objectAtIndex:j];
			
			if([line isEqualToString:@""])
				continue; 
			
			NSArray *keyValueArray = [line componentsSeparatedByString:@": "];
			
			if ([keyValueArray count] >= 2) {
				//coalesce all entries after 0
				NSString *value = [keyValueArray objectAtIndex:1];
				
				for (int k = 2; k < [keyValueArray count]; k++) {
					value = [value stringByAppendingString:[keyValueArray objectAtIndex:k]];
				}
				
				//add key value pair to headers dict
				[headers setObject:value forKey:[keyValueArray objectAtIndex:0]];
			}
		} 
		
	}
	
	return headers; 
	
}


+ (NSString *)extractBody:(NSString *)response_str
{ 
	NSError *error = NULL; 
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:\\r?\\n){2}[\\w\\W]+?(?:\\r?\\n){2}"
																		   options:NSRegularExpressionCaseInsensitive 
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:response_str options:0 range:NSMakeRange(0, [response_str length])];
	
	if ([matches count] > 0) {
		NSTextCheckingResult *result = [matches objectAtIndex:0];
		
		//take the body after headers
		NSString *body = [response_str substringFromIndex:(result.range.location + result.range.length)]; 
		return body;
	}
	
	return @""; 
	
}

+ (NSString *)extractVersion:(NSString *)response_str
{ 
	NSError *error = NULL; 
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=HTTP/)[\\d\\.x]{3}(?= \\d+)"
																		   options:NSRegularExpressionCaseInsensitive 
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:response_str options:0 range:NSMakeRange(0, [response_str length])];
	
	if ([matches count] >= 1) {
		NSTextCheckingResult *firstResult = [matches objectAtIndex:0];
		NSString *version = [response_str substringWithRange:firstResult.range];
		
		return version;
	}
	
	return @"";
	
}

+ (NSString *)extractMessage:(NSString *)response_str
{	
	NSError *error = NULL; 
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=HTTP/[\\d\\.x]{3} \\d{3} )[^\\r\\n]+" 
																		   options:NSRegularExpressionCaseInsensitive 
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:response_str options:0 range:NSMakeRange(0, [response_str length])];
	
	if ([matches count] >= 1) {
		NSTextCheckingResult *firstResult = [matches objectAtIndex:0];
		NSString *message = [response_str substringWithRange:firstResult.range];
		
		return message;
	}
	
	return @""; 
	
}

@end
