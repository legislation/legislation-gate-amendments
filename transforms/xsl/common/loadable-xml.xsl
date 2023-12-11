<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:l="http://www.tso.co.uk/assets/namespace/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:m="http://www.w3.org/1998/Math/MathML"
	exclude-result-prefixes="xs leg ukm err tso xhtml l dc dct"
	version="2.0">
	
<xsl:import href="utils.xsl"/>

<xsl:param name="date" as="xs:string?" select="if (doc-available('input:date')) then doc('input:date') else ()" />
<xsl:param name="latestConcurrentVersionNumber" as="xs:integer?" select="if (doc-available('input:latestConcurrentVersionNumber')) then xs:integer(doc('input:latestConcurrentVersionNumber')) else ()" />

<xsl:variable name="strDocumentMainType" select="/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />

<xsl:variable name="strDocumentMinorTypeValue" select="/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMinorType/@Value"  />

<!-- Allowance for historic items where rules were identified as 'articles' This makes allowance for the updated augment to correctly cast the identifier for the legislation item that is being edited -->
<xsl:variable name="strDocumentMinorType" select="if (($strDocumentMinorTypeValue = 'rule') and (some $item in //leg:P1/@id satisfies matches($item, '^article-'))) then 'order' else $strDocumentMinorTypeValue"  />

<xsl:variable name="baseDate" as="xs:string" select="string(leg:base-date($strDocumentMainType))"/>

<xsl:variable name="nodeset" select="/"/>
<xsl:variable name="versions" select="$nodeset//leg:Versions"/>

<xsl:output indent="no" />

<xsl:key name="identified" match="*[@id]" use="@id" />



<xsl:template match="/" mode="loadable">
	<xsl:variable name="strIdentifier" select="*/ukm:Metadata/dc:identifier[starts-with(., 'http://www.legislation.gov.uk')][1]" />
	<xsl:variable name="submittedData" select="//(leg:Primary | leg:Secondary | leg:EURetained)" />
	<xsl:variable name="changesResolved">
		<xsl:apply-templates>
			<xsl:with-param name="strIdentifier" tunnel="yes" select="$strIdentifier" />
			<xsl:with-param name="strDocumentMainType" select="$strDocumentMainType" tunnel="yes" />
			<xsl:with-param name="strDocumentMinorType" select="$strDocumentMinorType" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:variable>
	<!-- clean the generated IDs -->
	<xsl:variable name="cleanIds">
		<xsl:apply-templates select="$changesResolved" mode="CleanIDs"/>
	</xsl:variable>
	<!-- de-duplicated any matching IDs -->
	<xsl:variable name="deduplicatedIds">
		<xsl:apply-templates select="$cleanIds" mode="DeduplicateIDs" />
	</xsl:variable>
	<xsl:variable name="ChangeCitationIDs">	
		<xsl:apply-templates select="$cleanIds" mode="ChangeCitationIDs">
			<xsl:with-param name="strIdentifier" tunnel="yes" select="$strIdentifier" />
			<xsl:with-param name="submittedData" tunnel="yes" select="$submittedData" />
		</xsl:apply-templates>
	</xsl:variable>
	
	<!-- re-link any Citations and their CitationSubRefs that are broken post de-duping -->
	<xsl:apply-templates select="$ChangeCitationIDs" mode="Re-LinkCitations"/>
	
</xsl:template>
	

<xsl:template match="@*|node()" mode="CleanIDs">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="CleanIDs"/>
	</xsl:copy>
</xsl:template>
	
<!-- remove any unwanted content from generated IDs -->
<xsl:template match="@id" mode="CleanIDs">
	<xsl:attribute name="id">
		<xsl:value-of select="replace(., 'repealed$', '')"></xsl:value-of>
	</xsl:attribute>
</xsl:template>
	

	
<!-- check if supplied ID is a duplicate ending in 'n1', 'n2' etc. to differentiate from original -->
<xsl:function name="tso:matchDuplicateID" as="xs:boolean">
	<xsl:param name="ID" as="xs:string?"/>
	<xsl:sequence select="matches($ID, '-?n\d+$')"/>
