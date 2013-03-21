
/*
 Copyright 2010 OuterCurve Foundation
 
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

#import "ODataSampleAppAppDelegate.h"
#import "RootViewController.h"
#import "WindowsCredential.h"

@implementation ODataSampleAppAppDelegate

@synthesize window,navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	navigationController=[[UINavigationController alloc]initWithRootViewController:rootViewController];
	[self.window setRootViewController:navigationController];
	[rootViewController release];
    // Override point for customization after application launch
    [self.window makeKeyAndVisible];
}


- (void)dealloc {
    [navigationController release];	
	[self.window release];
    [super dealloc];
}


@end
