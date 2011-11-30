
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
#import "mProperties.h"
#import "ODataBool.h"

@interface ODataObject : NSObject/*<NSCopying>*/{

	/**
     * variable holding unique id (GUID)
     */
    NSString				*m_objectID;
	NSMutableDictionary		*m_OData_entityMap;
	NSMutableDictionary		*m_OData_propertiesMap;
	NSMutableDictionary		*m_OData_entityKey;
	NSMutableArray			*m_OData_relLinks;
	NSString				*m_OData_baseURI;
	NSMutableDictionary		*m_OData_entityFKRelation;
	ODataBool				*m_OData_hasStream;
	NSString				*m_OData_etag;
}

@property ( nonatomic, retain, getter=getObjectID,		   setter=setObjectID         ) NSString *m_objectID;
@property ( nonatomic, retain, getter=getEntityMap,		   setter=setEntityMap		  )NSMutableDictionary *m_OData_entityMap;
@property ( nonatomic, retain, getter=getEntityKey,		   setter=setEntityKey		  )NSMutableDictionary *m_OData_entityKey;
@property ( nonatomic, retain, getter=getRelLinks,		   setter=setRelLinks		  )NSMutableArray *m_OData_relLinks;
@property ( nonatomic, retain, getter=getBaseURI,		   setter=setBaseURI		  )NSString *m_OData_baseURI;
@property ( nonatomic, retain, getter=getEntityFKRelation, setter=setEntityFKRelation )NSMutableDictionary *m_OData_entityFKRelation;
@property ( nonatomic, retain, getter=getEtag,			   setter=setEtag             )NSString *m_OData_etag;
- (id) init;
- (id) initWithUri:(NSString*)anUri;
- (id) getActualEntityTypeName:(id)aKey;
- (id) getDeepCopy;
- (BOOL) hasStream;
-(NSMutableArray *)getSyndicateArray;
-(mProperties *)getPropertiesFromPropertiesMap:(NSString *)propname;

@end
