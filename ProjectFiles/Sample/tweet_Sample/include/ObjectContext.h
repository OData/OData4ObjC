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


#import <Foundation/Foundation.h>

#import "MSODataResponseDelegate.h"
#import "ObjectContextDelegate.h"
#import "ODataDelegate.h"

#import "ODataEntity.h"
#import "ODataObject.h"
#import "RelatedEnd.h"
#import "ResourceBox.h"
#import "Dictionary.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "QueryOperationResponse.h"
#import "DataServiceRequestException.h"
#import "AtomEntry.h"
#import "AtomParser.h"
#import "Utility.h"
#import "DataServiceStreamResponse.h"
#import "ODataSVC.h"
#import "CredentialBase.h"

@class HTTPHandler;

@interface ObjectContext : NSObject <MSODataResponseDelegate>
{
	/**
     *
     * ObjectContextDelegate delegate for passing back result or error 
     */
	id<ObjectContextDelegate> m_objectContextdelegate;
	
	/**
     *
     * ODataDelegate delegate for passing back result or error 
     */
	id<ODataDelegate> m_oDataDelegate;
	
	/**
     *
     * ObjectContextDelegate delegate for passing back result or error 
     */
	id<ObjectContextDelegate> m_delegate;
	
	/**
     *
     * ODataSVC object contains workspaces and collections
     */
	ODataSVC *m_ODataSVC;
	
	/**
     *
     * Httprequest object for firing the query and getting the result
     */
	//HttpRequest *httpRequest;
	
	/**
	 *
     * The user provided url to Data Service or Azure Storage Tables
     */
	NSString *m_baseUri;
	
    /**
     *
     * baseURI with a slash
     */
    NSString *m_baseUriWithSlash;
	
    /**
     *
     * <array<string>>
     */
    NSMutableArray *m_entities;
	
    /**
     *
     * <array<key => value>>
     * Associative array to map from entity set to entity type. During proxy
     * class generation this array will be populated
     */
    NSMutableDictionary *m_entitySet2Type;
	
    /**
     *
     * <array<key => value>>
     * Associative array to map from entity type to entity set. During proxy
     * class generation this array will be populated
     */
    NSMutableDictionary *m_entityType2Set;
	
    /**
     *
     * <array<key =>array<key, value>>
     * Associative arry holding association type. 0..1, 1 or *
     */
    NSMutableDictionary *m_association;
	
    /**
     * This dictioary will be used to track all the data service entites
     * currently in the context.
     * Key=>ODataObject : Value=>ResourceBox
     */ 
    Dictionary *m_objectToResource;
	
    /**
     * This dictioary will be used to track all the related entites
     * currently in the context.
     * Key=>RelatedEnd : Value=>RelatedEnd
     */ 
    Dictionary *m_bindings;
    
    /**
     * This array will track the objects in the context
     * which have identity (ex: object in the context which
     * result of a query execution)
     */
    NSMutableDictionary *m_identityToResource;
    
    /**
     * Hold the id of next changed entries
     */
    NSInteger m_nextChange;
    
    /**
     * Credential Object holding credential information [Windows or Azure]
     */ 
    CredentialBase *m_Credential;  
    
    /**
     * Proxy Object holding ProxyServer information
     */ 
    HttpProxy *m_httpProxy;    
    
    /**
     * This array holds custom headers as key-value
     */
	NSMutableDictionary *m_customHeaders;
	
    /**
     *
     * @var <string>
     */
    NSString *m_accept;
    
    /**
     *
     * @var <string> 
     */
    NSString *m_contentType;
	
    /**
     *
     * @var <bool>
     */
    BOOL m_usePostTunneling;
	
    /**
     *
     * @var <SaveChangesOptions>
     * To hold save changes option, SaveChangesOptions::Batch or
     * SaveChangesOptions::None
     */
    NSInteger m_saveChangesOptions;
    
    /**
     *
     * @var <bool>
     * Decide how to perfrom updation, if set true then PUT else MERGE
     */
    BOOL m_replaceOnUpdateOption;
	
	/**
     *
     * @var <string>
     * data service version number
     */
	NSString *m_dataServiceVersion;
	/**
     *
     * @var <string>
     * data service Namespace
     */
	NSString *m_serviceNamespace;
	
	/**
     *
     * dictionary for getting relationship value
     */
	NSMutableDictionary *m_entityFKRelation;
}

@property ( nonatomic , retain , getter=getObjectContextDelegate ,	setter=setObjectContextDelegate	) id<ObjectContextDelegate> m_objectContextdelegate;
@property ( nonatomic , retain , getter=getDelegate ,				setter=setDelegate				) id<ObjectContextDelegate> m_delegate;
@property ( nonatomic , retain , getter=getODataSVC ,				setter=setODataSVC				) ODataSVC *m_ODataSVC;
@property ( nonatomic , retain , getter=getCredentials ,				setter=setCredentials			) CredentialBase *m_Credential;