</xsl:function>
	
<!-- amend supplied ID so that if a duplicate with 'n1', 'n2' etc. suffix then this is removed -->
<xsl:function name="tso:replaceDuplicateID" as="xs:string">
	<xsl:param name="ID" as="xs:string?"/>
	<xsl:sequence select="replace($ID, '-?n\d+$', '')"/>
</xsl:function>

<xsl:key name="changes" match="leg:Addition[@Mark = 'Start'] | leg:Repeal[@Mark = 'Start'] | leg:Substitution[@Mark = 'Start']" use="leg:containedText(.)/generate-id(.)" />

<!-- Turn Addition/Repeal milestones into wrapper elements around text nodes -->

<xsl:template match="leg:CommentaryRef[preceding-sibling::*[1][self::leg:Repeal[@Mark = 'Start'][@RetainText='false']]]" >
	<!-- this removes repealed commentary refs that are immediate siblings to the repeal otherwise they will be placed outside of the rpealed text  -->
</xsl:template>

<xsl:template match="leg:Addition[@Mark] | leg:Repeal[@Mark] | leg:Substitution[@Mark]" />

	<xsl:template match="text()[normalize-space(.) != '' and not(ancestor::math:*)]" priority="5">
		<xsl:variable name="text" as="text()" select="." />
		<xsl:variable name="openChanges" as="element()*" select="key('changes', generate-id($text))" />
		<xsl:call-template name="wrapChanges">
			<xsl:with-param name="node" select="$text" />
			<xsl:with-param name="changes" select="$openChanges" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="math:math" priority="5">
		<xsl:variable name="math" as="element()">			
			<xsl:copy>
				<xsl:copy-of select="@*" />
				<xsl:apply-templates select="*[not(self::leg:Addition|self::leg:Repeal|self::leg:Substitution)]"/>
			</xsl:copy>
		</xsl:variable>
		<xsl:variable name="isChanges" as="text()*" select="descendant::*[./text()[normalize-space(.) != '']][1]/text()"/>
		<xsl:variable name="openChanges" as="element()*" select="key('changes', generate-id($isChanges[1]))" />
		<xsl:call-template name="wrapChanges">
			<xsl:with-param name="node" select="$math" />
			<xsl:with-param name="changes" select="$openChanges" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="wrapChanges">
		<xsl:param name="node" as="node()" required="yes" />
		<xsl:param name="changes" as="element()*" required="yes" />
		<xsl:param name="markup" as="xs:boolean" select="false()" tunnel="yes" />
		<xsl:choose>
			<xsl:when test="$changes">
				<xsl:element name="{name($changes[1])}" namespace="{namespace-uri($changes[1])}">
					<xsl:sequence select="$changes[1]/(@* except (@Mark, @overflow, @display))" />
					<xsl:call-template name="wrapChanges">
						<xsl:with-param name="node" select="$node" />
						<xsl:with-param name="changes" select="subsequence($changes, 2)" />
					</xsl:call-template>
				</xsl:element>
			</xsl:when>
			<!--
		<xsl:when test="$markup">
			<xsl:call-template name="wrap">
				<xsl:with-param name="node" select="$text" />
			</xsl:call-template>
		</xsl:when>
		-->
			<xsl:otherwise>
				<xsl:sequence select="$node"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<xsl:function name="leg:containedText" as="text()*">
	<xsl:param name="change" as="element()" />
	<xsl:variable name="id" as="xs:string" select="$change/@ChangeId" />
	<xsl:variable name="changeType" as="xs:QName" select="node-name($change)" />
	<xsl:apply-templates select="$change/following::node()[self::text() or self::*[node-name(.) = $changeType]][1]" mode="leg:containedText">
		<xsl:with-param name="id" select="$id" tunnel="yes" />
		<xsl:with-param name="changeType" select="$changeType" tunnel="yes" />
	</xsl:apply-templates>
</xsl:function>

<xsl:template match="text()" mode="leg:containedText" priority="10">
	<xsl:sequence select="." />
	<xsl:next-match />
