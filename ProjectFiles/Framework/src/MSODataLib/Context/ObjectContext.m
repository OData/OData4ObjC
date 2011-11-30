
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

#import "ObjectContext.h"
#import "constants.h"
#import "ResourceBox.h"

#import "HttpResponse.h"
#include "Utility.h"
#import "SaveResult.h"
#import "ODataXMLElements.h"
#import "ODataXMlParser.h"
#import "HTTPHandler.h"
#import "WindowsCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataRTTI.h"

@implementation ObjectContext
@synthesize m_objectContextdelegate , m_oDataDelegate;

@synthesize m_delegate;
@synthesize m_baseUri, m_baseUriWithSlash, m_serviceNamespace;
@synthesize m_nextChange, m_accept;
@synthesize m_contentType, m_usePostTunneling;
@synthesize m_saveChangesOptions, m_replaceOnUpdateOption;
@synthesize m_objectToResource , m_bindings;
@synthesize m_dataServiceVersion ;
@synthesize m_httpProxy;
@synthesize m_identityToResource , m_customHeaders;
@synthesize m_ODataSVC;
@synthesize m_Credential;
@synthesize m_entities;
@synthesize m_timeOutInterval;

+ (void)initialize
{
	Tables *table=[[Tables alloc]initWithUri:nil];
	[table release];
	table =nil;
}

#pragma mark init and dealloc methods

- (void) dealloc
{
	if(m_Credential != nil){
		[m_Credential release];
		 m_Credential=nil;
	}
	
	if (m_entities !=nil) {
		[m_entities release];
		m_entities = nil;
	}
	
	if (m_entitySet2Type!=nil) {
		[m_entitySet2Type release];
		m_entitySet2Type =nil;
	}
	
	if (m_entityType2Set !=nil) {
		[m_entityType2Set release];
		m_entityType2Set = nil;
	}
	
	if (m_association !=nil) {
		[m_association release];
		m_association = nil;
	}
	
	if ( m_customHeaders !=nil) {
		[m_customHeaders release];
		m_customHeaders = nil;
	}
	
	if (m_baseUri !=nil) {
		[m_baseUri release];
		m_baseUri = nil;
	}
	
	if (m_baseUriWithSlash !=nil) {
		[m_baseUriWithSlash release];
		m_baseUriWithSlash = nil;
	}
	
	if (m_accept !=nil) {
		[m_accept release];
		m_accept = nil;
	}
	
	if (m_contentType !=nil) {
		[m_contentType release];
		m_contentType = nil;
	}
	
	if (m_dataServiceVersion !=nil) {
		[m_dataServiceVersion release];
		m_dataServiceVersion = nil;
	}
	
	if (m_entityFKRelation !=nil) {
		[m_entityFKRelation release];
		m_entityFKRelation = nil;
	}
	
	if (m_httpProxy !=nil) {
	    [m_httpProxy release];
		m_httpProxy = nil;
	}
	
	if (m_ODataSVC !=nil) {
		[m_ODataSVC release];
		m_ODataSVC = nil;
	}
	
	if (m_objectToResource !=nil) {
		[m_objectToResource release];
		m_objectToResource = nil;
	}
	
	if (m_identityToResource !=nil) {
		[m_identityToResource release];
		m_identityToResource = nil;
	}
	
	if (m_bindings !=nil) {
		[m_bindings release];
		m_bindings = nil;
	}
	
	[super dealloc];
}


- (id) init
{
	self=[self initWithUri:nil credentials:nil dataServiceVersion:nil];
	return self;
}

- (id) initWithUri: (NSString*) aUri credentials:(id)aCredential dataServiceVersion:(NSString *)aDataServiceVersion
{
	if(self = [super init] )
	{
		self.m_entities			= [[NSMutableArray alloc]init];
		m_entitySet2Type		= [[NSMutableDictionary alloc]init];
		m_entityType2Set		= [[NSMutableDictionary alloc]init];
		m_association			= [[NSMutableDictionary alloc]init];
		m_entityFKRelation		= [[NSMutableDictionary alloc]init];
		self.m_objectToResource	= [[Dictionary alloc] init];
		self.m_bindings			= [[Dictionary alloc] init];
		self.m_identityToResource	= [[NSMutableDictionary alloc] init];
		self.m_nextChange		= 0;
		self.m_httpProxy		= nil;		
		self.m_ODataSVC = [[ODataSVC alloc] init];
		self.m_serviceNamespace	=nil;
		[self setBaseUri:aUri];
		if([aUri hasSuffix:@"/"])
			[self setBaseUriWithSlash:aUri];
		else
			[self setBaseUriWithSlash:[aUri stringByAppendingString:@"/"]];
		
		self.m_customHeaders			= [[NSMutableDictionary alloc] init];
		[self setAccept:[NSString stringWithString:Resource_Accept_ATOM]];
		[self setContentType:[NSString stringWithString:Resource_Content_Type_ATOM]];
		self.m_usePostTunneling		= NO;
		self.m_saveChangesOptions	=  Resource_DefaultSaveChangesOptions;
		self.m_replaceOnUpdateOption	= NO;
		[self setBaseUri:aUri];
		[self setCredentials:aCredential];
		if([[aCredential getCredentialType] isEqualToString:@"AZURE"])
			[self setDataServiceVersion:@"1.0"];
		else
			[self setDataServiceVersion:aDataServiceVersion];
		[self setTimeOutInterval:30.0];
	}
	return self;
}

- (void) getSVC
{
	if([self getBaseUri])
		[self retrieveSVC:[self getBaseUri]];
	
	if([m_ODataSVC getBaseUrl] != nil)
	{
		[self setBaseUri:[NSString stringWithString:[m_ODataSVC getBaseUrl]]];
	}		
	
	if([self getBaseUri])
	{
		[self setBaseUri:[NSString stringWithString:[self getBaseUri]]];
	}
	
	[self setBaseUriWithSlash:[NSString stringWithString:m_baseUri]];
	
	[self setAccept:[NSString stringWithString:Resource_Accept_ATOM]];
	[self setContentType:[NSString stringWithString:Resource_Content_Type_ATOM]];
	
	if([m_baseUriWithSlash hasSuffix:@"/"]==NO)
	{
		NSString *tmp = [m_baseUriWithSlash stringByAppendingString:@"/"];
		if(tmp)
		{
			[m_baseUriWithSlash release];
			m_baseUriWithSlash = nil;
			[self setBaseUriWithSlash:[NSString stringWithString:tmp]];
			[tmp release];
			tmp = nil;
		}
	}
}

#pragma mark other methods
/**     
 * To set the SaveChange mode batch or Non-Batch
 */
- (void) setSaveChangesOptions : (NSInteger) aSaveChangesOptions
{
	if(aSaveChangesOptions != None && aSaveChangesOptions != Batch)
	{
		NSException *anException = [NSException exceptionWithName:@"Invalid Operation" reason:Resource_InvalidSaveChangesOptions userInfo:nil];
		[anException raise];
	}
	m_saveChangesOptions = aSaveChangesOptions;
}

/** 
 * To insert an object into data service.
 * @param string entityName The class name of entity to be inserted.
 * @param object The instance of entity to be inserted.
 */

- (void) addObject:(NSString*) anEntityName object:(ODataObject*) anObject
{	
	[self throwExceptionIfNotValidObject: anObject methodName:@"AddObject"];
	
	if([m_objectToResource containsKey:anObject] == YES)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityAlreadyContained] userInfo:nil];
		[anException raise];
	}
	
	ResourceBox* resourceBox = [[ResourceBox alloc] initWithIdentity:@"" editLink:anEntityName resource:anObject];
	[resourceBox setState: Added]; // Added changes
	[self incrementChange: resourceBox]; 
	[m_objectToResource add:anObject value:resourceBox];
	[resourceBox release];
}

