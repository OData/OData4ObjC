
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

#import "DetailsViewController.h"
#import "ODataSampleAppAppDelegate.h"


@implementation DetailsViewController

@synthesize items;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"detailsview loaded");
	[[self navigationController] setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Set up the cell...
	if(indexPath.row == 0)
		cell.textLabel.text =[NSString stringWithFormat:@"ROWId = %@",[items.m_ROWID stringValue]];	
	else if(indexPath.row == 1)
		cell.textLabel.text =[NSString stringWithFormat:@"State = %@",items.m_State];
	else if(indexPath.row == 2)
		cell.textLabel.text =[NSString stringWithFormat:@"City = %@",items.m_City];	
	else if(indexPath.row == 3)
		cell.textLabel.text = [NSString stringWithFormat:@"Year = %@",[items.m_Year stringValue]];	
	else if(indexPath.row == 4)
		cell.textLabel.text =[NSString stringWithFormat:@"Population = %@",[items.m_Population stringValue]];	
	else if(indexPath.row == 5)
		cell.textLabel.text = [NSString stringWithFormat:@"ViolentCrime = %@",[items.m_ViolentCrime stringValue]];	
	else if(indexPath.row == 6)
		cell.textLabel.text = [NSString stringWithFormat:@"MurderAndNonEgligentManslaughter = %@",[items.m_MurderAndNonEgligentManslaughter stringValue]];
	else if(indexPath.row == 7)
		cell.textLabel.text = [NSString stringWithFormat:@"ForcibleRape = %@",[items.m_ForcibleRape stringValue]];
	else if(indexPath.row == 8)
		cell.textLabel.text = [NSString stringWithFormat:@"MurderAndNonEgligentManslaughter = %@",[items.m_MurderAndNonEgligentManslaughter stringValue]];
	else if(indexPath.row == 9)
		cell.textLabel.text = [NSString stringWithFormat:@"Robbery = %@",[items.m_Robbery stringValue]];
	else if(indexPath.row == 10)
		cell.textLabel.text = [NSString stringWithFormat:@"AggravatedAssault = %@",[items.m_AggravatedAssault stringValue]];
	else if(indexPath.row == 11)
		cell.textLabel.text = [NSString stringWithFormat:@"PropertyCrime = %@",[items.m_PropertyCrime stringValue]];
	else if(indexPath.row == 12)
		cell.textLabel.text = [NSString stringWithFormat:@"Burglary = %@",[items.m_Burglary stringValue]];
	else if(indexPath.row == 13)
		cell.textLabel.text = [NSString stringWithFormat:@"LarcenyTheft = %@",[items.m_LarcenyTheft stringValue]];
	else if(indexPath.row == 14)
		cell.textLabel.text = [NSString stringWithFormat:@"MotorVehicleTheft = %@",[items.m_MotorVehicleTheft stringValue]];
	else if(indexPath.row == 15)
		cell.textLabel.text = [NSString stringWithFormat:@"Arson = %@",[items.m_Arson stringValue]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}


- (void)dealloc {
	[items release];
    [super dealloc];
}


@end

