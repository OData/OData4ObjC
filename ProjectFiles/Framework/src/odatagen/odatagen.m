
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
#import <Cocoa/Cocoa.h>
#include <string.h>
#include<stdio.h>
#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>

#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>

#import "HTTPHandler.h"
#import "ACSUtil.h"



/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to create header file with extension .h
 * PARAMETER    : xml file which is to be parsed, output file name with path
 * RETURN VALUE : void
 *************************************************************************************************************************************************************************************/

xmlDocPtr xsltParce(const char *xmlfilename,NSString* filePath,xsltStylesheetPtr *cur)
{
	xmlDocPtr doc, res;

	*cur = xsltParseStylesheetFile((const xmlChar *)[filePath UTF8String]);// .xsl
	doc = xmlParseFile(xmlfilename);//Parse the Input File
	res = xsltApplyStylesheet(*cur, doc, NULL);
	xmlFreeDoc(doc);
	return res;
}
void CreateHeaderFile(const char * xmlfilename,const char* OutFileName)
{
	xsltStylesheetPtr curBase = NULL,curDerived=NULL;
	xmlDocPtr resBase,resDerived;BOOL isDir, exists = NO;
	NSString *dirPath;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *mainPath = [[NSBundle mainBundle] bundlePath];
	
	dirPath = [mainPath stringByAppendingString:@"/objc_baseClasses.xsl"];
	exists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
	if (exists) {
			 resBase =xsltParce(xmlfilename,dirPath,&curBase);
	}else{
		@throw [NSException exceptionWithName:@"File Not Found" reason:@"objc_baseClasses.xsl file not found" userInfo:nil];
	}
	
	isDir, exists = NO;
		
	dirPath = [mainPath stringByAppendingString:@"/objc_headers.xsl"];
	exists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
	if (exists) {
		 resDerived=xsltParce(xmlfilename,dirPath,&curDerived);
	}else{
		@throw [NSException exceptionWithName:@"File Not Found" reason:@"objc_headers.xsl file not found" userInfo:nil];
	}
	
	[fileManager release];
	
	FILE *fp=fopen(OutFileName, "w+");	
	if(fp==NULL)
		printf("odatagen: Failed to create header file. Please verify the output path.\n");
	else
	{
		xsltSaveResultToFile(fp, resBase, curBase);
		xsltSaveResultToFile(fp, resDerived, curDerived);
		fclose(fp);
		fp=NULL;
	}	
	xsltFreeStylesheet(curBase);
	xmlFreeDoc(resBase);
	xsltFreeStylesheet(curDerived);
	xmlFreeDoc(resDerived);
	xsltCleanupGlobals();
	xmlCleanupParser();	
}

/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to create implementation file with extension .m
 * PARAMETER    : xml file which is to be parsed, output file name with path,file name
 * RETURN VALUE : void
 *************************************************************************************************************************************************************************************/

void CreateImplementationFile(const char * xmlfilename,const char* OutFileName,NSString* fileName)
{
	xsltStylesheetPtr cur = NULL;
	xmlDocPtr doc, res;FILE *fp;
	

	BOOL isDir, exists = NO;
	NSString *dirPath;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *mainPath = [[NSBundle mainBundle] bundlePath];
		
	dirPath = [mainPath  stringByAppendingString:@"/objc_implementation.xsl"];
	exists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
	if (exists) {
		cur = xsltParseStylesheetFile((const xmlChar *)[dirPath UTF8String]);// .xsl
		doc = xmlParseFile(xmlfilename);//Parse the Input File
		res=xsltApplyStylesheet(cur, doc, NULL);
	}else{
		@throw [NSException exceptionWithName:@"File Not Found" reason:@"objc_implementation.xsl file not found" userInfo:nil];
	}
	
	[fileManager release];

	
	NSString *temp=@"#import ";
	temp=[temp stringByAppendingFormat:@"\"%@.h\"\n",fileName];
	
	dirPath = [mainPath stringByAppendingString:@"/copyrightInfo.xsl"];	
	exists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
	if (!exists) 
		@throw [NSException exceptionWithName:@"File Not Found" reason:@"copyrightInfo.xsl file not found" userInfo:nil];
	
	NSString *copyrightInfo=[NSString stringWithContentsOfFile:dirPath encoding:NSUTF8StringEncoding error:nil];
	
	copyrightInfo= [copyrightInfo stringByAppendingString:temp];
	const char *buffer=[copyrightInfo UTF8String];	
	
		fp=fopen(OutFileName, "w+");	
	
		if(fp==NULL)
			printf("odatagen: Failed to create implementation file. Please verify the output path.\n");
		else
		{
			fwrite(buffer, 1,strlen(buffer), fp);
			xsltSaveResultToFile(fp, res, cur);	
			fclose(fp);
			fp=NULL;
		}
	
	xsltFreeStylesheet(cur);
	xmlFreeDoc(res);
	xmlFreeDoc(doc);
	xsltCleanupGlobals();
	xmlCleanupParser();	
}

