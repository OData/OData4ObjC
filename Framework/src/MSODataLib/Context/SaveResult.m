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

#import "SaveResult.h"
#import "Dictionary.h"
#import "constants.h"
#import "ODataGUID.h"
#import "HttpResponse.h"
#import "HTTPHandler.h"
#import "AtomParser.h"
#import "ODataXMlParser.h"
#import "ODataServiceException.h"
#import "HttpBatchRequest.h"
#import "HttpBatchResponse.h"


@implementation SaveResult
@synthesize m_context , m_batchBoundary, m_changesetBoundry;
@synthesize m_batchRequestBody , m_completed , m_entryIndex;
@synthesize m_processingMediaLinkEntry , m_mediaResourceRequestStream , m_isAzureRequest;
@synthesize m_processingMediaLinkEntryPut, m_httpResponsesArray;

- (void) dealloc
{
	[m_changedEntries release];
	m_changedEntries = nil;
	
	[m_batchBoundary release];
	m_batchBoundary = nil;
	
	[m_changesetBoundry release];
	m_changesetBoundry = nil;
	
	[m_batchRequestBody release];
	m_batchRequestBody = nil;
	
	[m_httpResponsesArray release];
	m_httpResponsesArray = nil;
	
	[m_mediaResourceRequestStream release];
	m_mediaResourceRequestStream = nil;
	
	[m_operationResponses release];
	m_operationResponses = nil;
	
	[m_changeOrderIDToHttpStatus release];
	m_changeOrderIDToHttpStatus = nil;
	
	[super dealloc];
}

/**
 * Constructs a new SaveResult Object.
 *  @param ObjectContext m_context The m_context object.
 */     
- (id) initWithObjectContext:(ObjectContext*)anObjectContext saveChangesOptions:(NSInteger)aSaveChangesOptions
{
	if(self = [super init])
	{
		if([[[anObjectContext getCredentials] getCredentialType] isEqualToString:@"AZURE"])
			self.m_isAzureRequest = YES;
		else
			self.m_isAzureRequest = NO;
		
		self.m_entryIndex = 0;
		
		[self setContext:anObjectContext];
		
		Dictionary *mergedDictionary = [Dictionary Merge:[m_context getObjectToResource] dictionary2:[m_context getBindings] propertyName:@"State" propertyValue:Unchanged condition:NO];
		
		m_changedEntries = [[mergedDictionary sortObjects] retain];
		[self setBatchBoundary:[NSString stringWithFormat:@"batch_%@",[ODataGUID GetNewGuid]]];
		[self setChangesetBoundry:[NSString stringWithString:@""]];
		self.m_completed = NO;
		
		self.m_processingMediaLinkEntry = NO;
		self.m_processingMediaLinkEntryPut = NO;
		self.m_mediaResourceRequestStream = nil;
		m_operationResponses = [[NSMutableArray alloc]init];
		m_changeOrderIDToHttpStatus = [[NSMutableDictionary alloc]init];
		
		if(aSaveChangesOptions == None)
		{
			NSArray *entries = [[m_context getObjectToResource] values];
			if(entries)
			{
				NSUInteger count = [entries count];
				for(NSUInteger index = 0; index < count; ++index)
				{
					ResourceBox* resourceBox = (ResourceBox*)[entries objectAtIndex:index];
					if(resourceBox)
					{
						if( ( [resourceBox getState] == Unchanged )&& ( [resourceBox getSaveStream]  != nil) )
						{
							[m_changedEntries addObject:resourceBox];
						}
					}
				}
			}
		}
	}
	return self;
}

/*
 * This function will generates the batchrequest from the m_changedEntries
 * list
 */
- (void) batchRequest:(BOOL) aReplaceOnUpdateOption
{			
	[self setChangesetBoundry:[NSString stringWithFormat:@"changeset_%@",[ODataGUID GetNewGuid]]];
	NSUInteger changedEntriesCount = [m_changedEntries count];
	
	if(changedEntriesCount > 0)
	{		
		m_batchRequestBody = [[NSMutableString alloc] init];
		@try
		{
			[Utility WriteLine:[NSString stringWithFormat:@"--%@",m_batchBoundary] inStream:m_batchRequestBody];
			[Utility WriteLine:[NSString stringWithFormat:@"Content-Type: multipart/mixed; boundary=%@",m_changesetBoundry] inStream:m_batchRequestBody];
			[m_batchRequestBody appendString:@"\n"];
			for(NSUInteger index = 0; index < changedEntriesCount; ++index)
			{
				[Utility WriteLine:[NSString stringWithFormat:@"--%@",m_changesetBoundry] inStream:m_batchRequestBody];
				NSMutableString *changesetHeader = [self createChangeSetHeader:index replaceOnUpdateOption:aReplaceOnUpdateOption];
				NSString *changesetBody = [self createChangeSetBody:index replaceOnUpdateOption:aReplaceOnUpdateOption];
				if (changesetBody != nil)
				{
					[Utility WriteLine:[NSString stringWithFormat:@"Content-Length: %d",strlen([changesetBody UTF8String])] inStream:changesetHeader];	
				}
								
				[Utility WriteLine:changesetHeader inStream:m_batchRequestBody];
				[Utility WriteLine:changesetBody inStream:m_batchRequestBody];
			}			
		}
		@catch(NSException *exception)
		{
			
			@throw [[[ODataServiceException alloc]initWithError:[exception reason] contentType:nil headers:nil statusCode:0]autorelease];
		}
		[Utility WriteLine:[NSString stringWithFormat:@"--%@--",m_changesetBoundry] inStream:m_batchRequestBody];
		[Utility WriteLine:[NSString stringWithFormat:@"--%@--",m_batchBoundary] inStream:m_batchRequestBody];
		
		[self performBatchRequest];
		[self endBatchRequest];
	}
}


/*
 * This function will generates the batchrequest from the m_changedEntries
 * list
 */
