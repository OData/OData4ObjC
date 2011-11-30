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

#import "AzureTableUtil.h"
#include <CommonCrypto/CommonHMAC.h>

#import "Utility.h"


@implementation AzureTableUtil
@synthesize m_accountName,m_accountKey,m_usePathStyleUri;

- (id) initWithAccountName:(NSString *)anAccountName accountKey:(NSString *)anAccountKey usePathStyleUri:(BOOL )anUsePathStyleUri
{
	if(self=[super init])
	{
		m_PREFIX_STORAGE_HEADER = @"x-ms-";
		m_AZURE_API_VERSION = @"2009-04-14";
		[self setAccountName:anAccountName];
		[self setAccountKey:anAccountKey];
		[self setUsePathStyleUri:anUsePathStyleUri];
	}
	return self;
}

/**
 * Prepare query string for signing
 *
 * @param  <string> $value Original query string
 * @return <string> Query string for signing
 */
- (NSString *) prepareQueryStringForSigning:(NSString *)aValue
{

	// Check for 'comp='
	if([aValue rangeOfString:@"comp="].length==0)
	{
		// If not found, no query string needed
		return @"";
	}
	else
	{
		if([aValue length]>0 && [aValue hasPrefix:@"?"])
		{
			aValue=[aValue substringFromIndex:1];
		}
		// Split parts
		NSArray *queryParts=[aValue componentsSeparatedByString:@"&"];
		for(int i=0;i<[queryParts count];i++)
		{
			if([[queryParts objectAtIndex:i] rangeOfString:@"comp="].length==0)
			{
				return [@"?" stringByAppendingString:[queryParts objectAtIndex:i]];
			}
		}
		return @"";
	}
}
/**
 * Parse the Url to azure table.
 * 
 * @param <uri> $url
 * @return <array>
 */
- (NSArray *) parseRequestUrl:(NSString *)anUrl
{
	NSURL *url=[[NSURL alloc]initWithString:anUrl];
	NSString* path=[url path];
	NSString* query=[url query];
	if(path==nil)
	{
		path=@"/";
	}
	if(query==nil)
	{
		query=@"";
	}
	else
	{
		query=[@"?" stringByAppendingString:query];
	}
	
	path=[path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	query=[query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	path=[path stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
	query=[query stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
	
	NSArray *arr=[[NSArray alloc] initWithObjects:path,query,nil];
	[url release];
	return [arr autorelease];
}

/**
 * To create authorization header for $requestUrl and other required headers.
 * 
 * @param <Uri> $requestUrl
 * @return <array>
 */
- (NSMutableDictionary *) getSignedHeaders:(NSString *)aRequestUrl
{
		//extract the query string + path
	//http://host:port/path?querystring
	NSArray* array=[self parseRequestUrl:aRequestUrl];
	if([array count]<2)
		return nil;
	
	NSMutableDictionary *headers=[[NSMutableDictionary alloc]init];
	NSString *temp=@"";

	if([self getUsePathStyleUri])
	{
		NSUInteger intgr=[[array objectAtIndex:0] rangeOfString:@"/"].location;
		temp=[[array objectAtIndex:0] substringFromIndex:intgr];
	}
	
	NSString *queryString=[self prepareQueryStringForSigning:[array objectAtIndex:1]];
	NSString *canonicalizedResource=[@"/" stringByAppendingString:[self getAccountName]];

	if([self getUsePathStyleUri])
	{
		canonicalizedResource=[canonicalizedResource stringByAppendingFormat:@"/%@",[self getAccountName]];
	}

	canonicalizedResource=[canonicalizedResource stringByAppendingString:[array objectAtIndex:0]];

	if(queryString !=nil)
	{
		canonicalizedResource=[canonicalizedResource stringByAppendingString:queryString];
	}

	NSString *requestDate;	
	
	if([headers objectForKey:[m_PREFIX_STORAGE_HEADER stringByAppendingString:@"date"]]!=nil)
	{
		requestDate=[headers objectForKey:[m_PREFIX_STORAGE_HEADER stringByAppendingString:@"date"]];
	}
	else
	{
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
		[dateFormat setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
		requestDate=[dateFormat stringFromDate:[NSDate date]];
		[dateFormat release];		
	}
	
	NSString *stringToSign=requestDate;
	stringToSign=[stringToSign stringByAppendingFormat:@"\n%@",canonicalizedResource];

	const char *szStringToSign=[stringToSign cStringUsingEncoding:NSASCIIStringEncoding];
	
	NSData *keyData=[Utility Base64Decode:[self getAccountKey]];	
	//NSData *keyData=[Utility dataWithBase64EncodedString:[self getAccountKey]];//alternate way for base 64 decoding added for bug 188. do not delete this line	
		
	unsigned char hmac[CC_SHA256_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA256,[keyData bytes],[keyData length],szStringToSign,strlen(szStringToSign),hmac);
	
	NSData *HMACdata=[[NSData alloc]initWithBytes:hmac length:sizeof(hmac)];
	
	NSString *signature=[Utility Base64Encode:HMACdata onSeparateLines:YES];
	
	//The current version of azure table support only dataservice version 1.0.
	//even though the context set the data service version to 2.0. Setting header
	//here will overwrite that value.
	temp=[@"SharedKeyLite " stringByAppendingFormat:@"%@:%@",[self getAccountName],signature];
	
	[m_PREFIX_STORAGE_HEADER stringByAppendingString:@"date"];
	[headers setObject:requestDate forKey:[m_PREFIX_STORAGE_HEADER stringByAppendingString:@"date"]];	
	[headers setObject:Resource_DataServiceVersion_1 forKey:@"DataServiceVersion"];	
	[headers setObject:m_AZURE_API_VERSION forKey:@"x-ms-version"];	
	[headers setObject:temp forKey:@"Authorization"];
	
	[HMACdata release];
	HMACdata=nil;
	
	return [headers autorelease];
}

- (NSString *)base64encoding:(unsigned const char*)aBytesBuffer
{
	char *base64_chars = 
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz"
	"0123456789+/";

	int i = 0;
	int j = 0;
	int k = 0;
	unsigned char char_array_3[3];
	unsigned char char_array_4[4];

	int length = strlen((const char*)aBytesBuffer);
	char ret[length];
	
	
	while (length--) {
		char_array_3[i++] = *(aBytesBuffer++);
		if (i == 3) {
			char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
			char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
			char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
			char_array_4[3] = char_array_3[2] & 0x3f;
			
			for(i = 0; (i <4) ; i++)
				ret[k++] = base64_chars[char_array_4[i]];
			i = 0;
		}
	}
	
	if (i)
	{
		for(j = i; j < 3; j++)
			char_array_3[j] = '\0';
		
		char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
		char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
		char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
		char_array_4[3] = char_array_3[2] & 0x3f;
		
		for (j = 0; (j < i + 1); j++)
			ret[k++]=base64_chars[char_array_4[j]];

		while((i++ < 3))
			ret[k++]='=';
	}
	
	NSString *temp=[NSString stringWithFormat:@"%s",ret];
	return temp;
	
}

@end
