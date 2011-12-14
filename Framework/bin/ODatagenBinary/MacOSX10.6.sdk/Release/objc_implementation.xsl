<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx"
xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices"
xmlns:schema_1_0="http://schemas.microsoft.com/ado/2006/04/edm"
xmlns:schema_1_1="http://schemas.microsoft.com/ado/2007/05/edm"
xmlns:schema_1_2="http://schemas.microsoft.com/ado/2008/09/edm"
xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">
<xsl:output method="text"/>
<!-- Service NameSpace-->
<xsl:variable name="service_namespace" select="concat(//schema_1_0:EntityType/../@Namespace, //schema_1_1:EntityType/../@Namespace, //schema_1_2:EntityType/../@Namespace)" />
<xsl:variable name="modified_service_namespace">
	<xsl:call-template name="cleanQuote">
	<xsl:with-param name="string">
	<xsl:value-of select="$service_namespace"/>
	</xsl:with-param>
</xsl:call-template>
</xsl:variable>
<!-- Default service URI passed externally -->
<xsl:param name="DefaultServiceURI"/>
<xsl:template match="/">
<xsl:apply-templates select="/edmx:Edmx/edmx:DataServices/schema_1_0:Schema | /edmx:Edmx/edmx:DataServices/schema_1_1:Schema | /edmx:Edmx/edmx:DataServices/schema_1_2:Schema"/>
</xsl:template>
<xsl:template match="/edmx:Edmx/edmx:DataServices/schema_1_0:Schema | /edmx:Edmx/edmx:DataServices/schema_1_1:Schema | /edmx:Edmx/edmx:DataServices/schema_1_2:Schema">
<xsl:apply-templates select="schema_1_0:EntityContainer | schema_1_1:EntityContainer | schema_1_2:EntityContainer"/>

<xsl:for-each select="schema_1_0:ComplexType | schema_1_1:ComplexType | schema_1_2:ComplexType">
<xsl:apply-templates select="."/>
</xsl:for-each>
<xsl:for-each select="schema_1_0:EntityType | schema_1_1:EntityType | schema_1_2:EntityType">
<xsl:apply-templates select="."/>
</xsl:for-each>
</xsl:template>
<xsl:template match="schema_1_0:ComplexType | schema_1_1:ComplexType | schema_1_2:ComplexType">
@implementation <xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/> 
<xsl:for-each select="schema_1_0:Property | schema_1_1:Property | schema_1_2:Property">
	@synthesize m_<xsl:value-of select="@Name"/>;</xsl:for-each>
@end
</xsl:template>
<!-- Generate container class -->
<xsl:template match="schema_1_0:EntityContainer | schema_1_1:EntityContainer | schema_1_2:EntityContainer">
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
 
/**
 * Container interface <xsl:value-of select="@Name"/>, Namespace: <xsl:value-of select="$service_namespace"/>
 */
@implementation <xsl:value-of select="@Name"/> 

	@synthesize m_OData_etag;
<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
	@synthesize m_<xsl:value-of select="@Name"/>;</xsl:for-each>
/**
 * The initializer for <xsl:value-of select="@Name"/> accepting service URI
 */
- (id) init
{
	NSString* tmpuri =[[NSString alloc]initWithString:DEFAULT_SERVICE_URL];
	self=[self initWithUri:tmpuri credential:nil];
	[tmpuri release];
	return self;
}

