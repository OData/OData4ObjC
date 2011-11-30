
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


#import "ODataXMLElements.h"


@implementation ODataXMLElements

@synthesize m_parentElement,m_name,m_stringValue,m_children,m_attributes;
@synthesize m_nameSpaceMap;

-(id)init
{
	if(self = [super init])
	{
		
		[self setAttributes:[[[NSMutableDictionary alloc] init ] autorelease]];
		[self setChildren:[[[NSMutableArray alloc] init] autorelease]] ;
		[self setNameSpaceMap:[[[NSMutableDictionary alloc]init] autorelease]];
	}
	return self;
}
	/*
	 * Retrives collection of XML elements for a given XML tag name
	 * @param NSString name of the XML tag
	 * return NSArray
	 */
-(NSArray *)elementsForName:(NSString *)elementName
{
	NSMutableArray *elements = [[NSMutableArray  alloc]initWithCapacity:[m_children count]];
	
	for(int i =0;i<[m_children count];i++)
	{
			if([[[m_children objectAtIndex:i] getName] isEqualToString:elementName] )
			{
				[elements addObject:[m_children objectAtIndex:i]];
			}
	}
	if([elements count] == 0)
	{
		 [elements release];
		return nil;
	}
	
	return [elements autorelease];
}

-(void) saveElementsForName:(NSString *)elementName inArray:(NSMutableArray*) anArray
{
	for(int i =0;i<[m_children count];i++)
	{
		if([[[m_children objectAtIndex:i] getName] isEqualToString:elementName] )
		{
			[anArray addObject:[m_children objectAtIndex:i]];
		}
	}
}

/*
 * Retrives XML attribute value for a given XML tag name
 * @param NSString name of the XML attribute
 * return NSString
 */
-(NSString *)attributeForName:(NSString *)attributeName
{
	NSString *value = [m_attributes objectForKey: attributeName];
	return value;
}

-(void)dealloc
{
	[m_nameSpaceMap release];
	m_nameSpaceMap = nil;

	[m_name release];
	m_name = nil;
	
	[m_stringValue release];
	m_stringValue = nil;
	
	[m_children release];
	m_children = nil;
	
	[super dealloc];
}

-(void) setNameSpace:(ODataNameSpace *)anODataNameSpace
{
	if(anODataNameSpace)
	{
		NSString *aNameSpace = [anODataNameSpace getNameSpace];
		[m_nameSpaceMap setObject:anODataNameSpace forKey:aNameSpace];
	}
}

-(void) getDataServiceNameSpaceByRef:(NSMutableString*) aNameSpaceByRef nameSpaceURIRef:(NSMutableString*)aNameSpaceURIByRef
{
	NSEnumerator *enumerator = [m_nameSpaceMap objectEnumerator];
	ODataNameSpace *odataNameSpace = nil;
		
	while ((odataNameSpace = [enumerator nextObject])) 
	{
		if(odataNameSpace)
		{
			if([odataNameSpace isDataServiceNameSpace])				
			{
				aNameSpaceByRef		= [NSMutableString stringWithString:[odataNameSpace getNameSpace]];
				aNameSpaceURIByRef  = [NSMutableString stringWithString:[odataNameSpace getNameSpaceURI]];
				break;
			}
		}
	}
	
	if( aNameSpaceByRef ==nil && m_parentElement)
	{
		[m_parentElement getDataServiceNameSpaceByRef:aNameSpaceByRef nameSpaceURIRef:aNameSpaceURIByRef];
	}
}

-(void) getPropertiesNameSpaceByRef:(NSMutableString*) aNameSpaceByRef nameSpaceURIRef:(NSMutableString*)aNameSpaceURIByRef
{
	NSEnumerator *enumerator = [m_nameSpaceMap objectEnumerator];
	ODataNameSpace *odataNameSpace = nil;
		
	while ((odataNameSpace = [enumerator nextObject])) 
	{
		if(odataNameSpace)
		{
			if([odataNameSpace isPropertiesNameSpace])
			{
				aNameSpaceByRef		= [NSMutableString stringWithString:[odataNameSpace getNameSpace]];
				aNameSpaceURIByRef  = [NSMutableString stringWithString:[odataNameSpace getNameSpaceURI]];

				break;
			}
		}
	}
	
	if( aNameSpaceByRef ==nil && m_parentElement)
	{
		[m_parentElement getPropertiesNameSpaceByRef:aNameSpaceByRef nameSpaceURIRef:aNameSpaceURIByRef];
	}
	
}
-(void) getAtomNameSpaceByRef:(NSMutableString*) aNameSpaceByRef nameSpaceURIRef:(NSMutableString*)aNameSpaceURIByRef
{
	NSEnumerator *enumerator = [m_nameSpaceMap objectEnumerator];
	ODataNameSpace *odataNameSpace = nil;
	
	while ((odataNameSpace = [enumerator nextObject])) 
	{
		if(odataNameSpace)
		{
			if([odataNameSpace isAtomNameSpace])
			{
				aNameSpaceByRef		= [NSMutableString stringWithString:[odataNameSpace getNameSpace]];
				aNameSpaceURIByRef  = [NSMutableString stringWithString:[odataNameSpace getNameSpaceURI]];
				
				break;
			}
		}
	}
	
	if( aNameSpaceByRef ==nil && m_parentElement)
	{
		[m_parentElement getAtomNameSpaceByRef:aNameSpaceByRef nameSpaceURIRef:aNameSpaceURIByRef];
	}
	
}


-(NSString*) getDataServiceNameSpace
{
	NSEnumerator *enumerator = [m_nameSpaceMap objectEnumerator];
	ODataNameSpace *odataNameSpace = nil;
	NSString *str = nil;
	
	while ((odataNameSpace = [enumerator nextObject])) 
	{
		if(odataNameSpace)
		{
			if([odataNameSpace isDataServiceNameSpace])				
			{
				str		= [odataNameSpace getNameSpace];
				break;
			}
		}
	}
	
	if( str ==nil && m_parentElement)
	{
		str = [m_parentElement getDataServiceNameSpace];
	}

	return str;
}

-(NSString*) getPropertiesNameSpace
{
	NSEnumerator *enumerator = [m_nameSpaceMap objectEnumerator];
	ODataNameSpace *odataNameSpace = nil;
	NSString *str = nil;
	
	while ((odataNameSpace = [enumerator nextObject])) 
	{
		if(odataNameSpace)
		{
			if([odataNameSpace isPropertiesNameSpace])
			{
				str		= [odataNameSpace getNameSpace];
				break;
			}
		}
	}
	
	if( str ==nil && m_parentElement)
	{
		str = [m_parentElement getPropertiesNameSpace];
	}

	return str;
}
-(NSString*) getAtomNameSpace
{
	NSEnumerator *enumerator = [m_nameSpaceMap objectEnumerator];
	ODataNameSpace *odataNameSpace = nil;
	NSString *str = nil;
	
	while ((odataNameSpace = [enumerator nextObject])) 
	{
		if(odataNameSpace)
		{
			if([odataNameSpace isAtomNameSpace])
			{
				str		= [odataNameSpace getNameSpace];
				break;
			}
		}
	}
	
	if( str ==nil && m_parentElement)
	{
		str = [m_parentElement getAtomNameSpace];
	}
	
	return str;
}
@end