/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to get the file name
 * PARAMETER    : xml file which is to be parsed
 * RETURN VALUE : string 
 *************************************************************************************************************************************************************************************/

NSString* getFileName(const char * xmlfilename)
{
	xsltStylesheetPtr cur = NULL;
	xmlDocPtr doc, res;FILE *fp;
	char filename[2048]={0};
	BOOL isDir, exists = NO;
	NSString *dirPath;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *mainPath = [[NSBundle mainBundle] bundlePath];
		
		dirPath = [mainPath stringByAppendingString:@"/objc_filename.xsl"];
		exists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
		if (exists) {
			cur = xsltParseStylesheetFile((const xmlChar *)[dirPath UTF8String]);// .xsl
			doc = xmlParseFile(xmlfilename);//Parse the Input File
			res=xsltApplyStylesheet(cur, doc, NULL);
		}else
			@throw [NSException exceptionWithName:@"File Not Found" reason:@"objc_filename.xsl file not found" userInfo:nil];
	
	fp=fopen("filename", "w+");
	if(fp==NULL)
		printf("\nodatagen: Failed to get filename");
	
	xsltSaveResultToFile(fp, res, cur);
	
	int size=ftell(fp);
	if(size>0)
	{
		fseek(fp, 0, SEEK_SET);
		fread(filename,1,size, fp);
	}
	fclose(fp);
	fp=NULL;
	remove("filename");
	
	xsltFreeStylesheet(cur);
	xmlFreeDoc(res);
	xmlFreeDoc(doc);
	xsltCleanupGlobals();
	xmlCleanupParser();
	
	return [NSString stringWithUTF8String: filename];
}


/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to get metadata from uri
 * PARAMETER    : uri 
 * RETURN VALUE : string
 *************************************************************************************************************************************************************************************/

NSString* getDataFromUri(NSString* uri,NSMutableDictionary *headers)
{    
	HTTPHandler *handle=[[HTTPHandler alloc]init];

	if([[headers objectForKey:@"/auth"] caseInsensitiveCompare:@"windows"] == NSOrderedSame)
		[handle performHTTPRequest:uri username:[headers objectForKey:@"/u"] password:[headers objectForKey:@"/p"] headers:nil httpbody:nil httpmethod:@"GET"];
		
	else if([[headers objectForKey:@"/auth"] caseInsensitiveCompare:@"acs"] == NSOrderedSame)
	{
		
		ACSUtil *util=[[ACSUtil alloc]initWithServiceName:[headers objectForKey:@"/sn"] wrapName:[headers objectForKey:@"/u"] wrapPassword:[headers objectForKey:@"/p"] wrapScope:[headers objectForKey:@"/at"] claims:[headers objectForKey:@"/claims"]];
		
		NSMutableDictionary *requestHeaders  =[util getSignedHeaders];
		[handle performHTTPRequest:uri username:nil password:nil headers:requestHeaders httpbody:nil httpmethod:@"GET"];
		[util release];
	}
	else
		[handle performHTTPRequest:uri username:nil password:nil headers:nil httpbody:nil httpmethod:@"GET"];
	
	
	NSString *httpRawResponse;
	NSString *contentString = [handle.http_response_headers objectForKey:@"Content-Type"];
	NSRange range=[contentString rangeOfString:@"="];
	if([[contentString substringFromIndex:range.location+1] compare:@"utf-8"] == NSOrderedSame)
	{
		httpRawResponse = [[NSString alloc] initWithData:[handle http_response] encoding:NSUTF8StringEncoding];
	}else
	{
		@throw [NSException exceptionWithName:@"Invalid Content-Type" reason:@"" userInfo:nil];
	}
		
	[handle release];
	return [httpRawResponse autorelease];
}

