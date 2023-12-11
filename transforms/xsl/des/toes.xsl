<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:gate="http://www.gate.ac.uk"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs tso leg gate dc err" version="2.0">

	<!--

	This XSLT uses a series of modes to locate the data needed within the Changes elelements

	MODES
	_____________________________________________________________________________________
	Mode			Description
	calcAmends	
	tso:insertion	Updates the insertion point when there are multiple provisions that have been made into individual effects
	tso:sections		Generates Section/SectionRange for the supplied LegRef
	Ref			Generate the ref attribute
	tso:parentRef	Finds the parent LegRef/Legislation from the supplied LegRef
	tso:legislation	finds the Legislation eleement associated for a given Action
	tso:location		finds the LegRef element associated for a given Action
	tso:addition		finds the Quote/LegAmendment element for a given insert/substitution Action	
	tso:repeal		finds the Quote/LegRef element for a delete/substitution Action
	tso:repealRange	generates the repeal nodeset from a given Quote
	tso:insertionPoint	generates the insertion nodeset for a given Action
	tso:context		generates the Section/SectionGroup nodeset for a given LegRef
	tso:text		generates the Text nodeset for a given quote
	tso:startDate	locates the Date elements for a given action
	________________________________________________________________________________________

	FUNCTIONS
	_______________________________________________________________________________________
	tso:calcAffectedLeg	
	tso:calcYearFromUri		returns the year string  from a given uri
	tso:calcRegnalYearFromUri	returns the regnal year string  from a given uri
	tso:calcNumberFromUri		returns the number string  from a given uri, or empty if the 'number' is an ISBN
	tso:calcLegislationFromUri	returns the legislation type string  from a given uri
	tso:calcSectionFromUri		
	tso:calcSectionUriAsId		returns section id from a number uri (ie regulation/2/1 returns regulation-2-1)
	tso:calcUriFromSection		reverse of above
	tso:uriSplitter			
	tso:uriGenerator
	tso:parentRef			function for finding the parent ref of  a legref
	tso:sectionUri			generate uri from a LegRef
	tso:legislation			finds legislation element from a given Action
	tso:section				finds LegRef element from a given Action
	tso:GetAmendment			finds the BlockAmendment within the body of the document
	tso:GetAmendmentSections	gets the amendment sections from the BlockAmendment 
	tso:startDate			get the Date for a a given action
	tso:correctProvisionUri		tanslation routine for uris to get the correct provision name
	-->	
	
	
	<xsl:import href="../common/utils.xsl" />

	<xsl:key name="markup" match="gate:*[@id]" use="@id" />

	<xsl:variable name="legUri" as="xs:string"
				select="(//leg:Legislation[1]/(@IdURI, ukm:Metadata/dc:identifier[starts-with(., 'http://www.legislation.gov.uk/id/')])[1])[1]" />
				
	<xsl:variable name="legAlternativeNumber" as="xs:string?"
				select="//leg:Legislation[1]/ukm:Metadata//ukm:AlternativeNumber[@Category = ('NI','S','W')]/@Value" />			
				
	<xsl:variable name="legType" as="xs:string"
				select="/(DesDocument|GateDocument)/leg:Legislation/ukm:Metadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />

	<xsl:variable name="citationStartNumber" as="xs:integer">
		<xsl:variable name="largestId" as="xs:string?">
			<xsl:for-each select="//leg:Citation | //leg:CitationSubRef">
				<xsl:sort select="@id" order="descending" />
				<xsl:if test="position() = 1">
					<xsl:value-of select="@id" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="if (exists($largestId)) then xs:integer(substring-after($largestId, 'c')) else 0" />
	</xsl:variable>

	
	<xsl:output indent="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates select="*/Changes"/>
	</xsl:template>
    
	<!-- This has been asked to be removed by email from RM 2012-01-20 this is going through in the xml but is not required as rendered excel or pdf  -->
	<xsl:template match="Changes[@parserName = 'Commencement Finder']">
		<xsl:param name="legUri" as="xs:string" select="$legUri" />
	
		<xsl:apply-templates select="descendant::Action[not(@type = ('Amendment'))]" mode="effect">
			<xsl:with-param name="affectingLeg" as="xs:string" select="$legUri" tunnel="yes" />
			<xsl:with-param name="affectingYear" as="xs:integer" select="tso:calcYearFromUri($legUri)" tunnel="yes" />
			<xsl:with-param name="affectingNumber" as="xs:integer?" select="tso:calcNumberFromUri($legUri)" tunnel="yes" />
			<xsl:with-param name="affectingType" as="xs:string" select="$legType" tunnel="yes" />
		</xsl:apply-templates>
		
	</xsl:template>
	
	
	<xsl:template match="Changes[@parserName = 'Legislation Parser' or @parserName = 'Enabling Power Finder'(:not(@parserName = 'Repeals and Revocations Finder' or @parserName='Non Textual Finder'):)]">
		<xsl:param name="legUri" as="xs:string" select="$legUri" />
	
		<xsl:apply-templates select="descendant::Action[not(@type = ('Amendment'))]" mode="effect">
			<xsl:with-param name="affectingLeg" as="xs:string" select="$legUri" tunnel="yes" />
			<xsl:with-param name="affectingYear" as="xs:integer" select="tso:calcYearFromUri($legUri)" tunnel="yes" />
			<xsl:with-param name="affectingNumber" as="xs:integer?" select="tso:calcNumberFromUri($legUri)" tunnel="yes" />
			<xsl:with-param name="affectingType" as="xs:string" select="$legType" tunnel="yes" />
		</xsl:apply-templates>
		
	</xsl:template>

	<!-- this parser will report all repeals and revocations that cannot be identified otherwise - these will include tabul;ated items in schedules  -->
	<xsl:template match="Changes[@parserName = 'Repeals and Revocations Finder']">
		<xsl:param name="legUri" as="xs:string" select="$legUri" />
		<xsl:apply-templates select="RR">
			<xsl:with-param name="affectingLeg" as="xs:string" select="$legUri" tunnel="yes" />
				<xsl:with-param name="affectingYear" as="xs:integer" select="tso:calcYearFromUri($legUri)" tunnel="yes" />
				<xsl:with-param name="affectingNumber" as="xs:integer?" select="tso:calcNumberFromUri($legUri)" tunnel="yes" />
				<xsl:with-param name="affectingType" as="xs:string" select="$legType" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Changes[@parserName = 'Extent Finder']">
		
	</xsl:template>

	<xsl:template match="RR">
		<xsl:variable name="affectedLeg" as="element(Legislation)" select="Legislation"/>
		
		<xsl:choose>
			<xsl:when test="not(RRitem)">
				<xsl:call-template name="GenerateNoActionEffect">
					<xsl:with-param name="affectedLeg" select="$affectedLeg" />
					<xsl:with-param name="affectedSection" select="Legislation" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="RRitem">
					
					<xsl:variable name="affectedSection" as="element()*" select="tso:section((.//*[not(ancestor-or-self::InlineLocationOf)])[last()])[last()]"/>
					<xsl:call-template name="GenerateNoActionEffect">
						<xsl:with-param name="affectedLeg" select="$affectedLeg" />
						<xsl:with-param name="affectedSection" select="$affectedSection" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Changes[@parserName = 'Non Textual Finder']">
		<xsl:param name="legUri" as="xs:string" select="$legUri" />
		
		<!--<xsl:variable name="affectedLeg" as="element(Legislation)?" select="(.//Legislation)[1]"/>-->
		
		<xsl:variable name="NonTextualPhrase" as="element(NonTextualPhrase)?" select="(*/NonTextualPhrase)[1]"/>
		<xsl:variable name="affectedSection" as="element()*" select="if (exists($NonTextualPhrase)) then tso:section($NonTextualPhrase) else ()" />
		<xsl:variable name="affectedLeg" as="element()?">
			<xsl:apply-templates select="$affectedSection" mode="tso:legislation"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="exists($affectedLeg) and $affectedLeg instance of element(Legislation)">
			
			
				<xsl:call-template name="GenerateNoActionEffect">
					<xsl:with-param name="affectingLeg" as="xs:string" select="$legUri" tunnel="yes" />
					<xsl:with-param name="affectingYear" as="xs:integer" select="tso:calcYearFromUri($legUri)" tunnel="yes" />
					<xsl:with-param name="affectingNumber" as="xs:integer?" select="tso:calcNumberFromUri($legUri)" tunnel="yes" />
					<xsl:with-param name="affectingType" as="xs:string" select="$legType" tunnel="yes" />
					<xsl:with-param name="affectedLeg" select="$affectedLeg" />
					<xsl:with-param name="affectedSection" select="$affectedSection" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="NTgeneral[.//Legislation] | NTpurposes[.//Legislation]">
		<xsl:variable name="affectedLeg" as="element(Legislation)" select="(.//Legislation)[1]"/>
		<xsl:variable name="affectedSection" as="element()?" select="(.//*[self::LegRef])[last()]"/>
		<xsl:call-template name="GenerateNoActionEffect">
			<xsl:with-param name="affectingLeg" as="xs:string" select="$legUri" tunnel="yes" />
			<xsl:with-param name="affectingYear" as="xs:integer" select="tso:calcYearFromUri($legUri)" tunnel="yes" />
			<xsl:with-param name="affectingNumber" as="xs:integer?" select="tso:calcNumberFromUri($legUri)" tunnel="yes" />
			<xsl:with-param name="affectingType" as="xs:string" select="$legType" tunnel="yes" />
			<xsl:with-param name="affectedLeg" select="$affectedLeg" />
			<xsl:with-param name="affectedSection" select="$affectedSection" />
		</xsl:call-template>
	</xsl:template>	
	
	
	<xsl:template name="GenerateNoActionEffect">
		<xsl:param name="affectingLeg" as="xs:string" required="yes" tunnel="yes" />
		<xsl:param name="affectingType" as="xs:string" required="yes" tunnel="yes" />
		<xsl:param name="affectingYear" as="xs:integer" required="yes" tunnel="yes" />
		<xsl:param name="affectingNumber" as="xs:integer?" required="yes" tunnel="yes" />
		<xsl:param name="affectedLeg" as="element(Legislation)" required="yes" />
		<xsl:param name="affectedSection" as="element()?" required="yes" /><!-- returns either Legislation | LegRef | Error  -->
		
		<xsl:variable name="legislation" as="element()?" select="key('markup', $affectedLeg/@id, root())" />
		
		<!-- this should always be the first condition on the choose but ssi/2010/413 shows otherwise - could be a GATE issue -->
		<xsl:variable name="ref" as="xs:string">
			<xsl:choose>
				<xsl:when test="$legislation instance of element()">
					<xsl:apply-templates select="$affectedLeg" mode="Ref" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$affectedSection" mode="Ref" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="starts-with($ref,'ERROR')">
			<xsl:message>ERROR: <xsl:value-of select="$ref"/></xsl:message>
		</xsl:if>
		
		<xsl:variable name="legislation" as="element()?" select="key('markup', $affectedLeg/@id, root())" />
		
		<!-- this catches instances where we have tabulated lists in schedules with a citation to the legislation in one column and GATE does not recognise the title in the second column  -->
		<xsl:variable name="affectedLeg" as="element(Legislation)">
			<xsl:choose>
				<xsl:when test="empty($affectedLeg/@context) and $legislation/ancestor::xhtml:td/preceding-sibling::xhtml:td//leg:Citation">
					<xsl:variable name="context" as="element(leg:Citation)" select="$legislation/ancestor::xhtml:td/preceding-sibling::xhtml:td//leg:Citation[1]"/>
					<Legislation xmlns="" context="{$context/@URI}" type="{substring-before(substring-after($context/@URI, 'http://www.legislation.gov.uk/id/'), '/')}" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$affectedLeg"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
				
		
		
		
		<xsl:variable name="affectedNumber" as="xs:integer?" select="if (exists($affectedLeg/@context) and $affectedLeg/@context != '') then tso:calcNumberFromUri($affectedLeg/@context) else ()" />
		<xsl:variable name="affectedYear" as="xs:integer?" select="if (exists($affectedLeg/@context) and $affectedLeg/@context != '') then tso:calcYearFromUri($affectedLeg/@context) else ()" />
		<xsl:variable name="affectedType" as="xs:string?" select="if (exists($affectedLeg/@type) and $affectedLeg/@type != '') then tso:getClass($affectedLeg/@type) else ()" />
		<xsl:variable name="EffectName" as="xs:string" select="if ($affectedLeg/@type = ('primary','secondary','') or not($affectedLeg/@type)) then 'UndefinedEffect' else 'Effect'"/>
		
		<xsl:variable name="repeal" as="element()?" select="($affectedSection/ancestor::RRitem//*)[last()]"/>
		<xsl:variable name="provisionRepeal" as="xs:boolean" 
			select="exists($repeal[not(self::Quote or self::InlineActionDeleteEntry or self::RefHeadingChange)])" />
		<xsl:variable name="repealedRange" as="element()*"
			select="if (not($provisionRepeal) and exists($repeal)) then tso:repealRange($repeal,$affectedSection) else ()" />
		
		
		<xsl:variable name="strRepealType" as="xs:string?">
			<xsl:choose>
				<xsl:when test="$repeal instance of element(Quote)">
					<xsl:text>words </xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		
		
		<xsl:variable name="type" as="xs:string">
			<!-- need to determine whether these are repeals or revokes - can only tell from the document they are in so we shall use some common tests-->
			<!-- usually held within a schedule dedicated to repeals/revokes -->
			
			<xsl:choose>
				<xsl:when test="ancestor-or-self::Changes[@parserName = 'Non Textual Finder']">
					<xsl:variable name="nonTextualPhrase" select="ancestor-or-self::Changes[@parserName = 'Non Textual Finder']/*/NonTextualPhrase"/>
					<xsl:choose>
						<xsl:when test="$nonTextualPhrase[@type='Excluded']">excluded</xsl:when>
						<xsl:when test="$nonTextualPhrase[@type='Applied']">applied</xsl:when>
						<xsl:when test="$nonTextualPhrase[@type='WithModifications']">applied (with modifications)</xsl:when>
						<xsl:otherwise>modified</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="matches($legislation/ancestor::leg:Schedule/leg:TitleBlock/leg:Title,'(revocations|revoke)','i') and 
								matches($legislation/ancestor::leg:Schedule/leg:TitleBlock/leg:Title,'(repeal)','i')">
					<xsl:value-of select="concat($strRepealType,'repealed')"/>
				</xsl:when>
				<xsl:when test="matches($legislation/ancestor::leg:Schedule/leg:TitleBlock/leg:Title,'(revocations|revoke)','i')">
					<xsl:value-of select="concat($strRepealType,'revoked')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($strRepealType,'repealed')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		
		<xsl:variable name="affectedProvisions" as="node()*">
			<xsl:apply-templates select="$affectedSection" mode="tso:sections">
				<xsl:with-param name="legislationURI" select="$affectedLeg/@context" />
			</xsl:apply-templates>
		</xsl:variable>
		
		<xsl:variable name="sectionRef" as="xs:string"
			select="tso:calcSectionUriAsId(tso:calcSectionFromUri($affectedSection/@sourceRef))" />
		
		<xsl:variable name="nstSection" as="node()*">
			<ukm:Section Ref="{tso:correctProvisionUri($sectionRef)}" URI="{concat($legUri, '/', translate(tso:correctProvisionUri($sectionRef), '-', '/'))}">
				<xsl:choose>
					<xsl:when test="empty($sectionRef) or $sectionRef = ''">
						<xsl:value-of select="concat('ERROR - missing source ref for ',$affectedSection/@id)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="tso:formatSection($sectionRef, '-')" />
					</xsl:otherwise>
				</xsl:choose>
			</ukm:Section>
		</xsl:variable>
		
		<xsl:for-each select="$affectedProvisions[self::ukm:Section or self::ukm:SectionRange or . = ('Order','Act','Instrument','Regulations','Rules')]">
			<xsl:element name="ukm:{$EffectName}">
				<xsl:attribute name="Applied" select="'false'"/>
				
				<xsl:attribute name="AffectingURI" select="$legUri"/>
				<xsl:attribute name="AffectingClass" select="$affectingType"/>
				<xsl:attribute name="AffectingYear" select="$affectingYear"/>
				<xsl:if test="exists($affectingNumber)">
					<xsl:attribute name="AffectingNumber" select="$affectingNumber"/>
				</xsl:if>
				<xsl:attribute name="AffectedURI" select="$affectedLeg/@context"/>
				<xsl:attribute name="AffectedClass" select="$affectedType"/>
				<xsl:attribute name="AffectedNumber" select="$affectedNumber"/>
				<xsl:if test="exists($affectedYear)">
					<xsl:attribute name="AffectedYear" select="$affectedYear"/>
				</xsl:if>
				
				<xsl:if test="exists($legAlternativeNumber) and $legAlternativeNumber != ''">
					<xsl:attribute name="AlternativeAffectingNumber" select="$legAlternativeNumber"/>
				</xsl:if>
				
				<xsl:attribute name="Ref" select="$ref"/>
				
				
				
				<xsl:attribute name="Type">
					<xsl:sequence select="$type"/>
				</xsl:attribute>
				
				
				<xsl:if test="$affectedProvisions">
					<xsl:attribute name="AffectedProvisions" select="if (string(.) = 'contents') then 'Table of Contents' else string(.)" />
				</xsl:if>
				
				<xsl:if test="$nstSection">
					<xsl:attribute name="AffectingProvisions" select="string($nstSection)" />
				</xsl:if>
				
				<xsl:choose>
					<xsl:when test="not($provisionRepeal) and $affectedSection/ancestor::Changes[@parserName = 'Repeals and Revocations Finder']">
						<ukm:OmittedRange>
							<xsl:sequence select="$repealedRange" />
						</ukm:OmittedRange>
					</xsl:when>
				</xsl:choose>
				
				
				<ukm:AffectedProvisions>
					<xsl:sequence select="."/>
				</ukm:AffectedProvisions>
				<ukm:AffectingProvisions>
					<xsl:sequence select="$nstSection"/>
				</ukm:AffectingProvisions>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>



	<xsl:template match="Action" mode="effect">
		<!--<xsl:message>Processing action <xsl:value-of select="@id" /></xsl:message>-->
		<xsl:variable name="affectedLeg" as="element()" select="tso:legislation(.)" />
		<!-- affectedSections is either a legref, legislation or an error element  -->
		<xsl:variable name="affectedSections" as="element()*" select="tso:section(.)" />
		<xsl:variable name="action" as="element()" select="." />
		<!--<xsl:message>Processing Action  <xsl:value-of select="@id"/> Type: <xsl:value-of select="@type"/></xsl:message>-->
		<xsl:choose>
			<!-- we do not need commencement orders going through  -->
			<!--<xsl:when test="@type = 'ComingIntoForce'"></xsl:when>-->
			<!-- this allows for a list of provision repeals  -->
			<xsl:when test="exists($affectedSections) and $affectedLeg instance of element(err:Error) and $affectedSections instance of element(Legislation)+">
				<xsl:for-each select="$affectedSections">
					<xsl:call-template name="GenerateEffect">
						<xsl:with-param name="affectedLeg" select="." />
						<xsl:with-param name="affectedSection" select="." />
						<xsl:with-param name="action" select="$action" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$affectedLeg instance of element(err:Error)">
				<!-- In the ComingIntoForce types we can have the legislation within a list so lets see if theres an inline legislaiton here first  -->
				<xsl:choose>
					<xsl:when test="exists($affectedSections)">
						<xsl:for-each select="$affectedSections">
							<!-- have another attempt at finding legislation  -->
							<!-- there are some instance where the legialstion is not picked up from titles - we could possibly search for an ancestor::leg:Title/gate:legistaion element  -->
							<xsl:variable name="itemLegislation" as="element()?"><xsl:apply-templates select="." mode="tso:legislation"/></xsl:variable>
							<xsl:choose>
								<xsl:when test="$itemLegislation instance of element(Legislation)">
									<xsl:call-template name="GenerateEffect">
										<xsl:with-param name="affectedLeg" select="$itemLegislation" />
										<xsl:with-param name="affectedSection" select="." />
										<xsl:with-param name="action" select="$action" />
									</xsl:call-template>
								</xsl:when>
								<!-- this wiill produce an undefined effect which is better than nothing!  -->
								<xsl:when test="not($affectedSections instance of element(err:Error))">
									<xsl:message>INFO:  <xsl:value-of select="$affectedLeg"/></xsl:message>
									<xsl:call-template name="GenerateEffect">
										<xsl:with-param name="affectedLeg" select="$affectedLeg" />
										<xsl:with-param name="affectedSection" select="." />
										<xsl:with-param name="action" select="$action" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="$affectedLeg" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise><xsl:sequence select="$affectedLeg" /></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$affectedSections instance of element(err:Error) and ancestor::Cited">
				<!-- TODO make cited legislation template  --><xsl:message>Cited Legislation with yet to be developed - Action  <xsl:value-of select="@id"/> Type: <xsl:value-of select="@type"/></xsl:message>
			</xsl:when>
			<xsl:when test="$affectedSections instance of element(err:Error)">
				<xsl:sequence select="$affectedSections" />
			</xsl:when>
			<!-- for ToC entries we have a generated LegRef  -->
			<xsl:when test="exists($affectedSections) and $affectedSections/@minorType = 'contents'">
				<xsl:call-template name="GenerateEffect">
					<xsl:with-param name="affectedLeg" select="$affectedLeg" />
					<xsl:with-param name="affectedSection" select="$affectedSections" />
					<xsl:with-param name="action" select="$action" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="exists($affectedSections)">
				<xsl:for-each select="$affectedSections">
					<xsl:call-template name="GenerateEffect">
						<xsl:with-param name="affectedLeg" select="$affectedLeg" />
						<xsl:with-param name="affectedSection" select="." />
						<xsl:with-param name="action" select="$action" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="GenerateEffect">
					<xsl:with-param name="affectedLeg" select="$affectedLeg" />
					<xsl:with-param name="affectedSection" select="()" />
					<xsl:with-param name="action" select="$action" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="InlineChange | AnaphorRefGroup" mode="calcAmends">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>

	<xsl:template match="LegislationAmendment | InLegislation" mode="calcAmends">
		<xsl:message>Legislation <xsl:value-of select="Legislation/@sourceRef"/></xsl:message>
		<xsl:apply-templates select="* except (Legislation | Action)" mode="#current">
			<xsl:with-param name="affectedLeg" tunnel="yes" select="Legislation" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="GenerateEffect">
		<xsl:param name="affectingLeg" as="xs:string" required="yes" tunnel="yes" />
		<xsl:param name="affectingType" as="xs:string" required="yes" tunnel="yes" />
		<xsl:param name="affectingYear" as="xs:integer" required="yes" tunnel="yes" />
		<xsl:param name="affectingNumber" as="xs:integer?" required="yes" tunnel="yes" />
		<xsl:param name="affectedLeg" as="element()" required="yes" />
		<xsl:param name="affectedSection" as="element()?" required="yes" /><!-- returns either Legislation | LegRef | Anaphor | Error  -->
		<xsl:param name="action" as="element(Action)" required="yes" />
		
		<xsl:variable name="affectedType" as="xs:string?" select="if ($affectedLeg instance of element(Legislation) and exists($affectedLeg/@type) and $affectedLeg/@type != '') then tso:getClass($affectedLeg/@type) else ()" />
		
		<xsl:variable name="amendment" as="element()?" select="if (not($affectedSection/@minorType = 'contents') and $affectedSection instance of element(LegRef)) then tso:GetAmendment($action) else ()" />
		
		<xsl:variable name="affectingDocumentMinorType" as="xs:string?" select="/DesDocument/leg:Legislation/ukm:Metadata//ukm:DocumentClassification/ukm:DocumentMinorType/@Value" />
		
				
		<xsl:variable name="affectedYear" as="xs:integer?" select="if (exists($affectedLeg/@context) and $affectedLeg/@context != '') then tso:calcYearFromUri($affectedLeg/@context) else ()" />
		<!-- TODO  convert the regnal year to a calendaryear  - for now we will use the regnal 
		<xsl:variable name="affectedYear" as="xs:string?" select="if (exists($affectedYear)) then string($affectedYear) else tso:calcRegnalYearFromUri($affectedLeg/@context)" />-->
		<xsl:variable name="affectedNumber" as="xs:integer?" select="if (exists($affectedLeg/@context) and $affectedLeg/@context != '') then tso:calcNumberFromUri($affectedLeg/@context) else ()" />
		
		<xsl:if test="empty($affectedLeg/@context) or $affectedLeg/@context = ''">
			<!--<xsl:message>No context to <xsl:value-of select="$affectedLeg/@id"/></xsl:message>-->
		</xsl:if>
		
		<xsl:variable name="date" as="element()*" select="if ($action/@type = 'ComingIntoForce') then tso:startDate($affectedSection) else ()" />
		
		<xsl:variable name="type" as="xs:string" select="lower-case($action/@type)" />
		<xsl:variable name="repeal" as="element()*" select="tso:repeal($action)" />
		<xsl:variable name="provisionRepeal" as="xs:boolean" 
			select="exists($repeal[not(self::Quote or self::InlineActionDeleteEntry or self::RefHeadingChange)])" />
		<xsl:variable name="addition" as="element()*" select="tso:addition($action)" />
		<xsl:variable name="provisionAddition" as="xs:boolean" 
			select="exists($addition[not(self::Quote)])" />
		<xsl:variable name="insertionPoint" as="element()?" 
			select="if ($action/@type = 'Insert') then tso:insertionPoint($action) else ()" />
		<xsl:variable name="repealedRange" as="element()*"
			select="if (($action/@type = 'Substitution' or $action/@type = 'Delete') and not($provisionRepeal) and not($affectedSection/@minorType = 'contents')) then tso:repealRange($repeal,$affectedSection) else ()" />
		
		<xsl:variable name="ref" as="xs:string" select="$action/@sourceRef" />
		
		<xsl:variable name="affectedProvisions" as="node()*">
			<xsl:apply-templates select="$affectedSection" mode="tso:sections">
				<xsl:with-param name="legislationURI" select="$affectedLeg/@context" />
				<xsl:with-param name="action" select="$action" />
			</xsl:apply-templates>
		</xsl:variable>
		
		
		<xsl:variable name="affectingProvisions" as="node()*">
			<xsl:choose>
				<!-- when it is the cited legislation that we need to make sure it is the legislation that we use -->
				<xsl:when test="$action/@type='ComingIntoForce' and ($action/ancestor::Cited or $action/ancestor::Changes/preceding-sibling::Changes[1]/Cited)and $affectedSection instance of element(Anaphor)">
					<xsl:apply-templates select="$affectedSection" mode="tso:sections">
						<xsl:with-param name="legislationURI" select="$affectingLeg" />
						<xsl:with-param name="action" select="$action" />
					</xsl:apply-templates>
				</xsl:when>
				<!-- borderline case - when we have a repealed section that is in an ActinDeleteList  -->
				<xsl:when test="not($affectedSection/parent::ActionDeleteListItem) and $action/@type=('Repeal','Delete') and $action/../ActionDeleteList">
					
					<xsl:for-each select="$action/../ActionDeleteList/ActionDeleteListItem">
						
						<xsl:variable name="id" select="if (*[@id][1]/@id) then *[@id][1]/@id
														else if (.//Quote/@id) then .//Quote/@id
														else if (.//Location/@id) then .//Location/@id
														else (.//*/@id)[1]"/>
														
						<xsl:if test="empty($id)"><xsl:message>WARNING: Unable to find id for ActionDeleteListItem</xsl:message></xsl:if>
						<xsl:if test="exists($id)">
							<xsl:variable name="sectionRef" as="xs:string"
							select="key('markup', $id, $action/ancestor::document-node())/ancestor::*[@id][1]/@id" />
							
							<xsl:text> </xsl:text>
							<ukm:Section Ref="{$sectionRef}" URI="{concat($affectingLeg, '/', translate($sectionRef, '-', '/'))}">
								<xsl:value-of select="tso:formatSection($sectionRef, '-')" />
							</ukm:Section>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<!-- when we have a delted item list that has legref within it we only need to process that item -->
				<!-- the display section ref is dependant upon the document minor type - rules are translated to articles in augment.xsl so we need to translate this back from the minor type  -->
				<xsl:when test="$affectedSection/ancestor::*[contains(self::*/local-name(), 'ListItem')]">
					<xsl:variable name="sectionRef" as="xs:string"
						select="key('markup', $affectedSection/@id, $affectedSection/ancestor::document-node())/ancestor::*[@id][1]/@id" />
					<xsl:variable name="displaySectionRef" as="xs:string"
						select="if ($affectingDocumentMinorType = 'rule' and contains($sectionRef,'article')) then replace($sectionRef,'article','rule') else $sectionRef" />
					
					<ukm:Section Ref="{$sectionRef}" URI="{if ($ref = '') then concat($affectingLeg, '/', translate($sectionRef, '-', '/')) else $ref}">
						<xsl:value-of select="tso:formatSection($displaySectionRef, '-')" />
					</ukm:Section>
					<xsl:if test="$action/../InlineLocationSetOutIn">
						<xsl:variable name="sectionURI" as="xs:string" select="tso:sectionUri($action/../InlineLocationSetOutIn/LegRef[1])" />
						<xsl:variable name="sectionRef" as="xs:string" select="tso:calcSectionUriAsId($sectionURI)" />
						<xsl:variable name="displaySectionRef" as="xs:string"
						select="if ($affectingDocumentMinorType = 'rule' and contains($sectionRef,'article')) then replace($sectionRef,'article','rule') else $sectionRef" />
						<xsl:text> </xsl:text>
						<ukm:Section Ref="{$sectionRef}" URI="{$affectingLeg}{$sectionURI}">
							<xsl:value-of select="tso:formatSection($displaySectionRef, '-')" />
						</ukm:Section>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="sectionRef" as="xs:string"
						select="if ($ref = '') then key('markup', $action/@id, $action/ancestor::document-node())/ancestor::*[@id][1]/@id else tso:calcSectionUriAsId(tso:calcSectionFromUri($ref))" />
						<xsl:variable name="displaySectionRef" as="xs:string"
						select="if ($affectingDocumentMinorType = 'rule' and contains($sectionRef,'article')) then replace($sectionRef,'article','rule') else $sectionRef" />
					<xsl:variable name="nstSection" as="node()*">
						<ukm:Section Ref="{$sectionRef}" URI="{if ($ref = '') then concat($affectingLeg, '/', translate($sectionRef, '-', '/')) else $ref}">
							<xsl:if test="exists($date) and $date/@year and $date/@month and $date/@day">
								<xsl:attribute name="StartDate">
									<xsl:value-of select="tso:dateFromString($date/@year,$date/@month,$date/@day)"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="tso:formatSection($displaySectionRef, '-')" />
						</ukm:Section>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$action/../InlineLocationSetOutIn">
							<xsl:variable name="sectionURI" as="xs:string" select="tso:sectionUri($action/../InlineLocationSetOutIn/LegRef[1])" />
							<xsl:variable name="sectionRef" as="xs:string" select="tso:calcSectionUriAsId($sectionURI)" />
							<xsl:variable name="displaySectionRef" as="xs:string"
						select="if ($affectingDocumentMinorType = 'rule' and contains($sectionRef,'article')) then replace($sectionRef,'article','rule') else $sectionRef" />
							<ukm:SectionRange>
								<xsl:sequence select="$nstSection"/>
								<xsl:text> </xsl:text>
								<ukm:Section Ref="{$sectionRef}" URI="{$affectingLeg}{$sectionURI}">
									<xsl:if test="exists($date) and $date/@year and $date/@month and $date/@day">
										<xsl:attribute name="StartDate">
											<xsl:value-of select="tso:dateFromString($date/@year,$date/@month,$date/@day)"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="tso:formatSection($displaySectionRef, '-')" />
								</ukm:Section>
							</ukm:SectionRange>	
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$nstSection"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	



		
		
		<xsl:variable name="intAffectedSections" as="xs:integer" select="count($affectedProvisions[self::ukm:Section])"/>
		
		<!-- if there are multiple affecting provisions then we need to make each into an individual effect  -->
		<xsl:for-each select="$affectingProvisions[self::ukm:Section or self::ukm:SectionRange or . = ('Order','Act','Instrument','Regulations')]">
		
		
			<xsl:variable name="affectingProvisions">
				<xsl:sequence select="."/>
			</xsl:variable>
			
			<xsl:variable name="intAffectingPosition" select="position()"/>
			
		
			<!-- if we have multiple affected provisions that are not a range then we need to make an effect for each of them --> 
			<xsl:for-each select="$affectedProvisions[self::ukm:Section or self::ukm:SectionRange or . = ('Order','Act','Instrument','Regulations')]">
			
				<xsl:variable name="intAffectedPosition" select="position()"/>
					
				
				<xsl:variable name="substitutedProvisions" as="element(ukm:SubstitutedProvisions)?">
					<xsl:if test="$action/@type = 'Substitution' and $provisionAddition and exists($affectedProvisions)">
						<ukm:SubstitutedProvisions>
							<xsl:sequence select="." />
						</ukm:SubstitutedProvisions>
					</xsl:if>
				</xsl:variable>
				
				
				<xsl:variable name="insertionPoint" as="element()?">
					<xsl:choose>
						<xsl:when test="$intAffectedSections &gt; 1">
							<xsl:apply-templates select="$insertionPoint" mode="tso:insertion">
								<xsl:with-param name="position" select="$intAffectedPosition" as="xs:integer" tunnel="yes"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$insertionPoint instance of element(err:Error)">
								<xsl:message>ERROR: <xsl:value-of select="$insertionPoint"/></xsl:message>
							</xsl:if>
							<xsl:sequence select="$insertionPoint"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="affectedProvisions" as="element(ukm:AffectedProvisions)?">
					<xsl:variable name="sectionURIs" as="xs:string*" select="if (not($affectedSection/@minorType = 'contents')) then tso:GetAmendmentSections($action,$affectedSection) else ()" />
					<xsl:if test="exists($affectedProvisions) or exists($sectionURIs)">
						<ukm:AffectedProvisions>
							<xsl:if test="$provisionAddition and empty($sectionURIs)">
								<xsl:message>Unable to find amendment sections for <xsl:value-of select="$action/@id" /></xsl:message>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$affectedSection/ancestor::*/local-name() = ('TableEntryChange','TableAfterEntryChange','InTableChange') or contains($affectedSection/@uri,'table')">
									<!--<xsl:variable name="affectedTableSection" select="tso:section($affectedSection/ancestor::*[local-name() = ('TableEntryChange','TableAfterEntryChange','InTableChange')]/parent::*)"/>-->
									<xsl:variable name="affectedTableSection" select="tso:parentRef($affectedSection)"/>
									
									<xsl:apply-templates select="$affectedTableSection" mode="tso:sections">
										<xsl:with-param name="legislationURI" select="$affectedLeg/@context" />
										<xsl:with-param name="action" select="$action" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:when test="$provisionAddition and exists($sectionURIs)">
									<!-- work out the reference for the substitution -->
									<xsl:choose>
										<xsl:when test="count($sectionURIs) > 1">
											<!-- handle a range -->
											<xsl:variable name="startSectionURI" as="xs:string" select="$sectionURIs[1]" />
											<xsl:variable name="endSectionURI" as="xs:string" select="$sectionURIs[last()]" />
											<xsl:variable name="startSectionRef" as="xs:string" select="tso:calcSectionUriAsId($startSectionURI)" />
											<xsl:variable name="endSectionRef" as="xs:string" select="tso:calcSectionUriAsId($endSectionURI)" />
											<ukm:SectionRange Start="{tso:correctProvisionUri($startSectionRef)}" End="{tso:correctProvisionUri($endSectionRef)}"
												URI="{tso:correctProvisionUri($startSectionURI)}" UpTo="{tso:correctProvisionUri($endSectionURI)}">
												<ukm:Section Ref="{tso:correctProvisionUri($startSectionRef)}" URI="{$affectedLeg/@context}{tso:correctProvisionUri($startSectionURI)}">
													<xsl:value-of select="tso:formatSection($startSectionRef, '-')" />
												</ukm:Section>
												<xsl:text>-</xsl:text>
												<ukm:Section Ref="{tso:correctProvisionUri($endSectionRef)}" URI="{$affectedLeg/@context}{tso:correctProvisionUri($endSectionURI)}">
													<xsl:value-of select="tso:formatSection($endSectionRef, '-', $startSectionRef)" />
												</ukm:Section>
											</ukm:SectionRange>
										</xsl:when>
										<xsl:otherwise>
											<!-- handle a single one -->
											<xsl:variable name="sectionURI" as="xs:string" select="$sectionURIs" />
											<xsl:variable name="sectionRef" as="xs:string" select="tso:calcSectionUriAsId($sectionURI)" />
											
											<ukm:Section Ref="{tso:correctProvisionUri($sectionRef)}" URI="{$affectedLeg/@context}{tso:correctProvisionUri($sectionURI)}">
												<xsl:value-of select="tso:formatSection($sectionRef, '-')" />
											</ukm:Section>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="." />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="contains($affectedSection/@uri,'table') ">
								<xsl:choose>
									<xsl:when test="contains($affectedSection/@uri,',')">
										<xsl:variable name="uriTokens" select="tokenize($affectedSection/@uri,',')"/>
										<xsl:value-of select="translate(normalize-space($uriTokens[$intAffectedPosition]),'/',' ')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="translate($affectedSection/@uri,'/',' ')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="($action/ancestor::*/local-name() = ('TableEntryChange','InlineTableChange','TableChange','TableAfterEntryChange')) "> table entry</xsl:if>
							<xsl:if test="($action/ancestor::*/local-name() = ('RefHeadingChange','InlineLocationForHeading','InlineLocationForHeading','InlineAtEndOfHeading','HeadingChange','InlineHeadingAction')) and not($affectedSection/preceding-sibling::LegConjunction[@type='And'])"> heading</xsl:if>
							<!-- TODO update for allowance of 'entries' amendments 
							this is rather tricky as there are so many different ways that this can be drafted -->
							<!-- we need to allow for drafting techniques that use of a list to cotain a conjoining word between amended sections
							<xsl:if test="$action[@type = ('Insert', 'Substitution')] and 
								$action[@type = ('Insert', 'Substitution')]/following-sibling::*[self::LegAmendment] and 
								$amendment/gate:LegAmendment/*[not(self::leg:P1 or self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6 or self::leg:P7)][not(following-sibling::leg:P1 or following-sibling::leg:P2 or following-sibling::leg:P3 or following-sibling::leg:P4 or following-sibling::leg:P5 or following-sibling::leg:P6 or following-sibling::leg:P7)]/*[self::leg:UnorderedList or self::leg:OrderedList]"> 
								<xsl:text> entries</xsl:text></xsl:if> -->
						</ukm:AffectedProvisions>
					</xsl:if>
				</xsl:variable>
				
				<xsl:variable name="affectingProvisions" as="element(ukm:AffectingProvisions)">
					<ukm:AffectingProvisions>
						<xsl:sequence select="$affectingProvisions"/>
					</ukm:AffectingProvisions>
				</xsl:variable>
			
			
			
			
				<xsl:variable name="EffectName" as="xs:string" select="if ($affectedType = ('primary','secondary') or matches($affectedType,'unknown type','i') or not($affectedType)) then 'UndefinedEffect' else 'Effect'"/>
				
				
				<xsl:element name="ukm:{$EffectName}">
				<!--<ukm:Effect Applied="false" Action="{$action/@id}"
					AffectingURI="{$affectingLeg}" AffectingClass="{$affectingType}" 
					AffectingYear="{$affectingYear}" AffectingNumber="{$affectingNumber}"
					AffectedURI="{$affectedLeg/@context}" AffectedClass="{$affectedType}"
					AffectedNumber="{$affectedNumber}">-->
					<xsl:attribute name="Applied" select="'false'"/>
					<xsl:attribute name="Action" select="$action/@id"/>
					<xsl:attribute name="AffectingURI" select="$affectingLeg"/>
					<xsl:attribute name="AffectingClass" select="$affectingType"/>
					<xsl:attribute name="AffectingYear" select="$affectingYear"/>
					<xsl:if test="exists($affectingNumber)">
						<xsl:attribute name="AffectingNumber" select="$affectingNumber"/>
					</xsl:if>
					<xsl:attribute name="AffectedURI" select="$affectedLeg/@context"/>
					<xsl:attribute name="AffectedClass" select="$affectedType"/>
					<xsl:attribute name="AffectedNumber" select="$affectedNumber"/>
					
					<xsl:if test="exists($legAlternativeNumber) and $legAlternativeNumber != ''">
						<xsl:attribute name="AlternativeAffectingNumber" select="$legAlternativeNumber"/>
					</xsl:if>
					
					
					<xsl:attribute name="Ref">
						<xsl:apply-templates select="$action" mode="Ref" />
					</xsl:attribute>
					<xsl:attribute name="Type">
						<!-- to determine whether this is a block that is being amended or just words we need to check the amended content  -->
						<!-- TODO update for allowance of 'entries' amendments -->
						<xsl:variable name="amendment"  as="xs:boolean" select="if (empty($amendment) or 
						(: $amendment/gate:LegAmendment/*/*[self::leg:UnorderedList or self::leg:OrderedList] or :)
						($amendment/gate:LegAmendment/*[self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:P1group or self::leg:P1 or self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6 or self::leg:P7 or self::leg:Schedule] | $amendment/gate:LegAmendment/(leg:Pblock | leg:PsubBlock)/(leg:P1group | leg:P1) | $amendment/gate:LegRef)) then true() else false()" />	
							
						
						
						<xsl:choose>
							<xsl:when test="$substitutedProvisions">
								<xsl:variable name="strType" as="xs:string" select="if (matches($action,'replace','i')) then 'replaced' else 'substituted'"/>
								<xsl:choose>
									<xsl:when test="contains($affectedSection/@uri,'table')">table substituted</xsl:when>
									<xsl:when test="exists($addition[self::Quote]) or exists($repeal[self::Quote]) (:not($amendment):)">
										<xsl:value-of select="concat('words ',$strType)"/>
									</xsl:when>
									<xsl:when test="$substitutedProvisions = $affectedProvisions or not($amendment)">
										<xsl:value-of select="$strType"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>substituted for </xsl:text>
										<xsl:value-of select="$substitutedProvisions" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$action/@type = 'Insert'">
								<xsl:variable name="strType" as="xs:string" select="if (matches($action,'add','i')) then 'added' else 'inserted'"/>
								<xsl:choose>
									<xsl:when test="$action/ancestor::*[self::TableChange or self::TocChange]"><xsl:value-of select="concat('entry ',$strType)"/></xsl:when>
									<xsl:when test="exists($addition[1][self::Quote]) and not(contains(tso:NormalizeQuote($addition[1][self::Quote]),' '))"><xsl:value-of select="concat('word ',$strType)"/></xsl:when>
									<xsl:when test="exists($addition[self::Quote]) or not($amendment)"><xsl:value-of select="concat('words ',$strType)"/></xsl:when>
									<xsl:when test="$provisionAddition"><xsl:value-of select="$strType"/></xsl:when>
									<xsl:otherwise>text amended</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$action/@type = 'Substitution'">
								<xsl:choose>
									<!-- renumbering -->
									<xsl:when test="$action/following-sibling::*[1][self::LegRef] and matches($action,'become','i')">renumbered</xsl:when>
									<!-- rare occurance of a substitution that is paraphrased as a 'replace' -->
									<xsl:when test="$action/preceding-sibling::Location[1] = 'replace'">replaced</xsl:when>
									<xsl:when test="contains($affectedSection/@uri,'table')">table substituted</xsl:when>
									<!-- bit of a bodge to determine if this is a single word amendment  -->
									<xsl:when test="(exists($addition[1][self::Quote]) and not(contains(tso:NormalizeQuote($addition[1][self::Quote]),' '))) and 
													(exists($repeal[self::Quote]) and not(contains(tso:NormalizeQuote($repeal[1][self::Quote]),' ')))">word substituted</xsl:when>
									<xsl:when test="exists($addition[self::Quote]) or not($amendment)">words substituted</xsl:when>
									<xsl:when test="$provisionAddition">substituted</xsl:when>
									<xsl:otherwise>text amended</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$action/@type = 'Delete'">
								<xsl:variable name="strType" as="xs:string" select="if (matches($action,'delete','i')) then 'deleted' else 'omitted'"/>
								<xsl:choose>
									<xsl:when test="exists($repealedRange[1][self::ukm:Entry])">
										<xsl:choose>
											<xsl:when test="$repealedRange[1]/ukm:Text[2]">
												<xsl:value-of select="concat('entries ',$strType)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat('entry ',$strType)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="exists($repeal[1][self::Quote]) and not(count($repeal[self::Quote]) &gt; 1) and not(contains(tso:NormalizeQuote($repeal[1][self::Quote]),' '))">
										<xsl:value-of select="concat('word ',$strType)"/>
									</xsl:when>
									
									<xsl:when test="$provisionRepeal"><xsl:value-of select="$strType"/></xsl:when>
									<xsl:when test="not(exists($repeal[1][self::Quote or self::LegRef]))">
										<xsl:value-of select="concat('entry ',$strType)"/>
									</xsl:when>
									<xsl:when test="exists($repeal[1][self::Quote]) and (not($amendment) or not(exists($repeal[1][self::LegRef])))"><xsl:value-of select="concat('words ',$strType)"/></xsl:when>
									
									<!--<xsl:when test="not(exists($repeal[1][self::Quote or self::LegRef])) and not($amendment)">
										<xsl:value-of select="concat('entry ',$strType)"/>
									</xsl:when>
									<xsl:when test="exists($repeal[1][self::Quote]) or (not($amendment) and not(exists($repeal[1][self::LegRef])))"><xsl:value-of select="concat('words ',$strType)"/></xsl:when>
									-->
									
									<xsl:when test="$provisionRepeal"><xsl:value-of select="$strType"/></xsl:when>
									<xsl:otherwise>text amended</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$action/@type = 'ComingIntoForce'">coming into force</xsl:when>
							<xsl:when test="$action/@type = 'Repeal'">
								<xsl:choose>
									<xsl:when test="contains($action,'revoked')">revoked</xsl:when>
									<xsl:otherwise>repeal</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$type" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="exists($affectedYear)">
						<xsl:attribute name="AffectedYear" select="$affectedYear" />
					</xsl:if>
					<xsl:if test="$affectedProvisions">
						<xsl:attribute name="AffectedProvisions" select="if (string($affectedProvisions) = 'contents') then 'Table of Contents' else string($affectedProvisions)" />
					</xsl:if>
					<xsl:if test="$affectingProvisions">
						<xsl:attribute name="AffectingProvisions" select="normalize-space(string($affectingProvisions))" />
					</xsl:if>
					<xsl:if test="$substitutedProvisions">
						<xsl:attribute name="SubstitutedProvisions"  >
							<xsl:choose>
								<xsl:when test="contains($affectedSection/@uri,'table')">
									<xsl:value-of select="string($affectedProvisions)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="string($substitutedProvisions)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$affectedSection and not($affectedSection instance of element(Legislation)) and not($action/@type = 'Repeal')">
						<xsl:attribute name="AffectedCitationRef">
							<xsl:apply-templates select="key('legislationCitation', $affectedSection/@id, $action/ancestor::document-node())" mode="Ref" />
						</xsl:attribute> 
					</xsl:if>
					<xsl:if test="$addition">
						<xsl:attribute name="AdditionRef">
							<xsl:apply-templates select="$addition" mode="Ref" />
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="exists($substitutedProvisions) and not($repeal instance of element(Quote)) and not($affectedSection/ancestor::TableEntryChange or contains($affectedSection/@uri,'table'))">
							<xsl:if test="$substitutedProvisions instance of element(err:Error)">
								<xsl:message>ERROR: <xsl:value-of select="$insertionPoint"/></xsl:message>
							</xsl:if>
							<xsl:sequence select="$substitutedProvisions" />
						</xsl:when>
						<xsl:when test="$action/@type = 'Substitution'">
							<ukm:SubstitutedRange>
								<xsl:if test="$repeal instance of element(err:Error)">
									<xsl:message>ERROR: <xsl:value-of select="$repeal"/></xsl:message>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="$affectedSection/ancestor::TableEntryChange">
										<!-- TODO -->
										<ukm:Match>
											<ukm:TableEntry>
												<xsl:choose>
													<xsl:when test="$repeal instance of element(RefHeadingChange)">
														<ukm:Heading>
															<xsl:sequence select="$affectedProvisions/*" />
														</ukm:Heading>
													</xsl:when>
													<xsl:otherwise>
														<xsl:sequence select="$affectedProvisions/*" />
														<xsl:if test="$repeal instance of element(Quote)">
															<xsl:apply-templates select="$repeal" mode="tso:text" />
														</xsl:if>
													</xsl:otherwise>
												</xsl:choose>
											</ukm:TableEntry>
										</ukm:Match>
									</xsl:when>
									<xsl:when test="contains($affectedSection/@uri,'table')">
										<ukm:Match>
											<xsl:sequence select="$affectedProvisions/node()" />
										</ukm:Match>
									</xsl:when>
									<xsl:when test="$affectedSection/@minorType='contents'">
										<ukm:Match>
											<!-- TODO -->
											<xsl:sequence select="$affectedProvisions/*" />
											<xsl:apply-templates select="$repeal" mode="tso:related" />
											<xsl:apply-templates select="$repeal" mode="tso:text" />
										</ukm:Match>
									</xsl:when>
									<xsl:when test="($affectedSection/preceding-sibling::LegConjunction[@type='And'] or $affectedSection/following-sibling::RefHeadingChange/LegConjunction[@type='And']) and exists($repeal)">
										<ukm:Match>
											<xsl:apply-templates select="Location" mode="tso:position" />
											<xsl:sequence select="$affectedProvisions/*" />
											<xsl:apply-templates select="$repeal" mode="tso:text" />
										</ukm:Match>
									</xsl:when>
									<xsl:when test="$repealedRange">
										<xsl:if test="$repealedRange instance of element(err:Error)">
											<xsl:message>ERROR: <xsl:value-of select="$repeal"/></xsl:message>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$intAffectedSections &gt; 1">
												<xsl:apply-templates select="$repealedRange" mode="tso:insertion">
													<xsl:with-param name="position" select="$intAffectedPosition" as="xs:integer" tunnel="yes"/>
												</xsl:apply-templates>
											</xsl:when>
											<xsl:otherwise>
												<xsl:sequence select="$repealedRange"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$repeal" mode="tso:repealRange" />
									</xsl:otherwise>
								</xsl:choose>
							</ukm:SubstitutedRange>
						</xsl:when>
						<xsl:when test="$action/@type = 'Delete' and $action/../ActionDeleteList  and not($provisionRepeal)">
							<ukm:OmittedRange>
								<!--<xsl:sequence select="$repealedRange[$intAffectingPosition]" />-->
								<xsl:sequence select="if (not($provisionRepeal) and not($affectedSection/@minorType = 'contents') and exists($repeal[$intAffectingPosition])) then tso:repealRange($repeal[$intAffectingPosition],$affectedSection) else ()" />
							</ukm:OmittedRange>
						</xsl:when>
						<xsl:when test="$action/@type = 'Delete' and not($provisionRepeal)">
							<ukm:OmittedRange>
								<xsl:sequence select="$repealedRange" />
							</ukm:OmittedRange>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="$action/@type = 'Insert'">
						<ukm:InsertionPoint>
							<xsl:sequence select="$insertionPoint" />
						</ukm:InsertionPoint>
					</xsl:if>
					<xsl:if test="$addition and not($provisionAddition)">
						<xsl:choose>
							<xsl:when test="$action/@type = 'Substitution'">
								<ukm:Substitution>
									<xsl:apply-templates select="$addition" mode="tso:text" />
								</ukm:Substitution>
							</xsl:when>
							<xsl:when test="$action/@type = 'Insert'">
								<ukm:Insertion>
									<xsl:apply-templates select="$addition" mode="tso:text" />
								</ukm:Insertion>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$action/@type = 'ComingIntoForce' and exists($date)">
						<xsl:variable name="location" as="element()?">
							<xsl:apply-templates select="$affectedSection" mode="tso:qualification"/>
						</xsl:variable>
						
						<xsl:variable name="qualification" as="xs:string">
							<xsl:choose>
								<xsl:when test="$location instance of element(Location)">
									<xsl:choose>
										<xsl:when test="$location/@type='NotInForce'">
											<xsl:text>in force in so far as not already in force</xsl:text>
										</xsl:when>
										<xsl:when test="$location/@type='Relates'">
											<xsl:text>for specified provisions</xsl:text>
										</xsl:when>
										<xsl:otherwise>wholly in force</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>wholly in force</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<ukm:InForceDates>
							<xsl:for-each select="$date">
								<xsl:if test="@year and @month and @day">
									<ukm:InForce Date="{tso:dateFromString($date/@year,$date/@month,$date/@day)}" Qualification="{$qualification}" />
								</xsl:if>
							</xsl:for-each>
						</ukm:InForceDates>
					</xsl:if>
					<xsl:sequence select="$affectedProvisions" />
					<xsl:sequence select="$affectingProvisions" />
				</xsl:element>
		
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>


	<!-- the tso:insertion mode templates will update the insertion point when there are multiple provisions - these will be made into separate effects  -->
	<xsl:template match="node() | @*" mode="tso:insertion">
		<xsl:param name="position"  as="xs:integer" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="tso:insertion"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ukm:SectionRange/ukm:Section | ukm:SectionGroup/ukm:Section" mode="tso:insertion" priority="5">
		<xsl:param name="position" as="xs:integer" tunnel="yes"/>
		<xsl:if test="$position = (count(preceding-sibling::ukm:Section) + 1)">
			<xsl:copy>
				<xsl:apply-templates select="node() | @*" mode="tso:insertion"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ukm:SectionRange | ukm:SectionGroup" mode="tso:insertion">
		<xsl:param name="position" as="xs:integer" tunnel="yes"/>
		<xsl:apply-templates select="node()" mode="tso:insertion"/>
	</xsl:template>

	<!-- TSO:SECTIONS MODE  -->
	<xsl:template match="LegRef[@sourceRef = ''][not(ancestor::EnablingProvisions)]" mode="tso:sections">
		<xsl:message>Missing Source Ref for <xsl:value-of select="."/></xsl:message>
	</xsl:template>

	<xsl:template match="LegRef[@sourceRef != '' or ancestor::EnablingProvisions]" mode="tso:sections">
		<xsl:param name="legislationURI" as="xs:string?">
			<xsl:variable name="legislation" as="element(Legislation)?">
				<xsl:apply-templates select="." mode="tso:legislation" />
			</xsl:variable>
			<xsl:sequence select="$legislation/@context" />
		</xsl:param>
		<xsl:param name="action" as="element()?"/>
		
		<xsl:variable name="parentRef" select="tso:parentRef(.)" as="element()?" />
		
		<xsl:variable name="minorType" select="@minorType" />
		
		<xsl:variable name="parentSection" as="element()?" >
			<xsl:variable name="legislation" as="element(Legislation)?">
				<xsl:apply-templates select="if (exists($action)) then $action else ." mode="tso:legislation" />
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$minorType = 'contents' or ($parentRef/@minorType='rule' and $minorType='rule')">
					<xsl:choose>
						<xsl:when test="exists($legislation)"><xsl:sequence select="$legislation"/></xsl:when>
						<xsl:otherwise><err:Error>INFO: No Legislation found</err:Error></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- we may need to extend the tso:parentRef() function to look backwards if there are parent legref in the source of the LD Commencement Finder  -->
				<xsl:when test="$parentRef instance of element(err:Error) and ancestor::Changes[@parserName='LD Commencement Finder']">
					<xsl:choose>
						<xsl:when test="exists($legislation)"><xsl:sequence select="$legislation"/></xsl:when>
						<xsl:otherwise><err:Error>INFO: No Legislation found</err:Error></xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$parentRef"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		
		<!-- THIS IS A DUBIOUS FIX THAT COULD BE SUPERSEDED BY A GATE FIX  -->
		<!-- it allows for adjacent paras that are nested in the gate markup as the same change  -->
		<xsl:variable name="parentSection" select="if ($parentSection/@minorType = 'paragraph' and $minorType = 'paragraph' and matches(@uri,'^/paragraph/[a-z0-9]+$','i') and matches($parentSection/@uri,'^/paragraph/[a-z0-9]+$','i')) then tso:parentRef($parentSection) else $parentSection" />
		<!-- END OF FIX  -->
		
		<xsl:variable name="sectionsString" as="xs:string+" select="." />
		<xsl:variable name="sections" as="xs:string*" select="tokenize(@uri, '\s*,\s*')" />
		<xsl:choose>
			<xsl:when test="not(@uri) or count($sections) = 0">
				<err:Error>No sections defined</err:Error>
			</xsl:when>
			<xsl:when test="contains(@uri, ', ') and exists($action) and count($sections) = 2 and ($action/following-sibling::LegAmendment or not($action/@type = ('Insert', 'Substitution', 'ComingIntoForce'))) ">
				<xsl:variable name="start" select="substring-before(@uri, ', ')" />
				<xsl:variable name="end" select="substring-after(@uri, ', ')" />
				
				<xsl:variable name="end" select="if (matches(.,'[^s][^\s]\([a-z0-9]+\)\sand\s\([a-z0-9]+\)$','i') and not(contains($start,'paragraph') and contains($end,'paragraph'))) then replace($start,'/[a-z0-9]+$',$end) else $end" />
				
				<xsl:variable name="startSectionURI" as="xs:string" select="tso:sectionUri($start, $minorType, $parentSection)" />
				<xsl:variable name="endSectionURI" as="xs:string" select="tso:sectionUri($end, $minorType, $parentSection)" />
				<xsl:variable name="startSectionRef" as="xs:string" select="tso:calcSectionUriAsId($startSectionURI)" />
				<xsl:variable name="endSectionRef" as="xs:string" select="tso:calcSectionUriAsId($endSectionURI)" />
				
				
				<ukm:SectionRange Start="{tso:correctProvisionUri($startSectionRef)}" End="{tso:correctProvisionUri($endSectionRef)}" 
					URI="{$legislationURI}{tso:correctProvisionUri($startSectionURI)}" UpTo="{$legislationURI}{tso:correctProvisionUri($endSectionURI)}">
					<ukm:Section Ref="{tso:correctProvisionUri($startSectionRef)}" URI="{$legislationURI}{tso:correctProvisionUri($startSectionURI)}">
						<xsl:value-of select="tso:formatSection($startSectionRef, '-')" />
					</ukm:Section>
					<xsl:text> </xsl:text>
					<ukm:Section Ref="{tso:correctProvisionUri($endSectionRef)}" URI="{$legislationURI}{tso:correctProvisionUri($endSectionURI)}">
						<xsl:value-of select="tso:formatSection($endSectionRef, '-', $startSectionRef)" />
					</ukm:Section>
				</ukm:SectionRange>
			</xsl:when>
			<xsl:otherwise>
			<xsl:variable name="firstSection" as="xs:string?" select="$sections[position() = 1]" />
			<xsl:for-each select="$sections">
				<xsl:variable name="i" as="xs:integer" select="position()" />
				<xsl:variable name="previousSection" as="xs:string?" select="$sections[position() = $i - 1]" />
				
				<xsl:if test="position() != 1"><xsl:text> </xsl:text></xsl:if>
				<xsl:choose>
					<xsl:when test="contains(., 'RANGE')">
						<!-- we need to allow for instances such as 426/2 RANGE /4  -->
						<xsl:variable name="start" select="substring-before(., ' RANGE ')" />
						<xsl:variable name="end" select="substring-after(., ' RANGE ')" />
						<xsl:variable name="startTokens" select="tokenize(if (starts-with($start,'/')) then substring-after($start,'/') else $start, '/')" />
						<xsl:variable name="endTokens" select="tokenize(if (starts-with($end,'/')) then substring-after($end,'/') else $end, '/')" />
						<xsl:variable name="end" select="if (count($startTokens) != count($endTokens)) then 
											concat((if (starts-with($start,'/')) then '/' else ''),
											string-join(for $i in 1 to (count($startTokens) - count($endTokens)) return $startTokens[$i], '/'),
											(if (starts-with($end,'/')) then $end else concat('/',$end))) 
											else $end" />
						<xsl:variable name="startSectionURI" as="xs:string" select="tso:sectionUri($start, $minorType, $parentSection)" />
						<xsl:variable name="endSectionURI" as="xs:string" select="tso:sectionUri($end, $minorType, $parentSection)" />
						<xsl:variable name="startSectionRef" as="xs:string" select="tso:calcSectionUriAsId($startSectionURI)" />
						<xsl:variable name="endSectionRef" as="xs:string" select="tso:calcSectionUriAsId($endSectionURI)" />
						<ukm:SectionRange Start="{$startSectionRef}" End="{$endSectionRef}" 
							URI="{$legislationURI}{$startSectionURI}" UpTo="{$legislationURI}{$endSectionURI}">
							<ukm:Section Ref="{tso:correctProvisionUri($startSectionRef)}" URI="{$legislationURI}{tso:correctProvisionUri($startSectionURI)}">
								<xsl:value-of select="tso:formatSection($startSectionRef, '-')" />
							</ukm:Section>
							<xsl:text>-</xsl:text>
							<ukm:Section Ref="{tso:correctProvisionUri($endSectionRef)}" URI="{$legislationURI}{tso:correctProvisionUri($endSectionURI)}">
								<xsl:value-of select="tso:formatSection($endSectionRef, '-', $startSectionRef)" />
							</ukm:Section>
						</ukm:SectionRange>
					</xsl:when>
					<!-- where we have combined sections such as   regulation 5(12)(a) and (b)   we need to take into account the preceding provision numbers  -->
					<!--  we also need to distinguish between absolute refernces such as paragraph/5 and paragraph/8  which will not need the trackback-->
					<xsl:when test="position() != 1 and $firstSection and matches($sectionsString,'\([a-z0-9]+\)\sand\s\([a-z0-9]+\)$','i') and not(contains($firstSection,'paragraph') and contains(.,'paragraph'))">
						
						<xsl:variable name="fullPath" as="xs:string" select="replace($firstSection,'/[a-z0-9]+$',.)" />
						<xsl:variable name="sectionURI" as="xs:string" select="tso:sectionUri($fullPath, $minorType, $parentSection)" />
						<xsl:variable name="sectionRef" as="xs:string" select="tso:calcSectionUriAsId($sectionURI)" />
						
					
						<!--<xsl:value-of select="tso:formatSection($sectionRef, '-', $previousSectionRef)" />-->
						<ukm:Section Ref="{tso:correctProvisionUri($sectionRef)}" URI="{$legislationURI}{tso:correctProvisionUri($sectionURI)}">
							<xsl:value-of select="tso:formatSection($sectionRef, '-')" />
						</ukm:Section>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="sectionURI" as="xs:string" select="tso:sectionUri(., $minorType, $parentSection)" />
						<xsl:variable name="sectionRef" as="xs:string" select="tso:calcSectionUriAsId($sectionURI)" />
						<ukm:Section Ref="{tso:correctProvisionUri($sectionRef)}" URI="{$legislationURI}{tso:correctProvisionUri($sectionURI)}">
							<xsl:value-of select="tso:formatSection($sectionRef, '-')" />
						</ukm:Section>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<!-- this is to process whole act repeals  - we need to reference the category that represents the legislation type and pass this back as a string-->
	<xsl:template match="Legislation[@sourceRef != '']" mode="tso:sections">
		<xsl:param name="legislationURI" as="xs:string?"/>
		<xsl:variable name="strType" select="@type" as="xs:string?"/>
		<xsl:variable name="strCategory" as="xs:string">
			<xsl:choose>
				<!-- not when it is an SI and an order it should be recognised as such - optherwise we will just use the category of the legislation type  -->
				<xsl:when test="not($strType) or $strType = ''"><xsl:value-of select="concat('ERROR: no type for ',@id)"/></xsl:when>
				<xsl:when test="@type = ('wsi','ssi','uksi','secondary') and matches(.,'\sorder\s+[0-9]{4}','i')">Order</xsl:when>
				<xsl:when test="@type = ('wsi','ssi','uksi','secondary') and matches(.,'\sregulations\s+[0-9]{4}','i')">Regulations</xsl:when>
				<xsl:when test="@type = ('wsi','ssi','uksi','secondary') and matches(.,'\srules\s+[0-9]{4}','i')">Rules</xsl:when>
				<xsl:otherwise><xsl:value-of select="$tso:legTypeMap[@abbrev = $strType]/@category"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="starts-with($strCategory,'ERROR')">
			<xsl:message><xsl:value-of select="concat('ERROR: no type for ',@id)"/></xsl:message>
		</xsl:if>
		<xsl:value-of select="$strCategory"/>
	</xsl:template>

	<xsl:template match="Anaphor[@subType='ThisLegislation']" mode="tso:sections">
		<xsl:param name="legislationURI" as="xs:string?"/>
		<xsl:variable name="strSchemaType" select="$legType" as="xs:string"/>
		<xsl:variable name="strType" select="$tso:legTypeMap[@schemaType = $strSchemaType]/@abbrev"/>
		<xsl:variable name="strCategory" as="xs:string">
			<xsl:choose>
				<!-- not when it is an SI and an order it should be recognised as such - optherwise we will just use the category of the legislation type  -->
				<xsl:when test="$strType = ('wsi','ssi','uksi','secondary') and matches(.,'\sorder\s*','i')">Order</xsl:when>
				<xsl:when test="$strType = ('wsi','ssi','uksi','secondary') and matches(.,'\sregulations\s*','i')">Regulations</xsl:when>
				<xsl:when test="$strType = ('wsi','ssi','uksi','secondary') and matches(.,'\srules\s*','i')">Rules</xsl:when>
				<xsl:otherwise><xsl:value-of select="$tso:legTypeMap[@schemaType = $strSchemaType]/@category"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$strCategory"/>
	</xsl:template>
	
	
	
<xsl:template match="*" mode="action" priority="1">
	<xsl:element name="ukm:{local-name()}">
		<xsl:apply-templates mode="action" />
	</xsl:element>
</xsl:template>

<xsl:template match="err:Error" mode="#all">
	<xsl:sequence select="." />
</xsl:template>

<xsl:template match="ukm:Changes//*[@id]" mode="Ref">
	<xsl:variable name="ref">
		<xsl:apply-templates select="key('markup', @id)" mode="Ref" />
	</xsl:variable>
	<xsl:sequence select="if (exists($ref) and $ref != '') then $ref else concat('ERRORref no element found for ', @id)"/>
</xsl:template>

<xsl:template match="ukm:Anaphor" mode="Ref">
	<xsl:variable name="nextPlaceholder" as="element()" select="following::*[@id][1]" />
	<xsl:variable name="nextPlaceholderMarkup" as="element()" select="key('markup', $nextPlaceholder/@id)" />
	<xsl:apply-templates select="$nextPlaceholderMarkup/preceding::gate:Anaphor[1]" mode="Ref" />
</xsl:template>

<xsl:template match="ukm:InlineLocationAtEndNoRef" mode="Ref">
	<xsl:variable name="nextPlaceholder" as="element()" select="following::*[@id][1]" />
	<xsl:variable name="nextPlaceholderMarkup" as="element()" select="key('markup', $nextPlaceholder/@id)" />
	<xsl:apply-templates select="$nextPlaceholderMarkup/preceding::gate:Location[@type = 'AtTheEnd'][1]" mode="Ref" />
</xsl:template>

<xsl:template match="ukm:InlineLocationAtAppropriatePlace" mode="Ref">
	<xsl:variable name="nextPlaceholder" as="element()" select="following::*[@id][1]" />
	<xsl:variable name="nextPlaceholderMarkup" as="element()" select="key('markup', $nextPlaceholder/@id)" />
	<xsl:apply-templates select="$nextPlaceholderMarkup/preceding::gate:Location[@type = 'AppropriatePlace'][1]" mode="Ref" />
</xsl:template>

<xsl:template match="ukm:LegAmendment" mode="Ref" as="xs:string" priority="5">
	<xsl:variable name="action" as="element(Action)" select="preceding-sibling::Action" />
	<xsl:apply-templates select="tso:GetAmendment($action)" mode="Ref" />
</xsl:template>

<xsl:template match="ukm:InlineLocationSetOutIn" mode="Ref" as="xs:string+" priority="5">
	<xsl:apply-templates select="tso:GetAmendment(.)" mode="Ref" />
</xsl:template>

<xsl:template match="ukm:RefHeadingChange" mode="Ref" as="xs:string+" priority="5">
	<xsl:apply-templates select="../LegRef" mode="Ref" />
</xsl:template>



<xsl:template match="ukm:Action" mode="Ref" priority="10">
	<xsl:text>e</xsl:text><xsl:number level="any" format="00000" />
</xsl:template>

<xsl:template match="leg:InlineAmendment/gate:Quote" mode="Ref">
	<xsl:apply-templates select=".." mode="Ref" />
</xsl:template>

<xsl:template match="gate:Quote" mode="Ref">
	<xsl:value-of>q<xsl:number level="any" format="00000" /></xsl:value-of>
</xsl:template>

<xsl:template match="gate:Legislation | gate:LegRef | gate:SubLocation | gate:SubLocationGroup" mode="Ref">
	<!-- although we are not using saxon9-2 we need this to make sure that we return a string not a sequence of strings  -->
	<!-- use the prefix cg so that this does not get overwritten by the augment routines - we need to keep these ids for effects linking  -->
	<xsl:variable name="strRefNum">
		<xsl:value-of>cg<xsl:number value="count(preceding::*[self::gate:Legislation | self::gate:LegRef | self::gate:SubLocation | self::gate:SubLocationGroup]) + $citationStartNumber" format="00000" /></xsl:value-of>
	</xsl:variable>
	<xsl:value-of select="string-join($strRefNum,'')"/>
</xsl:template>

<xsl:template match="gate:Anaphor | gate:Location[@type = ('AtTheEnd', 'AppropriatePlace')]" mode="Ref">
	<xsl:value-of>s<xsl:number count="gate:Anaphor | gate:Location[@type = ('AtTheEnd', 'AppropriatePlace')]" level="any" format="00000" /></xsl:value-of>
</xsl:template>

<xsl:template match="leg:InlineAmendment | leg:BlockAmendment" mode="Ref">
	<xsl:value-of>a<xsl:number count="leg:InlineAmendment | leg:BlockAmendment" level="any" format="00000" /></xsl:value-of>
</xsl:template>

<xsl:template match="leg:Legislation" mode="Ref" />

<xsl:template match="*" mode="Ref">
	<xsl:value-of select="concat('ERRORref', translate(name(), ':', '_'))" />
</xsl:template>

<xsl:function name="tso:calcAffectedLeg" as="element(Legislation)">
	<xsl:param name="context" as="element()" />
	<xsl:param name="affectedLeg" as="element(Legislation)?" />
	<xsl:variable name="affectedLeg" as="element(Legislation)?" select="if (empty($affectedLeg) and $context/LocationLegislation) then $context/LocationLegislation/Legislation else $affectedLeg"/>        
	<xsl:variable name="affectedLeg" as="element(Legislation)?" select="if (empty($affectedLeg) and $context/Legislation) then $context/Legislation else $affectedLeg"/>
	<xsl:variable name="affectedLeg" as="element(Legislation)" select="if (empty($affectedLeg)) then $context/preceding::Legislation[1] else $affectedLeg"/>
	<xsl:sequence select="$affectedLeg"/>
</xsl:function>

<xsl:template match="InRefChange | InParaChange | InGroupChange | RefAmendment | ParaAmendment | TableAmendment | GroupOfLegislationAmendment | RefOfLegislationAmendment" mode="calcAmends">
	<xsl:param name="affectedLeg" as="element(Legislation)?" tunnel="yes" select="Legislation" />
	<xsl:variable name="context" select="."/>
	<xsl:variable name="affectedLeg" as="element(Legislation)" select="tso:calcAffectedLeg(., $affectedLeg)"/>
	<xsl:apply-templates select="Error" mode="#current"/>
	<!-- We need for-each because may be more than one section referred to -->
	<xsl:for-each select="LegRef">
		<xsl:apply-templates select="$context/(* except (LegRef | LegConjunction | Error))" mode="#current">
			<xsl:with-param name="affectedLeg" tunnel="yes" select="$affectedLeg" />
			<xsl:with-param name="affectedSection" tunnel="yes" select="." />
		</xsl:apply-templates>
	</xsl:for-each>
</xsl:template>

<xsl:function name="tso:calcYearFromUri" as="xs:integer?">
	<xsl:param name="uri"/>
	<xsl:variable name="year" select="substring-after($uri, 'http://www.legislation.gov.uk/id/')"/>
	<xsl:variable name="year" select="substring-before(substring-after($year, '/'), '/')"/>
	<xsl:sequence select="if ($year castable as xs:integer) then xs:integer($year) else ()"/>
</xsl:function>

<xsl:function name="tso:calcRegnalYearFromUri" as="xs:string?">
	<xsl:param name="uri"/>
	<xsl:variable name="year" select="substring-after($uri, 'http://www.legislation.gov.uk/id/')"/>
	<xsl:variable name="tokens" select="tokenize($year, '/')" />
	<xsl:sequence select="string-join($tokens[not(position() = 1 or position() = last())],'/')"/>
</xsl:function>

<xsl:function name="tso:calcNumberFromUri" as="xs:integer?">
	<xsl:param name="uri"/>
	<xsl:variable name="path" select="substring-after($uri, 'http://www.legislation.gov.uk/id/')" />
	<xsl:variable name="tokens" select="tokenize($path, '/')" />
	<xsl:sequence select="if ($tokens[last()] castable as xs:integer and string-length($tokens[last()]) &lt; 6) then xs:integer($tokens[last()]) else ()"/>
</xsl:function>

    <xsl:function name="tso:calcLegislationFromUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:variable name="number" select="replace($uri, '(http://www\.legislation\.gov\.uk/id/[^/]+/[^/]+/[^/]+/).*', '$1')"/>
        <xsl:value-of select="$number"/>
    </xsl:function>

    <xsl:function name="tso:calcSectionFromUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:variable name="number" select="replace($uri, 'http://www\.legislation\.gov\.uk/id/[^/]+/[^/]+/[^/]+(/.*)', '$1')"/>
        <xsl:value-of select="$number"/>
    </xsl:function>

<!-- Expecting format /regulation/2/1 -->
<xsl:function name="tso:calcSectionUriAsId" as="xs:string">
	<xsl:param name="number" as="xs:string"/>
	<xsl:variable name="result" select="translate(substring($number, 2), '/', '-')"/>
	<xsl:value-of select="$result"/>
</xsl:function>

<!-- Expects /283/1 and 'regulation', etc -->
<xsl:function name="tso:calcUriFromSection" as="xs:string">
	<xsl:param name="number" as="xs:string" />
	<xsl:param name="docType" as="xs:string?" />
	<xsl:choose>
		<xsl:when test="$number = 'RANGE'">RANGE</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="result">
				<xsl:choose>
					<xsl:when test="starts-with($number, concat('/', $docType)) or empty($docType)" />
					<xsl:when test="$docType = 'contents'">/contents</xsl:when>
					<xsl:when test="$docType = ('regulation','regulations')">/regulation</xsl:when>
					<xsl:when test="$docType = ('article','articles')">/article</xsl:when>
					<xsl:when test="$docType = 'rule'">/rule</xsl:when>
					<xsl:when test="$docType = ('section','sections')">/section</xsl:when><!-- alloance for plural when there is a range  -->
					<xsl:when test="$docType = 'paragraph'">/paragraph</xsl:when>
				</xsl:choose>
				<xsl:value-of select="$number" />
			</xsl:variable>
			<xsl:value-of select="$result" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
    
    <!-- Prefix is any higher level part of the URI that needs to be prepended -->
    <xsl:function name="tso:uriSplitter">
        <xsl:param name="text"/>
        <xsl:param name="prefix"/>
        <xsl:choose>
            <xsl:when test="exists(tokenize($text, ', ')[position() > 1])">
                <xsl:variable name="startLevel" select="tokenize($text, ', ')[1]"/>
                <xsl:value-of select="concat($prefix, $startLevel)"/>
                <xsl:for-each select="tokenize($text, ', ')[position() > 1]">
                    <xsl:sequence select="tso:uriGenerator(concat($prefix, $startLevel), tokenize(., ' RANGE '))"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="exists(tokenize($text, ' RANGE '))">
                <xsl:variable name="startLevel" select="tokenize($text, ' RANGE ')[1]"/>
                <xsl:message terminate="no"><xsl:value-of select="$text"/></xsl:message>
                <xsl:sequence select="tso:uriGenerator(concat($prefix, $startLevel), tokenize($text, ' '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="concat($prefix, $text)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="tso:uriGenerator">
        <xsl:param name="topLevel"/>
        <xsl:param name="remainingTokens"/>
        <xsl:variable name="firstToken" select="$remainingTokens[1]"/>
        <xsl:variable name="topLevelParts" select="count(tokenize($topLevel, '/'))" as="xs:integer"/>
        <xsl:variable name="firstTokenParts" select="count(tokenize($firstToken, '/')) - 1" as="xs:integer"/>
        <xsl:variable name="refText">
            <xsl:choose>
                <xsl:when test="$firstToken = 'RANGE'">
                    <xsl:text>RANGE</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$topLevelParts > $firstTokenParts">
                        <xsl:value-of select="string-join(tokenize($topLevel, '/')[position() &lt;= ($topLevelParts - $firstTokenParts)], '/')"/>
                    </xsl:if>
                    <xsl:value-of select="$remainingTokens[1]"/>
                </xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>            
        <xsl:sequence select="$refText"/>
        <xsl:if test="exists($remainingTokens[position() > 1])">
            <xsl:sequence select="tso:uriGenerator($topLevel, $remainingTokens[position() > 1])"/>
        </xsl:if>            
    </xsl:function>

<xsl:function name="tso:parentRef" as="element()">
	<xsl:param name="legRef" as="element(LegRef)" />
	<xsl:variable name="parentRef" as="element()*">
		<xsl:apply-templates select="$legRef" mode="tso:parentRef" />
	</xsl:variable>
	<!-- a part can either be a child to a schedule of part of the main body - therefore if it has no parent we will check to see if it has any legislation parent  -->
	<xsl:variable name="parentRef" as="element()*">
		<xsl:choose>
			<xsl:when test="empty($parentRef) and $legRef[@minorType = 'part']">
				<xsl:apply-templates select="$legRef" mode="tso:legislation" />
			</xsl:when>
			<xsl:when test="$parentRef instance of element(LegRef) and (contains($parentRef/@uri,'table') or contains($parentRef/@uri,'entry')) and not($parentRef is $legRef)">
				<xsl:sequence select="tso:parentRef($parentRef)" />
			</xsl:when>
			<!-- if the minortype is not a section when we have a paragraph then look to see if its in a higher level - ie a InRefChange  -->
			<!-- this is highlighted by uksi/2011/464 but may need some more tailoring -->
			<xsl:when test="$parentRef instance of element(Legislation) and $legRef[@minorType = 'paragraph'] and $legRef/ancestor::*/preceding-sibling::InRefChange[1]/LegRef[@minorType = ('section', 'sections', 'regulation', 'article', 'schedule','rule','contents')]">
				<xsl:sequence select="$legRef/ancestor::*/preceding-sibling::InRefChange[1]/LegRef"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$parentRef"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	
	<xsl:choose>
		<xsl:when test="$parentRef/@id = $legRef/@id">
			<err:Error>INFO: The parent is the same as the LegRef <xsl:value-of select="$legRef/@id" /></err:Error>
		</xsl:when>
		<xsl:when test="empty($parentRef)">
			<err:Error>INFO: Couldn't find parent for LegRef <xsl:value-of select="$legRef/@id" /></err:Error>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$parentRef[last()]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="LegRef[@minorType = ('section', 'sections', 'regulation', 'article', 'schedule','contents')]" mode="tso:parentRef" priority="10">
	<xsl:apply-templates select="." mode="tso:legislation" />
</xsl:template>
<!--
<xsl:template match="LegRef[@minorType = 'rule']" mode="tso:parentRef" priority="10">
	<xsl:variable name="parentRef" as="element()*">
		<xsl:apply-templates select="../../.." mode="tso:location" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$parentRef[1] instance of element(LegRef) and $parentRef[1]/@minorType = 'schedule'">
			<xsl:sequence select="$parentRef[1]" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="tso:legislation" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>-->


<xsl:template match="LegRef[ancestor::Changes[@parserName='LD Commencement Finder']]" mode="tso:parentRef" priority="4">
	<xsl:variable name="sourceRef" select="@sourceRef"/>
	<xsl:sequence select="(ancestor::Changes/preceding-sibling::Changes[@parserName='Commencement Finder']//InlineLocationSetOutIn/LegRef[concat($legUri,@uri) = $sourceRef])[1]" />
</xsl:template>

<xsl:template match="LegRef[preceding-sibling::*[1][self::LegRef]]" mode="tso:parentRef" priority="7">
	<xsl:sequence select="preceding-sibling::LegRef[1]" />
</xsl:template>

<xsl:template match="GroupOfLegislationAmendment[LegRef]" mode="tso:parentRef" priority="7">
	<xsl:sequence select="LegRef[1]" />
</xsl:template>


<xsl:template match="LegRef[following-sibling::*[1][self::Location/@type = 'Of'] and following-sibling::*[2][self::LegRef]]" mode="tso:parentRef" priority="6">
	<xsl:sequence select="following-sibling::LegRef[1]" />
</xsl:template>

<xsl:template match="LegRef[following-sibling::*[1][self::InlineLocationLegislation][InlineLocationOf/Location/@type = 'Of'][InlineLocationOf/LegRef]]" mode="tso:parentRef" priority="5">
	<xsl:sequence select="following-sibling::InlineLocationLegislation[1]/InlineLocationOf/LegRef" />
</xsl:template>

<xsl:template match="LegRef[parent::InlineHeadingTo/parent::HeadingChange/InlineLocationOf[Location/@type = 'Of'][LegRef]]" mode="tso:parentRef" priority="15">
	<xsl:sequence select="parent::InlineHeadingTo/parent::HeadingChange/InlineLocationOf/LegRef" />
</xsl:template>

<xsl:template match="LegRef[not(parent::InlineLocationOf)][parent::*[self::LegParas or matches(self::*/local-name(.), '^InlineLocation.*Para$')]/../InlineLocationOf[Location/@type = 'Of'][LegRef]]" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../../InlineLocationOf/LegRef" />
</xsl:template>

<xsl:template match="LegRef[following-sibling::*[1][self::InlineLocationOf/Location/@type = 'Of'][self::InlineLocationOf/LegRef]]" mode="tso:parentRef" priority="8">
	<xsl:sequence select="following-sibling::InlineLocationOf/LegRef" />
</xsl:template>

<xsl:template match="LegRef[following-sibling::*[1][self::InlineLocationIn/Location/@type = 'In'][self::InlineLocationIn/LegRef]]" mode="tso:parentRef" priority="8">
	<xsl:sequence select="following-sibling::InlineLocationIn/LegRef" />
</xsl:template>

<xsl:template match="InlineLocationIn/LegRef" mode="tso:parentRef">
	<xsl:apply-templates select="../../.." mode="tso:location" />
</xsl:template>

<xsl:template match="LegRef[parent::InlineForRefInDefinition][preceding-sibling::LegRef]" mode="tso:parentRef" priority="15">
	<xsl:sequence select="preceding-sibling::LegRef" />
</xsl:template>

<xsl:template match="*[LocationOf]/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../LocationOf/LegRef" />
</xsl:template>

<xsl:template match="*[LocationOf]/InlineHeadingTo/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../../LocationOf/LegRef" />
</xsl:template>

<xsl:template match="*[LocationLegislation]/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../LocationLegislation/Legislation[1]" />
</xsl:template>

<xsl:template match="*[LocationLegislation]/InlineHeadingTo/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../../LocationLegislation/Legislation[1]" />
</xsl:template>

<xsl:template match="*[Legislation]/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../Legislation[1]" />
</xsl:template>

<xsl:template match="*[Legislation]/InlineHeadingTo/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../../Legislation[1]" />
</xsl:template>

<xsl:template match="*[Legislation]/EnablingProvision/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../../Legislation[1]" />
</xsl:template>

<xsl:template match="CommencementListItem/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="../../Legislation[1]" />
</xsl:template>

<xsl:template match="Changes/*/LegRef" mode="tso:parentRef" priority="2">
	<xsl:apply-templates select="(../preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
</xsl:template>

<xsl:template match="Changes/*/InlineHeadingTo/LegRef" mode="tso:parentRef" priority="2">
	<xsl:apply-templates select="(../../preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
</xsl:template>

<xsl:template match="EnablingProvision/LegRef" mode="tso:parentRef" priority="2">
	<xsl:apply-templates select="(ancestor::EnablingProvisions/preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
</xsl:template>

<xsl:template match="LegRef[parent::*/preceding-sibling::RefOfLegislationAmendment]" mode="tso:parentRef" priority="4">
	<xsl:sequence select="parent::*/preceding-sibling::RefOfLegislationAmendment[1]/LegRef"/>
</xsl:template>

<!--
<xsl:template match="NTtail/LegRef" mode="tso:parentRef" priority="5">
	<xsl:sequence select="ancestor::*/NTreferences/LegRef" />
</xsl:template>-->

<!-- this is to stop looping when the parent goes up the tree rather than down in which case we need to ignore the immediate parent legref -->
<xsl:template match="LocationOf/LegRef" mode="tso:parentRef">
	<xsl:variable name="ancestor" as="element()" select="ancestor::*[not(self::LocationOf)][1]" />
	<xsl:choose>
		<xsl:when test="$ancestor/parent::* instance of element(Changes)">
			<xsl:apply-templates select="($ancestor/preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
		</xsl:when>
		<xsl:when test="@minorType='part'">
			<xsl:apply-templates select="." mode="tso:legislation" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="ancestor::*[not(self::LocationOf)][1]/../.." mode="tso:location" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- this is to stop looping when the parent goes up the tree rather than down in which case we need to ignore the immediate parent legref -->
<xsl:template match="InlineLocationOf/LegRef" mode="tso:parentRef">
	<xsl:variable name="ancestor" as="element()" select="ancestor::*[not(self::InlineLocationOf) and not(self::InlineLocationLegislation/InlineLocationOf)][1]" />
	<xsl:choose>
		<xsl:when test="$ancestor/parent::* instance of element(Changes)">
			<xsl:apply-templates select="($ancestor/preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
		</xsl:when>
		<xsl:when test="@minorType='part'">
			<xsl:apply-templates select="." mode="tso:legislation" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="ancestor::*[not(self::InlineLocationOf)][1]/.." mode="tso:location" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="LocationLegislation/LocationOf//LegRef" mode="tso:parentRef" priority="2">
	<xsl:sequence select="ancestor::LocationLegislation/Legislation[1]" />
</xsl:template>

<xsl:template match="*[matches(local-name(.), '^Leg.*Refs$')]/LegRef | *[matches(local-name(.), '^Leg.*Paras$')]/LegRef | InlineHeadingTo/LegRef | *[matches(local-name(.), '^InlineLocation.+Action$')]/*[1]/LegRef" mode="tso:parentRef">
	<xsl:choose>
		<xsl:when test="local-name(../../..) = 'Changes'">
			<xsl:apply-templates select="(ancestor::Changes/preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="../../.." mode="tso:location" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="InlineLocationSetOutIn/LegRef" mode="tso:parentRef" priority="15">
	<xsl:variable name="context" as="element(LegRef)?" select="following-sibling::LegRef[1]" />
	<xsl:choose>
		<xsl:when test="exists($context)">
			<xsl:sequence select="$context" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="/(GateDocument|DesDocument)/leg:Legislation[1]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="InlineWordsAtEnd/InlineLocationAtEnd/LegRef" mode="tso:parentRef">
	<xsl:apply-templates select="../../../.." mode="tso:location" />
</xsl:template>

<xsl:template match="InlineInDefinition" mode="tso:parentRef">
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>

<xsl:template match="LegRef" mode="tso:parentRef">
	<xsl:apply-templates select="../.." mode="tso:location" />
</xsl:template>

<!--
<xsl:template match="*" mode="tso:location" priority="10">
	<xsl:message>location of <xsl:value-of select="name()" /> <xsl:value-of select="@id" /></xsl:message>
	<xsl:next-match />
</xsl:template>
-->

<xsl:template match="LegRef[ancestor::Changes[@parserName='LD Commencement Finder']]" mode="tso:legislation" priority="6">
	<xsl:variable name="sourceRef" select="@sourceRef"/>
	<xsl:apply-templates select="(ancestor::Changes/preceding-sibling::Changes[@parserName='Commencement Finder']//InlineLocationSetOutIn/LegRef[concat($legUri,@uri) = $sourceRef])[1]" mode="tso:legislation" />
</xsl:template>

<xsl:template match="*[LocationLegislation]" mode="tso:legislation" priority="5">
	<xsl:sequence select="LocationLegislation[Legislation][1]/Legislation[1]" />
</xsl:template>

<xsl:template match="*[InlineLocationLegislation]" mode="tso:legislation" priority="5">
	<xsl:sequence select="InlineLocationLegislation[Legislation][1]/Legislation[1]" />
</xsl:template>

<xsl:template match="*[Legislation]" mode="tso:legislation" priority="4">
	<xsl:sequence select="Legislation[1]" />
</xsl:template>

<xsl:template match="*[Anaphor/@type = 'Legislation']" mode="tso:legislation" priority="5">
	<xsl:apply-templates select="preceding-sibling::*[1]" mode="tso:legislation" />
</xsl:template>

<xsl:template match="Changes/*" mode="tso:legislation">
	<xsl:apply-templates select="preceding-sibling::*[1]" mode="tso:legislation" />
</xsl:template>

<!-- this may be a bit dubious but each NT is generated in its own changes element  -->
<xsl:template match="Changes[@parserName='Non Textual Finder']/*/NTreferences[Anaphor/@type = 'Legislation'] | 
					Changes[@parserName='Non Textual Finder']/*[NTreferences[Anaphor/@type = 'Legislation']] | 
					Changes[@parserName='Non Textual Finder']/*[starts-with(local-name(.), 'NT')][Anaphor/@type = 'Legislation']" 
					priority="10" mode="tso:legislation">
	<xsl:sequence select="(ancestor::Changes/preceding-sibling::Changes[@parserName='Non Textual Finder'][1]//Legislation)[1]" />
</xsl:template>

<xsl:template match="*[NTlegislationProvisions]" mode="tso:legislation" priority="5">
	<xsl:sequence select="NTlegislationProvisions[Legislation][1]/Legislation[1]" />
</xsl:template>

<xsl:template match="*[NTreferences[Legislation]]" mode="tso:legislation" priority="5">
	<xsl:sequence select="NTreferences[Legislation][1]/Legislation[1]" />
</xsl:template>

<xsl:template match="*[NTtail[Legislation]]" mode="tso:legislation" priority="6">
	<xsl:sequence select="NTtail[Legislation][1]/Legislation[1]" />
</xsl:template>

<xsl:template match="EnablingProvisions[preceding-sibling::*]" mode="tso:legislation">
	<xsl:apply-templates select="preceding-sibling::*[1]" mode="tso:legislation" />
</xsl:template>

<xsl:template match="InlineChange" mode="tso:legislation" priority="3">
	<xsl:apply-templates select="preceding-sibling::*[1]" mode="tso:legislation" />
</xsl:template>

<xsl:template match="*" mode="tso:legislation">
	<xsl:apply-templates select=".." mode="tso:legislation" />
</xsl:template>

<xsl:function name="tso:sectionUri" as="xs:string">
	<xsl:param name="legRef" as="element(LegRef)" />
	<xsl:choose>
		<!-- ignore the legref if its a table and go to its parent  -->
		<xsl:when test="not($legRef/@minorType) and (contains($legRef/@uri,'table') or contains($legRef/@uri,'entry'))">
			<xsl:sequence select="tso:sectionUri(tso:parentRef($legRef))" />
		</xsl:when>
		<xsl:when test="not($legRef/@minorType)">
			<xsl:message>ERROR: no minorType for <xsl:value-of select="$legRef/@id"/></xsl:message>
			<xsl:sequence select="concat('/error', ' no minorType')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="tso:sectionUri($legRef/@uri, $legRef/@minorType, tso:parentRef($legRef))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="tso:sectionUri" as="xs:string">
	<xsl:param name="uri" as="xs:string" />
	<xsl:param name="minorType" as="xs:string?" />
	<xsl:param name="parentRef" as="element()" />
	
	<xsl:variable name="localRef" as="xs:string" select="tso:calcUriFromSection($uri, $minorType)" />
	
	<xsl:choose>
		<xsl:when test="$parentRef instance of element(Legislation) or $parentRef instance of element(Anaphor)">
			<xsl:sequence select="$localRef" />
		</xsl:when>
		<xsl:when test="$parentRef instance of element(err:Error)">
			<!-- we dont want an error on the undefined effects as they are undefined - ie we know about it!! 
			<xsl:sequence select="concat('/error', $localRef)" /> -->
			<xsl:sequence select="$localRef" />
		</xsl:when>
		<xsl:when test="$parentRef instance of element(leg:Legislation)">
			<xsl:sequence select="$localRef" />
		</xsl:when>
		<!-- this is to catch instances such as uksi/2011/2056 where the local and parent are the same - therefore we shall take the parent  -->
		<xsl:when test="$parentRef/@uri = $localRef and $parentRef/@minorType = $minorType">
			<xsl:sequence select="tso:sectionUri($parentRef)" />
		</xsl:when>
		<xsl:when test="tso:sectionUri($parentRef) = $localRef">
			<xsl:sequence select="$localRef" />
		</xsl:when>
		<xsl:when test="starts-with($localRef, '/paragraph') and ($parentRef/@minorType = ('section', 'regulation', 'article', 'paragraph','sub-paragraph','subsection','rule'))">
			<xsl:sequence select="concat(tso:sectionUri($parentRef), substring-after($localRef, '/paragraph'))" />
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:sequence select="concat(tso:sectionUri($parentRef), $localRef)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="tso:enablingPowersLegislation" as="element()?">
	<xsl:param name="legRef" as="element(LegRef)" />
	<!-- the enabling powers is usually at the start of the doc and therefore if there is an anaphor element we need to look into the body of the doc to find the gate:legislaiton element as this will not be picked up in the changes as there will be no preceding changes -->
	<xsl:choose>
		<xsl:when test="$legRef/ancestor-or-self::EnablingProvisions//Anaphor[@type='Legislation']">
			<xsl:variable name="id" select="$legRef/@id"/>
			<xsl:variable name="legislation" select="$legRef/root()//leg:Legislation//*[@id=$id]/preceding::gate:Legislation[1]" />
			<xsl:if test="exists($legislation)">
				<Legislation context="{$legislation/@context}" rule="{$legislation/@rule}" type="{$legislation/@type}" id="{$legislation/@id}" sourceRef=""/>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$legRef/preceding::legislation" mode="tso:legislation" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>



<xsl:function name="tso:legislation" as="element()">
	<xsl:param name="action" as="element(Action)" />
	<xsl:variable name="legislation" as="element(Legislation)?" 
		select="$action/ancestor::*[Legislation or LocationLegislation or InlineLocationAfterRefAction or InlineLocationLegislation or InlineTableRefChange][1]/(Legislation | LocationLegislation/Legislation | InlineLocationAfterRefAction//Legislation | InlineLocationLegislation//Legislation | InlineTableRefChange//Legislation)[1]" />
	<xsl:variable name="legislation"  as="element()?" >
		<xsl:choose>
			<xsl:when test="exists($legislation)">
				<xsl:sequence select="$legislation"/>
			</xsl:when>
			<xsl:when test="$action/ancestor::*[LegRefs/Anaphor[@subType='ThisLegislation']]">
				<xsl:sequence select="$action/ancestor::*[LegRefs/Anaphor[@subType='ThisLegislation']]/LegRefs[Anaphor/@subType='ThisLegislation'][1]/Anaphor[@subType='ThisLegislation']"/>	
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
		
	<xsl:choose>
		<xsl:when test="empty($legislation)">
			<!-- we need to make sure the action is from the same parser type -->
			<xsl:variable name="parserName" as="xs:string" select="$action/ancestor::Changes/@parserName" />
			<xsl:variable name="previousAction" as="element(Action)?" select="$action/preceding::Action[ancestor::Changes[@parserName = $parserName]][1]" />
			<!--<xsl:variable name="anaphor" as="element(Anaphor)?" select="$action/ancestor::*[CommencementPara/LegRefs/Anaphor]/CommencementPara/LegRefs/Anaphor" />-->
			<xsl:choose>
			<!--	<xsl:when test="exists($anaphor) and $anaphor/@subType='ThisLegislation'">
					<Legislation xmlns="" context="{$legUri}" type="{substring-before(substring-after($legUri, 'http://www.legislation.gov.uk/id/'), '/')}" />
				</xsl:when>-->
				<!-- if the legislation is in a P1group title it is not picked up so this will do the job for it  -->
				<xsl:when test="$action/root()//gate:Action[@id = $action/@id]/ancestor::leg:P1group/leg:Title/gate:Legislation[@context != '']">
					<xsl:variable name="context" as="element(gate:Legislation)" select="$action/root()//gate:Action[@id = $action/@id]/ancestor::leg:P1group/leg:Title/gate:Legislation[@context != ''][1]"/>
					<Legislation xmlns=""  >
						<xsl:copy-of select="$context/@*"/>
					</Legislation>
				</xsl:when>
				<xsl:when test="exists($previousAction) and not($previousAction/ancestor::Cited)">
					<xsl:sequence select="tso:legislation($previousAction)" />
				</xsl:when>
				<xsl:when test="$action/ancestor::Changes[@parserName = 'Commencement Finder']/preceding-sibling::Changes/Cited/Legislation">
					<xsl:sequence select="$action/ancestor::Changes[@parserName = 'Commencement Finder']/preceding-sibling::Changes/Cited/Legislation" />
				</xsl:when>
				<xsl:when test="exists($previousAction)">
					<err:Error>No cited legislation found for <xsl:value-of select="$action/@id" /></err:Error>
				</xsl:when>
				<xsl:otherwise>
					<err:Error>No legislation found for <xsl:value-of select="$action/@id" /></err:Error>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- if we have a NoContext rule then DES is unable to determine the affected legislation so we need to generate an undetermined effect  -->
		<xsl:when test="empty($legislation/@context) and $legislation/@rule='NoContext'">
			<xsl:variable name="ref" as="xs:string?" select="$legislation/@id" />
			<xsl:variable name="location" as="element()?" select="$legislation/root()//gate:Legislation[@id = $ref]" />
			<!-- if GATE can't find the legislation, sometimes there is a Footnote reference so let's look for that  -->
			<xsl:choose>
				<xsl:when test="$location/leg:FootnoteRef/@Ref and $legislation/root()//leg:Footnote[@id = $location/leg:FootnoteRef/@Ref]//leg:Citation">
					<xsl:variable name="context" as="element(leg:Citation)" select="($legislation/root()//leg:Footnote[@id = $location/leg:FootnoteRef/@Ref]//leg:Citation)[1]"/>
					<Legislation xmlns="" context="{$context/@URI}" type="{substring-before(substring-after($context/@URI, 'http://www.legislation.gov.uk/id/'), '/')}" />
				</xsl:when>
				<!-- this is a fringe case SI 2011/249 -->
				<xsl:when test="$legislation/preceding-sibling::CrossRef/@type='Cited' and $legislation/preceding-sibling::Anaphor/@subType='ThisLegislation'">
					<xsl:sequence select="$legislation/preceding-sibling::Anaphor[@subType='ThisLegislation']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$legislation" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="empty($legislation/@context)">
			<Legislation xmlns="" context="{$legUri}" type="{substring-before(substring-after($legUri, 'http://www.legislation.gov.uk/id/'), '/')}" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legislation" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:section" as="element()+">
	<xsl:param name="action" as="element()" />
	<xsl:variable name="location" as="element()*">
		<xsl:apply-templates select="$action" mode="tso:location" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$action/@type = ('Repeal','ComingIntoForce') and $location instance of element(Legislation)+">
			<xsl:sequence select="$location" />
		</xsl:when>
		<xsl:when test="$action instance of element(NonTextualPhrase) and $location instance of element(Legislation)+">
			<xsl:sequence select="$location" />
		</xsl:when>
		<xsl:when test="$action/@type = 'ComingIntoForce' and $location instance of element(Anaphor)">
			<xsl:sequence select="$location" />
		</xsl:when>
		<xsl:when test="$action instance of element(Anaphor) and $location instance of element(Legislation)">
			<xsl:sequence select="$location" />
		</xsl:when>
		<xsl:when test="$action/ancestor::TocChange">
			<LegRef uri="/contents" minorType="contents" type="Section" sourceRef="$action/@sourceRef">contents</LegRef>
		</xsl:when>
		<xsl:when test="$location instance of element(err:Error)">
			<xsl:sequence select="$location" />
		</xsl:when>
		<xsl:when test="not($location instance of element(LegRef)+) and $location/parent::*//Error">
			<err:Error>GATE could not find LegRef for <xsl:value-of select="$action/@id" /></err:Error>
		</xsl:when>
		<xsl:when test="not($location instance of element(LegRef)+)">
			<err:Error>Location of <xsl:value-of select="$action/@id" /> is not a LegRef</err:Error>
		</xsl:when>
		<xsl:otherwise>
			<!-- take the lst one for the location -->
			<xsl:sequence select="$location" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="*[Anaphor[not(@subType='ThisLegislation') and not(@subType='Of')]]//Action[not(@type='Amendment')]" mode="tso:location" priority="15">
	<xsl:apply-templates select="preceding::Action[1]" mode="tso:location" />
</xsl:template>

<xsl:template match="*[Anaphor[@subType='ThisLegislation']][not(.//LegRef)]//Action" mode="tso:location" priority="15">
	<xsl:sequence select="ancestor::*/Anaphor" />
</xsl:template>

<xsl:template match="Anaphor[@type='WholeLegislation']" mode="tso:location" priority="15">
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>

<xsl:template match="Action[@type='Amendment']" mode="tso:location" priority="15">
	<xsl:sequence select="(following-sibling::*[1]//LegRef)[last()]" />
</xsl:template>

<xsl:template match="*[not(self::NTlocationSubjectTo or self::NTmiddle or self::NTtail) ][LegRef]" mode="tso:location" priority="10">
	<xsl:if test="count(LegRef) &gt; 1">
		<xsl:message>INFO: More than one LegRef found <xsl:for-each select="LegRef"><xsl:value-of select="@id"/> </xsl:for-each></xsl:message>
	</xsl:if>
	<!--<xsl:sequence select="LegRef[1]" />-->
	<xsl:sequence select="LegRef" />
</xsl:template>

<xsl:template match="*[(LegRefs | LegSubRefs | LegSubSubRefs  | LegParas | LegSubRefs | LegSubParas | LegSubSubParas | LegSubSubSubParas)/LegRef]" mode="tso:location" priority="15">
	<xsl:sequence select="(LegRefs | LegSubRefs | LegSubSubRefs  | LegParas | LegSubRefs | LegSubParas | LegSubSubParas | LegSubSubSubParas)/LegRef" />
</xsl:template>



<xsl:template match="*[LegRefs/Anaphor]" mode="tso:location" priority="7">
	<xsl:sequence select="LegRefs/Anaphor" />
</xsl:template>

<!-- special case for coming into force 
<xsl:template match="*[ancestor::Changes[@parserName = 'Commencement Finder']/preceding-sibling::*[1][self::Changes[@parserName = 'Commencement Finder']]/Cited]" mode="tso:location" priority="1">
	<xsl:sequence select="ancestor::Changes/preceding-sibling::*[1]//(Legislation | Anaphor)[1]" />
</xsl:template> -->
<xsl:template match="Changes[@parserName = 'Commencement Finder'][preceding-sibling::*[1][self::Changes[@parserName = 'Commencement Finder']]/Cited]" mode="tso:location" priority="1">
	<xsl:sequence select="preceding-sibling::*[1]//(Legislation | Anaphor)[1]" />
</xsl:template>


<xsl:template match="*[CommencementList/CommencementListItem/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="CommencementListItem/LegRef" />
</xsl:template>

<xsl:template match="*[CommencementList/CommencementSubList/CommencementSubListItem/LegRef | CommencementList/CommencementSubList/CommencementSubListItem/LegRefs/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="CommencementList/CommencementSubList/CommencementSubListItem/LegRef | CommencementList/CommencementSubList/CommencementSubListItem/LegRefs/LegRef" />
</xsl:template>

<xsl:template match="*[CommencementList/CommencementSubList/CommencementSubListItem]" mode="tso:location" priority="9">
	<!--  We can have either LegRefs/LegRef or LegRef here so need to apply templates -->
	<xsl:apply-templates select="CommencementList/CommencementSubList/CommencementSubListItem" mode="tso:location" />
</xsl:template>

<!-- if we have an InlineLocationSetOutIn element for Commencemnts then this will refer to a Long Distance relationship and we need to find all those matches within such parsers -->
<!-- long distance relationships only work for commencements at the min -->
<xsl:template match="*[InlineLocationSetOutIn/LegRef][//Changes[@parserName='LD Commencement Finder']/CommencementRef/LegRef[@sourceRef = concat($legUri, InlineLocationSetOutIn/LegRef/@uri)]]" mode="tso:location" priority="15">
	<xsl:variable name="uri" select="concat($legUri, InlineLocationSetOutIn/LegRef/@uri)"/>
	<xsl:sequence select="//Changes[@parserName='LD Commencement Finder']/CommencementRef/LegRef[@sourceRef = $uri]"/>
</xsl:template>

<xsl:template match="*[InlineLocationSetOutIn/LegRef][//Changes[@parserName='LD Commencement Finder']/CommencementRef/LegRef]" mode="tso:location" priority="10">
	<xsl:variable name="uri" select="concat($legUri, InlineLocationSetOutIn/LegRef[1]/@uri)"/>
	<xsl:choose>
		<xsl:when test="//Changes[@parserName='LD Commencement Finder']/CommencementRef/LegRef/@sourceRef = $uri">
			<xsl:sequence select="//Changes[@parserName='LD Commencement Finder']/CommencementRef/LegRef[@sourceRef = $uri]"/>
		</xsl:when>
		<xsl:otherwise>
			<err:Error>Unable to find a LD match for the LegRef <xsl:value-of select="InlineLocationSetOutIn/LegRef/@id"/></err:Error>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[InlineLocationSetOutIn/LegRef][not(Action)]" mode="tso:location" priority="7">
	<xsl:sequence select="InlineLocationSetOutIn/LegRef" />
</xsl:template>

<xsl:template match="*[InlineLocationOf/LegRef]" mode="tso:location" priority="7">
	<xsl:sequence select="InlineLocationOf/LegRef" />
</xsl:template>

<xsl:template match="InlineForRefInDefinition[LegRef]" mode="tso:location" priority="25">
	<xsl:sequence select="LegRef[last()]" />
</xsl:template>

<xsl:template match="*[ProvisionList/ProvisionListItem/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="ProvisionList/ProvisionListItem/LegRef" />
</xsl:template>

<xsl:template match="*[Legislation]" mode="tso:location" priority="7">
	<xsl:sequence select="Legislation" />
</xsl:template>

<xsl:template match="*[NTlegislationProvisions]" mode="tso:location" priority="10">
	<xsl:sequence select="NTlegislationProvisions/Legislation" />
</xsl:template>

<xsl:template match="*[NTreferences]" mode="tso:location" priority="7">
	<xsl:sequence select="NTreferences/LegRef" />
</xsl:template>

<xsl:template match="*[NTlocationUnderRefs]" mode="tso:location" priority="7">
	<xsl:sequence select="NTlocationUnderRefs/LegRef" />
</xsl:template>

<xsl:template match="*[InlineWordsAtEnd/InlineLocationAtEnd/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="InlineWordsAtEnd/InlineLocationAtEnd/LegRef" />
</xsl:template>

<xsl:template match="InlineLocationAtBeginning[InlineLocationOf/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="InlineLocationOf/LegRef" />
</xsl:template>

<!-- if we have a conjunction that has a heading and a legref we need to capture the parent legref as well to make 2 effects  -->
<xsl:template match="*[LegRef[count(.) = 1]][LegConjunction][Location[@type='Heading']][Location[@type='In']]" mode="tso:location" priority="12">
	<xsl:sequence select="LegRef" />
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>


<xsl:template match="*[ActionDeleteList//LegRef[not(parent::InlineLocationOf)]]" mode="tso:location" priority="10">
	<xsl:sequence select="ActionDeleteList//LegRef[not(parent::InlineLocationOf)]" />
</xsl:template>

<xsl:template match="*[LocationLegislation]" mode="tso:location" priority="8">
	<xsl:sequence select="LocationLegislation/Legislation" />
</xsl:template>

<xsl:template match="*[InlineLocationLegislation]" mode="tso:location" priority="8">
	<xsl:sequence select="InlineLocationLegislation/Legislation" />
</xsl:template>


<!-- provison repela lists need to take the legislation element for each item  -->
<xsl:template match="InlineProvisionRepeal[ActionDeleteList/ActionDeleteListItem/Legislation]" mode="tso:location" priority="1">
	<xsl:sequence select="ActionDeleteList/ActionDeleteListItem/Legislation" />
</xsl:template>

<xsl:template match="*[InlineHeadingTo/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="InlineHeadingTo/LegRef" />
</xsl:template>

<xsl:template match="*[InlineDefinition/LegRef]" mode="tso:location" priority="10">
	<xsl:sequence select="InlineDefinition/LegRef" />
</xsl:template>

<xsl:template match="*[InlineTableRefChange]" mode="tso:location" priority="1">
	<xsl:sequence select="(InlineTableRefChange//LegRef)[1]" />
</xsl:template>

<xsl:template match="*[matches(local-name(.), '^InlineLocation.+RelatedEntryAction')]" mode="tso:location" priority="9">
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>

<xsl:template match="*[matches(local-name(.), '^InlineLocation.+Action$')]" mode="tso:location" priority="10">
	<xsl:variable name="locationElementName" as="xs:string" select="replace(local-name(.), 'Action$', '')" />
	<xsl:choose>
		<xsl:when test="*[local-name(.) = $locationElementName]/LegRef">
			<xsl:sequence select="*[local-name(.) = $locationElementName]/LegRef[1]" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select=".." mode="tso:location" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Changes/*[not(starts-with(string(self::*/local-name()),'NT'))]" mode="tso:location">
	<xsl:apply-templates select="(preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
