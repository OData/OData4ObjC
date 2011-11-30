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

@interface ClientType : NSObject
{
	NSMutableDictionary		*m_attributes;
    NSMutableDictionary		*m_properties;
    NSMutableDictionary		*m_navigationProperties;
    NSMutableDictionary		*m_sortedEPMProperties;
    BOOL					m_hasEPM;
}

@property ( nonatomic , retain , getter=getAttributes ,				setter=setAttributes			) NSMutableDictionary *m_attributes;
@property ( nonatomic , retain , getter=getProperties ,				setter=setProperties			) NSMutableDictionary *m_properties;
@property ( nonatomic , retain , getter=getNavigationProperties ,	setter=setNavigationProperties	) NSMutableDictionary *m_navigationProperties;
@property ( nonatomic , retain , getter=getRawSortedEPMProperties,	setter=setSortedEPMProperties	) NSMutableDictionary *m_sortedEPMProperties;
@property ( nonatomic , assign , getter=hasEPM ,					setter=setHasEPM				) BOOL m_hasEPM;

- (id) initWithType:(NSString*)aType;

- (NSArray*) getPropertiesKeys;
- (NSArray*) getPropertiesValues;
- (NSArray*) getRawNonEPMProperties:(BOOL)aReturnKeepInContentProperties;
- (NSArray*) getNavigationPropertiesKeys;
- (NSArray*) getNavigationPropertiesValues;
- (NSArray*) getAllProperties;
- (NSArray*) geyKeyProperties;


+ (ClientType*) Create:(NSString*)aType;

@end