/** 
 * To update an entity instance in data service.
 * @param object The instance of entity to be updated.
 */
- (void) updateObject:(ODataObject*) anObject
{
	[self throwExceptionIfNotValidObject: anObject methodName:@"UpdateObject"];
	
	ResourceBox * resourcebox = (ResourceBox*)[m_objectToResource tryGetValue:anObject];
	if(resourcebox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	if (Unchanged == [ resourcebox getState])
	{
		[resourcebox setState:Modified];
		[self incrementChange:resourcebox];
	}
}

/** 
 * To create an m_association between two entity instances
 * @param sourceObject The source object participating the m_association.
 * @param targetObject The target object participating the m_association.
 * @param entityName The class name of target object.
 * This method only supports adding links to relationships with
 * multiplicity = * (The source property is Collection).
 */
- (void) addLink:(ODataObject*) aSourceObject sourceProperty:(NSString*) aSourceProperty targetObject:(ODataObject*) aTargetObject
{
	[self throwExceptionIfNotValidObject: aSourceObject methodName:@"AddLink"];
	[self throwExceptionIfNotValidObject: aTargetObject methodName:@"AddLink"];
	
	RelatedEnd * key = [[RelatedEnd alloc] initWithObject:aSourceObject sourceProperty:aSourceProperty targetResource:aTargetObject];
	
	[self validateAddLink:key];
	[key setState:Added];
	[m_bindings add:key value:key]; 
	ResourceBox *sourceResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:aSourceObject];
	if(sourceResourceBox != nil)
	{
		++sourceResourceBox.m_relatedLinkCount;
		[self incrementChange:key];
	}
	[key release];
}

/** 
 * To delete an entity instance from the data service.
 * @param object The entity instance to be deleted.     
 */
- (void) deleteObject:(ODataObject*)anObject
{	
	[self throwExceptionIfNotValidObject: anObject methodName:@"DeleteObject"];
	ResourceBox *resourceBox = (ResourceBox*)[m_objectToResource tryGetValue:anObject];
	if(resourceBox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	NSInteger state = [resourceBox getState];
	if (Added == state)
	{		  
		if (nil != [resourceBox getIdentity])
		{
			[m_identityToResource removeObjectForKey:[resourceBox getIdentity]];
		}
		[self detachRelated:resourceBox];
		[resourceBox setState:Detached];
		[m_objectToResource remove:anObject];
	}
	else if (Deleted != state)
	{
		[resourceBox setState:Deleted];
		[self incrementChange:resourceBox];
	}		
}

/** 
 * To delete an m_association between two entity instances
 * @param <Object> sourceObject The source object participating the
 *        m_association.
 * @param <Object> targetObject The target object participating the
 *        m_association.
 * @param <string> entityName The class name of target object.
 * @Return No return value
 */
- (void) deleteLink:(ODataObject*) aSourceObject sourceProperty:(NSString*)aSourceProperty targetObject:(ODataObject*)aTargetObject
{
	[self throwExceptionIfNotValidObject: aSourceObject methodName:@"DeleteLink"];
	[self throwExceptionIfNotValidObject: aTargetObject methodName:@"DeleteLink"];
	
	RelatedEnd * key = [[RelatedEnd alloc] initWithObject:aSourceObject sourceProperty:aSourceProperty targetResource:aTargetObject];
	[key setState:Deleted];
	[self incrementChange:key];
	id bindingValue = (ResourceBox*)[m_bindings tryGetValue:key];
	if(bindingValue != nil && Added == [bindingValue getState])
	{
		[self detachExistingLink:key];
		return;
	}

	ResourceBox *sourceResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:aSourceObject];
	ResourceBox *targetResourcebox = (ResourceBox*)[m_objectToResource tryGetValue:aTargetObject];
	
	if(((bindingValue == nil) && ( (Added == [sourceResourceBox getState]) || (Added == [targetResourcebox getState]) ) ) )
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_NoRelationWithInsertEnd] userInfo:nil];
		[anException raise];
	}
	else if (bindingValue == nil)
	{
		[m_bindings add:key value: key];
		sourceResourceBox.m_relatedLinkCount++;
		bindingValue = (RelatedEnd*)key;
		
	}
	
	if (Deleted != [ bindingValue getState])
	{
		[bindingValue setState:Deleted];
		[self incrementChange:bindingValue];
	}
	[key release];
}

/**     
 * @param <Object> sourceObject The source object participating the
 *        m_association.
 * @param <string> sourceProperty The property on the source object that
 *        identifies the target object of the new link.
 * @param <Object or null> $targetObject The target object participating
 *        the m_association.
 * This method only supports adding links to relationships with
 * multiplicity = 1 (The source property is an object reference).
 */
- (void) setLink:(ODataObject*) aSourceObject sourceProperty:(NSString*)aSourceProperty targetObject:(ODataObject*)aTargetObject
{
	[self throwExceptionIfNotValidObject: aSourceObject methodName:@"SetLink"];

	RelatedEnd * key = [[RelatedEnd alloc] initWithObject:aSourceObject sourceProperty:aSourceProperty targetResource:aTargetObject];
	
	[self validateSetLink: key];
	
	[key setState:Modified];
	[self incrementChange:key];
	RelatedEnd *key1 = [self detachReferenceLink:aSourceObject sourceProperty:aSourceProperty targetObject:aTargetObject];
	[key1 setState:Modified];
	if(key1 == nil)
	{
		key1 = [key retain];
		[m_bindings add:key1 value:key1];
		[key1 release];
	}
	
	if (Modified != [key1 getState])
	{		
		ResourceBox *sourceResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:aSourceObject];
		if(sourceResourceBox) sourceResourceBox.m_relatedLinkCount++;
		[self incrementChange:key1];
	}
	[key release];
}

/** 
 *
 * @param <type> object: Entity Instance in Added or Modified state
 * @param array headers: HTTP Header
 * This method is used to add HTTP Custom headers to an entity in added or
 * modified state, so that when user call SaveChanges this header will be
 * added to the http header specific to the object.
 */
- (void) setEntityHeaders:(id)anObject header:(NSDictionary*) aHeaders 
{
	if(aHeaders == nil || [aHeaders count] == 0)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityHeaderOnlyArray] userInfo:nil];
		[anException raise];
	}
	
	[self throwExceptionIfNotValidObject:anObject methodName:@""];
	
	ResourceBox * resourcebox = (ResourceBox*)[m_objectToResource tryGetValue:anObject];
	if(resourcebox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	if(!([resourcebox getState] == Added || [resourcebox getState] == Modified))
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityHeaderCannotAppy] userInfo:nil];
		[anException raise];
	}
	[resourcebox setHeaders:aHeaders];
}

/**
 * This function will updates the m_entities changed (in Added, Modifed,
 * Deleted state) in to the store.
 * @Return No return value
 */
- (void) saveChanges
{   
	SaveResult *result = [[SaveResult alloc] initWithObjectContext:self saveChangesOptions:m_saveChangesOptions];
	
	@try 
	{
		if(self.m_saveChangesOptions == Batch)
		{
			[result batchRequest:self.m_replaceOnUpdateOption];
		}
		else
		{
			[result nonBatchRequest:self.m_replaceOnUpdateOption];
		}
	}
	@catch (ODataServiceException * e) 
	{
		@throw e;
	}
	@catch (NSException * e) 
	{
		@throw e;
	}	
	@finally 
	{
		[result release];
	}
}

/**
 * @Return <bool> 
 * return true of entry (ResourceBox, RelatedEnd) has modifed else false     
 */
