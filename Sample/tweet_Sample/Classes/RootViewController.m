
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

#import "RootViewController.h"
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "DetailsViewController.h"
#import "ODataSampleAppAppDelegate.h"

#import "AzureTableCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"
#import "eventsEntities.h"
#import "DemoService.h"
#import "NorthwindEntities.h"
#import "NetflixCatalog.h"

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


/*-(void) testTweets
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];     
	eventEntities *proxy=[[eventEntities alloc]initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc" credential:nil];
	[proxy setDataServiceVersion:@"2.0"];
	
	DataServiceQuery *query = [proxy tweets];
	NSString *count=[query count];
	[query skip:[count intValue]];
	QueryOperationResponse *response = [query execute];

	DataServiceQueryContinuation *continuation=nil;
	DataServiceDeltaQuery *deltaQuery = nil;

	if([response hasDelta])
		deltaQuery = [response getDeltaQuery];
	
	if ([deltaQuery hasDelta]) {
		response =[proxy executeDSDeltaQuery:deltaQuery];
		do
		{
			resultArray=[response getResult];
			//process deltas
			int count=[resultArray count];
			NSLog(@"Number Of deleted/inserted/updated Entries.....%d",count);
			for (int i=0; i<count; i++)
			{
				id object=[resultArray objectAtIndex:i];
				if([object isKindOfClass:[ODataDeletedObject class]])
				{
					//process deleted object
					EventModel_DeletedSession *delSession=[resultArray objectAtIndex:i];
					NSLog(@"keyValues=%@",[[delSession getKeyValues] description]);
					NSLog(@"objectId...%@",delSession.m_objectID);
					NSLog(@"timeStamp..%@",delSession.m_timestamp);
					NSLog(@"baseURI....%@",delSession.m_OData_baseURI);
				}
				else{
					//process add or update
					EventModel_Tweet *tweets=[resultArray objectAtIndex:i];	
					NSLog(@"Author...%@",[tweets getAuthor]);
					NSLog(@"tweet...%@",[tweets getText]);
				}
				
			}
			//check if there is continuation
			continuation=[response getContinuation:nil];
			if([continuation getNextLinkUri] !=nil)
				response=[proxy executeDSQueryContinuation:continuation];
			else
				continuation =nil;
		}while(continuation !=nil);    
	}
	
	[cred release];
	[proxy release];
	
}*/

#pragma mark -----------
#pragma mark deleted-entry response processer
/* this method parses hard coded xml response for deleted entry.*/

/*-(void) testMixResProcessor
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	eventsEntities *proxy=[[eventsEntities alloc] initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc/" credential:cred];
	[proxy setDataServiceVersion:@"2.0"];
	
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc ]init];
	
	NSString *str=@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\" ?>"\
	"<feed xml:base=\"http://mixwithtweets.cloudapp.net/OData.svc/\" xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://www.w3.org/2005/Atom\">"\
	"<title type=\"text\">Tweets</title>"\
	"<id>http://mixwithtweets.cloudapp.net/OData.svc/Tweets</id>"\
	"<updated>2011-03-30T22:00:42Z</updated>"\
	"<author>"\
	"<name />"\
	"</author>"\
	"<link rel=\"self\" title=\"Tweets\" href=\"Tweets\" />"\
	"<deleted-entry ref=\"http://mixwithtweets.cloudapp.net/OData.svc/Tweets(TweetID='45013874071707648',ScheduleItemId=BD326537-7441-452B-A752-8F9C4F792EB9)\" when=\"2011-03-30T22:00:34.277\" xmlns=\"http://purl.org/atompub/tombstones/1.0\" />"\
	"<deleted-entry ref=\"http://mixwithtweets.cloudapp.net/OData.svc/Tweets(TweetID='45013604419911680',ScheduleItemId=7B04BF20-63E0-4CCF-8AC4-0835DA3BA76E)\" when=\"2011-03-30T22:00:34.277\" xmlns=\"http://purl.org/atompub/tombstones/1.0\" />"\
	"<deleted-entry ref=\"http://mixwithtweets.cloudapp.net/OData.svc/Tweets(TweetID='45012771330473984',ScheduleItemId=BD326537-7441-452B-A752-8F9C4F792EB9)\" when=\"2011-03-30T22:00:34.277\" xmlns=\"http://purl.org/atompub/tombstones/1.0\" />"\
	"<deleted-entry ref=\"http://mixwithtweets.cloudapp.net/OData.svc/Tweets(TweetID='45012454098468865',ScheduleItemId=BD326537-7441-452B-A752-8F9C4F792EB9)\" when=\"2011-03-30T22:00:34.277\" xmlns=\"http://purl.org/atompub/tombstones/1.0\" />"\
	"<deleted-entry ref=\"http://mixwithtweets.cloudapp.net/odata.svc/Tweets(TweetID='10000000000000000',SessionID=93)\" when=\"2011-04-08T08:18:28.36\" m:reason=\"deleted\" />"\
	"<link rel=\"http://odata.org/delta\" href=\"http://mixwithtweets.cloudapp.net/OData.svc/Tweets?$deltatoken=B:255832\" />"\
	"</feed>";
	
	NSData *nonUTF8Data = [str dataUsingEncoding:NSUTF8StringEncoding];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:proxy];
	[atom EnumerateObjects:theXMLDocument  queryResponseObject:queryOperationResponse];
	
	[atom release];
	[handler release];
	
	NSArray *arr=[queryOperationResponse getResult];
	for (int i=0; i<[arr count]; i++) {
		EventModel_DeletedTweet *tweet=[arr objectAtIndex:i];
		NSLog(@"base uri=%@",[tweet getBaseURI]);
		NSLog(@"Id=%@",[tweet getObjectID]);
		NSLog(@"timestamp=%@",[[tweet getTimestamp] description]);
		NSLog(@"reason=%@",[tweet getReason]);
		NSLog(@"keyValues=%@",[[tweet getKeyValues] description]);
	}
	[cred release];
	[proxy release];
}*/

