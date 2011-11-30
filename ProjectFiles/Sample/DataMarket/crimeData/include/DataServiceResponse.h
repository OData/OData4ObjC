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


#import "OperationResponse.h"

@interface DataServiceResponse : NSObject
{
	BOOL m_batchResponse;
	NSString* m_headers;
	NSMutableArray *m_operationResponse;
	NSInteger m_statusCode;
}

@property ( nonatomic , assign , getter=IsBatchResponse ,		setter=setBatchResponse		) BOOL m_batchResponse;
@property ( nonatomic , retain , getter=getBatchHeaders ,		setter=setHeaders			) NSString *m_headers;
@property ( nonatomic , retain , getter=getOperationResponse ,	setter=setOperationResponse	) NSMutableArray *m_operationResponse;
@property ( nonatomic , assign , getter=getBatchStatusCode ,	setter=setStatusCode		) NSInteger m_statusCode;

- (id) initWithHeader:(NSString*)aHeader statusCode:(NSInteger)aStatusCode operationResponse:(NSMutableArray*)anOperationResponse batchResponse:(BOOL)aBatchResponse;

@end
