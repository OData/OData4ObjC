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
#import "AzureTableUtil.h"
#import "Utility.h"
#import "ACSUtilException.h"
@implementation ACSUtil
@synthesize m_serviceNamespace , m_wrapName;
@synthesize m_wrapPassword , m_wrapScope;
@synthesize m_claims , m_proxy;
@synthesize m_token;


/**
 * Destructor. Release the memory allocated to member variables.
 */
- (void) dealloc
{
	[m_serviceNamespace release];
	m_serviceNamespace = nil;
	
	[m_wrapName release];
	m_wrapName = nil;
	
	[m_wrapPassword release];
	m_wrapPassword = nil;
	
	[m_wrapScope release];
	m_wrapScope = nil;
	
	[m_claims release];
	m_claims = nil;
	
	[m_proxy release];
	m_proxy = nil;
	
	[m_token release];
	m_token = nil;
	
	[super dealloc];
}

/**
 * Constructor. It will initialize the member variables.
 */
- (id) initWithServiceName:(NSString*) aServiceName wrapName:(NSString*)aWrapName wrapPassword:(NSString*)aWrapPassword wrapScope:(NSString*)aWrapScope claims:(NSMutableDictionary*)aClaims proxy:(HttpProxy*)aProxy
{
	if(self=[super init])
	{
		if(aServiceName)
		{
			[self setServiceNamespace:aServiceName];
		}
		
		if(aWrapName)
		{
			[self setWrapName:aWrapName];
		}
		
		if(aWrapPassword)
		{
			[self setWrapPassword:aWrapPassword];
		}
		
		if(aWrapScope)
		{
			[self setWrapScope:aWrapScope];
		}
		
		if(aClaims)
		{
			[self setClaims:aClaims];
		}
		
		if(aProxy)
		{
			[self setProxy:aProxy];
		}
	}
	return self;
}
    
/**
 * To create authorization header. It will call the function getACSToken for getting token, create an entry in dictionary for authorization and return the dictionary. 
 */
- (NSDictionary*) getSignedHeaders
{
	NSString *accessToken=[NSString stringWithFormat:@"%c%@%c",'"',[self getACSToken],'"'];
	
	accessToken=[Utility URLDecode:accessToken];
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
							  [Utility URLEncode:m_wrapScope], [Utility URLEncode:m_wrapName],[Utility URLEncode:m_wrapPassword]];
							
		NSEnumerator *enumerator = [m_claims keyEnumerator];
		NSString* key;
		while(key = [ enumerator nextObject] )
		{
			NSString *value = [m_claims objectForKey:key];
			if(value)
			{
				postBody = [postBody stringByAppendingFormat:@"&%@=%@",key,value];
			}
		}

		NSString *url = [NSString stringWithFormat:@"https://%@.accesscontrol.windows.net/WRAPv0.9/" , m_serviceNamespace];
		
		[httpRequest performHTTPRequest:url username:nil password:nil headers:nil httpbody:[postBody dataUsingEncoding:NSUTF8StringEncoding] httpmethod:@"POST"];
	
		if([httpRequest http_error])
		{
			@throw [[[ACSUtilException alloc]initWithError:[[httpRequest http_error] localizedDescription] headers:[httpRequest http_response_headers] statusCode:[httpRequest http_status_code]]autorelease];
		}
			
		[self setToken:[[[NSString alloc] initWithData:[httpRequest http_response] encoding:NSUTF8StringEncoding]autorelease]];
		
		 NSRange range = [m_token rangeOfString:@"Error"];
		 
		if(range.length > 0)
		{
			@throw [[[ACSUtilException alloc]initWithError:[NSString stringWithFormat:@"Invalid Token received: %@",m_token] headers:nil statusCode:[httpRequest http_status_code]]autorelease];
			
		}
		
		NSArray *params = [m_token componentsSeparatedByString:@"&"];
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
			@throw [[[ACSUtilException alloc]initWithError:[NSString stringWithFormat:@"Invalid Token received: %@",m_token] headers:nil statusCode:[httpRequest http_status_code]]autorelease];
		}
	}
	@catch(ACSUtilException *exception)
	{
		@throw exception;
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

	return m_token;
}


@end

