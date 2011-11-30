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

#include <objc/message.h>
#import "Utility.h"

#define BINARY_SIZE 3
#define BASE64_SIZE 4
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((64 / 4) * 3)

static unsigned char Base64EncodeArray[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static unsigned char Base64DecodeArray[256] =
{
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 62, 65, 65, 65, 63, 
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 65, 65, 65, 65, 65, 65, 
    65,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 65, 65, 65, 65, 65, 
    65, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 65, 65, 65, 65, 65, 
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
    65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65,
};

static char encodingTable[64] = {
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

static NSString *const ACCEPT_TYPE  = @"Accept: application/json";
static NSString *const CONTENT_TYPE = @"Content-Type: application/json";
static NSString *const REQUEST_GET  = @"GET";

@implementation Utility

+ (NSString*) getAcceptType
{
	return ACCEPT_TYPE;
}

+ (NSString*) getContentType
{
	return CONTENT_TYPE;
}


+ (NSString*) getRequestGet
{
	return REQUEST_GET;
}


/**
 * This function is to retrive Entity name from
 * type property.
 * @param string type The value of Type property of __metadata.
 * @return string entityName The entity Name
 */
+ (NSString*) getEntityNameFromType:(NSString*) aType
{
	NSString * entityName = nil;
	if(aType == nil)
		return nil;
	NSRange range = [aType rangeOfString:@"."];
	if(range.length > 0 )
	{
		entityName = [aType substringFromIndex:(range.location + 1)];
    }
	return entityName;
}

/**
 * This function is to retrive Property Name from
 * raw property returned by the reflection method
 * getProperties.
 * @param string rawProperty The raw property
 * string returned by getProperties.
 * @return string propertyName The Property Name.
 */
+ (NSString*) getPropertyName:(NSString*) aRawProperty
{
	NSString * propertyName = nil;
	if(aRawProperty == nil)
		return nil;
	NSRange range = [aRawProperty rangeOfString:@"$"];
	if(range.length > 0 )
	{
		NSString * tmp = [aRawProperty substringFromIndex:(range.location + 1)];
		if(tmp != nil)
		{
			range.length = 0; range.location=0;
			range = [tmp rangeOfString:@" "];
			if(range.length > 0 )
			{
				propertyName = [tmp substringToIndex:range.location];
			}
		}
    }
	return propertyName;
}

/**
 * Function to find the index of last occurance of a
 * character in a string.
 * @return index of char in string, -1 if not found.
 */
+ (NSInteger) reverseFind:(NSString*) aSourceString findString:(NSString*)aFindString
{
	NSUInteger len = [aSourceString length];
	if(len == 0)
		return -1;
	
	if([aSourceString hasSuffix:aFindString])
	{
		return (len -1);
	}
	
	for( NSInteger index=len -1 ; index >= 0 ; --index ) 
	{
		if([aSourceString characterAtIndex:index] == [aFindString characterAtIndex:0])
		{
			return index;
		}
	}
	
	return -1;
}


/**
 *@param <string> uri
 *@return string The entity set name.
 *This function will retrive the entity set name from 
 *a url which of the  format
 *http://host/service.svc/EntitySet(KeyValue)
 *
 */

+ (NSString*) getEntityNameFromUrl:(NSString*) anUri
{
	if(anUri == nil)
	{
		return nil;
	}
	
	NSRange openBracesRange = [anUri rangeOfString:@"(" options:NSBackwardsSearch];
	
	if(openBracesRange.length == 0)
	{

		return anUri;
	}
	else
	{
		return [anUri substringWithRange:NSMakeRange(0,openBracesRange.location)];
	}	
}

+ (NSString*) getEntitySetFromUrl:(NSString*) anUri
{
	if(anUri == nil)
	{

		return nil;
	}
		
	NSRange openBracesRange = [anUri rangeOfString:@"(" options:NSBackwardsSearch];
	
	if(openBracesRange.length == 0)
	{
		return nil;
	}
	
	NSRange slashRange = [anUri rangeOfString:@"/"];
	if(slashRange.length == 0)
	{
		return [anUri substringToIndex:slashRange.location];
	}
	
	if(slashRange.location > openBracesRange.location)
	{
		return [anUri substringFromIndex:(slashRange.location + 1)];
	}
	
	for(NSUInteger i = slashRange.location + 1; i < openBracesRange.location; ++i)
	{
		if([anUri characterAtIndex:i] == '/')
			slashRange.location = i;
	}
	
	NSString *tmp = [anUri substringFromIndex:(slashRange.location+1)];
	return [tmp substringToIndex:(openBracesRange.location - slashRange.location - 1)];
}

/**
 *@param string
 *@param <string> value
 *Merge value with string and append a newline at the end
 */
+ (void) WriteLine:(NSString*)aLine inStream:(NSMutableString*) aStream
{
	if(aLine == nil)
		return;
	[aStream appendString:aLine];
	[aStream appendString:@"\n"];
}

/**
 * Function to make a uri corrosponding to an entity instance.
 * @param object The entity instance.
 * @return string uri The uri of entity instance in data service
 * corrosponding to $object.
 */
+ (NSString*) getUri:(ODataObject*)anObject
{

	return nil;
}


+ (BOOL) HttpSuccessCode:(NSNumber*)aHttpCode
{
	if(aHttpCode != nil)
	{
		NSInteger httpCode = [aHttpCode intValue];
		NSInteger restype = floor(httpCode / 100);
		return (restype == 2 || restype == 1);
	}
	
	NSException *anException = [NSException exceptionWithName:@"Exception" reason:@"Utility::HttpSuccessCode The httpCode argument cannot be nil" userInfo:nil];
	[anException raise];
	
	return NO;
}


+ (NSString*) CreateUri:(NSString*)aBaseUri requestUri:(NSString*)aRequestUri
{
	if(aRequestUri == nil || [aRequestUri length] == 0)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:@"Utility::CreateUri The requestUri argument cannot be null" userInfo:nil];
		[anException raise];
	}
	
	if([Utility IsAbsoluteUrl:aRequestUri] == YES)
	{
		return [NSString stringWithFormat:@"%@",aRequestUri];
	}
	
	if([aBaseUri hasSuffix:@"/"] || [aRequestUri hasPrefix:@"/"])
		return [NSString stringWithFormat:@"%@%@",aBaseUri,aRequestUri];		
	else
		return [NSString stringWithFormat:@"%@/%@",aBaseUri,aRequestUri];
}

