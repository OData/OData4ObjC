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

#import "Dictionary.h"

@implementation Dictionary
@synthesize m_entries;

- (void) dealloc
{
	[self removeAll];
	[m_entries release];
	m_entries = nil;
	[super dealloc];
}

- (id) init
{
	if(self = [super init] )
	{
		self.m_entries = [[NSMutableDictionary alloc]init];
	}
	return self;
}

- (void) addObject:(ODataObject*)aKey value:(id) aValue
{
	NSString *strObjectID = nil;
	strObjectID = [aKey getObjectID];
		
	if(strObjectID)
	{
		if([m_entries objectForKey:strObjectID] != nil)
		{
			NSException *anException = [NSException exceptionWithName:@"Exception" reason:@"Key already exists" userInfo:nil];
			[anException raise];
		}
		
		Pair * pair = [[Pair alloc] initWithObject:aKey value:aValue];
		[m_entries setObject:pair forKey:strObjectID];
		[pair release];
	}
}
	
-(void) add:(id)aKey value:(id) aValue 
{
	NSString *strObjectID = nil;
	strObjectID = [aKey getObjectID];
	if(strObjectID)
	{
		if([m_entries objectForKey:strObjectID] != nil)
		{
			NSException *anException = [NSException exceptionWithName:@"Exception" reason:@"Key already exists" userInfo:nil];
			[anException raise];
		}
		
		Pair * pair = [[Pair alloc] initWithObject:aKey value:aValue];
		
		[m_entries setObject:pair forKey:strObjectID];
		[pair release];
	}
}
    
/** 
 * To remove an entry from dictionary
 * @param <object> $key The key object, Must be derived from Object
 * @returns <bool> TRUE: if $key exists, FALSE: if $key not exists
 *		
 */	

- (BOOL) remove:(id)aKey 
{
	NSString *strObjectID = nil;
	if (!([aKey respondsToSelector:@selector(getObjectID)]))
	{
		return NO;
	}
	
	strObjectID = [aKey getObjectID];

	
	if(strObjectID)
	{
		Pair *pair = [m_entries objectForKey:strObjectID];
		if ( pair != nil)
		{
			[m_entries removeObjectForKey:strObjectID];
			return YES;
		}
	}
    return NO;
}	
    
/**
 * To remove all entries from dictionary
 */
- (void) removeAll 
{
	[m_entries removeAllObjects];
}
    
/**
 * @param <object> $key
 * To check a particular key exists in the dictionary
 */
- (BOOL) containsKey:(id) aKey 
{
	
	NSString *strObjectID = nil;
	strObjectID = [aKey getObjectID];
	
	if(strObjectID)
	{
		if([m_entries objectForKey:strObjectID] != nil)
		{	
			return YES;
		}
	}
	return NO;
}

/*
 * 
 * @Returns <Object list>
 * To retrives collection of value objects
 */

- (NSArray*) values 
{
	NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:[m_entries count]];
	
	NSEnumerator *enumerator = [m_entries keyEnumerator];
	NSString* objectID;
	while(objectID = [ enumerator nextObject] )
	{
		Pair *pair = [m_entries objectForKey:objectID];
		if(pair)
		{
			[tmpArray addObject:[pair getValue]];
		}
	}
	return tmpArray;
}
   
   
/*
 * @Returns <Object list>
 * To retrives collection of key objects
 */

- (NSArray*) keys 
{
	NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:[m_entries count]];
	
	NSEnumerator *enumerator = [m_entries keyEnumerator];
	NSString* objectID;
	while(objectID = [ enumerator nextObject] )
	{
		Pair *pair = [m_entries objectForKey:objectID];
		if(pair)
		{
			[tmpArray addObject:[pair getKey]];
		}
	}
	return tmpArray;
}

/**
 * To get number of Key:Value pair in the Dictionary
 * @Return<integer>	 
 */    
   
- (NSUInteger) count 
{
	return [m_entries count];
}
    