- (BOOL) hasModifiedResourceState:(ODataEntity*)anEntry
{
	if(Unchanged != [anEntry getState])
	{
		return YES;
	}
	
	return NO;
}

/** 
 * @param <Object> SourceObject Instance of the entity into which value of
 *                 the property to be loaded.
 * @param <Object> PropertyName Name of the property whose value to be
 *        loaded.
 * @param <DataServiceQueryContinuation> [optional] Used in the case of
 *                                       Server Side Paging
 * @Return QueryOperationResponse
 * If DataServiceQueryContinuation is null then this API will Load deferred
 * content for a specified property from the data service else Loads a page
 * of related m_entities by using the next link URI in
 * dataServiceQueryContinuation.
 */
- (QueryOperationResponse*) loadProperty:(ODataObject*) aSourceObject propertyName:(NSString*)aPropertyName dataServiceQueryContinuation:(DataServiceQueryContinuation*) aDataServiceQueryContinuationObject
{   
	[self throwExceptionIfNotValidObject: aSourceObject methodName:@"LoadProperty"];
	NSString *requestUri = nil;
	ResourceBox *resourceBox = [m_objectToResource tryGetValue:aSourceObject];
	
	if(resourceBox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	NSInteger state = [resourceBox getState];
	if (Added == state)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_NoLoadWithInsertEnd] userInfo:nil];
		[anException raise];
	}
	
	if(aDataServiceQueryContinuationObject != nil)
	{
		requestUri = [aDataServiceQueryContinuationObject getNextLinkUri];
	}
	else
	{
		requestUri = [NSString stringWithFormat:@"%@/%@", [resourceBox getResourceUri:m_baseUriWithSlash], aPropertyName];
	}
	HTTPHandler *httpRequest = [self executeHTTPRequest:requestUri httpmethod:@"GET" httpbody:nil etag:nil];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:requestUri];
	
	NSData *nonUTF8Data = [httpRequest http_response];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:self];
	[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
	if([httpRequest http_error])
	{
		ODataServiceException *e= [[ODataServiceException alloc]initWithError:[[httpRequest http_error]localizedDescription] contentType:nil headers:[httpRequest http_response_headers] statusCode:[httpRequest http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		@throw e;
	}
	
	
	 NSString *variableName = [NSString stringWithFormat:@"m_%@",aPropertyName];
	[[ODataRTTI getObjectInstanceVariable:aSourceObject variablename:variableName] autorelease];
		
	[ODataRTTI setObjectInstanceVariable:aSourceObject varname:variableName value:[[queryOperationResponse getResult]retain]];
	
	[atom release];
	[handler release];
	
	return [queryOperationResponse autorelease];
} 

//#pragma mark execute methods
/*
 * Send HTTP request and store HTTP response
 * @param NSString HTTP URL
 * @param NSString HTTP method
 * @param NSData HTTP body
 * @param NSString object eTag
 * return HTTPHandler
 */
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbodydata:(NSData *)body etag:(NSString *)etag
{
	return [self executeHTTPRequest:aUri httpmethod:method httpbodydata:body etag:etag customHeaders:nil];
}


/*
 * Send HTTP request and store HTTP response
 * @param NSString HTTP URL
 * @param NSString HTTP method
 * @param NSString HTTP body
 * @param NSString object eTag
 * return HTTPHandler
 */
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbody:(NSString *)body etag:(NSString *)etag 
{	
	
	NSData *httpdata = nil;
	if(body == nil)
		httpdata = nil;
	else
		httpdata = [[NSData alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	HTTPHandler * httpHandler =  [self executeHTTPRequest:aUri httpmethod:method httpbodydata:httpdata etag:etag customHeaders:nil];
	[httpdata release];
	return httpHandler;	
}

/*
 * Send HTTP request and store HTTP response
 * @param NSString HTTP URL
 * @param NSString HTTP method
 * @param NSData HTTP body
 * @param NSString object eTag
 * @param NSMutableDictionary collection of custom Headers
 * return HTTPHandler
 */
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbodydata:(NSData *)body etag:(NSString *)etag customHeaders:(NSMutableDictionary *)custom_headers
{
  	NSLog(@"HTTP URL = %@",aUri);
	NSMutableDictionary *headers = [[Utility CreateHeaders:method eTag:etag ODataServiceVersion:[self getDataServiceVersion]] retain];
	
	HTTPHandler *httpRequest = [[HTTPHandler alloc] init];
	[httpRequest setErrorDelegate:self];
	
	[httpRequest setTimeInterval:[self getTimeOutInterval]];
	HttpRequest *request = nil;
	HttpResponse *response = nil;
	NSString *UserName = nil;
	NSString *Password = nil;
	
	NSString *type = [[self getCredentials] getCredentialType];
	
	if(custom_headers != nil)
	{
		id key, value;
		NSArray *keys = [custom_headers allKeys];
		int count = [keys count];
		for (int i = 0; i < count; i++)
		{
			key = [keys objectAtIndex: i];
			value = [custom_headers objectForKey: key];
			[headers setObject:value
						forKey:key];
		}	
	}
	
	if(method == nil)
		method = @"GET";
	else if(![method isEqualToString:@"GET"])
		method = @"POST";
		
	request = [[HttpRequest alloc] initWithUrl:aUri httpMethod:method credential:[self getCredentials] header:headers postBody:body]; 
	[self onBeforeHttpRequest:request];
	

	if([type isEqualToString:@"WINDOWS"])
	{		
		UserName = [[request getCredential] getUserName];
		Password = [[request getCredential] getPassword];
	}
	
	[httpRequest performHTTPRequest:[request getUri] username:UserName password:Password headers:[[request getHeaders] GetAll] httpbody:body httpmethod:method];
	
	response = [[HttpResponse alloc] initWithHTTP:[httpRequest http_response] headers:[httpRequest http_response_headers] httpCode:[httpRequest http_status_code] httpMessage:[[httpRequest http_error] localizedDescription]];
	if([httpRequest http_error])
		[response setHttpError:[httpRequest http_error]];
	
	[self onAfterHttpRequest:response];

	[headers release];
	[request release];
	[response release];
	return [httpRequest autorelease];
}

/*
 * Send HTTP request and store HTTP response
 * @param NSString HTTP URL
 * @param NSString HTTP method
 * @param NSString HTTP body
 * @param NSString object eTag
 * @param NSMutableDictionary collection of custom Headers
 * return HTTPHandler
 */
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbody:(NSString *)body etag:(NSString *)etag customHeaders:(NSMutableDictionary *)custom_headers
{
		
	NSData *httpdata = nil;
	if(body == nil)
		httpdata = nil;
	else
		httpdata = [[NSData alloc ] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	HTTPHandler * httpHandler =  [self executeHTTPRequest:aUri httpmethod:method httpbodydata:httpdata etag:etag customHeaders:custom_headers];
	[httpdata release];
	return httpHandler;
}

- (QueryOperationResponse*) execute:(NSString*)aQuery
{
	QueryComponents *queryComponents = nil;
	NSString *requestUri = [NSString stringWithFormat:@"%@%@",[self getBaseUriWithSlash] ,aQuery];
	queryComponents = [ [QueryComponents alloc] initWithUri:requestUri version:nil];
	
	[queryComponents setUri:[[queryComponents getUri] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
	
	HTTPHandler *httpRequest = [self executeHTTPRequest:[queryComponents getUri] httpmethod:@"GET" httpbody:nil etag:nil];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:[queryComponents getUri]];
	if([httpRequest http_error])
	{
		@throw [[DataServiceRequestException alloc] initWithResponse:queryOperationResponse];
	}
	
	NSData *nonUTF8Data = [httpRequest http_response];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:self];
	[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
	[atom release];
	[handler release];
	return [queryOperationResponse autorelease];
}    
/**
 * executes service operation
 * @param <uri> query
 * @param <string> http method
 * @param <bool> to check weather returntype is a collection or a single value
 * return value is either NSString or NSArray depending upon the value of input parameter isReturnTypeCollection.
 */

- (id) executeServiceOperation:(NSString*)aQuery httpMethod:(NSString*)aHttpMethod isReturnTypeCollection:(BOOL)isReturnTypeCollection
{
	QueryComponents *queryComponents = nil;
	NSString *requestUri = [NSString stringWithFormat:@"%@%@",[self getBaseUriWithSlash] ,aQuery];
	queryComponents = [ [QueryComponents alloc] initWithUri:requestUri version:nil];
	
	[queryComponents setUri:[[queryComponents getUri] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
	
	HTTPHandler *httpRequest = nil;
	if ([self.m_customHeaders count] > 0)
	{
		httpRequest = [self executeHTTPRequest:[queryComponents getUri] httpmethod:aHttpMethod httpbody:nil etag:nil customHeaders:self.m_customHeaders];
	}
	else httpRequest = [self executeHTTPRequest:[queryComponents getUri] httpmethod:aHttpMethod httpbody:nil etag:nil];

	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:[queryComponents getUri]];
	
	[queryComponents release];
	
	NSData *nonUTF8Data = [httpRequest http_response];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:self];
	[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
	if([httpRequest http_error])
	{
		ODataServiceException *e= [[ODataServiceException alloc]initWithError:[[httpRequest http_error]localizedDescription] contentType:nil headers:[httpRequest http_response_headers] statusCode:[httpRequest http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		@throw e;
	}
	
	if(isReturnTypeCollection)
	{
		NSArray *result=[[self getCopy:[queryOperationResponse getResult]]retain];
		[handler release];
		[atom release];
		[queryOperationResponse release];
		
		return [result autorelease];
	}
	else 
	{
		NSArray *result=[queryOperationResponse getResult];
		if([result count]==1)
		{
			id resultObj =[[queryOperationResponse getResult] objectAtIndex:0];
			[handler release];
			[atom release];
			[queryOperationResponse release];
			return resultObj;
		}
		else if([result count]==0)
		{
			[handler release];
			[atom release];
			[queryOperationResponse release];
			return [[[NSString alloc]initWithData:[httpRequest http_response] encoding:NSUTF8StringEncoding]autorelease];
		}
	}
	return nil;
}    

/**     
 * @param <Uri/DataServiceQueryContinutation> $uriOrDSQueryContinuation
 * @return <EntityObjectCollection>
 * Create the HttpRequest for retriving the entity set identified by the
 * uri or DataServiceQueryContinutation object and returns the seralized
 * entity objects
 */
- (QueryOperationResponse*) executeDSQueryContinuation:(DataServiceQueryContinuation*)aDataServiceQueryContinuationObject
{
	QueryComponents *queryComponents = nil;
	queryComponents = [aDataServiceQueryContinuationObject createQueryComponents];       
	
	[queryComponents setUri:[[queryComponents getUri] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];

	
	HTTPHandler *httpRequest = [self executeHTTPRequest:[queryComponents getUri] httpmethod:@"GET" httpbody:nil etag:nil];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:[queryComponents getUri]];
	
	NSData *nonUTF8Data = [httpRequest http_response];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:self];
	[atom EnumerateObjects:theXMLDocument  queryResponseObject:queryOperationResponse];
	if([httpRequest http_error])
	{
		ODataServiceException *e= [[ODataServiceException alloc]initWithError:[[httpRequest http_error]localizedDescription] contentType:nil headers:[httpRequest http_response_headers] statusCode:[httpRequest http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		@throw e;
	}
	[atom release];
	[handler release];
	return [queryOperationResponse autorelease];
}    

#pragma mark other methods
/**
 * @param <ResourceBox/RelatedEnd> resourceBoxOrRelatedEnd
 * Increment the changeOrder associated with Entry (ResourceBox or RelatedEnd)
 * @Return No return value
 */
- (void) incrementChange :(ODataEntity*) anEntity
{
	++self.m_nextChange;
	[anEntity setChangeOrder:[self getNextChange]];
}

/** 
 * @param <RelatedEnd> relatedEnd
 * @Return No return value
 * Check whether creating a link between relatedEnd::SourceResource and 
 * relatedEnd::TargetResource is valid based on current states
 */
- (void) validateAddLink:(RelatedEnd*) aRelatedEndObject 
{
	ODataObject* sourceObject = [aRelatedEndObject getSourceResource];
	NSString* sourceProperty = [NSString stringWithString:[aRelatedEndObject getSourceProperty]];
	ODataObject* targetObject = [aRelatedEndObject getTargetResource];
	
	ResourceBox *sourceResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:sourceObject];
	
	if (!sourceResourceBox)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	ResourceBox *targetResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:targetObject];
	
	if (!targetResourceBox)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	if (([sourceResourceBox getState] == Deleted) || ((targetResourceBox != nil) && ([targetResourceBox getState] == Deleted)))
	{
		ODataServiceException* errorObj = [[ODataServiceException alloc] initWithName:@"Invalid Operation" reason:Resource_NoRelationWithDeleteEnd userInfo:nil];
		
		@throw errorObj;
		
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_NoRelationWithDeleteEnd] userInfo:nil];
		[anException raise];
	}
	
	if ([m_bindings containsKey:aRelatedEndObject] == YES) // as no previously
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_RelationAlreadyContained] userInfo:nil];
		[anException raise];
	}
	
	
	@try 
	{
		[self checkRelationForObject:sourceObject property:sourceProperty method:@"addLink"];
	}
	@catch (NSException * e) {
		NSLog(@"exception:%@:%@",[e name],[e reason]);
		@throw e;
	}

}

/**
 * @param <RelatedEnd> relatedEnd
 * @Return No return value
 * Check whether creating  reference link between relatedEnd::SourceResource
 * and relatedEnd::TargetResource is valid based on current states
 */
- (void) validateSetLink:(RelatedEnd*) aRelatedEndObject
{
	ODataObject* sourceObject = [aRelatedEndObject getSourceResource];
	NSString* sourceProperty = [NSString stringWithString:[aRelatedEndObject getSourceProperty]];
	ODataObject* targetObject = [aRelatedEndObject getTargetResource];
	
	if(targetObject == nil)
		return;
	
	ResourceBox *sourceResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:sourceObject];
	
	if (!sourceResourceBox)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	ResourceBox *targetResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:targetObject];
	
	if (!targetResourceBox)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	if (([sourceResourceBox getState] == Deleted) || ((targetResourceBox != nil) && ([targetResourceBox getState] == Deleted)))
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_NoRelationWithDeleteEnd] userInfo:nil];
		[anException raise];
	}
	@try 
	{
		[self checkRelationForObject:sourceObject property:sourceProperty method:@"setLink"];
	}
	@catch (NSException * e) {
		@throw e;
	}
}

