<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- Legislation schema XHTML output for consolidated legislation -->

<!-- Version 1.00 -->
<!-- Created by Paul Appleby -->
<!-- Last changed 18/03/2009 by Paul Appleby -->
<!-- Change history

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xhtml="http://www.w3.org/1999/xhtml" 
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" 
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" 
xmlns:math="http://www.w3.org/1998/Math/MathML" 
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:err="http://www.tso.co.uk/assets/namespace/error"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:dct="http://purl.org/dc/terms/"
xmlns:fo="http://www.w3.org/1999/XSL/Format" 
xmlns:svg="http://www.w3.org/2000/svg" 
xmlns:atom="http://www.w3.org/2005/Atom" 
exclude-result-prefixes="atom leg ukm math msxsl dc dct ukm fo xsl svg xhtml tso xs err">

<!-- ========== Standard code for outputting legislation ========= -->

<xsl:import href="legislation_xhtml_vanilla.xslt"/>

<xsl:import href="../../common/utils.xsl"/>
<xsl:import href="process-annotations.xslt"/>

<xsl:import href="../../des/utils.xsl"/>

<xsl:output method="xhtml" version="1.0" omit-xml-declaration="yes"  indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<xsl:key name="citations" match="leg:Citation" use="@id" />
<xsl:key name="commentary" match="leg:Commentaries/leg:Commentary" use="@id"/>
<xsl:key name="commentaryRef" match="leg:CommentaryRef" use="@Ref"/>
<xsl:key name="commentaryRef" match="leg:Addition | leg:Repeal | leg:Substitution" use="@CommentaryRef"/>
<xsl:key name="commentaryRefInChange" match="leg:Addition | leg:Repeal | leg:Substitution" use="concat(@CommentaryRef, '+', @ChangeId)" />
<xsl:key name="additionRepealChanges" match="leg:Addition | leg:Repeal | leg:Substitution" use="@ChangeId"/>
<xsl:key name="substituted" match="leg:Repeal[@SubstitutionRef]" use="@SubstitutionRef" />
<xsl:key name="citationLists" match="leg:CitationList" use="@id"/>
<xsl:key name="versions" match="leg:Version" use="@id" />
<xsl:key name="versionOf" match="*[@AltVersionRefs]" use="tokenize(@AltVersionRefs, ' ')" />

<!-- we need to reference the document order of the commentaries rather than the commenatry order in order to gain the correct numbering sequence. Therefore we will build a nodeset of all CommentartRef/Addition/Repeal elements and their types which can be queried when determining the sequence number -->

