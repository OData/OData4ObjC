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

  
enum SaveChangesOptions
{
	None = 0,
	Batch = 1
};


/**
 *
 * This file contains the definition of EntityStates Class (used as enum)
 */
/**
 * The EntityStates Class.
 * 
 * This class defines constants which is used to represents state of entity instances
 * during object tracking.
 *  
 */
enum EntityStates
{
	/**
	 * Used to indicate a new entity has been added (using AddObject) or
	 * a new link has been created (using AddLink)
	 */
		
	Added = 1,
		
	/**
	 * Used to indicate an entity has been deleted (using DeleteObject) or
	 * a link has been deleted (using DeleteLink)
	 */
		
	Deleted = 2,
		
	/**
	 * Used to indicate a link has been detached (when we delete an object using 
	 * DeleteObject all assoicated links added using AddLink should be released
	 * and its status should be set to Detached)
	 */
		
	Detached = 3,
		
	/**
	 * Used to indicate an entity has been modified (using UpdateObject)
	 */
		
	Modified = 4,
		
	/**
	 * Used to indicate the entity has not yet changed (when we perform any query
	 * execution the resultant entities will be in  Unchanged state).
	 */
	Unchanged = 5
};

//constanst for HTTPRequestHeader
extern NSString* const HttpRequestHeader_Accept;
extern NSString* const HttpRequestHeader_AcceptCharset;
extern NSString* const HttpRequestHeader_AcceptEncoding;
extern NSString* const HttpRequestHeader_AcceptLanguage;
extern NSString* const HttpRequestHeader_Allow;
extern NSString* const HttpRequestHeader_Authorization;
extern NSString* const HttpRequestHeader_CacheControl;
extern NSString* const HttpRequestHeader_Connection;
extern NSString* const HttpRequestHeader_ContentDisposition;
extern NSString* const HttpRequestHeader_ContentLength;
extern NSString* const HttpRequestHeader_ContentType;
extern NSString* const HttpRequestHeader_ContentEncoding;
extern NSString* const HttpRequestHeader_ContentLanguage;
extern NSString* const HttpRequestHeader_ContentLocation;
extern NSString* const HttpRequestHeader_ContentMd5;
extern NSString* const HttpRequestHeader_ContentRange;
extern NSString* const HttpRequestHeader_Cookie;
extern NSString* const HttpRequestHeader_Date;
extern NSString* const HttpRequestHeader_Expect;
extern NSString* const HttpRequestHeader_Expires;
extern NSString* const HttpRequestHeader_From1;
extern NSString* const HttpRequestHeader_Host;
extern NSString* const HttpRequestHeader_IfMatch;
extern NSString* const HttpRequestHeader_IfModifiedSince;
extern NSString* const HttpRequestHeader_IfNoneMatch;
extern NSString* const HttpRequestHeader_IfRange;
extern NSString* const HttpRequestHeader_IfUnmodifiedSince;
extern NSString* const HttpRequestHeader_KeepAlive;
extern NSString* const HttpRequestHeader_LastModified;
extern NSString* const HttpRequestHeader_Location;
extern NSString* const HttpRequestHeader_MaxForwards;
extern NSString* const HttpRequestHeader_Pragma;
extern NSString* const HttpRequestHeader_ProxyAuthorization;
extern NSString* const HttpRequestHeader_Referer;
extern NSString* const HttpRequestHeader_Range;
extern NSString* const HttpRequestHeader_Slug;
extern NSString* const HttpRequestHeader_Te;
extern NSString* const HttpRequestHeader_Translate;
extern NSString* const HttpRequestHeader_Trailer;
extern NSString* const HttpRequestHeader_TransferEncoding;
extern NSString* const HttpRequestHeader_Upgrade;
extern NSString* const HttpRequestHeader_UserAgent;
extern NSString* const HttpRequestHeader_Via;
extern NSString* const HttpRequestHeader_Warn;
extern NSString* const HttpRequestHeader_Warning;
extern NSString* const HttpRequestHeader_XHTTPMethod;