</xsl:template>

<xsl:template match="Changes/*[starts-with(string(self::*/local-name()),'NT')]" mode="tso:location">
	<xsl:apply-templates select="*[LegRef][1]//LegRef[1]" mode="tso:parentRef" />
</xsl:template>

<!-- COMMENCEMENT ORDERS LOCATIONS -->
<xsl:template match="*[InlineLocationLegislation/InlineLocationOf/LegRef]" mode="tso:location" priority="9">
	<xsl:sequence select="InlineLocationLegislation/InlineLocationOf/LegRef" />
</xsl:template>




<xsl:template match="Changes/LocationAtEndNoRef" mode="tso:location" priority="10">
	<xsl:sequence select="(preceding-sibling::*[1]//LegRef)[1]"/>
</xsl:template>

<xsl:template match="EnablingProvisions" mode="tso:location">
	<xsl:apply-templates select="(preceding-sibling::*[1]//LegRef)[1]" mode="tso:parentRef" />
</xsl:template>

<xsl:template match="ComesIntoForce | CommencementProvision" mode="tso:location" priority="1">
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>

<xsl:template match="NonTextualPhrase" mode="tso:location">
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>

<xsl:template match="DesDocument" mode="tso:location"/>

<xsl:template match="*" mode="tso:location">
	<xsl:apply-templates select=".." mode="tso:location" />