- (id) initWithUri:(NSString*)anUri credential:(id)acredential
{
	NSString* tmpuri=nil;
	if([anUri length]==0)
	{
	 	tmpuri = DEFAULT_SERVICE_URL;
	}
	else
	{
		tmpuri =[NSString stringWithString:anUri];
	}
	if(![tmpuri hasSuffix:@"/"])
	{
		tmpuri=[tmpuri stringByAppendingString:@"/"];
	}

	if(self=[super initWithUri:tmpuri credentials:acredential dataServiceVersion:DataServiceVersion])
	{
		[super setServiceNamespace:@"<xsl:value-of select="$service_namespace"/>"];

		NSMutableArray* tempEntities=[[NSMutableArray alloc]init];
		<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet  | schema_1_2:EntitySet">
		[tempEntities addObject:@"<xsl:value-of select="@Name"/>"];</xsl:for-each>

		if([tempEntities count] > 0 )
		{
			[super setEntitiesWithArray:tempEntities];
		}
		[tempEntities release];

		NSMutableArray* tempEntitiySetKey=[[NSMutableArray alloc]init];
		<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
		[tempEntitiySetKey addObject:@"<xsl:value-of select="translate(@Name, $uppercase, $smallcase)" />"];</xsl:for-each>

		NSMutableArray* tempEntitiyTypeobj=[[NSMutableArray alloc]init];
		<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
		[tempEntitiyTypeobj addObject:@"<xsl:value-of select="substring-after(@EntityType, concat($service_namespace, '.'))"/>"];</xsl:for-each>

		if( ( [tempEntitiySetKey count] > 0 ) &amp;&amp; ( [tempEntitiyTypeobj count] > 0 ) )
		{
			[super setEntitySet2TypeWithObject:tempEntitiyTypeobj forKey:tempEntitiySetKey];

		}

		[tempEntitiySetKey release];
		[ tempEntitiyTypeobj release];

		NSMutableArray* tempEntitiyTypeKey=[[NSMutableArray alloc]init];
		<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
		[tempEntitiyTypeKey addObject:@"<xsl:value-of select="translate(substring-after(@EntityType, concat($service_namespace, '.')), $uppercase, $smallcase)" />"];</xsl:for-each>
		NSMutableArray* tempEntitySetObj=[[NSMutableArray alloc]init];
		<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
		[tempEntitySetObj addObject:@"<xsl:value-of select="@Name"/>"];</xsl:for-each>

		if( ( [tempEntitiyTypeKey count] > 0 ) &amp;&amp; ( [tempEntitySetObj count] > 0 ) )
		{
			[super setEntityType2SetWithObject:tempEntitySetObj forKey:tempEntitiyTypeKey];

		}
    	[tempEntitiyTypeKey release];
		[tempEntitySetObj release];

		NSMutableArray* foreignKeys=[[NSMutableArray alloc]init];		<xsl:for-each select="/edmx:Edmx/edmx:DataServices/schema_1_0:Schema/schema_1_0:Association | /edmx:Edmx/edmx:DataServices/schema_1_1:Schema/schema_1_1:Association | /edmx:Edmx/edmx:DataServices/schema_1_2:Schema/schema_1_2:Association">
		[foreignKeys addObject:@"<xsl:value-of select="@Name"/>"];</xsl:for-each>

		NSMutableArray *arrOfDictionaries=[[NSMutableArray alloc]initWithCapacity:[foreignKeys count]];
<xsl:if test="/edmx:Edmx/edmx:DataServices/schema_1_0:Schema/schema_1_0:Association | /edmx:Edmx/edmx:DataServices/schema_1_1:Schema/schema_1_1:Association | /edmx:Edmx/edmx:DataServices/schema_1_2:Schema/schema_1_2:Association">
		NSMutableArray *arr;
 </xsl:if>
<xsl:for-each select="/edmx:Edmx/edmx:DataServices/schema_1_0:Schema/schema_1_0:Association | /edmx:Edmx/edmx:DataServices/schema_1_1:Schema/schema_1_1:Association | /edmx:Edmx/edmx:DataServices/schema_1_2:Schema/schema_1_2:Association">
		arr=[[NSMutableArray alloc]init];
<xsl:for-each select="schema_1_0:End | schema_1_1:End | schema_1_2:End">		[arr addObject:[[[NSDictionary alloc]initWithObjectsAndKeys:@"<xsl:value-of select="@Role"/>",@"EndRole",@"<xsl:value-of select="substring-after(@Type,concat($service_namespace,'.'))"/>",@"Type",@"<xsl:value-of select="@Multiplicity"/>",@"Multiplicity",nil] autorelease]];
</xsl:for-each>		[arrOfDictionaries addObject:arr];
		[arr release];

</xsl:for-each>		if( ( [foreignKeys count] > 0 ) &amp;&amp; ( [arrOfDictionaries count] > 0 ) )
		{
			[super setAssociationforObjects:arrOfDictionaries forKeys:foreignKeys];
		}
		[foreignKeys release];
		[arrOfDictionaries release];

		<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">m_<xsl:value-of select="@Name"/> = [[DataServiceQuery alloc]initWithUri:@"<xsl:value-of select="@Name"/>" objectContext: self];
		</xsl:for-each>
	}
	return self;
}