/**
 * Generate Time Stamp
 *
 * @return NSString
 */
+ (NSString*) TimeInISO8601
{
	NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
	[dateformat setDateFormat:@"Y-m-d"];
	
	NSDateFormatter *timeformat = [[NSDateFormatter alloc] init];
	[timeformat setDateFormat:@"H:i:s"];
	
	NSDate *now = [[NSDate alloc] init];
	
	NSString *dateString = [dateformat stringFromDate:now];
	NSString *timeString = [timeformat stringFromDate:now];
	NSString *date = [NSString stringWithFormat:@"%@T%@Z",dateString,timeString];
	[dateformat release];
	[timeformat release];
	[now release];
	return date;
}

/**
 * Verify HTTP Uri 
 *
 * @param NSString HTTP uri 
 *
 * @return Boolen value
 */
+ (BOOL) IsAbsoluteUrl:(NSString*)anUrl
{
	NSURL *nsurl = [[[NSURL alloc]initWithString:anUrl] autorelease];
	if( ( [nsurl scheme] != nil)  && ( [nsurl host] != nil ))
	{
		return YES;
	}
	return NO;
}


/**
 * Create headers for HTTP request
 *
 * @param NSString HTTP method type
 * @param NSString eTag value for header
 * @param NSString OData service version

 * @return Collections of Headers
 */

