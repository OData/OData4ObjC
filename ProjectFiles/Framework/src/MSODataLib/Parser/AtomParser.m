
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


#import "AtomParser.h"
#import "ObjectContext.h"
#import "Utility.h"
#import "AtomEntry.h"
#import "QueryOperationResponse.h"
#import "XMLGenerator.h"
#import "ODataBool.h"
#import "ODataSVC.h"
#import "ODataXMLElements.h"
#import "ODataXMlParser.h"
#import "ResourceBox.h"
#import "ODataRTTI.h"
#import "XMLBuilder.h"
#import "TableEntry.h"

@implementation AtomParser

@synthesize m_objectContext,m_nextLinkUrl,m_queryResponseObject;


-(id)init
{
	return [self initwithContext:nil];
}


-(id)initwithContext:(ObjectContext *)context
{
	
	if(self = [super init])
	{
		self.m_objectContext = context;
	}
	return self;	
}


	/*
	 * Retrive edit link value
	 * @param ODataXMLElements XML element
	 * return NSString
	 */
-(NSString *)getEditLink:(ODataXMLElements *)theElement
{
	NSString *editlink = nil;
	
	NSMutableArray *links = [[NSMutableArray alloc]init];
	
	[theElement saveElementsForName:@"link" inArray:links];
	
	int linkcount = [links count];
	int i =0;
	for(i=0;i<linkcount;i++)
	{
		ODataXMLElements *element = [links objectAtIndex:i];
		NSString *nextlink = [self getAttributeValue:element varname:@"rel"];
		
		if([nextlink isEqualToString:@"edit"])
		{
			editlink = [self getAttributeValue:element varname:@"href"];			
		}
	}
	[links release];
	return editlink;
}

/*
 * Store XML value in class Object
 * @param ODataXMLElements XML element
 * @param ResourceBox containing Object
 * return NULL
 */
-(void)updateEntryObjects:(ODataXMLElements *)theElement resourceBox:(ResourceBox *)aResourceBox
{
	NSString *type = [theElement getName];
	
	if([type isEqualToString:@"entry"])
	{
		id obj = nil;
		NSString *editLink = [self getEditLink:theElement];
		
		if(editLink == nil)
			return;
				
		if(aResourceBox)
			obj = [aResourceBox getResource];
		else
		{
			return;
		}
				
		if(obj != nil)
		{
			
			//Azure
			if(![[[m_objectContext getCredentials] getCredentialType] isEqualToString:@"AZURE"])
			{		
				[self storeFeedCustomizationProperties:obj xmlelement:theElement];
				[self storeObjectSyndicateProperties:obj xmlelement:theElement];
			}
			NSString *propertiesNS = [theElement getPropertiesNameSpace];
			
			if(propertiesNS != nil)
				[obj setEtag:[self getAttributeValue:theElement varname:[NSString stringWithFormat:@"%@:etag",propertiesNS]]];
			else
				[obj setEtag:[self getAttributeValue:theElement varname:@"m:etag"]];
			
			[aResourceBox setEditLink:editLink];	
			[self storeObjectProperties:obj xmlelement:theElement];
		}
		else
			return;		
	}
}

/*
 * Enumerate and Parse XML elements 
 * @param ODataXMLElements XML element
 * @param id class instance of ObjectContext
 * @param id class instance of QueryOperationResponse
 * return NULL
 */
-(void)EnumerateObjects:(ODataXMLElements *)XMLDocument queryResponseObject:(id)queryResponse
{
	//Get type of document
	NSString *type = [XMLDocument getName];
	NSMutableArray *entries = nil;
	
	m_queryResponseObject = queryResponse; 

	NSMutableArray *inlineCount = [[NSMutableArray alloc]init];
	NSString *propertiesNS = [XMLDocument getPropertiesNameSpace];

	if(propertiesNS != nil)
	{
		[XMLDocument saveElementsForName:[NSString stringWithFormat:@"%@:count",propertiesNS] inArray:inlineCount];
	}
	else
	{
		[XMLDocument saveElementsForName:@"m:count" inArray:inlineCount];
	}
	
	if([inlineCount count] > 0)
	{
		[m_queryResponseObject setInlineCountValue:[[[inlineCount objectAtIndex:0] getStringValue] intValue]];
	}
	else
		[m_queryResponseObject setInlineCountValue:-1];

	[inlineCount release];
	
	NSString *atomFeed;
	NSString *atomEntry;
	NSString *atomError;
	
	NSString *atomNS = [XMLDocument getAtomNameSpace];
	if(atomNS){
		atomFeed = [NSString stringWithFormat:@"%@:feed",atomNS];
		atomEntry = [NSString stringWithFormat:@"%@:entry",atomNS];
		atomError = [NSString stringWithFormat:@"%@:error",atomNS];
	}else{
		atomFeed=@"feed";
		atomEntry=@"entry";
		atomError=@"error";
	}
	if([type isEqualToString:atomFeed])
	{
		entries = [[self EnumerateFeeds:XMLDocument parent:nil] retain];
		
		//Initialize the array when odata response contain o entries/feed.
		if (!entries) {
			entries = [[NSMutableArray alloc] initWithCapacity:0];
		}
	}
	else if([type isEqualToString:atomEntry])
	{
		entries = [[NSMutableArray alloc] init] ;
		id object = [self EnumerateEntry:XMLDocument parent:nil];
		[entries addObject:object];	
	}
	
	if([type isEqualToString:atomError])
	{
		NSString *errorDescription=[self getErrorDetails:XMLDocument];
		[m_queryResponseObject setInnerException:errorDescription];
	}
	
	[m_queryResponseObject setCountValue:[entries count]];
	[m_queryResponseObject setResult:entries];
	[entries release];
	
	[m_queryResponseObject setObjectIDToNextLinkUrl:m_nextLinkUrl];
}
-(NSString *) getErrorDetails:(ODataXMLElements *)theElement
{	
	NSMutableArray *array = [[NSMutableArray alloc]init];
	NSString *atomNS = [theElement getAtomNameSpace];
	if(atomNS)
		[theElement  saveElementsForName:[NSString stringWithFormat:@"%@:message",atomNS] inArray:array];
	else
		[theElement  saveElementsForName:@"message" inArray:array];
	
	
	if([array count]!=0)
	{
		ODataXMLElements *errorElement=[array objectAtIndex:0];
		NSString *errorDetail=[errorElement getStringValue];
		[array release];
		return errorDetail;
	}
	else
	{
		[array release];
		return nil;
	}
}