- (void) batchRequest1:(BOOL) aReplaceOnUpdateOption
{		
	[m_changesetBoundry release];
	m_changesetBoundry = nil;
	[self setChangesetBoundry:[NSString stringWithFormat:@"changeset_%@",[ODataGUID GetNewGuid]]];
	NSUInteger changedEntriesCount = [m_changedEntries count];
	
	if(changedEntriesCount > 0)
	{
		@try
		{
			m_batchRequestBody = [[NSMutableString alloc] init];
			[Utility WriteLine:m_batchBoundary inStream:m_batchRequestBody];
			[Utility WriteLine:[NSString stringWithFormat:@"Content-Type: multipart/mixed; charset=utf-8; boundary=%@",m_changesetBoundry] inStream:m_batchRequestBody];
			
			for(NSUInteger index = 0; index < changedEntriesCount; ++index)
			{
				[Utility WriteLine:[NSString stringWithFormat:@"--%@",m_changesetBoundry] inStream:m_batchRequestBody];
				
				NSMutableString *changesetHeader = (NSMutableString*)[self createChangeSetHeader:index replaceOnUpdateOption:aReplaceOnUpdateOption];
				NSMutableString *changesetBody =(NSMutableString*)[self createChangeSetBody:index replaceOnUpdateOption:aReplaceOnUpdateOption];
				if (changesetBody != nil)
				{
					[changesetHeader appendString:@"\n"];
					[Utility WriteLine:[NSString stringWithFormat:@"Content-Length: %d",[changesetBody length]] inStream:changesetHeader];
				}
				[Utility WriteLine:@"" inStream:changesetHeader];
				
				NSString *tmp = [[NSString alloc] initWithFormat:@"%@%@",m_batchRequestBody,changesetHeader];
				[m_batchRequestBody release];
				m_batchRequestBody = nil;
				[self setBatchRequestBody:[NSString stringWithString:tmp]];
				[tmp release];
				
				if(changesetBody != nil)
				{
					tmp = [[NSString alloc] initWithFormat:@"%@%@",m_batchRequestBody,changesetBody];
					[m_batchRequestBody release];
					m_batchRequestBody = nil;
					[self setBatchRequestBody:[NSString stringWithString:tmp]];
					[tmp release];
				}
			}
		}
		@catch(NSException *exception)
		{
			@throw [[[ODataServiceException alloc]initWithError:[exception reason] contentType:nil headers:nil statusCode:0]autorelease];
		
		}
		
		[Utility WriteLine:[NSString stringWithFormat:@"--%@--",m_changesetBoundry] inStream:m_batchRequestBody];
		[Utility WriteLine:[NSString stringWithFormat:@"--%@--",m_batchBoundary] inStream:m_batchRequestBody];
		
		[self performBatchRequest];
		[self endBatchRequest];
	}
}

-(void)processChangedSet:(NSString *)response
{
	NSRange slashRange2 = [response rangeOfString:@"Content-ID: "];
	if(slashRange2.length == 0)
		return;
	response = [response substringFromIndex:(slashRange2.location + 12)];
	NSRange slashRange3 = [response rangeOfString:@"\n"];
	if(slashRange3.length == 0)
		return;
	NSString *contentId = [response substringWithRange:NSMakeRange(0,slashRange3.location)];
	id obj = nil;
	ResourceBox *aResourceBox = nil;
	for(int i = 0; i<[m_changedEntries count]; i++)
	{
		aResourceBox  = [m_changedEntries objectAtIndex:i];
		if([aResourceBox getChangeOrder] == [contentId intValue])
		{
			if([aResourceBox getState] == Added)
			{
				if([aResourceBox respondsToSelector:@selector(getSaveStream)]==YES)
					obj = [aResourceBox getResource];
			}				
			break;
		}
	}
	
	if(obj != nil)
	{
		NSRange slashRange = [response rangeOfString:@"<?xml"];
		NSRange slashRange1 = [response rangeOfString:@"</ent"];
		NSString *xml=nil;
		if(!(slashRange.location==NSNotFound || slashRange1.location==NSNotFound))
		{
			xml = [response substringWithRange:NSMakeRange(slashRange.location,(slashRange1.location - slashRange.location)+8)];
		}
		ODataXMlParser *parse = [[ODataXMlParser alloc] init];
		AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
		[atom updateEntryObjects:[parse parseData:[xml dataUsingEncoding:NSUTF8StringEncoding]] resourceBox:aResourceBox];
		[atom release];
		[parse release];
	}
}

-(void)parserBatchResponse:(HTTPHandler *)httpHandle
{
		if(httpHandle.http_status_code == 200 || httpHandle.http_status_code == 202)
		{
			NSString *response1 = [[NSString alloc] initWithData:httpHandle.http_response encoding:NSUTF8StringEncoding];
			NSString *response = response1;
			
			while(response)
			{
				NSRange slashRange = [response rangeOfString:@"--changeset"];
				if(slashRange.length == 0)
					return;
				response = [response substringFromIndex:(slashRange.location + 12)];
				NSRange slashRange1 = [response rangeOfString:@"--changeset"];
				if(slashRange1.length == 0)
					return;
				NSString *xmlchunk = [response substringWithRange:NSMakeRange(0,slashRange1.location)];
				[self processChangedSet:xmlchunk];
				response = [response substringFromIndex:(slashRange1.location)];		
			}
			[response1 release];
		}
}


/**
 * This function will fire the batch request and load _httpResponses with response
 * belongs to each changeset in the batch request.
 */
- (void) performBatchRequest
{
	NSString *uri =[m_context getBaseUriWithSlash];
	uri = [uri stringByAppendingString:@"$batch"];
	HttpBatchRequest *request = [[HttpBatchRequest alloc] initWithUri:uri batchBoundary:m_batchBoundary batchRequestBody:m_batchRequestBody credentials:nil batchHeaders:m_context.m_customHeaders credentialsInHeaders:NO context:m_context];
	HttpBatchResponse *response = [request GetResponse];
	[self setHttpResponsesArray:[response getHttpResponses]];
	[self storeBatchResponse];
	[request release];
}
-(void)storeBatchResponse
{
	for(int i=0;i<[m_httpResponsesArray count];i++)
	{
		Microsoft_Http_Response *content = [m_httpResponsesArray objectAtIndex:i];
		NSString *contentId = [self getContentId:content];
		[self LoadProperty:[content getBody] contentID:contentId];
	}
}
-(NSString *)getContentId:(Microsoft_Http_Response *)content
{
	NSString *contentId = nil;
	NSMutableDictionary *headers = [content getHeaders];
	NSArray *keys = [headers allKeys];
	for(int i=0;i<[keys count];i++)
	{
		NSString *headerKey = [keys objectAtIndex:i];
		
		if([headerKey isEqualToString:@"Content-ID"])
		 {
			 contentId =[[content getHeaders] objectForKey:headerKey];
			 break;
		 }
		
	}
	return contentId;
}
-(void) LoadProperty:(NSString *)response contentID:(NSString *)contentId
{
	id obj = nil;
	
	ResourceBox *aResourceBox = nil;
	for(int i = 0; i<[m_changedEntries count]; i++)
	{
		aResourceBox  = [m_changedEntries objectAtIndex:i];
		if([aResourceBox getChangeOrder] == [contentId intValue])
		{
			if([aResourceBox getState] == Added)
			{
				if([aResourceBox respondsToSelector:@selector(getSaveStream)]==YES)
					obj = [aResourceBox getResource];
			}				
			break;
		}
	}
	
	if(obj != nil)
	{
		ODataXMlParser *parse = [[ODataXMlParser alloc] init];
		AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
		[atom updateEntryObjects:[parse parseData:[response dataUsingEncoding:NSUTF8StringEncoding]] resourceBox:aResourceBox];	
		[atom release];
		[parse release];
	}
}

/*
 *  This function will:
 *  a. Checks any error is returned by dataservice (ex: if user try to add
 *          a record with existing key)
 *  b. Populate the entities created by user from the response
 *  c. Updation of entity states and clean up activity.
 */