+ (NSMutableDictionary*)CreateHeaders:(NSString*)aMethodType eTag:(NSString*)aETag ODataServiceVersion:(NSString *)dataserviceversion
{
	NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
	if([aMethodType isEqualToString:@"BATCH"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"multipart/mixed;charset=utf-8" 
					forKey: @"Content-Type"];	
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];	
	}
	else if([aMethodType isEqualToString:@"POST"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: @"application/atom+xml;charset=utf-8"
					forKey: @"Content-Type"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
	}
	else if([aMethodType isEqualToString:@"MERGE"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: @"application/atom+xml;charset=utf-8"
					forKey: @"Content-Type"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
		[headers setObject: @"MERGE"
					forKey: @"X-HTTP-Method"];
		if(aETag != nil)
			[headers setObject: aETag
						forKey: @"If-Match"];
	}
	
	else if([aMethodType isEqualToString:@"PUT"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: @"application/atom+xml;charset=utf-8"
					forKey: @"Content-Type"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
		[headers setObject: @"PUT"
					forKey: @"X-HTTP-Method"];
		if(aETag != nil)
			[headers setObject: aETag
						forKey: @"If-Match"];
	}
	else if([aMethodType isEqualToString:@"DELETE"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
		[headers setObject: @"DELETE"
					forKey: @"X-HTTP-Method"];
		if(aETag != nil)
			[headers setObject: aETag forKey: @"If-Match"];
	}
	else if([aMethodType isEqualToString:@"GET"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];	
	}
	else if([aMethodType isEqualToString:@"ADD"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
		[headers setObject: @"plain/text;charset=utf-8"
					forKey: @"Content-type"];
		if(aETag != nil)
			[headers setObject: aETag forKey: @"Slug"];
	}
	else if([aMethodType isEqualToString:@"UPDATE"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
		[headers setObject: @"plain/text;charset=utf-8"
					forKey: @"Content-type"];
		[headers setObject: @"PUT"
					forKey: @"X-HTTP-Method"];
		if(aETag != nil)
			[headers setObject: aETag forKey: @"Slug"];
	}
	else if([aMethodType isEqualToString:@"SETLINK"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
		[headers setObject: @"application/xml;charset=utf-8"
					forKey: @"Content-type"];
		[headers setObject: @"PUT"
					forKey: @"X-HTTP-Method"];
		if(aETag != nil)
			[headers setObject: aETag forKey: @"Slug"];
	}
	else if([aMethodType isEqualToString:@"ADDLINK"])
	{
		[headers setObject: @"application/atom+xml,application/xml"
					forKey: @"Accept"];
		[headers setObject: @"UTF-8"
					forKey: @"Accept-Charset"];
		[headers setObject: @"application/xml;charset=utf-8"
					forKey: @"Content-Type"];
		[headers setObject: dataserviceversion
					forKey: @"DataServiceVersion"];
		[headers setObject: @"2.0"
					forKey: @"MaxDataServiceVersion"];
	}
	
	
	return [headers autorelease];
}
/**
 * Encode string in URL Format
 */
+ (NSString *) URLEncode:(NSString *) aString
{
	NSString *encodedString=(NSString *)CFURLCreateStringByAddingPercentEscapes(
																				NULL,
																				(CFStringRef)aString,
																				NULL,
																				(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				kCFStringEncodingUTF8 );
	
	return [encodedString autorelease];
}
/**
 * Decode URL String
 */
+ (NSString *) URLDecode:(NSString *) aString
{
	NSString *decodedString=(NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
																				   (CFStringRef)aString,
																				   CFSTR(""));
	
	return [decodedString autorelease];
}

+ (NSData *) dataWithBase64EncodedString:(NSString *) string {
	NSMutableData *mutableData = nil;
	
	if( string ) {
		unsigned long ixtext = 0;
		unsigned long lentext = 0;
		unsigned char ch = 0;
		unsigned char inbuf[4], outbuf[3];
		short i = 0, ixinbuf = 0;
		BOOL flignore = NO;
		BOOL flendtext = NO;
		NSData *base64Data = nil;
		const unsigned char *base64Bytes = nil;
		
		// Convert the string to ASCII data.
		base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
		base64Bytes = [base64Data bytes];
		mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
		lentext = [base64Data length];
		
		while( YES ) {
			if( ixtext >= lentext ) break;
			ch = base64Bytes[ixtext++];
			flignore = NO;
			
			if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
			else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
			else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
			else if( ch == '+' ) ch = 62;
			else if( ch == '=' ) flendtext = YES;
			else if( ch == '/' ) ch = 63;
			else flignore = YES;
			
			if( ! flignore ) {
				short ctcharsinbuf = 3;
				BOOL flbreak = NO;
				
				if( flendtext ) {
					if( ! ixinbuf ) break;
					if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
					else ctcharsinbuf = 2;
					ixinbuf = 3;
					flbreak = YES;
				}
				
				inbuf [ixinbuf++] = ch;
				
				if( ixinbuf == 4 ) {
					ixinbuf = 0;
					outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
					outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
					outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
					
					for( i = 0; i < ctcharsinbuf; i++ )
						[mutableData appendBytes:&outbuf[i] length:1];
				}
				
				if( flbreak )  break;
			}
		}
	}
	NSData *data=[[NSData alloc]initWithData:mutableData];
	return data;
}

+ (NSString *) base64Encoding:(NSData *) data {
	const unsigned char	*bytes = [data bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[data length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	unsigned short i = 0;
	unsigned short charsonline = 0, ctcopy = 0;
	unsigned long ix = 0;
	
	while( YES ) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
		
		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
		
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
		
		switch( ctremaining ) {
			case 1:
				ctcopy = 2;
				break;
			case 2:
				ctcopy = 3;
				break;
		}
		
		for( i = 0; i < ctcopy; i++ )
			[result appendFormat:@"%c", encodingTable[outbuf[i]]];
		
		for( i = ctcopy; i < 4; i++ )
			[result appendString:@"="];
		
		ixtext += 3;
		charsonline += 4;
		
	}
	
	return [NSString stringWithString:result];
}

/**
 * Encode string in base64
 */
+ (NSString*) Base64Encode:(NSData*) anInputData onSeparateLines:(BOOL)separateLines
{
	size_t length = [anInputData length];
	const unsigned char *inBuf = (const unsigned char *)[anInputData bytes];

	size_t outBufLength = ((length / BASE64_SIZE) + ((length % BASE64_SIZE) ? 1 : 0)) * BASE64_SIZE;
	
	if (separateLines)
	{
		outBufLength += (outBufLength / OUTPUT_LINE_LENGTH) * 2;
	}
	
	outBufLength += 1;
	
	char *outBuf = (char *)malloc(outBufLength);
	if (!outBuf)
	{
		return NULL;
	}
	
	size_t i = 0;
	size_t outlength = 0;
	const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
	size_t size = lineLength;
	
	while (true)
	{
		if (size > length)
		{
			size = length;
		}
		
		for (; i + BASE64_SIZE - 1 < size; i += BINARY_SIZE)
		{
			outBuf[outlength++] = Base64EncodeArray[(inBuf[i] & 0xFC) >> 2];
			outBuf[outlength++] = Base64EncodeArray[((inBuf[i] & 0x03) << 4)     | ((inBuf[i + 1] & 0xF0) >> 4)];
			outBuf[outlength++] = Base64EncodeArray[((inBuf[i + 1] & 0x0F) << 2) | ((inBuf[i + 2] & 0xC0) >> 6)];
			outBuf[outlength++] = Base64EncodeArray[inBuf[i + 2] & 0x3F];
		}
		
		if (size == length)
		{
			break;
		}
		
		outBuf[outlength++] = '\r';
		outBuf[outlength++] = '\n';
		size += lineLength;
	}
	
	if (i + 1 < length)
	{
		outBuf[outlength++] = Base64EncodeArray[(inBuf[i] & 0xFC) >> 2];
		outBuf[outlength++] = Base64EncodeArray[((inBuf[i] & 0x03) << 4) | ((inBuf[i + 1] & 0xF0) >> 4)];
		outBuf[outlength++] = Base64EncodeArray[(inBuf[i + 1] & 0x0F) << 2];
		outBuf[outlength++] =	'=';
	}
	else if (i < length)
	{
		outBuf[outlength++] = Base64EncodeArray[(inBuf[i] & 0xFC) >> 2];
		outBuf[outlength++] = Base64EncodeArray[(inBuf[i] & 0x03) << 4];
		outBuf[outlength++] = '=';
		outBuf[outlength++] = '=';
	}
	outBuf[outlength] = 0;
	
	NSString *str = nil;
	
	if(outlength > 0)
	{
		str =[[NSString alloc] initWithBytes:outBuf length:outlength encoding:NSASCIIStringEncoding];
		free(outBuf);
	}
	return [str autorelease];
}

/**
 * Decode base64 string
 */
+ (NSData*) Base64Decode:(NSString*) anInputString
{
	if ([anInputString length] <= 0)
	{
		return nil;
	}
	
	
	int length = [anInputString length];
	const char* inBuf = [anInputString cStringUsingEncoding:NSASCIIStringEncoding];
	size_t outBufLength =
	((length+BASE64_SIZE-1) / BASE64_SIZE) * BINARY_SIZE;
	unsigned char *outBuf = (unsigned char *)malloc(outBufLength);
	
	size_t i = 0;
	size_t outlength = 0;
	while (i < length)
	{
		unsigned char tmpBuf[BASE64_SIZE];
		size_t index = 0;
		while (i < length)
		{
			unsigned char decodeValue = Base64DecodeArray[inBuf[i++]];
			if (decodeValue != 65)
			{
				tmpBuf[index++] = decodeValue;
				
				if (index == BASE64_SIZE)
				{
					break;
				}
			}
		}
		
		outBuf[outlength]		= (tmpBuf[0] << 2) | (tmpBuf[1] >> 4);
		outBuf[outlength + 1]	= (tmpBuf[1] << 4) | (tmpBuf[2] >> 2);
		outBuf[outlength + 2]	= (tmpBuf[2] << 6) | tmpBuf[3];
		
		outlength += index - 1;
	}
	
	
	NSData *data = nil;
	
	if(outlength > 0)
	{
		data =[[NSData alloc] initWithBytes:outBuf length:outlength];
		free(outBuf);
	}
	return [data autorelease];	
}


@end