<!-- Chunyu:Added a condition for versions. We should go from the root call Call HA048969 -->
<xsl:variable name="g_commentaryOrder">
	<xsl:variable name="commentaryRoot" as="node()+"
		select="if (empty($selectedSection)) then root()
		        (: include all commentaries if the section has been repealed :)
		        else if ($selectedSection/@Match = 'false' and (not($selectedSection/@Status) or $selectedSection/@Status != 'Prospective') and not($selectedSection/@RestrictStartDate and ((($version castable as xs:date) and xs:date($selectedSection/@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date($selectedSection/@RestrictStartDate) &gt; current-date())))) then root()
		        else if (root()//leg:Versions) then root()
		        else $selectedSection" />
	<xsl:for-each-group select="$commentaryRoot//(leg:CommentaryRef | leg:Addition | leg:Repeal | leg:Substitution)" group-by="(@Ref, @CommentaryRef)[1]">
		<leg:commentary id="{current-grouping-key()}" Type="{key('commentary', current-grouping-key())/@Type}" />
	</xsl:for-each-group>
</xsl:variable>

<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>

<xsl:variable name="legislationYear" select="/(leg:Legislation|leg:Fragment)/ukm:Metadata//ukm:Year/@Value"/>
<xsl:variable name="legislationNumber" select="/(leg:Legislation|leg:Fragment)/ukm:Metadata//ukm:Number/@Value"/>
<xsl:variable name="uriPrefix" select="tso:GetUriPrefixFromType(/(leg:Legislation|leg:Fragment)/ukm:Metadata//ukm:DocumentMainType/@Value, $legislationYear)"/>
<xsl:variable name="dcIdentifier" select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/dc:identifier"/>
<xsl:variable name="isRepealedAct" select="matches((/leg:Legislation/ukm:Metadata/dc:title)[1], '\((repealed|revoked)(\s*[\d]{1,2}\.[\d]{1,2}\.[\d]{4}\s*)?\)\s*$', 'i')"/>

<xsl:param name="version" as="xs:string" select="($paramsDoc/parameters/version, $paramsDoc/parameters/date, '')[1]"/>
<xsl:variable name="contentsLinkParams" as="xs:string" select="if ($paramsDoc/parameters/extent[. != '']) then '?view=extent' else ''" />

<xsl:param name="g_blnWrap" as="xs:boolean" select="$paramsDoc/parameters/wrap = 'true'" />

<xsl:variable name="g_ndsTemplateDoc" 
	select="if ($g_blnWrap) then doc('HTMLTemplate_Vanilla-v-1-0.xml') else doc('HTMLTemplate_snippet.xml')" />

<xsl:param name="selectedSection" as="element()?" select="()" />
<xsl:variable name="selectedSectionSubstituted" as="xs:boolean" select="if (exists($selectedSection)) then tso:isSubstituted($selectedSection) else false()" />
<xsl:variable name="showTextualEffects" as="xs:boolean" select="false()" />
<xsl:variable name="showCommencementEffects" as="xs:boolean" select="false()" />
<xsl:variable name="showExtentEffects" as="xs:boolean" select="false()" />

<!-- ========= Code for consolidation ========== -->

<xsl:template match="leg:Legislation|leg:Fragment">
	
	<!--<p>Parameters for this page: </p>
	<xsl:for-each select="doc('input:request')/parameters/*">
		<p><xsl:value-of select="name()"/>: <xsl:value-of select="."/></p>
	</xsl:for-each>-->
	<xsl:call-template name="FuncLegNotification"/>
	<xsl:choose>
		<xsl:when test="$paramsDoc/parameters/view = 'introduction'">
			<xsl:apply-templates select="leg:Primary/leg:PrimaryPrelims | leg:Secondary/leg:SecondaryPrelims | leg:EURetained/leg:EUPrelims" />
			<xsl:apply-templates select="*[not(self::leg:Primary | self::leg:Secondary | self::leg:EURetained | self::leg:Contents)] | processing-instruction()"/>
		</xsl:when>
		<xsl:when test="$paramsDoc/parameters/view = 'body'">
			<xsl:apply-templates select="(leg:Primary | leg:Secondary)/leg:Body | leg:EURetained/leg:EUBody"/>
		</xsl:when>
		<xsl:when test="$paramsDoc/parameters/view = 'contents'">
			<xsl:apply-templates select="leg:Contents" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="*[not(self::leg:Contents)] | processing-instruction()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Ignore tasks in presentation (only appera within fragments) -->
<xsl:template match="leg:Tasks" />

<xsl:template match="leg:PrimaryPrelims" mode="Introduction">
	<div class="LegClearFix LegPrelims">
		<xsl:call-template name="FuncOutputPrimaryPrelimsPreContents"/>
		<xsl:apply-templates select="/(leg:Legislation|leg:Fragment)/leg:Contents"/>		
		<xsl:call-template name="FuncOutputPrimaryPrelimsPostContents"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:SecondaryPrelims" mode="Introduction">
	<div class="LegClearFix LegPrelims">
		<xsl:apply-templates select="leg:Number | leg:SubjectInformation | leg:Title"/>
		<xsl:apply-templates select="leg:SecondaryPreamble"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<!-- Suppress repealed content -->
<!-- D315: For substitutions we would like to show only the 'new' text again enclosed in brackets, at the moment on the system both the new and old text are appearing (unless the substitution has restricted extent, in which case both should be shown) -->
<xsl:template match="leg:Group[.//leg:Repeal[@SubstitutionRef]] | leg:Part[.//leg:Repeal[@SubstitutionRef]] | leg:Chapter[.//leg:Repeal[@SubstitutionRef]] | 
		leg:Schedule[.//leg:Repeal[@SubstitutionRef]] | leg:ScheduleBody[.//leg:Repeal[@SubstitutionRef]] |
		leg:Pblock[.//leg:Repeal[@SubstitutionRef]] | leg:PsubBlock[.//leg:Repeal[@SubstitutionRef]] | leg:P1group[.//leg:Repeal[@SubstitutionRef]] | 
		leg:P1[.//leg:Repeal[@SubstitutionRef]] | leg:P2[.//leg:Repeal[@SubstitutionRef]] | leg:P3[.//leg:Repeal[@SubstitutionRef]] | 
		leg:P4[.//leg:Repeal[@SubstitutionRef]] | leg:P5[.//leg:Repeal[@SubstitutionRef]] | leg:P6[.//leg:Repeal[@SubstitutionRef]] | leg:P7[.//leg:Repeal[@SubstitutionRef]] |
		leg:P1para[.//leg:Repeal[@SubstitutionRef]] | leg:P2para[.//leg:Repeal[@SubstitutionRef]] | leg:P3para[.//leg:Repeal[@SubstitutionRef]] | 
		leg:P4para[.//leg:Repeal[@SubstitutionRef]] | leg:P5para[.//leg:Repeal[@SubstitutionRef]] | leg:P6para[.//leg:Repeal[@SubstitutionRef]] | leg:P7para[.//leg:Repeal[@SubstitutionRef]]"
		priority="99">
	<xsl:param name="showRepeals" select="false()" tunnel="yes" />			
	<xsl:if test="$selectedSectionSubstituted or not(tso:isSubstituted(.)) or $showRepeals or .//leg:Repeal/@Extent or .//leg:Repeal[@RetainText='true']">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<!-- DXXX: For repeals we would like to show only the text again enclosed in brackets if showRepeals is turned on, unless @RetainText='true' is prsent in the content -->
<xsl:template match="leg:Group[.//leg:Repeal[not(@RetainText='true')]] | leg:Part[.//leg:Repeal[not(@RetainText='true')]] | leg:Chapter[.//leg:Repeal[not(@RetainText='true')]] | 
		leg:Schedule[.//leg:Repeal[not(@RetainText='true')]] | leg:ScheduleBody[.//leg:Repeal[not(@RetainText='true')]] |
		leg:Pblock[.//leg:Repeal[not(@RetainText='true')]] | leg:PsubBlock[.//leg:Repeal[not(@RetainText='true')]] | leg:P1group[.//leg:Repeal[not(@RetainText='true')]] | 
		leg:P1[.//leg:Repeal[not(@RetainText='true')]] | leg:P2[.//leg:Repeal[not(@RetainText='true')]] | leg:P3[.//leg:Repeal[not(@RetainText='true')]] | 
		leg:P4[.//leg:Repeal[not(@RetainText='true')]] | leg:P5[.//leg:Repeal[not(@RetainText='true')]] | leg:P6[.//leg:Repeal[not(@RetainText='true')]] | leg:P7[.//leg:Repeal[not(@RetainText='true')]] | 
		leg:P1para[.//leg:Repeal[not(@RetainText='true')]] | leg:P2para[.//leg:Repeal[not(@RetainText='true')]] | leg:P3para[.//leg:Repeal[not(@RetainText='true')]] | 
		leg:P4para[.//leg:Repeal[not(@RetainText='true')]] | leg:P5para[.//leg:Repeal[not(@RetainText='true')]] | leg:P6para[.//leg:Repeal[not(@RetainText='true')]] | leg:P7para[.//leg:Repeal[not(@RetainText='true')]]"
		priority="100">
	<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
	<xsl:param name="withinRepeal" select="()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$showRepeals or $withinRepeal or not(tso:isRepealed(.))">
			<xsl:next-match />
		</xsl:when>
		<xsl:when test="self::leg:P1para or self::leg:P2para or self::leg:P3para or self::leg:P4para or self::leg:P5para or self::leg:P6para or self::leg:P7para">
			<xsl:next-match>
				<xsl:with-param name="withinRepeal" tunnel="yes" select="." />
			</xsl:next-match>
		</xsl:when>
		<xsl:when test=".//leg:Text">
			<p>. . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Want to retain numbers in these cases, so just target the text
<xsl:template match="text()" priority="5">
	<xsl:param name="withinRepeal" select="()" tunnel="yes" />	
	<xsl:choose>
		<xsl:when test="empty($withinRepeal) or not(ancestor::*[. is $withinRepeal])">
			<xsl:next-match />
		</xsl:when>
		<xsl:when test="normalize-space(.) != '' and ($withinRepeal//leg:Text//text()[normalize-space(.) != ''])[1] is .">
			<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>		
		</xsl:when>
	</xsl:choose>
</xsl:template> -->

<xsl:template match="leg:Repeal[@SubstitutionRef]">
	<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
	
	<xsl:if test="$selectedSectionSubstituted or $showRepeals or @Extent or @RetainText='true'">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:function name="tso:isSubstituted" as="xs:boolean">
	<xsl:param name="element" as="element()" />
	<xsl:variable name="firstTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][1]/ancestor::leg:Repeal[@SubstitutionRef]" />
	<xsl:variable name="lastTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][last()]/ancestor::leg:Repeal[@SubstitutionRef]" />
	<xsl:sequence select="exists($firstTextRepeal) and exists($lastTextRepeal) and $firstTextRepeal/@ChangeId = $lastTextRepeal/@ChangeId" />
</xsl:function>

<xsl:function name="tso:isRepealed" as="xs:boolean">
	<xsl:param name="element" as="element()" />
	<xsl:variable name="firstTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][1]/ancestor::leg:Repeal[not(@SubstitutionRef) and not(@Status = 'Proposed')]" />
	<xsl:variable name="lastTextRepeal" as="element(leg:Repeal)*" select="$element/descendant::text()[normalize-space(.) != ''][last()]/ancestor::leg:Repeal[not(@SubstitutionRef) and not(@Status = 'Proposed')]" />
	<xsl:sequence select="exists($firstTextRepeal) and exists($lastTextRepeal) and $firstTextRepeal/@ChangeId = $lastTextRepeal/@ChangeId" />
</xsl:function>

<xsl:template match="leg:ContentsItem/leg:ContentsNumber">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />
	<xsl:variable name="nstContent">
		<xsl:apply-templates/>
		<xsl:if test="translate(., ' &#160;', '') != ''">
			<xsl:text>.</xsl:text>
		</xsl:if>
	</xsl:variable>
	<!-- <span class="LegDS {concat('LegContentsNo', $strAmendmentSuffix)}{if (exists($matchIndex)) then ' LegSearchResult' else ()}"> -->
	<span class="LegDS {concat('LegContentsNo', $strAmendmentSuffix)}{if (../@MatchText) then ' LegSearchResult' else ()}">
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:copy-of select="$nstContent" />
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$nstContent" />
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>
	
<xsl:template match="leg:ContentsPart/leg:ContentsNumber | leg:ContentsEUPart/leg:ContentsNumber | leg:ContentsChapter/leg:ContentsNumber | leg:ContentsEUChapter/leg:ContentsNumber | leg:ContentsEUTitle/leg:ContentsNumber | leg:ContentsEUSection/leg:ContentsNumber | leg:ContentsEUSubsection/leg:ContentsNumber | leg:ContentsDivision/leg:ContentsNumber">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />
	<p class="{if (parent::leg:ContentsDivision) then 'LegContentsItem'  else concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:if test="exists($matchIndex) and ../@ContentRef">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="class" select="'LegSearchResult'" />
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="following-sibling::leg:ContentsTitle" mode="inlineTitle"/>
				</a>
			<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="following-sibling::leg:ContentsTitle" mode="inlineTitle"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</p>
</xsl:template>	
	
<xsl:template match="leg:ContentsNumber">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />
	<p class="{concat('LegContentsNo', $strAmendmentSuffix)}">
		<xsl:if test="exists($matchIndex) and ../@ContentRef">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="class" select="'LegSearchResult'" />
					</xsl:if>
					<xsl:choose>
						<xsl:when test=". = '' and ../leg:ContentsTitle = ''">
							<xsl:value-of select="substring-after(local-name(..), 'Contents')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates />
						</xsl:otherwise>
					</xsl:choose>
				</a>
			<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</p>
</xsl:template>

<xsl:template match="leg:ContentsPart/leg:ContentsTitle | leg:ContentsEUPart/leg:ContentsTitle | leg:ContentsChapter/leg:ContentsTitle  | leg:ContentsEUChapter/leg:ContentsTitle  | leg:ContentsEUTitle/leg:ContentsTitle | leg:ContentsEUSection/leg:ContentsTitle | leg:ContentsEUSubsection/leg:ContentsTitle | leg:ContentsDivision/leg:ContentsTitle" mode="inlineTitle">
	<xsl:apply-templates/>
</xsl:template>

<!-- Chunyu  HA050364 deleted leg:ContentsPart/leg:ContentsTitle in this template. It has casused the titles were missing see nisi/2007/1351,NISI 2007/287 (NI 1) and etc.-->
	<!-- Yashashri HA051273 - Reverted code changed by chunyu to existing one  as it was creating other issue(HA051273)with one extra condition so that it can fix both issue in call HA051273 and HA049670(the issue chunuy fixed)-->
	<xsl:template match="leg:ContentsPart[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsEUPart[leg:ContentsNumber]/leg:ContentsTitle |  leg:ContentsChapter[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsEUChapter[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsEUTitle[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsEUSection[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsEUSubsection[leg:ContentsNumber]/leg:ContentsTitle | leg:ContentsDivision[leg:ContentsNumber]/leg:ContentsTitle">
<!--  FM U437: Chapter Headings should appear even if there is no chapter number-->   
</xsl:template>

<xsl:template match="leg:Contents/leg:ContentsTitle">
	<h2 class="LegContentsHeading">
		<xsl:value-of select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/dc:title" />			
	</h2>
</xsl:template>

<xsl:template match="leg:ContentsSchedules/leg:ContentsTitle">
	<xsl:apply-imports />
</xsl:template>

<xsl:template match="leg:ContentsItem/leg:ContentsTitle">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />		
	<!-- Chunyu HA051073 changed the condition of LegSearchResult into @MatchText. It will be safer to get search result. There are instances that replicated section ids. See aosp/1690/7
	<span class="LegDS {concat('LegContentsTitle', $strAmendmentSuffix)}{if (exists($matchIndex)) then ' LegSearchResult' else ()}"> -->
	<!-- pass that through as a tunnelling parameter called $matchRefs. Then on a given item get the index-of() this item's ContentRef wtihin -->	
		<span class="LegDS {concat('LegContentsTitle', $strAmendmentSuffix)}{if (../@MatchText) then ' LegSearchResult' else ()}">
		<xsl:if test="exists($matchIndex)">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<!--	HA050978 - added condition to have links for titles in ContentsSchedule - http://www.legislation.gov.uk/apni/1970/10/contents-->
			<xsl:when test="parent::*/parent::leg:ContentsSchedule/@DocumentURI and not(parent::*/@DocumentURI)">
				<a href="{substring-after(parent::*/parent::leg:ContentsSchedule/@DocumentURI, 'http://www.legislation.gov.uk')}">
					<xsl:apply-templates/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</span>
	<xsl:call-template name="matchLinks">
		<xsl:with-param name="matchIndex" select="$matchIndex" />
	</xsl:call-template>		
</xsl:template>

<xsl:template match="leg:ContentsTitle">
	<xsl:param name="matchRefs" tunnel="yes" select="()" />
	<xsl:param name="linkFragment" tunnel="yes" as="xs:string?" select="()" />
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="matchIndex" as="xs:integer?" select="if (exists(../@ContentRef)) then index-of($matchRefs, ../@ContentRef)[1] else ()" />		
	<p class="{concat('LegContentsTitle', $strAmendmentSuffix)}">
		<!-- pass that through as a tunnelling parameter called $matchRefs. Then on a given item get the index-of() this item's ContentRef wtihin -->
		<xsl:if test="exists($matchIndex) and ../@ContentRef">
			<xsl:attribute name="id" select="concat('match-', $matchIndex)"/>
		</xsl:if>	
		<xsl:choose>
			<xsl:when test="parent::*/@DocumentURI">
				<xsl:variable name="contentsLinkParams"
					select="if (exists($matchIndex) and ../@Status = 'Repealed') then 
					          string-join(('?timeline=true', if (exists($contentsLinkParams)) then substring($contentsLinkParams, 2) else ()), '&amp;') 
					        else 
					          $contentsLinkParams" />
				<a href="{substring-after(parent::*/@DocumentURI, 'http://www.legislation.gov.uk')}{$contentsLinkParams}{$linkFragment}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="class" select="'LegSearchResult'" />
					</xsl:if>
					<xsl:apply-templates/>
				</a>
			<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>		
	</p>
</xsl:template>
	
	<!-- added by Yashashri - call No : HA050979 - citation links should not appear in TOC -->	
	<xsl:template match="leg:ContentsSchedule/leg:ContentsTitle/leg:Citation"/>

<xsl:template name="matchLinks">
	<xsl:param name="matchRefs" as="xs:string*" tunnel="yes" select="()" />
	<xsl:param name="matchIndex" as="xs:integer?" required="yes" />
	<xsl:if test="exists($matchIndex)">
		<!-- adding previous link-->			
		<xsl:if test="$matchIndex &gt; 1">
			<span class="skipLink prev">
				<a href="{concat('#match-', $matchIndex -1 )}">Previous Match</a>
			</span>
		</xsl:if>
		<!-- adding next link-->
		<xsl:if test="$matchIndex &lt; count($matchRefs)">
			<span class="skipLink next">
				<a href="{concat('#match-', $matchIndex + 1)}">Next Match</a>
			</span>
		</xsl:if>
	</xsl:if>		
</xsl:template>

<!--Chunyu:Call HA049511 Added includedDocument in $showSection to resovle the xml file to display properly on the page see /uksi/1999/1892/ -->
<xsl:template match="leg:Body | leg:EUBody | leg:Schedules">
	<xsl:param name="showSection" as="element()*" tunnel="yes" select="()" />
	<xsl:choose>
		<xsl:when test="ancestor::leg:BlockAmendment">
			<xsl:next-match />
		</xsl:when>
		<xsl:when test="exists($showSection[not(//leg:IncludedDocument)])">
			<xsl:apply-templates select="$showSection" mode="showSectionWithAnnotation"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="ProcessAnnotations" />
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Adding Annotations for parent levels if the current section is dead/repeal -->
<xsl:template match="*" mode="showSectionWithAnnotation">
	<xsl:apply-templates select="."/>
</xsl:template>


<xsl:template match="leg:InlineAmendment">
	<span class="LegAmendingText">
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution">
	<xsl:param name="showSection" select="root()" tunnel="yes" />
	<xsl:param name="showRepeals" select="false()" tunnel="yes" />	
	<xsl:variable name="showCommentary" as="xs:boolean" select="tso:showCommentary(.)" />
	<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />
	<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else if ($g_strDocumentType = $g_strEUretained and ancestor::leg:Footnotes) then ancestor::leg:Footnotes else root()/leg:Legislation/(leg:EURetained|leg:Primary|leg:Secondary)" />
	<xsl:variable name="sameChanges" as="element()*" select="key('additionRepealChanges', $changeId, $showSection)" />
	<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
	<xsl:variable name="lastChange" as="element()?" select="$sameChanges[last()]" />
	<xsl:variable name="isFirstChange" as="xs:boolean?">
		<xsl:choose>
			<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
				<xsl:sequence select="$firstChange is (ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Repeal|leg:Substitution))[@ChangeId = $changeId][1]" />
			</xsl:when>
			<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Title/parent::leg:P1group">
				<xsl:sequence select="$firstChange is . and
					empty(ancestor::leg:Title/parent::leg:P1group/leg:P1[1]/leg:Pnumber//(leg:Addition|leg:Repeal|leg:Substitution)[@ChangeId = $changeId])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$firstChange is ." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="changeType" as="xs:string">
		<xsl:choose>
			<xsl:when test="key('substituted', $changeId)">Substitution</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$showCommentary">
		<xsl:if test="$isFirstChange = true()">
			<span class="LegChangeDelimiter">[</span>
		</xsl:if>
		<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
	</xsl:if>
	<span class="Leg{if (@Status = 'Proposed') then 'Proposed' else ''}{$changeType}">
		<xsl:apply-templates/>
	</span>
	<xsl:if test="$showCommentary and key('additionRepealChanges', @ChangeId, $showSection)[last()] is .">
		<span class="LegChangeDelimiter">]</span>
	</xsl:if>
</xsl:template>

<!-- these templates handle the display of the revision brackets for equations that have been substituted by images  -->
<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution" mode="mathrevisions">
	<xsl:param name="showSection" select="root()" tunnel="yes" />
	<xsl:param name="showRepeals" select="false()" tunnel="yes" />
	<xsl:variable name="showCommentary" as="xs:boolean" select="tso:showCommentary(.)" />
	<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />
	<xsl:variable name="showSection" as="node()"
		select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection else root()" />
	<xsl:variable name="sameChanges" as="element()*" select="key('additionRepealChanges', $changeId, $showSection)" />
	<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
	<xsl:variable name="lastChange" as="element()?" select="$sameChanges[last()]" />
	<xsl:variable name="isFirstChange" as="xs:boolean?">
		<xsl:sequence select="$firstChange is ." />
	</xsl:variable>
	<xsl:variable name="changeType" as="xs:string">
		<xsl:choose>
			<xsl:when test="key('substituted', $changeId)">Substitution</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$showCommentary">
		<xsl:if test="$isFirstChange = true()">
			<span class="LegChangeDelimiter">[</span>
		</xsl:if>
		<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
	</xsl:if>
	<xsl:apply-templates  mode="mathrevisions"/>
	<xsl:if test="$showCommentary and key('additionRepealChanges', @ChangeId, $showSection)[last()] is .">
		<span class="LegChangeDelimiter">]</span>
	</xsl:if>
</xsl:template>

<xsl:template	match="node()|@*"  mode="mathrevisions">
	<xsl:apply-templates  mode="mathrevisions"/>
</xsl:template>

<!--<xsl:template match="leg:Repeal">
	<xsl:apply-templates select="." mode="AdditionRepealRefs"/>
	<span class="LegRepeal">
		<xsl:apply-templates/>
	</span>
</xsl:template>-->
	
<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution" mode="AdditionRepealRefs">
	<xsl:param name="showSection" select="root()" tunnel="yes" />
	<xsl:if test="@CommentaryRef">
		<xsl:variable name="commentaryItem" select="key('commentary', @CommentaryRef)[1]" as="element(leg:Commentary)*"/>
		<xsl:if test="$commentaryItem/@Type = ('F', 'M', 'X')">
			<!-- The <Title> comes before the <Pnumber> in the XML, but appears after the <Pnumber> in the HTML display
			so the first commentary reference for the change is the one in the <Title> rather than the one in the <Pnumber>-->
			<xsl:variable name="changeId" as="xs:string" select="@ChangeId" />			
			<xsl:variable name="showSection" as="node()"
				select="if (ancestor::*[@VersionReplacement]) then ancestor::*[@VersionReplacement] else if (exists($showSection) and ancestor-or-self::*[. is $showSection]) then $showSection  else if ($g_strDocumentType = $g_strEUretained and ancestor::leg:Footnotes) then ancestor::leg:Footnotes else root()/leg:Legislation/(leg:EURetained|leg:Primary|leg:Secondary)" />
	
			<xsl:variable name="sameChanges" as="element()*" select="key('commentaryRefInChange', concat(@CommentaryRef, '+', @ChangeId), $showSection)" />
			
			<xsl:variable name="firstChange" as="element()?" select="$sameChanges[1]" />
			<xsl:variable name="isFirstChange" as="xs:boolean?">
				<xsl:choose>
					<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group">
						<xsl:sequence select="$firstChange is (ancestor::leg:Pnumber/parent::leg:P1/parent::leg:P1group//(leg:Addition|leg:Substitution|leg:Repeal))[@ChangeId = $changeId][1]" />
					</xsl:when>
					<xsl:when test="$g_strDocumentType = $g_strPrimary and ancestor::leg:Title/parent::leg:P1group">
						<xsl:sequence select="$firstChange is . and
							empty(ancestor::leg:Title/parent::leg:P1group/leg:P1[1]/leg:Pnumber//(leg:Addition|leg:Substitution|leg:Repeal)[@ChangeId = $changeId])" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$firstChange is ." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="$isFirstChange = true()">
				<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
				<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @CommentaryRef)[1] is ., $commentaryItem,  translate($versionRef,' ',''))"/>
			</xsl:if>		
		</xsl:if>
	</xsl:if>
</xsl:template>

<!-- Make assumption here that comments have been filtered to only contain those relevant for content being viewed -->
<!--Chunyu HA051080 added the logic for CommentaryRef. We need to display each individual commentaryref if it is not the child of additon and etc. We only output the first one if  the commentaryrefs with same ref are the chidren of addtion and etc.-->
<xsl:template match="leg:EURetained/leg:CommentaryRef | leg:Primary/leg:CommentaryRef | leg:Secondary/leg:CommentaryRef" />

<xsl:template match="leg:CommentaryRef">
	<xsl:variable name="commentaryItem" select="key('commentary', @Ref)[1]" as="element(leg:Commentary)?"/>
	<xsl:variable name="versionRef" select="ancestor-or-self::*[@VersionReference][1]/@VersionReference"/>
	<xsl:if test="empty($commentaryItem)">
		<span class="LegError">No commentary item could be found for this reference <xsl:value-of select="@Ref"/></span>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="../(self::leg:Addition | self::leg:Repeal | self::leg:Substitution)">
			<xsl:if test="tso:showCommentary(.) and $commentaryItem/@Type = ('F', 'M', 'X') and key('commentaryRef', @Ref)[1] is .">
				<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @Ref)[1] is ., $commentaryItem,  translate($versionRef,' ',''))"/>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="tso:showCommentary(.) and $commentaryItem/@Type = ('F', 'M', 'X') ">
				<xsl:sequence select="tso:OutputCommentaryRef(key('commentaryRef', @Ref)[1] is ., $commentaryItem,  translate($versionRef,' ',''))"/>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>
	
<xsl:function name="tso:OutputCommentaryRef" as="element(xhtml:a)">
	<xsl:param name="isFirstReference" as="xs:boolean"/>
	<xsl:param name="commentaryItem" as="element(leg:Commentary)"/>
	<xsl:param name="versionRef" as="xs:string"/>
	<a class="LegCommentaryLink" href="#commentary-{$commentaryItem/@id}{$versionRef}" title="View the commentary text for this item">
		<!-- There may be multiple references to the commentary. Only output back id on first one -->
		<xsl:if test="$isFirstReference">
			<xsl:attribute name="id" select="concat('reference-', $commentaryItem/@id, $versionRef)"/>
		</xsl:if>
		<xsl:variable name="thisId" select="$commentaryItem/@id"/>
		<xsl:value-of select="$commentaryItem/@Type"/>
		<!--<xsl:value-of select="count($commentaryItem/preceding-sibling::*[@Type = $commentaryItem/@Type]) + 1"/>-->
		<!-- we need to reference the document order of the commentaries rather than the commentary order in order to gain the correct numbering sequence -->
		<xsl:value-of select="count($g_commentaryOrder/leg:commentary[@id = $thisId][1]/preceding-sibling::*[@Type = $commentaryItem/@Type]) + 1"/>
	</a>
</xsl:function>

<!-- when we have repealed parts then a child para is usually added which has the annotation in it  -->
<xsl:template match="leg:P[not(parent::leg:P1group)]">
	<xsl:apply-templates/>
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
</xsl:template>

<xsl:template match="leg:SignedSection">
	<xsl:next-match/>
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
</xsl:template>

<xsl:template match="leg:ExplanatoryNotes">
	<xsl:next-match/>
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
</xsl:template>

<xsl:template match="leg:Commentaries | err:Warning | leg:CitationLists"/>

	<!-- ANNOTATION PROCESSING -->
	<!-- call the annotation processing from a common module that serves both html and fo generation  --> 
	<xsl:template match="*" mode="ProcessAnnotations" priority="100">
		<xsl:next-match/>
	</xsl:template>


<!-- Override Vanilla handling -->
<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:Schedule | leg:Form" mode="Structure">
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	<xsl:call-template name="FuncProcessStructureContents"/>
</xsl:template>
	
<!-- ========== Handle extent information ========== -->
<!-- May need to extend this to cover a standalone P1 as well as P1group for secondary formatted legislation -->

<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims" priority="100">
	<xsl:if test="ancestor-or-self::*/@RestrictExtent">
		<xsl:variable name="blnConcurrent" as="xs:boolean" select="@Concurrent = 'true'" />
		<p class="LegExtentParagraph{if ($blnConcurrent) then ' LegConcurrent' else ''}">
			<xsl:copy-of select="tso:generateExtentInfo(.)"/>
		</p>
	</xsl:if>	
	<xsl:next-match/>
</xsl:template>

<xsl:template name="FuncGenerateMajorHeadingNumber">
	<xsl:param name="strHeading"/>
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="blnConcurrent" as="xs:boolean" 
		select="parent::*/@Concurrent = 'true'" />
	<xsl:element name="span">
		<xsl:attribute name="class">
			<xsl:text>Leg</xsl:text>
			<xsl:value-of select="$strHeading"/>
			<xsl:text>No</xsl:text>
			<!-- Allow for any section reference apart from Scottish where it it output underneath -->
			<xsl:if test="following-sibling::leg:Reference and not(contains($g_strDocumentMainType, 'ScottishAct'))"> LegHeadingRef</xsl:if>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:if test="not(following-sibling::leg:Reference)">
					<xsl:text> Leg</xsl:text>
				</xsl:if>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
			<xsl:if test="$blnConcurrent"> LegConcurrent</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
		<xsl:if test="ancestor-or-self::*/@RestrictExtent">
			<xsl:sequence select="tso:generateExtentInfo(..)"/>
		</xsl:if>	
	</xsl:element>
</xsl:template>

	<xsl:template name="FuncGenerateMajorHeadingTitle">
	<xsl:param name="strHeading"/>
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
	<xsl:variable name="blnConcurrent" as="xs:boolean" 
		select="parent::*/@Concurrent = 'true'" />
	<xsl:variable name="blnHasNumber" as="xs:boolean" select="exists(../leg:Number) or exists(parent::leg:TitleBlock/../leg:Number)" />
	<xsl:element name="span">		
		<xsl:attribute name="class">
			<!-- Yashashri: Changed To make Headings Left alligned - Support call - HA047941-->
			<!-- Chunyu: Added the condition for Yash's change to limit for pblock see HA050365 http://www.legislation.gov.uk/nia/2012/3/part/3 -->
				<xsl:choose>
					<xsl:when test="leg:Emphasis and not(parent::leg:Pblock)">LegClearFix LegSP1GroupTitle</xsl:when>
					<xsl:otherwise>	
						<xsl:text>Leg</xsl:text>
						<xsl:value-of select="$strHeading"/>
						<xsl:text>Title</xsl:text>
						<xsl:if test="$strAmendmentSuffix != ''">
							<xsl:text> Leg</xsl:text>
							<xsl:value-of select="$strAmendmentSuffix"/>
						</xsl:if>
						<xsl:if test="not($blnHasNumber) and $blnConcurrent"> LegConcurrent</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
		</xsl:attribute>	
		<xsl:apply-templates/>
		<xsl:if test="not($blnHasNumber) and ancestor-or-self::*/@RestrictExtent">
			<xsl:sequence select="tso:generateExtentInfo(if (parent::leg:TitleBlock) then parent::leg:TitleBlock/.. else ..)" />
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment)]/leg:Title/node()[last()]" priority="100">
	<xsl:next-match/>
	<xsl:if test="ancestor-or-self::*/@RestrictExtent">
		<xsl:variable name="blnConcurrent" as="xs:boolean" 
			select="ancestor::leg:P1group/@Concurrent = 'true'" />
		<xsl:variable name="nstContent" as="node()*">
			<xsl:copy-of select="tso:generateExtentInfo(ancestor::leg:P1group)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$blnConcurrent">
				<span class="{concat('LegConcurrent', if (ancestor::leg:P1group/@Status='Prospective') then ' LegProspective' else '' )}">
					<xsl:sequence select="if ($g_strDocumentType = $g_strEUretained) then () else $nstContent" />
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="if ($g_strDocumentType = $g_strEUretained) then () else $nstContent" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!--  for regular EU Divisions we need to format the extent data as per the uk legislation  -->
<xsl:template match="leg:Division[not(@Type = ('EUPart','EUChapter','EUSection','EUSubsection', 'ANNEX'))][not(ancestor::leg:BlockAmendment)][not(ancestor::leg:EUPrelims )]/leg:Title/node()[last()] |
leg:Division[not(@Type = ('EUPart','EUChapter','EUSection','EUSubsection', 'ANNEX'))][not(ancestor::leg:BlockAmendment)][not(ancestor::leg:EUPrelims )][not(leg:Title)]/*[not(self::leg:Number)][1]/leg:Text/node()[last()]" priority="100">
	<!--
	 |
leg:Division[not(@Type = ('EUPart','EUChapter','EUSection','EUSubsection', 'ANNEX'))][not(ancestor::leg:BlockAmendment)][not(leg:Title)]/*[not(self::leg:Number)][1]/leg:Text/node()[last()]
-->
	<xsl:next-match/>
	<xsl:if test="ancestor-or-self::*/@RestrictExtent and $g_strDocumentType = $g_strEUretained">
		<xsl:variable name="blnConcurrent" as="xs:boolean" 
			select="ancestor::leg:P1group/@Concurrent = 'true'" />
		<xsl:variable name="nstContent" as="node()*">
			<xsl:copy-of select="tso:generateExtentInfo(ancestor::*[@RestrictExtent][1])"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$blnConcurrent">
				<span class="{concat('LegConcurrent', if (ancestor::leg:Division/@Status='Prospective') then ' LegProspective' else '' )}">
					<xsl:sequence select="$nstContent" />
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$nstContent" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:function name="tso:generateExtentInfo" as="element()?">
	<xsl:param name="element" as="node()" />
	<xsl:variable name="extent" as="xs:string" select="($element/ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent, 'E+W+S+N.I.')[1]" />
	<span class="LegExtentRestriction">
		<!--<xsl:if test="$nstSelectedSection is $element">-->
			<xsl:attribute name="id" select="concat('extent-', translate($extent, '+', '-'))" />
		<!--</xsl:if>-->
		<xsl:attribute name="title">
			<xsl:variable name="extentsToken" select="tokenize($extent, '\+')" />
			<xsl:text>Applies to </xsl:text>
			<xsl:value-of select="tso:extentDescription($extentsToken)" />
		</xsl:attribute>
		<span class="btr"></span>
		<xsl:value-of select="$extent" />
		<span class="bbl"></span><span class="bbr"></span>
	</span>
</xsl:function>

<!-- FM 
	Issue  235: Block repeal: Where there has been a block repeal (e.g a whole Part repeal as in 1975 c.30 Part II) instead of the 'no longer effect' styling can the 
	sectoins be presented as (e.g 21. ............................................) . 
	At section level only the section number with the dots should be displayed along with an annotation box that only shows the repeal annottaion, pulled in from the parent. 
	When viewed at higher levels (e.g Part, cross heading, chapter, act levels) the sections within that level should be brought back as abover with just number and dotted lines. 
	No annotations needed under each section as the repel annotation will be in the part annotation.
-->
<!-- displaying P1group/title as dotted line if the section is repealed.  -->
<xsl:template match="leg:P1group[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]/leg:Title" priority="60">
	<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>
</xsl:template>

<!-- hiding P1, P if any of the ancestors are repealed -->
<xsl:template match="leg:P[exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))])]" priority="60"/>
<xsl:template match="leg:P1[parent::leg:P1group and exists(ancestor::*[@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))])]" priority="50"/>

<!-- process only the first descendant line of elements from P1s that are repealed -->
<xsl:template match="leg:P1[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]//*" priority="70">
	<xsl:if test="not(preceding-sibling::leg:*) or preceding-sibling::*[1][self::leg:Pnumber]">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<!-- process text within P1s that are repealed -->
<xsl:template match="leg:P1[not(ancestor::leg:BlockAmendment) and @Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))]//text()" priority="70">
	<xsl:choose>
		<xsl:when test="ancestor::leg:Pnumber/parent::leg:P1[not(ancestor::leg:BlockAmendment)]">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="provision" as="element(leg:P1)" select="ancestor::leg:P1[not(ancestor::leg:BlockAmendment)][1]" />
			<xsl:variable name="firstText" as="text()?" select="(($provision//leg:Text)[1]//text())[1]" />
			<xsl:if test=". is $firstText">
				<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--Every child that's repealed has @Match = 'false' and @RestrictEndDate not @Status = 'Prospective': -->
<!--Chunyu HA049670 Changed priority from 50 to 51 since it conflicts with the template of line 955 see nisi/2007/1351 part -->
<xsl:template match="leg:Division | leg:Part | leg:Body | leg:EUBody | leg:Schedules | leg:Pblock | leg:PsubBlock | leg:ExplanatoryNotes | leg:SignedSection" priority="51">
	<xsl:variable name="isWholeActView" select="./root()/leg:Legislation/@DocumentURI = $dcIdentifier"/>
	<xsl:variable name="isBodyView" select="matches($dcIdentifier, '/body')"/>
	<xsl:variable name="isSchedulesView" select="matches($dcIdentifier, '/schedules|/annexes')"/>
	<xsl:variable name="isSignatureView" select="matches($dcIdentifier, '/signature')"/>
	<xsl:variable name="documentURI" select="@DocumentURI"/>
	<xsl:variable name="repealedText" select="if ($isWholeActView) then 'act\s+(repeal|revoked|omitted)' else '(repeal|revoked|omitted)'"/>
	<xsl:variable name="commentary" as="xs:string*" 
			select="if ($isWholeActView) then 
						./root()//(leg:EUPrelims|leg:PrimaryPrelims|leg:SecondaryPrelims)//leg:CommentaryRef/@Ref
					else if ($isBodyView or $isSchedulesView) then 
						./root()//(leg:EURetained | leg:Primary|leg:Secondary)/leg:CommentaryRef/@Ref
					else leg:CommentaryRef/@Ref|(leg:Number|leg:Title)/leg:CommentaryRef/@Ref"/>
	<xsl:variable name="isRepealedStatus" select="@Status = 'Repealed'"/>
	<xsl:variable name="isRepealed" select="(every $child in (leg:* except (leg:Number, leg:Title)) satisfies 
					(
						(
							($child/@Match = 'false' and $child/@RestrictEndDate) and 
							not($child/@Status = 'Prospective') and
							(
								(
									($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) 
								) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() )
							)
						) 
					 or ($child/@Match = 'false' and $child/@Status = 'Repealed')
					 or (self::leg:Division and (($child/self::leg:P[not(@id)] and $isRepealedStatus) or ($child/@Match = 'false' and $child/@Status = 'Repealed')))
				   or (
				  (:  allowance for prosp repeals made by EPP  :)
						$child/@Match = 'false' and matches($child/@Status, 'prospective|repealed', 'i') and 
						(some $text in $commentary satisfies matches(string(/leg:Legislation/leg:Commentaries/leg:Commentary[@id = $text][1]), $repealedText, 'i')
						)  and 
						(exists($child//leg:Text) or exists($child//xhtml:td)) and 
						(every $text in ($child//leg:Text | $child//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = '')
						)
					)
				) or 
				(	(:  the explanatory notes do not appear to always have an enddate or status attribute so we must infer the repeal  :)
					self::leg:ExplanatoryNotes and (
					every $child in (leg:* except (leg:Number, leg:Title)) satisfies
					(exists($child//leg:Text) or exists($child//xhtml:td)) and 
					(every $text in ($child//leg:Text | $child//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = ''))
				)"/>
	
					
	<xsl:choose>
		<xsl:when test="$isWholeActView and $isRepealedAct and $isRepealed">
			
		</xsl:when>
		<xsl:when test="$isSignatureView and (self::leg:Body or self::leg:EUBody)">
			<xsl:apply-templates/>
		</xsl:when>
		<xsl:when test="($documentURI = ($dcIdentifier) or $isSchedulesView or $isBodyView) and $isRepealed">
			<xsl:call-template name="FuncProcessRepealedMajorHeading" />
			<p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="FuncProcessRepealedMajorHeading">
	<xsl:if test="self::leg:Group | self::leg:Part | self::leg:Chapter | self::leg:Schedule">
		<xsl:call-template name="FuncCheckForIDelement"/>
	</xsl:if>
	<xsl:if test="not(preceding-sibling::*[1][self::leg:Title or self::leg:Number]) and not(self::leg:Form)">
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)">
				<div class="LegClear{name()}First"/>
			</xsl:when>
			<xsl:otherwise>
				<div class="LegClear{name()}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<xsl:if test="leg:Reference and not(contains($g_strDocumentMainType, 'ScottishAct'))">
		<p class="LegArticleRef">
			<xsl:for-each select="leg:Reference">
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:apply-templates/>
			</xsl:for-each>
		</p>
	</xsl:if>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:attribute name="class">
			<xsl:text>Leg</xsl:text>
			<!-- For Scottish PGAs all schedule headings are the same in schedules as in the body but are not necessariliy the same for other types -->
			<xsl:if test="ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule']] and $g_strDocumentType = $g_strPrimary and not(name() = 'Schedule') and not(contains($g_strDocumentMainType, 'ScottishAct'))">
				<xsl:text>Schedule</xsl:text>
			</xsl:if>
			<xsl:value-of select="name()"/>
			<xsl:if test="preceding-sibling::*[1][self::leg:Title or self::leg:Number] or not(preceding-sibling::*)">
				<xsl:text>First</xsl:text>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates select="leg:Number | leg:Title | leg:TitleBlock | processing-instruction()[following-sibling::leg:Number or following-sibling::leg:Title or following-sibling::leg:TitleBlock or following-sibling::leg:Reference]"/>
	</xsl:element>
	<xsl:if test="leg:Reference and contains($g_strDocumentMainType, 'ScottishAct')">
		<!-- Generate suffix to be added for CSS classes for amendments -->
		<xsl:variable name="strAmendmentSuffix">
			<xsl:call-template name="FuncCalcAmendmentNo"/>
		</xsl:variable>
		<p>
			<xsl:attribute name="class">
				<xsl:text>LegArticleRefScottish</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:text> Leg</xsl:text>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:for-each select="leg:Reference">
				<xsl:call-template name="FuncCheckForID"/>
				<xsl:apply-templates/>
			</xsl:for-each>
		</p>
	</xsl:if>
</xsl:template>

<!--For schedules you have to look inside the ScheduleBody: -->
<xsl:template match="leg:Schedule" priority="50">
	<xsl:variable name="documentURI" select="@DocumentURI"/>
	<xsl:variable name="commentary" as="xs:string*" select="leg:CommentaryRef/@Ref|(leg:Number|leg:Title)/leg:CommentaryRef/@Ref"/>
	<xsl:choose>
		<xsl:when test="$documentURI = ($dcIdentifier) and (@Match = 'false' and @RestrictEndDate and not(@Status = 'Prospective') and
				   ((($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictEndDate) &lt;= current-date() ))) or (every $child in (leg:ScheduleBody/*)
		  satisfies (($child/@Match = 'false' and $child/@RestrictEndDate and not($child/@Status = 'Prospective')) and
				   ((($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= xs:date($version) ) or (not($version castable as xs:date) and xs:date($child/@RestrictEndDate) &lt;= current-date() ))) or ($child/@Match = 'false' and $child/@Status = 'Repealed')
				   or (
				   (some $text in $commentary satisfies matches(string(/leg:Legislation/leg:Commentaries/leg:Commentary[@id = $text]), 'repeal|omitted|revoked', 'i')) and (exists(.//leg:Text) or exists(.//xhtml:td)) and (every $text in (.//leg:Text | .//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = '')
				   ))
				   ">
			<p class="LegArticleRef">
				<xsl:for-each select="leg:Reference">
					<xsl:call-template name="FuncCheckForID"/>
					<xsl:apply-templates/>
				</xsl:for-each>
			</p>		  
			 <h2 class="LegScheduleFirst">
				<xsl:apply-templates select="leg:Number | leg:TitleBlock" />
			</h2>
			<p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
			<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--<xsl:template match="*[@Match = 'false' and not(@Status = 'Prospective') and not(ancestor::leg:Contents)]" priority="50">
	<div class="LegBlockRepeal">
		<p class="LegClearFix LegBlockRepealHeading"><span>No longer has effect</span></p>
		<xsl:next-match />
	</div>
</xsl:template>-->

<xsl:template match="*[(@RestrictStartDate castable as xs:date) and @Match = 'false' and not(ancestor::leg:Contents) and ((($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date(@RestrictStartDate) &gt; current-date() ))]" priority="50">
	<xsl:param name="showingValidFromDate" tunnel="yes" as="xs:date?" select="()" />
	<xsl:choose>
		<xsl:when test="empty($showingValidFromDate) or xs:date(@RestrictStartDate) != $showingValidFromDate">
			<div class="LegBlockNotYetInForce">
				<p class="LegClearFix LegBlockNotYetInForceHeading"><span>Valid from <xsl:value-of select="format-date(xs:date(@RestrictStartDate), '[D01]/[M01]/[Y0001]')"/></span></p>
				<xsl:next-match>
					<xsl:with-param name="showingValidFromDate" tunnel="yes" select="xs:date(@RestrictStartDate)" />
				</xsl:next-match>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[not(ancestor::leg:Contents) and ((@Match = 'false' and @Status = 'Prospective') or (@Status = 'Dead' and $version castable as xs:date and xs:date(@RestrictEndDate) &gt; xs:date($version)))]" priority="60">
	<xsl:param name="showingProspective" tunnel="yes" as="xs:boolean" select="false()" />
	<xsl:variable name="documentURI" select="@DocumentURI"/>
	<xsl:variable name="commentary" as="xs:string*" select="leg:CommentaryRef/@Ref|(leg:Number|leg:Title)/leg:CommentaryRef/@Ref"/>
	<xsl:choose>
		<!-- do not display anything for repealed schedules when viewed from the whole legislation  -->
		<xsl:when test="self::leg:Schedules and (preceding-sibling::leg:Body or preceding-sibling::leg:EUBody) and not(matches($dcIdentifier, 'schedules$')) and $isRepealedAct and (exists(.//leg:Text) or exists(.//xhtml:td)) and (every $text in (.//leg:Text | .//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = '')">
		
		</xsl:when>
		<xsl:when test="not($showingProspective)">
			<div class="LegBlockNotYetInForce">
				<p class="LegClearFix LegBlockNotYetInForceHeading"><span>Prospective</span></p>
				<xsl:choose>
					<xsl:when test="$documentURI = ($dcIdentifier) and (self::leg:Part or self::leg:Pblock or self::leg:Schedule) and (some $text in $commentary satisfies matches(string(/leg:Legislation/leg:Commentaries/leg:Commentary[@id = $text]), 'repeal|omitted|revoked', 'i')) and (exists(.//leg:Text) or exists(.//xhtml:td)) and (every $text in (.//leg:Text | .//xhtml:td) satisfies normalize-space(replace($text, '[\.\s]' , '')) = '')">
						<xsl:call-template name="FuncProcessRepealedMajorHeading" />
						<p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
						<xsl:apply-templates select="." mode="ProcessAnnotations"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:next-match>
							<xsl:with-param name="showingProspective" tunnel="yes" select="true()" />
						</xsl:next-match>
					</xsl:otherwise>
				</xsl:choose>
				
			</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P1[@NotesURI] | leg:Schedule[@NotesURI] | leg:Part[@NotesURI]" mode="showEN">
	<xsl:variable name="enType" 
		select="if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href) then 'notes'
					else if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href) then 'executive-notes'
					else if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc' and not(@hreflang = 'cy')]/@href) then 'policy-notes'
					else if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href) then 'memorandum'
					else '' "/>
		
	<xsl:if test="$enType != ''">
		<div class="eniw">
			<span class="enNote">
				<xsl:value-of select="if ($enType = 'executive-notes') then 'Executive Note' 
											   else if ($enType = 'policy-notes') then 'Policy Notes'
											   else if ($enType = 'memorandum') then 'Explanatory Memorandum' 
											   else 'Explanatory Notes'"/>
			</span>
			<a class="LegDS noteLink" href="{substring-after(@NotesURI, 'http://www.legislation.gov.uk')}">
				<xsl:text>Show </xsl:text>
				<xsl:value-of select="if ($enType = 'executive-notes') then 'EN' 
											   else if ($enType = 'policy-notes') then 'PN'
											   else if ($enType = 'memorandum') then 'EM' 
											   else 'EN'"/>
			</a>
		</div>		
	</xsl:if>
</xsl:template>

<xsl:template match="leg:P1 | leg:Schedule" mode="showEN">
	<xsl:if test=". is $selectedSection or parent::leg:P1group is $selectedSection">
		<xsl:variable name="enType" 
			select="if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href) then 'notes'
						else if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href) then 'executive-notes'
						else if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc' and not(@hreflang = 'cy')]/@href) then 'policy-notes'
						else if (/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href) then 'memorandum'
						else '' "/>
			
		<xsl:if test="$enType != ''">
			<div class="eniw">
				<span class="enNote">
					<xsl:text>This </xsl:text>
					<xsl:value-of select="if (self::leg:P1) then 'section' else 'schedule'" />
					<xsl:text> has no associated </xsl:text>
					<xsl:value-of select="if ($enType = 'executive-notes') then 'Executive Note' 
												  else if ($enType = 'policy-notes') then 'Policy Notes'
												   else if ($enType = 'memorandum') then 'Explanatory Memorandum' 
												   else 'Explanatory Notes'"/>
				</span>
			</div>		
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:P1 | leg:Schedule" mode="showTextualEffects">
	<xsl:if test="$showTextualEffects and not(ancestor::leg:BlockAmendment)">
		<div class="interweave effects textualEffects">
			<span class="title">
				<xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" />
				<xsl:text> textual effects from this </xsl:text>
				<xsl:value-of select="if (self::leg:P1) then 'section' else 'schedule'" />
			</span>
			<a class="LegDS showHide" href="/changes/affecting/{substring-after(@IdURI, 'http://www.legislation.gov.uk/id/')}?type=textual">
				<xsl:text>Show</xsl:text>
			</a>
			<div class="content">
				<xsl:if test="$supportParticipation">
					<p class="effect">
						<form action="/changes" method="post">
							<input type="hidden" name="task" value="{replace(/leg:Legislation/@IdURI, '/id/', '/task/researching-effects/')}" />
							<input type="hidden" name="effect-type" value="http://www.legislation.gov.uk/def/legislation/TextualAmendment" />
							<input type="hidden" name="affecting-legislation" value="{/leg:Legislation/@IdURI}" />
							<label for="affecting-provision-textual-{generate-id()}"><span class="accessibleText">Operative provision </span></label>
							<select id="affecting-provision-textual-{generate-id()}" name="affecting-provision">
								<xsl:for-each select="descendant-or-self::*[@id and @IdURI]">
									<option value="{@IdURI}">
										<xsl:value-of select="tso:formatSection(@id, '-')" />
									</option>
								</xsl:for-each>
							</select>
							<label for="affected-legislation-label-textual-{generate-id()}"> affects legislation </label>
							<input id="affected-legislation-label-textual-{generate-id()}" name="affected-legislation-label" 
								class="autocomplete legislation" 
								data-autocomplete="/legislation/data.json" />
							<input name="affected-legislation" />
							<label for="affected-provision-label-textual-{generate-id()}"> provisions </label>
							<input id="affected-provision-label-textual-{generate-id()}" name="affected-provision-label" class="autocomplete provision" />
							<button name="action" class="userFunctionalElement" type="submit" value="create">Create</button>
						</form>
					</p>
				</xsl:if>
			</div>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:P1 | leg:Schedule" mode="showCommencementEffects">
	<xsl:if test="$showCommencementEffects and not(ancestor::leg:BlockAmendment)">
		<div class="interweave effects commencementEffects">
			<span class="title">
				<xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" />
				<xsl:text> commencements from this </xsl:text>
				<xsl:value-of select="if (self::leg:P1) then 'section' else 'schedule'" />
			</span>
			<a class="LegDS showHide" href="/changes/affecting/{substring-after(@IdURI, 'http://www.legislation.gov.uk/id/')}?type=commencement">
				<xsl:text>Show</xsl:text>
			</a>
			<div class="content">
				<xsl:if test="$supportParticipation">
					<p class="effect">
						<form action="/changes" method="post">
							<input type="hidden" name="task" value="{replace(/leg:Legislation/@IdURI, '/id/', '/task/researching-commencement/')}" />
							<input type="hidden" name="effect-type" value="http://www.legislation.gov.uk/def/legislation/Commencement" />
							<input type="hidden" name="affecting-legislation" value="{/leg:Legislation/@IdURI}" />
							<label for="affecting-provision-commencement-{generate-id()}"><span class="accessibleText">Provision </span></label>
							<select id="affecting-provision-commencement-{generate-id()}" name="affecting-provision">
								<xsl:for-each select="descendant-or-self::*[@id and @IdURI]">
									<option value="{@IdURI}">
										<xsl:value-of select="tso:formatSection(@id, '-')" />
									</option>
								</xsl:for-each>
							</select>
							<label for="affected-legislation-label-commencement-{generate-id()}"> commences legislation </label>
							<input id="affected-legislation-label-commencement-{generate-id()}" name="affected-legislation-label" 
								class="autocomplete legislation" data-autocomplete="/legislation/data.json" />
							<input name="affected-legislation" />
							<label for="affected-provision-label-commencement-{generate-id()}"> provisions </label>
							<input id="affected-provision-label-commencement-{generate-id()}" name="affected-provision-label" class="autocomplete provision" />
							<label for="commencement-{generate-id()}"> on </label>
							<input id="commencement-{generate-id()}" name="commencement" class="datepicker" size="10" />
							<button name="action" class="userFunctionalElement" type="submit" value="create">Create</button>
						</form>
					</p>
				</xsl:if>
			</div>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:P1 | leg:Schedule" mode="showExtentEffects">
	<xsl:if test="$showExtentEffects and not(ancestor::leg:BlockAmendment)">
		<div class="interweave effects extentEffects geoExtShowing">
			<span class="title">
				<xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" />
				<xsl:text> extent information from this </xsl:text>
				<xsl:value-of select="if (self::leg:P1) then 'section' else 'schedule'" />
			</span>
			<a class="LegDS showHide" href="/changes/affecting/{substring-after(@IdURI, 'http://www.legislation.gov.uk/id/')}?type=extent">
				<xsl:text>Show</xsl:text>
			</a>
			<div class="content">
				<xsl:if test="$supportParticipation">
					<p class="effect">
						<form action="/changes" method="post">
							<input type="hidden" name="task" value="{replace(/leg:Legislation/@IdURI, '/id/', '/task/researching-extent/')}" />
							<input type="hidden" name="effect-type" value="http://www.legislation.gov.uk/def/legislation/ExtentAssignment" />
							<input type="hidden" name="affecting-legislation" value="{/leg:Legislation/@IdURI}" />
							<input type="hidden" name="affected-legislation" value="{/leg:Legislation/@IdURI}" />
							<label for="affecting-provision-extent-{generate-id()}"><span class="accessibleText">Provision </span></label>
							<select id="affecting-provision-extent-{generate-id()}" name="affecting-provision">
								<xsl:for-each select="descendant-or-self::*[@id and @IdURI]">
									<option value="{@IdURI}">
										<xsl:value-of select="tso:formatSection(@id, '-')" />
									</option>
								</xsl:for-each>
							</select>
							<label for="extent-{generate-id()}"> assigns the extent </label>
							<select id="extent-{generate-id()}" name="extent">
								<option value="http://www.legislation.gov.uk/def/legislation/UnitedKingdom">UK</option>
								<option value="http://www.legislation.gov.uk/def/legislation/GreatBritain">GB</option>
								<option value="http://www.legislation.gov.uk/def/legislation/EnglandAndWales">E+W</option>
								<option value="http://www.legislation.gov.uk/def/legislation/England">E</option>
								<option value="http://www.legislation.gov.uk/def/legislation/Wales">W</option>
								<option value="http://www.legislation.gov.uk/def/legislation/Scotland">S</option>
								<option value="http://www.legislation.gov.uk/def/legislation/NorthernIreland">N.I.</option>
							</select>
							<label for="affected-provision-label-extent-{generate-id()}"> to </label>
							<input id="affected-provision-label-extent-{generate-id()}" name="affected-provision-label" 
								class="autocomplete provision" 
								data-autocomplete="{substring-after(/leg:Legislation/@DocumentURI, 'http://www.legislation.gov.uk')}/section/data.json" />
							<button name="action" class="userFunctionalElement" type="submit" value="create">Create</button>
						</form>
					</p>
				</xsl:if>
			</div>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Schedule//leg:P1 | leg:Fragment/leg:Primary/leg:P1 | leg:Fragment/leg:Secondary/leg:P1 | leg:PrimaryPrelims | leg:SecondaryPrelims | leg:P1group | leg:P1[not(parent::leg:P1group)] | leg:Schedule/leg:ScheduleBody//leg:Tabular">
	<xsl:next-match/>
	<!-- If there are alternate versions outputting ot annotations will happen there -->
	<xsl:if test="not(@AltVersionRefs) and not(parent::leg:BlockAmendment)">
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:if>
</xsl:template>
	
<xsl:template name="FuncApplyVersions">
	<xsl:if test="@AltVersionRefs">
		<!-- Output annotations for default version -->
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
		<xsl:call-template name="FuncApplyVersion">
			<xsl:with-param name="strVersions" select="concat(normalize-space(@AltVersionRefs), ' ')"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template name="FuncApplyVersion">
	<xsl:param name="strVersions"/>
	
	<xsl:variable name="strVersion" select="normalize-space(substring-before(concat($strVersions, ' '), ' '))"/>
	<!-- We are going to create a copy of the XML but put the versioned XML into the same place as the original version -->
	<xsl:apply-templates select="$g_ndsVersions[@id = $strVersion]" mode="VersionNormalisationContext">
		<xsl:with-param name="itemToReplace" select="."/>
		<xsl:with-param name="strVersion" select="@RestrictExtent, $strVersion"/>
	</xsl:apply-templates>
	
	<xsl:variable name="strRemainingVersions" select="normalize-space(substring-after($strVersions, $strVersion))"/>
	<xsl:if test="$strRemainingVersions != ''">
		<xsl:call-template name="FuncApplyVersion">
			<xsl:with-param name="strVersions" select="$strRemainingVersions"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Version" mode="VersionNormalisationContext">
	<xsl:param name="itemToReplace" as="element()"/>
	<xsl:param name="strVersion"/>

	<xsl:variable name="ndsVersionToUse" select="."/>	
	<!-- Generate a document that is the correct context -->
	<xsl:variable name="rtfNormalisedDoc">
		<xsl:for-each select="$g_ndsMainDoc">
			<xsl:apply-templates mode="VersionNormalisation">
				<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
				<xsl:with-param name="itemToReplace" select="$itemToReplace"/>
				<xsl:with-param name="strVersion" select="$strVersion"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:for-each select="$rtfNormalisedDoc">
		<xsl:apply-templates select="//*[@VersionReplacement = 'True']"/>
	</xsl:for-each>
	
</xsl:template>	
	
<xsl:template match="*" mode="VersionNormalisation">
	<xsl:param name="ndsVersionToUse"/>
	<xsl:param name="itemToReplace" as="element()"/>
	<xsl:param name="strVersion"/>
	<xsl:choose>
		<xsl:when test=". >> $itemToReplace">
			<xsl:copy-of select="."/>
		</xsl:when>
		<xsl:when test="not(some $i in descendant-or-self::* satisfies $i is $itemToReplace)">
			<xsl:copy-of select="."/>
		</xsl:when>
		<xsl:when test=". is $itemToReplace">
			<xsl:for-each select="$ndsVersionToUse/*">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<!--We will use a VersionReplacement attribute to identify the substituted content -->
					<xsl:attribute name="VersionReplacement">True</xsl:attribute>
					<xsl:attribute name="VersionReference" select="$strVersion"/>
					<xsl:if test="not(@xml:lang) and $ndsVersionToUse/@Language">
						<xsl:attribute name="xml:lang">
							<xsl:for-each select="$ndsVersionToUse">
								<xsl:choose>
									<xsl:when test="@Language = 'French'">fr</xsl:when>
									<!-- Need to add more languages here -->
								</xsl:choose>						
							</xsl:for-each>
						</xsl:attribute>
					</xsl:if>
					<xsl:copy-of select="node()"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates mode="VersionNormalisation">
					<xsl:with-param name="ndsVersionToUse" select="$ndsVersionToUse"/>
					<xsl:with-param name="itemToReplace" select="$itemToReplace"/>
					<xsl:with-param name="strVersion" select="$strVersion"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" priority="0.25">
	<xsl:choose>
		<xsl:when test="ancestor::leg:BlockAmendment">
			<span class="LegAmendingText">
				<xsl:next-match/>
			</span>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="following::*[1][self::leg:BlockAmendment[@CitationListRef]]" mode="CitationListRef"/>
</xsl:template>

<xsl:template match="leg:Commentary" mode="DisplayAnnotations">
	<xsl:param name="versionRef"/>
	<div class="LegCommentaryItem" id="commentary-{@id}{translate($versionRef,' ','')}">
		<xsl:apply-templates select="leg:Para" mode="DisplayAnnotations" >
				<xsl:with-param name="versionRef" select="$versionRef"/>
			</xsl:apply-templates>
	</div>
</xsl:template>

<xsl:template match="leg:Commentary/leg:Para" mode="DisplayAnnotations">
	<xsl:param name="versionRef"/>
	<p class="LegCommentaryPara">
		<xsl:if test="position() = 1">
			<span class="LegCommentaryType">
				<!-- we need to reference the document order of the commentaries rather than the commentary order in order to gain the correct numbering sequence -->
				<xsl:variable name="thisId" select="parent::leg:Commentary/@id"/>
				<xsl:variable name="thisType" select="parent::leg:Commentary/@Type"/>
				<xsl:variable name="strType" as="xs:string"
					select="concat(../@Type, count($g_commentaryOrder/leg:commentary[@id = $thisId][1]/preceding-sibling::*[@Type = $thisType]) + 1)" />
				
				
				<!--<xsl:variable name="strType" as="xs:string"
					select="concat(../@Type, count(../preceding-sibling::leg:Commentary[@Type = current()/../@Type]) + 1)" />-->
				<xsl:choose>
					<xsl:when test="../@Type = ('F', 'M', 'X')">
						<a href="#reference-{../@id}{translate($versionRef,' ','')}" title="Go back to reference for this commentary item">
							<xsl:value-of select="$strType" />
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$strType" />
					</xsl:otherwise>
				</xsl:choose>
			</span>
		</xsl:if>
		<xsl:apply-templates mode="DisplayAnnotations" />
	</p>
</xsl:template>

<xsl:template match="leg:Commentary/leg:Para/leg:Text" mode="DisplayAnnotations">
	<span class="LegCommentaryText">
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="leg:Citation">
	<xsl:variable name="uri">
		<xsl:value-of select="replace(./@URI,'&amp;','and')"/>
	</xsl:variable>	
	<a class="LegCitation" title="{if (@Title) then @Title else 'Go to item of legislation'}" rel="cite">
		<xsl:choose>
			<xsl:when test="@URI">
				<xsl:attribute name="href" select="$uri" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="href" select="concat('/', tso:GetUriPrefixFromType(@Class, @Year), '/', @Year, '/', @Number, if (@SectionRef) then concat('/', translate(@SectionRef, '-', '/')) else())" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</a>
</xsl:template>

<xsl:template match="leg:CitationSubRef[@URI and not(leg:CitationSubRef)]">
	<xsl:variable name="legislation" as="element(leg:Citation)?"
		select="key('citations', @CitationRef)[1]" />
	<xsl:variable name="title" as="xs:string"
		select="string-join(('Go to', if ($legislation/@Title) then $legislation/@Title else if ($legislation) then $legislation else (), .), ' ')" />
	<xsl:variable name="uri">
		<xsl:value-of select="replace(./@URI,'&amp;','and')"/>
		</xsl:variable>
	<a class="LegCitation" href="{$uri}" title="{$title}" rel="cite">
		<xsl:choose>
			<xsl:when test="@Operative = 'true'">
				<strong><xsl:apply-templates /></strong>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</a>
</xsl:template>

<xsl:template match="leg:BlockAmendment" mode="CitationListRef">
	<xsl:variable name="citationList" select="key('citationLists', @CitationListRef)" as="element(leg:CitationList)"/>
	<xsl:choose>
		<!-- If only one item go direct -->
		<xsl:when test="count($citationList/leg:Citation) = 1">
			<xsl:apply-templates select="$citationList/leg:Citation" mode="AffectedLegislation"/>
		</xsl:when>
		<xsl:otherwise>
			<a class="LegCitation" href="/{$uriPrefix}/{$legislationYear}/{$legislationNumber}{tso:IsStartDate(@StartDate)}/affected/{$citationList/@id}" title="Go to list of affected legislation" rel="cite">
				<img class="LegAffectedLink" src="/images/icon_linkto_affected_leg.gif" alt=""/>
			</a>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="leg:CitationListRef">
	<xsl:variable name="citationList" select="key('citationLists', @Ref)" as="element(leg:CitationList)"/>
	<xsl:choose>
		<!-- If only one item go direct -->
		<xsl:when test="count($citationList/leg:Citation) = 1">
			<xsl:apply-templates select="$citationList/leg:Citation" mode="AffectedLegislation"/>
		</xsl:when>
		<xsl:otherwise>
			<a class="LegCitation" href="/{$uriPrefix}/{$legislationYear}/{$legislationNumber}{tso:IsStartDate(@StartDate)}/affected/{$citationList/@id}" title="Go to list of affected legislation" rel="cite">
				<img class="LegAffectedLink" src="/images/icon_linkto_affected_leg.gif" alt=""/>
			</a>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="leg:Citation" mode="AffectedLegislation">
	<a class="LegCitation" href="/{tso:GetUriPrefixFromType(@Class, @Year)}/{@Year}/{@Number}{tso:IsStartDate(@StartDate)}#reference-{@CommentaryRef}" title="Go to affected legislation" rel="cite">
		<img class="LegAffectedLink" src="/images/icon_linkto_affected_leg.gif" alt=""/>
	</a>
</xsl:template>

<xsl:template match="leg:Term">
	<span class="LegTerm" id="{@id}">
		<xsl:apply-templates/>
	</span>
</xsl:template>
	
<xsl:key name="effects" match="ukm:Effect | ukm:UndefinedEffect" use="@Ref" />

<xsl:template match="leg:Span[key('effects',@id)]">
	<span class="LegEffect" id="{@id}">
		<xsl:apply-templates/>
	</span>
</xsl:template>	
	
<xsl:template match="leg:Text[leg:Span[key('effects',@id)]]" priority="1001">
	<xsl:next-match/>
	<xsl:apply-templates select="leg:Span[key('effects',@id)]"   mode="effect"/>
</xsl:template>		

<xsl:template match="leg:Span[key('effects',@id)]"  mode="effect">
	<xsl:variable name="effect" as="element()*" select="key('effects', @id)" />	
	<xsl:for-each select="$effect">
		<p class="LegEffectBox">
			<xsl:apply-templates select="." mode="effect"/>
		</p>
	</xsl:for-each>
</xsl:template>	


<xsl:function name="tso:IsStartDate" as="xs:string?">
	<xsl:param name="startDate"/>
	<xsl:if test="$startDate">
		<xsl:sequence select="concat('/', $startDate)"/>
	</xsl:if>
</xsl:function>

<!-- *** Text Processing Overrides *** -->

<xsl:template match="leg:Text" priority="1000">
	<xsl:next-match>
		<xsl:with-param name="nstLastTextNode" tunnel="yes" select="(.//text())[last()]" />
	</xsl:next-match>
</xsl:template>

<xsl:template match="leg:Text[following-sibling::*[1][self::leg:BlockAmendment][child::*[1][self::leg:Text]]]" priority="999">
	<xsl:next-match>
		<xsl:with-param name="nstRunOnAmendmentText" tunnel="yes" 
			select="if ($g_strDocumentType = $g_strPrimary or following-sibling::leg:BlockAmendment[1]/string(@PartialRefs) != '')
			        then following-sibling::leg:BlockAmendment[1]/leg:Text[1]
			        else ()" />
	</xsl:next-match>
</xsl:template>

<!-- JDC HA056626 http://www.legislation.gov.uk/uksi/2013/2005/regulation/2/made - paragraphs 8 and 9 -->			
<!-- If we are in an empty List Item/Paragraph/Text within a leg:BlockAmendment//leg:OrderedList, with a non-empty one before it, the quote needs to go here. -->
<xsl:template match="leg:BlockAmendment//leg:OrderedList/leg:ListItem[last()][preceding-sibling::*[self::leg:ListItem]/leg:Para/leg:Text != '']/leg:Para[last()]/leg:Text[. = ''] ">
	<xsl:call-template name="FuncOutputAmendmentEndQuote"/>
</xsl:template>

<!-- This catches the first leg:Text within a P1 that hasn't got a P1group parent and that has some extent restriction applied -->
<!--Chunyu HA049670 Added [last()] for P1 which has a scenario with two P1 see nisi/2007/1351 schedule 5 -->
<xsl:template match="*[not(self::leg:P1group)]/leg:P1[ancestor-or-self::*/@RestrictExtent]//leg:*[preceding-sibling::leg:*[1][self::leg:Pnumber]]/leg:Text[not(preceding-sibling::*) and not(ancestor::leg:BlockAmendment)][not($g_strDocumentType = $g_strEUretained)]">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="nstExtentMarker" select="tso:generateExtentInfo(ancestor::leg:P1[not(ancestor-or-self::leg:BlockAmendment)][last()])" />
	<!-- For primary legislation the indent of content is dependent upon its parent for amendments therefore we need more information if the parent is lower level than the content being amended -->
	<xsl:choose>
		<!-- N1 without a P1group -->
		<xsl:when test="parent::leg:P1para and $g_strDocumentType = $g_strPrimary">
			<!-- Calculate if in a primary schedule -->
			<xsl:variable name="strScheduleContext">
				<xsl:call-template name="FuncGetScheduleContext"/>
			</xsl:variable>
			<p class="LegClearFix {concat('Leg', $strScheduleContext, 'P1Container')} LegExtentContainer">
				<xsl:call-template name="FuncCheckForID"/>				
				<!-- For primary legislation ... -->
				<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
					<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
						<xsl:for-each select="..">
							<xsl:call-template name="FuncCheckForID"/>
						</xsl:for-each>
						<xsl:apply-templates select="."/>
					</xsl:for-each>
				</span>		
				<span class="Text">
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:call-template name="FuncGetTextClass"/>
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
				</span>
				<!-- eu legisaltion will add the extent info to the number -->
			</p>
		</xsl:when>
		<!-- Numbered paragraphs using hanging indent so we need to process them in a special manner -->
		<!-- For secondary legislation we need to make sure that we dont pick up N1-N3 or N1-N3-N4 (both very rare) -->
		<xsl:when test="parent::*[(self::leg:P2para and $g_strDocumentType = $g_strPrimary) 
			 or (self::leg:P1para and ancestor::leg:Schedule and $g_strDocumentType = $g_strPrimary)
			 or self::leg:P3para[not($g_strDocumentType = $g_strSecondary and parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber])]
			 or self::leg:P4para[not($g_strDocumentType = $g_strSecondary and parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]/parent::leg:P3[not(preceding-sibling::*)]/parent::leg:P1para/preceding-sibling::*[1][self::leg:Pnumber])]
			 or self::leg:P5para or self::leg:P6para or self::leg:P7para]">
			<!-- Calculate if in a primary schedule -->
			<xsl:variable name="strScheduleContext">
				<xsl:call-template name="FuncGetScheduleContext"/>
			</xsl:variable>
			<xsl:variable name="nstText">
				<span class="Text">
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:call-template name="FuncGetTextClass"/>
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
				</span>
			</xsl:variable>
			<xsl:variable name="strClass" select="concat('LegClearFix Leg', $strScheduleContext, name(parent::*/parent::*), 'Container')" />
			<!--<xsl:variable name="strScheduleNestedContext">
				<xsl:call-template name="FuncGetScheduleNestedAmendmentContext"/>
			</xsl:variable>-->
			<p>
				<xsl:call-template name="FuncCheckForID"/>				
				<xsl:choose>
					<!-- Combined N3-N4 paragraph -->
					<xsl:when test="parent::leg:P4para/parent::leg:P4[not(preceding-sibling::*)]/parent::leg:P3para/preceding-sibling::*[1][self::leg:Pnumber]">
						<xsl:attribute name="class" select="$strClass" />
						<span class="LegDS LegLHS {concat('LegN3No', $strAmendmentSuffix)}">
							<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<span class="LegDS LegLHS LegN4No">
							<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<xsl:sequence select="$nstText" />
					</xsl:when>
					<!-- Combined N4-N5 paragraph -->
					<xsl:when test="parent::leg:P5para/parent::leg:P5[not(preceding-sibling::*)]/parent::leg:P4para/preceding-sibling::*[1][self::leg:Pnumber]">
						<xsl:attribute name="class" select="$strClass" />
						<span class="LegDS LegLHS {concat('LegN4N5No', $strAmendmentSuffix)}">
							<xsl:for-each select="parent::*/parent::*/parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<span class="LegDS LegLHS LegN5No">
							<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
								<xsl:for-each select="..">
									<xsl:call-template name="FuncCheckForID"/>
								</xsl:for-each>
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</span>
						<xsl:sequence select="$nstText" />
					</xsl:when>
					<xsl:otherwise>
						<!-- For primary legislation ... -->
						<!-- If in a schedule and a combined N1-N2 then output N1 number. -->
						<!-- If context is unknown and BlockAmendment does not contain P1group then assume it is a schedule amendment as an amendment to a P1 in the body does not make any sense or if TargetClass is secondary apply similar logic (as secondary gets formatted like primary) -->
						<!-- Also if the below functionality has been invoked then handle that too -->
						<xsl:choose>					
							<xsl:when test="$g_strDocumentType = $g_strPrimary and 
								parent::leg:P2para and 
								generate-id(ancestor::leg:P1[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber or ancestor::leg:Title)][1]) = generate-id(descendant::text()[not(normalize-space(.) = '')][1]) and
								generate-id(ancestor::leg:P2[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber)][1]) = generate-id(descendant::text()[not(normalize-space(.) = '')][1])">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegSN1No', $strAmendmentSuffix)}">
									<xsl:for-each select="ancestor::leg:P1[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>									
								</span>
								<span class="LegDS {concat('LegSN2No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<!-- P2-P3 -->
							<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P3para[ancestor::leg:P2para] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber or ancestor::leg:Title)]  or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]))) and
							generate-id(ancestor::leg:P2[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P3group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
							generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1])">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegP2No', $strAmendmentSuffix)}">
									<xsl:for-each select="ancestor::leg:P2[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>									
								</span>
								<span class="LegDS {concat('LegSN1N3No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<!-- P1-P3 -->
							<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P3para[not(ancestor::leg:P2para)] and (ancestor::*[self::leg:Schedule or self::leg:BlockAmendment][1][self::leg:Schedule or self::leg:BlockAmendment[@Context = 'schedule' or ((@Context = 'unknown' or @TargetClass = 'secondary') and not(descendant::leg:P1group))]] or (ancestor::leg:P1group/@Layout = 'below' and generate-id(ancestor::leg:P1group[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber or ancestor::leg:Title)]  or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]))) and
							generate-id(ancestor::leg:P1[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1] or ancestor::leg:Title/parent::leg:P3group)] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1]) and
							generate-id(ancestor::leg:P3[1]/descendant::node()[not(self::processing-instruction())][self::text()[not(normalize-space() = '' or ancestor::leg:Pnumber[1])] or self::leg:Emphasis or self::leg:Strong or self::leg:Superior or self::leg:Inferior or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:Citation or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:CommentaryRef or self::leg:CitationSubRef or self::math:math or self::leg:Character or self::leg:FootnoteRef or self::leg:Span or self::leg:Term or self::leg:Definition or self::leg:Proviso or self::leg:MarginNoteRef or self::leg:Underline or self::leg:SmallCaps][1]) = generate-id(node()[not(self::processing-instruction())][1])">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
									<xsl:for-each select="ancestor::leg:P1[1]">
										<xsl:call-template name="FuncCheckForID"/>
										<xsl:apply-templates select="leg:Pnumber"/>
									</xsl:for-each>									
								</span>
								<span class="LegDS {concat('LegSN1N3No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<!-- Special handling for P1 numbers in schedules in primary legislation -->
							<xsl:when test="$g_strDocumentType = $g_strPrimary and parent::leg:P1para">
								<xsl:attribute name="class" select="concat($strClass, ' LegExtentContainer')" />
								<span class="LegDS {concat('LegP1No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>		
								<xsl:sequence select="$nstText" />
								<xsl:sequence select="$nstExtentMarker" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class" select="$strClass" />
								<span class="LegDS LegLHS {concat('Leg', name(parent::*/parent::*), 'No', $strAmendmentSuffix)}">
									<xsl:for-each select="parent::*/preceding-sibling::leg:Pnumber">
										<xsl:for-each select="..">
											<xsl:call-template name="FuncCheckForID"/>
										</xsl:for-each>
										<xsl:apply-templates select="."/>
									</xsl:for-each>
								</span>
								<xsl:sequence select="$nstText" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="not(ancestor::leg:MarginNote)">
				<xsl:variable name="blnShowExtent"
					select="generate-id(ancestor::leg:P1[1]/descendant::text()[not(normalize-space(.) = '' or ancestor::leg:Pnumber or ancestor::leg:Title)][1]) = generate-id(descendant::text()[1][not(normalize-space(.) = '')][1]) and not($g_strDocumentType = ($g_strEUretained))" />
				<xsl:variable name="textClass" as="node()*">
					<xsl:call-template name="FuncGetTextClass">
						<xsl:with-param name="flMode" select="'Block'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="classAttribute" as="attribute(class)?" select="$textClass[. instance of attribute(class)]" />
				<!-- JT: Do not use $textClass except $classAttribute as this reorders the content! -->
				<xsl:variable name="content" select="$textClass[not(. is $classAttribute)]" />
				<p class="{if (exists($classAttribute)) then $classAttribute else concat('LegText', $strAmendmentSuffix)}{if ($blnShowExtent) then ' LegExtentContainer' else ''}">
					<xsl:for-each select="ancestor::leg:P1">
						<xsl:call-template name="FuncCheckForID"/>
					</xsl:for-each>
					<xsl:call-template name="FuncGetLocalTextStyle"/>
					<xsl:sequence select="$content" />
					<xsl:apply-templates select="node()[not(position() = 1 and self::text() and normalize-space() = '')] | processing-instruction()"/>
					<xsl:if test="$blnShowExtent">
						<xsl:sequence select="$nstExtentMarker" />
					</xsl:if>
				</p>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="FuncTextPostOperations">
	<xsl:param name="nstLastTextNode" as="text()?" tunnel="yes" select="(ancestor::leg:Text[1]//text())[last()]" />
	<xsl:param name="nstRunOnAmendmentText" as="element(leg:Text)?" tunnel="yes" select="()" />
	<!-- Output generated text around paragraph numbers -->
	<xsl:variable name="nstPnumber" as="element(leg:Pnumber)?"
		select="ancestor::leg:Pnumber" />
	<xsl:if test="exists($nstPnumber) and normalize-space(.) != ''">
		<xsl:choose>
			<xsl:when test="$nstPnumber/@PuncAfter">
				<xsl:value-of select="$nstPnumber/@PuncAfter" />
			</xsl:when>
			<xsl:when test="$nstPnumber/parent::leg:P1 and $g_strDocumentType = $g_strPrimary"/>
			<xsl:when test="$g_strDocumentType = $g_strEUretained"/>
			<xsl:when test="$nstPnumber/parent::leg:P1">.</xsl:when>
			<xsl:otherwise>)</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	
	<xsl:call-template name="FuncCheckForEndOfQuote"/>
	
	<!-- Check if  last node in a footnote in which case output back link if a standard footnote -->
	<!-- JT: In XML generated for SLS, there are no footnotes 
	<xsl:if test="not(ancestor::leg:Citation or ancestor::leg:CitationSubRef or ancestor::leg:InternalLink or ancestor::leg:ExternalLink or ancestor::leg:Acronym or ancestor::leg:Abbreviation or ancestor::leg:Definition or ancestor::leg:Proviso or ancestor::leg:Superior or ancestor::leg:Inferior or ancestor::leg:SmallCaps or ancestor::leg:Underline) and ancestor::leg:Footnote[not(ancestor::xhtml:table)] and generate-id(ancestor::leg:Footnote[1]/descendant::text()[not(normalize-space() = '')][last()]) = generate-id()">
		<xsl:call-template name="FuncCheckForBackReference"/>
	</xsl:if>
	-->
	
	<!-- For primary legislation some amendments run on from the prevoius paragraph. Also allow it for very rare instances of secondary legislation where PartialRefs forces it -->
	<xsl:if test="exists($nstRunOnAmendmentText) and $nstLastTextNode is .">
		<xsl:text> </xsl:text>
		<span class="LegRunOnAmendment">
			<xsl:apply-templates select="$nstRunOnAmendmentText/(node() | processing-instruction())" />
		</span>
	</xsl:if>
	