</xsl:template>

<xsl:function name="tso:addition" as="element()*">
	<xsl:param name="action" as="element(Action)" />
	<xsl:apply-templates select="$action" mode="tso:addition" />
</xsl:function>

<xsl:template match="Action" mode="tso:addition" />

<xsl:template match="Action[@type = ('Insert', 'Substitution')]" mode="tso:addition" as="element()*">
	<xsl:apply-templates select=".." mode="tso:addition" />
</xsl:template>

<xsl:template match="InlineActionInsert | ActionInsert | InlineActionSubstitute | InlineLocationAtAppropriatePlace" mode="tso:addition" as="element()*">
	<xsl:sequence select="InlineWords/Quote | Quote | LegAmendment |LegRef" />
</xsl:template>

<xsl:template match="ActionSubstitute[Location/@type='For']" mode="tso:addition" as="element()*">
	<xsl:sequence select="Location[@type='For']/following-sibling::Quote" />
</xsl:template>

<xsl:template match="InlineLocationAtAppropriatePlace[InlineActionInsert]" mode="tso:addition">
	<xsl:sequence select="InlineActionInsert/(Quote | LegAmendment)" />
</xsl:template>

<xsl:template match="InlineLocationFor" mode="tso:addition" as="element()">
	<xsl:sequence select="Action/following-sibling::Quote | Action/following-sibling::LegAmendment" />
