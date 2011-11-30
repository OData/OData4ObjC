
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


@interface HttpBatchResponse : NSObject 
{
	NSMutableArray *m_httpResponses;
    NSString *m_rawHttpBatchResponse;
    NSString *m_correctHttpLine;
    NSString *m_changesetBoundary;
}

@property(nonatomic, retain,getter=getHttpResponses,setter=setHttpResponses)NSMutableArray *m_httpResponses;
@property(nonatomic, retain,getter=getRawBatchResponse,setter=setRawBatchResponse)NSString *m_rawHttpBatchResponse;
@property(nonatomic, retain,getter=getCorrectHttpLine,setter=setCorrectHttpLine)NSString *m_correctHttpLine;
@property(nonatomic, retain,getter=getChangesetBoundary,setter=setChangesetBoundary) NSString *m_changesetBoundary;

-(id) initWithResponses:(NSArray *)httpResponses rawHttpBatchResponse:(NSString *)batchResponse
changesetBoundary:(NSString *)changesetBoundary;
+(HttpBatchResponse *) CreateBatchResponse:(NSString *)response;
+(NSString *) ExtractChangesetBoundary:(NSString *)body;
+(NSArray *) ExtractHttpResponses:(NSString *)response changesetBoundary:(NSString *)changeset;
@end
