
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

#import "ACSUtil.h"

@implementation ACSUtil
@synthesize serviceNamespace , wrapName;
@synthesize wrapPassword , wrapScope;
@synthesize claims;
@synthesize token;


/*
 * Destructor to release the memory allocated to member variables.
 */
- (void) dealloc
{
	[serviceNamespace release];
	serviceNamespace = nil;
	
	[wrapName release];
	wrapName = nil;
	
	[wrapPassword release];
	wrapPassword = nil;
	
	[wrapScope release];
	wrapScope = nil;
	
	[claims release];
	claims = nil;
	
	[token release];
	token = nil;
	
	[super dealloc];
}
/**
 *Constructor. It will initialize the member variables.
 */
- (id) initWithServiceName:(NSString*) aServiceName wrapName:(NSString*)aWrapName wrapPassword:(NSString*)aWrapPassword wrapScope:(NSString*)aWrapScope claims:(NSMutableDictionary*)aClaims;
{
	if(self=[super init])
	{
		if(aServiceName)
			serviceNamespace=aServiceName;			
		
		if(aWrapName)
			wrapName=aWrapName;
		
		if(aWrapPassword)
			wrapPassword=aWrapPassword;
		
		if(aWrapScope)
			wrapScope=aWrapScope;
		
		if(aClaims)
			claims=aClaims;
	}
	return self;
}
/**
 * To get encoded string in URL Format
 */
- (NSString *) encodeString:(NSString *) aString
{
	aString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																  NULL,
																  (CFStringRef)aString,
																  NULL,
																  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																  kCFStringEncodingUTF8 );
	
	return aString;
}
/**
 * To get decoded string in URL Format
 */
- (NSString *) decodeString:(NSString *) aString
{
	aString=(NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
																   (CFStringRef)aString,
																   CFSTR(""));
	
	return aString;
}

/**
 * To create authorization header. It will call the function getACSToken for getting token, create an entry in dictionary for authorization and return the dictionary. 
 */
- (NSMutableDictionary*) getSignedHeaders
{
	NSString *accessToken=[NSString stringWithFormat:@"%c%@%c",'"',[self getACSToken],'"'];
	accessToken=[self decodeString:accessToken];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"WRAP access_token=%@",accessToken],@"Authorization",nil];
	return [dict autorelease];
}
/**
 * To get token from ACS. Throws NSException if error occurred.
 */
- (NSString*) getACSToken
{
	HTTPHandler *httpRequest =[[HTTPHandler alloc]init];
	@try 
	{
		NSString *postBody = [NSString stringWithFormat:@"wrap_scope=%@&wrap_name=%@&wrap_password=%@",
							  [self encodeString:wrapScope], [self encodeString:wrapName],[self encodeString:wrapPassword]];
							
		NSEnumerator *enumerator = [claims keyEnumerator];
		NSString* key;
		while(key = [ enumerator nextObject] )
		{
			NSString *value = [claims objectForKey:key];
			if(value)
			{
				postBody = [postBody stringByAppendingFormat:@"&%@=%@",key,value];
			}
		}

		NSString *url = [NSString stringWithFormat:@"https://%@.accesscontrol.windows.net/WRAPv0.9/" , serviceNamespace];
		[httpRequest performHTTPRequest:url username:nil password:nil headers:nil httpbody:[postBody dataUsingEncoding:NSUTF8StringEncoding] httpmethod:@"POST"];
		
		if([httpRequest http_error])
		{
			NSException *anException = [NSException exceptionWithName:@"Exception" reason:@"" userInfo:nil];
			[anException raise];
		}
			
		[self setToken:[[NSString alloc] initWithData:[httpRequest http_response] encoding:NSUTF8StringEncoding]];
		
		NSRange range = [token rangeOfString:@"Error"];
		if(range.length > 0)
		{
			NSException *anException = [NSException exceptionWithName:@"ACSUtilException" reason:[NSString stringWithFormat:@"Invalid Token received: %@",token] userInfo:nil];
			[anException raise];
		}
		
		NSArray *params = [token componentsSeparatedByString:@"&"];
		if(params)
		{
			NSString *firstobject = [params objectAtIndex:0];
			if(firstobject)
			{
				range = [firstobject rangeOfString:@"wrap_access_token"];
				if(range.length > 0 )
				{
					NSArray *parts = [firstobject componentsSeparatedByString:@"="];
					
					if(parts && [parts count] > 1)
					{
						[self setToken:[parts objectAtIndex:1]];
					}
				}
			}
		}
		else
		{
			NSException *anException = [NSException exceptionWithName:@"ACSUtilException" reason:[NSString stringWithFormat:@"Invalid Token received: %@",token] userInfo:nil];
			[anException raise];
		}
	}
	@catch(NSException *exception)
	{
		@throw exception;
	}
	@finally 
	{
		[httpRequest release];
		httpRequest = nil;
	}

	return token;
}
		
@end