/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to get metadata from uri and save it to a file
 * PARAMETER    : uri
 * RETURN VALUE : boolean value
 *************************************************************************************************************************************************************************************/

BOOL downloadAndSaveMetaDataInFile(NSString *uri,NSMutableDictionary *headers)
{	
	BOOL res = NO;
	@try
	{
		NSString *tmp =[getDataFromUri(uri,headers) retain];
		if(tmp)
		{
			const char * data = [tmp cStringUsingEncoding:NSASCIIStringEncoding];
			if(data != NULL && strlen(data) > 0 )
			{
				FILE *fp;
				fp=fopen("metadata.xml", "w+");
				if(fp)
				{
					fwrite(data, strlen(data), 1, fp);
					fclose(fp);
					res = YES;
				}
			}
		}
	}
	@catch (NSException *exception) 
	{
		NSLog(@"%@::%@",[exception name],[exception reason]);
		res=NO;
	}	
	return res;
}
/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to check for valididity of /claims options
 * PARAMETER    : NSString containing key=pair values for option 
 * RETURN VALUE : dictionary with all key=pair options
 *************************************************************************************************************************************************************************************/
NSMutableDictionary* claimsValidation (NSString* claimString)
{
	if ([claimString compare:@""]==NSOrderedSame) {
		@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"odatagen :Specify value for /claims=" userInfo:nil];
	}

	NSMutableDictionary *claimDict=[[NSMutableDictionary alloc] init];
	NSArray *arr=[claimString componentsSeparatedByString:@","];
	for (int i=0; i<[arr count]; i++) {
		NSRange range=[[arr objectAtIndex:i] rangeOfString:@"="];
		[claimDict setObject:[[arr objectAtIndex:i] substringFromIndex:range.location+1] forKey:[[arr objectAtIndex:i] substringToIndex:range.location]];
	}
	return [claimDict autorelease];
}

/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : Function to check for valid options
 * PARAMETER    : number of options, all the options
 * RETURN VALUE : dictionary with all options
 *************************************************************************************************************************************************************************************/


NSMutableDictionary *validateOptions(int argc, const char * argv[])
{
	
	NSMutableDictionary *options=nil;
	NSMutableArray *validOptions=nil;
	NSMutableArray *array=nil;
	
	@try 
	{	
		if(argc==1)
		{
			@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"\nodatagen: Usage: odatagen [/uri=<data service Uri> | /metadata=<service metadata file>] [/out=<output file path>][/auth=windows|acs /u=username /p=password [/sn=servicenamespace /at=applies_to]][/ups=yes|no]" userInfo:nil];
		}
		
		options=[[NSMutableDictionary alloc]init];
		validOptions=[[NSMutableArray alloc]initWithObjects:@"/uri",@"/metadata",@"/out",@"/auth",@"/u",@"/p",@"/sn",@"/at",@"/ups",nil];
		array=[[NSMutableArray alloc]init];
		
		for(int i=1;i<argc;i++)
		{	
			NSString *temp=[NSString stringWithUTF8String:argv[i]];
			NSRange range=[temp rangeOfString:@"="];
			
			if(range.location==NSNotFound)
			{
				@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"Make sure the format of all commandline options are parameter=value" userInfo:nil];
			}
			//claims
			if ([[temp substringToIndex:range.location] compare:@"/claims"]==NSOrderedSame) 
			{
				[validOptions addObject:@"/claims"];
			}
			if(![validOptions containsObject:[temp substringToIndex:range.location]])
			{
				@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"Make sure all commandline options are valid options" userInfo:nil];
			}
			//claims
			if ([[temp substringToIndex:range.location] compare:@"/claims"]==NSOrderedSame) 
			{
				[array addObject:[temp substringToIndex:range.location]];
				[array addObject:claimsValidation([temp substringFromIndex:range.location+1])];
			}else
			{			
				 [array addObject:[temp substringToIndex:range.location]];
				 [array addObject:[temp substringFromIndex:range.location+1]];
			 }
				 
			if([options objectForKey:[array objectAtIndex:0]]!=nil)
			{
				@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"Option cannot be repeated" userInfo:nil];
			}
			[options setObject:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
			[array removeAllObjects];
		}
		
		NSArray *arrOptions=[options allKeys];
		
		if(!([arrOptions containsObject:@"/uri"] || [arrOptions containsObject:@"/metadata"]))
			@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"odatagen :Specify input path /uri= or /metadata=" userInfo:nil];
		
		if([[options objectForKey:@"/uri"] isEqualToString:@""] || [[options objectForKey:@"/metadata"] isEqualToString:@""])
			@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"odatagen :Specify value for /uri= or /metadata=" userInfo:nil];
		
		if([arrOptions containsObject:@"/uri"] && [arrOptions containsObject:@"/metadata"])
			@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"Invalid path usage.Using '/uri' and '/metadata' together not allowed" userInfo:nil];

		if(!([arrOptions containsObject:@"/out"]))
			@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"odatagen :Specify output file path /out=" userInfo:nil];
		
		if([arrOptions containsObject:@"/auth"])
		{
			NSString *authstr=[options valueForKey:@"/auth"];
			
			if([authstr caseInsensitiveCompare:@"windows"] == NSOrderedSame)
			{
				//check for claim values
				if(!([arrOptions containsObject:@"/u"] && [arrOptions containsObject:@"/p"]) || ([arrOptions containsObject:@"/sn"] && [arrOptions containsObject:@"/at"]))
					@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"Using authentication type \'windows\' requires /u and /p to be present only" userInfo:nil];
				
			}
			else if([authstr caseInsensitiveCompare:@"acs"]== NSOrderedSame)
			{
				if(!([arrOptions containsObject:@"/u"] && [arrOptions containsObject:@"/p"] &&
					 [arrOptions containsObject:@"/sn"] && [arrOptions containsObject:@"/at"]))
					@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"Using authentication type \'acs\' requires /u /p /sn and /at to be present" userInfo:nil];
			}
			else
				@throw [NSException exceptionWithName:@"Invalid arguments" reason:@"value of auth option is not valid" userInfo:nil];
		}
		
		if(!([arrOptions containsObject:@"/ups"]))		
			[options setObject:[NSNumber numberWithBool:YES] forKey:@"/ups"];
		
	}
	@catch (NSException * exception) {
		NSLog(@"%@: %@",[exception name],[exception reason]);
		return nil;
	}
	@finally {
		[validOptions release];
		validOptions=nil;
		[array release];
		array=nil;
	}
	return [options autorelease];
}
				 

