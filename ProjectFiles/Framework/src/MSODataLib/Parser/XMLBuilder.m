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

#import "XMLBuilder.h"
#import "XMLGenerator.h"
#import "ODataXMLElements.h"

@implementation XMLBuilder

@synthesize xmlElements;

- (id) init
{
	if(self = [super init])
	{
		self.xmlElements = [[NSMutableArray alloc] init];
	}
	return self;
}


/**
 * Inserts XML element
 * @param NSString name of XML element
 * @param NSString value of XML element
 * return NULL
 */
-(void)addParentNode:(NSString *)name value:(NSString *)nodevalue  
{		
	if(name == nil)
		return;
	ODataXMLElements *pelement = [[ODataXMLElements alloc] init];
	pelement.m_name = name;
	pelement.m_stringValue = nodevalue;
	[xmlElements addObject:pelement];
	[pelement release];
}


/**
 * Insert attribute value for given XML element name
 * @param NSString name of XML element
 * @param NSString name of attribute
 * @param NSString value of attribute
 * return NULL
 */
-(void)addXMLAttribute:(NSString *)nodename attribute:(NSString *)attributename attributevalue:(NSString *)value  
{	
	
	if(attributename == nil)
		return;
	ODataXMLElements *element = [self retriveXMlElement:nodename];
	
	if(element == nil)
	{
		[self addParentNode:nodename value:nil];
		element = [self retriveXMlElement:nodename];
	}
	if(value == nil)
		value = @"";
	[element.m_attributes setObject:attributename forKey:value];
}


/**
 * Retrives XML element for given name
 * @param NSString name of XML element
 * return ODataXMLElement
 */
-(ODataXMLElements *)retriveXMlElement:(NSString *)nodename
{
	ODataXMLElements *element = nil;
	
	for(int i =0 ; i <[xmlElements count];i++)
	{
		ODataXMLElements *node = [xmlElements objectAtIndex:i];
		if([node.m_name isEqualToString:nodename])
		{
			element = node;
			break;
		}
	}
	return element;
}


/**
 * Build XML string
 * return NSString
 */
-(NSString *)buildXML
{
	XMLGenerator *xml = [[XMLGenerator alloc] initWithString:@""];
	for(int i =0 ; i <[xmlElements count];i++)
	{
		ODataXMLElements *node = [xmlElements objectAtIndex:i];
		NSString *nodename = node.m_name;
		NSString *nodevalue = node.m_stringValue;
		NSString *attributes = [self buildAttributes:node.m_attributes];
		if(nodevalue == nil)
			nodevalue = @"";
		[xml addTag:nodename tagInnerstring:attributes tagValue:nodevalue];			
	}
	
	NSString * str = [NSString stringWithFormat:@"%@",[xml XMLString]];
	[xml release];
	return str;
}


/**
 * Generate XML string for given attribute
 * @param NSMutableDictionary collecton of attributes
 * return NSString
 */
-(NSString *)buildAttributes:(NSMutableDictionary *)dict
{ 
	NSString *xmlstring = @"";
	NSArray *keys;
	int i, count;
	id key, value;
	
	keys = [dict allKeys];
	count = [keys count];
	for (i = 0; i < count; i++)
	{
		key = [keys objectAtIndex: i];
		value = [dict objectForKey: key];
		xmlstring = [NSString stringWithFormat:@"%@ %@=\"%@\" ",xmlstring,value,key];
	}
	return xmlstring;
}

-(void)dealloc
{
	[xmlElements release];
	xmlElements = nil;
	
	[super dealloc];
}

@end
