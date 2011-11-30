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

#import "ClientType.h"
#import "ODataObject.h"

static NSMutableDictionary *m_cache = nil;

@implementation ClientType
@synthesize m_attributes ,				m_properties;
@synthesize m_navigationProperties ,	m_sortedEPMProperties;
@synthesize m_hasEPM;

+ (void) initialize
{
	m_cache = [[NSMutableDictionary alloc] init];
}

- (void) dealloc
{
	[m_attributes release];
	m_attributes = nil;
	
	[m_properties release];
	m_properties = nil;
	
	[m_navigationProperties release];
	m_navigationProperties = nil;
	
	[m_sortedEPMProperties release];
	m_sortedEPMProperties = nil;
	
	[super dealloc];
}

/**
 * Constructor
 */
- (id) initWithType:(NSString*)aType
{
	if(self = [super init])
	{
		[self setAttributes:[[[NSMutableDictionary alloc] init] autorelease]];
		[self setProperties:[[[NSMutableDictionary alloc] init] autorelease]];
		[self setNavigationProperties:[[[NSMutableDictionary alloc] init] autorelease]];
		[self setSortedEPMProperties:[[[NSMutableDictionary alloc] init] autorelease]];
	}
	return self;
}

/**
 * Create and returns ClientType object for an entity $type.
 */
+ (ClientType*) Create:(NSString*)aType
{
	ClientType* c = [m_cache objectForKey:aType];
	if(c == nil)
	{
		c = [[ClientType alloc] initWithType:aType];
		[m_cache setObject:c forKey:aType];
	}

	return c;
}

/**
 * Returns name of all entity properties of the entity represented by
 * this instance of ClientType. Note that this function returns all the
 * properties with @Type attribute equal to 'EntityProperty'
 */
- (NSArray*) getPropertiesKeys
{
	NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:[m_properties count]];
	
	NSEnumerator *enumerator = [m_properties keyEnumerator];
	NSString* key;
	while(key = [ enumerator nextObject] )
	{
		[tmpArray addObject:key];
	}
	return tmpArray;
}


/**
 * Returns Entity Property Objects which holds information about
 * property of the entity represented by this instance of ClientType.
 * Note that this function returns all the property Objects with
 * @Type attribute equal to 'EntityProperty'
 */
- (NSArray*) getPropertiesValues
{
	NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:[m_properties count]];
	
	NSEnumerator *enumerator = [m_properties keyEnumerator];
	NSString* key;
	while(key = [ enumerator nextObject] )
	{
		ODataObject *value = [m_properties objectForKey:key];
		if(value)
		{
			[tmpArray addObject:value];
		}
	}
	return tmpArray;
}


/**
 * @return <array<PropertyObject>>
 * Returns Non-EPM Property Objects. If $retrunKeepInContentProperties is true
 * the returned collection includes EPM property with FC_KeepInContent true.
 */
- (NSArray*) getRawNonEPMProperties:(BOOL)aReturnKeepInContentProperties
{
	return nil;
}
 

/**
 * Returns name of all Navigation properties of the entity represented by
 * this instance of ClientType. Note that this function returns all the
 * properties with @Type attribute equal to 'NavigationProperty'
 */
- (NSArray*) getNavigationPropertiesKeys
{
	NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:[m_navigationProperties count]];
	
	NSEnumerator *enumerator = [m_navigationProperties keyEnumerator];
	NSString* key;
	while(key = [ enumerator nextObject] )
	{
		[tmpArray addObject:key];
	}
	return tmpArray;
}

/**
 * Returns Property Objects which holds information about Navigation
 * property of the entity represented by this instance of ClientType.
 * Note that this function returns all the property Objects with
 * @Type attribute equal to 'NavigationProperty'
 */
- (NSArray*) getNavigationPropertiesValues
{
	NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:[m_navigationProperties count]];
	
	NSEnumerator *enumerator = [m_navigationProperties keyEnumerator];
	NSString* key;
	while(key = [ enumerator nextObject] )
	{
		ODataObject *value = [m_navigationProperties objectForKey:key];
		if(value)
		{
			[tmpArray addObject:value];
		}
	}
	return tmpArray;
}

/**
 * Returns all entity and navigation properties
 */
- (NSArray*) getAllProperties
{
	NSArray *arrayProperties = [self getPropertiesKeys];
	NSArray *arrayNavigationProperties = [self getNavigationPropertiesKeys];
	
	if(arrayProperties == nil)
		return arrayNavigationProperties;
	else if(arrayNavigationProperties == nil)
		return arrayProperties;
	
	NSArray *mergedArray = [arrayProperties  arrayByAddingObjectsFromArray:arrayNavigationProperties];
	return mergedArray;
}

/**
 * Returns Key Properties of entity represented by this instance of ClientType.
 */
 - (NSArray*) geyKeyProperties
{
	return [m_attributes objectForKey:@"key"];
}

@end
