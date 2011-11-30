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

#import "mProperties.h"



@implementation mProperties
@synthesize m_EdmType;
@synthesize m_MaxLength;
@synthesize m_MinLength;
@synthesize m_FixedLength;
@synthesize m_Nullable;
@synthesize m_Unicode;
@synthesize m_ConcurrencyMode;
@synthesize m_FC_TargetPath;
@synthesize m_FC_KeepInContent;
@synthesize m_FC_SourcePath;
@synthesize m_FC_ContentKind;
@synthesize m_FC_NsPrefix;
@synthesize m_FC_NsUri;

-(id)init
{
	if(self=[super init])
	{
		[self setEdmType:@""];
		[self setMaxLength:@""];
		[self setMinLength:@""];
		[self setFixedLength:NO];
		[self setNullable:NO];
		[self setUnicode:NO];
		[self setConcurrencyMode:@""];
		[self setFC_TargetPath:@""];
		[self setFC_KeepInContent:YES];
		[self setFC_SourcePath:@""];
		[self setFC_ContentKind:@""];
		[self setFC_NsPrefix:@""];
		[self setFC_NsUri:@""];
	}
	return self;
}

-(id)initWithEdmType:(NSString *)anEdmType MaxLength:(NSString *)theMaxLength MinLength:(NSString *)theMinLength FixedLength:(BOOL)isFixedLength Nullable:(BOOL)isNullable
			 Unicode:(BOOL)isUnicode ConcurrencyMode:(NSString *)aConcurrencyMode FC_TargetPath:(NSString *)aFC_TargetPath FC_KeepInContent:(BOOL)isFC_KeepInContent
	   FC_SourcePath:(NSString *)aFC_SourcePath FC_ContentKind:(NSString *)aFC_ContentKind FC_NsPrefix:(NSString *)aFC_NsPrefix FC_NsUri:(NSString *)aFC_NsUri
{
	if(self=[super init])
	{
		if(anEdmType)
			[self setEdmType:[NSString stringWithFormat:@"%@",anEdmType]];
		
		if(theMaxLength)
			[self setMaxLength:[NSString stringWithFormat:@"%@",theMaxLength]];
		
		if(theMinLength)
			[self setMinLength:[NSString stringWithFormat:@"%@",theMinLength]];
		
		[self setFixedLength:isFixedLength];
		[self setNullable:isNullable];
		[self setUnicode:isUnicode];
		
		if(aConcurrencyMode)
			[self setConcurrencyMode:[NSString stringWithFormat:@"%@",aConcurrencyMode]];
		
		if(aFC_TargetPath)
			[self setFC_TargetPath:[NSString stringWithFormat:@"%@",aFC_TargetPath]];
		
		[self setFC_KeepInContent:isFC_KeepInContent];
		
		if(aFC_SourcePath)
			[self setFC_SourcePath:[NSString stringWithFormat:@"%@",aFC_SourcePath]];
		
		if(aFC_ContentKind)
			[self setFC_ContentKind:[NSString stringWithFormat:@"%@",aFC_ContentKind]];
		
		if(aFC_NsPrefix)
			[self setFC_NsPrefix:[NSString stringWithFormat:@"%@",aFC_NsPrefix]];
		
		if(aFC_NsUri)
			[self setFC_NsUri:[NSString stringWithFormat:@"%@",aFC_NsUri]];
	}
	return self;
}

-(void) dealloc
{
	[m_EdmType release];
	m_EdmType=nil;
	[m_MaxLength release];
	m_MaxLength=nil;
	[m_MinLength release];
	m_MinLength=nil;
 
	[m_ConcurrencyMode release];
	m_ConcurrencyMode=nil;
	[m_FC_TargetPath release];
	m_FC_TargetPath=nil;
 
	[m_FC_SourcePath release];
	m_FC_SourcePath=nil;
	[m_FC_ContentKind release];
	m_FC_ContentKind=nil;
	[m_FC_NsPrefix release];
	m_FC_NsPrefix=nil;
	[m_FC_NsUri release];
	m_FC_NsUri=nil;
	
	[super dealloc];
}
@end
