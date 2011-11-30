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

@interface OperationResponse : NSObject
{
    /**
     *
     * @var <array>
     */
    NSMutableDictionary *m_headers;

    /**
     *
     * @var <string>
     */
    NSString *m_innerException;

    /**
     *
     * @var <Integer>
     */
    NSInteger m_statusCode;

}

@property ( nonatomic , retain , getter=getInnerException , setter=setInnerException ) NSString * m_innerException;
@property ( nonatomic , assign , getter=getStatusCode ,		setter=setStatusCode	 ) NSInteger m_statusCode;


- (id) initWithHeaders:(NSDictionary*)aHeaders errorMsg:(NSString*)anErrorMsg statusCode:(NSInteger)aStatusCode;
- (NSString*) getError;
- (NSDictionary*) getHeaders;
- (NSInteger) getStatusCode;

@end