/** 
 * @param <RelatedEnd> relatedEnd
 * @Return No return value
 * Check whether deleteing a link between relatedEnd::SourceResource and 
 * relatedEnd::TargetResource is valid based on current states
 */
- (void) validateDeleteLink:(RelatedEnd*) aRelatedEndObject
{
	ODataObject* sourceObject = [aRelatedEndObject getSourceResource];
	NSString* sourceProperty = [NSString stringWithString:[aRelatedEndObject getSourceProperty]];
	ODataObject* targetObject = [aRelatedEndObject getTargetResource];
	
	ResourceBox *sourceResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:sourceObject];
	
	if (!sourceResourceBox)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	ResourceBox *targetResourceBox = (ResourceBox*)[m_objectToResource tryGetValue:targetObject];
	
	if (!targetResourceBox)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	if (([sourceResourceBox getState] == Deleted) || ((targetResourceBox != nil) && ([targetResourceBox getState] == Deleted)))
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_NoRelationWithDeleteEnd] userInfo:nil];
		[anException raise];
	}
	@try 
	{
		[self checkRelationForObject:sourceObject property:sourceProperty method:@"deleteLink"];
	}
	@catch (NSException * e) {
		NSLog(@"exception:%@:%@",[e name],[e reason]);
		@throw e;
	}
	
}