- (void) endBatchRequest
{
	
	[self checkForDataServiceVersion];
	[self checkForDataServiceError];
	[self loadResourceBoxes];
	
	NSArray *relatedEnds = [[m_context getBindings] values];
	
	NSUInteger count = [relatedEnds count];
	NSUInteger index = 0;
	NSInteger state = 0;
	for( index = 0 ; index < count ; ++index )
	{
		RelatedEnd * relatedEnd = [relatedEnds objectAtIndex:index];
		if(relatedEnd)
		{
			state = [relatedEnd getState];
			if(state == Deleted)
			{
				[[m_context getBindings ]remove:relatedEnd];
			}
			else if( state == Modified || state == Added)
			{
				[ relatedEnd setState:Unchanged];
			}
		}
	}
	
	NSArray *resourceBoxes = [[m_context getObjectToResource] values];
	
	count = [resourceBoxes count];
	index = 0;
	state = 0;
	for( index = 0 ; index < count ; ++index )
	{
		ResourceBox * resourceBox = [resourceBoxes objectAtIndex:index];
		if(resourceBox)
		{
			state = [resourceBox getState];
			
			if(state == Deleted)
			{
				NSString * identity = [resourceBox getIdentity];
				
				if(nil != identity) 
				{
					[[m_context getIdentityToResource]removeObjectForKey:identity];
				}
				[[m_context getObjectToResource] remove:[resourceBox getResource]];
			}
			else if(state == Modified || state == Added)
			{
				[resourceBox setState:Unchanged];
			}
		}
	}
}

/*
 * Check the version of responses.
 */
- (void) checkForDataServiceVersion
{
	NSUInteger count = [m_httpResponsesArray count];
	NSUInteger index = 0;
	
	for( index = 0 ; index < count ; ++index )
	{
		HttpResponse * httpResponse = [m_httpResponsesArray objectAtIndex:index];
		if(httpResponse)
		{
			NSDictionary *headers = [httpResponse getHeaders];
			
			NSString * dataserviceversion = [headers objectForKey:@"Dataserviceversion"];
			if(dataserviceversion)
			{
				NSInteger value  = [dataserviceversion intValue];
				NSInteger value1 = [Resource_MaxDataServiceVersion intValue];
				if(value > value1)
				{
					@throw [[[ODataServiceException alloc]initWithError:[NSString stringWithFormat:@"Invalid operation:%@",Resource_MaxDataServiceVersion] contentType:nil headers:headers statusCode:0]autorelease];

				}
			}
		}
	}
}

/*
 * Checks resposnce from data service contains any error if so
 * throw exception
 */
- (void) checkForDataServiceError
{
	if ( [m_httpResponsesArray count] > 0)
	{
		HttpResponse * httpResponse = [m_httpResponsesArray objectAtIndex:0];
		
		if(httpResponse)
		{
			/*if([httpResponse isError])
			{
				NSDictionary *headers = [httpResponse getHeaders];
				NSString * contentType = [headers objectForKey:@"Content-type"];
				
				if(contentType == nil)
					contentType = @"";
				
				@throw [[[ODataServiceException alloc]initWithError:[httpResponse getHTMLFriendlyBody] contentType:nil headers:[httpResponse getHeaders] statusCode:[httpResponse getCode]]autorelease];
				
			}*/
		}
	}
}

/**
 * Load the resource boxes holding the resources added by user from
 * corrosponding response from server.
 * @return <type> no return value
 */
- (void) loadResourceBoxes
{
	NSUInteger count = [m_changedEntries count];
	NSUInteger index = 0;
	
	for( index = 0 ; index < count ; ++index )
	{
		ResourceBox * resourceBox = [m_changedEntries objectAtIndex:index];
		
		if(resourceBox)
		{
			if( ( [resourceBox isResource] == YES ) && ( [resourceBox getState] == Added) )
			{
				[ self loadResourceBox:resourceBox];
			}
		}
	}
}

/**
 *
 * @param <type> resourceBox
 * @return <type> no return value
 */
- (void) loadResourceBox:(ResourceBox*)aResourceBox
{
	NSInteger contentID = [aResourceBox getChangeOrder];
	NSString *str=nil;
	NSString *contentType=nil;
	
	str = [self getBodyByContentID:contentID contentType:contentType ];		 
	if(str == nil)
	{
		return;
	}
	
	[m_context loadResourceBox:str resouceBox:aResourceBox contentType:contentType];
	[aResourceBox setState:Unchanged];
}

/**
 *
 * @param <type> Content_ID
 * @return <type> json response
 * This function will return body (json format)of httpResponse with
 * Content-id header equal to $Content_ID
 */
- (NSString*) getBodyByContentID:(NSInteger)aContentID contentType:(NSString*) aContentType
{
	NSUInteger count = [m_httpResponsesArray count];
	NSUInteger index = 0;
	
	for( index = 0 ; index < count ; ++index )
	{
		Microsoft_Http_Response * httpResponse = [m_httpResponsesArray objectAtIndex:index];
		if(httpResponse)
		{
			NSDictionary *headers = [httpResponse getHeaders];
			
			if(headers)
			{
				NSString * contentid = [headers objectForKey:@"Content-id"];
				if( contentid != nil && ([contentid intValue] == aContentID) )
				{
					NSString *contenttype = [headers objectForKey:@"Content-type"];
					
					if(contenttype)
					{
						[aContentType release];
						aContentType = [NSString stringWithString:contenttype];
					}
				}
				return [httpResponse getBody];
			}			
		}
	}
	return nil;
}

/**
 *
 * @param <integer> index
 * @return <string> returns body part of one MIME part
 * This fuction will creates changeset body (MIME part body) for
 * a changeset that will become a part batchrequest.
 */
- (NSString*) createChangeSetBody:(NSUInteger)index replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	NSString *changesetBody = nil;
	
	if(m_changedEntries == nil || index >= [m_changedEntries count])
		return changesetBody;
	
	ResourceBox * resourceBox = [m_changedEntries objectAtIndex:index];
	
	if(resourceBox)
	{
		if([resourceBox isResource] == YES)
		{
			changesetBody = [self createChangeSetBodyForResource:resourceBox isNewLineRequired:NO replaceOnUpdateOption:aReplaceOnUpdateOption];
		}
		else
		{
			changesetBody = [self createChangesetBodyForBinding:(RelatedEnd*)resourceBox isNewLineRequired:YES replaceOnUpdateOption:aReplaceOnUpdateOption];
		}
	}
	return changesetBody;
}

/**
 *
 * @param <ResourceBox> resourceBox
 * @param <bool> newline
 * @return <string> Body of changeset for entity in AtomPub format
 */
- (NSString*) createChangeSetBodyForResource:(ResourceBox*)aResourceBox isNewLineRequired:(BOOL)aNewLine replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	NSInteger state = [aResourceBox getState];
	if(Deleted == state)
	{            
		return nil;
	}
	
	if(Added != state && Modified != state)
	{
		NSException *anException = [NSException exceptionWithName:@"InternalError" reason:Resource_UnexpectdEntityState userInfo:nil];
		[anException raise];
	}
	
	
	ODataObject *object = [aResourceBox getResource];
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
	if(state == Added)
	{
		NSString *body = [atom buildXML:object methodtype:"POST"];
		[atom release];
		return body;
	}
	else if(state ==Modified)
	{
		NSString * entityHttpMethod = [self getEntityHttpMethod:state replaceOnUpdateOption:aReplaceOnUpdateOption];
		NSString *body = [atom buildXML:object methodtype:[entityHttpMethod UTF8String]];
		[atom release];
		return body;
	}
	return nil;	
}


