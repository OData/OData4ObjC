
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


@interface XMLGenerator : NSObject {
	
	/*
	 * Stores XML string
	 */
	NSMutableString *XMLString;
	
}

@property(nonatomic,retain) NSMutableString *XMLString;

-(id)initDefaultAtomHeader;
-(id)initWithString:(NSString *)xmlstring;
-(void)addTagToXML:(NSString *)tag withValue:(NSString *)value;
-(void)addSelfClosedTag:(NSString *)tag withInnerValueTitle:(NSString *)innerValueTitle andValue:(NSString *)value;
-(void)addSelfClosedTag:(NSString *)tag withInnerString:(NSString *)innerString;
-(void)addSelfClosedTag:(NSString *)tag;
-(void)addSingleTag:(NSString *)tag withInnerString:(NSString *)innerString;
-(void)addSingleValue:(NSString *)value;
-(void)addSingleTag:(NSString *)tag;
-(void)endSingleTag:(NSString *)tag;
-(void)addTag:(NSString *)tagname tagInnerstring:(NSString *)taginval tagValue:(NSString *)tagval;
-(void)addTag:(NSString *)parenttagname childTag:(NSString *)childtagname childtagValue:(NSString *)tagval;

@end