</xsl:template>

<xsl:template match="*[@xml:lang != 'en']" priority="1000">
	<xsl:next-match>
		<xsl:with-param name="strLanguage" tunnel="yes" select="@xml:lang" />
	</xsl:next-match>
</xsl:template>

<!-- JDC - HA058520 - need to display Pnumber and AppendText in the following scenario - P3/P3Para within a BlockAmendment, with empty Text element, but with a populated Pnumber within the P3 and AppendText following the BlockAmendment, e.g. http://www.legislation.gov.uk/asp/2010/6/section/10/enacted, section 10(1)(a). -->
<xsl:template match="leg:P3para/leg:BlockAmendment[preceding-sibling::*[1][self::leg:Text and .!=''] and not(preceding-sibling::*[not(self::leg:Text)]) and following-sibling::*[1][self::leg:AppendText and .!=''] and not(following-sibling::*[not(self::leg:AppendText)])]/leg:P3/leg:P3para[preceding-sibling::*[1][self::leg:Pnumber and .!=''] and not(preceding-sibling::*[not(self::leg:Pnumber)]) and not (following-sibling::*)]/leg:Text[.='' and not(preceding-sibling::*) and not (following-sibling::*)]">	
	<p class="LegClearFix LegP3Container">	
		<span class="LegDS LegLHS LegP3NoC3Amend">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="../../leg:Pnumber"/>
			<xsl:text>)</xsl:text>
			<xsl:text>&#8221;</xsl:text>
		</span>
		<span class="LegDS LegRHS LegP3TextC3Amend">
			<span class="LegAmendingText">
				<xsl:value-of select="../../../../leg:AppendText"/>
			</span>
		</span>
	</p>