</xsl:template>

<xsl:template match="math:math" mode="leg:containedText" priority="20">
	<xsl:sequence select="." />
	<xsl:next-match />
</xsl:template>
	
<xsl:template match="leg:Commentaries//text()" mode="leg:containedText" priority="15">
	
</xsl:template>

<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution" mode="leg:containedText">
	<xsl:param name="changeType" as="xs:QName" tunnel="yes" required="yes" />
	<xsl:param name="id" as="xs:string" tunnel="yes" required="yes" />
	<xsl:if test="@Mark != 'End' or $changeType != node-name(.) or $id != @ChangeId">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="node()" mode="leg:containedText">
	<xsl:param name="changeType" as="xs:QName" required="yes" tunnel="yes" />
	<xsl:apply-templates select="following::node()[self::text() or self::*[node-name(.) = $changeType]][1]" mode="leg:containedText" />
</xsl:template>

<!-- strip unwanted whitespace -->

<xsl:template match="text()[normalize-space(.) = '']">
	<xsl:if test="../text()[normalize-space(.) != '']">
		<xsl:value-of select="." />
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Term/@id" priority="10">
	<xsl:sequence select="." />
</xsl:template>

<!-- Refresh IdURI attributes -->

<!--
<xsl:template match="@id[not(matches(., '[a-z][0-9]{5}'))]">
	<xsl:param name="strIdentifier" tunnel="yes" required="yes" />
	<xsl:sequence select="." />
	<xsl:attribute name="IdURI">
		<xsl:value-of select="$strIdentifier" />
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="starts-with(., 'crossheading-')">
				<xsl:value-of select="concat('crossheading/', substring-after(., 'crossheading-'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="replace(., '-', '/')" />
			</xsl:otherwise>
		</xsl:choose>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>
-->

<xsl:template match="@IdURI" />

<xsl:template match="leg:Primary/*[descendant-or-self::*/@RestrictStartDate = $date] | leg:Secondary/*[descendant-or-self::*/@RestrictStartDate = $date] | leg:EURetained/*[descendant-or-self::*/@RestrictStartDate = $date]">
	<xsl:copy>
		<xsl:choose>
			<xsl:when test="@Status = 'Prospective'">
				<xsl:sequence select="@* except (@Status, @Match)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="@*" />
			</xsl:otherwise>
		</xsl:choose>
		<!-- Currently only adjust top level, as we're only worried about sections, but later we will want to pick out 
			   what's adjusted to the new date more exactly -->
		<xsl:choose>
			<!-- for in force amendments on prospective sections we need to record the date in order to implement the prospective versioning  -->
			<!--<xsl:when test="exists($date) and @Status = 'Prospective'">
				<xsl:attribute name="ProspStartDate" select="$date" />
			</xsl:when>-->
			<xsl:when test="exists($date) and $date castable as xs:date">
				<xsl:attribute name="RestrictStartDate" select="$date" />
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="." mode="content" />
	</xsl:copy>
</xsl:template>

