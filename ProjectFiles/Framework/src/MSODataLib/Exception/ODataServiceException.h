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
#import <Foundation/NSException.h>


@interface ODataServiceException : NSException {
	NSString		*m_error;
    NSString		*m_detailedError;
    NSDictionary	*m_headers;
    NSInteger		m_statusCode;
}

@property (nonatomic,	retain,	getter=getError,		setter=setError			) NSString *m_error;
@property (nonatomic,	retain,	getter=getDetailedError,setter=setDetailedError	) NSString *m_detailedError;
@property (nonatomic,	retain,	getter=getHeaders,		setter=setHeaders		) NSDictionary *m_headers;
@property (nonatomic,	assign,	getter=getStatusCode,	setter=setErrorCode		) NSInteger m_statusCode;

-(id) init;
-(id) initWithError:(NSString *)anError contentType:(NSString *)aContentType headers:(NSDictionary *)aHeaders statusCode:(NSInteger)aSattusCode;

@end
