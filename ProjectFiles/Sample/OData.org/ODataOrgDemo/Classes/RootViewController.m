
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
//#import "DetailsViewController.h"
#import "ODataOrgDemoAppDelegate.h"
#import "AzureTableCredential.h"
#import "Tables.h"
#import "DemoService.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"


@implementation RootViewController

@synthesize resultArray;



- (void) onAfterReceive:(HttpResponse*)response
{
	NSLog(@"on after receive");
	NSLog(@"http response = %@",[response getHttpMessage]);
}


-(void) retrieveProducts
{
	NSLog(@"retriving products....");
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(4pso0zvr1z0vxiozq2sudgcs))/OData/OData.svc/" credential:nil];
	
	DataServiceQuery *query = [proxy products];
	//[query top:1];
	QueryOperationResponse *response = [query execute];
	NSArray *resultArr =[[response getResult] retain];
	NSLog(@"resultarray...%d",[resultArr count]);
	for (int i =0;i<[resultArr count]; i++) {
		
		ODataDemo_Product *p = [resultArr objectAtIndex:i];
		NSLog(@"=== product %d  ===",i);
		NSLog(@"product id...%@",[[p getID] stringValue]);
		NSLog(@"product name...%@",[p getName]);
		NSLog(@"product desc......%@",[p getDescription]);
		NSLog(@"Rdate..%@",[p getReleaseDate]);
		NSLog(@"Ddate..%@",[p getDiscontinuedDate]);
		
	}
}


-(void)addProductObject
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(4pso0zvr1z0vxiozq2sudgcs))/OData/OData.svc/" credential:nil];
	
	ODataDemo_Product *p = [[ODataDemo_Product alloc] init];
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"];
	
	NSDate *d = [fmt dateFromString:@"2011-07-01T00:00:00.00"];
	[p setName:@"1JULYPRODUCT"];
	[p setID:[NSNumber numberWithInt:30000]];
	[p setDescription:@"product information:This is demo product information:1"];
	[p setReleaseDate:[NSDate date]];
	[p setRating:[NSNumber numberWithInt:1]];
	[p setDiscontinuedDate:d];
	[proxy addToProducts:p];
	
	//[proxy setSaveChangesOptions:Batch];
	
	[proxy saveChanges];
	
	[p release];
	[proxy release];
	
}

-(void) updateProductObject
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(4pso0zvr1z0vxiozq2sudgcs))/OData/OData.svc/" credential:nil];
	DataServiceQuery *query = [proxy products];
	[query filter:@"Name eq '1JULYPRODUCT'"];
	QueryOperationResponse *queryOperationResponse = [query execute];
	if(queryOperationResponse)
	{	
		NSArray *resultArray1=[queryOperationResponse getResult];
		ODataDemo_Product *c=[resultArray1 objectAtIndex:0];
		[c setName:@"final_1JULYPRODUCT"];
		[proxy updateObject:c];
		//[proxy setSaveChangesOptions:Batch];
		[proxy saveChanges];
		
		[c release];
		[proxy release];
	}
	
}
-(void) deleteProductObject
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(4pso0zvr1z0vxiozq2sudgcs))/OData/OData.svc/" credential:nil];
	DataServiceQuery *query = [proxy products];
	[query filter:@"Name eq '30JUNPRODUCT'"];
	QueryOperationResponse *queryOperationResponse = [query execute];
	if(queryOperationResponse)
	{	
		resultArray=[queryOperationResponse getResult];
		ODataDemo_Product *c=[resultArray objectAtIndex:0];
		[proxy deleteObject:c];
		[proxy setSaveChangesOptions:Batch];
		[proxy saveChanges];
	}
	[proxy release];
}