/*
 * To retrives value corrosponding to a key object
 * @param <object> $key The key object, Must be derived from Object
 * @param <object> $value [OUT] The value object, will conatins the value corrosponding
 * to key on return
 * Returns <bool> TRUE: if $key exists,	FALSE: if $key not exists 
 */


- (id) tryGetValue:(id)aKey 
{
	
	NSObject* value=nil;
	
	NSString *strObjectID = nil;
	strObjectID = [aKey getObjectID];
	
	if(strObjectID)
	{
		if([m_entries objectForKey:strObjectID] != nil)
		{
			Pair *pair  = [m_entries objectForKey:strObjectID];
			if(pair)
				value = [pair getValue];
		}
	}
	return value;
}

///////////////////////////////////////////////////////////////////////////////
+ (NSMutableArray*)bubbleSortDictionaryByKeys:(NSDictionary*)dict
{
	//this method takes an NSDictionary and performs a basic bubblesort
	//on its keys. It then returns those ordered keys as an NSMutableArray.
	//You can then traverse the original NSDictionary and retrive its
	//ordered objects by simply stepping through each key in the NSMutableArray.
	
	if(!dict)
		return nil;
	NSMutableArray *sortedKeys = [NSMutableArray arrayWithArray: [dict allKeys]];
	if([sortedKeys count] <= 0)
		return nil;
	else if([sortedKeys count] == 1)
		return sortedKeys; //no sort needed
	
	//perform bubble sort on keys:
	int n = [sortedKeys count] -1;
	int i;
	BOOL swapped = YES;
	
	NSString *key1,*key2;
	NSComparisonResult result;
	
	while(swapped)
	{
		swapped = NO;
		for(i=0;i<n;i++)
		{
			key1 = [sortedKeys objectAtIndex: i];
			key2 = [sortedKeys objectAtIndex: i+1];
			
			//here is where we do our basic NSString comparison
			//This can be easily customized.
			//See the options for -compare: in NSString docs
			result = [key1 compare: key2 options: NSCaseInsensitiveSearch];
			if(result == NSOrderedDescending)
			{
				//we retain for good form, but these
				//objects should still be safely
				//retained by the dictionary:
				[key1 retain];
				[key2 retain];
				
				//pop the two keys out of the array
				[sortedKeys removeObjectAtIndex: i]; // key1
				[sortedKeys removeObjectAtIndex: i]; // key2
				//replace them
				[sortedKeys insertObject: key1 atIndex: i];
				[sortedKeys insertObject: key2 atIndex: i];
				
				[key1 release];
				[key2 release];
				
				swapped = YES;
			}
		}
	}
	
	return sortedKeys;
}

- (NSMutableArray *) sortObjects
{
	
	NSMutableDictionary *sortedDictionary = [[NSMutableDictionary alloc]initWithCapacity:[m_entries count]];
	
	NSArray *keys;
	int i, count;
	id key, value;
	
	keys = [m_entries allKeys];
	count = [keys count];
	for (i = 0; i < count; i++)
	{
		key = [keys objectAtIndex: i];
		value = [m_entries objectForKey: key];
		
		Pair *val = value;
		[sortedDictionary setObject: value    
								   forKey:[NSNumber numberWithInt:[val.m_value getChangeOrder]-1]];
	}	
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	i = 0;
	count = 0;
	
	if([sortedDictionary count] == 0)
	{
		[sortedDictionary release];
		return [array autorelease];
	}
	
	while(1)
	{		
		Pair *objpair = [sortedDictionary objectForKey:[NSNumber numberWithInt:i]];
		if(objpair)
		{
			[array addObject:[objpair getValue]];	
			count++;
			if(count >= [m_entries count])
				break;
		}
		i++;
	}
	
	[sortedDictionary release];
	return [array autorelease];
}

///////////////////////////////////////////////////////////////////////////////
/* To Sort the dictionary 'values' based on any property of class representing
 * the value object.
 * @param <string> $propertyName The name of property used for sorting
 * @Returns No return value 
 */

