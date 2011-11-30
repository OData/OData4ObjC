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


#import "DataServiceQuery.h"
#import "constants.h"
#import "HTTPHandler.h"

#import "AtomParser.h"
#import "ODataXMLElements.h"
#import "ODataXMlParser.h"

@implementation DataServiceQuery
@synthesize m_entitySetUrl, m_context, m_isAzureRequest;
@synthesize m_delegate,m_systemQueryOptions;

#pragma mark MSODataTestAppDelegate methods

- (void)onSuccess:(NSData*)data
{
	NSLog(@"DATA recieved= [%@]",data);
}

- (void)onError:(NSError*)error
{
	if(m_delegate!=nil)
	{
		[m_delegate onError:error];
	}
}

#pragma mark init and dealloc methods

- (void) dealloc
{
	[m_systemQueryOptions release];
	m_systemQueryOptions = nil;
		
	[m_options release];
	m_options = nil;
	
	[m_expand release];
	m_expand = nil;
	
	[m_orderby release];
	m_orderby = nil;
	[m_other release];
	m_other = nil;
	
	[m_entitySetUrl release];
	m_entitySetUrl = nil;
	
	[super dealloc];
}

- (id) initWithUri:(NSString*)anEntitySetUrl objectContext:(ObjectContext*)anObjectContext
{
	if(self = [super init])
	{
		NSMutableArray *objects = [[NSMutableArray alloc] initWithObjects:@"$expand",@"$filter",@"$inlinecount",@"$orderby",@"$skip",@"$top",@"$select",nil];
		NSMutableArray *keys	= [[NSMutableArray alloc] initWithObjects:@"$expand",@"$filter",@"$inlinecount",@"$orderby",@"$skip",@"$top",@"$select",nil];
		[self setSystemQueryOptions:[NSMutableDictionary dictionaryWithObjects:objects forKeys:keys]];
		[objects release];
		objects = nil;
		[keys release];
		keys = nil;
		
		m_options					= [[NSMutableDictionary alloc] init];
		m_expand					= [[NSMutableArray alloc] init];
		m_orderby					= [[NSMutableArray alloc] init];
		m_other						= [[NSMutableArray alloc] init];
		self.m_isAzureRequest			= NO;
		
		if(anEntitySetUrl)
		{       
			NSString *temp=[[anObjectContext getBaseUriWithSlash] stringByAppendingString:anEntitySetUrl];
			[self setEntitySetUrl:[NSString stringWithString:temp]];
		}
		else                            
			[self setEntitySetUrl:[NSString stringWithString:@""]];         
		
		[self setContext:anObjectContext];
	}
	return self;
}

#pragma mark m_other methods
/**
 *
 * @param <string> option The string value that contains the name
 *                         of the query string option to add
 * @param <string> value The string that contains the value of the
 *                         query string option
 * @return <DataServiceQuery> Self reference that includes the requested
 *                         query option
 */