</xsl:template>

<xsl:template match="*[InlineLocationSetOutIn]" mode="tso:addition" as="element(InlineLocationSetOutIn)">
	<xsl:sequence select="InlineLocationSetOutIn" />
</xsl:template>

<xsl:template match="ActionDeleteRef | ActionDeleteGroup | InlineActionDeleteSubRef | RefRepeal | InlineActionDelete | ActionDeleteSubRef | ActionDeleteSubSubRef | InlineActionDeleteEntry" mode="tso:addition" />

<xsl:template match="*" mode="tso:addition">
	<err:Error>No addition match for <xsl:value-of select="name()" /> <xsl:value-of select="@id" /></err:Error>
</xsl:template>

<xsl:function name="tso:repeal" as="element()*">
	<xsl:param name="action" as="element(Action)" />
	<xsl:apply-templates select="$action" mode="tso:repeal" />
</xsl:function>

<xsl:template match="Action" mode="tso:repeal" />

<xsl:template match="Action[@type = ('Delete', 'Substitution')]" mode="tso:repeal" as="element()*">
	<xsl:apply-templates select=".." mode="#current" />
</xsl:template>

<xsl:template match="InlineActionInsert | InlineLocationAtAppropriatePlace" mode="tso:repeal" />

<xsl:template match="InlineActionSubstitute" mode="tso:repeal" as="element()+">
	<xsl:apply-templates select=".." mode="tso:repeal" />
