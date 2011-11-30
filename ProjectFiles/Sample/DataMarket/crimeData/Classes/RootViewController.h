
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

#import "ODataDelegate.h"
#import "TableEntry.h"

@interface RootViewController : UITableViewController<ODataDelegate>{
	NSArray *resultArray;
}

@property (nonatomic, retain)NSArray *resultArray;

@end
@interface Table23Aug1 :TableEntry
{
    /**
     *
     * @Type:EntityProperty
     */
    NSString *m_Name;
	
    /**
     *
     * @Type:EntityProperty
     */
	NSString *m_Age;
	
    /**
     *
     * @Type:EntityProperty
     */
    NSString *m_Address;
}
@property(nonatomic,retain,getter=getName, setter = setName)NSString *m_Name;
@property(nonatomic,retain,getter=getAge, setter = setAge)NSString *m_Age;
@property(nonatomic,retain,getter=getAddress, setter = setAddress)NSString *m_Address;
-(id) initWithUri:(NSString *)aUri;

@end