-(void) addLink
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(qg3ip020t4o00tpd1wbrb2l4))/OData/OData.svc/" credential:nil];
	DataServiceQuery *query = [proxy products];[query top:1];
	QueryOperationResponse *queryOperationResponse = [query execute];
	resultArray=[queryOperationResponse getResult];
	ODataDemo_Product *aProduct =[resultArray objectAtIndex:0];
	
	query = [proxy categories];[query top:1];
	queryOperationResponse = [query execute];
	resultArray=[queryOperationResponse getResult];
	ODataDemo_Category *aCategory =[resultArray objectAtIndex:0];
	
	[proxy addLink:aCategory sourceProperty:@"Products" targetObject:aProduct];
	[proxy setSaveChangesOptions:Batch];
	[proxy saveChanges];
	[proxy release];
	
}
-(void) setLink
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(qg3ip020t4o00tpd1wbrb2l4))/OData/OData.svc/" credential:nil];
	
	DataServiceQuery *query = [proxy products];
	[query filter:@"Name eq 'Bread'"];
	QueryOperationResponse *queryOperationResponse = [query execute];
	resultArray=[queryOperationResponse getResult];
	ODataDemo_Product *p=[resultArray objectAtIndex:0];
	
	query = [proxy categories];
	[query filter:@"Name eq 'Food'"];
	queryOperationResponse = [query execute];
	resultArray=[queryOperationResponse getResult];
	ODataDemo_Category *c=[resultArray objectAtIndex:0];
	
	[proxy setLink:p sourceProperty:@"Category" targetObject:c];
	[proxy setSaveChangesOptions:Batch];
	[proxy saveChanges];
	[proxy release];
}


-(void) deleteLink
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(qg3ip020t4o00tpd1wbrb2l4))/OData/OData.svc/" credential:nil];
	
	DataServiceQuery *query = [proxy categories];
	[query filter:@"Name eq 'Food'"];
	QueryOperationResponse *queryOperationResponse = [query execute];
	resultArray=[queryOperationResponse getResult];
	ODataDemo_Category *c=[resultArray objectAtIndex:0];
	
	query = [proxy products];
	[query filter:@"Name eq 'Bread'"];
	queryOperationResponse = [query execute];
	resultArray=[queryOperationResponse getResult];
	ODataDemo_Product *p=[resultArray objectAtIndex:0];
	
	[proxy deleteLink:c sourceProperty:@"Product" targetObject:p];
	[proxy setSaveChangesOptions:Batch];
	[proxy saveChanges];
	[proxy release];       
}

-(void)checkForInnerError
{
	DemoService *proxy=[[DemoService alloc]initWithUri:@"http://services.odata.org/(S(qg3ip020t4o00tpd1wbrb2l4))/OData/OData.svc/" credential:nil];

	NSString *errStr=@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>\
	<error xmlns=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\">\
	<code></code>\
	<message xml:lang=\"en-US\">Error processing request stream. The URI specified is not valid.</message>\
	<innererror>\
    <message>Invalid Uri specified. The query DataServiceProvider.DSPLinqQuery 1[DataServiceProvider.DSPResource] must refer to a single resource</message>\
    <type>System.ArgumentException</type>\
    <stacktrace> at DataServiceProvider.DSPUpdateProvider.GetResource(IQueryable query, String fullTypeName) </stacktrace>\
	</innererror>";
	
	ODataXMlParser *parse = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [parse parseData:[errStr dataUsingEncoding:NSUTF8StringEncoding]];
	AtomParser *atom = [[AtomParser alloc] initwithContext:proxy];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc] initWithValues:nil innerException:nil statusCode:0 query:nil];
	[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
	
}

#pragma mark viewDidLoad method
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	@try 
	{
		//[self checkForInnerError];
		//uncomment to products
		//[self addProductObject];
		
		//[self updateProductObject];
		//[self deleteProductObject];
		[self retrieveProducts];
		
		//[self addLink];
		//[self setLink];
		//[self deleteLink];
		
		//[self functionImport];
		
	}
	@catch (DataServiceRequestException * e) 
	{
		NSLog(@"exception = %@,  innerExceptiom= %@",[e name],[[e getResponse] getError]);
	}	
	@catch (ODataServiceException * e) 
	{
		NSLog(@"exception = %@,  \nDetailedError = %@",[e name],[e getDetailedError]);
		
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
	
	NSLog(@"didReceiveMemoryWarning........");
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
		//NetflixCatalog_Model_Title *t = [resultArray objectAtIndex:indexPath.row];
		//cell.textLabel.text = [t getShortName];
		
	}
	return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//NetflixCatalog_Model_Title *t = [resultArray objectAtIndex:indexPath.row];
	//DetailsViewController *details = [[DetailsViewController alloc] initWithStyle:UITableViewStylePlain];
	//details.items = t;
	//[[self navigationController] pushViewController:details animated:YES];
	//[details release];
}


- (void)dealloc {
    [super dealloc];
}


@end

