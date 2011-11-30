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

  
#import "constants.h"

//////////////////////////////////////
//constants for HTTPRequestHeader
NSString* const HttpRequestHeader_Accept						= @"Accept";
NSString* const HttpRequestHeader_AcceptCharset					= @"Accept-Charset";
NSString* const HttpRequestHeader_AcceptEncoding				= @"Accept-Encoding";
NSString* const HttpRequestHeader_AcceptLanguage				= @"Accept-Language";
NSString* const HttpRequestHeader_Allow							= @"Allow";
NSString* const HttpRequestHeader_Authorization					= @"Authorization";
NSString* const HttpRequestHeader_CacheControl					= @"Cache-Control";
NSString* const HttpRequestHeader_Connection					= @"Connection";
NSString* const HttpRequestHeader_ContentDisposition			= @"Content-Disposition";
NSString* const HttpRequestHeader_ContentLength					= @"Content-Length";
NSString* const HttpRequestHeader_ContentType					= @"Content-Type";
NSString* const HttpRequestHeader_ContentEncoding				= @"Content-Encoding";
NSString* const HttpRequestHeader_ContentLanguage				= @"Content-Language";
NSString* const HttpRequestHeader_ContentLocation				= @"Content-Location";
NSString* const HttpRequestHeader_ContentMd5					= @"Content-MD5";
NSString* const HttpRequestHeader_ContentRange					= @"Content-Range";
NSString* const HttpRequestHeader_Cookie						= @"Cookie";
NSString* const HttpRequestHeader_Date							= @"Date";
NSString* const HttpRequestHeader_Expect						= @"Expect";
NSString* const HttpRequestHeader_Expires						= @"Expires";
NSString* const HttpRequestHeader_From1							= @"From";
NSString* const HttpRequestHeader_Host							= @"Host";
NSString* const HttpRequestHeader_IfMatch						= @"If-Match";
NSString* const HttpRequestHeader_IfModifiedSince				= @"If-Modified-Since";
NSString* const HttpRequestHeader_IfNoneMatch					= @"If-None-Match";
NSString* const HttpRequestHeader_IfRange						= @"If-Range";
NSString* const HttpRequestHeader_IfUnmodifiedSince				= @"If-Unmodified-Since";
NSString* const HttpRequestHeader_KeepAlive						= @"";
NSString* const HttpRequestHeader_LastModified					= @"Last-Modified";
NSString* const HttpRequestHeader_Location						= @"Location";
NSString* const HttpRequestHeader_MaxForwards					= @"Max-Forwards";
NSString* const HttpRequestHeader_Pragma						= @"Pragma";
NSString* const HttpRequestHeader_ProxyAuthorization			= @"Proxy-Authorization";
NSString* const HttpRequestHeader_Referer						= @"Referer";
NSString* const HttpRequestHeader_Range							= @"Range";
NSString* const HttpRequestHeader_Slug							= @"Slug";
NSString* const HttpRequestHeader_Te							= @"TE";
NSString* const HttpRequestHeader_Translate						= @"Translate";
NSString* const HttpRequestHeader_Trailer						= @"Trailer";
NSString* const HttpRequestHeader_TransferEncoding				= @"Transfer-Encoding";
NSString* const HttpRequestHeader_Upgrade						= @"Upgrade";
NSString* const HttpRequestHeader_UserAgent						= @"User-Agent";
NSString* const HttpRequestHeader_Via							= @"Via";
NSString* const HttpRequestHeader_Warn							= @"Warn";
NSString* const HttpRequestHeader_Warning						= @"Warning";
NSString* const HttpRequestHeader_XHTTPMethod					= @"X-HTTP-Method";
/////////////////////////////////////

/////////////////////////////////////
//constants for HTTPVerb
NSString* const HttpVerb_DELETE									= @"DELETE";
NSString* const HttpVerb_GET									= @"GET";
NSString* const HttpVerb_POST									= @"POST";
NSString* const HttpVerb_PUT									= @"PUT";
NSString* const HttpVerb_MERGE									= @"MERGE";
/////////////////////////////////////


//definition of all erro messages thrown by context tracking and request generation logic
NSString* const Resource_AddInvalidObject						= @"Trying to Add Invalid Object";
NSString* const Resource_UpdateInvalidObject					= @"Trying to Update Invalid Object";
NSString* const Resource_DeleteInvalidObject					= @"Trying to Delete Invalid Object";
NSString* const Resource_AddLinkInvalidObject					= @"Trying to Add Link between Objects, where one or both objects are invalid";
NSString* const Resource_SetLinkInvalidObject					= @"Trying to Set Link between Objects, where one or both objects are invalid";
NSString* const Resource_DeleteLink								= @"Trying to Delete Link between Objects, where one or both objects are invalid";
NSString* const Resource_LoadPropertyInvalidObject				= @"Trying to call LoadProperty in an invalid object";
NSString* const Resource_InvalidObject							= @"Object is not valid";
NSString* const Resource_EntityAlreadyContained					= @"The context is already tracking the entity.";
NSString* const Resource_EntityNotContained						= @"The context is not currently tracking the entity.";

