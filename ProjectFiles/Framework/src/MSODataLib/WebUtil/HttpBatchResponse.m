
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

#import "HttpBatchResponse.h"
#import "Microsoft_Http_Response.h"

@implementation HttpBatchResponse

@synthesize m_httpResponses;
@synthesize m_rawHttpBatchResponse;
@synthesize m_correctHttpLine;
@synthesize m_changesetBoundary;

-(void)dealloc
{
	[m_httpResponses release];
	m_httpResponses = nil;
	[m_rawHttpBatchResponse release];
	m_rawHttpBatchResponse = nil;
	[m_correctHttpLine release];
	m_correctHttpLine = nil;
	[m_changesetBoundary release];
	m_changesetBoundary = nil;
	[super dealloc];
}

-(id) initWithResponses:(NSMutableArray *)httpResponses rawHttpBatchResponse:(NSString *)batchResponse
	  changesetBoundary:(NSString *)changesetBoundary
{
	if(self = [super init])
	{
		[self setHttpResponses:httpResponses];
		[self setRawBatchResponse:batchResponse];
		[self setChangesetBoundary:changesetBoundary];
	}
	return self;
}

+(HttpBatchResponse *) CreateBatchResponse:(NSString *)response
{
	NSString *changesetBoundary = [HttpBatchResponse ExtractChangesetBoundary:response];
	
	if(changesetBoundary == nil)
		return nil;
	
	NSArray *httpResponses = [self ExtractHttpResponses:response changesetBoundary:changesetBoundary];
		
	HttpBatchResponse *batchResponse = [[HttpBatchResponse alloc] initWithResponses:httpResponses rawHttpBatchResponse:response changesetBoundary:changesetBoundary];
	return [batchResponse autorelease];
}

+(NSArray *) ExtractHttpResponses:(NSString *)httpResponse changesetBoundary:(NSString *)changeset
{
	NSMutableArray *httpresponses = [[NSMutableArray alloc] init];
	NSString *boundary = [NSString stringWithFormat:@"--%@",changeset];
	
	NSArray *responses = [httpResponse componentsSeparatedByString:boundary];
	
	if([responses count] <2)
	{
		Microsoft_Http_Response *temp = [Microsoft_Http_Response fromString:httpResponse];
		if(temp != nil)
			[httpresponses addObject:temp];
		
		return [httpresponses autorelease];
	}
	
	for(int i=0;i<[responses count];i++)
	{
		Microsoft_Http_Response *temp = [Microsoft_Http_Response fromString:[responses objectAtIndex:i]];
		if(temp != nil)
			[httpresponses addObject:temp];
	}	
	return httpresponses;
}


+(NSString *) ExtractChangesetBoundary:(NSString *)body
{ 
	
	NSError *error = NULL; 
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=boundary=)changesetresponse_[^\\r\\n]+" 
																		   options:NSRegularExpressionCaseInsensitive 
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:body options:0 range:NSMakeRange(0, [body length])];
	if ([matches count] == 0) {
		return @"";
	}
	
	NSTextCheckingResult *firstResult = [matches objectAtIndex:0];
	NSString *boundary = [body substringWithRange:firstResult.range];
	
	return boundary;
	
}

@end
