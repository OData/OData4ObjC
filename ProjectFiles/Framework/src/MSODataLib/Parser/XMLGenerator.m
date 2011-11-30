
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


#import "XMLGenerator.h"


@implementation XMLGenerator


@synthesize XMLString;

/*
 * Initializes XMLGenerator class
 * returns Id
 */
-(id)initDefaultAtomHeader{
	if(self = [super init])
		XMLString = [[NSMutableString alloc] initWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"];
	return self;
}

/*
 * Initializes XMLGenerator class with given string
 * @param NSString
 * returns Id
 */
-(id)initWithString:(NSString *)xmlstring
{
	if(self = [super init])
	{
		if(![xmlstring isEqualToString:@""])
			XMLString = [[NSMutableString alloc] initWithString:xmlstring];
		else
			XMLString = [[NSMutableString alloc] initWithString:@""];
	}
	return self;
}

/*
 * Adds tag value pair in the XML
 * @param NSString tag name
 * @param NSString XML value
 * returns NULL
 */
-(void)addTagToXML:(NSString *)tag withValue:(NSString *)value{
	[XMLString appendFormat:@"<%@>%@</%@>",tag,value,tag];
}

/*
 * Adds tag value pair in the XML
 * @param NSString tag name
 * @param NSString XML value
 * returns NULL
 */
-(void)addSelfClosedTag:(NSString *)tag withInnerValueTitle:(NSString *)innerValueTitle andValue:(NSString *)value{
	[XMLString appendFormat:@"<%@ %@=%@ />",tag,innerValueTitle,value];
}

/*
 * Adds tag value pair in the XML along with inner string
 * @param NSString tag name
 * @param NSString XML value
 * returns NULL
 */
-(void)addSelfClosedTag:(NSString *)tag withInnerString:(NSString *)innerString{
	[XMLString appendFormat:@"<%@ %@ />",tag,innerString];
}

/*
 * Adds tag in the XML 
 * @param NSString tag name
 * returns NULL
 */
-(void)addSelfClosedTag:(NSString *)tag {
	[XMLString appendFormat:@"<%@/>",tag];
}

/*
 * Adds tag in the XML along with inner string
 * @param NSString tag name
 * returns NULL
 */
-(void)addSingleTag:(NSString *)tag withInnerString:(NSString *)innerString{
	[XMLString appendFormat:@"<%@ %@ >",tag,innerString];
}

/*
 * Adds a single value in the XML 
 * @param NSString tag name
 * returns NULL
 */
-(void)addSingleValue:(NSString *)value{
	[XMLString appendFormat:@"%@",value];
}

/*
 * Adds a single tag in the XML 
 * @param NSString tag name
 * returns NULL
 */
-(void)addSingleTag:(NSString *)tag{
	[XMLString appendFormat:@"<%@>",tag];
}

/*
 * Adds a single closing tag in the XML 
 * @param NSString tag name
 * returns NULL
 */
-(void)endSingleTag:(NSString *)tag{
	[XMLString appendFormat:@"</%@>",tag];
}

/*
 * Adds a tag value pair in the XML along with inner string
 * @param NSString tag name
 * returns NULL
 */
-(void)addTag:(NSString *)tagname tagInnerstring:(NSString *)taginval tagValue:(NSString *)tagval
{
	[XMLString appendFormat:@"<%@ %@ >%@</%@>",tagname,taginval,tagval,tagname];
}

/*
 * Adds a tag value pair in the XML along with inner string
 * @param NSString tag name
 * returns NULL
 */
-(void)addTag:(NSString *)parenttagname childTag:(NSString *)childtagname childtagValue:(NSString *)tagval
{
	[XMLString appendFormat:@"<%@><%@>%@</%@></%@>",parenttagname,childtagname,tagval,childtagname,parenttagname];
}


-(void)dealloc
{
	[XMLString release];
	XMLString = nil;
	
	[super dealloc];
}

@end
