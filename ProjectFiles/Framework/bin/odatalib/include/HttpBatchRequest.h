
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

@class HttpRequest;
@class ObjectContext;
@class HttpBatchResponse;

@interface HttpBatchRequest : NSObject 
{
	HttpRequest *m_httpRequest;
	ObjectContext *m_context;
}

@property (nonatomic, retain,getter=getHTTPRequest, setter=setHTTPRequest)HttpRequest *m_httpRequest;
@property (nonatomic, assign,getter=getContext, setter=setContext)ObjectContext *m_context;

-(id)initWithUri:(NSString *)uri batchBoundary:(NSString *)batchBounds batchRequestBody:(NSString *)body 
	   credentials:(id)credential batchHeaders:(NSMutableDictionary *)headers 
credentialsInHeaders:(BOOL)isCredentialInHeaders context:(ObjectContext *)objContext;
-(HttpBatchResponse *) GetResponse;
@end