/**
 *
 * @param <RelatedEnd> binding
 * @param <bool> newline
 * @return <string> Body of changeset for binding
 */
- (NSString*) createChangesetBodyForBinding:(RelatedEnd*)aRelatedEnd isNewLineRequired:(BOOL) aNewLine replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	NSInteger state = [aRelatedEnd getState];
	if ((Added != state) && (Modified != state))
	{
		return nil;
	}
	
	//In the case of SetLink target can be null to indicate
	//DELETE operation.
	ODataObject *targetObject = [aRelatedEnd getTargetResource];
	if(targetObject == nil)
	{
		return nil;
	}
	
	NSMutableString *changesetBodyForBinding = [[NSMutableString alloc] init];
	NSString *targetObjectUri = nil;        
	ResourceBox *targetResourcebox = [[m_context getObjectToResource] tryGetValue:targetObject];
	if(targetResourcebox != nil)
	{
		if([targetResourcebox getState] == Added || [targetResourcebox getState] == Modified)
			targetObjectUri = [NSString stringWithFormat:@"$%d",[targetResourcebox getChangeOrder]];
		else
			targetObjectUri = [targetResourcebox getEditMediaResourceUri:[m_context getBaseUriWithSlash]];
	}
	
	[Utility WriteLine:@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>" inStream:changesetBodyForBinding];
	NSString * tmp = [[NSString alloc] initWithFormat:@"%@<uri xmlns=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\">%@</uri>\n",changesetBodyForBinding,targetObjectUri];
	[changesetBodyForBinding release];
	changesetBodyForBinding = [[NSMutableString alloc] initWithString:tmp];
	[tmp release];
		
	return [changesetBodyForBinding autorelease];
}

/**
 *
 * @param <integer> index
 * @return <string> returns header part of one MIME part
 * This fuction will creates changeset header (MIME part header) for
 * a changeset that will become a part batchrequest.
 */
- (NSMutableString*) createChangeSetHeader:(NSUInteger)anIndex replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	NSMutableString *changesetHeader = nil;
	if(anIndex >= [m_changedEntries count])
	{
		return nil;
	}
	
	ODataEntity *resourceBox = [m_changedEntries objectAtIndex:anIndex];
	if(resourceBox && [resourceBox isResource] == YES)
	{
		changesetHeader = [self createChangeSetHeaderForResource:(ResourceBox*) resourceBox replaceOnUpdateOption:aReplaceOnUpdateOption];
	}
	else
	{
		changesetHeader = [self createChangesetHeaderForBinding:(RelatedEnd*)resourceBox];
	}
	return changesetHeader;
}


/**
 *
 * @param <ResourceBox> resourceBox
 * @return <string> returns header of changeset for an entity 
 */
- (NSMutableString*) createChangeSetHeaderForResource:(ResourceBox*)aResourceBox replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	NSString *entityHttpMethod = [self getEntityHttpMethod:[aResourceBox getState]  replaceOnUpdateOption:aReplaceOnUpdateOption];
	NSMutableString *changesetHeaderForResource = [[NSMutableString alloc] init];
	NSString *resourceUri = [aResourceBox getResourceUri:[m_context getBaseUriWithSlash]];
	[self writeOperationRequestHeaders:changesetHeaderForResource methodName:entityHttpMethod uri:resourceUri];
	[Utility WriteLine:[NSString stringWithFormat:@"Content-ID: %d",[aResourceBox getChangeOrder]] inStream:changesetHeaderForResource];
	[Utility WriteLine:[NSString stringWithFormat:@"Accept: %@" , [m_context getAccept]] inStream:changesetHeaderForResource];

	if([[aResourceBox getHeaders] count] > 0 )
	{
		NSDictionary *headers = [aResourceBox getHeaders];
		NSEnumerator *enumerator = [headers keyEnumerator];
		NSString* httpHeadrName;
		while(httpHeadrName = [ enumerator nextObject] )
		{
			NSString *httpHeaderValue = [headers objectForKey:httpHeadrName];
			if(httpHeaderValue)
			{
				[Utility WriteLine:[NSString stringWithFormat:@"%@:%@",httpHeadrName , httpHeaderValue] inStream:changesetHeaderForResource];
			}
		}
	}
	
	NSString *eTag = nil;
	
	
	
	if(m_isAzureRequest)
	{
		if([entityHttpMethod isEqualToString:HttpVerb_DELETE])
		{
			NSString *className = [[[aResourceBox getResource] class] description];
			if(!(className != nil && [className isEqualToString:@"Tables"]))
			{
				eTag = [[aResourceBox getResource] getEtag];
				if(eTag == nil)
					eTag = @"*";				
			}			
		}
		else if([entityHttpMethod isEqualToString:HttpVerb_MERGE])
		{
			eTag = [[aResourceBox getResource] getEtag];
			if(eTag == nil)
				eTag = @"*";
		}
		
	}
	else
	{
		eTag = [[aResourceBox getResource] getEtag];
	}

		
	if(eTag)
	{
		[Utility WriteLine:[NSString stringWithFormat:@"%@: %@" ,HttpRequestHeader_IfMatch,eTag] inStream:changesetHeaderForResource];
	}
	
	
								
	if (Deleted != [aResourceBox getState])
	{
			[Utility WriteLine:[NSString stringWithString:@"Content-Type: application/atom+xml;type=entry;charset=utf-8"] inStream:changesetHeaderForResource];
	}
	return [changesetHeaderForResource autorelease];
}

/**
 *
 * @param <RelatedEnd> binding
 * @return <string> returns header of changeset for binding in json format
 */
- (NSMutableString*) createChangesetHeaderForBinding:(RelatedEnd*)aRelatedEnd
{		
	NSMutableString *changesetHeaderForBinding = [[NSMutableString alloc] init];
	ResourceBox *targetResourceBox = [[m_context getObjectToResource] tryGetValue:[aRelatedEnd getTargetResource]];
	NSString *uri = [targetResourceBox getEditLink];
	
	NSString *httpmethod = nil;
	ResourceBox *sourceResourceBox = [[m_context getObjectToResource] tryGetValue:[aRelatedEnd getSourceResource]];
	NSString *absoluteUri = nil;
	
	if([aRelatedEnd getState] == Modified)
	{
		uri = [Utility getEntityNameFromUrl:uri];
		uri = [m_context getEntityTypeNameFromSet:uri];
	}
	else if([aRelatedEnd getState] == Added)
	{
		uri = [Utility getEntityNameFromUrl:uri];
	}
	
	if(uri == nil)
	{
		uri = [m_context getEntityTypeNameFromSet:[aRelatedEnd getSourceProperty]];
		httpmethod = @"DELETE";
	}
	
	if (Added == [sourceResourceBox getState] || Modified == [sourceResourceBox getState])
	{
		absoluteUri = [NSString stringWithFormat:@"$%d/$links/%@",[sourceResourceBox getChangeOrder],uri];
	}
	else
	{
		absoluteUri = [NSString stringWithFormat:@"%@/$links/%@",[sourceResourceBox getResourceUri:[m_context getBaseUriWithSlash]],uri];
	}

	if(httpmethod)
		[self writeOperationRequestHeaders:changesetHeaderForBinding methodName:httpmethod uri:absoluteUri];
	else
		[self writeOperationRequestHeaders:changesetHeaderForBinding methodName:[self getBindingHttpMethod:aRelatedEnd] uri:absoluteUri];
	[Utility WriteLine:@"DataServiceVersion: 1.0;Objective-C" inStream:changesetHeaderForBinding];
	[Utility WriteLine:[NSString stringWithFormat:@"Accept: %@" , [m_context getAccept]] inStream:changesetHeaderForBinding];
	[Utility WriteLine:[NSString stringWithFormat:@"Content-ID: %d" ,[aRelatedEnd getChangeOrder]] inStream:changesetHeaderForBinding];
	
	if ( (nil != [aRelatedEnd getTargetResource]) && ( (Added == [aRelatedEnd getState]) || (Modified == [aRelatedEnd getState])))
	{
		[Utility WriteLine:@"Content-Type: application/xml" inStream:changesetHeaderForBinding];
	}
	return [changesetHeaderForBinding autorelease];
}