/*
 * Enumerate and Parse XML elements 
 * @param ODataSVC OData service information
 * @param ODataXMLElements XML element
 * return NULL
 */
-(void)retrieveServices:(ODataSVC *)service xmlDocument:(ODataXMLElements *)XMLDocument
{
	NSString *type = [XMLDocument  getName];
	if([type isEqualToString:@"service"])
	{
		
		ODataXMLElements *element = XMLDocument;
		NSString *baseUrl = [self getAttributeValue:element varname:@"xml:base"];
		[service setBaseUrl:baseUrl];
		NSMutableDictionary *workspaces = [[NSMutableDictionary alloc] init];
		
		NSMutableArray *array = [[NSMutableArray alloc]init];
		[element saveElementsForName:@"workspace" inArray:array];

		
		for(int i=0;i<[array count];i++)
		{
			
			ODataXMLElements *workspacenode = [array objectAtIndex:i];
						
			//get workspace title
			
			NSMutableArray *workspacetitles = [[NSMutableArray alloc]init];
			[workspacenode saveElementsForName:@"atom:title" inArray:workspacetitles];
			
			NSString *title = nil;
			if([workspacetitles count] > 0)
				title = [[workspacetitles objectAtIndex:0] getStringValue];
			
			//get collections
			
			NSMutableArray *collections = [[NSMutableArray alloc]init];
			[workspacenode saveElementsForName:@"collection" inArray:collections];
			
			NSMutableDictionary *collecionsDict = [[NSMutableDictionary alloc] init];
			for(int j=0;j<[collections count];j++)
			{
				//get collection href
				ODataXMLElements *collectionnode = [collections objectAtIndex:j];
				NSString *href = [self getAttributeValue:collectionnode varname:@"href"];
				
				//get collection title
				
				NSMutableArray *titles = [[NSMutableArray alloc]init];
				[collectionnode saveElementsForName:@"atom:title" inArray:titles];
				
				NSString *collectiontitle = nil;
				
				if([titles count] >0)
					collectiontitle = [[titles objectAtIndex:0] getStringValue];
				
				ODataCollection *collection = [[ODataCollection alloc] initWithHref:href title:collectiontitle];
				
				if(collectiontitle)
					[collecionsDict setObject:collection forKey:collectiontitle];
				
				[collection release];
				[titles release];
			}		
			
			ODataWorkspace *workspaceobject = [[ODataWorkspace alloc] initWithTitle:title collections:collecionsDict];
			if(title)
				[workspaces setObject:workspaceobject forKey:title ];
			[collecionsDict release];
			[workspaceobject release];
			[workspacetitles release];
			[collections release];
		}
		[service setWorkspaces:workspaces];
		[workspaces release];
		[array release];
	}
}


/*
 * Enumerate Feed elements from XML 
 * @param ODataXMLElements XML element
 * @param id class instance of parent ODataXMLElements
 * return NSMutableArray
 */
-(NSMutableArray *)EnumerateFeeds:(ODataXMLElements *)theElement parent:(id)parentObject
{
	NSMutableArray *entries = [[NSMutableArray alloc]init];
	
	NSString * atomEntry;
	NSString *atomNS = [theElement getAtomNameSpace];
	if(atomNS)
		atomEntry = [NSString stringWithFormat:@"%@:entry",atomNS];
	else
		atomEntry=@"entry";
	
	[theElement saveElementsForName:atomEntry inArray:entries];
	
	int count = [entries count];
	NSMutableArray *class_objects = nil;
	id firstobject = nil;
    
	for(int i =0;i<count;i++)
	{		
		id entry = [self EnumerateEntry:[entries objectAtIndex:i] parent:parentObject];
		if(entry != nil)
		{
			if(class_objects == nil)
				class_objects = [[NSMutableArray alloc] init];
			[class_objects addObject:entry];
		}
		
		if(i==0)
			firstobject = entry;
	}
	
	if(firstobject != nil)
	{
		// fetch next link
		NSMutableArray *links = [[NSMutableArray alloc]init];
		
		NSString * atomLink;
		if(atomNS)
			atomLink = [NSString stringWithFormat:@"%@:link",atomNS];
		else
			atomLink=@"link";
		[theElement saveElementsForName:atomLink inArray:links];
		
		int linkcount = [links count];
	
		int i =0;
		for(i=0;i<linkcount;i++)
		{
			ODataXMLElements *element = [links objectAtIndex:i];
			NSString *nextlink = [self getAttributeValue:element varname:@"rel"];
		
			if([nextlink isEqualToString:@"next"])
			{
				NSString *nextURL = [self getAttributeValue:element varname:@"href"];
				if(nextURL != nil)
				{
					if(parentObject == nil)
					{
						if(m_nextLinkUrl == nil)
						{
							[self setNextLinkUrl:[[[NSMutableDictionary alloc] init] autorelease]];
						}
						[m_nextLinkUrl setObject:nextURL forKey:@"0"];
					}
					else
					{
						if(m_nextLinkUrl == nil)
						{
							[self setNextLinkUrl:[[[NSMutableDictionary alloc] init] autorelease]];
							[m_nextLinkUrl setObject:@"" forKey:@"0"];				
						}
						if(firstobject)
							[m_nextLinkUrl setObject: nextURL forKey: [firstobject getObjectID]]; 
					}
				}
			}
		}
		[links release];
	}
	[entries release];
	
	return [class_objects autorelease];
}


/*
 * Enumerate Entry elements from XML 
 * @param ODataXMLElements XML element
 * @param id class instance of parent ODataXMLElements
 * return id
 */