NSString* const Resource_NoRelationWithDeleteEnd				= @"One or both of the ends of the relationship is in the deleted state.";
NSString* const Resource_RelationAlreadyContained				= @"The context is already tracking the relationship.";
NSString* const Resource_NoRelationWithInsertEnd				= @"One or both of the ends of the relationship is in the added state.";
NSString* const Resource_RelationNotRefOrCollection				= @"The sourceProperty is not a reference or collection of the target's object type.";
NSString* const Resource_SetLinkReferenceOnly					= @"Incorrect Linking. SetLink method only works when the relationship with the sourceProperty is one to one.";
NSString* const Resource_AddLinkCollectionOnly					= @"Incorrect Linking. AddLink and DeleteLink methods only work when relationship with the sourceProperty is a one to many.";
NSString* const Resource_InCorrectLinking						= @"Incorrect Linking. AddLink will work only when relationship is one to many and setlink will work only when relationship is one to one";

NSString* const Resource_CountNotPresent						= @"Count value is not part of the response stream";
NSString* const Resource_MissingEditMediaLinkInResponseBody		= @"Error processing response stream. Missing href attribute in the edit-Media link element in the response";
NSString* const Resource_ExpectedEmptyMediaLinkEntryContent		= @"Error processing response stream. The ATOM content element is expected to be empty if it has a source attribute.";
NSString* const Resource_ExpectedValidHttpResponse				= @"DataServiceStreamResponse constructor requires valid HttpResponse object";
NSString* const Resource_InvalidArgumentForGetStream			= @"Second argument of GetStream API should be null, string or object of type DataServiceRequestArgs";
NSString* const Resource_EntityNotMediaLinkEntry				= @"This operation requires the specified entity to represent a Media Link Entry";
NSString* const Resource_SetSaveStreamWithoutEditMediaLink		= @"The binary property on the entity cannot be modified as a stream because the corresponding entry in the response does not have an edit-media link. Ensure that the entity has a binary property that is accessible as a stream in the data model.";
NSString* const Resource_LinkResourceInsertFailure				= @"One of the link\'s resources failed to insert.";
NSString* const Resource_MLEWithoutSaveStream					= @"Media Link Entry, but no save stream was set for the entity";
NSString* const Resource_ArgumentNotNull						= @" Argument cannot be null";
NSString* const Resource_NoLocationHeader						= @"The response to this POST request did not contain a \'location\' header. That is not supported by this client.";
NSString* const Resource_InvalidSaveChangesOptions				= @"The specified SaveChangesOptions is not valid, use SaveChangesOptions::Batch or SaveChangesOptions::None";
NSString* const Resource_NullValueNotAllowedForKey				= @"The serialized resource has a null value in key member, Null values are not supported in key members - [Check you have set value of any key memeber to null by mistake or if you have used select query option, make sure this member variable is selected] Key Name: ";
NSString* const Resource_NoLoadWithInsertEnd					= @"The context cannot load the related collection or reference for objects in the added state";
NSString* const Resource_NoLoadWithUnknownProperty				= @"The context cannot load the related collection or reference to the unknown property - ";
NSString* const Resource_AttachLocationFailedDescRetrieval		= @"Internal Error: AttachLocation Failed to retrieve the descriptor";
NSString* const Resource_UnexpectdEntityState					= @"Unexpected Entity State while trying to generate changeset body for resource";
NSString* const Resource_InvalidEntityClassName					= @"Failed to find entity class with name -";
NSString* const Resource_InvalidExecuteArg						= @"Execute API receives only uri or DataServiceQueryContinuation";
NSString* const Resource_NoEmptyQueryOption						= @"Error in DataService Query: Can\'t add empty Query option";
NSString* const Resource_ReservedCharNotAllowed					= @"Error in DataService Query: Can\'t add query option because it begins with reserved character \'$\' - ";
NSString* const Resource_NoDuplicateOption						= @"Error in DataService Query: Can\'t add duplicate query option - ";
NSString* const Resource_NoCountAndInLineCount					= @"Cannot add count option to the resource set because it would conflict with existing count options";
NSString* const Resource_CollectionNotBelongsToQueryResponse	= @"GetContinuation API: The collection is not belonging to the QueryOperationResponse";
NSString* const Resource_FCTargetPathMissing					= @"Invalid Proxy File failed to retrieve \'FC_TargetPath\' for the property - ";
NSString* const Resource_FCKeepInContentMissing					= @"Invalid Proxy File failed to retrieve \'FC_KeepInContent\' for the property - ";
NSString* const Resource_FCContentKindMissing					= @"Invalid Proxy File failed to retrieve \'FC_ContentKind\' for the property - ";
NSString* const Resource_FCNsPrefixMissing						= @"Invalid Proxy File failed to retrieve \'FC_NsPrefix\' for the property - ";
NSString* const Resource_FCNsUriMissing							= @"Invalid Proxy File failed to retrieve \'FC_NsUri\' for the property - ";
NSString* const Resource_EntityHeaderCannotAppy					= @"Entity header can be applied only if entity is in added or modified state";
NSString* const Resource_EntityHeaderOnlyArray					= @"Second argument to SetEntityHeader must be an array";

    
//definition for data service specific headers
NSString* const Resource_MaxDataServiceVersion					= @"2.0";
NSString* const Resource_DefaultDataServiceVersion				= @"1.0";
NSString* const Resource_DataServiceVersion_1					= @"1.0";
NSString* const Resource_DataServiceVersion_2					= @"2.0";
    
//definition of possible Accept and Content-Types headers    
NSString* const Resource_Accept_ATOM							= @"application/atom+xml,application/xml";	    
NSString* const Resource_Content_Type_ATOM						= @"application/atom+xml,application/xml";
NSString* const Resource_AZURE_API_VERSION						= @"2009-04-14";
NSInteger const Resource_DefaultSaveChangesOptions				= None;
    
//error message for version mismatch
NSString* const Resource_VersionMisMatch						= @"Response version mismatch. Client Library Expect version 2.0, but service returns response with version ";
