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


@interface HTTPHeaders : NSObject 
{
	NSMutableDictionary *m_httpHeaders;
}

- (id) initWithHeaders:(NSDictionary*)aHeader; 
- (void) Add:(id)key valuepair:(id)value;
- (void) Remove:(id)key;
- (BOOL) TryGetValue:(id)key valuepair:(id)value;
- (BOOL) HasKey:(id)key;
- (NSArray *) GetAllKeys;
- (NSMutableDictionary *) GetAll;
- (void) Clear;
- (void) CopyFrom:(NSMutableDictionary *)sourceHeaders;

@end
