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
#import "constants.h"

@interface AzureTableUtil : NSObject {
	
	@private
    /**
     * Storage header prefix.
     * 
     */
    NSString *m_PREFIX_STORAGE_HEADER;
	
    /**
     * azure api version.
     * 
     */
    NSString *m_AZURE_API_VERSION;
	
	@protected
    /**
     * Account name for Windows Azure.
     *
     * @var <string>
     */
    NSString *m_accountName;
	
    /**
     * Account key for Windows Azure.
     *
     * @var <string>
     */
    NSString *m_accountKey;
	
    /**
     * Use path-style uri
     *
     * @var <string>
     */
    BOOL m_usePathStyleUri;// = false;
}

@property(nonatomic,retain, getter=getAccountName,		setter=setAccountName		)NSString *m_accountName;
@property(nonatomic,retain, getter=getAccountKey,		setter=setAccountKey		)NSString *m_accountKey;
@property(nonatomic,assign, getter=getUsePathStyleUri,	setter=setUsePathStyleUri	)BOOL m_usePathStyleUri;

- (id) initWithAccountName:(NSString *)anAccountName accountKey:(NSString *)anAccountKey usePathStyleUri:(BOOL )anUsePathStyleUri;
- (NSString *) prepareQueryStringForSigning:(NSString *)aValue;
- (NSArray *) parseRequestUrl:(NSString *)anUrl;
- (NSMutableDictionary *) getSignedHeaders:(NSString *)aRequestUrl;
- (NSString *) base64encoding:(unsigned const char*)aBytesBuffer;
@end