</xsl:template>

<xsl:template match="text()">
	<xsl:param name="strLanguage" tunnel="yes" select="'en'" />
	<xsl:call-template name="FuncTextPreOperations"/>
	<!-- Check if text node is in a language other than English -->
	<xsl:choose>
		<xsl:when test="$strLanguage != 'en'">
			<span lang="{$strLanguage}" xml:lang="{$strLanguage}">
				<!-- Check that if there are any characters that can not be rendered correctly.  If this is the case then these need to be replaced with corresponding images. -->
				<xsl:call-template name="FuncProcessTextForUnicodeChars">
					<xsl:with-param name="strText">
						<xsl:call-template name="FuncNormalizeSpace">
							<xsl:with-param name="strString" select="." />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</span>
		</xsl:when>
		<xsl:otherwise>
			<!-- Check that if there are any characters that can not be rendered correctly.  If this is the case then these need to be replaced with corresponding images. -->
			<xsl:call-template name="FuncProcessTextForUnicodeChars">
				<xsl:with-param name="strText">
					<xsl:call-template name="FuncNormalizeSpace">
						<xsl:with-param name="strString" select="." />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>		
		</xsl:otherwise>
	</xsl:choose>		
	<!-- JDC HA069475 - Don't do post ops here if text is within an "Emphasis" element, as they would also be output in italics. -->  
   <xsl:if test="not(parent::leg:Emphasis)">
      <xsl:call-template name="FuncTextPostOperations"/>
   </xsl:if>
