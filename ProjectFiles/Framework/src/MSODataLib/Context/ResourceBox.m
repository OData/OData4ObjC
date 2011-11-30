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


#import "ResourceBox.h"
#import "Utility.h"

@implementation ResourceBox
@synthesize m_editLink , m_identity;
@synthesize m_relatedLinkCount , m_resource;
@synthesize m_editMediaLink , m_mediaLinkEntry;
@synthesize m_streamETag , m_entityTag;
@synthesize m_streamLink , m_saveStream; 

- (void) dealloc
{
	[m_identity release];
	m_identity = nil;
	
	[m_editLink release];
	m_editLink = nil;
	
	[m_resource release];
	m_resource = nil;
	
	[m_editMediaLink release];
	m_editMediaLink = nil;
	
	[m_streamETag release];
	m_streamETag = nil;
	
	[m_streamLink release];
	m_streamLink = nil;
	
	[m_saveStream release];
	m_saveStream = nil;
	
	[m_headers release];
	m_headers = nil;
	
	[super dealloc];
}

-(id) initWithIdentity:(NSString*)anIdentity editLink:(NSString*) anEditLink resource:(ODataObject*) anResource
{
	if(self = [super init])
	{
		if(anIdentity)	[self setIdentity:[NSString stringWithString:anIdentity]];
		if(anEditLink)	[self setEditLink:[NSString stringWithString:anEditLink]];
		[self setResource:anResource];
		
		self.m_editMediaLink = nil;
        self.m_mediaLinkEntry = NO;
        self.m_streamETag = nil;
        self.m_streamLink = nil;
        self.m_saveStream = nil;
        m_headers = [[NSMutableDictionary alloc]init];
    }
	return self;
}

-(BOOL) isResource
{
	return YES;
}    


-(NSString*) getResourceUri:(NSString*) aBaseUriWithSlash tragetResourceBox:(ResourceBox *)aResourceBox
{
	
	if(!aBaseUriWithSlash) return nil;
	
	NSString * resourceUri = nil; 
	
	resourceUri = [self getResourceUri:aBaseUriWithSlash];
	
	if(aResourceBox != nil)
	{
	resourceUri = [resourceUri stringByAppendingString:[NSString stringWithFormat:@"/$links/%@",[aResourceBox getResourceUri:@""]]];
	}
	
	return resourceUri;
}


-(NSString*) getResourceUri:(NSString*) aBaseUriWithSlash
{
	
	if(!aBaseUriWithSlash) return nil;
	
	NSString * resourceUri = nil; 
	
	if(!m_editLink) 
	{
		resourceUri = [NSString stringWithString:aBaseUriWithSlash];
	}
	else
	{
		resourceUri = [aBaseUriWithSlash stringByAppendingString:m_editLink];  
	}
	
	return resourceUri;
}
    
/**
  *Check current m_resource is participating in the binding represented by
  *related
  */
-(BOOL) isRelatedEntity:(RelatedEnd*)anRelatedEndObj
{
	if(!m_resource || !anRelatedEndObj) return NO;
	
    if ([m_resource getObjectID] == [[anRelatedEndObj getSourceResource] getObjectID])
	{
		return YES;
	}
    
	return NO;
}

/**
 *
 * @param <uri> baseUriWithSlash The service uri
 * @return <uri> The media m_resource uri if it exists
 */
-(NSString*) getMediaResourceUri:(NSString*) aBaseUriWithSlash
{
	if(m_streamLink)
    {
		//Seems the m_streamLink value ie value of href attribute of Content
        //node is absolute, if its relative we should append the
        //baseurl (after removing .svc part) with m_streamLink
        return m_streamLink;
	}
    return nil;
}

/**
 *
 * @param <Uri> baseUriWithSlash
 * @return <Uri>
 * Returns Edit-Media m_resource Uri
 */
-(NSString*) getEditMediaResourceUri:(NSString*) aBaseUriWithSlash
{
	if(m_editMediaLink != nil)
    {            
		return [aBaseUriWithSlash stringByAppendingString:m_editMediaLink];
	}
    return [aBaseUriWithSlash stringByAppendingString:m_editLink];
}

-(void) setHeaders:(NSDictionary*)aHeaders
{
	[m_headers removeAllObjects];
	m_headers = nil;
	if(aHeaders && [aHeaders count] > 0 )
	{
		m_headers = [NSMutableDictionary dictionaryWithDictionary:aHeaders];
	}
}

- (NSDictionary*) getHeaders
{
	return m_headers;
}

@end
