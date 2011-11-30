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


@interface ODataNameSpace : NSObject {
	NSString	*m_nameSpace;
	NSString	*m_nameSpaceURI;
	BOOL		m_isDataServiceNameSpace;
	BOOL		m_isPropertiesNameSpace;
	BOOL        m_isAtomNameSpace;
	
}

@property (nonatomic,retain,getter=getNameSpace,	setter=setNameSpace)	NSString *m_nameSpace;
@property (nonatomic,retain,getter=getNameSpaceURI,	setter=setNameSpaceURI)	NSString *m_nameSpaceURI;

-(id) initWithNameSpace:(NSString*) aNameSpace nameSpaceURI:(NSString*)aNameSpaceURI;
-(BOOL) isDataServiceNameSpace;
-(BOOL) isPropertiesNameSpace;
-(BOOL)isAtomNameSpace;
-(void) print;

@end