</xsl:template>

<!-- need to take the first quote as the second is what will be substituted  -->
<xsl:template match="ActionSubstitute[Quote]" mode="tso:repeal" as="element()+">
	<xsl:sequence select="Quote[1]" />
</xsl:template>

<xsl:template match="InlineChange" mode="tso:repeal" as="element()+">
	<xsl:apply-templates select=".." mode="tso:repeal" />
</xsl:template>


<!-- if we want repealrange to handle the substitution then take the related element which will then be applied by the repealrange mode later -->
<xsl:template match="InlineLocationForHeading" mode="tso:repeal" as="element()+">
	<xsl:sequence select="." />
</xsl:template>

<xsl:template match="HeadingChange[InlineHeading]" mode="tso:repeal" as="element()+">
	<xsl:sequence select="InlineHeading" />
</xsl:template>

<xsl:template match="InlineHeadingAction[InlineHeading/Quote]" mode="tso:repeal" as="element()+">
	<xsl:sequence select="InlineHeading/Quote" />
</xsl:template>

<xsl:template match="LocationForDefinition[Quote]" mode="tso:repeal" as="element()+">
	<xsl:sequence select="Quote" />
</xsl:template>

<xsl:template match="InRefChange | LocationForPara | InlineParaChange" mode="tso:repeal" as="element()+">
	<xsl:sequence select="LegRef" />
