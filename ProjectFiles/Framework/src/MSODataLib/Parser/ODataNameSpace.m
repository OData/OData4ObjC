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

#import "ODataNameSpace.h"

static NSString * strDataServiceNameSpace=@"dataservices";
static NSString * strPropertiesNameSpace=@"dataservices/metadata";
static NSString * strAtomNameSpace=@"Atom";

@implementation ODataNameSpace
@synthesize m_nameSpace, m_nameSpaceURI;

-(void) dealloc
{
	[m_nameSpace release];
	m_nameSpace = nil;
	
	[m_nameSpaceURI release];
	m_nameSpaceURI = nil;
	
	[super dealloc];
}

-(id) initWithNameSpace:(NSString*) aNameSpace nameSpaceURI:(NSString*)aNameSpaceURI
{
	if(self=[super init])
	{
		[self setNameSpace:aNameSpace];
		[self setNameSpaceURI:aNameSpaceURI];
		
		if(m_nameSpace != nil)
		{
			if([m_nameSpaceURI hasSuffix:strDataServiceNameSpace])
				m_isDataServiceNameSpace=YES;
			else 
				m_isDataServiceNameSpace=NO;
			
			if([m_nameSpaceURI hasSuffix:strPropertiesNameSpace])
				m_isPropertiesNameSpace=YES;
			else
				m_isPropertiesNameSpace=NO;
			if ([m_nameSpaceURI hasSuffix:strAtomNameSpace]) {
				m_isAtomNameSpace=YES;
			}
			else
				m_isAtomNameSpace=NO; 
		}
	}
	return self;
}

-(BOOL) isDataServiceNameSpace
{
	return m_isDataServiceNameSpace;
}

-(BOOL) isPropertiesNameSpace
{
	return m_isPropertiesNameSpace;
}
-(BOOL)isAtomNameSpace
{
	return m_isAtomNameSpace;
}

-(void) print
{
	NSLog(@"namespace = %@ , uri = %@",m_nameSpace,m_nameSpaceURI);
}

@end