</xsl:template>

<xsl:variable name="g_strUnicodeCharsRegex" as="xs:string">
	<xsl:value-of>
		(
		<xsl:value-of select="$g_ndsUnicodeCharsToConvert/@unicode" separator="|" />
		)
	</xsl:value-of>
</xsl:variable>
<xsl:key name="entities" match="entity" use="@unicode" />

<xsl:template name="FuncProcessTextForUnicodeChars">
	<xsl:param name="strText"/>
	<xsl:param name="ndsUnicodeCharsToConvert" select="$g_ndsUnicodeCharsToConvert" />
	<xsl:param name="strPathToImages" select="''"/>
	<xsl:choose>
		<xsl:when test="matches($strText, $g_strUnicodeCharsRegex, 'x')">
			<xsl:analyze-string select="$strText" regex="{$g_strUnicodeCharsRegex}" flags="x">
				<xsl:matching-substring>
					<xsl:variable name="ndsEntity" as="element(entity)"
						select="key('entities', ., $g_ndsUnicodeCharsDoc)" />
					<img class="LegUnicodeCharacter" 
						src="{$strPathToImages}{$ndsEntity/@image}" 
						alt="{$ndsEntity/@explanation}" 
						title="{$ndsEntity/@explanation}" 
						style="height: 1em;" />
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="." />
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$strText" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="FuncLegNotification">
	<xsl:if test="$paramsDoc/parameters/version != '' and $paramsDoc/parameters/version != $g_ndsMetadata/dct:valid">
		<p class="LegNotification">Please note that the date you requested in the address for this web page is not an actual date upon which a change occurred to this item of legislation. You are being shown the legislation from <xsl:value-of select="format-date($g_ndsMetadata/dc:valid, '[D10] [MNn] [Y]')"/>, which is the first date before then upon which a change was made.</p>
	</xsl:if>