<xsl:template match="leg:Schedules | leg:Group | leg:Part | leg:Chapter | leg:Schedule | leg:Appendix | leg:Pblock | leg:PsubBlock | leg:EUPart | leg:EUTitle | leg:EUChapter | leg:EUSection | leg:EUSubsection | leg:Division |
	leg:P1[not(ancestor::leg:BlockAmendment)] | leg:P2[not(ancestor::leg:BlockAmendment)] | leg:P3[not(ancestor::leg:BlockAmendment)] | leg:P4[not(ancestor::leg:BlockAmendment)] | leg:P5[not(ancestor::leg:BlockAmendment)] | leg:P6[not(ancestor::leg:BlockAmendment)] | leg:Body[not(ancestor::leg:BlockAmendment)]/leg:P | leg:EUBody[not(ancestor::leg:BlockAmendment)]/leg:P |
	leg:NumberedPara | leg:P[@FragmentId] | leg:BlockText[@FragmentId] | leg:P1group[@FragmentId and not(leg:P1)]" mode="content">
	<xsl:param name="blnSubstituted" as="xs:boolean" tunnel="yes"
		select="every $t in .//text()[not(normalize-space(.) = '')] satisfies key('changes', generate-id($t))[self::leg:Repeal[@SubstitutionRef]]" />
	
	<!-- we need to reference any changes throughout the heirarchy as the high level amends queries will not do this-->
	<!-- for high level amends we also need to filter the RestrictStartDate down to the descendant provisions -->
	<xsl:variable name="addStartDate" as="xs:boolean" select="exists($date) and $date castable as xs:date and 
					(
						(
							(self::leg:Schedules or self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:EUTitle or self::leg:EUPart  or self::leg:EUChapter or self::leg:EUSection or self::leg:EUSubsection or self::leg:Division or self::leg:Schedule or self::leg:Appendix or self::leg:Attachments or self::leg:Pblock or self::leg:PsubBlock) 
								and descendant::*[@RestrictStartDate = $date]
						) 
						(:	need to make allowance for high level prosp insertions ie 2012 c.10 plus normal insertions such as 2010 asp 2 :)
							or
						(	
							(self::*[not(@RestrictStartDate)][not(@Status = 'Prospective')][not(ancestor::leg:BlockAmendment)][not(self::leg:P1/parent::leg:P1group or self::leg:P2 or self::leg:P3 or self::leg:P4 or self::leg:P5 or self::leg:P6)])
								and ancestor::*[@RestrictStartDate][1]/@RestrictStartDate = $date
						)
						
					)"/>
	
	<xsl:choose>
		<xsl:when test="$addStartDate">
			<xsl:attribute name="RestrictStartDate" select="$date" />
		</xsl:when>
		<xsl:when test="$date castable as xs:date and (self::leg:Schedules or self::leg:Group or self::leg:Part or self::leg:Chapter or self::leg:Schedule or self::leg:EUPart or self::leg:EUTitle or self::leg:EUChapter or self::leg:EUSection or self::leg:EUSubsection or self::leg:Division or self::leg:Appendix or self::leg:Attachments or self::leg:Attachment or self::leg:Pblock or self::leg:PsubBlock or self::leg:P1group or self::leg:P1[not(parent::leg:P1group)]) and not(@RestrictStartDate) and not(ancestor::leg:BlockAmendment) and not(@Status='Prospective')">
			<xsl:attribute name="RestrictStartDate" 
					select="if (ancestor::*[@RestrictStartDate][1]) then 
								ancestor::*[@RestrictStartDate][1]/@RestrictStartDate
							else $baseDate" />
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
	
	<xsl:choose>
		<xsl:when test="(not(@id) or $blnSubstituted or matches(@id, '^p[0-9]+')) and not(ancestor::leg:BlockAmendment) and not(self::leg:Schedules)">
			<xsl:variable name="id" as="attribute()?">
				<xsl:apply-templates select="." mode="createId">
					<xsl:with-param name="blnSubstituted" select="$blnSubstituted" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="resolvedId" as="attribute()?">
				<xsl:if test="exists($id)">
					<xsl:attribute name="id">
						<xsl:value-of select="tso:getNextDeduplicateNumber($id)"/>
					</xsl:attribute>
				</xsl:if>
			</xsl:variable>
			
			<xsl:sequence select="$resolvedId" />
			<xsl:apply-templates>
				<!-- markup the content if we're adding a new id now, as this is probably a pasted section -->
				<xsl:with-param name="markup" select="exists($id)" tunnel="yes" />
				<xsl:with-param name="blnSubstituted" select="$blnSubstituted" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- high level amends need to take the restrict start date down through the heiarchy and this scenario is not covered by above template-->