</xsl:template>

<xsl:template match="InlineLocationFor[Action] | InlineLocationForDefinition[Action]" mode="tso:repeal" as="element()">
	<xsl:sequence select="Action/preceding-sibling::*[1]" />
</xsl:template>

<xsl:template match="InlineLocationFor[InlineActionSubstitute] | InlineLocationForDefinition[InlineActionSubstitute]" mode="tso:repeal" as="element(Quote)+">
	<xsl:sequence select="InlineActionSubstitute/preceding-sibling::Quote" />
</xsl:template>

<xsl:template match="RefRepeal" mode="tso:repeal" as="element(LegRef)+">
	<xsl:sequence select="LegRefs/LegRef" />
</xsl:template>

<xsl:template match="InlineActionDelete[.//Quote] | InlineActionDeleteEntry[.//Quote]" mode="tso:repeal" as="element(Quote)+" priority="10">
	<xsl:sequence select=".//Quote"/>
</xsl:template>

<xsl:template match="InlineActionDelete[.//LegRef] | InlineActionDeleteEntry[.//LegRef]" mode="tso:repeal" as="element(LegRef)+"  priority="5">
	<xsl:sequence select=".//LegRef"/>
</xsl:template>


<!--
<xsl:template match="InlineActionDelete[InlineWordsAtEnd/Quote]" mode="tso:repeal" as="element(Quote)+">
	<xsl:sequence select="InlineWordsAtEnd/Quote" />
