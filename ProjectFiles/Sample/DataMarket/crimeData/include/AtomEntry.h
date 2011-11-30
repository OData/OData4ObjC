
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


@interface AtomEntry : NSObject {
	/**
     *
     * @var <bool> Indicate whethter entry is a MediaLinkEntry or not
     */
    BOOL m_mediaLinkEntry;
    /**
     *
     * @var <Uri> The uri to the actual resource, taken from
     * stc attribute of Content node
     * ex: http://mflasko-dev/Shared%20Documents/Bug_Stats.xlsx
     */
    NSString *m_mediaContentUri;
	
    /**
     *
     * @var <Uri> The href value from media-edit link
     * <link m:etag=""{4762C1D2-43B0-40B2-AF9D-CF205E1FBB2E},16""
     *       rel="edit-media" title="SharedDocumentsItem"
     *       href="SharedDocuments(2)/$value" />
     */
    NSString *m_editMediaLink;
	
    /**
     *
     * @var <string> The vlaue of m:etag attribute of edit-media link
     */
    NSString *m_streamETag;
    
    /**
     *
     * @var <string> ETag attribute of entity 
     */
    NSString *m_entityETag;
	
    /**
     *
     * @var <Uri> The href value in the edit link node
     */
	NSString *m_identity;
}

@property ( nonatomic ,	assign , getter=getMediaLinkEntry ,	setter=setMediaLinkEntry	) BOOL m_mediaLinkEntry;
@property ( nonatomic , retain , getter=getMediaContentUri, setter=setMEdiaContentUri	) NSString *m_mediaContentUri;
@property ( nonatomic , retain , getter=getEditMediaLink ,	setter=setEditMediaLink		) NSString *m_editMediaLink;
@property ( nonatomic , retain , getter=getStreamETag ,		setter=setStreamETag		) NSString *m_streamETag;
@property ( nonatomic , retain , getter=getEntityETag ,		setter=setEntityETag		) NSString *m_entityETag;
@property ( nonatomic , retain , getter=getIdentity	,		setter=setIdentity			) NSString *m_identity;

- (id) init;

@end
