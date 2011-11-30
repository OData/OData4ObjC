
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


#import "ODataXMlParser.h"
#import "ODataXMLElements.h"
#import "ODataNameSpace.h"


@implementation ODataXMlParser

@synthesize xmlElements , rootElement, tempparentElement , parentElement;

-(id)init
{
	if(self = [super init])
	{		
		self.xmlElements = [[NSMutableArray alloc] init];
	}
	return self;	
}
/*
 * Returns collection of ODataXMLElement
 * return NSMutableArray
 */
-(NSMutableArray *)getArrayOfElements
{
	return xmlElements;
}

/*
 * Parse XML data
 * @param NSData XML data
 * return ODataXMLElements
 */
-(ODataXMLElements *)parseData:(NSData *)xmlDocument 
{	
	if([xmlDocument length])
	{
		NSXMLParser* xmlParser = nil;
		
		xmlParser=[[NSXMLParser alloc] initWithData:xmlDocument];
		if(xmlParser)
		{		
			[xmlParser setDelegate: self];
			[xmlParser parse];
			[xmlParser release];
		}
		if(rootElement)
			[xmlElements addObject:rootElement];
		return rootElement;
	}
	return nil;
}

/*
 * Delegate for NSXMLParser XML node start event
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	ODataXMLElements *element = [[ODataXMLElements alloc] init];
	[element setName:elementName];
	[element setAttributes :[NSMutableDictionary dictionaryWithDictionary:attributeDict]];
	
	[self addNameSpace:attributeDict inXMLDocument:element];
	
	if(rootElement == nil)
	{
		[self setRootElement:element];
		[rootElement setParentElement:nil];
		[self setParentElement:element];
	}
	else
	{
		NSMutableArray  *children = [parentElement getChildren];
		[children addObject:element];
		
		[element setParentElement:parentElement];
		if(parentElement == nil)
			[xmlElements addObject:element];
		
		[self setParentElement:element];
	}
	[element release];
}

/*
 * Delegate for NSXMLParser XML node end event
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self setParentElement:[parentElement getParentElement]];
}

/*
 * Delegate for NSXMLParser XML value event
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if([parentElement getStringValue] == nil)
	{
		[parentElement setStringValue:string];
	}
	else
	{
		[parentElement setStringValue:[[parentElement getStringValue] stringByAppendingString:string]];
	}
}

/*
 * Delegate for NSXMLParser end event
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}


/*
 * Delegate for NSXMLParser error
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"NSXMLParser : %@",[parseError localizedDescription]);	
}


-(void)dealloc
{
	[xmlElements release];
	xmlElements = nil;
	
	[rootElement release];
	rootElement = nil;
		
	[super dealloc];
}

-(void) addNameSpace:(NSDictionary *)attributeDict inXMLDocument:(ODataXMLElements*)theXMLDocument
{
		if(attributeDict)
		{
			NSInteger count = [attributeDict count];
			if(count > 0)
			{
				NSString *objects[count];
				NSString *keys[count];
				[attributeDict getObjects:(id*)&objects andKeys:(id*)&keys];
				NSString *xmlns=@"xmlns:";
				
				for (int i = 0; i < count; i++) 
				{
					NSString *str = keys[i];
					NSRange range=[[str lowercaseString] rangeOfString:xmlns];
					if(range.length > 0 )
					{
						NSString *strNameSpace = [str substringFromIndex:[xmlns length]];
						if(strNameSpace)
						{
							ODataNameSpace *odataNameSpace = [[ODataNameSpace alloc]initWithNameSpace:strNameSpace nameSpaceURI:objects[i]];
							[theXMLDocument setNameSpace:odataNameSpace];
							[odataNameSpace release];
						}						
					}					
				}
			}
		}
}

@end

