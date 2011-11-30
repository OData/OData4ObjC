
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


#import <Foundation/Foundation.h>

@interface  ODataCollection : NSObject
{
	NSString *m_href;
	NSString *m_title;
}

@property ( nonatomic , retain , getter=getHref, setter= setHref ) NSString * m_href;
@property ( nonatomic , retain , getter=getTitle, setter= setTitle ) NSString * m_title;

- (id) initWithHref:(NSString*)aHref title:(NSString*)aTitle;

@end

@interface ODataWorkspace : NSObject
{
	NSString *m_title;
	NSMutableDictionary *m_collections;
}

@property ( nonatomic , retain , getter=getTitle, setter= setTitle ) NSString * m_title;
@property ( nonatomic , retain , getter=getCollections , setter=setCollections ) NSMutableDictionary * m_collections;

- (id) initWithTitle:(NSString*)aTitle collections:(NSMutableDictionary*)theCollections;
- (ODataCollection*) getCollection:(NSString*)aHref;

@end

@interface ODataSVC : NSObject
{
	NSString *m_baseUrl;
	NSMutableDictionary *m_workspaces;
}

@property ( nonatomic , retain , getter=getBaseUrl , setter= setBaseUrl ) NSString *m_baseUrl;
@property ( nonatomic , retain , getter=getWorkspaces , setter=setWorkspaces ) NSMutableDictionary *m_workspaces;

- (id) initWithUrl:(NSString*)anUrl workspaces:(NSMutableDictionary*)theWorkspaces;
- (ODataWorkspace*) getWorkspace:(NSString*)aTitle;

@end




