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


#import "ODataObject.h"
#import "ODataGUID.h"


@implementation ODataObject
@synthesize m_objectID,m_OData_entityKey,m_OData_relLinks,m_OData_baseURI,m_OData_entityFKRelation,m_OData_etag;
@synthesize m_OData_entityMap;

-(id) init
{
	if(self = [super init])
	{
		[self setObjectID:[NSString stringWithString:[ODataGUID GetNewGuid]]];
		m_OData_hasStream=[[ODataBool alloc]init];
		m_OData_entityMap =[[NSMutableDictionary alloc]init];
		m_OData_propertiesMap=[[NSMutableDictionary alloc]init];
		m_OData_entityFKRelation=[[NSMutableDictionary alloc]init];
		m_OData_entityKey=[[NSMutableDictionary alloc]init];
	}
	return self;
}
- (id) initWithUri:(NSString*)anUri
{
	if(self = [super init])
	{
		[self setObjectID:[NSString stringWithString:[ODataGUID GetNewGuid]]];
		m_OData_hasStream=[[ODataBool alloc]init];
		self.m_OData_entityMap =[[NSMutableDictionary alloc]init];
		m_OData_propertiesMap=[[NSMutableDictionary alloc]init];
		self.m_OData_entityFKRelation=[[NSMutableDictionary alloc]init];
		self.m_OData_entityKey=[[NSMutableDictionary alloc]init];
		[self setBaseURI:anUri];
	}
	return self;
}

-(void) dealloc
{
	[m_objectID release];
	m_objectID=nil;
	[m_OData_entityKey release];
	m_OData_entityKey=nil;
	[m_OData_relLinks release];
	m_OData_relLinks=nil;
	[m_OData_baseURI release];
	m_OData_baseURI=nil;
	[m_OData_entityFKRelation release];
	m_OData_entityFKRelation=nil;
	[m_OData_etag release];
	m_OData_etag=nil;
	[m_OData_propertiesMap release];
	m_OData_propertiesMap=nil;
	[m_OData_entityMap release];
	m_OData_entityMap = nil;
	[m_OData_hasStream release];
	m_OData_hasStream = nil;
	
	[super dealloc];
	
}
/**
 * Method for getting Entity Type Name corrosponding to navigation Name
 * @param navigation name
 * returns EntityType name for the key else returns the key.
 */
- (id) getActualEntityTypeName:(id)aKey
{
	id value = [m_OData_entityMap objectForKey:aKey];
	if(value != nil)
		return value;
	return aKey;
	
}

/**
 * Method for getting properties object corrosponding to interface member\n"\
 * @param name of parameter
 * returns mProperties Object for corrosponding parameter
 */
- (mProperties *) getPropertiesFromPropertiesMap:(id)aKey;
{
	return [m_OData_propertiesMap objectForKey:aKey];
}
/*
 * method to check if the object supports media link
 * returns YES if the object supports media link else returns NO
 */
- (BOOL) hasStream
{
	return [m_OData_hasStream getbool];
}
/*
 * method to get deep copy of the object
 */

- (id)getDeepCopy
{
	return nil;
}
/*
 * method to get properties which have syndication
 * returns array of name of properties 
 */

-(NSMutableArray *)getSyndicateArray
{
	return nil;
}

@end