/*-(void)chkNameSpaceProblem
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	eventEntities *m_ctx=[[eventEntities alloc] initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc/" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc ]init];
	
	NSString *str=@"<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>"\
	"<feed xml:base=\"http://mixwithtweets.cloudapp.net/odata.svc/\" xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns:t=\"http://purl.org/atompub/tombstones/1.0\" xmlns=\"http://www.w3.org/2005/Atom\">"\
	"<title type=\"text\">Tweets</title>"\
	"<id>http://mixwithtweets.cloudapp.net/odata.svc/Tweets</id>"\
	"<updated>2011-04-09T06:38:53Z</updated>"\
	"<link rel=\"self\" title=\"Tweets\" href=\"Tweets\" />"\
	"<entry>"\
	"<id>http://mixwithtweets.cloudapp.net/odata.svc/Tweets(SessionID=93,TweetID='10000000000000008')</id>"\
	"<title type=\"text\"></title>"\
	"<updated>2011-04-09T06:38:53Z</updated>"\
	"<author><name /></author>"\
	"<link rel=\"edit\" title=\"Tweet\" href=\"Tweets(SessionID=93,TweetID='10000000000000008')\" />"\
	"<link rel=\"http://schemas.microsoft.com/ado/2007/08/dataservices/related/Session\" type=\"application/atom+xml;type=entry\" title=\"Session\" href=\"Tweets(SessionID=93,TweetID='10000000000000008')/Session\" />"\
	"<category term=\"eventsModel.Tweet\" scheme=\"http://schemas.microsoft.com/ado/2007/08/dataservices/scheme\" />"\
	"<content type=\"application/xml\">"\
	"<m:properties>"\
	"<d:TweetID>10000000000000008</d:TweetID>"\
	"<d:Author>faketweeter</d:Author>"\
	"<d:Text>This is fake text</d:Text>"\
	"<d:SessionID m:type=\"Edm.Int32\">93</d:SessionID>"\
	"</m:properties>"\
	"</content>"\
	"</entry>"\
	"<t:deleted-entry ref=\"http://mixwithtweets.cloudapp.net/odata.svc/Tweets(TweetID='10000000000000000',SessionID=93)\" when=\"2011-04-08T08:18:28.36\" m:reason=\"deleted\" />"\
	"<link rel=\"http://odata.org/delta\" href=\"http://mixwithtweets.cloudapp.net/odata.svc/Tweets?$filter=SessionID%20eq%2093&amp;$orderby=TweetID%20desc&amp;$deltatoken=B:718035\" />"\
	"</feed>";
	
	NSData *nonUTF8Data = [str dataUsingEncoding:NSUTF8StringEncoding];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_ctx];
	[atom EnumerateObjects:theXMLDocument  queryResponseObject:queryOperationResponse];
	
	[atom release];
	[handler release];
	
	NSArray *arr=[queryOperationResponse getResult];
	for (int i=0; i<[arr count]; i++) {
		//EventModel_DeletedTweet *tweet=[arr objectAtIndex:i];
		//NSLog(@"base uri=%@",[tweet getBaseURI]);
		//NSLog(@"Id=%@",[tweet getObjectID]);
		//NSLog(@"timestamp=%@",[[tweet getTimestamp] description]);
		//NSLog(@"reason=%@",[tweet getReason]);
		//NSLog(@"keyValues=%@",[[tweet getKeyValues] description]);
		id object=[arr objectAtIndex:i];
		if([object isKindOfClass:[ODataDeletedObject class]])
		{
			//process deleted object
			EventModel_DeletedSession *delSession=[arr objectAtIndex:i];
			NSLog(@"keyValues=%@",[[delSession getKeyValues] description]);
			NSLog(@"objectId...%@",delSession.m_objectID);
			NSLog(@"timeStamp..%@",delSession.m_timestamp);
			NSLog(@"baseURI....%@",delSession.m_OData_baseURI);
		}
		else{
			//process add or update
			EventModel_Tweet *tweets=[arr objectAtIndex:i];	
			NSLog(@"Author...%@",[tweets getAuthor]);
			NSLog(@"tweet...%@",[tweets getText]);
		}
		
	}
	[cred release];
	[m_ctx release];
}
-(void)testForCommentInTweets
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	eventEntities *m_ctx=[[eventEntities alloc] initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc/" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc ]init];
	
	NSString *str=@"<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"yes\"?>"\
	"<feed xml:base=\"http://mixwithtweets.cloudapp.net/odata.svc/\" xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns:at=\"http://purl.org/atompub/tombstones/1.0\" xmlns=\"http://www.w3.org/2005/Atom\">"\
	"<at:deleted-entry ref=\"http://mixwithtweets.cloudapp.net/odata.svc/Tweets(TweetID='10000000000000000',SessionID=93)\" when=\"2005-11-29T12:11:12Z\" m:reason=\"deleted\">"\
	"<at:comment>Removed comment spam</at:comment>"\
	"<at:by>"\
	"<name>John Doe</name>"\
	"<email>jdoe@example.org</email>"\
	"</at:by>"\
	"</at:deleted-entry>"\
	"</feed>";
	
	NSData *nonUTF8Data = [str dataUsingEncoding:NSUTF8StringEncoding];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_ctx];
	[atom EnumerateObjects:theXMLDocument  queryResponseObject:queryOperationResponse];
	
	[atom release];
	[handler release];
	
	NSArray *arr=[queryOperationResponse getResult];
	for (int i=0; i<[arr count]; i++) {
	
		id object=[arr objectAtIndex:i];
		if([object isKindOfClass:[ODataDeletedObject class]])
		{
			//process deleted object
			EventModel_DeletedSession *delSession=[arr objectAtIndex:i];
			NSLog(@"keyValues=%@",[[delSession getKeyValues] description]);
			NSLog(@"personInfo=%@",[[delSession getPersonInfo] description]);
			NSLog(@"objectId...%@",delSession.m_objectID);
			NSLog(@"timeStamp..%@",delSession.m_timestamp);
			NSLog(@"baseURI....%@",delSession.m_OData_baseURI);
			NSLog(@"Comment....%@",[delSession getComment]);
		}
		else{
			//process add or update
			EventModel_Tweet *tweets=[arr objectAtIndex:i];	
			NSLog(@"Author...%@",[tweets getAuthor]);
			NSLog(@"tweet...%@",[tweets getText]);
		}
	}
	[cred release];
	[m_ctx release];
}*/