-(id)EnumerateEntry:(ODataXMLElements *)theElement parent:(id)parentObject
{
	NSString * entityType=nil;
	NSMutableArray *array = [[NSMutableArray alloc]init];
	
	NSString * atomId;
	NSString *atomNS=[theElement getAtomNameSpace];
	if(atomNS)
		atomId = [NSString stringWithFormat:@"%@:id",atomNS];
	else
		atomId=@"id";
	[theElement saveElementsForName:atomId inArray:array];
	
	ODataXMLElements *element = nil;
	
	if([array count] > 0)
		element = [array objectAtIndex:0];

	//retrieve class name
	[array release];
	
	array = [[NSMutableArray alloc]init];
	
	NSString *atomCategory;
	if(atomNS)
		atomCategory=[NSString stringWithFormat:@"%@:category",atomNS];
	else
		atomCategory=@"category";
	[theElement saveElementsForName:atomCategory inArray:array];
	
	if([array count] > 0)
	{
		ODataXMLElements *element1 = [array objectAtIndex:0];
		NSString* str=[self getAttributeValue:element1 varname:@"term"];		
		NSRange r=[str rangeOfString:@"." options:NSBackwardsSearch];
			
		if([[[m_objectContext getCredentials] getCredentialType] isEqualToString:@"AZURE"])
			entityType=[str substringFromIndex:r.location+1];
		else
			entityType=[NSString stringWithFormat:@"%@_%@",[[m_objectContext getServiceNamespace]stringByReplacingOccurrencesOfString:@"." withString:@"_"],[str substringFromIndex:r.location+1]];
	}
	else 
	{
		NSString * entitySet = [Utility getEntitySetFromUrl:[element getStringValue]];
		
		if([[[m_objectContext getCredentials] getCredentialType] isEqualToString:@"AZURE"])
			entityType=[m_objectContext getEntityTypeNameFromSet:entitySet];
		else
			entityType=[NSString stringWithFormat:@"%@_%@",[[m_objectContext getServiceNamespace]stringByReplacingOccurrencesOfString:@"." withString:@"_"],[m_objectContext getEntityTypeNameFromSet:entitySet]];
		
	}
	[array release];

	//get class object
	AtomEntry *atomentry = [[AtomEntry alloc] init];
	[atomentry setIdentity:[element getStringValue]];
	
	[self CheckAndProcessMediaLinkEntryData:theElement atomentryobject:atomentry];
	
	id classObject = [m_objectContext addToObjectToResource:entityType atomEntry:atomentry];
	
	[atomentry release];
	
	if(classObject == nil)
	{
		return nil;
	}
	
	[self storeObjectProperties:classObject xmlelement:theElement];
	
	//etag handling
	NSString *propertiesNS = [theElement getPropertiesNameSpace];
	NSString *etag = nil;
	
	if(propertiesNS != nil)
		etag =[self getAttributeValue:theElement varname:[NSString stringWithFormat:@"%@:etag",propertiesNS]];
	else
		etag = [self getAttributeValue:theElement varname:@"m:etag"];
	
	[[ODataRTTI getObjectInstanceVariable:classObject variablename:@"m_OData_etag"] autorelease];
	
	[ODataRTTI setObjectInstanceVariable:classObject varname:@"m_OData_etag" varval:etag];
		
	//Azure
	if(![[[m_objectContext getCredentials] getCredentialType] isEqualToString:@"AZURE"])
	{
		//set properties for class objects
	
		[self storeFeedCustomizationProperties:classObject xmlelement:theElement];	
		[self storeObjectSyndicateProperties:classObject xmlelement:theElement];
	
		if (parentObject != nil)
		{
			[m_objectContext addToBindings:parentObject sourcePropertyName:entityType targetObject:classObject];		
		}
	
		//parse the relational links for retriving inline nodes
		NSString *atomLink;
		NSMutableArray *links = [[NSMutableArray alloc]init];
		if(atomNS)
			atomLink = [NSString stringWithFormat:@"%@:link",atomNS];
		else
			atomLink=@"link";
		[theElement saveElementsForName:atomLink inArray:links];
		
		int count = [links count];
		for(int i =0;i<count;i++)
		{
			ODataXMLElements *element = [links objectAtIndex:i];
		
			//set child nodes to parent object
			NSMutableArray *inline_entries = [self EnumeratLinks:element parent:classObject];
			if(inline_entries)
			{
				NSString *href = [self getAttributeValue:element varname:@"href"];
				NSString * entitySet = [Utility getEntitySetFromUrl:href];
				NSString *navigatorproperty = [NSString stringWithFormat: @"m_%@", entitySet];
				[[ODataRTTI getObjectInstanceVariable:classObject variablename:navigatorproperty] autorelease];
				
				[ODataRTTI setObjectInstanceVariable:classObject varname:navigatorproperty value:[inline_entries retain]];
			}
		}
		[links release];
	}

	return classObject;
}


/*
 * Parse MediaLink elements from XML 
 * @param ODataXMLElements XML element
 * @param id class instance of AtomEntry
 * return NULL
 */
-(void)CheckAndProcessMediaLinkEntryData:(ODataXMLElements *)theElement  atomentryobject:(AtomEntry *)atomentry
{
	atomentry.m_editMediaLink = nil;
	atomentry.m_mediaLinkEntry = NO;
	atomentry.m_mediaContentUri = nil;
	atomentry.m_streamETag = nil;	
	//parse the relational links for retriving inline nodes
	
	NSMutableArray *links = [[NSMutableArray alloc]init];
	
	NSString * atomLink;
	NSString *atomNS = [theElement getAtomNameSpace];
	if(atomNS)
		atomLink = [NSString stringWithFormat:@"%@:link",atomNS];
	else
		atomLink=@"link";
	[theElement saveElementsForName:atomLink inArray:links];
	
	int count = [links count];
	for(int i =0;i<count;i++)
	{
		ODataXMLElements *element = [links objectAtIndex:i];
		NSString *attributename = [self getAttributeValue:element varname:@"rel"];
		if([attributename isEqualToString:@"edit-media"])
		{
			atomentry.m_editMediaLink = [self getAttributeValue:element varname:@"href"];
			
			NSString *propertiesNS = [theElement getPropertiesNameSpace];
			
			if(propertiesNS != nil)
				atomentry.m_streamETag = [self getAttributeValue:element varname:[NSString stringWithFormat:@"%@:etag",propertiesNS]];
			else
				atomentry.m_streamETag = [self getAttributeValue:element varname:@"m:etag"];
			
			atomentry.m_mediaLinkEntry = YES;
		}	
	}
	[links release];
	
	if(atomentry.m_mediaLinkEntry)
	{
		NSMutableArray *content = [[NSMutableArray alloc]init];
	
		NSString * atomContent;
		if(atomNS)
			atomContent = [NSString stringWithFormat:@"%@:content",atomNS];
		else
			atomContent=@"content";
		[theElement saveElementsForName:atomContent inArray:content];
		
		
		count = [content count];
		for(int i =0;i<count;i++)
		{
			ODataXMLElements *element = [content objectAtIndex:i];
			NSString *attributename = [self getAttributeValue:element varname:@"src"];
			atomentry.m_mediaContentUri = attributename;			
		}
		[content release];
	}
}