-(void) checkRelationForObject:(ODataObject*)sourceObject property:(NSString *)sourceProperty method:(NSString *)method 
{	
	BOOL isfound=NO;
	
	NSString *toRole=[[sourceObject getEntityMap] objectForKey:sourceProperty];
	if(toRole == nil)
			@throw [NSException exceptionWithName:@"Invalid Operation" reason:Resource_RelationNotRefOrCollection userInfo:nil];
	
	NSString *relationship=[[sourceObject getEntityFKRelation] objectForKey:toRole];
	if(relationship == nil)
		@throw [NSException exceptionWithName:@"Invalid Operation" reason:Resource_RelationNotRefOrCollection userInfo:nil];
		
	NSArray *arrOfAssociation=[m_association objectForKey:relationship];
	if(arrOfAssociation == nil)
		@throw [NSException exceptionWithName:@"Invalid Operation" reason:Resource_RelationNotRefOrCollection userInfo:nil];
	
	int count=[arrOfAssociation count];
	for(int z = 0; z < count; z++)
	{
		if([[[arrOfAssociation objectAtIndex:z] objectForKey:@"EndRole"] isEqualToString:toRole])
		{
			isfound=YES;
			NSString *multiplicity=[[arrOfAssociation objectAtIndex:z] objectForKey:@"Multiplicity"];
			if(!(  ([method isEqualToString:@"setLink"] && [multiplicity isEqualToString:@"0..1"]) ||
				 ([method isEqualToString:@"setLink"] && [multiplicity isEqualToString:@"1"]) ||
				 ([method isEqualToString:@"addLink"] && [multiplicity isEqualToString:@"*"]) ||
				 ([method isEqualToString:@"deleteLink"])   ))
			{
				//Invalid Operation
				@throw [NSException exceptionWithName:@"Invalid Operation" reason:Resource_InCorrectLinking userInfo:nil];//incorrect linking
			}
			break;    
		}
	}
	
	if(!isfound)
	{
		//Invalid Operation
		@throw [NSException exceptionWithName:@"Invalid Operation" reason:Resource_RelationNotRefOrCollection userInfo:nil];//not associated entities
	}
	
}

/**
 * @param <ResourceBox> resourceBox
 * @Return No return value
 * Detach all m_bindings created with resourceBox::Resource as 
 * source object
 */
- (void) detachRelated:(ResourceBox*) aResourceBoxObject
{
	NSArray* bindingValues = [m_bindings values];
	NSUInteger count = [bindingValues count];
	
	for(NSUInteger index=0;index<count;++index)
	{
		RelatedEnd* bindingValue = (RelatedEnd*)[bindingValues objectAtIndex:index];
		if ( (bindingValue != nil) && ([aResourceBoxObject isRelatedEntity:bindingValue] == YES))
		{
			[self detachExistingLink:bindingValue];
		}
	}
}

/**
 * @param <RelatedEnd> relatedEnd
 * Remove the relatedEnd from Binding dictionary
 */
- (void) detachExistingLink:(RelatedEnd*) aRelatedEndObject
{
	if ([ m_bindings remove: aRelatedEndObject] == YES)
	{
		[aRelatedEndObject setState:Detached];
		ResourceBox *resourceBox = (ResourceBox*)[m_objectToResource tryGetValue:[aRelatedEndObject getSourceResource]];
		if(resourceBox != nil)
		{
			resourceBox.m_relatedLinkCount--;
		}
	}
}

/**     
 * @param <Object> source
 * @param <string> sourceProperty
 * @param <Object> target
 * @return <RelatedEnd or null>
 * This function is used by SetLink API. If SetLink is already called to add
 * link between source and target, then this function returns the existing
 * binding. If SetLink is called between source and some other target then
 * this function detach that link
 */ 
	
- (RelatedEnd*) detachReferenceLink:(ODataObject*) aSourceObject sourceProperty:(NSString*)aSourceProperty targetObject:(ODataObject*)aTargetObject
{
	NSArray* bindingValues = [m_bindings values];
	NSUInteger count = [bindingValues count];
	
	for(NSUInteger index=0;index<count;++index)
	{
		RelatedEnd* relatedEnd = (RelatedEnd*)[bindingValues objectAtIndex:index];
		if(relatedEnd != nil)
		{
			if (   ( [[[relatedEnd getSourceResource] getObjectID] isEqualToString:[aSourceObject getObjectID]] ) 
				&& ( [[relatedEnd getSourceProperty] isEqualToString:aSourceProperty] ) )
			{
				if(((nil == aTargetObject) && (nil ==[relatedEnd getTargetResource])) ||
				   ((nil != aTargetObject) && (nil != [relatedEnd getTargetResource])
					&& ([[aTargetObject getObjectID] isEqualToString:[[relatedEnd getTargetResource] getObjectID]]))
				   )
				{                    
					return relatedEnd;
				}
				[self detachExistingLink:relatedEnd];
			}
		}            
	}        
	return nil;
}

/**
 * @param <string> str
 * @param<ResourceBox> resourceBox
 * This function will update the $resourceBox::Source object by parsing
 * the atom XML in $str
 */
- (void) loadResourceBox:(NSString*) aString resouceBox:(ResourceBox*) aResourceBox contentType:(NSString*) am_contentType
{
	
	NSString *uri = nil;
	AtomEntry *atomEntry = nil;
	
	if(uri)
	{
		NSInteger index = [Utility reverseFind:uri findString:@"/"];
		if(index != -1 )
		{
			NSString *editLink = [uri substringFromIndex:(index + 1)];
			[aResourceBox setIdentity:uri];
			[aResourceBox setEditLink:editLink];
		}
	}
	
	//If $str represents content of entry of type Media then
	//popluate values specific to media entry 
	if([atomEntry getEditMediaLink] != nil)
		[aResourceBox setEditMediaLink:[NSString stringWithFormat:@"%@",[atomEntry getEditMediaLink]]];

	
		[aResourceBox setMediaLinkEntry:[atomEntry getMediaLinkEntry]];
	
	if([atomEntry getStreamETag] != nil)
		[aResourceBox setStreamETag:[NSString stringWithFormat:@"%@",[atomEntry getStreamETag]]];
	
	if([atomEntry getEntityETag] != nil)
		[aResourceBox setEntityTag:[NSString stringWithFormat:@"%@",[atomEntry getEntityETag]]];
	
	if([atomEntry getMediaContentUri] != nil)
		[aResourceBox setStreamLink:[NSString stringWithFormat:@"%@",[atomEntry getMediaContentUri]]];
	
}	

/**
 * @param <string> entityType Name of entity Type
 * @param <AtomEntry> atomEntry AtomEntry
 * @return <Object> The object representing the entity instance
 * This function will check whether an object with identity
 * atomEntry::Identity exists in the context, if it exists return that
 * object. If not create the object for that entity instance, add it to
 * m_objectToResource and return it.
 */