</xsl:template>

<xsl:template match="leg:EUTitle/leg:Title">
	<span class="LegEUTitleTitle">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<xsl:template match="leg:EUTitle | leg:EUPart | leg:EUChapter | leg:EUSection | leg:EUSubsection | leg:Division[@Type = ('EUPart','EUChapter','EUSection','EUSubsection', 'ANNEX')] | leg:Division[leg:Title]"  priority="15">
	<xsl:variable name="element" select="if (@Type) then @Type else local-name()"/>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
		
	<xsl:if test="not(preceding-sibling::*[1][self::leg:Title or self::leg:Number]) and not(self::leg:Form) or parent::leg:Division[not(@Type)]">
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::*) and (parent::xhtml:td)">
			</xsl:when>
			<xsl:when test="not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)">
				<div class="LegClear{$element}First"/>
			</xsl:when>
			<xsl:otherwise>
				<div class="LegClear{$element}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<!--<div class="{concat('Leg', $element, if (not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)) then 'First' else (),'Divison')}">-->
		<a id="{@id}" class="LegAnchorID"/>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">
				<xsl:value-of select="concat('LegClearFix Leg', $element, if (not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)) then 'First' else (),$strAmendmentSuffix)"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Title | leg:Number"/>
		</xsl:element>
		<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Number)]"/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	<!--</div>-->