<xsl:template match="leg:P1group[not(@RestrictStartDate)][not(ancestor::leg:BlockAmendment)][not(@FragmentId)]" mode="content">
	<xsl:choose>
		<xsl:when test="exists($date) and (descendant::*[@RestrictStartDate = $date] or (not(@RestrictStartDate) and ancestor::*[@RestrictStartDate][1]/@RestrictStartDate = $date)) and not(@Status='Prospective')">
			<xsl:attribute name="RestrictStartDate" select="$date" />
		</xsl:when>
		<xsl:when test="not(@Status='Prospective') and not(@RestrictStartDate) and $date castable as xs:date">
			<xsl:attribute name="RestrictStartDate" 
					select="if (ancestor::*[@RestrictStartDate][1]) then 
								ancestor::*[@RestrictStartDate][1]/@RestrictStartDate
							else $baseDate" />
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
	<xsl:apply-templates />
</xsl:template>



<xsl:template match="node()" mode="content">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="leg:Group/@RestrictStartDate | leg:Part/@RestrictStartDate | leg:Chapter/@RestrictStartDate | leg:Schedule/@RestrictStartDate | leg:Appendix/@RestrictStartDate | leg:Pblock/@RestrictStartDate | leg:PsubBlock/@RestrictStartDate | leg:EUPart/@RestrictStartDate | leg:EUTitle/@RestrictStartDate | leg:EUChapter/@RestrictStartDate | leg:EUSection/@RestrictStartDate | leg:EUSubsection/@RestrictStartDate | leg:Division/@RestrictStartDate | leg:Attachments/@RestrictStartDate">
	<xsl:choose>
		<xsl:when test="not(parent::*/descendant::*/@RestrictStartDate = $date)">
			<xsl:copy>
				<xsl:apply-templates select="parent::*/@*" />
				<xsl:apply-templates select="parent::*" mode="content" />
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise><!--  we already have this added in the main template for these elements --></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="node()|@*">
	<xsl:variable name="isInForce" as="xs:boolean" select="exists(descendant-or-self::*[@RestrictStartDate = $date])"/>
	<xsl:copy>
		<xsl:apply-templates select="@* except (if (($isInForce and not(@Status='Repealed'))) then (@Match, @Status) else ())" />
		<xsl:apply-templates select="." mode="content" />
	</xsl:copy>
</xsl:template>

<!-- we can have legacy instances where the restrictstartdate is added to the P1 element which are not required and will be incorrect for the update  -->
<xsl:template match="leg:P1group[@RestrictStartDate = $date]/leg:P1[@RestrictStartDate != $date]">
	<xsl:copy>
		<xsl:apply-templates select="@* except @RestrictStartDate" />
		<xsl:apply-templates select="." mode="content" />
	</xsl:copy>
</xsl:template>

<!--  If a concurrent version is updated then we need to take that date down to the main body version  -->
<xsl:template match="leg:P1group[@AltVersionRefs][@RestrictStartDate != $date]">
	<xsl:copy>
		<xsl:apply-templates select="@* except @RestrictStartDate" />
		<xsl:choose>
			<xsl:when test="@AltVersionRefs and (some $ref in tokenize(@AltVersionRefs, ' ') satisfies $versions/leg:Version[@id = $ref]/*[@RestrictStartDate = $date])">
				<xsl:attribute name="RestrictStartDate" select="$date" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="RestrictStartDate" select="@RestrictStartDate" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="." mode="content" />
	</xsl:copy>
</xsl:template>

<xsl:template match="leg:Tasks" />

<!-- Create ToC -->

<xsl:template match="leg:Fragment | leg:Legislation" mode="ChangeCitationIDs">
	<xsl:param name="strIdentifier" as="xs:string" tunnel="yes" required="yes" />
	<xsl:copy>
		<xsl:sequence select="@*" />
		<xsl:sequence select="ukm:Metadata" />
		<Contents>
			<xsl:apply-templates select="(leg:Primary | leg:Secondary | leg:EURetained)/*" mode="ToC">
				<xsl:with-param name="id" tunnel="yes" select="$strIdentifier" />
				<xsl:with-param name="original" tunnel="yes" select="root()" />
				<xsl:with-param name="date" tunnel="yes" select="()" />
			</xsl:apply-templates>
		</Contents>
		<xsl:apply-templates select="leg:*" mode="#current" />
	</xsl:copy>
</xsl:template>

