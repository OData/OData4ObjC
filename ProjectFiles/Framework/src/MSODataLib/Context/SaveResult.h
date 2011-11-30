
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
#import "DataServiceResponse.h"
#import "ContentStream.h"
#import "HttpRequest.h"
#import "ResourceBox.h"
#import "RelatedEnd.h"
#import "OperationResponse.h"
#import "DataServiceSaveStream.h"
#import "Microsoft_Http_Response.h"

@interface SaveResult : NSObject
{
    /**
     * Reference to contextobject instance
     * Type: ObjectContext
     */
    ObjectContext *m_context;

    /**
     * The list holding the merged result of values in ObjectToContext and
     * Bindings dictionaries of context object, only the entries with State
     * Unchanged will be loaded. For each entries in this list one changeset
     * (a MIME part of batchRequest) will be genereated.
     * type: array of Entry (see Entry class)
     */
    NSMutableArray *m_changedEntries;

    /**
     * The string holding batch boundary for the batch request
     * format will be batch_{guid}
     * type: string
     */
	NSMutableString *m_batchBoundary;

    /**
     * The string holding changeset boundary for the batch request
     * format will be changeset_{guid}
     * type: string
     */
    NSMutableString *m_changesetBoundry;

    /**
     * The string holding the body part of batch request. This variable
     * type: string
     */
    NSMutableString *m_batchRequestBody;
    
    /**
     * The list holding the collection of http response for each chnageset
     * in the batch request.
     * type: array of HttpResponse (see HttpResonse Class)
     */
    NSMutableArray *m_httpResponsesArray;
    
    /**
     *
     * @var <bool>
     * Used during Non-Batch mode updation.
     */
    BOOL m_completed;

    /**
     *
     * @var <index>
     * Used to identify the entry in the _changedEntries array which
     * is currenty processing suring Non-Batch mode.
     */
    NSUInteger m_entryIndex;

    /**
     *
     * @var <bool>
     * true if system is processing a stream set using SetSaveStream, with
     * PUT or POST operation.
     */
    BOOL m_processingMediaLinkEntry;

    /**
     *
     * @var <bool>
     * true if system is processing a stream set using SetSaveStream, with
     * PUT operation.
     */
    BOOL m_processingMediaLinkEntryPut;
	

    /**
     *
     * @var <string>
     * The stream set by SetSaveStream
     */
    ContentStream *m_mediaResourceRequestStream;

    /**
     *
     * @var <OperationResponse[]>
     */
    NSMutableArray *m_operationResponses;
	

    /**
     *
     * @var <array<int, HttpStatus>>
     */
	NSMutableDictionary *m_changeOrderIDToHttpStatus;

    /**
     *
     * @var <bool> Flag indicate the source, Data service hosted on Windows
     * or on Azure Table Storage
     */
    BOOL m_isAzureRequest;
    
}

@property ( nonatomic , assign , getter=getContext ,						setter=setContext						) ObjectContext *m_context;
@property ( nonatomic , retain , getter=getHttpResponsesArray ,				setter=setHttpResponsesArray			) NSMutableArray *m_httpResponsesArray;
@property ( nonatomic , retain , getter=getBatchBoundary ,					setter=setBatchBoundary					) NSMutableString *m_batchBoundary;
@property ( nonatomic , retain , getter=getChangesetBoundry	,				setter=setChangesetBoundry				) NSMutableString *m_changesetBoundry;
@property ( nonatomic , retain , getter=getBatchRequestBody	,				setter=setBatchRequestBody				) NSMutableString *m_batchRequestBody;
@property ( nonatomic , assign , getter=getCompleted ,						setter=setCompleted						) BOOL m_completed;
@property ( nonatomic , assign , getter=getEntryIndex ,						setter=setEntryIndex					) NSUInteger m_entryIndex;
@property ( nonatomic , assign , getter=getProcessingMediaLinkEntry ,		setter=setProcessingMediaLinkEntry		)  BOOL m_processingMediaLinkEntry;
@property ( nonatomic , assign , getter=getProcessingMediaLinkEntryPut ,	setter=setProcessingMediaLinkEntryPut	)  BOOL m_processingMediaLinkEntryPut;
@property ( nonatomic , retain , getter=getMediaResourceRequestStream ,		setter=setMediaResourceRequestStream	) ContentStream *m_mediaResourceRequestStream;
@property ( nonatomic , assign , getter=isAzureRequest	,					setter=setAzureRequest					) BOOL m_isAzureRequest;

