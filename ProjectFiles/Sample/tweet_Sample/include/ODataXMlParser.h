
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

@class ODataXMLElements;

@interface ODataXMlParser : NSObject 
{
	
	/*
	 * Stores the current ODataXMLElement
	 */
	ODataXMLElements *currentElement;
	
	/*
	 * Stores the root ODataXMLElement
	 */
	ODataXMLElements *parentElement;
	
	/*
	 * Stores the ODataXMLElement
	 */
	ODataXMLElements *tempparentElement;
	
	/*
	 * Stores collection of ODataXMLElement
	 */
	NSMutableArray   *xmlElements;
}


@property(nonatomic,retain) ODataXMLElements *currentElement;
@property(nonatomic,retain) ODataXMLElements *parentElement;
@property(nonatomic,retain) ODataXMLElements *tempparentElement;
@property(nonatomic,retain) NSMutableArray   *xmlElements;

-(id)init;
-(ODataXMLElements *)parseData:(NSData *)xmlDocument;
-(NSMutableArray *)getArrayOfElements;

@end
