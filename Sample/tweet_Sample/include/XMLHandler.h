//
//  XMLHandler.h
//  XML
//
//  Created by admin on 10/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class ODataXMLElements;

@interface XMLHandler : NSObject 
{
	ODataXMLElements *currentElement;
	ODataXMLElements *parentElement;
	ODataXMLElements *tempparentElement;
	BOOL isParent;
}


-(ODataXMLElements *)parseData:(NSData *)xmlDocument;

@end