@property ( nonatomic , retain , getter=getBaseUri ,				setter=setBaseUri				) NSString *m_baseUri;
@property ( nonatomic , retain , getter=getBaseUriWithSlash ,		setter=setBaseUriWithSlash		) NSString *m_baseUriWithSlash;
@property ( nonatomic , assign , getter=getNextChange ,				setter=setNextChange			) NSInteger m_nextChange; 
@property ( nonatomic , retain , getter=getAccept ,					setter=setAccept				) NSString *m_accept;
@property ( nonatomic , retain , getter=getContentType ,			setter=setContentType			) NSString *m_contentType;
@property ( nonatomic , assign , getter=getUsePostTunneling ,		setter=setUsePostTunneling		) BOOL m_usePostTunneling;
@property ( nonatomic , assign , getter=getSaveChangesOptions ,		setter=setSaveChangesOptions	) NSInteger m_saveChangesOptions;
@property ( nonatomic , assign , getter=getReplaceOnUpdateOption ,	setter=setReplaceOnUpdateOption	) BOOL m_replaceOnUpdateOption;
@property ( nonatomic , retain , getter=getObjectToResource ,		setter=setObjectToResource		) Dictionary *m_objectToResource;
@property ( nonatomic , retain , getter=getBindings ,				setter=setBindings				) Dictionary *m_bindings;
@property ( nonatomic , retain , getter=getHttpProxy ,				setter=setHttpProxy				) HttpProxy *m_httpProxy;
@property ( nonatomic , retain , getter=getIdentityToResource ,		setter=setIdentityToResource	) NSMutableDictionary *m_identityToResource;
@property ( nonatomic , retain , getter=getEntities ,				setter=setEntities				) NSMutableArray *m_entities;

@property ( nonatomic , retain , getter=getEntityFKRelation ,		setter=setEntityFKRelation		) NSMutableDictionary *m_entityFKRelation;
@property ( nonatomic , retain , getter=getCustomHeaders ,			setter=setCustomHeaders			) NSMutableDictionary *m_customHeaders;
@property ( nonatomic , retain , getter=getDataServiceVersion ,		setter=setDataServiceVersion	) NSString *m_dataServiceVersion;
@property ( nonatomic , retain , getter=getServiceNamespace ,		setter=setServiceNamespace		) NSString *m_serviceNamespace;
@property ( nonatomic , retain , getter=getODataDelegate ,			setter=setODataDelegate			) id<ODataDelegate> m_oDataDelegate;


//@property ( nonatomic, retain ) HttpRequest *httpRequest;

- (id) init;
- (id) initWithUri: (NSString*) aUri credentials:(id)aCredential dataServiceVersion:(NSString *)aDataServiceVersion;
- (void) getSVC;
- (void) retrieveSVC:(NSString*)aUri;

- (void) setSaveChangesOptions : (NSInteger) aSaveChangesOptions;
- (void) addObject:(NSString*) anEntityName object:(ODataObject*) anObject;
- (void) updateObject:(ODataObject*) anObject;
- (void) addLink:(ODataObject*) aSourceObject sourceProperty:(NSString*) aSourceProperty targetObject:(ODataObject*) aTargetObject;
- (void) deleteObject:(ODataObject*)anObject;
- (void) deleteLink:(ODataObject*) aSourceObject sourceProperty:(NSString*)aSourceProperty targetObject:(ODataObject*)aTargetObject;
- (void) setLink:(ODataObject*) aSourceObject sourceProperty:(NSString*)aSourceProperty targetObject:(ODataObject*)aTargetObject;
- (void) setEntityHeaders:(id)anObject header:(NSDictionary*) aHeaders;
- (void) saveChanges;
- (BOOL) hasModifiedResourceState:(ODataEntity*)anEntry;
- (QueryOperationResponse*) loadProperty:(ODataObject*) aSourceObject propertyName:(NSString*)aPropertyName dataServiceQueryContinuation:(DataServiceQueryContinuation*) aDataServiceQueryContinuationObject;
- (void) onBeforeHttpRequest:(HttpRequest *)request;
- (void) onAfterHttpRequest:(HttpResponse*)response;

//- (void) execute:(id)anUriOrDSQueryContinuationObject;
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbody:(NSString *)body etag:(NSString *)etag;
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbodydata:(NSData *)body etag:(NSString *)etag;
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbody:(NSString *)body etag:(NSString *)etag customHeaders:(NSMutableDictionary *)custom_headers;
-(HTTPHandler*) executeHTTPRequest:(NSString *)aUri httpmethod:(NSString *)method httpbodydata:(NSData *)body etag:(NSString *)etag customHeaders:(NSMutableDictionary *)custom_headers;

