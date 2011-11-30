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

#import "HTTPHeaders.h"


@implementation HTTPHeaders

@synthesize m_httpHeaders;

- (void) dealloc {
	
	[m_httpHeaders release];
	m_httpHeaders = nil;
	[super dealloc];
}

- (id) initWithHeaders:(NSDictionary*)aHeader 
{
	if(self = [super init])
	{
		m_httpHeaders = [[NSMutableDictionary alloc] initWithDictionary:aHeader];
	}
	return self;
}


- (void) Add:(id)key valuepair:(id)value
{
	if(key == nil || value == nil)
		return;
	[m_httpHeaders setObject: value        
			 forKey: key]; 
}


- (void) Remove:(id)key
{
	[m_httpHeaders removeObjectForKey: key];
}


- (BOOL) TryGetValue:(id)key valuepair:(id)value
{
	BOOL isValue = NO;
	
	id keyValue = [m_httpHeaders objectForKey: key];
	
	if(keyValue)
	{
		isValue =  YES;
		value = keyValue;
	}
	return isValue;
}


-(BOOL) HasKey:(id)key
{
	BOOL isValue = NO;
	
	id keyValue = [m_httpHeaders objectForKey: key];
	
	if(keyValue)
	{
		isValue =  YES;
	}
	return isValue;
}


- (NSArray *) GetAllKeys
{
	NSArray *keys = nil;	
	keys = [m_httpHeaders allKeys];
	return keys;
}


- (NSMutableDictionary *) GetAll
{
	return m_httpHeaders;
}


- (void) Clear
{
	[m_httpHeaders removeAllObjects];
}

- (void) CopyFrom:(NSMutableDictionary *)sourceHeaders
{
	[m_httpHeaders addEntriesFromDictionary:sourceHeaders];
}

@end