/**
 *
 * @param <RelatedEnd> binding
 * @return <Uri>
 * Create relatieve uri for binding operation based on state of binding 
 */
- (NSString*) createRequestRelativeUri:(RelatedEnd*)binding
{
	return nil;
}

/**
 *
 * @param <URi> baseUriWithSlash
 * @param <ResourceBox> resource
 * @param <boolean> isRelative
 * @return <Uri>
 * Returns the EditLink uri for the entity hold by the ResourceBox resource.
 */
- (NSString*) generateEditLinkUri:(NSString*)aBaseUriWithSlash resource:(ODataObject*)anODataObject isRelative:(BOOL)isRelative
{
	NSString *editLinkUri = nil;
	if(isRelative)
	{
		editLinkUri = [NSString stringWithFormat:@"%@%@",aBaseUriWithSlash,[Utility getUri:anODataObject]];
	}
	else
	{
		editLinkUri = [NSString stringWithString:[Utility getUri:anODataObject]];
	}
	
	return editLinkUri;
}

/**
 *
 * @param <string> [out] outVal
 * @param <HttpVerb> methodName
 * @param <Uri> uri
 */
- (void) writeOperationRequestHeaders:(NSMutableString*)aStream  methodName:(NSString*)aMethodName uri:(NSString*)anUri
{
	[Utility WriteLine:@"Content-Type: application/http" inStream:aStream];
	[Utility WriteLine:@"Content-Transfer-Encoding: binary" inStream:aStream];
	[Utility WriteLine:@"" inStream:aStream];
	[Utility WriteLine:[NSString stringWithFormat:@"%@ %@ HTTP/1.1",aMethodName , anUri] inStream:aStream];
}


/**
 *
 * @param <EntityStates> state
 * @return <string> Returns HTTP method to be used for an entity
 * based on the state of the ResourceBox holding the entity
 */
- (NSString*) getEntityHttpMethod:(NSInteger)aState replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	if(aState == Added)
	{
		return @"POST";
	}
	
	if(aState == Deleted)
	{
		return @"DELETE";
	}
	
	if(aState == Modified)
	{
		if(aReplaceOnUpdateOption)
		{
			return @"PUT";
		}
		
		return @"MERGE";
	}

	NSException *anException = [NSException exceptionWithName:@"Exception" reason:@"Invalid entity state while generating HTTP method" userInfo:nil];
	[anException raise];
	
	return nil;
}

/**
 *
 * @param <RelatedEnd> binding
 * @return <string> Returns HTTP method to be used for a binding
 * based on the state of the RelatedEnd holding the binding
 */
- (NSString*) getBindingHttpMethod:(RelatedEnd*)binding
{
	if (Deleted == [binding getState])
	{
		return @"DELETE";
	}
	else if (Modified == [binding getState])
	{
		return @"PUT";
	}
	else if (Added == [binding getState])
	{
		return @"POST";
	}
	  
	return @"POST";
}

/**
 * Create HTTP request body for an Object 
 *
 * @param ResourceBox containing the object
 * @param BOOL for specifying update or replace operation
 * @return NSString
 */
-(NSString *) createRequestBody:(ResourceBox *)aResourceBox replacementOption:(BOOL)aReplaceOnUpdateOption
{
	NSInteger state = [aResourceBox getState];
	if(Deleted == state)
	{            
		return nil;
	}
	
	if(Added != state && Modified != state)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:Resource_UnexpectdEntityState userInfo:nil];
		[anException raise];
	}
	
	ODataObject *object = [aResourceBox getResource];
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
	NSString *str = nil;
	if(state == Added)
	{
		str = [atom buildXML:object methodtype:"POST"];
	}
	else if(state ==Modified)
	{
		NSString * entityHttpMethod = [self getEntityHttpMethod:state replaceOnUpdateOption:aReplaceOnUpdateOption];
		str = [atom buildXML:object methodtype:[entityHttpMethod UTF8String]];
	}
	
	[atom release];
	return str;
}

/**
 * Generates HTTP request headers and body for Object state functionality 
 *
 * @param ResourceBox containing the object
 * @param BOOL for specifying update or replace operation
 * @return NULL
 */