/*
 * Populate ResourceBox with MediaLink Enteries.
 * @param ODataXMLElements XML element
 * @param ResourceBox containing the class Object
 * return NULL
 */
-(void)CheckAndProcessMediaLinkEntryData:(ODataXMLElements *)theElement  resourceBox:(ResourceBox *)resource
{
	if(![[resource getResource] hasStream] || theElement == nil)
		return;
	[resource setEditMediaLink:nil];
	[resource setMediaLinkEntry:YES];
	[resource setStreamLink:nil];
	[resource setStreamETag:nil];
		
	NSString *propertiesNS = [theElement getPropertiesNameSpace];
	NSString *etag=nil;
	if(propertiesNS != nil)
		etag=[NSString stringWithFormat:@"%@:etag",propertiesNS];
	else
		etag=@"m:etag";
	
	[resource setEntityTag:[self getAttributeValue:theElement varname:etag]];
	
	id obj = [resource getResource];
	
	if(obj != nil)
		[obj setEtag:[self getAttributeValue:theElement varname:etag]];
	
	//parse the relational links for retriving inline nodes
	NSMutableArray *links = [[NSMutableArray alloc]init];
	[theElement saveElementsForName:@"link" inArray:links];
	
	int count = [links count];
	for(int i =0;i<count;i++)
	{
		ODataXMLElements *element = [links objectAtIndex:i];
		NSString *attributename = [self getAttributeValue:element varname:@"rel"];
		if([attributename isEqualToString:@"edit-media"])
		{
			[resource setStreamETag:[self getAttributeValue:element varname:etag]];
			[resource setEditMediaLink:[self getAttributeValue:element varname:@"href"]];
	
		}		
	}
	[links release];
	
	NSMutableArray *content = [[NSMutableArray alloc]init];
	[theElement saveElementsForName:@"content" inArray:content];
	
	count = [content count];
	for(int i =0;i<count;i++)
	{
		ODataXMLElements *element = [content objectAtIndex:i];
		NSString *attributename = [self getAttributeValue:element varname:@"src"];
		[resource setStreamLink:[self getAttributeValue:element varname:attributename]];			
	}
	[content release];
	
	NSMutableArray *editLink = [[NSMutableArray alloc]init];
	[theElement saveElementsForName:@"id" inArray:editLink];
	
	count = [editLink count];
	for(int i =0;i<count;i++)
	{
		ODataXMLElements *element = [editLink objectAtIndex:i];
		NSInteger index = [Utility reverseFind:[element getStringValue] findString:@"/"];
		if(index != -1)
		{			
			[resource setEditLink:[[element getStringValue] substringFromIndex:(index + 1)]];
		}		
	}
	[editLink release];
	
	[self storeObjectSyndicateProperties:[resource getResource] xmlelement:theElement];
	[self storeFeedCustomizationProperties:[resource getResource] xmlelement:theElement];
	[self storeObjectProperties:[resource getResource] xmlelement:theElement];
}


/*
 * Parse Link tags from XML
 * @param ODataXMLElements XML element
 * @param id class instance of parent ODataXMLElements
 * return NSMutableArray
 */
-(NSMutableArray *)EnumeratLinks:(ODataXMLElements *)theElement  parent:(id)parentObject
{
	NSString *propertiesNS = [theElement getPropertiesNameSpace];
	NSMutableArray *array = [[NSMutableArray alloc]init];
	
	if(propertiesNS != nil)
	{
		[theElement saveElementsForName:[NSString stringWithFormat:@"%@:inline",propertiesNS] inArray:array];
	}
	else
	{
		[theElement saveElementsForName:@"m:inline" inArray:array];
	}
	
	if([array count] > 0)
	{
		ODataXMLElements *inline_element = [array objectAtIndex:0];
		
		NSArray *inline_childern = [inline_element getChildren];
		if([inline_childern count] == 0)
			return nil;
		ODataXMLElements *element = [inline_childern objectAtIndex:0];
		NSString *type = [element getName];
		if([type isEqualToString:@"feed"])
		{
			NSMutableArray *entries = [[self EnumerateFeeds:element parent:parentObject] retain];
			[array release];
			return [entries autorelease];
		}
		else if([type isEqualToString:@"entry"])
		{
			NSMutableArray *entries = [[NSMutableArray alloc] init];
			id object = [self EnumerateEntry:element parent:parentObject];
			[entries addObject:object];	
			[array release];
			return [entries autorelease];
		}
		[array release];
		return nil;
	}
	[array release];
	return nil;
}

/*
 * Store class Object value
 * @param id class Object
 * @param ODataXMLElement XML element
 * return NULL
 */