-(void)expandQuery
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	eventsEntities *m_ctx=[[eventsEntities alloc] initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc/" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	
	DataServiceQuery *query = [m_ctx sessions];
	/*[query orderBy:@"SessionID"];
	[query expand:@"Speakers"];
	[query expand:@"Tweets"];*/
	
	[query orderBy:@"SessioniD"];
	[query expand:@"Speakers"];
	[query expand:@"Tweets"];
	[query top:10];
	[query skip:9];
	[query select:@"SessionID"];
	[query includeTotalCount:@"allpages"];
	
	
	/*[query orderBy:@"SessionID"];
	[query top:10];
	[query skip:8];
	[query filter:@"Title eq 'xyz'"];
	[query select:@"SessionID"];
	[query expand:@"Tweets"];
	[query addQueryOption:@"format" query:@"atom"];
	[query includeTotalCount:@"allpages"];*/
	
	
	
	QueryOperationResponse *response = [query execute];
	NSArray *arr=[response getResult];
	NSLog(@"Number Of deleted/inserted/updated Entries.....%d",[arr count]);
	
	[cred release];
	[m_ctx release];
	
}
-(void)testDataservices
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	DemoService *m_ctx=[[DemoService alloc] initWithUri:@"http://services.odata.org/OData/OData.svc/" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	
	DataServiceQuery *query = [m_ctx products];
	[query top:5];
	
	QueryOperationResponse *response = [query execute];
	NSArray *arr=[response getResult];
	NSLog(@"Number Of deleted/inserted/updated Entries.....%d",[arr count]);
	[cred release];
	[m_ctx release];
	
}
-(void)testNorthwindEntities
{
	
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	NorthwindEntities *m_ctx=[[NorthwindEntities alloc] initWithUri:@"http://services.odata.org/Northwind/Northwind.svc/" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	
	DataServiceQuery *query = [m_ctx customers];
	[query filter:@"substringof('Alfreds', CompanyName) eq true"];	
	QueryOperationResponse *response = [query execute];
	NSArray *arr=[response getResult];
	NSLog(@"Number Of deleted/inserted/updated Entries.....%d",[arr count]);
	[cred release];
	[m_ctx release];
}

#pragma mark add/delete/update FUNCTION
/*-(void)testDeltaForNorthwindEntities
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	NorthwindEntities *m_ctx=[[NorthwindEntities alloc] initWithUri:@"http://northwinddelta.cloudapp.net/DeltaService.svc" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	
	DataServiceQuery *query = [m_ctx products];
	//NSString *count=[query count];
	//[query skip:[count intValue]];
	QueryOperationResponse *response = [query execute];
	
	DataServiceQueryContinuation *continuation=nil;
	DataServiceDeltaQuery *deltaQuery = nil;
	
	if([response hasDelta])
		deltaQuery = [response getDeltaQuery];
	
	if ([deltaQuery hasDelta]) {
		response =[m_ctx executeDSDeltaQuery:deltaQuery];
		do
		{
			resultArray=[response getResult];
			//process deltas
			int count=[resultArray count];
			NSLog(@"Number Of deleted/inserted/updated Entries.....%d",count);
			/*for (int i=0; i<count; i++)
			 {
			 id object=[resultArray objectAtIndex:i];
			 if([object isKindOfClass:[ODataDeletedObject class]])
			 {
			 //process deleted object
			 EventModel_DeletedSession *delSession=[resultArray objectAtIndex:i];
			 NSLog(@"keyValues=%@",[[delSession getKeyValues] description]);
			 NSLog(@"objectId...%@",delSession.m_objectID);
			 NSLog(@"timeStamp..%@",delSession.m_timestamp);
			 NSLog(@"baseURI....%@",delSession.m_OData_baseURI);
			 }
			 else{
			 //process add or update
			 EventModel_Tweet *tweets=[resultArray objectAtIndex:i];	
			 NSLog(@"Author...%@",[tweets getAuthor]);
			 NSLog(@"tweet...%@",[tweets getText]);
			 }
			 
			 }
			//check if there is continuation
			continuation=[response getContinuation:nil];
			if([continuation getNextLinkUri] !=nil)
				response=[m_ctx executeDSQueryContinuation:continuation];
			else
				continuation =nil;
		}while(continuation !=nil);    
	}
	
	
	[cred release];
	[m_ctx release];
}*/

/*-(void)testDeltaForNetflix
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	NetflixCatalog *m_ctx=[[NetflixCatalog alloc] initWithUri:@"http://netflixdeltaservice.cloudapp.net/v1/Catalog/" credential:cred];
	[m_ctx setDataServiceVersion:@"2.0"];
	
	DataServiceQuery *query = [m_ctx titles];
	NSString *count=[query count];
	[query skip:[count intValue]];
	QueryOperationResponse *response = [query execute];
	
	DataServiceQueryContinuation *continuation=nil;
	DataServiceDeltaQuery *deltaQuery = nil;
	
	if([response hasDelta])
		deltaQuery = [response getDeltaQuery];
	
	if ([deltaQuery hasDelta]) {
		response =[m_ctx executeDSDeltaQuery:deltaQuery];
		do
		{
			resultArray=[response getResult];
			//process deltas
			int count=[resultArray count];
			NSLog(@"Number Of deleted/inserted/updated Entries.....%d",count);
			/*for (int i=0; i<count; i++)
			 {
			 id object=[resultArray objectAtIndex:i];
			 if([object isKindOfClass:[ODataDeletedObject class]])
			 {
			 //process deleted object
			 EventModel_DeletedSession *delSession=[resultArray objectAtIndex:i];
			 NSLog(@"keyValues=%@",[[delSession getKeyValues] description]);
			 NSLog(@"objectId...%@",delSession.m_objectID);
			 NSLog(@"timeStamp..%@",delSession.m_timestamp);
			 NSLog(@"baseURI....%@",delSession.m_OData_baseURI);
			 }
			 else{
			 //process add or update
			 EventModel_Tweet *tweets=[resultArray objectAtIndex:i];	
			 NSLog(@"Author...%@",[tweets getAuthor]);
			 NSLog(@"tweet...%@",[tweets getText]);
			 }
			 
			 }
			//check if there is continuation
			continuation=[response getContinuation:nil];
			if([continuation getNextLinkUri] !=nil)
				response=[m_ctx executeDSQueryContinuation:continuation];
			else
				continuation =nil;
		}while(continuation !=nil);    
	}
	
	[cred release];
	[m_ctx release];
}*/

-(void)addObjectDemoService
{
	WindowsCredential *cred=[[WindowsCredential alloc]initWithUserName:@"tejashri_rote" password:@"mnbv!234"];
	DemoService *ctx=[[DemoService alloc]initWithUri:@"http://services.odata.org/OData/OData.svc" credential:cred];
	ODataDemo_Product *aProduct=[[ODataDemo_Product alloc]initWithUri:nil];
	[aProduct setName:@"15AprilProduct"];
	[ctx addToProducts:aProduct];
	//[ctx setSaveChangesOptions:1];
	[ctx saveChanges];
	[cred release];[ctx release];
}


-(void)testResultArrayForNil
{
	eventsEntities *m_ctx=[[eventsEntities alloc] initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc/" credential:nil];
	[m_ctx setDataServiceVersion:@"2.0"];
	QueryOperationResponse *queryOperationResponse = [[QueryOperationResponse alloc ]init];

	NSData *nonUTF8Data = [[NSData alloc] init];
	ODataXMlParser *handler = [[ODataXMlParser alloc] init];
	ODataXMLElements *theXMLDocument = [handler parseData:nonUTF8Data];
	AtomParser *atom = [[AtomParser alloc] initwithContext:m_ctx];
	[atom EnumerateObjects:theXMLDocument queryResponseObject:queryOperationResponse];
	[atom release];
	
	//QueryOperationResponse *response = [query execute];
	resultArray =[[queryOperationResponse getResult] retain];
	NSLog(@"resultarray...%d",[resultArray count]);
	
	[m_ctx release];
	
}
-(void) testTweetsCount
 {
	 eventsEntities *proxy=[[eventsEntities alloc]initWithUri:@"http://mixwithtweets.cloudapp.net/OData.svc" credential:nil];
	 [proxy setDataServiceVersion:@"2.0"];
 
	 DataServiceQuery *query = [proxy tweets];
	// NSString *count=[query count];
	// [query skip:[count intValue]];
	 [query skip:130];
	 QueryOperationResponse *response = [query execute];
	 resultArray =[[response getResult] retain];
	 NSLog(@"resultarray...%d",[resultArray count]);
	 
 }
#pragma mark viewDidLoad method
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	@try 
	{
		//[self testResultArrayForNil];
		//[self addObjectDemoService];
		//[self testDataservices];
		//[self testNorthwindEntities];
		//[self expandQuery];
		//[self testForCommentInTweets];
		[self testTweetsCount];
		//[self testMixResProcessor];
		//[self  chkNameSpaceProblem];	
		//[self testDeltaForNorthwindEntities];
		//[self testDeltaForNetflix];
	}
	@catch (DataServiceRequestException * e) 
	{
		NSLog(@"exception = %@, %@, %@",[e name],[e reason],[[e getResponse] getError]);
	}	
	@catch (ODataServiceException * e) 
	{
		NSLog(@"exception = %@, %@, %@",[e name],[e reason],[e getDetailedError]);
	
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
   // return [resultArray count];
	return 10;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	/*if([resultArray count] > 0 )
	{
		NetflixCatalog_Model_Title *t = [resultArray objectAtIndex:indexPath.row];
		//cell.textLabel.text = [t getShortName];
		
	}*/
	return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
/*	NetflixCatalog_Model_Title *t = [resultArray objectAtIndex:indexPath.row];
	DetailsViewController *details = [[DetailsViewController alloc] initWithStyle:UITableViewStylePlain];
	details.items = t;
	[[self navigationController] pushViewController:details animated:YES];
	[details release];*/
}


- (void)dealloc {
    [super dealloc];
}

- (void)onBeforeSend:(HttpRequest *)request {
}


@end

