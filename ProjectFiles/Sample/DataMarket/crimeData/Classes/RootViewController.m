
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

#import "RootViewController.h"
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "DetailsViewController.h"
#import "ODataSampleAppAppDelegate.h"

#import "AzureTableCredential.h"
#import "Tables.h"

# import "ODataXMlParser.h"
#import "datagovCrimesContainer.h"

@implementation Table23Aug1
@synthesize m_Name,m_Age,m_Address;

-(id) initWithUri:(NSString *)aUri
{
	self=[super initWithUri:aUri];
	return self;
}
@end

@implementation RootViewController

@synthesize resultArray;

- (void) onAfterReceive:(HttpResponse*)response
{
	NSLog(@"on after receive");
	NSLog(@"http response = %@",[response getHttpMessage]);
}


-(void)addCrimeObject
{
	@try{
		NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
		[dict setObject:@"true" forKey:@"access"];
		
		ACSCredential *cred=[[ACSCredential alloc]initWithServiceName:@"dallas" wrapName:@"https://dallas.azure.windows.net/" wrapPassword:@"w+O/zDwUii+D1pPhas9VTfyP23USxnkceQ6tzv85NUs=" wrapScope:@"https://dallas.azure.windows.net/c8a25409-eb32-466e-a34c-b8af30fa847a" claims:dict proxy:nil];
		
		datagovCrimesContainer *govCrime=[[datagovCrimesContainer alloc] initWithUri:@"https://api.datamarket.azure.com/Data.ashx/data.gov/Crimes/" credential:cred];
		[govCrime setODataDelegate:self];
	
		data_gov_Crimes_CityCrime *cityCrime=[[data_gov_Crimes_CityCrime alloc] init];
		[cityCrime setCity:@"demoCity"];
		[cityCrime setYear:[NSNumber numberWithInt:2011]];
		[cityCrime setPopulation:[NSNumber numberWithInt:10000]];
		[cityCrime setRobbery:[NSNumber numberWithInt:3]];
		[cityCrime setMotorVehicleTheft:[NSNumber numberWithInt:0]];
	
		[govCrime addToCityCrime:cityCrime];
		[govCrime saveChanges];
		
		NSArray *arr = [govCrime.m_objectToResource values] ;
			if([arr count]>0){
				data_gov_Crimes_CityCrime *p1 =[arr objectAtIndex:0];
			
				NSLog(@"=== Crime Information  ===");
				NSLog(@" City...%@",[p1 getCity]);
				NSLog(@" Year...%d",[p1 getYear]);
				NSLog(@" Population...%d",[p1 getPopulation]);
				NSLog(@" robbery...%d",[p1 getRobbery]);
				NSLog(@" MotorVehicleTheft...%@",[p1 getMotorVehicleTheft]);
	
			}
			[cityCrime release];
			[govCrime release];
	}
	@catch(NSException *e)
	{
		NSLog(@"Exception:%@:%@",[e name],[e reason]);
	}
}
//update object
-(void)updateCrimeObject
{
	@try {
		WindowsCredential *credt = [[WindowsCredential alloc] initWithUserName:@"livefx" password:@"FEQynzVxM41sj4GVkciFkFsOi/Vh7WxeY0P/JCGQ4K8="];
		
		datagovCrimesContainer *govCrime = [[datagovCrimesContainer alloc] initWithUri:@"https://api.datamarket.azure.com/Data.ashx/data.gov/Crimes/"credential:credt];
		DataServiceQuery *query =[govCrime citycrime];
		[query top:1];
		//[query addQueryOption:@"format" query:@"json"];
		QueryOperationResponse *response = [query execute];
		data_gov_Crimes_CityCrime *crimedata=[[response getResult] objectAtIndex:0];
		
		//update property
		[crimedata setState:@"MAHARASTRA"];
		
		[govCrime updateObject:crimedata];
		
		[govCrime saveChanges];
		
		[crimedata release];
	}
	@catch (NSException * e) {
		NSLog(@"Exception:%@:%@",[e name],[e reason]);
	}
	
}

//Windows basic Authentation
-(void)retrieveAllCrimeDetails_Windows
{
	WindowsCredential *credt = [[WindowsCredential alloc] initWithUserName:@"livefx" password:@"FEQynzVxM41sj4GVkciFkFsOi/Vh7WxeY0P/JCGQ4K8="];
	
	datagovCrimesContainer *govCrime = [[datagovCrimesContainer alloc] initWithUri:@"https://api.datamarket.azure.com/Data.ashx/data.gov/Crimes/"credential:credt];
	DataServiceQuery *query =[govCrime citycrime];
	//[query addQueryOption:@"format" query:@"json"];
	[query top:10];
	QueryOperationResponse *response = [query execute];
	resultArray =[[response getResult] retain];
	
	NSLog(@"WindowsCredential resultarray...%d",[resultArray count]);
	for (int i =0;i<[resultArray count]; i++) {
		data_gov_Crimes_CityCrime *t=[resultArray objectAtIndex:i];
		NSLog(@"***** citycrime %d *****",i);
		NSLog(@" name ...%@",[t getCity]);
	}
	
}