/*************************************************************************************************************************************************************************************
 * DESCRIPTION  : entry point function.
 * PARAMETER    : the uri or metadata as argv[1], the output file path as argv[2]
 * RETURN VALUE : int
 *************************************************************************************************************************************************************************************/

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary* headers=validateOptions(argc,argv);
	
	NSError *err=nil; BOOL isDir=NO;
	@try{
		NSFileManager *fileManager=[NSFileManager defaultManager];
		NSString* mainPath=[[NSBundle mainBundle] bundlePath];
		NSRange range=[mainPath rangeOfString:@"Debug"];
		if (range.location != NSNotFound) {
		
				NSRange fileRange=[mainPath rangeOfString:@"build"];
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_filename.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[[mainPath substringToIndex:fileRange.location] stringByAppendingString:@"objc_filename.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_filename.xsl"] error:&err];
				
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_baseClasses.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[[mainPath substringToIndex:fileRange.location] stringByAppendingString:@"objc_baseClasses.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_baseClasses.xsl"] error:&err];
				
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_headers.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[[mainPath substringToIndex:fileRange.location] stringByAppendingString:@"objc_headers.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_headers.xsl"] error:&err];
				
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_implementation.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[[mainPath substringToIndex:fileRange.location] stringByAppendingString:@"objc_implementation.xsl"]	toPath:[mainPath  stringByAppendingString:@"/objc_implementation.xsl"] error:&err];
			
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/copyrightInfo.xsl"] isDirectory:&isDir]) 	
					[fileManager copyItemAtPath:[[mainPath substringToIndex:fileRange.location] stringByAppendingString:@"copyrightInfo.xsl"] toPath:[mainPath stringByAppendingString:@"/copyrightInfo.xsl"] error:&err];
		
			if (err) 
				@throw [NSException exceptionWithName:@"Error While moving xslt file " reason: [err localizedDescription] userInfo:nil];
		
		}else{
				NSRange fileRange=[mainPath rangeOfString:@"bin"];
				if (fileRange.location == NSNotFound) 
					@throw [NSException exceptionWithName:@"fileRange Error While moving xslt file " reason: [err localizedDescription] userInfo:nil];
			
				NSString *filePath = [[mainPath substringToIndex:fileRange.location] stringByAppendingString:@"src/odatagen"];
			
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_filename.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[filePath stringByAppendingString:@"/objc_filename.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_filename.xsl"] error:&err];
			
						
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_baseClasses.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[filePath stringByAppendingString:@"/objc_baseClasses.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_baseClasses.xsl"] error:&err];
			
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_headers.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[filePath stringByAppendingString:@"/objc_headers.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_headers.xsl"] error:&err];
			
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/objc_implementation.xsl"] isDirectory:&isDir]) 
					[fileManager copyItemAtPath:[filePath stringByAppendingString:@"/objc_implementation.xsl"] toPath:[mainPath stringByAppendingString:@"/objc_implementation.xsl"] error:&err];
			
				if (![fileManager fileExistsAtPath:[mainPath stringByAppendingString:@"/copyrightInfo.xsl"] isDirectory:&isDir]) 
						[fileManager copyItemAtPath:[filePath stringByAppendingString:@"/copyrightInfo.xsl"] toPath:[mainPath stringByAppendingString:@"/copyrightInfo.xsl"] error:&err];
			
			if (err) 
				@throw [NSException exceptionWithName:@"Error While moving xslt file " reason: [err localizedDescription] userInfo:nil];
				
		}
		
		if(headers!=nil)
		{
			[headers retain];
			NSString *outDirPath=nil;
			NSString *outPut=[headers objectForKey:@"/out"];
			if(outPut)
			{
				outDirPath=[outPut stringByAppendingString:@"/"];
			}	
			else 
			{
				outDirPath=@"./";
			}

			if([headers objectForKey:@"/uri"])
			{
				NSString *uri = [headers objectForKey:@"/uri"];
				if(![uri hasSuffix:@"$metadata"])
				{
					if([uri hasSuffix:@"/"])
						uri=[uri stringByAppendingString:@"$metadata"];
					else 
						uri=[uri stringByAppendingString:@"/$metadata"];	
				}
				if(downloadAndSaveMetaDataInFile(uri,headers)==NO)
				{
					NSLog(@"odatagen: Error in saving metadata");
				}
				else
				{
					NSString *filename= getFileName("./metadata.xml");
				
					if([filename length]!=0)
					{
						outDirPath=[outDirPath stringByAppendingString:filename];
					
						NSString *outFileName=[outDirPath stringByAppendingString:@".h"];
						const char* outFile=[outFileName cStringUsingEncoding:NSUTF8StringEncoding];
						CreateHeaderFile("./metadata.xml",outFile);
					
						outFileName=[outDirPath stringByAppendingString:@".m"];
						outFile=[outFileName cStringUsingEncoding:NSUTF8StringEncoding];
						CreateImplementationFile("./metadata.xml",outFile,filename);
						remove("./metadata.xml");
					}
					else 
					{
						NSLog(@"odatagen: Failed to generate proxy classes. Please verify the metadata.");
					}
				}
			}
			else if([headers objectForKey:@"/metadata"])
			{
				NSString *uri = [headers objectForKey:@"/metadata"];
				xmlSubstituteEntitiesDefault(1);//to substitute entities
				xmlLoadExtDtdDefaultValue = 1;//to load external entity subsets
			
				const char* path=[uri cStringUsingEncoding:NSUTF8StringEncoding];
			
				NSString *filename= getFileName(path);
				if([filename length]!=0)
				{
					outDirPath=[outDirPath stringByAppendingString:filename];
				
					NSString *outFileName=[outDirPath stringByAppendingString:@".h"];
					const char* outFile=[outFileName cStringUsingEncoding:NSUTF8StringEncoding];
					CreateHeaderFile(path,outFile);
				
					outFileName=[outDirPath stringByAppendingString:@".m"];
					outFile=[outFileName cStringUsingEncoding:NSUTF8StringEncoding];
					CreateImplementationFile(path,outFile,filename);
				}
				else
				{
					NSLog(@"odatagen: Failed to generate proxy classes. Please verify the metadata.");
				}			
			}
			else
			{
				NSLog(@"odatagen:Specify the input type /metadata= or /uri=\n");
			}
		}
	}@catch (NSException * exception) {
			NSLog(@"%@: %@",[exception name],[exception reason]);
		}
		
    [pool drain];
    return 0;
}

