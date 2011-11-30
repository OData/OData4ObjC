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



@interface mProperties : NSObject
{
	NSString	*m_EdmType;
	NSString	*m_MaxLength;
	NSString	*m_MinLength;
	
	BOOL		m_FixedLength;
	BOOL		m_Nullable;
	BOOL		m_Unicode;
	
	NSString	*m_ConcurrencyMode;
	NSString	*m_FC_TargetPath;
	BOOL		m_FC_KeepInContent;
	NSString	*m_FC_SourcePath;
	NSString	*m_FC_ContentKind;
	NSString	*m_FC_NsPrefix;
	NSString	*m_FC_NsUri;
}
@property(nonatomic,retain,	getter=getEdmType,			setter=setEdmType			) NSString *m_EdmType;
@property(nonatomic,retain,	getter=getMaxLength,		setter=setMaxLength			) NSString *m_MaxLength;
@property(nonatomic,retain,	getter=getMinLength,		setter=setMinLength			) NSString *m_MinLength;

@property(nonatomic,assign,	getter=getFixedLength,		setter=setFixedLength		) BOOL m_FixedLength;
@property(nonatomic,assign,	getter=getNullable,			setter=setNullable			) BOOL m_Nullable;
@property(nonatomic,assign,	getter=getUnicode,			setter=setUnicode			) BOOL m_Unicode;

@property(nonatomic,retain,	getter=getConcurrencyMode,	setter=setConcurrencyMode	) NSString *m_ConcurrencyMode;
@property(nonatomic,retain,	getter=getFC_TargetPath,	setter=setFC_TargetPath		) NSString *m_FC_TargetPath;
@property(nonatomic,assign,	getter=getFC_KeepInContent,	setter=setFC_KeepInContent	) BOOL m_FC_KeepInContent;
@property(nonatomic,retain,	getter=getFC_SourcePath,	setter=setFC_SourcePath		) NSString *m_FC_SourcePath;
@property(nonatomic,retain,	getter=getFC_ContentKind,	setter=setFC_ContentKind	) NSString *m_FC_ContentKind;
@property(nonatomic,retain,	getter=getFC_NsPrefix,		setter=setFC_NsPrefix		) NSString *m_FC_NsPrefix;
@property(nonatomic,retain,	getter=getFC_NsUri,			setter=setFC_NsUri			) NSString *m_FC_NsUri;

-(id)init;
-(id)initWithEdmType:(NSString *)anEdmType MaxLength:(NSString *)theMaxLength MinLength:(NSString *)theMinLength FixedLength:(BOOL)isFixedLength Nullable:(BOOL)isNullable
			 Unicode:(BOOL)isUnicode ConcurrencyMode:(NSString *)aConcurrencyMode FC_TargetPath:(NSString *)aFC_TargetPath FC_KeepInContent:(BOOL)isFC_KeepInContent
	   FC_SourcePath:(NSString *)aFC_SourcePath FC_ContentKind:(NSString *)aFC_ContentKind FC_NsPrefix:(NSString *)aFC_NsPrefix FC_NsUri:(NSString *)aFC_NsUri;
@end