</xsl:template>

<xsl:template match="InlineActionDelete[ActionDeleteList/ActionDeleteListItem/Quote]" mode="tso:repeal" as="element(Quote)+">
	<xsl:sequence select="ActionDeleteList/ActionDeleteListItem/Quote" />
</xsl:template>

<xsl:template match="InlineActionDelete[InlineWords/Quote]" mode="tso:repeal" as="element(Quote)+">
	<xsl:sequence select="InlineWords/Quote" />
</xsl:template>

<xsl:template match="InlineActionDelete[InlineWordsFrom]" mode="tso:repeal" as="element(Quote)+">
	<xsl:sequence select="InlineWordsFrom/Quote" />
</xsl:template>

<xsl:template match="InlineActionDelete[InlineDefinition]" mode="tso:repeal" as="element(Quote)+">
	<xsl:sequence select="InlineDefinition/Quote" />
</xsl:template>
-->
<!-- This is probably a misclassification by GATE -->
<xsl:template match="InlineActionDeleteEntry[LegRef or Relation]" mode="tso:repeal">
	<xsl:sequence select="." />
</xsl:template>

<xsl:template match="InlineLocationForRelatedEntryAction[InlineLocationForRelatedEntry[LegRef or Relation]]" mode="tso:repeal">
	<xsl:sequence select="InlineLocationForRelatedEntry/*[self::LegRef or self::Relation]" />
</xsl:template>

<xsl:template match="ActionDeleteGroup | InlineActionDeleteRef | InlineActionDeleteSubRef | LocationForRef | LocationForSubRef | LocationForSubSubPara | ActionDeleteRef | ActionDeleteSubRef | ActionDeleteSubPara | ActionDeleteSubSubRef | ActionDeleteSubSubPara | ActionDeleteSubSubSubRef | ActionDeleteSubSubSubPara" mode="tso:repeal" as="element(LegRef)+">
	<xsl:sequence select="LegRef" />
</xsl:template>

<xsl:template match="LocationForSubPara[LegRef][not(Quote)]" mode="tso:repeal" as="element(LegRef)+">
	<xsl:sequence select="LegRef" />
</xsl:template>


<xsl:template match="InlineLocationForRef" mode="tso:repeal" as="element()+">
	<xsl:sequence select="(LegRefs | LegSubRefs | LegSubSubRefs  | LegParas | LegSubRefs | LegSubParas | LegSubSubParas | LegSubSubSubParas)/(LegRef|Quote)" />
</xsl:template>

<xsl:template match="InlineTableChange | InTableChange" mode="tso:repeal" as="element()+">
	<xsl:sequence select="if (Quote) then Quote else Location" />
</xsl:template>

<xsl:template match="InlineSubSubParaChange" mode="tso:repeal" as="element()+">
	<xsl:sequence select="if (Quote) then Quote else LegRef" />
</xsl:template>

<xsl:template match="InlineWordsFollowing[Quote] | InlineWordsFrom[Quote] | InlineWords[Quote] | InlineChange[Quote]" mode="tso:repeal" as="element(Quote)" priority="5">
	<xsl:sequence select="Quote" />
</xsl:template>

<xsl:template match="InlineLocationAfterWordsAction[InlineLocationAfterWords/Quote]" mode="tso:repeal" as="element(Quote)">
	<xsl:sequence select="InlineLocationAfterWords/Quote" />
</xsl:template>

<xsl:template match="InlineWordsFrom[InlineWordsTo]" mode="tso:repeal" as="element(Quote)">
	<xsl:sequence select="InlineWordsTo/Quote" />
</xsl:template>

<xsl:template match="RefHeadingChange | HeadingChange" mode="tso:repeal" as="element()">
	<xsl:sequence select="(Action/preceding-sibling::Quote, .)[1]" />
</xsl:template>

<xsl:template match="*" mode="tso:repeal">
	<err:Error>No repeal match for <xsl:value-of select="name()" /> <xsl:value-of select="@id" /></err:Error>
</xsl:template>

<xsl:function name="tso:repealRange" as="element()+">
	<xsl:param name="quote" as="element()+" />
	<xsl:param name="affectedSection" as="element()?" />
	<xsl:apply-templates select="$quote[1]" mode="tso:repealRange" >
		<xsl:with-param name="affectedSection" select="$affectedSection"/>
	</xsl:apply-templates>
</xsl:function>

<xsl:template match="InlineActionDelete | InlineLocationFor" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Match>
		<xsl:choose>
			<xsl:when test="ancestor::RefHeadingChange">
				<ukm:Heading>
					<xsl:apply-templates select="Location" mode="tso:position" />
					<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
					<xsl:apply-templates select="(Quote | Anaphor[@type = 'Words'])[1]" mode="tso:text" />
				</ukm:Heading>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Location" mode="tso:position" />
				<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
				<xsl:apply-templates select="(Quote | Anaphor[@type = 'Words'])[1]" mode="tso:text" />
			</xsl:otherwise>
		</xsl:choose>
	</ukm:Match>
</xsl:template>

<xsl:template match="InlineLocationAfterWords" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:After>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:After>
</xsl:template>

<xsl:template match="InlineWordsFrom" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:ToEnd>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:ToEnd>
</xsl:template>

<xsl:template match="InlineWordsTo" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:FromStart>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:FromStart>
</xsl:template>

<xsl:template match="InlineWordsAtEnd" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Match>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:Match>
</xsl:template>

<xsl:template match="InlineWords" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Match>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:Match>
</xsl:template>

<xsl:template match="InlineWordsFollowing" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:After>
		<ukm:Match>
			<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
			<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
		</ukm:Match>
	</ukm:After>
</xsl:template>

<xsl:template match="InlineHeading" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Match>
		<ukm:Heading>
			<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
			<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
		</ukm:Heading>
	</ukm:Match>
</xsl:template>

<xsl:template match="ActionDeleteListItem" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Match>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:Match>
</xsl:template>

<xsl:template match="ActionSubstitute" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Match>
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote[1] | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:Match>
</xsl:template>

<xsl:template match="RefHeadingChange | InlineLocationForHeading | HeadingChange" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<xsl:choose>
		<xsl:when test="Action/preceding-sibling::Quote or Action/preceding-sibling::Anaphor[@type = 'Words']">
			<ukm:Match>
				<xsl:apply-templates select="Location" mode="tso:position" />
				<ukm:Heading>
					<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
				</ukm:Heading>
				<xsl:apply-templates select="Action/preceding-sibling::Quote | Action/preceding-sibling::Anaphor[@type = 'Words']" mode="tso:text" />
			</ukm:Match>
		</xsl:when>
		<xsl:otherwise>
			<ukm:Heading>
				<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
			</ukm:Heading>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="InlineActionDeleteEntry" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Entry>
		<xsl:apply-templates select="Location" mode="tso:position" />
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="*[not(self::Action)]" mode="tso:text" />
	</ukm:Entry>
</xsl:template>

<xsl:template match="InlineLocationForRelatedEntry" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Related>
		<xsl:apply-templates select="Location" mode="tso:position" />
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Relation" mode="tso:text" />
	</ukm:Related>
</xsl:template>

<xsl:template match="InlineLocationBeforeRelatedEntry" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Related>
		<xsl:apply-templates select="Location" mode="tso:position" />
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Relation" mode="tso:text" />
	</ukm:Related>
</xsl:template>

<xsl:template match="InlineSentence" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Sentence>
		<xsl:apply-templates select="Location" mode="tso:position" />
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:Sentence>
</xsl:template>

<xsl:template match="InlineDefinition | InlineLocationForDefinition | LocationForDefinition" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<ukm:Definition>
		<xsl:apply-templates select="Location" mode="tso:position" />
		<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
		<xsl:apply-templates select="Quote | Anaphor[@type = 'Words']" mode="tso:text" />
	</ukm:Definition>
</xsl:template>

<xsl:template match="LegRef" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<xsl:apply-templates select="if (exists($affectedSection) and count($affectedSection) = 1) then $affectedSection else ." mode="tso:context" />
</xsl:template>

<xsl:template match="Quote | Anaphor[@type = 'Words'] | Relation" mode="tso:repealRange">
	<xsl:param name="affectedSection" as="element()?" />
	<xsl:apply-templates select=".." mode="tso:repealRange" >
		<xsl:with-param name="affectedSection" select="$affectedSection"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="tso:repealRange">
	<err:Error>No repealRange match for <xsl:value-of select="name()" /> <xsl:value-of select="@id" /></err:Error>
</xsl:template>

<xsl:template match="Location" mode="tso:position">
	<xsl:if test="@position">
		<xsl:attribute name="Position">
			<xsl:choose>
				<xsl:when test="@position = 'first'">1</xsl:when>
				<xsl:when test="@position = 'second'">2</xsl:when>
				<xsl:when test="@position = 'third'">3</xsl:when>
				<xsl:when test="@position = 'fourth'">4</xsl:when>
				<xsl:when test="@position = 'fifth'">5</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@position" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:function name="tso:insertionPoint" as="element()">
	<xsl:param name="action" as="element(Action)" />
	<xsl:apply-templates select="$action" mode="tso:insertionPoint" />
</xsl:function>

<xsl:template match="Action | InlineActionInsert | ActionInsert | InlineChange | InlineActionDelete | ActionDelete" mode="tso:insertionPoint" priority="1">
	<xsl:apply-templates select=".." mode="tso:insertionPoint" />
</xsl:template>



<xsl:template match="InRefChange[LegRef] | InlineParaChange[LegRef] | InParaChange[LegRef] | InSubRefChange[LegRef] | InSubParaChange[LegRef]" mode="tso:insertionPoint" priority="10">
	<ukm:In>
		<xsl:apply-templates select="LegRef" mode="tso:context" />
	</ukm:In>
</xsl:template>


<xsl:template match="TableAfterEntryChange[parent::RefAmendment]" mode="tso:insertionPoint">
	<ukm:After>
		<ukm:TableEntry>
			<xsl:apply-templates select="parent::RefAmendment/LegRef" mode="tso:context" />
		</ukm:TableEntry>
	</ukm:After>
</xsl:template>

<xsl:template match="AfterGroupChange | InlineAfterGroupChange" mode="tso:insertionPoint">
	<ukm:After>
		<ukm:Group>
			<xsl:apply-templates select="LegRef" mode="tso:context" />
		</ukm:Group>
	</ukm:After>
</xsl:template>

<xsl:template match="InlineLocationAfterWordsAction[InlineLocationAfterWords]" mode="tso:insertionPoint" priority="5">
	<ukm:After>
		<ukm:Match>
			<xsl:choose>
				<xsl:when test="ancestor::*/local-name() = ('TableEntryChange','TableAfterEntryChange')">
					<ukm:TableEntry>
						<xsl:apply-templates select="InlineLocationAfterWords" mode="tso:context" />
						<xsl:apply-templates select="InlineLocationAfterWords/Quote" mode="tso:text" />
					</ukm:TableEntry>
				</xsl:when>
				<xsl:when test="ancestor::*/local-name() = ('RefHeadingChange')">
					<ukm:Heading>
						<xsl:apply-templates select="InlineLocationAfterWords" mode="tso:context" />
						<xsl:apply-templates select="InlineLocationAfterWords/Quote" mode="tso:text" />
					</ukm:Heading>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="InlineLocationAfterWords" mode="tso:context" />
					<xsl:apply-templates select="InlineLocationAfterWords/Quote" mode="tso:text" />
				</xsl:otherwise>
			</xsl:choose>
		</ukm:Match>
	</ukm:After>
</xsl:template>

<xsl:template match="LocationAfterSubParaAction[InlineLocationAfterSubPara]" mode="tso:insertionPoint" priority="5">
	<ukm:After>
		<ukm:Match>
			<xsl:apply-templates select="InlineLocationAfterSubPara/LegRef" mode="tso:context" />
			<xsl:apply-templates select="InlineLocationAfterSubPara/Quote" mode="tso:text" />
		</ukm:Match>
	</ukm:After>
</xsl:template>

<xsl:template match="ActionInsert[Location[@type='AfterRef'][following-sibling::LegRef]]" mode="tso:insertionPoint" priority="5">
	<ukm:After>
		<ukm:Match>
			<xsl:apply-templates select="LegRef" mode="tso:context" />
		</ukm:Match>
	</ukm:After>
</xsl:template>

<!-- allow for ToC insertions  -->
<xsl:template match="InlineLocationAfterRelatedEntryAction[ancestor::TocChange][InlineLocationAfterRelatedEntry]" mode="tso:insertionPoint" priority="5">
	<ukm:After>
		<ukm:Match>
			<xsl:variable name="legislationURI" as="xs:string">
				<xsl:variable name="legislation" as="element(Legislation)?">
					<xsl:apply-templates select="." mode="tso:legislation" />
				</xsl:variable>
				<xsl:sequence select="$legislation/@context" />
			</xsl:variable>
			<ukm:Section Ref="/contents" URI="{$legislationURI}/contents">
				<xsl:value-of select="'contents'" />
			</ukm:Section>
			<xsl:apply-templates select="InlineLocationAfterRelatedEntry/Relation" mode="tso:text" />
		</ukm:Match>
	</ukm:After>
</xsl:template>

<xsl:template match="InlineLocationForRelatedEntryAction[InlineLocationForRelatedEntry]" mode="tso:insertionPoint" priority="1">
	<ukm:Match>
		<xsl:apply-templates select="." mode="tso:context" />
		<xsl:apply-templates select="InlineLocationForRelatedEntry/Relation" mode="tso:text" />
	</ukm:Match>
</xsl:template>

<xsl:template match="InlineLocationFor" mode="tso:insertionPoint" priority="1">
	<ukm:Match>
		<xsl:apply-templates select="." mode="tso:context" />
		<xsl:apply-templates select="Quote[1]" mode="tso:text" />
	</ukm:Match>
</xsl:template>

<xsl:template match="*[matches(local-name(.), '^InlineLocation(After|AtEnd).*Action$')]" mode="tso:insertionPoint">
	<xsl:variable name="locationElement" as="xs:string" select="replace(local-name(.), 'Action$', '')" />
	<ukm:After>
		<xsl:apply-templates select="*[local-name(.) = $locationElement]" mode="tso:context" />
		<xsl:apply-templates select="*[local-name(.) = $locationElement]/*" mode="tso:text" />
	</ukm:After>
</xsl:template>

<xsl:template match="*[matches(local-name(.), '^InlineLocation(Before|AtBeginning).*Action$')]" mode="tso:insertionPoint">
	<xsl:variable name="locationElement" as="xs:string" select="replace(local-name(.), 'Action$', '')" />
	<ukm:Before>
		<xsl:apply-templates select="*[local-name(.) = $locationElement]/LegRef" mode="tso:context" />
		<xsl:apply-templates select="*[local-name(.) = $locationElement]/*" mode="tso:text" />
	</ukm:Before>
</xsl:template>

<xsl:template match="InlineLocationBeforeWordsAction[InlineLocationBeforeWords/Quote]" mode="tso:insertionPoint" priority="5">
	<ukm:Before>
		<ukm:Match>
			<xsl:apply-templates select="InlineLocationBeforeWords" mode="tso:context" />
			<xsl:apply-templates select="InlineLocationBeforeWords/Quote" mode="tso:text" />
		</ukm:Match>
	</ukm:Before>
</xsl:template>

<xsl:template match="LocationBeforeRelatedEntryAction/InlineLocationBeforeRelatedEntryAction[InlineLocationBeforeRelatedEntry]" mode="tso:insertionPoint" priority="5">
	<ukm:Before>
		<ukm:Match>
			<xsl:apply-templates select="InlineLocationBeforeRelatedEntry" mode="tso:context" />
			<xsl:apply-templates select="InlineLocationBeforeRelatedEntry/*" mode="tso:text" />
		</ukm:Match>
	</ukm:Before>
</xsl:template>

<xsl:template match="InlineLocationAtBeginning" mode="tso:insertionPoint">
	<ukm:Before>
		<xsl:apply-templates select="." mode="tso:context" />
	</ukm:Before>
</xsl:template>

<xsl:template match="InlineLocationAfterSubSubPara" mode="tso:insertionPoint">
	<ukm:After>
		<xsl:apply-templates select="." mode="tso:context" />
	</ukm:After>
</xsl:template>

<xsl:template match="InlineLocationAtEndNoRef | InlineAtEndOfHeading" mode="tso:insertionPoint">
	<ukm:AtEnd>
		<ukm:Heading>
			<xsl:apply-templates select="." mode="tso:context" />
		</ukm:Heading>
	</ukm:AtEnd>
</xsl:template>

<xsl:template match="InlineActionDelete[InlineActionInsert][InlineLocationAfterSubSubPara]" mode="tso:insertionPoint">
	<ukm:After>
		<xsl:apply-templates select="InlineLocationAfterSubSubPara" mode="tso:context" />
	</ukm:After>
</xsl:template>

<xsl:template match="InlineAfterDefinition | InlineAtEndOfDefinition" mode="tso:insertionPoint">
	<ukm:After>
		<ukm:Definition>
			<xsl:apply-templates select="." mode="tso:context" />
			<xsl:apply-templates select="Quote" mode="tso:text" />
		</ukm:Definition>
	</ukm:After>
</xsl:template>

<xsl:template match="InlineBeforeDefinition" mode="tso:insertionPoint">
	<ukm:Before>
		<ukm:Definition>
			<xsl:apply-templates select="." mode="tso:context" />
			<xsl:apply-templates select="Quote" mode="tso:text" />
		</ukm:Definition>
	</ukm:Before>
</xsl:template>

<xsl:template match="InlineAfterEntry" mode="tso:insertionPoint">
	<ukm:After>
		<ukm:Entry>
			<xsl:apply-templates select="." mode="tso:context" />
			<xsl:apply-templates select="Quote" mode="tso:text" />
		</ukm:Entry>
	</ukm:After>
</xsl:template>