</xsl:template>

<!-- this is a very specific template to handle cases where we have a numbered paragraph marked up as a division -->
<xsl:template match="leg:Division[leg:Number][not(leg:Title)][empty(@Type) or @Type = 'Annotation']" priority="20">
	<xsl:variable name="element" select="if (@Type) then @Type else local-name()"/>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="extentcontainer" select="if (self::leg:Division[not(@Type = ('EUPart','EUChapter','EUSection','EUSubsection', 'ANNEX'))]) then
								' LegExtentContainer' else ()"/>
	<xsl:if test="not(preceding-sibling::*[1][self::leg:Title or self::leg:Number]) and not(self::leg:Form) or parent::leg:Division[not(@Type)]">
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::*) and (parent::xhtml:td)">
			</xsl:when>
			<xsl:when test="not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)">
				<div class="LegClear{$element}First"/>
			</xsl:when>
			<xsl:otherwise>
				<div class="LegClear{$element}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
		<a id="{@id}" class="LegAnchorID"/>
		<xsl:element name="h{$intHeadingLevel}">
			<xsl:attribute name="class">
				<xsl:value-of select="concat('LegClearFix Leg', $element, if (not(preceding-sibling::*) and (parent::leg:ScheduleBody or parent::leg:AppendixBody)) then 'First' else (),$strAmendmentSuffix, $extentcontainer)"/>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Number"/>
			<xsl:apply-templates select="leg:Number/following-sibling::*[1]" mode="numberedpara"/>
		</xsl:element>
		<xsl:apply-templates select="*[not(self::leg:Number)][self::*[not(preceding-sibling::*[1][self::leg:Number])]]"/>
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
</xsl:template>