- (ODataObject*) addToObjectToResource:(NSString*) anEntityType atomEntry:(AtomEntry*)anAtomEntryObject
{
	NSString *uri = [NSString stringWithFormat:@"%@",[anAtomEntryObject getIdentity]];
	
	if(m_identityToResource != nil)
	{
		ResourceBox * resourceBox = (ResourceBox*)[m_identityToResource objectForKey:uri];
		if(resourceBox)
		{
			return [resourceBox getResource];
		}
	}
	id resource = nil;
	@try
	{ 
		resource = [[NSClassFromString(anEntityType) alloc] initWithUri:uri];
		NSString *editLink =nil;
		NSInteger index = [Utility reverseFind:uri findString:@"/"];
		if(index != -1)
		{
			editLink = [uri substringFromIndex:(index + 1)];
		}
		
		ResourceBox *resourceBox = [[ResourceBox alloc] initWithIdentity:uri editLink:editLink resource:resource];
		
		if([anAtomEntryObject getEditMediaLink] != nil)
			[resourceBox setEditMediaLink:[NSString stringWithFormat:@"%@",[anAtomEntryObject getEditMediaLink]]];
		[resourceBox setMediaLinkEntry:[anAtomEntryObject getMediaLinkEntry]];
			
		if([anAtomEntryObject getStreamETag]!= nil)
			[resourceBox setStreamETag:[NSString stringWithFormat:@"%@",[anAtomEntryObject getStreamETag]]];
		
		if([anAtomEntryObject getEntityETag] != nil)
			[resourceBox setEntityTag:[NSString stringWithFormat:@"%@",[anAtomEntryObject getEntityETag]]];
		
		if([anAtomEntryObject getMediaContentUri] != nil)
			[resourceBox setStreamLink:[NSString stringWithFormat:@"%@",[anAtomEntryObject getMediaContentUri]]];
		
		[resourceBox setState:Unchanged];
		
		[m_objectToResource add:resource value:resourceBox];
		
		[m_identityToResource setObject:resourceBox forKey:uri];
		
		[resourceBox release];
		[resource release];
		
		resourceBox = (ResourceBox*)[m_identityToResource objectForKey:uri];
		if(resourceBox)
		{
			return [resourceBox getResource];
		}
	}
	@catch (NSException *ex)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_InvalidEntityClassName] userInfo:nil];
		[anException raise];
	}
	return nil;
}


/**
 * @param <Object> sourceObject
 * @param <string> sourcePropertyName
 * @param <Object> object
 * When user perfroms a query operation with expand option or LoadProperty
 * method, then the binding between the SourceObject and Target object become 
 * binding in the context. This function will add such a binding to Bindinds
 * dictionary
 */
- (void) addToBindings:(ODataObject*) aSourceObject sourcePropertyName:(NSString*) aSourcePropertyName targetObject:(ODataObject*) aTargetObject
{
	RelatedEnd * binding = [[RelatedEnd alloc] initWithObject:aSourceObject sourceProperty:aSourcePropertyName targetResource:aTargetObject];
	
	if ([ m_bindings containsKey: binding] == NO)
	{
		[binding setState:Unchanged];
		[m_bindings add:binding value:binding];
	}
	[binding release];
	binding = nil;
}

/**
 * @param <Object> object
 * @param <string> from
 *	Test the object object is an object if not throws exception
 */
- (void) throwExceptionIfNotValidObject:(id)anObject methodName:(NSString*) aMethodName
{
	ODataObject * obj = (ODataObject*)anObject;
	if( [obj isKindOfClass:[ODataObject class]] )
	{
		return;
	}
	
	NSString * message = nil;
	if([aMethodName isEqualToString:@"AddObject"])			message = Resource_AddInvalidObject;
	else if([aMethodName isEqualToString:@"UpdateObject"])	message = Resource_UpdateInvalidObject;
	else if([aMethodName isEqualToString:@"DeleteObject"])	message = Resource_DeleteInvalidObject;
	else if([aMethodName isEqualToString:@"AddLink"])		message = Resource_AddLinkInvalidObject;
	else if([aMethodName isEqualToString:@"SetLink"])		message = Resource_SetLinkInvalidObject;
	else if([aMethodName isEqualToString:@"DeleteLink"])	message = Resource_DeleteLink;
	else if([aMethodName isEqualToString:@"LoadProperty"])	message = Resource_LoadPropertyInvalidObject;
	else													message = Resource_InvalidObject;
	
	NSException *anException = [NSException exceptionWithName:@"InvalidOperation" reason:message userInfo:nil];
	[anException raise];
}

/**
 * For adding a custom header.
 * @param string headerName The custom header name
 * @param string HeaderValue The custom header value
 */
- (void) addHeader:(NSString*) aHeaderName headerValue:(NSString*)aHeaderValue
{
	[ m_customHeaders setObject:aHeaderValue forKey:aHeaderName];
}

/**
 * For clearing the array holding custom headers.
 */
- (void) removeHeaders
{
	[m_customHeaders removeAllObjects];
}

/**
 * This function returns the entity set name corrosponding to entity type
 * @param <string> entityType The Entity Type
 * @Return <string> 
 * Returns Entity set Name
 */
- (NSString*) getEntitySetNameFromType:(NSString*) aEntityType
{
	NSString * lowerCaseEntityName = [aEntityType lowercaseString];                                                                                                                                                                  
	NSString * entitySet = [m_entityType2Set objectForKey:lowerCaseEntityName];
	
	if(entitySet == nil )
	{
		entitySet = [NSString stringWithString:aEntityType];
	}
	
	return entitySet;
}

/**
 * This function returns the entity name corrosponding to entity set
 * @param <string> entitySet The Entity Set Name
 * @Return <string>
 * Returns Entity Type Name
 */
- (NSString*) getEntityTypeNameFromSet:(NSString*) aEntitySet
{
	NSString * lowerCaseEntityName = [aEntitySet lowercaseString];
	NSString * entityType = [m_entitySet2Type objectForKey:lowerCaseEntityName];
	
	if(entityType == nil && aEntitySet != nil)
	{
		entityType = [NSString stringWithString:aEntitySet];
	}
	
	return entityType;
}

/**     
 * @param <string> relationship The Name of m_association
 * @param <string> fromOrToRole The Name of From or To Role
 * @return <string>
 * Returns the relationship 0..1, 1 or *
 */
- (NSString*) getRelationShip:(NSString*) aRelationship fromOrToRole: (NSString*) aFromOrToRole
{
	NSString * relationship = [[m_association objectForKey:aRelationship] objectForKey:aFromOrToRole];
	if(relationship == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithString:@"Invalid Operation : Invalid RelationShip ($relationship) or FromToRole ($fromOrToRole)"] userInfo:nil];
		[anException raise];
	}
	
	return relationship;
}

/**
 * @param<EntityObject> entity
 * @return <uri>
 * Gets the URI that is used to return binary property data as a data stream. 
 */
- (NSString*) getReadStreamUri:(ODataEntity*) anEntity
{
	ResourceBox* resourceBox = (ResourceBox*)[ m_objectToResource tryGetValue:anEntity];
	if(resourceBox != nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Invalid Operation" reason:Resource_EntityNotContained userInfo:nil];
		[anException raise];
	}
	
	return [resourceBox getMediaResourceUri:m_baseUriWithSlash];
}

/**
 * @param<EntityObject> entity
 * @param<null, string or object of DataServiceRequestArgs> args
 * @return <DataServiceStreamResponse>
 * Synchronously requests a data stream that contains the binary property of
 * requested Media Link Entry $entity. The $args argument can be null,
 * a string representing m_accept message header or instance of DataServiceRequestArgs
 * class which contains settings for the HTTP request message (Slug, m_accept,
 * Content-Type etc..)
 */

