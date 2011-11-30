
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


@interface ODataEntity : NSObject {
	/**
     * Vaiable holding ChangeOrder of Resourcebox or RelatedEnd
     */
    NSInteger changeOrder;
	
    /**
     * State of ResourceBox or RelatedEnd. See the EntityStates class
     * for possible values.
     */
    NSInteger state;
}

@property ( nonatomic, assign , getter=getChangeOrder, setter=setChangeOrder) NSInteger changeOrder;
@property ( nonatomic, assign , getter=getState , setter=setState) NSInteger state;

- (id) init;

-(BOOL) isResource;



@end