<xsl:template match="InlineLocationAtAppropriatePlace" mode="tso:insertionPoint">
	<ukm:AppropriatePlaceIn>
		<xsl:apply-templates select="." mode="tso:context" />
	</ukm:AppropriatePlaceIn>
</xsl:template>

<xsl:template match="InlineAnaphorRef" mode="tso:insertionPoint">
	<xsl:variable name="context" as="element(LegRef)" select="tso:section(preceding::Action[1])" />
	<xsl:element name="ukm:{if (Anaphor/@subType = 'Following') then 'After' else 'Before'}">
		<xsl:choose>
			<xsl:when test="../..[self::Changes]">
				<xsl:apply-templates select="../preceding-sibling::*[1]" mode="tso:context" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="../.." mode="tso:context" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>

<xsl:template match="*" mode="tso:insertionPoint">
	<err:Error>No insertionPoint match for <xsl:value-of select="name()" /> <xsl:value-of select="@id" /></err:Error>
</xsl:template>

<xsl:template match="LegRef[not(ancestor::*/local-name() = ('TableEntryChange','TableAfterEntryChange'))]" mode="tso:context">
	<xsl:choose>
		<xsl:when test="contains(@uri, ',')">
			<ukm:SectionGroup>
				<xsl:apply-templates select="." mode="tso:sections" />
			</ukm:SectionGroup>
		</xsl:when>
		<xsl:when test="contains(parent::*/local-name(),'Heading')">
			<ukm:Heading>
				<xsl:apply-templates select="." mode="tso:sections" />
			</ukm:Heading>
		</xsl:when>
		<xsl:when test="./parent::InlineActionSubstitute/Action[@type='Substitution']">
			<xsl:variable name="parent" select="tso:parentRef(.)"/>
			<xsl:apply-templates select="$parent" mode="tso:sections" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="tso:sections" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[LegRef[not(ancestor::*/local-name() = ('TableEntryChange','TableAfterEntryChange'))]]" mode="tso:context" priority="5">
	<xsl:choose>
		<xsl:when test="contains(@uri, ',')">
			<ukm:SectionGroup>
				<xsl:apply-templates select="LegRef" mode="tso:sections" />
			</ukm:SectionGroup>
		</xsl:when>
		<xsl:when test="contains(parent::*/local-name(),'Heading')">
			<ukm:Heading>
				<xsl:apply-templates select="LegRef" mode="tso:sections" />
			</ukm:Heading>
		</xsl:when>
		<xsl:when test="../InlineActionSubstitute/Action[@type='Substitution']">
			<xsl:variable name="parent" select="tso:parentRef(LegRef)"/>
			<xsl:apply-templates select="$parent" mode="tso:sections" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="LegRef" mode="tso:sections" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[.//Action[not(ancestor::TableEntryChange)]]" mode="tso:context">
	<xsl:variable name="section" as="element(LegRef)+" select="tso:section(descendant::Action[1])" />
	<xsl:apply-templates select="$section" mode="tso:context" />
</xsl:template>

<xsl:template match="*" mode="tso:context">
	<xsl:apply-templates select=".." mode="tso:context" />
</xsl:template>

<xsl:template match="RRitem" mode="tso:context">
	<xsl:variable name="section" as="element(LegRef)+" select="tso:section(descendant::LegRef[1])" />
	<xsl:apply-templates select="$section" mode="tso:context" />
</xsl:template>


<xsl:template match="Quote" mode="tso:text">
	<ukm:Text>
		<xsl:attribute name="Ref">
			<xsl:apply-templates select="." mode="Ref" />
		</xsl:attribute>
		<xsl:value-of select="replace(., '(^“)|(”$)', '')" />
	</ukm:Text>
</xsl:template>

<xsl:template match="Anaphor[@type = 'Words']" mode="tso:text">
	<xsl:apply-templates select="preceding::Action[1]/preceding-sibling::*[1]" mode="tso:text" />
</xsl:template>

<xsl:template match="*" mode="tso:text">
	<ukm:Text>
		<xsl:value-of select="." />
	</ukm:Text>
</xsl:template>

<xsl:template match="Relation" mode="tso:text">
	<ukm:Related>
		<xsl:value-of select="." />
	</ukm:Related>
</xsl:template>

<xsl:template match="*/Relation" mode="tso:related">
	<ukm:Related>
		<xsl:value-of select="." />
	</ukm:Related>
</xsl:template>

<xsl:template match="InlineLocationForRelatedEntryAction[InlineLocationForRelatedEntry/Relation]" mode="tso:related">
	<ukm:Related>
		<xsl:value-of select="InlineLocationForRelatedEntry/Relation" />
	</ukm:Related>
</xsl:template>

<xsl:template match="*" mode="tso:related">
	<xsl:apply-templates select=".." mode="tso:related" />
</xsl:template>

<xsl:template match="Location | LegConjunction" mode="tso:text"/>

<xsl:template match="LegRef" mode="tso:qualification">
	<xsl:apply-templates select=".." mode="tso:qualification" />
</xsl:template>

<xsl:template match="*[CommencementTail/Location]" mode="tso:qualification">
	<xsl:sequence select="CommencementTail/Location[1]" />
</xsl:template>

<xsl:template match="*" mode="tso:qualification">
</xsl:template>



<xsl:function name="tso:GetAmendment" as="element()?">
	<xsl:param name="action" as="element()" />
	<xsl:choose>
		<xsl:when test="$action instance of element(InlineLocationSetOutIn) or $action instance of element(InlineLocationIn)">
			<xsl:variable name="uri" as="xs:string" select="tso:sectionUri($action/LegRef[1])" />
			<xsl:variable name="ref" as="xs:string" select="tso:calcSectionUriAsId($uri)" />
			<xsl:variable name="location" as="element()?" select="$action/root()//leg:*[@id = $ref]" />
			<xsl:choose>
				<xsl:when test="empty($location)">
					<err:Error>No element with id <xsl:value-of select="$ref"/> found</err:Error>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="amendment" as="element(leg:BlockAmendment)*" select="$location//leg:BlockAmendment[not(ancestor::leg:BlockAmendment)]" />
					<xsl:choose>
						<xsl:when test="empty($amendment)">
							<err:Error>Couldn't find block amendment in <xsl:value-of select="$ref" /></err:Error>
						</xsl:when>
						<xsl:when test="count($amendment) > 1">
							<err:Error>More than one block amendment in <xsl:value-of select="$ref" /></err:Error>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$amendment" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$action/../InlineLocationSetOutIn">
			<xsl:sequence select="tso:GetAmendment($action/../InlineLocationSetOutIn)" />
		</xsl:when>
		<xsl:when test="$action/../InlineLocationIn">
			<xsl:sequence select="tso:GetAmendment($action/../InlineLocationIn)" />
		</xsl:when>
		<xsl:when test="$action/../LegRef and not($action/../LegAmendment) and not(key('markup', $action/@id, $action/root())/parent::leg:Text/following-sibling::leg:BlockAmendment)">
			<err:Error>No block amendment for a LegRef in <xsl:value-of select="$action/@id" /></err:Error>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="action" as="element(gate:Action)" select="key('markup', $action/@id, $action/root())" />
			<xsl:sequence select="$action/following::leg:BlockAmendment[1]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<!--  FIND THE START DATE FOR COMMENCING LEGISLATION  -->
<xsl:function name="tso:startDate" as="element()?">
	<xsl:param name="section" as="element()" />
	<xsl:variable name="startDate" as="element()*">
		<xsl:apply-templates select="$section" mode="tso:startDate" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="empty($startDate) and $section/ancestor::Changes[@parserName='LD Commencement Finder']">
			<xsl:variable name="sourceRef" select="$section/@sourceRef"/>
			<xsl:variable name="sourceSection" select="($section/ancestor::Changes/preceding-sibling::Changes[@parserName='Commencement Finder']//InlineLocationSetOutIn/LegRef[concat($legUri,@uri) = $sourceRef])[1]"  as="element()?" />
			<xsl:variable name="startDate" as="element()*">
				<xsl:apply-templates select="$sourceSection" mode="tso:startDate" />
			</xsl:variable>
			<xsl:sequence select="$startDate[1]" />
		</xsl:when>
		<xsl:when test="empty($startDate)">
			<err:Error>Couldn't find Date for Section <xsl:value-of select="$section/@id" /></err:Error>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$startDate[1]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="*" mode="tso:startDate">
	<xsl:apply-templates select=".." mode="tso:startDate" />
</xsl:template>

<xsl:template match="*[ReverseComesIntoForce/Date]" mode="tso:startDate">
	<xsl:sequence select="ReverseComesIntoForce/Date" />
</xsl:template>

<xsl:template match="*[ComesIntoForce/Date]" mode="tso:startDate">
	<xsl:sequence select="ComesIntoForce/Date" />
</xsl:template>

<xsl:template match="Changes" mode="tso:startDate" as="element(Date)?">
	
</xsl:template>

<xsl:template match="*[Date]" mode="tso:startDate" as="element(Date)">
	<xsl:sequence select="Date[1]" />
</xsl:template>

<xsl:function name="tso:dateFromString" as="xs:date?">
	<xsl:param name="year" as="xs:string"/>
	<xsl:param name="month" as="xs:string"/>
	<xsl:param name="day" as="xs:string"/>
	<xsl:variable name="date" select="concat($year,'-',$month,'-',$day)"/>
	<xsl:value-of select="if ($date castable as xs:date) then xs:date($date) else ()"/>
</xsl:function>


<!-- this is to determine whether a quote should be refered to as a word or words -->
<xsl:function name="tso:NormalizeQuote" as="xs:string">
	<xsl:param name="string" as="xs:string" />
	<xsl:variable name="string" select="translate($string,'&#8220;&#8221;','')"/>
	<xsl:value-of select="normalize-space($string)"/>
</xsl:function>

<!-- this will correct uris for the correct provision names -->
<xsl:function name="tso:correctProvisionUri" as="xs:string">
	<xsl:param name="uri" as="xs:string" />
	<xsl:choose>
		<xsl:when test="matches($uri,'schedule')">
			<xsl:value-of select="replace($uri,'rule','paragraph')"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="replace($uri,'rule','article')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>



<xsl:function name="tso:GetAmendmentSections" as="xs:string*">
	<xsl:param name="action" as="element(Action)" />
	<xsl:param name="affectedSection" as="element()?" />
	<xsl:choose>
		<xsl:when test="$action/@type = 'ComingIntoForce'" />
		<!--<xsl:when test="$action[@type = ('Insert', 'Substitution')]/following-sibling::*[1][self::LegRef]">
			<xsl:variable name="sectionURI" as="xs:string" select="tso:sectionUri($action/following-sibling::*[1])" />
			<xsl:sequence select="$sectionURI" />
		</xsl:when>
		<xsl:when test="exists($affectedSection/@uri) and exists($affectedSection/@minorType) and not($affectedSection/preceding-sibling::Location/@type='AfterRef')">
			<xsl:variable name="location" as="element(LegRef)" select="tso:section($action)" />
			<xsl:variable name="parentRef" as="element()" 
					select="if ($action/parent::InlineActionInsert/parent::InlineLocationAtEndNoRef) then $location else tso:parentRef($location)" />
			<xsl:sequence select="tso:sectionUri($affectedSection/@uri, $affectedSection/@minorType, $parentRef)" />
		</xsl:when>-->
		<!-- If we cannot get the uri and minortype from the legref then we need to try to get it from the markup  -->
		<xsl:otherwise>
			<xsl:variable name="amendment" as="element()?" select="tso:GetAmendment($action)" />
			<xsl:if test="exists($amendment) and $amendment[self::err:Error]"><xsl:message><xsl:value-of select="$amendment"/></xsl:message></xsl:if>
			<xsl:if test="exists($amendment) and $amendment[not(self::err:Error)]">
				<xsl:variable name="location" as="element(LegRef)+" select="tso:section($action)" />
				
				<!-- In certain rare instances we can have more than one LegRef which will need concatenating - see uksi/2008/912 - with schedule 1 Part 1  - This needs more work doing to it-->
				<xsl:variable name="locationUri" as="xs:string" select="string-join(for $item in $location return $item/@uri,'')" />
				
				<xsl:variable name="parentRef" as="element()" 
					select="if ($action/parent::InlineActionInsert/parent::*[local-name() = ('InlineLocationAtEndNoRef','InlineLocationAfterWordsAction')] or $action/parent::ActionInsert) then $location[1] else tso:parentRef($location[1])" />
					
				<xsl:variable name="amendment" as="element()" select="if ($amendment/gate:LegAmendment) then $amendment/gate:LegAmendment else $amendment" />
				<!--<xsl:message>||<xsl:value-of select="$amendment/*/local-name()"/></xsl:message>-->
				<xsl:for-each select="$amendment/*[self::leg:Group or self::leg:Part or self::leg:Chapter or (:self::leg:P1group or :) self::leg:P1 or self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6 or self::leg:P7 or self::leg:Schedule] | $amendment/(leg:Pblock | leg:PsubBlock | leg:P1group)/(leg:P1group | leg:P1)">
					<xsl:variable name="minorType" as="xs:string">
						<xsl:choose>
							<xsl:when test="self::leg:P1group or self::leg:P1">
								<xsl:choose>
									<!-- fringe case when a block amendment identifies a provision of the type 16(1) as in the case of uksi/2011/2364 -->
									<xsl:when test="leg:Pnumber[not(../leg:Title)][../leg:P1para[count(leg:P2) = 1]/leg:P2/leg:Pnumber] and exists($parentRef/@minorType)">
										<xsl:sequence select="$parentRef/@minorType" />
									</xsl:when>
									<xsl:when test="$location[last()]/@minorType = ('section', 'regulation', 'article', 'paragraph', 'rule')">
										<xsl:sequence select="$location[last()]/@minorType" />
									</xsl:when>
									<xsl:when test="$parentRef/@minorType = 'schedule'">paragraph</xsl:when>
									<xsl:otherwise>section</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$location/parent::InlineLocationAfterRef and $action[@type = ('Insert', 'Substitution')]/following-sibling::*[1][self::LegAmendment] and (self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6 or self::leg:P7)">
								<xsl:choose>
									<xsl:when test="$location[last()]/@minorType = ('section', 'regulation', 'article', 'paragraph', 'rule')">
										<xsl:sequence select="$location[last()]/@minorType" />
									</xsl:when>
									<xsl:when test="$parentRef/@minorType = 'schedule'">paragraph</xsl:when>
									<xsl:otherwise>section</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6 or self::leg:P7">paragraph</xsl:when>
							<xsl:when test="self::leg:Pblock">crossheading</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="lower-case(local-name(.))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="sectionRef" as="xs:string?">
						<xsl:choose>
							<xsl:when test="leg:Number">
								<xsl:variable name="number" as="xs:string" select="normalize-space(leg:Number)" />
								<xsl:variable name="number" as="xs:string" select="replace($number, concat('^', $minorType, '\s*'), '', 'i')" />
								<xsl:value-of select="concat('/', $minorType, '/', $number)" />
							</xsl:when>
							<!-- when we insert a whole ssub-section after an existing sub-section then we need to take the parent from the legref that is being ignored  and ignore the last token of the uri--> 
							
							<xsl:when test="((position() &gt; 1 and count($location) = 1 and not(contains($location/@uri,'RANGE')) and not(contains($location/@uri,','))) or ($location/parent::InlineLocationAfterRef or $location/preceding-sibling::Location[@type='AfterRef'])) and $action[@type = ('Insert', 'Substitution')]/following-sibling::*[1][self::LegAmendment] and (self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6 or self::leg:P7)">
								<xsl:variable name="tokens" select="tokenize($location/@uri,'/')"/>
								<xsl:variable name="updatedUri">
									<xsl:for-each select="$tokens">
										<xsl:choose>
											<xsl:when test="position() = last()"></xsl:when>
											<xsl:otherwise>
												<xsl:if test="position() != 1"></xsl:if>
												<xsl:value-of select="."/>
												<xsl:text>/</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:variable>
								<xsl:value-of select="concat($updatedUri,self::*/leg:Pnumber)" />
							</xsl:when>
							<!-- fringe case when a block amendment identifies a provision of the type 16(1) as in the case of uksi/2011/2364 -->
							<xsl:when test="leg:Pnumber[not(../leg:Title)][..[count(leg:P1para) = 1]/leg:P1para[count(leg:P2) = 1]/leg:P2/leg:Pnumber]">
								<xsl:value-of select="concat('/', leg:Pnumber,'/',(leg:Pnumber/../leg:P1para/leg:P2/leg:Pnumber))" />
							</xsl:when>
							<xsl:when test="leg:Pnumber">
								<xsl:value-of select="concat('/', leg:Pnumber)" />
							</xsl:when>
							<xsl:when test="leg:P1/leg:Pnumber">
								<xsl:value-of select="concat('/', leg:P1[1]/leg:Pnumber)" />
							</xsl:when>
							<xsl:when test="leg:Title">
								<xsl:value-of select="concat('/', $minorType, '/', replace(replace(lower-case(leg:Title), '[^a-z0-9\s]', ''), '\s+', '-'))" />
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
									
					<!-- Make sure we have the correct parent - test the minor type against that of the legamendment -->
					<xsl:variable name="parentRef" as="element()" select="if ($minorType = ('section', 'sections', 'regulation', 'article', 'articles', 'schedule','contents') and $parentRef/@minorType = ('section', 'sections', 'regulation', 'article', 'articles','schedule','contents')) then tso:parentRef($parentRef) else $parentRef" />
					
					<!--<xsl:message>||<xsl:value-of select="$action/@id"/>||<xsl:value-of select="$sectionRef"/>||<xsl:value-of select="$minorType"/>||<xsl:value-of select="$parentRef"/>||<xsl:value-of select="./local-name()"/></xsl:message> -->
					
					<xsl:choose>
						<xsl:when test="empty($sectionRef)">ERRORamendmentSections<xsl:apply-templates select="$amendment" mode="Ref" /></xsl:when>
						<!-- if the subsitutued copy is the same section as the reference then we shall use the reference in case there are parent paras to take into account -->
						<!-- an exception to this case is when we have a range (indicated by a comma) in which case we can assume that the section ref will be the same - this was highlighted in uksi/2011/2200-->
						<xsl:when test="count($location) > 1 and count($amendment/*) = 1 and $action[@type = 'Substitution'] and ends-with($locationUri,$sectionRef) and not(contains($locationUri,','))">
							<xsl:for-each select="$location">
								<xsl:sequence select="tso:sectionUri(.)" />
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="count($amendment/*) = 1 and $action[@type = 'Substitution'] and ends-with($locationUri,$sectionRef) and not(contains($locationUri,','))">
							<xsl:sequence select="tso:sectionUri($location)" />
						</xsl:when>
						<xsl:when test="$action[@type = ('Insert', 'Substitution')] and ends-with($locationUri,$sectionRef) and not(contains($locationUri,',')) and not(contains($locationUri,'RANGE'))">
							<xsl:sequence select="tso:sectionUri($locationUri, $minorType, $parentRef)" />
						</xsl:when>
						<!-- catch where one provision substitutes multiple provisions  otherwise we will not get the main para number -->
						<xsl:when test="$action[@type = ('Insert', 'Substitution')] and ends-with(substring-before($locationUri,','),$sectionRef) and contains($locationUri,',')">
							<xsl:sequence select="tso:sectionUri(substring-before($locationUri,','), $minorType, $parentRef)" />
						</xsl:when>
						<xsl:otherwise>	
							<xsl:sequence select="tso:sectionUri($sectionRef, $minorType, $parentRef)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>




</xsl:stylesheet>