//consts HTTPVerb
extern NSString* const HttpVerb_DELETE;
extern NSString* const HttpVerb_GET;
extern NSString* const HttpVerb_POST;
extern NSString* const HttpVerb_PUT;
extern NSString* const HttpVerb_MERGE;
/**
 *
 
 * This file contains the constants for resource
  */

    //definition of all erro messages thrown by context tracking and request generation logic
    extern NSString* const Resource_AddInvalidObject;
    extern NSString* const Resource_UpdateInvalidObject;
	extern NSString* const Resource_DeleteInvalidObject;    
	extern NSString* const Resource_AddLinkInvalidObject;
    extern NSString* const Resource_SetLinkInvalidObject;
    extern NSString* const Resource_DeleteLink;
    extern NSString* const Resource_LoadPropertyInvalidObject;
    extern NSString* const Resource_InvalidObject;
    extern NSString* const Resource_EntityAlreadyContained;
    extern NSString* const Resource_EntityNotContained;
    extern NSString* const Resource_NoRelationWithDeleteEnd;
    extern NSString* const Resource_RelationAlreadyContained;
    extern NSString* const Resource_NoRelationWithInsertEnd;
    extern NSString* const Resource_RelationNotRefOrCollection;
    extern NSString* const Resource_SetLinkReferenceOnly;
    extern NSString* const Resource_AddLinkCollectionOnly;
    extern NSString* const Resource_CountNotPresent;
    extern NSString* const Resource_MissingEditMediaLinkInResponseBody;
    extern NSString* const Resource_ExpectedEmptyMediaLinkEntryContent;
    extern NSString* const Resource_ExpectedValidHttpResponse;
    extern NSString* const Resource_InvalidArgumentForGetStream;
    extern NSString* const Resource_EntityNotMediaLinkEntry;
	extern NSString* const Resource_SetSaveStreamWithoutEditMediaLink;
	extern NSString* const Resource_LinkResourceInsertFailure;
    extern NSString* const Resource_MLEWithoutSaveStream;
    extern NSString* const Resource_ArgumentNotNull;
    extern NSString* const Resource_NoLocationHeader;
    extern NSString* const Resource_InvalidSaveChangesOptions;
	extern NSString* const Resource_NullValueNotAllowedForKey;    
	extern NSString* const Resource_NoLoadWithInsertEnd;	
	extern NSString* const Resource_NoLoadWithUnknownProperty;    
	extern NSString* const Resource_AttachLocationFailedDescRetrieval;
	extern NSString* const Resource_UnexpectdEntityState;    
	extern NSString* const Resource_InvalidEntityClassName;
	extern NSString* const Resource_InvalidExecuteArg;
	extern NSString* const Resource_NoEmptyQueryOption;
	extern NSString* const Resource_ReservedCharNotAllowed;
	extern NSString* const Resource_NoDuplicateOption;
	extern NSString* const Resource_NoCountAndInLineCount;
	extern NSString* const Resource_CollectionNotBelongsToQueryResponse;
	extern NSString* const Resource_FCTargetPathMissing;    
	extern NSString* const Resource_FCKeepInContentMissing;
	extern NSString* const Resource_FCContentKindMissing;    
	extern NSString* const Resource_FCNsPrefixMissing;
	extern NSString* const Resource_FCNsUriMissing;   
	extern NSString* const Resource_EntityHeaderCannotAppy;
	extern NSString* const Resource_EntityHeaderOnlyArray;    

	//definition for data service specific headers
	extern NSString* const Resource_MaxDataServiceVersion;    
	extern NSString* const Resource_DefaultDataServiceVersion;
	extern NSString* const Resource_DataServiceVersion_1;
	extern NSString* const Resource_DataServiceVersion_2;

	//definition of possible Accept and Content-Types headers    
	extern NSString* const Resource_Accept_ATOM;    
	extern NSString* const Resource_Content_Type_ATOM;
	extern NSString* const Resource_AZURE_API_VERSION;
	extern NSInteger const  Resource_DefaultSaveChangesOptions;

	//error message for version mismatch
	extern NSString* const Resource_VersionMisMatch;