- (id) initWithObjectContext:(ObjectContext*)anObjectContext saveChangesOptions:(NSInteger)aSaveChangesOptions;

- (void) batchRequest:(BOOL) aReplaceOnUpdateOption;
-(void)storeBatchResponse;
- (void) performBatchRequest;
- (void) endBatchRequest;
- (void) checkForDataServiceVersion;
- (void) checkForDataServiceError;
- (void) loadResourceBoxes;
- (void) loadResourceBox:(ResourceBox*)aResourceBox;
- (NSString*) getBodyByContentID:(NSInteger)aContentID contentType:(NSString*) aContentType;
- (NSString*) createChangeSetBody:(NSUInteger)index replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (NSString*) createChangeSetBodyForResource:(ResourceBox*)aResourceBox isNewLineRequired:(BOOL)aNewLine replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;

- (NSString*) createChangesetBodyForBinding:(RelatedEnd*)aRelatedEnd isNewLineRequired:(BOOL) aNewLine replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (NSMutableString*) createChangeSetHeader:(NSUInteger)anIndex replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (NSMutableString*) createChangeSetHeaderForResource:(ResourceBox*)aResourceBox replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (NSMutableString*) createChangesetHeaderForBinding:(RelatedEnd*)aRelatedEnd;
- (NSString*) createRequestRelativeUri:(RelatedEnd*)binding;
- (NSString*) generateEditLinkUri:(NSString*)aBaseUriWithSlash resource:(ODataObject*)anODataObject isRelative:(BOOL)isRelative;
- (void) writeOperationRequestHeaders:(NSMutableString*)aStream  methodName:(NSString*)aMethodName uri:(NSString*)anUri;
- (NSString*) getEntityHttpMethod:(NSInteger)aState replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (NSString*) getBindingHttpMethod:(RelatedEnd*)binding;
- (DataServiceResponse*)  nonBatchRequest:(BOOL)aReplaceOnUpdateOption;
- (ResourceBox*) createRequestHeaderForSingleChange:(BOOL) aReplaceOnUpdateOption;
-(NSString *)getContentId:(Microsoft_Http_Response *)content;
-(void) LoadProperty:(NSString *)response contentID:(NSString *)contentId;
- (ContentStream*) createRequestBodyForSingleChange:(NSUInteger)anIndex replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;

- (HttpRequest*) createRequestHeaderForResource:(ResourceBox*)aResourceBox replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (HttpRequest*) createRequestHeaderForBinding:(RelatedEnd*)aRelatedEnd;
- (NSString*) createRequestBodyForResource:(ResourceBox*)aResourceBox replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;

- (NSString*) createRequestBodyForBinding:(RelatedEnd*)aRelatedEnd replaceOnUpdateOption:(BOOL)aReplaceOnUpdateOption;
- (HttpRequest*) checkAndProcessMediaEntryPut:(ResourceBox*)aResourceBox;
- (HttpRequest*) checkAndProcessMediaEntryPost:(ResourceBox *)aResourceBox;
- (HttpRequest*) createMediaResourceRequest:(NSString*) aRequestUri method:(NSString*)aMethod;
- (void) setupMediaResourceRequest:(HttpRequest*)aMediaResourceRequest resource:(ResourceBox*) aResourcBox;
- (NSString*) createRequestUri:(ResourceBox*)aSourceResourceBox binding:(RelatedEnd*)aRelatedEnd;   
- (void) updateChangeOrderIDToHttpStatus:(NSInteger)aHttpCode;
- (void) endNonBatchRequest;
- (void) updateEntriesState:(NSArray*)entries;

@end