<xsl:for-each select="schema_1_0:FunctionImport | schema_1_1:FunctionImport | schema_1_2:FunctionImport">/*
 * Method for service operation
 */
- (<xsl:choose><xsl:when test="contains(@ReturnType, 'Collection')">NSArray *</xsl:when><xsl:when test="contains(@ReturnType, 'Edm.')">NSString *</xsl:when><xsl:when test="contains(@ReturnType, @ComplexType)"><xsl:choose><xsl:when test="contains(@ReturnType,$service_namespace)"><xsl:value-of select="substring-after(@ReturnType, concat($service_namespace, '.'))"/> *</xsl:when><xsl:otherwise><xsl:value-of select="@ReturnType"/> *</xsl:otherwise></xsl:choose></xsl:when><xsl:when test="contains(@ReturnType, @EntityType)"><xsl:choose><xsl:when test="contains(@ReturnType,$service_namespace)"><xsl:value-of select="substring-after(@ReturnType, concat($service_namespace, '.'))"/> *</xsl:when><xsl:otherwise><xsl:value-of select="@ReturnType"/> *</xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise>NSString *</xsl:otherwise></xsl:choose>) <xsl:value-of select="@Name"/><xsl:if test="schema_1_0:Parameter | schema_1_1:Parameter | schema_1_2:Parameter">With<xsl:for-each select="schema_1_0:Parameter | schema_1_1:Parameter | schema_1_2:Parameter"><xsl:value-of select="translate(@Name, $uppercase, $smallcase)"/>:(<xsl:if test="@Type = 'Edm.String'">NSString *</xsl:if><xsl:if test="@Type = 'Edm.Int32'">NSNumber *</xsl:if><xsl:if test="@Type = 'Edm.Int16'">NSNumber *</xsl:if><xsl:if test="@Type = 'Edm.Int64'">NSNumber *</xsl:if>
<xsl:if test="@Type = 'Edm.Binary'">NSData *</xsl:if>
<xsl:if test="@Type = 'Edm.Decimal'">NSDecimalNumber *</xsl:if>
<xsl:if test="@Type = 'Edm.Boolean'">ODataBool *</xsl:if>
<xsl:if test="@Type = 'Edm.DateTime'">NSDate *</xsl:if>
<xsl:if test="@Type = 'Edm.Single'">NSDecimalNumber *</xsl:if>
<xsl:if test="@Type = 'Edm.Guid'">NSString *</xsl:if>
<xsl:if test="@Type = 'Edm.DateTimeOffset'">NSDate *</xsl:if>
<xsl:if test="@Type = 'Edm.Time'">NSDate *</xsl:if>
<xsl:if test="@Type = 'Edm.Byte'">Byte </xsl:if>
<xsl:if test="@Type = 'Edm.Double'">NSDecimalNumber *</xsl:if><xsl:if test="contains(@Type, $service_namespace)"><xsl:if test="contains(@Type,@ComplexType)"><xsl:value-of select="substring-after(@Type,concat($service_namespace, '.'))"/> *</xsl:if></xsl:if>)<xsl:value-of select="@Name"/><xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if></xsl:for-each>
</xsl:if>
{
<xsl:if test="schema_1_0:Parameter | schema_1_1:Parameter | schema_1_2:Parameter">	NSDictionary *params=[[NSDictionary alloc] initWithObjectsAndKeys:<xsl:for-each select="schema_1_0:Parameter | schema_1_1:Parameter | schema_1_2:Parameter"><xsl:value-of select="@Name"/>,@"<xsl:value-of select="@Name"/>",</xsl:for-each>nil];
</xsl:if><xsl:choose><xsl:when test="schema_1_0:Parameter | schema_1_1:Parameter | schema_1_2:Parameter">	NSString *aQuery=[self prepareQuery:@"<xsl:value-of select="@Name"/>" parameters:params];
</xsl:when><xsl:otherwise>	NSString *aQuery=[self prepareQuery:@"<xsl:value-of select="@Name"/>" parameters:nil];
</xsl:otherwise></xsl:choose><xsl:if test="schema_1_0:Parameter | schema_1_1:Parameter | schema_1_2:Parameter">	[params release];

</xsl:if>
<xsl:choose><xsl:when test="@m:HttpMethod">	return [self executeServiceOperation:aQuery httpMethod:@"<xsl:value-of select="@m:HttpMethod"/>" isReturnTypeCollection:<xsl:choose><xsl:when test="contains(@ReturnType, 'Collection')">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>];
</xsl:when><xsl:otherwise>	return [self executeServiceOperation:aQuery httpMethod:@"GET" isReturnTypeCollection:<xsl:choose><xsl:when test="contains(@ReturnType, 'Collection')">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>];
</xsl:otherwise></xsl:choose>}
</xsl:for-each>

