
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
#import "ODataNameSpace.h"


@interface ODataXMLElements : NSObject 
{
	/*
	 * Stores the root ODataXMLElement
	 */
	ODataXMLElements *m_parentElement;
	
	/*
	 * Stores the name of current XML node 
	 */
	NSString *m_name;
	
	/*
	 * Stores the value of current XML node 
	 */
	NSString *m_stringValue;
	
	/*
	 * Stores collection of child ODataXMLElement's within the current XML node 
	 */
	NSMutableArray  *m_children;
	
	/*
	 * Stores collection of XML attribute
	 */
	NSMutableDictionary *m_attributes;
	
	/*
	 * Stores the current node's metadata and dataservice namespaces information
	 */
	NSMutableDictionary *m_nameSpaceMap;
}

@property(nonatomic,assign,getter=getParentElement,setter=setParentElement) ODataXMLElements *m_parentElement;
@property(nonatomic,retain,getter=getName,setter=setName) NSString *m_name;
@property(nonatomic,retain,getter=getStringValue,setter=setStringValue) NSString *m_stringValue;
@property(nonatomic,retain,getter=getChildren,setter=setChildren) NSMutableArray  *m_children;
@property(nonatomic,assign,getter=getAttributes,setter=setAttributes) NSMutableDictionary *m_attributes;
@property(nonatomic,retain,getter=getNameSpaceMap,setter=setNameSpaceMap) NSMutableDictionary *m_nameSpaceMap;

-(id)init;
-(NSArray *)elementsForName:(NSString *)elementName;
-(void) saveElementsForName:(NSString *)elementName inArray:(NSMutableArray*) anArray;
-(NSString *)attributeForName:(NSString *)attributeName;

-(void) setNameSpace:(ODataNameSpace *)anODataNameSpace;

-(void) getDataServiceNameSpaceByRef:(NSMutableString*) aNameSpaceByRef nameSpaceURIRef:(NSMutableString*)aNameSpaceURIByRef;
-(void) getPropertiesNameSpaceByRef:(NSMutableString*) aNameSpaceByRef nameSpaceURIRef:(NSMutableString*)aNameSpaceURIByRef;
-(void) getAtomNameSpaceByRef:(NSMutableString*) aNameSpaceByRef nameSpaceURIRef:(NSMutableString*)aNameSpaceURIByRef;

-(NSString*) getDataServiceNameSpace;
-(NSString*) getPropertiesNameSpace;
-(NSString*) getAtomNameSpace;
@end