//need to check the return type.
- (DataServiceStreamResponse*) getReadStream:(ODataObject*)anODataObject 
{       
	HTTPHandler *httpRequest;
	ResourceBox *resourceBox = [m_objectToResource tryGetValue:anODataObject];
	
	if(resourceBox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotContained]  userInfo:nil];
		[anException raise];
	}
	
	NSString *mediaResourceUri = [resourceBox getMediaResourceUri:m_baseUriWithSlash];
	if (mediaResourceUri == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:[NSString stringWithFormat:@"Invalid Operation : %@", Resource_EntityNotMediaLinkEntry]  userInfo:nil];
		[anException raise];
	}
	
	
	httpRequest = [self executeHTTPRequest:mediaResourceUri httpmethod:@"GET" httpbody:nil etag:nil];
	if([httpRequest http_error])
	{
		QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpRequest http_response_headers] innerException:[httpRequest.http_error localizedDescription] statusCode:[httpRequest http_status_code] query:mediaResourceUri];
		ODataServiceException *e=[[ODataServiceException alloc]initWithError:[[httpRequest http_error] localizedDescription] contentType:nil headers:[httpRequest http_response_headers] statusCode:[httpRequest http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		[queryOperationResponse release];
		@throw e;
	
	}
	
	HttpResponse *response=[[HttpResponse alloc]initWithHTTP:[httpRequest http_response] headers:[httpRequest http_response_headers] httpCode:[httpRequest http_status_code] httpMessage:nil];
	DataServiceStreamResponse *streamResponse=[[DataServiceStreamResponse alloc]initWithHttpResponse:response];
	[response release];
	return [streamResponse autorelease];
	
}

/**
 * @param<EntityObject> entity
 * @param<BinaryStream> stream
 * @param<boolean> closeStream
 * @param<HttpRequestHeader::m_contentType> m_contentType
 * @param<HttpRequestHeader::Slug> slug
 * @return<none>
 * Sets a new data stream as the binary property of an entity, with the
 * specified settings in the request message
 */
- (void) setSaveStream:(ODataObject*)anODataObject stream:(NSData*)aStream closeStream:(BOOL)aCloseStream contentType:(NSString*)aContentType slug:(NSString*)aSlug
{
	if(aContentType == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"InvalidOperation" reason:[NSString stringWithFormat:@"SetSaveStream: The contentType %@", Resource_ArgumentNotNull] userInfo:nil];
		[anException raise];
	}
	
	if(aSlug ==nil)
	{
		NSException *anException = [NSException exceptionWithName:@"InvalidOperation" reason:[NSString stringWithFormat:@"SetSaveStream: The slug %@", Resource_ArgumentNotNull] userInfo:nil];
		[anException raise];
	}
	
	if(aStream == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"InvalidOperation" reason:[NSString stringWithFormat:@"SetSaveStream: The stream %@", Resource_ArgumentNotNull] userInfo:nil];
		[anException raise];
	}
	
	ResourceBox *resourceBox = [m_objectToResource tryGetValue:anODataObject];
	if(resourceBox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"InvalidOperation" reason:[NSString stringWithFormat:@"%@", Resource_EntityNotContained] userInfo:nil];
		[anException raise];
	}
	
	DataServiceRequestArgs *args = [[DataServiceRequestArgs alloc]init];
	[args setContentType:m_contentType];
	[args setSlug:aSlug];
	
	[resourceBox setMediaLinkEntry:YES];
	ContentStream * contentstream = [[ContentStream alloc] initWithStream:aStream isKnownMemoryStream:YES];
	[resourceBox setSaveStream:[[DataServiceSaveStream alloc] initWithStream:contentstream dataServiceRequestArgs:args]];  
	
	if([resourceBox getState] != Added)
		[resourceBox setState:Modified];
}


/**
 * @param<Uri> requestUri
 * @param<NSString*> httpVerb
 * @param<boolean> allowAnyType
 * @param<NSString> m_contentType
 * @param<NSString> m_dataServiceVersion
 * @return <HttpRequest>
 * Create an HttpRequest object with certain headers set based on the
 * parameters passed.
 */
- (HttpRequest*) createRequest:(NSString*) aRequestUri httpVerb:(NSString*)aHttpVerb allowAnyType:(BOOL) allowAnyType contentType:(NSString*)am_contentType dataServiceVersion:(NSString*)am_dataServiceVersion
{
	
	NSMutableDictionary * headers = [NSMutableDictionary dictionaryWithCapacity:5];
	
	if( ( m_usePostTunneling == YES ) && ( [aHttpVerb isEqualToString:HttpVerb_POST] ==NO ) && ( [aHttpVerb isEqualToString:HttpVerb_GET] == NO) )
	{
		[headers setObject:aHttpVerb forKey:HttpRequestHeader_XHTTPMethod];
		aHttpVerb = HttpVerb_POST;
	}
	
	if(am_dataServiceVersion == nil)
	{
		am_dataServiceVersion = Resource_DataServiceVersion_1;
	}
	
	if(allowAnyType == YES)
	{
		NSString *str = [NSString stringWithString:@"*/*"];
		[headers setObject:str forKey:HttpRequestHeader_Accept];
	}
	else
	{
		NSString *str = [NSString stringWithString:@"application/atom+xml,application/xml"];
		[headers setObject:str forKey:HttpRequestHeader_Accept];
	}
	
	[headers setObject:[NSString stringWithString:@"UTF-8"] forKey:HttpRequestHeader_AcceptCharset];
	[headers setObject:[NSString stringWithString:am_dataServiceVersion] forKey:@"m_dataServiceVersion"];
	[headers setObject:[NSString stringWithString:Resource_DataServiceVersion_2] forKey:@"Maxm_dataServiceVersion"];
	
	if([aHttpVerb isEqualToString:HttpVerb_GET] == NO)
	{
		[headers setObject:[NSString stringWithString:am_contentType] forKey:HttpRequestHeader_ContentType];

	}
	
	HttpRequest* request = [[HttpRequest alloc] initWithUrl:aRequestUri httpMethod:aHttpVerb credential:nil header:headers postBody:nil];  
	return [request autorelease];
}


/**     
 * @param <EntityObject> entity
 * @param <Uri> location
 * Update the EditLink and Identity of ResourceBox representing the $entity
 * using location, Also update the m_identityToResource Dictionary.
 */
- (void) attachLocation:(ODataObject*)anODataObject location:(NSString*)aLocation
{
	if(aLocation == nil)
		return;
	
	if([m_identityToResource objectForKey:aLocation] != nil)
	{
		[m_identityToResource removeObjectForKey:aLocation];
	}
	
	ResourceBox *resourceBox = [m_objectToResource tryGetValue:anODataObject];
	
	if(resourceBox == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"InternalError" reason:Resource_AttachLocationFailedDescRetrieval userInfo:nil];
		[anException raise];
	}
	
	NSString *editLink =nil;
	
	NSInteger index = [Utility reverseFind:aLocation findString:@"/"];
	
	if(index != -1)
	{
		editLink = [aLocation substringFromIndex:(index + 1)];
	}
	[resourceBox setIdentity:aLocation];
	[resourceBox setEditLink:editLink];
	[m_identityToResource setObject:resourceBox forKey:aLocation];
}

-(void) setEntitiesWithArray:(NSArray *)anArray
{
	[self setEntities:[[[NSArray alloc]initWithArray:anArray] autorelease] ];
}