-(void)storeObjectProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement
{
	//Get property
	NSMutableArray *array = [[NSMutableArray alloc]init];
	
	NSString *atomContent;
	NSString *atomNS = [theElement getAtomNameSpace];
	if(atomNS)
		atomContent=[NSString stringWithFormat:@"%@:content",atomNS];  
	else
		atomContent=@"content";
	[theElement saveElementsForName:atomContent inArray:array];
	
	ODataXMLElements *element = nil;
	if([array count] > 0)
		element = [array objectAtIndex:0];
	

	NSArray *arrayelements = [element getChildren];
	NSArray *elementproperties = nil;
	int count = 0;

	if([arrayelements count] > 0)
	{
		ODataXMLElements *theNode1 = [arrayelements objectAtIndex:0];
		elementproperties = [theNode1 getChildren];
		count = [elementproperties count];
	}
	else
	{
		NSMutableArray *array = [[NSMutableArray alloc]init];
		
		NSString *propertiesNS = [theElement getPropertiesNameSpace];
		
		if(propertiesNS != nil)
		{
			[theElement saveElementsForName:[NSString stringWithFormat:@"%@:properties",propertiesNS] inArray:array];
		}
		else	
		{
			[theElement saveElementsForName:@"m:properties" inArray:array];
		}
		
		ODataXMLElements *element = nil;
		if([array count] > 0)
			element = [array objectAtIndex:0];
		
		elementproperties = [element getChildren];
        count = [elementproperties count];
		[array release];
	}
	
	for(int i=0;i<count;i++)
	{
		ODataXMLElements *theNode11 = [elementproperties objectAtIndex:i];
		NSString *variablename = [theNode11 getName];
		NSString *tag = [variablename substringWithRange:NSMakeRange(2, [variablename length]-2) ];
		tag = [@"m_" stringByAppendingString:tag];
		NSArray *classproperties = [theNode11 getChildren];
		if([classproperties count] == 0)
		{
			[[ODataRTTI getObjectInstanceVariable:dynamicObject variablename:tag] autorelease];
			[ODataRTTI setObjectInstanceVariable:dynamicObject varname:tag varval:[theNode11 getStringValue]];
		}
		else if([classproperties count] > 0)
		{
			mProperties *p=[dynamicObject getPropertiesFromPropertiesMap:tag];
			NSString *edmType=[p getEdmType];
			[self storeClassProperties:dynamicObject xmlelement:(ODataXMLElements *)theNode11 edmType:edmType];
		}
	}
	[array release];
	
}


/*
 * Store class Object syndication values 
 * @param id class Object
 * @param ODataXMLElement XML element
 * return NULL
 */
-(void)storeObjectSyndicateProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement
{
	NSArray *SyndicateKeys = [dynamicObject getSyndicateArray];
	NSDictionary *syndication_mapping = [self retriveSyndicationMapping];
	
	for(int i = 0;i<[SyndicateKeys count];i++)
	{
		NSString *varname = [SyndicateKeys objectAtIndex:i];
		NSString *value = nil;
			
		id prop = [dynamicObject getPropertiesFromPropertiesMap:varname];				
		if(prop == nil)
			continue;
		
		if([[prop getFC_TargetPath] isEqualToString:@""])
			continue;
		
		if(![[prop getFC_NsPrefix] isEqualToString:@""])
			continue;
		
		NSString *mapping = [syndication_mapping objectForKey:[prop getFC_TargetPath]];
		
		NSRange range = [mapping rangeOfString:@"/"];
		
		if(range.length == 0)
		{
			NSMutableArray *array = [[NSMutableArray alloc]init];
			NSString *atomNS = [theElement getAtomNameSpace];
			if(atomNS)
				[theElement saveElementsForName:[NSString stringWithFormat:@"%@:%@",atomNS,mapping] inArray:array];
			else
				[theElement saveElementsForName:mapping inArray:array];
			
			if([array count] > 0)
			{
				ODataXMLElements *element = [array objectAtIndex:0];
				value = [element getStringValue];
			}
			[array  release];
		}
		else
		{
			NSString *parent = [mapping substringWithRange:NSMakeRange(0,range.location)];
			NSString *children = [mapping substringWithRange:NSMakeRange(range.location + 1,[mapping length] - (range.location + 1))];
			
			NSMutableArray *array = [[NSMutableArray alloc]init];
			[theElement saveElementsForName:parent inArray:array];
			if([array count] > 0)
			{
				ODataXMLElements *element = [array objectAtIndex:0];
				
				NSMutableArray *elementproperties = [[NSMutableArray alloc]init];
				[element saveElementsForName:children inArray:elementproperties];
				if([elementproperties count] > 0)
				{
					value = [[elementproperties objectAtIndex:0] getStringValue];
				}
				[elementproperties release];
			}
			[array release];
		}
		
		if(value == nil)
			continue;
		//Source path
		NSString *sourcepathname = [prop getFC_SourcePath];
		if([[prop getFC_SourcePath] isEqualToString:@""])
		{
			[[ODataRTTI getObjectInstanceVariable:dynamicObject variablename:varname] autorelease];
	
			[ODataRTTI setObjectInstanceVariable:dynamicObject varname:varname varval:value];
		}
		else
		{			
			NSString *variablenameis = [NSString stringWithFormat:@"m_%@",sourcepathname];
			id classtype = [ODataRTTI getObjectInstanceVariable:dynamicObject variablename:varname];
			if(classtype == nil)
			{
				NSString *classname = [NSString stringWithFormat:@"%@",[varname substringFromIndex:2]];
				classtype = [[[NSClassFromString(classname) alloc] init] autorelease];
			}
			[[ODataRTTI getObjectInstanceVariable:classtype variablename:variablenameis] autorelease];
			
			[ODataRTTI setObjectInstanceVariable:classtype varname:variablenameis varval:value];
			
			[[ODataRTTI getObjectInstanceVariable:dynamicObject variablename:varname] autorelease];
			
			[ODataRTTI setObjectInstanceVariable:dynamicObject varname:varname value:[classtype retain]];			
		}
	}	
}

/*
 * Store class Object syndication values 
 * @param id class Object
 * @param ODataXMLElement XML element
 * return NULL
 */
