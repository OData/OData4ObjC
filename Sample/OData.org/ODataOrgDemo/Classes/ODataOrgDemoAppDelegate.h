//
//  ODataOrgDemoAppDelegate.h
//  ODataOrgDemo
//
//  Created by CARLOS C TAPANG on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ODataOrgDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