- (DataServiceQuery*) addQueryOption:(NSString*)anOption query:(NSString*)aQuery
{
	if(anOption == nil || aQuery == nil)
	{
		QueryOperationResponse *queryOperationResponse = [[[QueryOperationResponse alloc] initWithValues:nil innerException:Resource_NoEmptyQueryOption statusCode:0 query:nil] autorelease];
		@throw [[[DataServiceRequestException alloc] initWithResponse:queryOperationResponse]autorelease];

	}
	
	NSString *tmpOption = [anOption stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if(tmpOption != nil && [tmpOption isEqual:@""])
	{
		QueryOperationResponse *queryOperationResponse = [[[QueryOperationResponse alloc] initWithValues:nil innerException:Resource_NoEmptyQueryOption statusCode:0 query:nil] autorelease];
		@throw [[[DataServiceRequestException alloc] initWithResponse:queryOperationResponse]autorelease];
	
	}
	
	if( ([tmpOption characterAtIndex:0] == '$') && ([m_systemQueryOptions objectForKey:tmpOption] == nil))
	{
		QueryOperationResponse *queryOperationResponse = [[[QueryOperationResponse alloc] initWithValues:nil innerException:Resource_ReservedCharNotAllowed statusCode:0 query:nil] autorelease];
		@throw [[[DataServiceRequestException alloc] initWithResponse:queryOperationResponse]autorelease];
	}
	
	NSString *tmpQuery = [aQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if([tmpOption isEqualToString:@"$expand"])
	{
		
		if(tmpQuery != nil && ![tmpQuery isEqual:@""])
		{
			[m_expand addObject:tmpQuery];
		}
	}
	else if([tmpOption isEqualToString:@"$orderby"])
	{
		
		if(tmpQuery != nil && ![tmpQuery isEqual:@""])
		{
			[m_orderby addObject:tmpQuery];
		}
	}
	else if([m_systemQueryOptions objectForKey:tmpOption] != nil)
	{
		if([m_options objectForKey:tmpOption] != nil)
		{
			QueryOperationResponse *queryOperationResponse = [[[QueryOperationResponse alloc] initWithValues:nil innerException:Resource_NoDuplicateOption statusCode:0 query:nil] autorelease];
			@throw [[[DataServiceRequestException alloc] initWithResponse:queryOperationResponse]autorelease];
		}
		[m_options setObject:tmpQuery forKey:tmpOption];
	}
	else
	{
		[m_other addObject:[NSString stringWithFormat:@"%@=%@",tmpOption , tmpQuery]];
	}
	
	return self;
}

/**
 *
 * @param <string> path A string value that contains the requesting URI.
 * @return <DataServiceQuery> Self reference that includes the requested
 *                         m_expand query option
 */
- (DataServiceQuery*) expand:(NSString*)anExpression
{
	return [self addQueryOption:@"$expand" query:anExpression];
}

/**
 * To add an expand query option.
 *
 * @param <string> expression
 * @return <DataServiceQuery> Self reference that includes the requested
 *                            $orderby option
 * @throws DataServiceRequestException
 */
- (DataServiceQuery*) orderBy:(NSString*)anExpression
{
	return [self addQueryOption:@"$orderby" query:anExpression];
}

/**
 * To add top query option.
 *
 * @param <int> count
 * @return <DataServiceQuery> Self reference that includes the requested
 *                            top option
 * @throws DataServiceRequestException
 */
- (DataServiceQuery*) top:(NSInteger)count
{
	NSString *str = [[NSString alloc] initWithFormat:@"%d",count];
	return [self addQueryOption:@"$top" query:[str autorelease]];
}

/**
 * To add skip query option.
 *
 * @param <int> count
 * @return <DataServiceQuery> Self reference that includes the requested
 *                            skip option
 * @throws DataServiceRequestException
 */
- (DataServiceQuery*) skip:(NSInteger)count
{
	NSString *str = [[NSString alloc] initWithFormat:@"%d",count];
	return [self addQueryOption:@"$skip" query:[str autorelease]];
}

/**
 * To add a filter query option.
 * 
 * @param <string> expression
 * @return <DataServiceQuery> Self reference that includes the requested
 *                            filter option
 * @throws DataServiceRequestException
 */
- (DataServiceQuery*) filter:(NSString*)anExpression
{
	return [self addQueryOption:@"$filter" query:anExpression];
}

/**
 * To add inlinecount query option.
 *
 * @return <DataServiceQuery> Self reference that includes the requested
 *                            inlinecount=allpages query option
 * @throws DataServiceRequestException
 */
- (DataServiceQuery*) includeTotalCount:(NSString*)anExpression
{
	return [self addQueryOption:@"$inlinecount" query:anExpression];
}
/**
 * To add selct query option.
 *
 * @return <DataServiceQuery> Self reference that includes the requested
 *                            inlinecount=allpages query option
 * @throws DataServiceRequestException
 */
- (DataServiceQuery*) select:(NSString*)anExpression
{
	return [self addQueryOption:@"$select" query:anExpression];
}
#pragma mark execute methods
/**
 * To get raw count from OData service.
 *
 * @return <int> Returns Row count
 * @throws DataServiceRequestException
 */
- (NSString*) count
{
	if([m_options objectForKey:@"$inlinecount"] != nil)
	{
		NSException *exception = [NSException exceptionWithName:@"Invalid Operation" reason:Resource_NoCountAndInLineCount userInfo:nil];
		[exception raise];
	}
	
	NSString *query = [NSString stringWithFormat:@"%@/$count",m_entitySetUrl];
	NSString *queryOptions=[self buildQueryOption];
	if([queryOptions hasPrefix:@"$"])
		query=[query stringByAppendingFormat:@"?%@",queryOptions];
	
	
	HTTPHandler *httpRequest = [m_context executeHTTPRequest:query httpmethod:nil httpbody:nil etag:nil];
	if([httpRequest http_error])
	{
		QueryOperationResponse *queryOperationResponse = [[[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:query] autorelease];
		
		@throw [[[DataServiceRequestException alloc] initWithResponse:queryOperationResponse]autorelease];
	}
	
	return [[NSString alloc]initWithData:[httpRequest http_response] encoding:NSUTF8StringEncoding];//29july
}

/**
 *
 * @return <EntityObjectCollection>
 */
- (QueryOperationResponse*) execute
{
	NSString *query=[NSString stringWithString:m_entitySetUrl];
	NSString *queryOption=[self buildQueryOption];
	if([queryOption length] > 0)
		query = [query stringByAppendingFormat:@"?%@",queryOption];	
	
	HTTPHandler *httpRequest = [m_context executeHTTPRequest:query httpmethod:@"GET" httpbody:nil etag:nil];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:query];
	if([httpRequest http_error])
	{
		@throw [[DataServiceRequestException alloc] initWithResponse:queryOperationResponse];
	}
	
	NSData *nonUTF8Data = [httpRequest http_response];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
	[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
	[atom release];
	[handler release];
	return [queryOperationResponse autorelease];
}
/**
 *
 * @return <Uri>
 * Retruns requested Uri
 */
- (NSString*) requestUri
{
	NSString * tmp = [NSString stringWithFormat:@"%@?%@",[self buildQueryOption]];
	return tmp;
}

-(void) clearAllOptions
{
	[m_options release];
	[m_expand release];
	[m_orderby release];
	[m_other release];
	
	m_options	= [[NSMutableDictionary alloc]init];
	m_expand	= [[NSMutableArray alloc] init];
	m_orderby	= [[NSMutableArray alloc] init];
	m_other		= [[NSMutableArray alloc] init];
}

/**
 * To build final query from all options.
 *
 * @return <string> The query options provided by client

*/
- (NSString*) buildQueryOption
{
	NSArray *tmpArray = [m_expand copy];
	NSUInteger index = [tmpArray count] - 1;
	for (id object in [tmpArray reverseObjectEnumerator]) 
	{
		if ([m_expand indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) 
		{
			[m_expand removeObjectAtIndex:index];
		}
		index--;
	}
	
	[tmpArray release];
	
	NSMutableString *expandOption = [[NSMutableString alloc] init];
	
	NSUInteger count = [m_expand count];
	for(index = 0;index<count;++index)
	{
		NSString *value = [m_expand objectAtIndex:index];
		if(value)
		{
			[expandOption appendString:value];
			[expandOption appendString:@","];
		}
	}
	
	if ([expandOption hasSuffix:@","]) {
		
		NSRange range=[expandOption rangeOfString:@"," options:NSBackwardsSearch];
		
		[expandOption deleteCharactersInRange:range];
	}
	
	if( [expandOption length] > 0 )
	{
		[expandOption setString:[NSString stringWithFormat:@"$expand=%@",expandOption]];
	}
	
	tmpArray = [m_orderby copy];
	index = [tmpArray count] - 1;
	for (id object in [tmpArray reverseObjectEnumerator]) 
	{
		if ([m_orderby indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) 
		{
			[m_orderby removeObjectAtIndex:index];
		}
		index--;
	}
	
	[tmpArray release];
	
	NSMutableString *orderbyOption = [[NSMutableString alloc] init];
	
	count = [m_orderby count];
	for(index = 0;index<count;++index)
	{
		NSString *value = [m_orderby objectAtIndex:index];
		if(value)
		{
			[orderbyOption appendString:value];
			[orderbyOption appendString:@","];
		}
	}
	
	if ([orderbyOption hasSuffix:@","]) {
		NSRange range=[orderbyOption rangeOfString:@"," options:NSBackwardsSearch];
		[orderbyOption deleteCharactersInRange:range];
	}
	
	if( [orderbyOption length] > 0 )
	{
		[orderbyOption setString:[NSString stringWithFormat:@"$orderby=%@",orderbyOption]];
	}
	
	NSMutableString *query=[[NSMutableString alloc] init];
	
	NSEnumerator *enumerator = [m_options keyEnumerator];
	NSString* key;
	while(key = [ enumerator nextObject] )
	{
		NSString *value = [m_options objectForKey:key];
		if(value)
		{
			[query appendString:key];
			[query appendString:@"="];
			[query appendString:value];
			[query appendString:@"&"];
		}
	}
	
	count = [m_other count];
	for(index = 0;index<count;++index)
	{
		NSString *tmp = [m_other objectAtIndex:index];
		if(tmp)
		{
			[query appendString:tmp];
			[query appendString:@"&"];
		}
	}
	
	if([orderbyOption length] > 0)
	{
		if ([expandOption length] > 0){ 
			[query appendString:expandOption];
			[query appendString:@"&"];
			[query appendString:orderbyOption];
		}else{ 
			[query appendString:orderbyOption];
		}
	}
	else
	{
		[query appendString:expandOption];
	}
	
	if( [query hasSuffix:@","])
	{
		NSRange range=[query rangeOfString:@"," options:NSBackwardsSearch];
		[query deleteCharactersInRange:range];
		
		if( [query hasSuffix:@"&"])
		{
			NSRange range=[query rangeOfString:@"&" options:NSBackwardsSearch];
			[query deleteCharactersInRange:range];
		}
	}
	else if( [query hasSuffix:@"&"])
	{
		NSRange range=[query rangeOfString:@"&" options:NSBackwardsSearch];
		[query deleteCharactersInRange:range];
		
		if( [query hasSuffix:@","])
		{
			NSRange range=[query rangeOfString:@"," options:NSBackwardsSearch];
			[query deleteCharactersInRange:range];
		}
	}
	[expandOption release];expandOption=nil;
	[orderbyOption release];orderbyOption=nil;
	
	query=((NSMutableString*)[query stringByReplacingOccurrencesOfString:@" " withString:@"+"]);
	
	return query;
}

/**
 *
 * @param <string> errorMessage
 * @return <QueryOperationResponse>
 * Create and returns QueryOperationResponse object using errorMessage
 */
- (QueryOperationResponse*) createQueryOperationResponse:(NSString*)anErrorMessage
{
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:nil innerException:anErrorMessage statusCode:0 query:nil];
	return [queryOperationResponse autorelease];
}	

@end