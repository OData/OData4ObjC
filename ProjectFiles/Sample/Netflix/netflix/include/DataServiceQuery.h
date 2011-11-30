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


#import "MSODataResponseDelegate.h"

#import "ObjectContext.h"
#import "QueryOperationResponse.h"
#import "DataServiceRequestException.h"

@interface DataServiceQuery: NSObject <MSODataResponseDelegate>
{
	/**
     *
     * ObjectContextDelegate delegate for passing back result or error 
     */
	id<ObjectContextDelegate> m_delegate;
	
	/**
     *
     * Httprequest object for firing the query and getting the result
     */
	//HttpRequest *httpRequest;
	
	/**
     *
     * intermediate flag
     */
	//OOL parseResult;
	
   /**
    *
    * @var <Url>
    */
	NSString *m_entitySetUrl;

   /**
    *
    * @var <ObjectContext>
    */
	ObjectContext *m_context;

   /**
    *
    * @var <array>
    */
	NSMutableDictionary *m_systemQueryOptions;
		
   /**
    *
    * @var <array>
    */
	NSMutableDictionary *m_options;

   /**
    *
    * @var <array>
    */
	NSMutableArray *m_expand;

	/**
	 * To hold orderby query options.
	 *
	 * @var <array>
	 */
	NSMutableArray *m_orderby;
	
   /**
    *
    * @var <array>
    */
	NSMutableArray *m_other;

   /**
    *
    * @var <boolean>
    */
	BOOL m_isAzureRequest;
}

@property ( nonatomic , retain , getter=getDelegate , setter=setDelegate) id<ObjectContextDelegate> m_delegate;

@property ( nonatomic , retain , getter=getEntitySetUrl , setter=setEntitySetUrl) NSString *m_entitySetUrl;
@property ( nonatomic , retain , getter=getContext , setter=setContext ) ObjectContext *m_context;
@property ( nonatomic , assign , getter=isAzureRequest , setter=setAzureRequest) BOOL m_isAzureRequest;

- (id) initWithUri:(NSString*)anEntitySetUrl objectContext:(ObjectContext*)anObjectContext;

- (DataServiceQuery*) addQueryOption:(NSString*)anOption query:(NSString*)aQuery;
- (DataServiceQuery*) expand:(NSString*)anExpression;
- (DataServiceQuery*) orderBy:(NSString*)anExpression;
- (DataServiceQuery*) top:(NSInteger)count;
- (DataServiceQuery*) skip:(NSInteger)count;
- (DataServiceQuery*) filter:(NSString*)anExpression;
- (DataServiceQuery*) includeTotalCount:(NSString*)anExpression;
- (DataServiceQuery*) select:(NSString*)anExpression;
- (NSString*) count;
- (QueryOperationResponse*) execute;
- (NSString*) requestUri;
-(void) clearAllOptions;
- (NSString*) buildQueryOption;
- (QueryOperationResponse*) createQueryOperationResponse:(NSString*)anErrorMessage;

@end