-(void)processObject:(ResourceBox *)aResourceBox replacementOption:(BOOL)aReplaceOnUpdateOption
{
	NSString *stream = nil;
	NSString *eTag = nil;
	
	NSString *httpMethod = [self getEntityHttpMethod:[aResourceBox getState] replaceOnUpdateOption:aReplaceOnUpdateOption];
	if(![httpMethod isEqualToString:@"DELETE"])
		stream = [self createRequestBody:aResourceBox replacementOption:aReplaceOnUpdateOption];
	
	if([[aResourceBox getResource] respondsToSelector:@selector(setEtag:)])
	{
		eTag = [[aResourceBox getResource] getEtag];
	}
	else if([[[m_context getCredentials] getCredentialType] isEqualToString:@"AZURE"])
	{
		if([httpMethod isEqualToString:@"MERGE"] )
			eTag = @"*";
		if([httpMethod isEqualToString:@"DELETE"])
		{
			NSString *className = [[[aResourceBox getResource] class] description];
			if(!(className != nil && [className isEqualToString:@"Tables"]))
			{
				eTag = @"*";
			}
		}
	}
		
	NSString *resourceUri = [aResourceBox getResourceUri:[m_context getBaseUriWithSlash]];
		
	//Add or Update or Delete object
	HTTPHandler *handle = [m_context executeHTTPRequest:resourceUri httpmethod:httpMethod httpbody:stream etag:eTag];
	
	if([[aResourceBox getResource] respondsToSelector:@selector(setEtag:)])
	{
		NSString *eTag = [[handle http_response_headers] valueForKey:@"Etag"];
		if(eTag)
			[[aResourceBox getResource] setEtag:eTag];
	}
	
	NSString *response = [[NSString alloc] initWithData:[handle http_response] encoding:NSUTF8StringEncoding];
	ODataXMlParser *parse = [[ODataXMlParser alloc] init];
	
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
	if([handle http_error])
	{
		QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[handle http_response_headers] innerException:[handle.http_error localizedDescription] statusCode:[handle http_status_code] query:resourceUri];
		ODataServiceException *e= [[ODataServiceException alloc]initWithError:[[handle http_error]localizedDescription] contentType:nil headers:[handle http_response_headers] statusCode:[handle http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		[queryOperationResponse release];
		@throw e;
	}
	
	[atom updateEntryObjects:[parse parseData:[response dataUsingEncoding:NSUTF8StringEncoding]] resourceBox:aResourceBox];
	[atom release];
	[parse release];
	[response release];
}

/**
 * Generates HTTP request headers and body for Media Link functionality 
 *
 * @param ResourceBox containing the object
 * @param BOOL for specifying update or replace operation
 * @return NULL
 */
-(void)processMediaLink:(ResourceBox *)aResourceBox replacementOption:(BOOL)aReplaceOnUpdateOption
{
	NSString *httpMethod = [self getEntityHttpMethod:[aResourceBox getState] replaceOnUpdateOption:aReplaceOnUpdateOption];
	DataServiceSaveStream *datahandle = [aResourceBox getSaveStream];
	NSString *editMediaResourceUri = [aResourceBox getEditMediaResourceUri:[m_context getBaseUriWithSlash]];
	
	if([httpMethod isEqualToString:@"DELETE"])
	{
		return;
	}
	if([httpMethod isEqualToString:@"POST"])
	{
		httpMethod = @"ADD";
	}
	else if([httpMethod isEqualToString:@"PUT"] || [httpMethod isEqualToString:@"MERGE"])
	{
		httpMethod = @"UPDATE";
	}
	
	HTTPHandler *httpresponse = [m_context executeHTTPRequest:editMediaResourceUri httpmethod:httpMethod httpbodydata:[[datahandle getStream]getStream] etag:[[datahandle getArgs] getSlug]];
	
	if([[aResourceBox getResource] respondsToSelector:@selector(setEtag:)])
	{
		NSString *eTag = [[httpresponse http_response_headers] valueForKey:@"Etag"];
		if(eTag)
			[[aResourceBox getResource] setEtag:eTag];
	}
	
	NSString *response = [[NSString alloc] initWithData:[httpresponse http_response] encoding:NSUTF8StringEncoding];
	ODataXMlParser *parse = [[ODataXMlParser alloc] init];
	
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_context];
	
	if([httpresponse http_error])
	{
		QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpresponse http_response_headers] innerException:[httpresponse.http_error localizedDescription] statusCode:[httpresponse http_status_code] query:editMediaResourceUri];
		ODataServiceException *e= [[ODataServiceException alloc]initWithError:[[httpresponse http_error]localizedDescription] contentType:nil headers:[httpresponse http_response_headers] statusCode:[httpresponse http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		[queryOperationResponse release];
		@throw e;
	}
	
	[atom CheckAndProcessMediaLinkEntryData:[parse parseData:[response dataUsingEncoding:NSUTF8StringEncoding]] resourceBox:aResourceBox];
	[atom release];
}


/**
 * Generates HTTP request headers and body for Object Link functionality 
 *
 * @param RelatedEnd containing the source and target object
 * @return NULL
 */
-(void)processObjectLinks:(RelatedEnd *)aRelatedEnd
{
	NSString *httpMethod = nil;
	NSString *resourceUri = nil;
	NSString *body = nil;
	NSInteger state = [aRelatedEnd getState];
	ResourceBox *aResourceBoxTarget = (ResourceBox*)[[m_context getObjectToResource] tryGetValue:[aRelatedEnd getTargetResource]];
	ResourceBox *aResourceBoxSource = (ResourceBox*)[[m_context getObjectToResource] tryGetValue:[aRelatedEnd getSourceResource]];
	
	if(aResourceBoxTarget != nil)                                                                                                                                                                         
	{                                                                                                                                                                                                     
	     NSString *uri = [aResourceBoxTarget getEditLink];                                                                                                                                             
	     if([aRelatedEnd getState] == Modified)                                                                                                                                                        
		 {                                                                                                                                                                                             
	           uri = [Utility getEntityNameFromUrl:uri];                                                                                                                                             
		       uri = [m_context getEntityTypeNameFromSet:uri];                                                                                                                                       
		 }                               
		
		if([aRelatedEnd getState] == Deleted)
			resourceUri = [NSString stringWithFormat:@"%@/$links/%@", [aResourceBoxSource getResourceUri:[m_context getBaseUriWithSlash]],uri];
		else if([aRelatedEnd getState] == Modified || [aRelatedEnd getState] == Added)
			resourceUri = [NSString stringWithFormat:@"%@/$links/%@", [aResourceBoxSource getResourceUri:[m_context getBaseUriWithSlash]],[Utility getEntityNameFromUrl:uri]];
		if(state!= Deleted)
			body = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>\n<uri xmlns=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\">%@</uri>",[aResourceBoxTarget getResourceUri:[m_context getBaseUriWithSlash]]];

	}  
	else
	{
		aResourceBoxTarget = [[ResourceBox alloc] initWithIdentity:@"" editLink:[m_context getEntityTypeNameFromSet:[aRelatedEnd getSourceProperty]] resource:nil];
		resourceUri = [aResourceBoxSource getResourceUri:[m_context getBaseUriWithSlash] tragetResourceBox:aResourceBoxTarget];
		state = Deleted;
		
	}
	
	if(state == Deleted)
	{
		httpMethod = @"DELETE";
	}
	else if(state == Modified)
	{		
		httpMethod = @"SETLINK";
	}
	else if(state == Added)
	{
		httpMethod = @"ADDLINK";
	}
	
	HTTPHandler *httpresponse =[m_context executeHTTPRequest:resourceUri httpmethod:httpMethod httpbody:body etag:nil];
	if([httpresponse http_error])
	{
		QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:[httpresponse http_response_headers] innerException:[httpresponse.http_error localizedDescription] statusCode:[httpresponse http_status_code] query:resourceUri];
		ODataServiceException *e= [[ODataServiceException alloc]initWithError:[[httpresponse http_error] localizedDescription] contentType:nil headers:[httpresponse http_response_headers] statusCode:[httpresponse http_status_code]];
		[e setDetailedError:[queryOperationResponse getError]];
		[queryOperationResponse release];
		@throw e;
 	}
}

