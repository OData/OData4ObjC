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


#import "ODataEntity.h"
#import "ODataObject.h"
#import "RelatedEnd.h"
#import "DataServiceSaveStream.h"

@interface ResourceBox: ODataEntity
{   
    
   /**
    * This variable will hold the uri to the resource if resource is existing
    * ex: http://server/service.svc/Customer(CustomerID='CHA25')
    * else null (just added)
    */
    NSString *m_editLink;
    
   /**
    * This variable will hold the relative uri of the resource
    * If the resource is just added in the context then this variable 
    * contains EntityName
    * ex: Customers
    * If the resource is already existing then this variable holds the unique id
    * in the data service
    * ex: Customers(CustomerID='CHA12')
    */
    NSString *m_identity;
    
   /**
    * Number of related links. ie number of elements in the Bindings dictionary
    * in which resource participate as SourceObject
    */ 
    NSInteger m_relatedLinkCount;
    
    /**
     * The entity instance
     */
    ODataObject *m_resource;    
    
    /**
     *
     * @var <uri> The uri taken from href attribute of edit-media link node
     * Populated from AtomEntry::EditMediaLink 
     */
    NSString *m_editMediaLink;

    /**
     *
     * @var <bool> True if associated resource is a Media Link Entry
     * Populated from AtomEntry::MediaLinkEntry
     */
    BOOL m_mediaLinkEntry;

    /**
     *
     * @var <string> The etag value taken from m:etag attribute of edit-media link node
     * Populated from AtomEntry::StreamETag
     */
    NSString *m_streamETag;
    
    /**
     *
     * @var <string> The etag value taken from m:etag attribute of entry node
     * Populated from AtomEntry::EntityTag
     */
    NSString *m_entityTag;

    /**
     *
     * @var <uri> The uri taken from href attribute of Content node
     * Populated from AtomEntry::MediaContentUri
     */
	NSString *m_streamLink;

    /**
     *
     * @var <DataServiceSaveStream> This object holds stream and 
     * headers to be send for PUTing or POSTing of BLOBs
     */
    DataServiceSaveStream *m_saveStream;

    /**
     *
     * @var <array> To hold http header specific for an entity
     * ex: Slug
     */
    NSMutableDictionary *m_headers;

}

@property ( nonatomic , retain , getter=getEditLink ,			setter=setEditLink			) NSString *m_editLink;
@property ( nonatomic , retain , getter=getIdentity ,			setter=setIdentity			) NSString *m_identity;
@property ( nonatomic , assign , getter=getRelatedLinkCount ,	setter=setRelatedLinkCount	) NSInteger m_relatedLinkCount;
@property ( nonatomic , retain , getter=getResource ,			setter=setResource			) ODataObject *m_resource;
@property ( nonatomic , retain , getter=getEditMediaLink ,		setter=setEditMediaLink		) NSString *m_editMediaLink;
@property ( nonatomic , assign , getter=getMediaLinkEntry ,		setter=setMediaLinkEntry	) BOOL m_mediaLinkEntry;
@property ( nonatomic , retain , getter=getStreamETag ,			setter=setStreamETag		) NSString *m_streamETag;
@property ( nonatomic , retain , getter=getEntityTag ,			setter=setEntityTag			) NSString *m_entityTag;
@property ( nonatomic , retain , getter=getStreamLink,			setter=setStreamLink		) NSString *m_streamLink;
@property ( nonatomic , retain , getter=getSaveStream ,			setter=setSaveStream		) DataServiceSaveStream *m_saveStream; 

-(id) initWithIdentity:(NSString*)anIdenity editLink:(NSString*) anEditLink resource:(ODataObject*) anResource;
-(NSString*) getResourceUri:(NSString*) aBaseUriWithSlash;
-(NSString*) getResourceUri:(NSString*) aBaseUriWithSlash tragetResourceBox:(ResourceBox *)aResourceBox;

-(BOOL) isRelatedEntity:(RelatedEnd*)anRelatedEndObj;
-(NSString*) getMediaResourceUri:(NSString*) aBaseUriWithSlash;
-(NSString*) getEditMediaResourceUri:(NSString*) aBaseUriWithSlash;
-(void) setHeaders:(NSDictionary*)aHeaders;
- (NSDictionary*) getHeaders;

@end