<xsl:template match="xi:include" mode="ToC">
	<xsl:param name="submittedData" as="node()*" tunnel="yes" required="yes" />
	<xsl:variable name="href" select="@href"/>
	<xsl:variable name="pi" as="processing-instruction()*" select="$submittedData//processing-instruction()[matches(., concat('href=&quot;', $href, '&quot;'))]"/>
	<xsl:variable name="PIname" select="$pi/name()"/>
	<xsl:variable name="tocPIname" select="if ($PIname = ('P1group', 'P1', 'P')) then 'ContentsItem' else concat('Contents', $PIname)"/>
	
	
	<xsl:if test="exists($tocPIname) and exists($pi) and not(matches($pi, 'introduction'))">
		<xsl:processing-instruction name="{$tocPIname}">
			<xsl:analyze-string select="$pi" regex='\s+id="([a-zA-Z-_\.\d]+)"\s'>
				 <xsl:matching-substring>
					<xsl:value-of select='translate(regex-group(1),"""", "")'/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:processing-instruction>
	</xsl:if>
</xsl:template>


<xsl:template match="processing-instruction()[starts-with(name(),'err-')]">
	<xsl:variable name="PI" select="substring-before(.,'content=')" />
	<xsl:variable name="PIname" select="substring-after(name(), 'err-')"/>
	<xsl:variable name="content" select="substring-after(., 'content=&quot;')"/>
	<xsl:element name="err:{$PIname}">
		<xsl:analyze-string select="$PI" regex='([\c]+)="(.*?")'>
			 <xsl:matching-substring>
				<xsl:attribute name="{regex-group(1)}">
					<xsl:value-of select='translate(regex-group(2),"""", "")'/>
				</xsl:attribute>
			 </xsl:matching-substring>
		</xsl:analyze-string>
		<xsl:value-of select='replace($content,"""$", "")' />
	</xsl:element>
</xsl:template>
	
	
<xsl:template match="processing-instruction()[matches(., 'href=')]">
   <xsl:variable name="content" select="substring-after(., 'href=&quot;')"/>
	<xsl:element name="xi:include">
		<xsl:attribute name="href">
			<xsl:value-of select='translate($content,"""", "")'/>
		</xsl:attribute>
	</xsl:element>
</xsl:template>
	
<!-- mark-up citations in any commentaries that are missing them -->
<xsl:template match="leg:Commentary/leg:Para/leg:Text">
	<leg:Text>
		<xsl:choose>
			<xsl:when test="leg:Citation | leg:CitationSubRef">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="Markup"/>
			</xsl:otherwise>
		</xsl:choose>
	</leg:Text>
</xsl:template>

<!-- template copied from augment.xsl as it's otherwised not used for some reason - issue with priority that needs looking into -->
<xsl:template match="leg:Commentary//text()" mode="Markup">
	<xsl:variable name="markedUp">
		<xsl:apply-templates select="." mode="MarkupCitations" />
	</xsl:variable>
	<xsl:variable name="titularHyphenRestored">
		<xsl:apply-templates select="$markedUp" mode="titularHyphen"/>
	</xsl:variable>
	<xsl:variable name="linked" as="document-node()">
		<xsl:document>
			<xsl:apply-templates select="$titularHyphenRestored" mode="LinkCitations" />
		</xsl:document>
	</xsl:variable>
	<xsl:apply-templates select="$linked" mode="AnnotateCitations" />
</xsl:template>

<xsl:function name="tso:getNextDeduplicateNumber" as="xs:string">
	<xsl:param name="id" as="xs:string"/>
	<xsl:choose>
		<xsl:when test="exists(key('identified', $id, $nodeset))">
			<xsl:variable name="next" select="count(key('identified', $id, $nodeset)) + 1"/>
			<xsl:value-of 
				select="if (matches($id, 'n[0-9]+$')) then 
							tso:getNextDeduplicateNumber(replace($id, 'n[0-9]+$', concat('n', $next))) 
						else 
							tso:getNextDeduplicateNumber(concat($id, 'n', count(key('identified', $id, $nodeset))))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$id"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

</xsl:stylesheet>