<xsl:template match="leg:EUPart/leg:Number | leg:EUChapter/leg:Number | leg:EUSection/leg:Number | leg:EUSubsection/leg:Number  | leg:EUTitle/leg:Number">
	<xsl:variable name="element" select="parent::*/local-name()"/>
	<xsl:call-template name="FuncGenerateMajorHeadingNumber">
		<xsl:with-param name="strHeading" select="$element"/>
	</xsl:call-template>
</xsl:template>

<xsl:template match="leg:Division/leg:Number">
	<xsl:variable name="contentcount" select="string-length(normalize-space(string-join((.//text()), '')))"/>
	<!-- In certain annexes ie 2014 No 254 the number is a name and is too long for formatting in the left column
		This is therefore resolved in the EU PDFs as blocked  content therefore a special rule is required-->
	<xsl:variable name="element" select="if (parent::*/@Type) then parent::*/ @Type
		else if (parent::leg:Division[not(@type)] and ancestor::leg:Schedule and $contentcount gt 8) then 'ScheduleSection'
		else parent::*/local-name()"/>
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!-- we need to deduce whether the division inidcates a high level or a provision level from the type -->
	<xsl:choose>
		<xsl:when test="$element = ('EUPart', 'EUTitle', 'EUChapter', 'EUSection', 'EUSubsectioin')">
			<xsl:call-template name="FuncGenerateMajorHeadingNumber">
				<xsl:with-param name="strHeading" select="$element"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<span class="Leg{$element}No{$strAmendmentSuffix}">
				<xsl:apply-templates/>
			</span>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:EUPart/leg:Title | leg:EUChapter/leg:Title | leg:EUSection/leg:Title | leg:EUSubsection/leg:Title |  leg:Division/leg:Title">
	<xsl:variable name="contentcount" select="string-length(normalize-space(string-join((parent::*/leg:Number//text()), '')))"/>
	<xsl:variable name="element" select="if (parent::*/@Type) then parent::*/ @Type 
		else if (parent::leg:Division[not(@type)] and ancestor::leg:Schedule and $contentcount gt 8) then 'ScheduleSection'
		else parent::*/local-name()"/>
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<span class="Leg{$element}Title{$strAmendmentSuffix}">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<xsl:template match="leg:P" mode="numberedpara">
	<xsl:variable name="element" select="if (parent::*/@Type) then parent::*/ @Type else parent::*/local-name()"/>
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<!--<span class="LegDivisionText{$strAmendmentSuffix}">
		<xsl:apply-templates select="leg:Text/node()"/>
	</span>
	<xsl:sequence select="tso:generateExtentInfo(ancestor::*[@RestrictExtent][1])"/>-->
	<span class="Leg{$element}Title{if (not(parent::*/leg:Number)) then 'NoNumber' else ()}{$strAmendmentSuffix}">
		<xsl:apply-templates select="leg:Text/node()"/>
	</span>
</xsl:template>


<xsl:template match="leg:P1[not(parent::leg:P1group)][$g_strDocumentType = ($g_strEUretained)]" priority="10">
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:variable name="intHeadingLevel">
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:variable name="nstContent" as="node()*">
		<xsl:copy-of select="if (ancestor::leg:BlockAmendment) then () else tso:generateExtentInfo(.)"/>
	</xsl:variable>
	<xsl:for-each select="leg:Pnumber">
		<xsl:call-template name="FuncCheckForIDelement"/>
	</xsl:for-each>
	<xsl:element name="h{$intHeadingLevel}">
		<xsl:variable name="strContext">
			<xsl:call-template name="FuncGetContext"/>
		</xsl:variable>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="parent::leg:BlockAmendment and not(preceding-sibling::*) or ($g_strDocumentType = ($g_strPrimary, $g_strEUretained) and preceding-sibling::*[1][self::leg:Title])">
					<xsl:text>LegClearFix LegP1ContainerFirst</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>LegClearFix LegP1Container</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="FuncGetScheduleContext"/>
			<xsl:if test="$strAmendmentSuffix != '' and $g_strDocumentType = $g_strSecondary">
				<!-- We want a single class for primary due to the handling indent and multiple classes for secondary -->
				<xsl:if test="$strContext = $g_strSecondary">
					<xsl:text> Leg</xsl:text>
				</xsl:if>
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
			<!-- Output an anchor for contents linking. Do here to avoid problem of anchor not clearing floats -->
			<!--<xsl:call-template name="FuncCheckForIDelement"/>-->
		<span>
			<xsl:attribute name="class">
				<xsl:text>LegDS LegP1No</xsl:text>
				<xsl:if test="$strAmendmentSuffix != ''">
					<xsl:if test="$strContext = $g_strSecondary and $g_strDocumentType = $g_strSecondary">
						<xsl:text> Leg</xsl:text>
					</xsl:if>
					<xsl:value-of select="$strAmendmentSuffix"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:apply-templates select="leg:Pnumber/node() | processing-instruction()"/>
			<xsl:if test="ancestor-or-self::*/@RestrictExtent">
				<xsl:sequence select="$nstContent"/>
			</xsl:if>
		</span>
		<xsl:apply-templates select="leg:Title"/>
	</xsl:element>
	<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Pnumber)]"/>
	<xsl:call-template name="FuncApplyVersions"/>
	<xsl:apply-templates select="." mode="ProcessAnnotations"/>
</xsl:template>

<xsl:template match="leg:P1group/leg:P1[1]/leg:Pnumber/node()[last()][not(ancestor::leg:BlockAmendment)][$g_strDocumentType = ($g_strEUretained)]" priority="10">
	<xsl:variable name="nstContent" as="node()*">
		<xsl:copy-of select="tso:generateExtentInfo(ancestor::leg:P1group)"/>
	</xsl:variable>
	<xsl:next-match/>
	<xsl:if test="ancestor-or-self::*/@RestrictExtent">
		<xsl:sequence select="$nstContent"/>
	</xsl:if>
</xsl:template>

<!-- EU special case numbered P2group elements -->
<xsl:template match="leg:P2group[leg:Pnumber][leg:Title]" priority="50">
	<xsl:variable name="strElementName">
		<xsl:text>h</xsl:text>
		<xsl:call-template name="FuncCalcHeadingLevel"/>
	</xsl:variable>
	<xsl:call-template name="FuncCheckForIDelement"/>
	<xsl:element name="{$strElementName}">
		<xsl:attribute name="class">
			<xsl:text>LegClearFix LegP2TitleContainer</xsl:text>
			<xsl:if test="preceding-sibling::*[1][self::leg:Title or self::leg:Number]">First</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates select="leg:Title | leg:Pnumber"/>
	</xsl:element>
	<xsl:apply-templates select="*[not(self::leg:Title or self::leg:Pnumber)]"/>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>


<xsl:template match="leg:P2group[leg:Pnumber]/leg:Title" priority="50">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:attribute name="class">
			<xsl:text>LegP2GroupTitleWithNo</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:P2group[leg:Pnumber]/leg:Pnumber" priority="50">
	<!-- Generate suffix to be added for CSS classes for amendments -->
	<xsl:variable name="strAmendmentSuffix">
		<xsl:call-template name="FuncCalcAmendmentNo"/>
	</xsl:variable>
	<xsl:element name="span">
		<xsl:call-template name="FuncCheckForID"/>
		<xsl:attribute name="class">
			<xsl:text>LegP2GroupNo</xsl:text>
			<xsl:if test="$strAmendmentSuffix != ''">
				<xsl:value-of select="$strAmendmentSuffix"/>
			</xsl:if>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:EUPreamble">
	<a id="{@id}" class="LegAnchorID"/>
	<div class="LegEnactingText">
		<xsl:apply-templates/>
	</div>
</xsl:template>

<xsl:template match="leg:EUPreamble/leg:Division" priority="50">
	<a id="{@id}" class="LegAnchorID"/>
	<xsl:element name="p">
		<xsl:attribute name="class">
			<xsl:value-of select="'LegClearFix LegPreambleP1Container'"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="leg:EUPreamble/leg:Division/leg:Number" priority="50">
	<xsl:variable name="classname" select="if (parent::*/@Type) then parent::*/@Type else 'Division'"/>
	<span class="LegDS LegPreambleP1No">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<xsl:template match="leg:EUPreamble/leg:Division/leg:P" priority="10">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="leg:EUPreamble/leg:Division/leg:P/leg:Text" priority="50">
	<span class="LegDS LegRHS LegPreambleP1Text">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<!-- the title elemnent in the preamble appears to just be a first paragraph so treat as such-->
<xsl:template match="leg:EUPreamble/leg:Division/leg:Title">
	<span class="LegDS LegRHS LegPreambleP1Text">
		<xsl:apply-templates/>
	</span>
</xsl:template>

<xsl:template match="leg:ContentsEUChapter" name="FuncContentsChapter">
	<li class="LegClearFix LegContentsChapter{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsEUPart" name="FuncContentsPart">
	<li class="LegClearFix LegContentsPart{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsEUSection" name="FuncContentsSection">
	<li class="LegClearFix LegContentsSection{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsEUSubsection" name="FuncContentsSubsection">
	<li class="LegClearFix LegContentsSubsection{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsDivision" name="FuncContentsDivision">
	<li class="LegClearFix LegContentsEntry{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsAttachments" name="FuncContentsSchedules">
	<li class="LegClearFix LegContentsAttachments{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:ContentsAttachment" name="FuncContentsSchedule">
	<li class="LegClearFix LegContentsAttachment{if (@ConfersPower='true') then ' LegConfersPower' else ()}">
		<xsl:call-template name="FuncTocListContents"/>
	</li>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:EUPrelims">
	<div class="LegClearFix LegPrelims">
		<xsl:call-template name="FuncOutputEUPrelimsPreContents"/>
		<xsl:apply-templates select="//leg:Legislation/leg:Contents"/>		
		<xsl:call-template name="FuncOutputEUPrelimsPostContents"/>
	</div>
	<xsl:call-template name="FuncApplyVersions"/>
	<xsl:if test="not(@AltVersionRefs)">
		<xsl:apply-templates select="." mode="ProcessAnnotations"/>
	</xsl:if>
</xsl:template>

<xsl:template name="FuncOutputEUPrelimsPreContents">
	<h1 class="LegType"><xsl:value-of select="concat(upper-case(tso:getType($g_strDocumentMainType, ())/@category), 'S')"/></h1>
	<xsl:apply-templates select="leg:MultilineTitle"/>
</xsl:template>

<xsl:template name="FuncOutputEUPrelimsPostContents">
	<xsl:apply-templates select="leg:EUPreamble"/>
</xsl:template>

<xsl:template match="leg:Attachment//leg:EUPrelims" priority="10">
	<div class="LegClearFix LegPrelims">
		<xsl:apply-templates/>		
	</div>
</xsl:template>

<xsl:template match="leg:Attachments" priority="10">
	<div class="LegClearFix legAttachments">
		<xsl:apply-templates/>		
	</div>
</xsl:template>

<xsl:template match="leg:Attachment" priority="10">
	<div class="LegClearFix legAttachment">
		<xsl:apply-templates/>		
	</div>
</xsl:template>

<xsl:template match="leg:EUPrelims/leg:MultilineTitle">
	
		<xsl:apply-templates/>
	
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:EUPrelims/leg:MultilineTitle/leg:Text">
	<h1 class="LegTitle">
		<xsl:apply-templates/>
	</h1>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Expanded">
	<em>
		<xsl:apply-templates/>
	</em>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:template match="leg:Uppercase">
	<span class="uppercase">
		<xsl:apply-templates/>
	</span>
	<xsl:call-template name="FuncApplyVersions"/>
</xsl:template>

<xsl:function name="tso:showCommentary" as="xs:boolean">
	<xsl:param name="commentaryRef" as="element()" />
	<xsl:variable name="fragment" select="$commentaryRef/ancestor::*[@RestrictStartDate or @RestrictEndDate or @Match or @Status][1]" />
	<xsl:variable name="isDead" as="xs:boolean" select="$fragment/@Status = 'Dead'" />
	<xsl:variable name="isValidFrom" as="xs:boolean" select="$fragment/@Match = 'false' and $fragment/@RestrictStartDate and ((($version castable as xs:date) and xs:date($fragment/@RestrictStartDate) &gt; xs:date($version) ) or (not($version castable as xs:date) and xs:date($fragment/@RestrictStartDate) &gt; current-date() ))" />
	<xsl:variable name="isRepealed" as="xs:boolean" select="$fragment/@Match = 'false' and (not($fragment/@Status) or $fragment/@Status != 'Prospective') and not($isValidFrom)"/>
	<xsl:variable name="commentary" as="element(leg:Commentary)?" select="key('commentary', $commentaryRef/(@Ref | @CommentaryRef), $commentaryRef/root())" />
	<xsl:sequence select="tso:showCommentary($commentary, $isRepealed, $isDead)" />
</xsl:function>

<xsl:function name="tso:showCommentary" as="xs:boolean">
	<xsl:param name="commentary" as="element(leg:Commentary)?" />
	<xsl:param name="isRepealed" as="xs:boolean" />
	<xsl:param name="isDead" as="xs:boolean" />
	<xsl:sequence select="not($isRepealed) or ($isRepealed and contains($commentary, 'temp.')) or $isDead" />
</xsl:function>

<xsl:function name="tso:commentaryNumber" as="xs:integer">
	<xsl:param name="commentary" as="xs:string" />
	<xsl:sequence select="count($g_commentaryOrder/leg:commentary[@id = $commentary][1]/preceding-sibling::*)" />
</xsl:function>

</xsl:stylesheet>