- (void) sort:(NSString*) propertyName {
	
	NSMutableDictionary *sortedDictionary = [[NSMutableDictionary alloc]initWithCapacity:[m_entries count]];
	NSMutableArray *sortedKeys = [Dictionary bubbleSortDictionaryByKeys:m_entries];
	
	NSEnumerator *arrayEnum = [sortedKeys objectEnumerator];
    NSString *key = nil;
    while(key = [arrayEnum nextObject])
    {
		Pair *pair = [m_entries objectForKey:key];
		if(pair)
		{
			[sortedDictionary setObject:pair forKey:key];
		}
	}
	
	[m_entries release];
	m_entries = nil;
	[self setEntries:[sortedDictionary autorelease]];
}
    
/*
 * To get the index of a key in the dictionary
 * @param <object> $key The key whose index to be returned
 * Returns<integer> index: if $key exists, -1: if $key not exists 
 */

- (NSInteger) findEntry: (id) aKey {

        return -1;
}


/*
 * To get a value based on index
 * @param integer $index The index of value to be returned
 * Returns:
 *		valueobject: if index is with in the range
 * Will throw exception if index is out of boundary
 */

- (ODataEntity*) getAt:(NSInteger) anIndex {

	return nil;
}
    

/**
 * @param <Dictionary> $dictionary1
 * @param <Dictionary> $dictionary2
 * @param <string> propertyName
 * @param <anyType> $propertyValue
 * @patam <bool> $condition
 * This function will merge two dictionaries. If $propertyName and $propertyValue  specified
 * then the merged result will only contains <key Value> pairs, where value of $propertyName
 * of each Value will be eual or not equal to $propertyValue baed on $condition
 */

+ (Dictionary*) Merge:(Dictionary*) aDictionary1 dictionary2:(Dictionary*) aDictionary2 propertyName:(NSString*) aPropertyName propertyValue:(NSInteger) aPropertyValue condition:(BOOL) aCondition 
{
	NSMutableDictionary *dict1 = [aDictionary1 getEntries];
	NSMutableDictionary *dict2 = [aDictionary2 getEntries];
	Dictionary* newMergedDictionary = [[Dictionary alloc] init];
	if(dict1 == nil)
	{
		[newMergedDictionary setEntries:dict2];
		return [newMergedDictionary autorelease];
	}	
	else if(dict2 == nil )
	{
		[newMergedDictionary setEntries:dict1];
		return [newMergedDictionary autorelease];
	}
		
	NSMutableDictionary *mergedDictionary = [[NSMutableDictionary alloc] init];
	
	NSEnumerator *enumerator = [dict1 keyEnumerator];
	NSString* key;
	while(key = [ enumerator nextObject] )
	{
		Pair *pair = [dict1 objectForKey:key];
		if(pair)
		{
			if(![Dictionary canAdd:[pair getValue] propertyName:aPropertyName propertyValue:aPropertyValue condition:aCondition])
			{
				continue;
			}
			[mergedDictionary setObject:pair forKey:key];
		}
	}
	
	enumerator = [dict2 keyEnumerator];
	
	while(key = [ enumerator nextObject] )
	{
		Pair *pair = [dict2 objectForKey:key];
		if(pair)
		{
			if(![Dictionary canAdd:[pair getValue] propertyName:aPropertyName propertyValue:aPropertyValue condition:aCondition])
			{
				continue;
			}
			[mergedDictionary setObject:pair forKey:key];
		}
	}
	
	[newMergedDictionary setEntries:mergedDictionary];
	[mergedDictionary release];
	
	return [newMergedDictionary autorelease];
}
    
/**
 * @param <anyType> value
 * @param <string> propertyName
 * @param <anyType> $propertyValue
 * @patam <bool> $condition
 * Tests a value can be added to merged dictionary
 */
+ (BOOL) canAdd:(ODataEntity*) anODataEntity propertyName: (NSString*) aPropertyName propertyValue:(NSInteger) aPropertyValue condition:(BOOL) aCondition {
	
	NSInteger state = [anODataEntity getState];
	if( ( (aCondition == YES) && (state != aPropertyValue)) || ( (aCondition == NO) && (state == aPropertyValue)))
	{
		return NO;
	}
	return YES;
}
		
@end