//New non Batch request
- (DataServiceResponse*)  nonBatchRequest:(BOOL)aReplaceOnUpdateOption
{
	
	@try
	{		
		for(int i = 0; i<[m_changedEntries count];i++)
		{
			ResourceBox *aResourceBox = [m_changedEntries objectAtIndex:i];
			if(aResourceBox != nil )
			{
								
				if([aResourceBox respondsToSelector:@selector(getSaveStream)]==NO)
				{
					RelatedEnd *relatedLink = (RelatedEnd *)aResourceBox;
					[self processObjectLinks:relatedLink];
				}
				
				else if([aResourceBox getSaveStream] != nil)
				{
					//Media Link processing
					[self processMediaLink:aResourceBox replacementOption:aReplaceOnUpdateOption];	
					[aResourceBox setSaveStream:nil];
				}
				
				else
				{
					// Add delete update Object processing
					[self processObject:aResourceBox replacementOption:aReplaceOnUpdateOption];
				}				
			}
		}
		
	}
	@catch(ODataServiceException *exception)
	{
		@throw exception;
	}
	@catch(NSException *exception)
	{
		[self endNonBatchRequest];
		@throw exception;
	}
	
	[self endNonBatchRequest];
	return nil;
}


/**
 *
 * @return <HttpRequest>
 * This function returns an HttpRequest object with required headers set
 * for currenlty selected (identified by this->_entryIndex)
 * entry (Resource or Binding). The headers will be set based on the type
 * of operation to be performed on the selected entry (POST, PUT, MERGE and
 * DELETE).
 * Based on the scenario [type of entry (Resource or Binding) and status of
 * associated stream (if exists, for Resource only)], this function will
 * call appropriate functions to handle specfic senario header generation.
 */
- (ResourceBox*) createRequestHeaderForSingleChange:(BOOL) aReplaceOnUpdateOption
{
	if([m_changedEntries count] > self.m_entryIndex)
	{
		ResourceBox *resourceBox =[m_changedEntries objectAtIndex:self.m_entryIndex];
		return resourceBox;
	}
	else
		return nil;
}

/**
 * 
 * @return <ContentStream>
 * This function returns an ContentStream object which holds a stream that
 * will become the body of the HttpRequest for currenlty selected
 * entry (Resource or Binding).
 * Based on the scenario [type of entry (Resource or Binding) and status of
 * associated stream (if exists, for Resource only)], this function prepare
 * and returns approperiate stream.
 */
- (ContentStream*) createRequestBodyForSingleChange:(NSUInteger)anIndex replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	ODataEntity * descriptor = [m_changedEntries objectAtIndex:anIndex];
	
	if([descriptor isResource])
	{
		if (m_processingMediaLinkEntry)
		{
			return [[[ContentStream alloc] initWithStream:[m_mediaResourceRequestStream getStream] isKnownMemoryStream:NO] autorelease];
		}
	}
	
	if ((Added != [descriptor getState]) && ( (Modified != [descriptor getState]) || ([(RelatedEnd*)descriptor getTargetResource] == nil)))
	{
		return nil;
	}
	return nil;
}

/**
 *
 * @param <ResourceBox> resourceBox
 * @return <HttpRequest>
 * Returns HttpRequest object with required headers set for the resourceBox
 */
- (HttpRequest*) createRequestHeaderForResource:(ResourceBox*)aResourceBox replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	NSString *entityHttpMethod = [self getEntityHttpMethod:[aResourceBox getState] replaceOnUpdateOption:aReplaceOnUpdateOption];
	
	//In the case of PUT, MERGE  or DELETE operations If-Match (ETag)
	//header is required
	BOOL ifMatch = NO;
	if(!([entityHttpMethod isEqualToString:HttpVerb_POST]))
	{
		ifMatch = YES;
		if((self.m_isAzureRequest) && ([entityHttpMethod  isEqualToString:HttpVerb_DELETE]))
		{
			NSString *className = [[[aResourceBox getResource] class] description];
			if(className != nil && [className isEqualToString:@"Tables"])
			{
				ifMatch = NO;
			}
		}
	}
	
	if(self.m_isAzureRequest)
	{		
		if(ifMatch)
		{
			NSString *tmpObj = [aResourceBox getEntityTag];
			if(tmpObj == nil || [tmpObj isEqualToString:@""])
			{
				tmpObj = [NSString stringWithString:@"*"];
			}
		}
		
	}
	
	NSString *resourceUri = [aResourceBox getResourceUri:[m_context getBaseUriWithSlash]];

	BOOL usePostTuneling = [m_context getUsePostTunneling];

	HttpRequest *request = [m_context createRequest:resourceUri httpVerb:entityHttpMethod allowAnyType:NO contentType:@"application/atom+xml" dataServiceVersion:Resource_DataServiceVersion_1];
	ODataObject * obj = [aResourceBox getResource];
	NSString * etag = nil;
	
	if(obj)
	{
		if ([obj respondsToSelector:@selector(getEtag)])
		{
			etag = [obj getEtag];
		}
	}
	
	
	[m_context setUsePostTunneling:usePostTuneling];
	return request;
}


/**
 *
 * @param <RelatedEnd> binding
 * @return <HttpRequest>
 * Returns HttpRequest object with required headers set for the binding
 */
- (HttpRequest*) createRequestHeaderForBinding:(RelatedEnd*)aRelatedEnd
{
	ResourceBox *sourceResourceBox = [[m_context getObjectToResource] tryGetValue:[aRelatedEnd getSourceResource]];
	
	ODataObject *targetResource = [aRelatedEnd getTargetResource];
	ResourceBox *targetResourceBox = nil;
	if( targetResource!= nil)
	{
		targetResourceBox = [[m_context getObjectToResource] tryGetValue:[aRelatedEnd getTargetResource]];
	}
	
	if([sourceResourceBox getIdentity] == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:Resource_LinkResourceInsertFailure userInfo:nil];
		[anException raise];
	}
	
	if((targetResourceBox != nil) && ([targetResourceBox getIdentity] == nil))
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:Resource_LinkResourceInsertFailure userInfo:nil];
		[anException raise];
	}
	
	return [m_context createRequest :[self createRequestUri:sourceResourceBox binding:aRelatedEnd] httpVerb:[self getBindingHttpMethod:aRelatedEnd] allowAnyType:NO contentType:@"application/xml" dataServiceVersion:Resource_DataServiceVersion_1];
}

/**
 *
 * @param <ResourceBox> resourceBox
 * @return <string> Body of changeset for resource entry in AtomPub format
 */
- (NSString*) createRequestBodyForResource:(ResourceBox*)aResourceBox replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	return [self createChangeSetBodyForResource:aResourceBox isNewLineRequired:NO replaceOnUpdateOption:aReplaceOnUpdateOption];
}

/**
 *
 * @param <RelatedEnd> $binding
 * @return <string> Body of changeset for binding entry in AtomPub format
 */
- (NSString*) createRequestBodyForBinding:(RelatedEnd*)aRelatedEnd replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption
{
	return [self createChangesetBodyForBinding:aRelatedEnd isNewLineRequired:YES replaceOnUpdateOption:aReplaceOnUpdateOption];
}

/**
 *
 * @param <ResourceBox> resourceBox
 * @Return <HttpRequest>
 * This function will check whether the resource represented  by the
 * $resourceBox has any BLOB associated with it, which is to be saved
 * using HTTP PUT. HTTP PUT will be used to save a BLOB when the
 * assoicated MLE (resource) is already exists in the data service, which
 * means state of the resource will be unchanged or modified.
 *
 */
