
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


@class ObjectContext;
@class QueryOperationResponse;
@class XMLGenerator;
@class ODataSVC;
@class ODataXMLElements;
@class AtomEntry;
@class ResourceBox;

@interface AtomParser : NSObject 
{
	/*
	 * Stores reference for ObjectContext 
	 */
	ObjectContext *m_objectContext;	
	
	/*
	 * Stores reference for QueryOperationResponse
	 */
	QueryOperationResponse *m_queryResponseObject;
	
	/*
	 * Contains collection of HTTP URI for Object Resource
	 */
	NSMutableDictionary *m_nextLinkUrl;
}

@property (nonatomic,assign) ObjectContext *m_objectContext;
@property (nonatomic,assign) QueryOperationResponse *m_queryResponseObject;
@property (nonatomic,retain,getter=getNextLinkUrl, setter=setNextLinkUrl) NSMutableDictionary *m_nextLinkUrl;

-(id)init;
-(id)initwithContext:(ObjectContext *)context;

-(NSString *)buildXML:(id) object methodtype:(const char *)type;
-(XMLGenerator *)buildXMLAtomProperties:(id) object methodtype:(const char *)type;
-(XMLGenerator *)buildXMLAtomContent:(id) object methodtype:(const char *)type;
-(NSString *)retrieveTime;
-(void)EnumerateObjects:(ODataXMLElements *)XMLDocument  queryResponseObject:(id)queryResponse;
-(NSMutableArray *) EnumerateFeeds:(ODataXMLElements *)theElement parent:(id)parentObject;
-(id) EnumerateEntry:(ODataXMLElements *)theElement parent:(id)parentObject;
-(void)storeObjectProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement;
-(void)storeClassProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement edmType:(NSString *)anEdmType;
-(NSString *) getAttributeValue:(ODataXMLElements *)node varname:(NSString *)name;
-(NSMutableArray *)EnumeratLinks:(ODataXMLElements *)theElement parent:(id)parentObject;
-(void)retrieveServices:(ODataSVC *)service xmlDocument:(ODataXMLElements *)XMLDocument;
-(NSString *)retriveObjectValue:(id)object variablename:(NSString *)syndvarname complexvarname:(NSString *)complexvar;
-(XMLGenerator *)buildXMLSyndicateContent:(id) object methodtype:(const char *)methodtype;
-(NSString *)buildXMLFeedCustomizationContent:(id)object methodtype:(const char *)methodtype;
-(void)CheckAndProcessMediaLinkEntryData:(ODataXMLElements *)theElement  atomentryobject:(AtomEntry *)atomentry;
- (NSDictionary *)retriveSyndicationMapping;
-(void)storeObjectSyndicateProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement;
-(void)storeFeedCustomizationProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement;
-(XMLGenerator *)buildXMLAtomContentForAzure:(id) object;
-(XMLGenerator *)buildXMLAtomPropertiesForAzureTable:(id) object ;
-(NSString *)retriveObjectXMLValue:(id)object methodtype:(const char *)methodtype variablename:(NSString *)varname;
-(void)updateEntryObjects:(ODataXMLElements *)theElement resourceBox:(ResourceBox *)aResourceBox;
-(void)CheckAndProcessMediaLinkEntryData:(ODataXMLElements *)theElement  resourceBox:(ResourceBox *)resource;
-(NSString *) getErrorDetails:(ODataXMLElements *)theElement;
@end;
