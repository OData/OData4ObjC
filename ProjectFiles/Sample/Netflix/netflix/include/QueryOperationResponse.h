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


#import "DataServiceQueryContinuation.h"

@interface QueryOperationResponse: NSObject
{
	NSString				*m_innerException;
    NSInteger				m_statusCode;
    NSString				*m_query;
	NSInteger				m_countValue;

	NSMutableDictionary		*m_headers;
    NSMutableArray			*m_result;
	NSMutableDictionary		*m_objectIDToNextLinkUrl;
	NSInteger               m_inlineCountValue;
}

@property ( nonatomic , retain , getter=getError ,					setter=setInnerException			) NSString *m_innerException;
@property ( nonatomic , assign , getter=getStatusCode ,				setter=setStatusCode				) NSInteger m_statusCode;
@property ( nonatomic , retain , getter=getQuery ,					setter=setQuery						) NSString *m_query;
@property ( nonatomic , assign , getter=getCountValue ,				setter=setCountValue				) NSInteger m_countValue;
@property ( nonatomic , retain , getter=getObjectIDToNextLinkUrl,	setter=setObjectIDToNextLinkUrl		) NSMutableDictionary		*m_objectIDToNextLinkUrl;
@property ( nonatomic , assign , getter=getInlineCountValue ,		setter=setInlineCountValue		    ) NSInteger m_inlineCountValue;


- (id) initWithValues:(NSDictionary*) aHeaders innerException:(NSString*)anInnerException statusCode:(NSInteger) aStatusCode query:(NSString*) aQuery;
- (NSDictionary*) getHeaders;
- (NSInteger) totalCount;
- (DataServiceQueryContinuation*) getContinuation:(NSArray*)collection;
- (NSMutableArray*) getResult;
- (void) setResult:(NSMutableArray*)array;

@end
