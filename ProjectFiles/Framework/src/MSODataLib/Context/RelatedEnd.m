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



#import "RelatedEnd.h"

@implementation RelatedEnd
@synthesize m_sourceResource , m_sourceProperty , m_targetResource;

- (void) dealloc
{
	[m_sourceResource release];
	m_sourceResource = nil;
	
	[m_sourceProperty release];
	m_sourceProperty = nil;
	
	[m_targetResource release];
	m_targetResource = nil;
	
	[super dealloc];
}
-(id) initWithObject:(ODataObject*)aSourceResource sourceProperty:(NSString*) aSourceProperty targetResource:(ODataObject*)aTargetResource
{
	if(self = [super init])
	{
		[self setSourceResource:aSourceResource];
		[self setSourceProperty:aSourceProperty];
		[self setTargetResource:aTargetResource];
    }
	return self;
}
    
-(BOOL) isResource
{
        return NO;
}    

/**
 * @param <RelatedEnd> relatedEnd1
 * @param <RelatedEnd> relatedEnd2
 * @Return <bool> if both ends are equal else false     
 */
-(BOOL) isEquals:(RelatedEnd*) aRelatedEndObj1 relatedEndObj2:(RelatedEnd*) aRelatedEndObj2
{
	NSString * targetObjectID1	= [NSString stringWithString:@"00000000-0000-0000-0000-000000000000"];
	NSString * targetObjectID2  = [NSString stringWithString:@"00000000-0000-0000-0000-000000000000"];
	
	if([aRelatedEndObj1 getTargetResource] !=nil)
	{
		targetObjectID1 = [[aRelatedEndObj1 getTargetResource] getObjectID];
	}

	if([aRelatedEndObj2 getTargetResource] !=nil)
	{
		targetObjectID2 = [[aRelatedEndObj2 getTargetResource] getObjectID];
	}
	
	if (([[aRelatedEndObj1 getSourceResource] getObjectID ] == [[aRelatedEndObj2 getSourceResource] getObjectID]) &&
		([ targetObjectID1 isEqualToString:targetObjectID2] ) &&
		([ [ aRelatedEndObj1 getSourceProperty ] isEqualToString : [ aRelatedEndObj2 getSourceProperty] ]))
	{
		return YES;
	}
	return NO;
}

/**
 * @Returns <UniqueID>
 * Returns unique id associated with this RelatedEnd
 */
-(NSString*) getObjectID {
	NSString * targetObjectID = [NSString stringWithString:@"00000000-0000-0000-0000-000000000000"];

	if( m_targetResource != nil)
	{
		targetObjectID = [NSString stringWithString:[ m_targetResource getObjectID]];
	}
	
	NSString* tmp = [NSString stringWithFormat:@"%@_%@_%@",[m_sourceResource getObjectID], m_sourceProperty, targetObjectID];
	return tmp;
}   
@end