-(void)storeFeedCustomizationProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement
{
	NSArray *SyndicateKeys = [dynamicObject getSyndicateArray];
	
	for(int i = 0;i<[SyndicateKeys count];i++)
	{
		NSString *varname = [SyndicateKeys objectAtIndex:i];
		NSString *value = nil;
		
		id prop = [dynamicObject getPropertiesFromPropertiesMap:varname];				
		if(prop == nil)
			continue;
		
		if([prop getFC_TargetPath]  || [[prop getFC_NsPrefix] isEqualToString:@""])
			continue;
		
		NSString *mapping = [prop getFC_TargetPath];
		NSString *prefix =[prop getFC_NsPrefix];
		NSRange range = [mapping rangeOfString:@"/"];
		
		if(range.length == 0)
		{
			NSString *tagname = [NSString stringWithFormat:@"%@:%@",prefix,mapping];
			
			NSMutableArray *array = [[NSMutableArray alloc]init];
			[theElement saveElementsForName:tagname inArray:array];
			
			if([array count] > 0)
			{
				ODataXMLElements *element = [array objectAtIndex:0];
				value = [element getStringValue];
			}
			[array release];			
		}
		else
		{
			NSString *parent = [mapping substringWithRange:NSMakeRange(0,range.location)];
			NSString *children = [mapping substringWithRange:NSMakeRange(range.location + 2,[mapping length] - (range.location  + 2))];
			parent = [NSString stringWithFormat:@"%@:%@",prefix,parent];
			children = [NSString stringWithFormat:@"%@:%@",prefix,children];

			NSMutableArray *array = [[NSMutableArray alloc]init];
			[theElement saveElementsForName:parent inArray:array];
			
			if([array count] > 0)
			{
				ODataXMLElements *element = [array objectAtIndex:0];
				value = [element attributeForName:children];		
			}
			[array release];
		}
		
		if(value == nil)
			continue;
		//Source path
		NSString *sourcepathname = [prop getFC_SourcePath];
		if([[prop getFC_SourcePath] isEqualToString:@""])
		{
			[[ODataRTTI getObjectInstanceVariable:dynamicObject variablename:varname] autorelease];
			
			[ODataRTTI setObjectInstanceVariable:dynamicObject varname:varname varval:value];
		}
		else
		{			
			NSString *variablenameis = [NSString stringWithFormat:@"m_%@",sourcepathname];
			id classtype = [ODataRTTI getObjectInstanceVariable:dynamicObject variablename:varname];
			if(classtype == nil)
			{
				NSString *classname = [NSString stringWithFormat:@"%@",[varname substringFromIndex:2]];
				classtype = [[[NSClassFromString(classname) alloc] init] autorelease];
			}
			[[ODataRTTI getObjectInstanceVariable:classtype variablename:variablenameis] autorelease];
			
			[ODataRTTI setObjectInstanceVariable:classtype varname:variablenameis varval:value];
			
			[[ODataRTTI getObjectInstanceVariable:dynamicObject variablename:varname] autorelease];
			
			[ODataRTTI setObjectInstanceVariable:dynamicObject varname:varname value:[classtype retain]];
		}
	}	
}


/*
 * Store class Object value
 * @param id class Object
 * @param ODataXMLElements XML element
 * return NULL
 */