- (HttpRequest*) checkAndProcessMediaEntryPut:(ResourceBox*)aResourceBox
{
	if([aResourceBox getSaveStream] == nil)
	{
		return nil;
	}
	
	NSString *editMediaResourceUri = [aResourceBox getEditMediaResourceUri:[m_context getBaseUriWithSlash]];
	
	if(editMediaResourceUri == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:Resource_SetSaveStreamWithoutEditMediaLink userInfo:nil];
		[anException raise];
	}
	
	[m_context setUsePostTunneling:NO];
	HttpRequest *mediaResourceRequest = [self createMediaResourceRequest:editMediaResourceUri method:@"PUT"];
		[m_context setUsePostTunneling:NO];
	[self setupMediaResourceRequest:mediaResourceRequest resource:aResourceBox];
	return mediaResourceRequest;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *
 * @param <ResourceBox> resourceBox
 * @Return <HttpRequest>
 * This function will check whether the resource represented  by the
 * resourceBox has any BLOB associated with it, which is to be saved
 * using HTTP POST. HTTP POST will be used to save a BLOB when the
 * assoicated MLE (resource) is not exists in the data service and which is
 * just added in the m_context by the client application, which
 * means state of the MLE (resource) will be added
 */
- (HttpRequest*) checkAndProcessMediaEntryPost:(ResourceBox *)aResourceBox
{  
	if (![aResourceBox getMediaLinkEntry])
	{           
		return nil;
	}
	
	if([aResourceBox getSaveStream] == nil)
	{
		NSException *anException = [NSException exceptionWithName:@"Exception" reason:Resource_MLEWithoutSaveStream userInfo:nil];
		[anException raise];
	}
	
	HttpRequest *mediaResourceRequest = [self createMediaResourceRequest:[aResourceBox getResourceUri:[m_context getBaseUriWithSlash]] method:@"POST"];
	[self setupMediaResourceRequest:mediaResourceRequest resource:aResourceBox];
	[aResourceBox setState:Modified];
	return mediaResourceRequest;
}

/**
 * @param <Uri> requestUri
 * @param <HttpVerb> method
 * @Return <HttpRequest>
 * This function will returns HttpRequest with required headers set for
 * a media resource (BLOB) request (POST or PUT)
 */
- (HttpRequest*) createMediaResourceRequest:(NSString*) aRequestUri method:(NSString*)aMethod
{
	HttpRequest * mediaResourceRequest = [m_context createRequest:aRequestUri httpVerb:aMethod allowAnyType:NO contentType:@"*/*" dataServiceVersion:Resource_DataServiceVersion_1];
	NSArray * tmpKeyArray = [[NSMutableArray alloc]initWithObjects:@"Content-Type",nil];
	NSArray * tmpObjArray = [[NSMutableArray alloc]initWithObjects:@"*/*",nil];
	
	NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] initWithObjects:tmpObjArray forKeys:tmpKeyArray];
	
	[tmpDict release];
	[tmpKeyArray release];
	[tmpObjArray release];
	return mediaResourceRequest;
}

/**
 *
 * @param <HttpRequest> mediaResourceRequest
 * @param <ResourceBox> resourcBox
 * Set the _mediaResourceRequestStream member variable with the stream
 * specified by user through SetSaveStream
 * Also set header of HttpRequest (for media resource POST or PUT) with
 * one passed by user through SetSaveStream
 */
- (void) setupMediaResourceRequest:(HttpRequest*)aMediaResourceRequest resource:(ResourceBox*) aResourcBox
{
	[self setMediaResourceRequestStream:[[aResourcBox getSaveStream] getStream]];
}

/**
 *
 * @param <ResourceBox> sourceResourceBox
 * @param <Binding> binding
 * @return <Uri>
 * Returns Uri to be used for a binding operation (AddLink, SetLink or DeleteLink)
 * For example if both Customer (with id 'ALKFI')and Order (1234)exists in
 * data service and in m_context, then Uri will be:
 * http://dataservice/Customers('ABCDE')/$links/Orders(1234)
 * if only Customer exists in the data service and m_context and Order is just
 * added in the m_context then Uri will be:
 * http://dataservice/Customers('ABCDE')/$links/Orders
 */
- (NSString*) createRequestUri:(ResourceBox*)aSourceResourceBox binding:(RelatedEnd*)aRelatedEnd
{
	return [Utility CreateUri:[aSourceResourceBox getResourceUri:[m_context getBaseUriWithSlash]] requestUri:[self createRequestRelativeUri:aRelatedEnd]];
}

/**
 *
 * @param <integer> httpCode HTTP Status code
 * This function will update the m_changeOrderIDToHttpStatus array,
 * which hold the status of each change request in non-batch mode.
 * This array will be used to update the state of all resources in the
 * m_context once all changes are done.
 * Note that we are skipping the case of BLOB PUT, this because BLOB put
 * will happen in two cases:
 * 1. MLE (resource) associated with the BLOB is in unchanged state
 *      (In this case resource dont have change order id)
 * 2. MLE (resource) associated with the BLOB is in modified state
 *      (In this case there will be another request generated for the
 *       MLE so skip the case of BLOB)
 */
- (void) updateChangeOrderIDToHttpStatus:(NSInteger)aHttpCode
{
	if(!(m_processingMediaLinkEntry && m_processingMediaLinkEntryPut))
	{
		ResourceBox *resourceBox = [m_changedEntries objectAtIndex:m_entryIndex];
		NSNumber * number = [[NSNumber alloc] initWithInt:[resourceBox getChangeOrder]];
		if([m_changeOrderIDToHttpStatus objectForKey:number] != nil)
		{
			[m_changeOrderIDToHttpStatus removeObjectForKey:number];
		}
		NSNumber *httpcode = [[NSNumber alloc] initWithInt:aHttpCode];
		[m_changeOrderIDToHttpStatus setObject:httpcode forKey:number];
		[number release];
		[httpcode release];
	}
}

/**
 *
 * Update the State of all entity instances (ResourceBox and Bindings).
 */
- (void) endNonBatchRequest
{
	[self updateEntriesState:[[m_context getObjectToResource] values]];
	[self updateEntriesState:[[m_context getBindings]values]];
}

/**
 *
 * Update the State of all entity instances (ResourceBox and Bindings) based
 * on the Http response status from data service for each entity, which
 * we have already stored in _changeOrderIDToHttpStatus array
 */
- (void) updateEntriesState:(NSArray*)entries
{
	NSUInteger count = [entries count];
	NSInteger index = 0;
	NSInteger state = 0;
	for(index = 0 ; index < count ; ++index)
	{
		ODataEntity *entry = [entries objectAtIndex:index];
		if(entry)
		{
			state = [entry getState];
			if(state != Unchanged)
			{
				if(state == Deleted)
				{
					if([entry isResource])
					{
						NSString *identity = [(ResourceBox*)entry getIdentity];
						if(nil != identity)
						{
							[[m_context getIdentityToResource]removeObjectForKey:identity];
						}
						[[m_context getObjectToResource] remove:[(ResourceBox*)entry getResource]];
					}
					else
					{
						[[m_context getBindings]remove:entry];
					}
				}
				if(state == Modified || state == Added)
				{
					[entry setState:Unchanged];
				}					
			}
		}
	}
}

@end
