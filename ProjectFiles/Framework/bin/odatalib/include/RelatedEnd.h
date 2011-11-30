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


#import "ODataEntity.h"
#import "ODataObject.h"

@interface RelatedEnd : ODataEntity
{
    /**
     * Holding the source of object of binding
     */
    ODataObject *m_sourceResource;
    
    /**
     * Holding the source property in Source Object
     */     
    NSString *m_sourceProperty;
    
    /**
     * Holding the target of object of binding
     */
    ODataObject *m_targetResource;
}

@property ( nonatomic , retain , getter=getSourceResource , setter=setSourceResource	) ODataObject *m_sourceResource;
@property ( nonatomic , retain , getter=getSourceProperty , setter=setSourceProperty	) NSString *m_sourceProperty;
@property ( nonatomic , retain , getter=getTargetResource , setter=setTargetResource	) ODataObject *m_targetResource;

-(id) initWithObject:(ODataObject*)aSourceResource sourceProperty:(NSString*) aSourceProperty targetResource:(ODataObject*)aTargetResource;
-(BOOL) isEquals:(RelatedEnd*) aRelatedEndObj1 relatedEndObj2:(RelatedEnd*) aRelatedEndObj2;
-(NSString*) getObjectID;
@end