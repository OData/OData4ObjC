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

#import "ODataObject.h"
#import "ODataEntity.h"
#import "Pair.h"

@interface Dictionary : NSObject
{
    /**
     * This array will hold the dictionary entries as Key-Value Pair
     * Dictionary::Key => Guid
     * Dictionary::Value => Entry(user_key, user_value)
     */
    NSMutableDictionary *m_entries;
}

@property ( nonatomic , retain , getter=getEntries , setter=setEntries ) NSMutableDictionary *m_entries;

- (id) init;

- (void) addObject:(ODataObject*)aKey value:(id) aValue;
- (void) add:(id)aKey value:(id) aValue;

- (BOOL) remove:(id)aKey;
- (BOOL) remove:(id)aKey;
- (void) removeAll;

- (BOOL) containsKey:(id) aKey;
- (NSArray*) values;
- (NSArray*) keys;
- (NSUInteger) count;
- (id) tryGetValue:(id)aKey;

- (void) sort:(NSString*) propertyName;
- (NSInteger) findEntry: (id) aKey;
- (id) getAt:(NSInteger) anIndex;

+ (Dictionary*) Merge:(Dictionary*) aDictionary1 dictionary2:(Dictionary*) aDictionary2 propertyName:(NSString*) aPropertyName propertyValue:(NSInteger) aPropertyValue condition:(BOOL) aCondition;
+ (BOOL) canAdd:(ODataEntity*) anODataEntity propertyName: (NSString*) aPropertyName propertyValue:(NSInteger) aPropertyValue condition:(BOOL) aCondition;
- (NSMutableArray *) sortObjects;

@end