-(void)storeClassProperties:(id)dynamicObject xmlelement:(ODataXMLElements *)theElement edmType:(NSString *)anEdmType
{
	NSString *variablename = [theElement getName];
	NSString *classname =nil;
	
	classname=[NSString stringWithFormat:@"%@",[anEdmType stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
	
	id classtype = [[NSClassFromString(classname) alloc] init];
	
	if(classtype == nil)
		return;
	
	NSArray *classproperties = [theElement getChildren];
	NSString *tag = nil;
	for(int i =0;i<[classproperties count];i++)
	{
		ODataXMLElements *theNode11 = [classproperties objectAtIndex:i];
		NSArray *nodeproperties = [theNode11 getChildren];
		if([nodeproperties count] == 0)
		{
			NSString *variablename = [theNode11 getName];
			tag = [variablename substringWithRange:NSMakeRange(2, [variablename length]-2) ];
			tag = [@"m_" stringByAppendingString:tag];	
			
			[[ODataRTTI getObjectInstanceVariable:classtype variablename:tag] autorelease];
			
			[ODataRTTI setObjectInstanceVariable:classtype varname:tag varval:[theNode11 getStringValue]];
		} // complex class type recursive yet to be tested
		else if([nodeproperties count] > 0)
		{
			mProperties *p=[dynamicObject getPropertiesFromPropertiesMap:tag];
			NSString *edmType=[p getEdmType];
			[self storeClassProperties:classtype xmlelement:(ODataXMLElements *)theNode11 edmType:edmType];
		}
	}
	tag = [variablename substringWithRange:NSMakeRange(2, [variablename length]-2) ];
	tag = [@"m_" stringByAppendingString:tag];	
	[[ODataRTTI getObjectInstanceVariable:dynamicObject variablename:tag] autorelease];
	
	[ODataRTTI setObjectInstanceVariable:dynamicObject varname:tag value:[classtype retain]];
	[classtype release];
}

/*
 * Store class Object value
 * @param ODataXMlElement XML element value
 * @param NSString member variable name
 * return NSString
 */
-(NSString *)getAttributeValue:(ODataXMLElements *)element varname:(NSString *)name
{
	return [element attributeForName:name];
}

/*
 * Parse and build OData XML from class Object
 * @param id class Object
 * @param char method type to use 
 * return NSString
 */
-(NSString *)buildXML:(id) object methodtype:(const char *)type
{
	XMLGenerator *xml=nil;
	//Azure
	if(![[[m_objectContext getCredentials] getCredentialType] isEqualToString:@"AZURE"])
	{
		xml = [[XMLGenerator alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<entry xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://www.w3.org/2005/Atom\">\n"];
		XMLGenerator *syndicationxml = [self buildXMLSyndicateContent:object methodtype:type];
		[xml addSingleValue:[syndicationxml XMLString]];
		[xml addSingleValue:@"<id />"];
		
		[xml addSingleValue:@"\n"];
		
		[xml addSingleValue:[NSString stringWithFormat:@"<category term=\"%@\" scheme=\"http://schemas.microsoft.com/ado/2007/08/dataservices/scheme\" />",[[[object class]description] stringByReplacingOccurrencesOfString:@"_" withString:@"."]]];
		
		[xml addSingleValue:@"\n"];
		XMLGenerator *content = [self buildXMLAtomContent:object  methodtype:type];
		
		if([object hasStream])
		{
			[xml addSingleValue:[content XMLString]];
		}
		else
		{
			[xml addTag:@"content" tagInnerstring:@"type=\"application/xml\"" tagValue:[content XMLString]];
		}		
		[xml addSingleValue:@"\n"];
		NSString *feed = [self buildXMLFeedCustomizationContent:object methodtype:type];
		if(![feed isEqualToString:@""])
		{
			[xml addSingleValue:feed];
			[xml addSingleValue:@"\n"];
		}
	}
	else
	{
		xml = [[XMLGenerator alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?><entry xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://www.w3.org/2005/Atom\"><title /><author>	<name />	</author>\n"];
		
		[xml addTagToXML:@"updated" withValue:[self retrieveTime]];
		[xml addSingleValue:@"<id />"];
		XMLGenerator *content = [self buildXMLAtomContentForAzure:object];
		[xml addTag:@"content" tagInnerstring:@"type=\"application/xml\"" tagValue:[content XMLString]];
	}
	[xml endSingleTag:@"entry"];
	
	NSString * str = [NSString stringWithFormat:@"%@",[xml XMLString]];
	[xml release];
	return str;
}

/*
 * Retrive collection of syndication mapping 
 * return NSDictionary
 */
- (NSDictionary *)retriveSyndicationMapping
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
	 @"author/email", @"SyndicationAuthorEmail", 
	 @"author/name", @"SyndicationAuthorName", 
	 @"author/uri", @"SyndicationAuthorUri",
	 @"contributor/email", @"SyndicationContributorEmail",
	 @"contributor/name", @"SyndicationContributorName",
	 @"contributor/uri", @"SyndicationContributorUri",
	 @"published", @"SyndicationPublished",
	 @"rights", @"SyndicationRights",
	 @"summary", @"SyndicationSummary",
	 @"title", @"SyndicationTitle",
	 @"updated", @"SyndicationUpdated",nil];
}


/*
 * Generate XML with syndication content
 * @param id class Object
 * @param char method type to use 
 * return XMLGenerator
 */
-(XMLGenerator *)buildXMLSyndicateContent:(id)object methodtype:(const char *)methodtype
{
	NSDictionary *syndication_mapping = [self retriveSyndicationMapping];
	
	NSArray *SyndicateKeys = [object getSyndicateArray];
	XMLGenerator *xml = [[XMLGenerator alloc] initWithString:@""];
	
	for(int j = [SyndicateKeys count] - 1 ; j>=0 ;j--)
	{
		NSString *syndvarname = [SyndicateKeys objectAtIndex:j];
		//get syndicate properties
		id prop = [object getPropertiesFromPropertiesMap:syndvarname];
		if(prop == nil)
			continue;
		
		if([[prop getFC_TargetPath] isEqualToString:@""] )
			continue;
		
		if(![[prop getFC_NsPrefix] isEqualToString:@""])
			continue;
		
		NSString *mapping = [syndication_mapping objectForKey:[prop getFC_TargetPath]];
		
		if(mapping == nil)
			continue;
		NSRange range = [mapping rangeOfString:@"/"];
		

		NSString *value = [self retriveObjectXMLValue:object methodtype:"update" variablename:syndvarname];
		if(![[prop getFC_SourcePath] isEqualToString:@""] )
		{
			value = [self retriveObjectValue:object variablename:syndvarname complexvarname:[prop getFC_SourcePath]];
		}
		if(value == nil)
		{
			value = @"";
		}
		
		if(range.length != 0)
		{
			NSString *parent = [mapping substringWithRange:NSMakeRange(0,range.location)];	
			NSString *child = [mapping substringWithRange:NSMakeRange(range.location +1, [mapping length] - (range.location + 1))];
			[xml addTag:parent childTag:child childtagValue:value];
		}
		else
		{
			if([mapping isEqualToString:@"updated"])
				value = [self retrieveTime];
			[xml addTagToXML:mapping  withValue:value];
		}
	}
	return [xml autorelease];
}



/*
 * Generate XML with syndication content
 * @param id class Object
 * @param char method type to use 
 * return XMLGenerator
 */
-(NSString *)buildXMLFeedCustomizationContent:(id)object methodtype:(const char *)methodtype
{
	NSArray *SyndicateKeys = [object getSyndicateArray];
	XMLBuilder *xmlbuilder = [[XMLBuilder alloc] init];
	
	for(int j = 0 ; j<[SyndicateKeys count];j++)
	{
		NSString *syndvarname = [SyndicateKeys objectAtIndex:j];
		//get syndicate properties
		id prop = [object getPropertiesFromPropertiesMap:syndvarname];
		if(prop == nil)
			continue;
		
		if([[prop getFC_TargetPath] isEqualToString:@""] || [[prop getFC_NsPrefix] isEqualToString:@""])
			continue;
		
		NSString *mapping = [prop getFC_TargetPath];
		NSString *prefix = [prop getFC_NsPrefix];
		
		if(mapping == nil)
			continue;
		
		NSRange range = [mapping rangeOfString:@"/"];
		
		NSString *value = [self retriveObjectXMLValue:object methodtype:"update" variablename:syndvarname];
		if(![[prop getFC_SourcePath] isEqualToString:@""] )
		{
			value = [self retriveObjectValue:object variablename:syndvarname complexvarname:[prop getFC_SourcePath]];
		}
		
		if(range.length != 0)
		{
			NSString *parent = [mapping substringWithRange:NSMakeRange(0,range.location)];
			NSString *children = [mapping substringWithRange:NSMakeRange(range.location +2, [mapping length] - (range.location + 2))];
			parent = [NSString stringWithFormat:@"%@:%@",prefix,parent];
			children = [NSString stringWithFormat:@"%@:%@",prefix,children];
			[xmlbuilder addXMLAttribute:parent attribute:children attributevalue:value];
		}
		else
		{
			NSString *parent = [NSString stringWithFormat:@"%@:%@",prefix,mapping];
			[xmlbuilder addParentNode:parent value:value];
			[xmlbuilder addXMLAttribute:parent attribute:@"xmlns:IPhone" attributevalue:@"http://iphone.persistent.co.in"];
		}	
	}
	NSString *str = [NSString stringWithFormat:@"%@",[xmlbuilder buildXML]];
	[xmlbuilder release];
	return str;
}


/*
 * Parse and build OData XML from class Object
 * @param id class Object
 * @param NSString syndication name
 * @param NSString variable name for custom class type
 * return NSString
 */
-(NSString *)retriveObjectValue:(id)object variablename:(NSString *)syndvarname complexvarname:(NSString *)complexvar
{	
	NSString *value = nil;
	ODataBool *isComplex = [[ODataBool alloc] init];
	
	value = [ODataRTTI getObjectInstanceVariableValue:object variablename:syndvarname isComplex:isComplex];
	if(isComplex.booleanvalue)
	{		
		if(complexvar == nil)
		{
			[isComplex release];
			return nil;
		}
		
		id classtype = [ODataRTTI getObjectInstanceVariable:object variablename:syndvarname];
		NSString *varname = [@"m_" stringByAppendingString:complexvar];
		value = [self retriveObjectValue:classtype variablename:varname complexvarname:nil];
	}
	[isComplex release];
	return value;
}

/*
 * Generate XML with member variable values
 * @param id class Object
 * @param char method type to use 
 * return XMLGenerator
 */
-(XMLGenerator *)buildXMLAtomPropertiesForAzureTable:(id) object 
{
	XMLGenerator *properties = [[XMLGenerator alloc] initWithString:@""];
	NSMutableArray *variablenames =[[NSMutableArray alloc]init];
	[ODataRTTI getAllVariableNames:object variableNamesArray:variablenames];

	NSString *value = nil;
	NSString *tagname = nil;
	
	for (int i=0; i<[variablenames count]; i++) 
	{		
		NSString *stringFromUTFString = [variablenames objectAtIndex:i];
		if([stringFromUTFString rangeOfString:@"m_OData_"].location == 0)
		{
			continue;
		}
		
		value = [self retriveObjectXMLValue:object methodtype:nil variablename:stringFromUTFString];
		tagname = [stringFromUTFString substringWithRange: NSMakeRange(2,[stringFromUTFString length]-2)];
		tagname = [ @"d:" stringByAppendingString:tagname];
		
		if(value)
		{
			[properties addTagToXML:tagname withValue:value];
			[properties addSingleValue:@"\n"];
		}
		else 
		{
			[properties addSelfClosedTag:tagname withInnerString:@"m:null=\"true\""];
			[properties addSingleValue:@"\n"];
		}
	}	
	[variablenames release];
	return [properties autorelease];
}

/*
 * Generate XML m:properties 
 * @param id class Object
 * @param char method type to use 
 * return XMLGenerator
 */
-(XMLGenerator *)buildXMLAtomContentForAzure:(id) object
{
	XMLGenerator *xml = [[XMLGenerator alloc] initWithString:@""];
	XMLGenerator *properties = [self buildXMLAtomPropertiesForAzureTable:object];
	[xml addSingleValue:@"\n"];
	[xml addTagToXML:@"m:properties" withValue:[properties XMLString]];
	[xml addSingleValue:@"\n"];
	return [xml autorelease];
}


/*
 * Generate XML m:properties 
 * @param id class Object
 * @param char method type to use 
 * return XMLGenerator
 */
-(XMLGenerator *)buildXMLAtomContent:(id) object methodtype:(const char *)methodtype
{
	XMLGenerator *xml = [[XMLGenerator alloc] initWithString:@""];
	XMLGenerator *properties = [self buildXMLAtomProperties:object  methodtype:methodtype];
	[xml addSingleValue:@"\n"];
	[xml addTagToXML:@"m:properties" withValue:[properties XMLString]];
	[xml addSingleValue:@"\n"];
	return [xml autorelease];
}


/*
 * Parse and build OData XML from class Object
 * @param id class Object
 * @param char method type to use 
 * @param char * name of instance variable
 * return NSString
 */
-(NSString *)retriveObjectXMLValue:(id)object methodtype:(const char *)methodtype variablename:(NSString *)varname
{
	NSString *value = nil;
	ODataBool *isComplex = [[ODataBool alloc] init];
	
	value = [ODataRTTI getObjectInstanceVariableValue:object variablename:varname isComplex:isComplex];
	if(isComplex.booleanvalue)
	{
		id classtype = [ODataRTTI getObjectInstanceVariable:object variablename:varname];
		value = [[self buildXMLAtomProperties:classtype methodtype:"complex"] XMLString];
	}
	[isComplex release];
	return value;
}


/*
 * Generate XML with member variable values
 * @param id class Object
 * @param char method type to use 
 * return XMLGenerator
 */
-(XMLGenerator *)buildXMLAtomProperties:(id) object methodtype:(const char *)methodtype
{
	XMLGenerator *properties = [[XMLGenerator alloc] initWithString:@""];
	NSMutableArray *variablenames = [[NSMutableArray alloc] init];
	[ODataRTTI getAllVariableNames:object variableNamesArray:variablenames];
	NSString *value = nil;
	NSString *tagname = nil;

	for (int i=0; i<[variablenames count]; i++) 
	{
		BOOL isNullable = YES;
		
		NSString *stringFromUTFString = [variablenames objectAtIndex:i];
		if([stringFromUTFString rangeOfString:@"m_OData_"].location == 0)
		{
			continue;
		}
		
		if(strcmp(methodtype,"complex")!=0)
		{
			id prop = [object getPropertiesFromPropertiesMap:stringFromUTFString];
			isNullable = [prop getNullable];	
			if([prop getFC_KeepInContent] == NO)
				continue;
		}
		

		value = [self retriveObjectXMLValue:object methodtype:methodtype variablename:stringFromUTFString];
		tagname = [stringFromUTFString substringWithRange: NSMakeRange(2,[stringFromUTFString length]-2)];
		tagname = [ @"d:" stringByAppendingString:tagname];
		
		if(value)
		{
			[properties addTagToXML:tagname withValue:value];
			[properties addSingleValue:@"\n"];
		}
		else 
		{
			[properties addSelfClosedTag:tagname withInnerString:@"m:null=\"true\""];
			[properties addSingleValue:@"\n"];
		}
	}	
	[variablenames release];
	return [properties autorelease];
}

/*
 * Build time stamp
 * return NSString
 */
-(NSString *)retrieveTime
{
	NSDate *dateTime = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	
	NSString *stringFromDate = [dateFormat stringFromDate:dateTime];
	[dateFormat release];
	return stringFromDate;
}

-(void)dealloc
{
	[m_nextLinkUrl release];
	m_nextLinkUrl = nil;
	
	[super dealloc];
}

@end
