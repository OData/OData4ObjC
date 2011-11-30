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

#import "TableEntry.h"


@implementation TableEntry


@synthesize m_OData_obectID;
@synthesize m_PartitionKey;
@synthesize m_RowKey;
@synthesize m_Timestamp;

-(void) dealloc
{
	[m_OData_obectID release];
	m_OData_obectID = nil;
	
	[m_PartitionKey release];
	m_PartitionKey = nil;
	
	[m_RowKey release];
	m_RowKey = nil;
	
	[m_Timestamp release];
	m_Timestamp = nil;
	
	[super dealloc];
}

-(id) initWithUri:(NSString *)anUri
{
	if(self=[super init])
	{
		[super setBaseURI:anUri];
		[self setTimestamp:@"1900-01-01T00:00:00"];
		[self setObjectID:[ODataGUID GetNewGuid]];
	}
	return self;
}

@end