- (QueryOperationResponse*) execute:(NSString*)aQuery;
- (QueryOperationResponse*) executeDSQueryContinuation:(DataServiceQueryContinuation*)aDataServiceQueryContinuationObject;

//- (QueryOperationResponse*) executeAndProcessResult:(HttpRequest*) httpRequest dataServiceVersion:(NSString*) aDataServiceVersion;
//- (HttpResponse*) executeAndReturnResponse:(HttpRequest*)httpRequest dataServiceVersion:(NSString*)aDataServiceVersion error:(BOOL*)isError innerException:(NSString*) anInnerException;

- (void) incrementChange :(ODataEntity*) anEntity;
- (void) validateAddLink:(RelatedEnd*) aRelatedEndObject;
- (void) validateSetLink:(RelatedEnd*) aRelatedEndObject;
- (void) validateDeleteLink:(RelatedEnd*) aRelatedEndObject;
- (void) checkRelationForObject:(ODataObject*)sourceObject property:(NSString *)sourceProperty method:(NSString *)method;
- (void) detachRelated:(ResourceBox*) aResourceBoxObject;
- (void) detachExistingLink:(RelatedEnd*) aRelatedEndObject;
- (RelatedEnd*) detachReferenceLink:(ODataObject*) aSourceObject sourceProperty:(NSString*)aSourceProperty targetObject:(ODataObject*)aTargetObject;
- (void) loadResourceBox:(NSString*) aString resouceBox:(ResourceBox*) aResourceBox contentType:(NSString*) aContentType;
- (ODataObject*) addToObjectToResource:(NSString*) anEntityType atomEntry:(AtomEntry*)anAtomEntryObject;

- (void) addToBindings:(ODataObject*) aSourceObject sourcePropertyName:(NSString*) aSourcePropertyName targetObject:(ODataObject*) aTargetObject;
- (void) throwExceptionIfNotValidObject:(id)anObject methodName:(NSString*) aMethodName;
- (void) addHeader:(NSString*) aHeaderName headerValue:(NSString*)aHeaderValue;
- (void) removeHeaders;
- (NSString*) getEntitySetNameFromType:(NSString*) aEntityType;
- (NSString*) getEntityTypeNameFromSet:(NSString*) aEntitySet;
- (NSString*) getRelationShip:(NSString*) aRelationship fromOrToRole: (NSString*) aFromOrToRole;
- (NSString*) getReadStreamUri:(ODataEntity*) anEntity;
- (DataServiceStreamResponse*) getReadStream:(ODataObject*)anODataObject; 
- (void) setSaveStream:(ODataObject*)anODataObject stream:(NSData*)aStream closeStream:(BOOL)aCloseStream contentType:(NSString*)aContentType slug:(NSString*)aSlug;
- (HttpRequest*) createRequest:(NSString*) aRequestUri httpVerb:(NSString*)aHttpVerb allowAnyType:(BOOL) allowAnyType contentType:(NSString*)aContentType dataServiceVersion:(NSString*)aDataServiceVersion;
- (void) attachLocation:(ODataObject*)anODataObject location:(NSString*)aLocation;

-(void) setEntitiesWithArray:(NSArray *)anArray;

-(void) setEntitySet2TypeWithObject:(NSArray *)anArrayOfEntityType forKey:(NSArray *)anArrayOfEntitySet;
-(void) setEntityType2SetWithObject:(NSArray *)anArrayOfEntitySet forKey:(NSArray *)anArrayOfEntityType;
-(void) setAssociationforObjects:(NSArray *)anArrayOfDictionaries forKeys:(NSArray *)aForeignKeysArray;

- (NSMutableDictionary*) getCustomHeaders;
- (NSMutableDictionary*) getWorkspaces;
- (ODataWorkspace*) getWorkspace:(NSString*)aTitle;
- (NSMutableArray *)getCopy:(NSArray *)queryOperationResponseArray;

//////////////////////////////////////////////////////////////////
- (NSArray*) getAllKeyObjets;
- (NSArray*) getAllEntityObjets;
//////////////////////////////////////////////////////////////////

- (id) executeServiceOperation:(NSString*)aQuery httpMethod:(NSString*)aHttpMethod isReturnTypeCollection:(BOOL)isReturnTypeCollection;
-(NSString *)prepareQuery:(NSString*)aFunctionName parameters:(NSDictionary*)aParam;
-(NSString *) retrieveDate:(NSDate *)date;

@end