<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
/**
 * Method returns DataServiceQuery reference for
 * the entityset <xsl:value-of select="@Name"/>
 */
- (id) <xsl:value-of select="translate(@Name, $uppercase, $smallcase)" />
{
	[self.m_<xsl:value-of select="@Name"/> clearAllOptions];
	return self.m_<xsl:value-of select="@Name"/>;
}
</xsl:for-each>
/**
 * Methods for adding object to the entityset/collection
 */
<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
- (void) addTo<xsl:value-of select="@Name"/>:(id)anObject
{
	[super addObject:@"<xsl:value-of select="@Name"/>" object:anObject];
}
</xsl:for-each>
- (void) dealloc
{
	[ m_OData_etag release];
	m_OData_etag = nil;
	<xsl:for-each select="schema_1_0:EntitySet | schema_1_1:EntitySet | schema_1_2:EntitySet">
	[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;</xsl:for-each>

	[super dealloc];
}

@end
</xsl:template>
<xsl:template match="schema_1_0:EntityType | schema_1_1:EntityType | schema_1_2:EntityType">
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
<xsl:variable name="service_namespace" select="concat(//schema_1_0:EntityType/../@Namespace, //schema_1_1:EntityType/../@Namespace, //schema_1_2:EntityType/../@Namespace)" />
<xsl:variable name="ClassName" select="@Name"/>
<xsl:variable name="baseClassName" select="substring-after(@BaseType, concat($service_namespace, '.'))"/>/**
 * @interface:<xsl:value-of select="@Name"/>
 <xsl:for-each select="schema_1_0:Key | schema_1_1:Key | schema_1_2:Key">
 <xsl:for-each select="schema_1_0:PropertyRef | schema_1_1:PropertyRef | schema_1_2:PropertyRef">
 * @key:<xsl:value-of select="@Name"/>
 </xsl:for-each>
 </xsl:for-each>
 <xsl:if test="@m:FC_SourcePath">
 * @FC_SourcePath:<xsl:value-of select="@m:FC_SourcePath"/>
 * @FC_TargetPath:<xsl:value-of select="@m:FC_TargetPath"/>
 * @FC_ContentKind:<xsl:value-of select="@m:FC_ContentKind"/>
 * @FC_KeepInContent:<xsl:value-of select="@m:FC_KeepInContent"/>
 </xsl:if>
 */
@implementation <xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/>

<xsl:for-each select="schema_1_0:Property | schema_1_1:Property | schema_1_2:Property">
	@synthesize m_<xsl:value-of select="@Name"/>;</xsl:for-each>
<xsl:for-each select="schema_1_0:NavigationProperty | schema_1_1:NavigationProperty | schema_1_2:NavigationProperty">
	@synthesize m_<xsl:value-of select="@Name"/>;</xsl:for-each>

/**
 *Method to create an instance of <xsl:value-of select="@Name"/>
 */
+ (id) Create<xsl:value-of select="@Name"/><xsl:if test="schema_1_0:Property[@Nullable = 'false'] | schema_1_1:Property[@Nullable = 'false'] | schema_1_2:Property[@Nullable = 'false']">With<xsl:for-each select="schema_1_0:Property[@Nullable = 'false'] | schema_1_1:Property[@Nullable = 'false'] | schema_1_2:Property[@Nullable = 'false']"><xsl:value-of select="translate(@Name, $uppercase, $smallcase)"/>:(<xsl:if test="@Type = 'Edm.String'">NSString *</xsl:if><xsl:if test="@Type = 'Edm.Int32'">NSNumber *</xsl:if><xsl:if test="@Type = 'Edm.Int16'">NSNumber *</xsl:if><xsl:if test="@Type = 'Edm.Int64'">NSNumber *</xsl:if>
<xsl:if test="@Type = 'Edm.Binary'">NSData *</xsl:if>
<xsl:if test="@Type = 'Edm.Decimal'">NSDecimalNumber *</xsl:if>
<xsl:if test="@Type = 'Edm.Boolean'">ODataBool *</xsl:if>
<xsl:if test="@Type = 'Edm.DateTime'">NSDate *</xsl:if>
<xsl:if test="@Type = 'Edm.Single'">NSDecimalNumber *</xsl:if>
<xsl:if test="@Type = 'Edm.Guid'">NSString *</xsl:if>
<xsl:if test="@Type = 'Edm.DateTimeOffset'">NSDate *</xsl:if>
<xsl:if test="@Type = 'Edm.Time'">NSDate *</xsl:if>
<xsl:if test="@Type = 'Edm.Byte'">Byte </xsl:if>
<xsl:if test="contains(@Type, $service_namespace)"><xsl:if test="contains(@Type,@ComplexType)"><xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="substring-after(@Type,concat($service_namespace, '.'))"/> *</xsl:if></xsl:if>
<xsl:if test="@Type = 'Edm.Double'">NSDecimalNumber *</xsl:if>)a<xsl:value-of select="@Name"/><xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if></xsl:for-each></xsl:if>
{
	<xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/> *a<xsl:value-of select="@Name"/> = [[<xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/> alloc]init];
	<xsl:for-each select="schema_1_0:Property[@Nullable = 'false'] | schema_1_1:Property[@Nullable = 'false'] | schema_1_2:Property[@Nullable = 'false']">
	a<xsl:value-of select="$ClassName"/>.m_<xsl:value-of select="@Name"/> = a<xsl:value-of select="@Name"/>;

	</xsl:for-each>return a<xsl:value-of select="@Name"/>;
}
/**
 * Initialising object for <xsl:value-of select="@Name"/>
 */
- (id) init
{
	self=[self initWithUri:nil];
	return self;
}

- (id) initWithUri:(NSString*)anUri 
{
	if(self=[super initWithUri:anUri])
	{
		[self setBaseURI:anUri];
		m_OData_hasStream.booleanvalue=<xsl:choose><xsl:when test="@m:HasStream">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose>;
		<xsl:for-each select="schema_1_0:NavigationProperty | schema_1_1:NavigationProperty | schema_1_2:NavigationProperty">[m_OData_entityMap setObject:@"<xsl:value-of select="@ToRole"/>" forKey:@"<xsl:value-of select="@Name"/>"];
		</xsl:for-each>mProperties *obj;
		<xsl:for-each select="schema_1_0:Property | schema_1_1:Property | schema_1_2:Property">
		obj=[[mProperties alloc]initWithEdmType:@"<xsl:value-of select="@Type"/>" MaxLength:@"<xsl:value-of select="@MaxLength"/>" MinLength:@"<xsl:value-of select="@MinLength"/>" FixedLength:<xsl:choose><xsl:when test="@FixedLength='false'">NO</xsl:when><xsl:when test="@FixedLength='true'">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose> Nullable:<xsl:choose><xsl:when test="@Nullable='false'">NO</xsl:when><xsl:when test="@Nullable='true'">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose> Unicode:<xsl:choose><xsl:when test="@Unicode='false'">NO</xsl:when><xsl:when test="@Unicode='true'">YES</xsl:when><xsl:otherwise>NO</xsl:otherwise></xsl:choose> ConcurrencyMode:@"<xsl:value-of select="@ConcurrencyMode"/>" FC_TargetPath:@"<xsl:value-of select="@m:FC_TargetPath"/>" FC_KeepInContent:<xsl:choose><xsl:when test="@m:FC_KeepInContent='false'">NO</xsl:when><xsl:when test="@m:FC_KeepInContent='true'">YES</xsl:when><xsl:otherwise>YES</xsl:otherwise></xsl:choose> FC_SourcePath:@"<xsl:value-of select="@m:FC_SourcePath"/>" FC_ContentKind:@"<xsl:value-of select="@m:FC_ContentKind"/>" FC_NsPrefix:@"<xsl:value-of select="@m:FC_NsPrefix"/>" FC_NsUri:@"<xsl:value-of select="@m:FC_NsUri"/>"];
		[m_OData_propertiesMap setObject:obj forKey:@"m_<xsl:value-of select="@Name"/>"];
		[obj release];
		</xsl:for-each>

<xsl:for-each select="schema_1_0:NavigationProperty | schema_1_1:NavigationProperty | schema_1_2:NavigationProperty">
		[m_OData_entityFKRelation setObject:@"<xsl:value-of select="substring-after(@Relationship, concat($service_namespace, '.'))"/>" forKey:@"<xsl:value-of select="@ToRole"/>"];</xsl:for-each>

		NSMutableArray *anEntityKey=[[NSMutableArray alloc]init];
<xsl:apply-templates select="schema_1_0:Key | schema_1_1:Key | schema_1_2:Key"/>		[m_OData_entityKey setObject:anEntityKey forKey:@"<xsl:value-of select="$ClassName"/>"];
		[anEntityKey release];
	}
	return self;
}

-(NSMutableArray *)getSyndicateArray
{
	NSMutableArray *syndicateArray=[[NSMutableArray alloc]init];
	<xsl:for-each select="schema_1_0:Property | schema_1_1:Property | schema_1_2:Property">	<xsl:if test="@m:FC_TargetPath">[syndicateArray addObject:@"m_<xsl:value-of select="@Name"/>"];
	</xsl:if>	</xsl:for-each>
	return [syndicateArray autorelease];
}
-(<xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/> *)getDeepCopy
{
	<xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/> *obj=[[<xsl:value-of select="$modified_service_namespace"/>_<xsl:value-of select="@Name"/> alloc]initWithUri:[self getBaseURI]];
<xsl:for-each select="schema_1_0:Property | schema_1_1:Property | schema_1_2:Property">	[obj set<xsl:value-of select="@Name"/>:[self get<xsl:value-of select="@Name"/>]];
</xsl:for-each><xsl:for-each select="schema_1_0:NavigationProperty | schema_1_1:NavigationProperty | schema_1_2:NavigationProperty">	[obj set<xsl:value-of select="@Name"/>:[self get<xsl:value-of select="@Name"/>]];
</xsl:for-each>
	return [obj autorelease];
}
- (void) dealloc
{
	<xsl:for-each select="schema_1_0:Property | schema_1_1:Property | schema_1_2:Property">
	<xsl:if test="@Type = 'Edm.String'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Binary'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Boolean'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.DateTime'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Guid'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Int16'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Int32'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Int64'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Decimal'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Single'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	<xsl:if test="@Type = 'Edm.Double'">[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;
	</xsl:if>
	</xsl:for-each>
	<xsl:for-each select="schema_1_0:NavigationProperty | schema_1_1:NavigationProperty | schema_1_2:NavigationProperty">
	[m_<xsl:value-of select="@Name"/> release];
	m_<xsl:value-of select="@Name"/> = nil;</xsl:for-each>
	[super dealloc];
}

@end
</xsl:template>
<xsl:template match="schema_1_0:Key | schema_1_1:Key | schema_1_2:Key">
<xsl:for-each select="schema_1_0:PropertyRef | schema_1_1:PropertyRef | schema_1_2:PropertyRef">		[anEntityKey addObject:@"<xsl:value-of select="@Name"/>"];
</xsl:for-each>
</xsl:template>

<xsl:template name="cleanQuote">
<xsl:param name="string" />
<xsl:if test="contains($string, '.')"><xsl:value-of
    select="substring-before($string, '.')" />_<xsl:call-template
    name="cleanQuote">
                <xsl:with-param name="string"><xsl:value-of
select="substring-after($string, '.')" />
                </xsl:with-param>
        </xsl:call-template>
</xsl:if>
<xsl:if test="not(contains($string, '.'))"><xsl:value-of
select="$string" />
</xsl:if>
</xsl:template>

</xsl:stylesheet>