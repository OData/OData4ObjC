
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


@interface ODataXMLElements : NSObject 
{
	/*
	 * Stores the root ODataXMLElement
	 */
	ODataXMLElements *parentElement;
	
	/*
	 * Stores the name of current XML node 
	 */
	NSString *name;
	
	/*
	 * Stores the value of current XML node 
	 */
	NSString *stringValue;
	
	/*
	 * Stores collection of child ODataXMLElement's within the current XML node 
	 */
	NSMutableArray  *children;
	
	/*
	 * Stores collection of XML attribute
	 */
	NSMutableDictionary *attributes;
}

@property(nonatomic,retain) ODataXMLElements *parentElement;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *stringValue;
@property(nonatomic,retain) NSMutableArray  *children;
@property(nonatomic,retain) NSMutableDictionary *attributes;

-(id)init;
-(NSArray *)elementsForName:(NSString *)elementName;
-(NSString *)attributeForName:(NSString *)attributeName;
@end
