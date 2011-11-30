
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


#import "ODataSVC.h"


@implementation ODataCollection
@synthesize m_href , m_title;

- (void) dealloc
{
	[m_href release];
	m_href = nil;
	[m_title release];
	m_title = nil;
	[super dealloc];
}

- (id) initWithHref:(NSString*)aHref title:(NSString*)aTitle
{
	if(self = [super init])
	{
		if(aHref)
			[self setHref:aHref];
		else
			[self setHref:[NSString stringWithString:@""]];
		if(aTitle)
			[self setTitle:aTitle];
		else
			[self setTitle:[NSString stringWithString:@""]];
	}
	return self;
}

@end

@implementation ODataWorkspace
@synthesize m_title , m_collections;

- (void) dealloc
{
	[m_title release];
	m_title = nil;
	[m_collections release];
	m_collections = nil;
	[super dealloc];
}

- (id) initWithTitle:(NSString*)aTitle collections:(NSMutableDictionary*)theCollections
{
	if(self = [super init])
	{
		if(aTitle)
			[self setTitle:aTitle];
		else
			[self setTitle:[NSString stringWithString:@""]];
		
		if(theCollections)
			[self setCollections:theCollections];
		else
			[self setCollections:[[[NSMutableDictionary alloc]init]autorelease]];
			
	}
	return self;
}

- (ODataCollection*) getCollection:(NSString*)aHref
{
	ODataCollection *collection = nil;
	
	if(aHref)
	{
		collection = [m_collections objectForKey:aHref];
	}
	return collection;
}

@end

@implementation ODataSVC
@synthesize m_baseUrl , m_workspaces;

- (void) dealloc
{
	[m_baseUrl release];
	m_baseUrl = nil;
	[m_workspaces release];
	m_workspaces = nil;
	[super dealloc];
}

- (id) initWithUrl:(NSString*)anUrl workspaces:(NSMutableDictionary*)theWorkspaces
{
	if(self = [super init])
	{
		if(anUrl)
			[self setBaseUrl:anUrl];
		else
			[self setBaseUrl:[NSString stringWithString:@""]];
		
		if(theWorkspaces)
			[self setWorkspaces:theWorkspaces];
		else
			[self setWorkspaces:[[[NSMutableDictionary alloc]init]autorelease]];
	}
	return self;
}

- (ODataWorkspace*) getWorkspace:(NSString*)aTitle;
{
	ODataWorkspace *workspace = nil;
	
	if(aTitle)
	{
		workspace = [m_workspaces objectForKey:aTitle];
	}
	return workspace;
}

@end