-(void) setEntitySet2TypeWithObject:(NSArray *)anArrayOfEntityType forKey:(NSArray *)anArrayOfEntitySet
{
	if([anArrayOfEntitySet count] != [anArrayOfEntityType count])
		return;
	NSUInteger count = [anArrayOfEntityType count];
	for(NSUInteger index = 0 ;index < count ; ++index)
	{
		[m_entitySet2Type setObject:[anArrayOfEntityType objectAtIndex:index] forKey:[anArrayOfEntitySet objectAtIndex:index]];
	}
	
}


-(void) setEntityType2SetWithObject:(NSArray *)anArrayOfEntitySet forKey:(NSArray *)anArrayOfEntityType
{
	if([anArrayOfEntityType count] != [anArrayOfEntitySet count])
		return;
	NSUInteger count = [anArrayOfEntityType count];
	for(NSUInteger index = 0 ;index < count ; ++index)
	{
		[m_entityType2Set setObject:[anArrayOfEntitySet objectAtIndex:index] forKey:[anArrayOfEntityType objectAtIndex:index]];
	}
	
}


-(void) setAssociationforObjects:(NSArray *)anArrayOfDictionaries forKeys:(NSArray *)aForeignKeysArray
{
	NSUInteger count = [aForeignKeysArray count];
	for(NSUInteger index=0;index<count;index++)
	{
		[m_association setObject:[anArrayOfDictionaries objectAtIndex:index] forKey:[aForeignKeysArray objectAtIndex:index]];
	}
	
}

- (NSMutableDictionary*) getCustomHeaders
{
	return m_customHeaders;
}

- (void) retrieveSVC:(NSString*)aUri
{
	HTTPHandler *httpRequest = [self executeHTTPRequest:aUri httpmethod:@"GET" httpbody:nil etag:nil];
	if([httpRequest http_status_code] == 200)
	{
		NSData *nonUTF8Data = [httpRequest http_response];
		ODataXMlParser *handler = [[ODataXMlParser alloc] init];
		ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
		AtomParser *atom = [[AtomParser alloc] initwithContext:self];
		[atom retrieveServices:m_ODataSVC xmlDocument:theXMLDocument];
		[atom release];
		[handler release];
	}
}

- (NSMutableDictionary*) getWorkspaces
{
	return [m_ODataSVC getWorkspaces];
}
	
- (ODataWorkspace*) getWorkspace:(NSString*)aTitle
{
	return [m_ODataSVC getWorkspace:aTitle];
}

- (NSMutableArray *)getCopy:(NSArray *)queryOperationResponseArray
{
	NSMutableArray *tempArray=[[NSMutableArray alloc]init];
	int count=[queryOperationResponseArray count];
	for (int i=0; i<count; i++) 
	{
		id obj=[[queryOperationResponseArray objectAtIndex:i] getDeepCopy];
		[tempArray addObject:obj];
	}
	return [tempArray autorelease];
}


/**
 * To invoke client registered callback using onBeforeSend.
 *
 * @param <HttpRequest> httpRequest
 */
- (void) onBeforeHttpRequest:(HttpRequest *)request
{
	if(m_oDataDelegate!=nil && [m_oDataDelegate respondsToSelector:@selector(onBeforeSend:)])
	{
		[m_oDataDelegate onBeforeSend:request];
	}
}

/**
 * To invoke client registered callback using onAfterReceive.
 *
 * @param <HttpRequest> httpRequest
 */
- (void) onAfterHttpRequest:(HttpResponse *)response
{
	if(m_oDataDelegate!=nil && [m_oDataDelegate respondsToSelector:@selector(onAfterReceive:)])
	{
		[m_oDataDelegate onAfterReceive:response];
	}
}

- (void)onSuccess:(NSData*)data
{
	NSLog(@"DATA recieved= [%@]",data);
}

- (void)onError:(NSError*)error
{
	if(m_objectContextdelegate!=nil)
	{
		[m_objectContextdelegate onError:error];
	}
}
/*
 *prepare query for service operation
 *@param <string> functionName
 *@param <dictionary> contains key value pairs for parameter names and their values
 *returns url string 
 */

-(NSString *)prepareQuery:(NSString*)aFunctionName parameters:(NSDictionary*)aParam
{
	NSString* anUrl=aFunctionName;
	if(aParam)
	{
		NSArray* arrOfObjects=[aParam allValues];
		NSArray* arrOfKeys=[aParam allKeys];
		
		int count=[arrOfKeys count];
		if (count)
		{
			id obj=[arrOfObjects objectAtIndex:0];
			id key=[arrOfKeys objectAtIndex:0];
			if(obj)
			{
				if([obj isKindOfClass:[NSString class]])
					anUrl=[anUrl stringByAppendingFormat:@"?%@='%@'",key,obj];
				else if([obj isKindOfClass:[NSDecimalNumber class]])
					anUrl=[anUrl stringByAppendingFormat:@"?%@=%@f",key,obj];
				else if([obj isKindOfClass:[NSDate class]])
				{				
					NSString *dateString = [self retrieveDate:obj];
					anUrl=[anUrl stringByAppendingFormat:@"?%@=%@",key,dateString];
				}
				else 
					anUrl=[anUrl stringByAppendingFormat:@"?%@=%@",key,obj];
			}
			for (int i=1; i<count; i++) 
			{
				obj=[arrOfObjects objectAtIndex:i];
				key=[arrOfKeys objectAtIndex:i];
				if(obj)
				{
					if([obj isKindOfClass:[NSString class]])
						anUrl=[anUrl stringByAppendingFormat:@"&%@='%@'",key,obj];
					else if([obj isKindOfClass:[NSDecimalNumber class]])
						anUrl=[anUrl stringByAppendingFormat:@"&%@=%@f",key,obj];
					else if([obj isKindOfClass:[NSDate class]])
					{
						NSString *dateString = [self retrieveDate:obj];
						anUrl=[anUrl stringByAppendingFormat:@"&%@=%@",key,dateString];
					}
					else
						anUrl=[anUrl stringByAppendingFormat:@"&%@=%@",key,obj];
				}
			}
		}
	}
	return anUrl;	
}

/*
 *convert date into proper format
 *@param <date> date
 *returns date in yyyy-MM-ddTHH:mm:ss.SSSSSSS format
 */

-(NSString *) retrieveDate:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"];
	NSString *dateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	
	return dateString;
}

/*
 delegate mehtod for ErrorDelegate protocol
*/
-(void)errorOccured:(HTTPHandler*)handle andResourceUri:(NSString*)resUri
{
	NSDictionary *userInfoDict=nil;
	NSString *contentType=[handle.http_response_headers objectForKey:@"Content-Type"];
	
	NSRange aRange = [contentType rangeOfString:@"application/xml"];
	if (aRange.location ==NSNotFound) {
		//string not found;
		NSString *exceptionDesc=[[[NSString alloc] initWithData:[handle http_response] encoding:NSUTF8StringEncoding] autorelease];
		[NSDictionary dictionaryWithObject:exceptionDesc forKey:NSLocalizedDescriptionKey];

	} else {
		
		ODataXMlParser *parse = [[ODataXMlParser alloc] init];
		ODataXMLElements *theXMLDocument = [parse parseData:[handle http_response]];
		AtomParser *atom = [[AtomParser alloc] initwithContext:self];
		QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[handle http_response_headers] innerException:nil statusCode:[handle http_status_code] query:resUri];
		[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
		userInfoDict =[NSDictionary dictionaryWithObject:atom.m_queryResponseObject.m_innerException forKey:NSLocalizedDescriptionKey];
		
		[atom release];
		[parse release];
		[queryOperationResponse release];
	}
	
	 NSError *error = [[[NSError alloc] initWithDomain:@"ODataError"
	 code:handle.http_status_code
	 userInfo:userInfoDict] autorelease];
	
	 handle.http_error = error;
	
}

@end