//ACS Authentation callback method

- (void) onBeforeSend:(HttpRequest*)aRequestHeader
{
	NSLog(@"onBeforeSend");
	NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
	[dict setObject:@"true" forKey:@"access"];
	
	ACSUtil *util=[[ACSUtil alloc]initWithServiceName:@"dallas" wrapName:@"https://dallas.azure.windows.net/" wrapPassword:@"w+O/zDwUii+D1pPhas9VTfyP23USxnkceQ6tzv85NUs=" wrapScope:@"https://dallas.azure.windows.net/c8a25409-eb32-466e-a34c-b8af30fa847a" claims:dict proxy:nil];
	//ACSUtil *util=[[ACSUtil alloc]initWithServiceName:@"dallas" wrapName:@"https://dallas.azure.windows.net/" wrapPassword:@"w+O/zDwUii+D1pPhas9VTfyP23USxnkceQ6tzv85NUs=" wrapScope:@"" claims:dict proxy:nil];

	@try
	{
		NSDictionary *valDict=[util getSignedHeaders];
		HTTPHeaders *headers = [aRequestHeader getHeaders];
		[[headers getHttpHeaders] addEntriesFromDictionary:valDict];
	}
	@catch (NSException *e) {
		@throw e;
	}
}
//ACS Authentation
-(void)retrieveAllCrimeDetails_ACS
{
	//@try{
		
		NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
		[dict setObject:@"true" forKey:@"access"];
		
		ACSCredential *cred=[[ACSCredential alloc]initWithServiceName:@"dallas" wrapName:@"https://dallas.azure.windows.net/" wrapPassword:@"w+O/zDwUii+D1pPhas9VTfyP23USxnkceQ6tzv85NUs=" wrapScope:@"https://dallas.azure.windows.net/c8a25409-eb32-466e-a34c-b8af30fa847a" claims:dict proxy:nil];
		//ACSCredential *cred=[[ACSCredential alloc]initWithServiceName:@"dallas" wrapName:@"https://dallas.azure.windows.net/" wrapPassword:nil wrapScope:nil claims:dict proxy:nil];
		datagovCrimesContainer *proxy=[[datagovCrimesContainer alloc] initWithUri:@"https://api.datamarket.azure.com/Data.ashx/data.gov/Crimes/" credential:cred];
		[proxy setODataDelegate:self];
		
		DataServiceQuery *query =[proxy citycrime];
		QueryOperationResponse *response = [query execute];
		resultArray =[[response getResult] retain];
		
		NSLog(@"resultarray...%d",[resultArray count]);
		for (int i =0;i<[resultArray count]; i++) {
			data_gov_Crimes_CityCrime *t=[resultArray objectAtIndex:i];
			NSLog(@"***** citycrime %d *****",i);
			NSLog(@" name ...%@",[t getCity]);
		}
		[proxy release];
	//}
//	@catch(NSException *e)
//	{
//		NSLog(@"Exception:%@:%@",[e name],[e reason]);
//	}
}
	
	
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	@try 
	{
		[self updateCrimeObject];
		//[self retrieveAllCrimeDetails_ACS];
		//[self retrieveAllCrimeDetails_Windows];
		//[self addCrimeObject];

	}
		@catch (NSException * e) 
	{
		NSLog(@"exception = %@, %@",[e name],[e reason]);
	}	
}

- (void)viewDidUnload {
	[resultArray release];
	resultArray = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[[self navigationController] setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [resultArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if([resultArray count] > 0 )
	{
		data_gov_Crimes_CityCrime *t = [resultArray objectAtIndex:indexPath.row];
		cell.textLabel.text = [t getCity];
	}
	
	//Tables *table=[resultArray objectAtIndex:indexPath.row];
	//cell.textLabel.text = [table getTableName];
    return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	data_gov_Crimes_CityCrime *t = [resultArray objectAtIndex:indexPath.row];
	DetailsViewController *details = [[DetailsViewController alloc] initWithStyle:UITableViewStylePlain];
	details.items = t;
	[[self navigationController] pushViewController:details animated:YES];
	[details release];
}


- (void)dealloc {
    [super dealloc];
}

@end

