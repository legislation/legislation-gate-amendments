<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:utils="http://www.legislation.gov.uk/namespaces/legislation/utils"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
  xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs err tso atom dc leg ukm utils"
	version="2.0">
	
	<xsl:variable name="brexitType" as="xs:string" select="'@BREXIT@'"/>
	
	<xsl:variable name="exitday" as="xs:string" select="'@EUEXITDAY@'"/>
	
	<xsl:variable name="exitTransitionDay" as="xs:string" select="'@EUENDTRANSITIONDAY@'"/>
	
	<xsl:variable name="hideEUdata"	as="xs:boolean" select="false()"/>
	
	<xsl:variable name="euUpdateToDate"	as="xs:date?" 
					select="if ($brexitType = 'deal' and $exitTransitionDay castable as xs:date) then 
							xs:date($exitTransitionDay) - xs:dayTimeDuration('P1D')
							else if ($exitday castable as xs:date) then
								xs:date($exitday) - xs:dayTimeDuration('P1D')
							else ()"/>

<xsl:variable name="strCurrentURIs" select="/(leg:Legislation|leg:Fragment)/ukm:Metadata/dc:identifier, 
	/(leg:Legislation|leg:Fragment)/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasPart']/@href" />
<xsl:variable name="nstSelectedSection" as="element()?" 
	select="/(leg:Legislation|leg:Fragment)/(leg:Primary | leg:Secondary | leg:EURetained)/(leg:Body | leg:EUBody | leg:Schedules)//*[@id != '' and @DocumentURI = $strCurrentURIs]" />

<xsl:variable name="requestInfoDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>	

<!--  this will always be true on the editorial system in the cloud  -->
<xsl:param name="supportParticipation" as="xs:boolean" 	select="true()" />

<!-- References to $DEVBOX actually get changed through string replacement during the ant build script -->
<!-- This is declared here to prevent errors showing when scripts are run standalone or during editing -->
<xsl:param name="DEVBOX" as="xs:boolean" select="false()" />

<xsl:variable name="g_nstCodeLists" select="document('../codelists.xml')/CodeLists/CodeList"/>

<xsl:variable name="createdTypes" as="xs:string*"
				  select="$g_nstCodeLists[@name = 'DocumentMainType' ]/Code[@status='created']/@schema"/>	


<xsl:variable name="tso:legTypeMap" as="element()+">
	<!-- The order here is significant; it's a preferential order for displaying the types in lists -->
  <tso:legType schemaType="UnitedKingdomPublicGeneralAct" abbrev="ukpga" class="primary" category="Act" display="Act"
  	en="Explanatory Notes" pn="Policy Note" singular="UK Public General Act" plural="UK Public General Acts"
  	start="1801" complete="1988" revised="true" />
  <tso:legType schemaType="UnitedKingdomLocalAct" abbrev="ukla" class="primary" category="Act" display="Act"
  	singular="UK Local Act" plural="UK Local Acts"
  	start="1857" complete="1991" revised="false" />
	<tso:legType schemaType="UnitedKingdomPrivateOrPersonalAct" abbrev="ukppa" class="primary" category="Act"
		singular="UK Private or Personal Act" plural="{leg:TranslateText('UK Private and Personal Acts')}"
		start="1801" complete="1987" revised="false" />
  <tso:legType schemaType="ScottishAct" abbrev="asp" class="primary" category="Act" display="Act"
  	en="Explanatory Notes" pn="Policy Note" singular="Act of the Scottish Parliament" plural="Acts of the Scottish Parliament"
  	start="1999" complete="1999" revised="true" />
  <tso:legType schemaType="WelshNationalAssemblyAct" class="primary" category="Act" display="Act" abbrev="anaw" 
	en="Explanatory Notes" pn="Policy Note" singular="Act of the National Assembly for Wales" plural="Acts of the National Assembly for Wales"
  	start="2012" complete="2012" revised="true" />
	<tso:legType schemaType="WelshParliamentAct" class="primary" category="Act" display="Act" abbrev="asc" 
		en="Explanatory Notes" pn="Policy Note" singular="Act of Senedd Cymru" plural="Acts of Senedd Cymru"
		start="2012" complete="2012" revised="true" />		
  <tso:legType schemaType="WelshAssemblyMeasure" class="primary" category="Measure" display="Measure" abbrev="mwa" 
	en="Explanatory Notes" pn="Policy Note" singular="Measure of the National Assembly for Wales" plural="Measures of the National Assembly for Wales"
  	start="2008" complete="2008" revised="true" />
  <tso:legType schemaType="UnitedKingdomChurchMeasure" class="primary" category="Measure" display="Measure" abbrev="ukcm" 
  	singular="Church Measure" plural="Church Measures"
  	start="1920" complete="1988" revised="true" />
  <tso:legType schemaType="NorthernIrelandAct" class="primary" category="Act" display="Act" abbrev="nia" 
  	en="Explanatory Notes" pn="Policy Note" singular="Act of the Northern Ireland Assembly" plural="Acts of the Northern Ireland Assembly"
  	start="2000" complete="2000" revised="true" />
  <tso:legType schemaType="ScottishOldAct" abbrev="aosp" class="primary" category="Act" display="Act"
  	singular="Act of the Old Scottish Parliament" plural="Acts of the Old Scottish Parliament"
  	start="1424" end="1707" timeline="century" revised="true" />
  <tso:legType schemaType="EnglandAct" abbrev="aep" class="primary" category="Act" display="Act"
  	singular="Act of the English Parliament" plural="Acts of the English Parliament"
  	start="1267" end="1706" timeline="century" revised="true" />
  <tso:legType schemaType="IrelandAct" abbrev="aip" class="primary" category="Act" display="Act"
  	singular="Act of the Old Irish Parliament" plural="Acts of the Old Irish Parliament"
  	start="1495" end="1800" timeline="century" revised="true" />
	<tso:legType schemaType="GreatBritainAct" abbrev="apgb" class="primary" category="Act" display="Act"
		singular="Act of the Parliament of Great Britain" plural="Acts of the Parliament of Great Britain"
		start="1707" end="1800" revised="true" />
		<tso:legType schemaType="GreatBritainLocalAct" abbrev="gbla" class="primary" category="Act"
		singular="Local Act of the Parliament of Great Britain" plural="{leg:TranslateText('Local Acts of the Parliament of Great Britain')}"
		start="1797" complete="1800" revised="false" />
	<tso:legType schemaType="GreatBritainPrivateOrPersonalAct" abbrev="gbppa" class="primary" category="Act"
		singular="Private or Personal Act of the Parliament of Great Britain" plural="{leg:TranslateText('Private and Personal Acts of the Parliament of Great Britain')}"
		start="1707" complete="1800" revised="false" />
	<!-- half way point -->
	<tso:legType schemaType="UnitedKingdomStatutoryInstrument" class="secondary" category="Instrument" display="S.I." abbrev="uksi" 
		en="Executive Note" em="Explanatory Memorandum" pn="Policy Note" singular="UK Statutory Instrument" plural="UK Statutory Instruments"
		start="1948" complete="1987" revised="true" />
  <tso:legType schemaType="WelshStatutoryInstrument" class="secondary" category="Instrument" display="S.I." abbrev="wsi" 
		em="Explanatory Memorandum" singular="Wales Statutory Instrument" pn="Policy Note" plural="Wales Statutory Instruments"
  	start="1999" complete="1999" revised="true" />
  <tso:legType schemaType="ScottishStatutoryInstrument" class="secondary" category="Instrument" display="S.S.I." abbrev="ssi" 
  	en="Executive Note" pn="Policy Note" singular="Scottish Statutory Instrument" plural="Scottish Statutory Instruments"
  	start="1999" complete="1999" revised="true" />
  <tso:legType schemaType="NorthernIrelandOrderInCouncil" class="primary" category="Order" display="Order" abbrev="nisi" 
  	em="Explanatory Memorandum" singular="Northern Ireland Order in Council" plural="Northern Ireland Orders in Council"
  	start="1972" complete="1987" revised="true" />
  <tso:legType schemaType="NorthernIrelandStatutoryRule" class="secondary" category="Rule" display="Rule" abbrev="nisr" 
  	em="Explanatory Memorandum" singular="Northern Ireland Statutory Rule" plural="Northern Ireland Statutory Rules"
  	start="1991" complete="1991" revised="true" />
  <tso:legType schemaType="UnitedKingdomChurchInstrument" class="secondary" category="Instrument" display="Instrument" abbrev="ukci" 
  	singular="Church Instrument" plural="Church Instruments"
  	start="1991" complete="1991" revised="false" />
  <tso:legType schemaType="UnitedKingdomMinisterialDirection" class="secondary" category="Direction" display="Direction" abbrev="ukmd" 
    singular="UK Ministerial Direction" plural="UK Ministerial Directions"
    start="2018" complete="2018" revised="false" />
  <tso:legType schemaType="UnitedKingdomMinisterialOrder" class="secondary" category="Order" display="Order" abbrev="ukmo" 
  	singular="UK Ministerial Order" plural="UK Ministerial Orders"
  	start="1992" timeline="none" revised="false" />
	<tso:legType schemaType="UnitedKingdomStatutoryRuleOrOrder" class="secondary" category="Order" display="Order" abbrev="uksro" 
		en="Executive Note" em="Explanatory Memorandum" pn="Policy Note" singular="UK Statutory Rule Or Order" plural="UK Statutory Rules and Orders"
		start="1900" end="1948" revised="false" />
  <tso:legType schemaType="NorthernIrelandStatutoryRuleOrOrder" class="secondary" category="Order" abbrev="nisro" 
  	em="Explanatory Memorandum" singular="Northern Ireland Statutory Rule Or Order" plural="Northern Ireland Statutory Rules and Orders"
  	start="1922" end="1973" revised="false" />
	<tso:legType schemaType="NorthernIrelandAssemblyMeasure" class="primary" category="Measure" display="Measure" abbrev="mnia" 
		singular="Measure of the Northern Ireland Assembly" plural="Measures of the Northern Ireland Assembly"
		start="1974" end="1974" timeline="none" revised="true" />
  <tso:legType schemaType="NorthernIrelandParliamentAct" class="primary" category="Act" display="Act" abbrev="apni" 
  	singular="Act of the Northern Ireland Parliament" plural="Acts of the Northern Ireland Parliament"
  	start="1921" end="1972" revised="true" />
	<!-- draft types -->
	<tso:legType schemaType="UnitedKingdomDraftStatutoryInstrument" class="draft" category="Instrument" display="S.I." abbrev="ukdsi" 
		en="Draft Executive Notes" em="Draft Explanatory Memorandum" singular="UK Draft Statutory Instrument" plural="UK Draft Statutory Instruments"
		start="1998" complete="1998" legType="UnitedKingdomStatutoryInstrument" revised="false" />
	<!--
  <tso:legType schemaType="WelshDraftStatutoryInstrument" class="draft" category="Instrument" abbrev="wdsi" 
		em="Explanatory Memorandum" singular="Wales Draft Statutory Instrument" plural="Wales Draft Statutory Instruments"
  	start="1999" complete="1999" legType="WelshStatutoryInstrument" />
  -->
  <tso:legType schemaType="ScottishDraftStatutoryInstrument" class="draft" category="Instrument" display="S.S.I." abbrev="sdsi" 
  	en="Draft Executive Notes"  pn="Draft Policy Note" singular="Scottish Draft Statutory Instrument" plural="Scottish Draft Statutory Instruments"
  	start="2001" complete="2001" legType="ScottishStatutoryInstrument" revised="false" />
  <tso:legType schemaType="NorthernIrelandDraftStatutoryRule" class="draft" category="Rule" display="Rule" abbrev="nidsr" 
  	em="Draft Explanatory Memorandum" singular="Northern Ireland Draft Statutory Rule" plural="Northern Ireland Draft Statutory Rules"
  	start="2000" complete="2000" legType="NorthernIrelandStatutoryRule" revised="false" />
	
	<tso:legType schemaType="UnitedKingdomImpactAssessment" class="IA" category="Impact Assessment" display="Impact Assessment" abbrev="ukia" 
  	em="" singular="UK Impact Assessment" plural="UK Impact Assessments"
  	start="2008" complete="2008" legType="UnitedKingdomImpactAssessment" revised="false" />
	
<!--  EU LEGISLATION -->
	<tso:legType schemaType="EuropeanUnionRegulation" abbrev="eur" class="euretained" category="Regulation" 
  	en="Explanatory Notes" pn="Policy Note" singular="European Union Regulation" plural="{leg:TranslateText('European Union Regulations')}"
  	start="2018" complete="2018" revised="true" />
	<tso:legType schemaType="EuropeanUnionDecision" abbrev="eudn" class="euretained" category="Decision" 
  	en="Explanatory Notes" pn="Policy Note" singular="European Union Decision" plural="{leg:TranslateText('European Union Decisions')}"
  	start="2018" complete="2018" revised="true" />
	<tso:legType schemaType="EuropeanUnionDirective" abbrev="eudr" class="euretained" category="Directive" 
  	en="Explanatory Notes" pn="Policy Note" singular="European Union Directive" plural="{leg:TranslateText('European Union Directives')}"
  	start="2018" complete="2018" revised="true" />
	<tso:legType schemaType="EuropeanUnionTreaty" abbrev="eut" class="euretained" category="Treaty"  category-plural="Treaties"
  	en="Explanatory Notes" pn="Policy Note" singular="European Union Treaty" plural="{leg:TranslateText('European Union Treaties')}"
  	start="2018" complete="2018" revised="true" />
	<tso:legType schemaType="EuropeanUnionOther" abbrev="euo" class="euretainedother" category="Other" 
	  en="Explanatory Notes" pn="Policy Note" singular="European Union Other" plural="{leg:TranslateText('European Union Others')}"
	  start="2018" complete="2018" revised="true" />
	<tso:legType schemaType="EuropeanUnionCorrigendum" abbrev="euc" class="euretainedother" category="Corrigendum" 
	  en="Explanatory Notes" pn="Policy Note" singular="European Union Corrigendum" plural="{leg:TranslateText('European Union Corrigenda')}"
	  start="2018" complete="2018" revised="true" />
</xsl:variable>

<xsl:variable name="leg:euretained" as="xs:string+">
	<xsl:sequence select="('EuropeanUnionRegulation', 'EuropeanUnionDecision', 'EuropeanUnionDirective')"/>
</xsl:variable>
	
<xsl:variable name="leg:euother" as="xs:string+">
	<xsl:sequence select="('EuropeanUnionCorrigendum', 'EuropeanUnionOther')"/>
</xsl:variable>
	
<xsl:variable name="leg:welshType" as="xs:string+">
	<xsl:sequence select="('WelshStatutoryInstrument', 'WelshAssemblyMeasure','WelshNationalAssemblyAct','WelshParliamentAct')"/>
</xsl:variable>
	
<xsl:function name="leg:abridgeContent">
	<xsl:param name="text" as="xs:string" />
	<xsl:param name="nWords" as="xs:integer" />
	<xsl:variable name="words" as="xs:string+" select="tokenize(normalize-space($text), '\s+')[position() &lt;= $nWords]" />
	<xsl:value-of select="concat(string-join($words, ' '), if (count(tokenize(normalize-space($text), '\s+')) &gt; $nWords) then '...' else ())" />
</xsl:function>

<xsl:function name="tso:getLongType" as="xs:string?">
	<xsl:param name="legType" as="xs:string" />
	<xsl:sequence select="$tso:legTypeMap[@abbrev = $legType]/@schemaType" />
</xsl:function>

<xsl:function name="tso:getClass" as="xs:string">
	<xsl:param name="legType" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$tso:legTypeMap[@abbrev = $legType]">
			<xsl:sequence select="$tso:legTypeMap[@abbrev = $legType]/@schemaType" />
		</xsl:when>
		<!-- if the DES service cannot reolsve the document class then it will return either primary or secondary  -->
		<xsl:when test="$legType = ('primary','secondary','euretained', 'euretainedother')">
			<xsl:sequence select="$legType" />
		</xsl:when>
		<xsl:when test="$legType = ('')">
			<xsl:sequence select="$legType" />
		</xsl:when>
		<xsl:when test="starts-with($legType, 'various')">
			<xsl:text>VariousLegislation</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<err:Error>Unknown type:<xsl:value-of select="$legType"/></err:Error>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
<xsl:function name="tso:getName" as="xs:string">
	<xsl:param name="legName" as="xs:string" />
	<xsl:choose>
		<xsl:when test="contains(lower-case($legName), 'various')">
			<xsl:text>Various Legislation</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="tso:TitleCase($legName)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="tso:getType" as="element(tso:legType)?">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:choose>
		<xsl:when test="$legType = 'ScottishAct'">
			<xsl:choose>
				<xsl:when test="if ($legYear castable as xs:integer) then xs:integer($legYear) &lt; 1800 else false()">
					<xsl:sequence select="$tso:legTypeMap[@abbrev = 'aosp']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$tso:legTypeMap[@abbrev = 'asp']" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$tso:legTypeMap[@schemaType = $legType]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetEffectingTypes" as="element(tso:legType)+">
	<xsl:sequence select="$tso:legTypeMap[not(@class = ('draft','IA')) and (@start >= 2002 or @complete >= 2002 or not(@end))]"/>
</xsl:function>

<xsl:function name="tso:ShowMoreResources" as="xs:boolean">
	<xsl:param name="item" as="document-node()" />
	<xsl:variable name="documentMainType" as="xs:string" select="$item/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:ENmetadata | ukm:Legislation)/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
	<xsl:sequence select="
		not($item/*/ukm:Metadata/ukm:Revisions) and
		(
			(: PDF documents :)
			exists($item/*/ukm:Metadata/(ukm:Notes|ukm:Alternatives|ukm:TableOfDestinations|ukm:TableOfOrigins|ukm:CorrectionSlip|ukm:TableOfEffects|ukm:CodeOfPractice|ukm:OrderInCouncil|ukm:OrdersInCouncil|ukm:OtherDocument)//*[contains(@URI, '.pdf')]) or
			(: reference to draft legislation :)
			$item/*/ukm:Metadata/ukm:Supersedes or
			(: revised legislation reference to affects on this :)
			$g_nstCodeLists[@name = 'DocumentMainType']/Code[@schema = $documentMainType]/@status = 'revised' or
			(: potentially affecting legislation :)
			(exists(tso:GetEffectingTypes()[@schemaType = $documentMainType]) and $item/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata | ukm:ENmetadata)/ukm:Year/@Value >= 2002)
		)" />
</xsl:function>

<xsl:function name="tso:ShowImpactAssessments" as="xs:boolean">
	<xsl:param name="item" as="document-node()" />
	<xsl:sequence select="not($item/*/ukm:Metadata/ukm:Revisions) and exists($item/*/ukm:Metadata/ukm:ImpactAssessments//*[ends-with(@URI, '.pdf')])" />
</xsl:function>

<!-- Convert schema document types to URI prefixes -->
<xsl:function name="tso:GetUriPrefixFromType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@abbrev" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetTitleFromType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@plural" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetTypeFromDraftType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@legType" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:GetSingularTitleFromType" as="xs:string">
  <xsl:param name="legType" as="xs:string" />
  <xsl:param name="legYear" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, $legYear)" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@singular" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="tso:TypeSelect" as="element()">
	<xsl:param name="selected" as="xs:string" select="''" />
	<xsl:param name="showPrimary" as="xs:boolean" select="true()" />
	<xsl:param name="showSecondary" as="xs:boolean" select="true()" />
	<xsl:param name="showEUretained" as="xs:boolean" select="true()" />	
	<xsl:param name="showDraft" as="xs:boolean" select="true()" />
	<xsl:param name="showImpacts" as="xs:boolean" select="true()" />
	<xsl:param name="showUnrevised" as="xs:boolean" select="true()" />
	<xsl:param name="error" as="xs:boolean" select="false()" />	
	<xsl:param name="allowMultipleLines" as="xs:boolean" select="false()" />		
	<xsl:param name="maxLineLength" as="xs:integer" select="0" />
	<xsl:param name="id" as="xs:string" select="'type'" />
	
	<select name="{$id}" id="{$id}">
		<xsl:if test="$error"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
	
		<xsl:if test="$showPrimary and $showSecondary">
			<option value="all">
				<xsl:if test="$selected = ''">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>
				<xsl:text>All </xsl:text>
				<xsl:if test="not($showUnrevised)">Revised </xsl:if>
				<xsl:text>Legislation (including originating from the EU)</xsl:text>
				<!--<xsl:if test="$showUnrevised"> (excluding draft)</xsl:if>-->
			</option>
		</xsl:if>
		
		<xsl:if test="$showPrimary">
			<option disabled="">--------------------------------------------</option>
			<xsl:if test="$showSecondary and $showUnrevised">
				<option value="primary">
					<xsl:if test="$selected = 'primary'">
						<xsl:attribute name="selected" select="'selected'" />
					</xsl:if>
					<xsl:text>All Primary Legislation</xsl:text>
				</option>
			</xsl:if>
			<xsl:apply-templates select="$tso:legTypeMap[@class = 'primary' and ($showUnrevised or @revised = 'true')]" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>

		</xsl:if>
		
		<xsl:if test="$showSecondary">
			<option disabled="">--------------------------------------------</option>
			<xsl:if test="$showPrimary and $showUnrevised">
				<option value="secondary">
					<xsl:if test="$selected = 'secondary'">
						<xsl:attribute name="selected" select="'selected'" />
					</xsl:if>			
					<xsl:text>All Secondary Legislation</xsl:text>
				</option>
			</xsl:if>
			
			<xsl:apply-templates select="$tso:legTypeMap[@class = 'secondary' and ($showUnrevised or @revised = 'true')]" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>
		
		</xsl:if>
		
		<xsl:if test="$showEUretained">
			<option disabled="">--------------------------------------------</option>
			<xsl:if test="$showSecondary and $showUnrevised">
				<option value="eu-origin">
					<xsl:if test="$selected = ('euretained', 'euretainedother')">
						<xsl:attribute name="selected" select="'eu-origin'" />
					</xsl:if>
					<xsl:value-of select="leg:TranslateText('European_Union_All')"/>
				</option>
			</xsl:if>
			<xsl:apply-templates select="$tso:legTypeMap[@class = ('euretained', 'euretainedother') and ($showUnrevised or @revised = 'true')]" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>

		</xsl:if>
		
		<xsl:if test="$showDraft">
			<option disabled="">--------------------------------------------</option>
			<option value="draft">
				<xsl:if test="$selected = 'draft'">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>			
				<xsl:text>All Draft Legislation</xsl:text>
			</option>
			
			<xsl:apply-templates select="$tso:legTypeMap[@class='draft']" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>
		</xsl:if>
		<!-- note that we are currently using ukia as this is the only IA type - if we have additional this will need to be changed to 'impact' -->
		<xsl:if test="$showImpacts">
			<option disabled="">--------------------------------------------</option>
			<option value="ukia">
				<xsl:if test="$selected = 'ukia'">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>			
				<xsl:text>All Impact Assessments</xsl:text>
			</option>
			
			<xsl:apply-templates select="$tso:legTypeMap[@class='IA']" mode="DisplaySelectOptions">
				<xsl:with-param name="selected" select="$selected"/>
				<xsl:with-param name="allowMultipleLines" select="$allowMultipleLines"/>				
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:apply-templates>
		</xsl:if>
	</select>
</xsl:template>

<xsl:template match="tso:legType" mode="DisplaySelectOptions">
	<xsl:param name="selected" as="xs:string"/>		
	<xsl:param name="allowMultipleLines" as="xs:boolean"/>
	<xsl:param name="maxLineLength" as="xs:integer"/>
	<xsl:choose>
		<xsl:when test="$allowMultipleLines and string-length(@plural) &gt; $maxLineLength ">

			<xsl:call-template name="DisplayOptionOnMultipleLines">
				<xsl:with-param name="displayText" select="@plural"/>
				<xsl:with-param name="abbrev" select="@abbrev"/>	
				<xsl:with-param name="selected" select="$selected"/>		
				<xsl:with-param name="maxLineLength" select="$maxLineLength"/>
			</xsl:call-template>
									
		</xsl:when>
		<xsl:otherwise>
			<option value="{@abbrev}">
				<xsl:if test="$selected eq @abbrev">
					<xsl:attribute name="selected" select="'selected'" />
				</xsl:if>
				<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
				<xsl:if test="$allowMultipleLines">
					<xsl:text>-&#160;</xsl:text>								
				</xsl:if>
				<xsl:value-of select="@plural"/>
			</option>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<xsl:template name="DisplayOptionOnMultipleLines">
	<xsl:param name="displayText" as="xs:string"/>
	<xsl:param name="abbrev" as="xs:string"/>	
	<xsl:param name="selected" as="xs:string"/>		
	<xsl:param name="maxLineLength" as="xs:integer"/>
		
	<xsl:variable name="displayLines" as="element()+">
			<xsl:call-template name="SplitTextOnMultipleLines">
				<xsl:with-param name="textTokens" select="tokenize($displayText,'\s+')" />
				<xsl:with-param name="text" select="''" />
				<xsl:with-param name="pos" select="1" />	
				<xsl:with-param name="maxLineLength" select="$maxLineLength" />
			</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="abbrev" select="$abbrev"/>
	
	<xsl:for-each select="$displayLines">
		<option value="{$abbrev}">
			<xsl:if test="position() = 1 and $selected eq $abbrev">
				<xsl:attribute name="selected" select="'selected'" />
			</xsl:if>
			<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:text>-&#160;</xsl:text>									
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&#160;&#160;&#160;</xsl:text>				
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="."/>
		</option>							
	</xsl:for-each>
</xsl:template>

 <xsl:template name="SplitTextOnMultipleLines" as="element()+">
	<xsl:param name="textTokens" as="xs:string+"/>
	<xsl:param name="text" as="xs:string"/>
	<xsl:param name="pos" as="xs:integer"/>	
	<xsl:param name="maxLineLength" as="xs:integer"/>		
	

	
	<xsl:choose>
		<xsl:when test="$pos &gt; count($textTokens)">
			<xsl:if test="string-length($text) ne 0 ">
				<tso:line><xsl:value-of select="$text"/></tso:line>		
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="textAdd" select="normalize-space(concat($text, ' ' , $textTokens[$pos]))"/>					
			<xsl:choose>
				<xsl:when test="string-length($textAdd) &gt; $maxLineLength"> 
					<tso:line><xsl:value-of select="$text"/></tso:line>
					<xsl:call-template name="SplitTextOnMultipleLines">
						<xsl:with-param name="textTokens" select="$textTokens" />
						<xsl:with-param name="text" select="''" />
						<xsl:with-param name="pos" select="$pos" />	
						<xsl:with-param name="maxLineLength" select="$maxLineLength" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="SplitTextOnMultipleLines">
						<xsl:with-param name="textTokens" select="$textTokens" />
						<xsl:with-param name="text" select="$textAdd" />
						<xsl:with-param name="pos" select="$pos+1" />	
						<xsl:with-param name="maxLineLength" select="$maxLineLength" />
					</xsl:call-template>			
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<xsl:template name="tso:TypeChoice" as="element()*">
	<xsl:param name="showPrimary" as="xs:boolean" select="true()" />
	<xsl:param name="showSecondary" as="xs:boolean" select="true()" />	
	<xsl:param name="showEUretained" as="xs:boolean" select="true()" />
	<xsl:param name="showDraft" as="xs:boolean" select="false()" />	
	<xsl:param name="showImpacts" as="xs:boolean" select="false()" />	
	<xsl:param name="selected" as="xs:string" select="''" />	
	<div id="checkboxes">
		<div class="searchCol2">
			<xsl:choose>
				<xsl:when test="$showDraft">
					<div class="typeCheckBoxDoubleCol">
							<input type="checkbox" name="type" value="draft" checked="checked">
								<xsl:if test="contains($selected, 'draft')">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label>All Draft</label>	
					</div>				
				</xsl:when>
				<xsl:when test="$showImpacts">
					<div class="typeCheckBoxDoubleCol">
							<!--<input type="checkbox" name="type" value="ukia" checked="checked">
								<xsl:if test="contains($selected, 'impacts')">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label>UK Impact Assessments</label>
							-->
							<input type="hidden" name="type" value="ukia"/>
								
					</div>				
				</xsl:when>
				<xsl:otherwise>
					<div class="typeCheckBoxDoubleCol">
						<xsl:if test="$showPrimary and $showSecondary and $showEUretained">
									<input type="checkbox" name="type" value="all">
										<xsl:if test="contains($selected, 'all')">
											<xsl:attribute name="checked"/>
										</xsl:if>
									</input>
							<label>All Legislation</label>
						</xsl:if>
						
						<xsl:if test="$showPrimary">
									<input type="checkbox" name="type" value="primary">
										<xsl:if test="contains($selected, 'primary')">
											<xsl:attribute name="checked"/>
										</xsl:if>
									</input>
							<label>All Primary</label>
						</xsl:if>
					</div>
						
					<div class="typeCheckBoxDoubleCol">
						<xsl:if test="$showSecondary">
								<div id="allSecondary"  class="typeCheckBoxCol">
									<input type="checkbox" name="type" value="secondary">
										<xsl:if test="contains($selected, 'secondary')">
											<xsl:attribute name="checked"/>
										</xsl:if>					
									</input>
									<label>All Secondary</label>	
								</div>
						</xsl:if>
						<xsl:if test="$showEUretained">
							<div id="allEuropean" class="typeCheckBoxCol">
								<input type="checkbox" name="type" value="eu-origin">
									<xsl:if test="contains($selected, 'eu-origin')">
										<xsl:attribute name="checked"/>
									</xsl:if>
								</input>
								<label><xsl:value-of select="leg:TranslateText('European_Union_All')"/></label>
							</div>
						</xsl:if>
					</div>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:variable name="dropListItems">
				<xsl:if test="$showPrimary">
					<xsl:for-each select="$tso:legTypeMap[@class = 'primary']">
						<div>
							<input type="checkbox" id="type{@abbrev}" name="type" value="{@abbrev}">
								<xsl:if test="contains($selected, @abbrev)">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label for="type{@abbrev}"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</xsl:if>
		
				<xsl:if test="$showSecondary">
					<xsl:for-each select="$tso:legTypeMap[@class = 'secondary']">
						<div>
							<input type="checkbox" id="type{@abbrev}" name="type" value="{@abbrev}">
								<xsl:if test="contains($selected, @abbrev)">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label for="type{@abbrev}"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</xsl:if>
			
				<xsl:if test="$showEUretained">				
					<xsl:for-each select="$tso:legTypeMap[@class = ('euretained', 'euretainedother')]">
						<div>
							<input type="checkbox" id="type{@abbrev}" name="type" value="{@abbrev}">
								<xsl:if test="contains($selected, @abbrev)">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label for="type{@abbrev}"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</xsl:if>
			
				<xsl:if test="$showDraft">				
					<xsl:for-each select="$tso:legTypeMap[@class = 'draft']">
						<div>
							<input type="checkbox" id="type{@abbrev}" name="type" value="{@abbrev}">
								<xsl:if test="contains($selected, @abbrev)">
									<xsl:attribute name="checked"/>
								</xsl:if>					
							</input>
							<label for="type{@abbrev}"><xsl:value-of select="@plural"/></label>
						</div>
					</xsl:for-each>	
				</xsl:if>	
			</xsl:variable>	
			<xsl:variable name="numberOfItems" select="count($dropListItems/*)"/>
			
			<xsl:if test="$numberOfItems != 0">
				
				<div id="uniqueExtents" class="typeCheckBoxCol extent">
					<input type="checkbox" id="ind" name="type" value="individual"/>
					<label for="ind"><xsl:value-of select="leg:TranslateText('Select types')"/></label> 
				</div>
				
				<div id="legChoicesColLeft" class="typeCheckBoxCol" style="width:220px">
					<xsl:copy-of select="$dropListItems/*[position() &lt; xs:integer(ceiling($numberOfItems div 2))+1]"/>
				</div>
				<div id="legChoicesColRight" class="typeCheckBoxCol" style="width:220px">
					<xsl:copy-of select="$dropListItems/*[position() > xs:integer(ceiling($numberOfItems div 2))]" />
				</div>
			</xsl:if>
		</div>
	</div>
</xsl:template>

<xsl:function name="tso:ResolveNumberForLegislation" as="xs:string">
	<xsl:param name="type" as="xs:string?" />
	<xsl:param name="year" as="xs:string?" />
	<xsl:param name="number" as="xs:string?" />
	<xsl:sequence select="	if (exists($type) and exists($year) and exists($number)) 
								then tso:GetNumberForLegislation($type, $year, $number)
							else ''"/>
</xsl:function>
	
<xsl:function name="tso:GetNumberForLegislation" as="xs:string">
	<xsl:param name="type" as="xs:string" />
	<xsl:param name="year" as="xs:string" />
	<xsl:param name="number" as="xs:string" />
	<xsl:sequence select="tso:GetNumberForLegislation($type, $year, $number, true())"/>
</xsl:function>

<xsl:function name="tso:GetNumberForLegislation" as="xs:string">
	<xsl:param name="type" as="xs:string" />
	<xsl:param name="year" as="xs:string" />
	<xsl:param name="number" as="xs:string" />
	<xsl:param name="includeYear" as="xs:boolean" />
	<xsl:variable name="includedYear" select="if ($includeYear) then concat($year, '/') else ()"/>
	<xsl:value-of>
		<xsl:choose>
			<xsl:when test="$type = ('UnitedKingdomPublicGeneralAct', 'GreatBritainAct', 'EnglandAct', 'NorthernIrelandAct','GreatBritainPrivateOrPersonalAct','GreatBritainLocalAct')">
				<xsl:text>c. </xsl:text>
				<xsl:value-of select="$number" />
			</xsl:when>
			<xsl:when test="$type = ('IrelandAct')">
				<xsl:text>c. </xsl:text>
				<xsl:value-of select="$number" />
				<xsl:text> [I]</xsl:text>				
			</xsl:when>
			<xsl:when test="$type = ('ScottishOldAct')">
				<xsl:text>c. </xsl:text>
				<xsl:value-of select="$number" />
				<xsl:text> [S]</xsl:text>
			</xsl:when>
			<xsl:when test="$type = ('UnitedKingdomLocalAct', 'UnitedKingdomLocalActRevised', 'UnitedKingdomPrivateOrPersonalAct')">
				<xsl:text>c. </xsl:text>
				<xsl:number format="i" value="$number" />
			</xsl:when>
			<xsl:when test="$type = 'ScottishAct'">
				<xsl:choose>
					<xsl:when test="if ($year castable as xs:integer) then xs:integer($year) &lt; 1800 else false()">c. <xsl:value-of select="$number" /></xsl:when>
					<xsl:otherwise>asp <xsl:value-of select="$number" /></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = ('NorthernIrelandParliamentAct', 'NorthernIrelandAssemblyMeasure')">Chapter <xsl:value-of select="$number" /></xsl:when>
			<xsl:when test="$type = 'WelshAssemblyMeasure'">nawm <xsl:value-of select="$number" /></xsl:when>
			<xsl:when test="$type = 'WelshNationalAssemblyAct'">anaw <xsl:value-of select="$number" /></xsl:when>
			<xsl:when test="$type = 'WelshParliamentAct'">asc <xsl:value-of select="$number" /></xsl:when>
			<xsl:when test="$type = ('UnitedKingdomStatutoryInstrument', 'NorthernIrelandOrderInCouncil', 'WelshStatutoryInstrument')">S.I. <xsl:value-of select="$includedYear"/><xsl:value-of select="$number" /></xsl:when>			
			<xsl:when test="$type = 'ScottishStatutoryInstrument'">S.S.I. <xsl:value-of select="$includedYear"/><xsl:value-of select="$number" /></xsl:when>						
			<xsl:when test="$type = 'NorthernIrelandStatutoryRule'">S.R. <xsl:value-of select="$includedYear"/><xsl:value-of select="$number" /></xsl:when>
			<xsl:when test="$type = 'NorthernIrelandStatutoryRuleOrOrder'">S.R. and O. <xsl:value-of select="$includedYear"/><xsl:value-of select="$number" /></xsl:when>
			<xsl:otherwise>No. <xsl:value-of select="$number" /></xsl:otherwise>
		</xsl:choose>
	</xsl:value-of>
</xsl:function>


<!-- this is to fall in line with the TOES Excel spreadsheet scheme so that editors can clearly understand what legislation type the effect refers to -->
<xsl:function name="tso:toesReference">
	<xsl:param name="type" as="xs:string" />
	<xsl:param name="year" as="xs:integer" />
	<xsl:param name="number" as="xs:integer" />
	
	<xsl:variable name="class" as="xs:string?" select="$tso:legTypeMap[@schemaType = $type]/@class"/>
	
	<xsl:value-of select="$year" />
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="$type = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','UnitedKingdomPrivateOrPersonalAct','GreatBritainPrivateOrPersonalAct','GreatBritainLocalAct','EnglandAct','GreatBritainAct','NorthernIrelandAct')">c. </xsl:when>
		<xsl:when test="$type = 'ScottishAct'">asp</xsl:when>
		<xsl:when test="$type = 'WelshAssemblyMeasure'">nawm</xsl:when>
		<xsl:when test="$type = 'UnitedKingdomChurchMeasure'">gsm</xsl:when>
		<xsl:when test="$type = ('UnitedKingdomStatutoryInstrument','NorthernIrelandOrderInCouncil')">SI</xsl:when>
		<xsl:when test="$type = 'WelshStatutoryInstrument'">WSI</xsl:when>
		<xsl:when test="$type = 'ScottishStatutoryInstrument'">SSI</xsl:when>
		<xsl:when test="$type = 'NorthernIrelandStatutoryRule'">SR</xsl:when>
		<xsl:when test="$type = 'NorthernIrelandStatutoryRuleOrOrder'">SRO</xsl:when>
		<xsl:when test="$type = 'UnitedKingdomChurchInstrument'">AI</xsl:when>
		<xsl:when test="$type = 'EuropeanUnionRegulation'">EUR</xsl:when>
		<xsl:when test="$type = 'EuropeanUnionDirective'">EUDR</xsl:when>
		<xsl:when test="$type = 'EuropeanUnionDecision'">EUDN</xsl:when>
		<xsl:when test="$type = 'EuropeanUnionTreaty'">EUT</xsl:when>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$type = ('UnitedKingdomLocalAct', 'UnitedKingdomPrivateOrPersonalAct')">
			<xsl:number value="$number" format="i" />
		</xsl:when>
		<xsl:when test="$class = 'primary' and not($type = 'NorthernIrelandOrderInCouncil')">
			<xsl:value-of select="format-number($number, '000')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="format-number($number, '0000')" />
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$type = ('NorthernIrelandOrderInCouncil', 'NorthernIrelandAct', 'NorthernIrelandParliamentAct')"> (N.I.)</xsl:if>
</xsl:function>

<xsl:function name="tso:TitleCase">
	<xsl:param name="strText" />
	<xsl:value-of select="upper-case(substring($strText, 1, 1))" />
	<xsl:variable name="strRest" select="substring($strText, 2)" />
	<xsl:choose>
		<xsl:when test="contains($strText, ' ')">
			<xsl:value-of select="substring-before($strRest, ' ')" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="tso:TitleCase(substring-after($strRest, ' '))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$strRest" />
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:function>

<!-- Wording for Category (Act, Rule, Measure, Instrument, Order) , used in opening options on ui -->
<xsl:function name="tso:GetCategory">
	<xsl:param name="legType" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@category" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
<!-- Wording for Category (Act, S.I., S.S.I., Rule, Measure, Order) , used in annotations -->
<xsl:function name="tso:GetDisplayCategory">
	<xsl:param name="legType" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type)">
			<xsl:sequence select="$type/@display" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$legType" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- Wording for EN  tab/label -->
<xsl:function name="tso:GetENLabel">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="enType" as="xs:string?" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type/@pn) and $enType ='pn'">
			<xsl:value-of select="$type/@pn"/>
		</xsl:when>
		<xsl:when test="exists($type/@en) and $enType ='en'">
			<xsl:value-of select="$type/@en"/>
		</xsl:when>
		<xsl:when test="exists($type/@em) and $enType ='em' ">
			<xsl:value-of select="$type/@em"/>
		</xsl:when>		
		<xsl:when test="exists($type) and exists($type/@en)">
			<xsl:value-of select="$type/@en"/>
		</xsl:when>
		<xsl:when test="exists($type) and exists($type/@em)">
			<xsl:value-of select="$type/@em"/>
		</xsl:when>
		<xsl:otherwise>
			()
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- Default Type for EN /EM tab -->
<xsl:function name="tso:GetDefaultENType">
	<xsl:param name="legType" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
		<xsl:when test="exists($type) and exists($type/@em)"> <!-- getting the default For UKSI -->
			<xsl:value-of select="'em' "/>
		</xsl:when>		
		<xsl:when test="exists($type) and exists($type/@en)">
			<xsl:value-of select="'en'"/>
		</xsl:when>		
		<xsl:otherwise>
			()
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:ENInterweavedAllowed" as="xs:boolean">
	<xsl:param name="type" as="xs:string" />
	<xsl:value-of select="$type = ('UnitedKingdomPublicGeneralAct', 'WelshAssemblyMeasure', 'ScottishAct', 'NorthernIrelandOrderInCouncil')" /> 
</xsl:function>

<xsl:function name="tso:ResolveShortCitation">
	<xsl:param name="legType" as="xs:string?" />
	<xsl:param name="legYear" as="xs:string?" />
	<xsl:param name="legNumber" as="xs:string?" />
	<xsl:sequence select="	if (exists($legType) and exists($legYear) and exists($legNumber)) 
								then tso:GetShortCitation($legType, $legYear, $legNumber)
							else ''"/>
</xsl:function>

	<xsl:function name="tso:GetShortCitation">
		<xsl:param name="legType" as="xs:string" />
		<xsl:param name="legYear" as="xs:string?" />
		<xsl:param name="legNumber" as="xs:string?" />
		<xsl:param name="legSection" as="xs:string?" />
		<xsl:sequence select="tso:GetShortCitation($legType, $legYear, $legNumber, $legSection, ())" />
	</xsl:function>
	
	<xsl:function name="tso:GetShortCitation">
		<xsl:param name="legType" as="xs:string" />
		<xsl:param name="legYear" as="xs:string?" />
		<xsl:param name="legNumber" as="xs:string?" />
		<xsl:sequence select="tso:GetShortCitation($legType, $legYear, $legNumber, (), ())" />
	</xsl:function>
	
	<xsl:function name="tso:GetShortCitation">
		<xsl:param name="legType" as="xs:string" />
		<xsl:param name="legName" as="xs:string?" />
		<xsl:sequence select="tso:GetShortCitation($legType, (), (), (), $legName)" />
	</xsl:function>
	
	<xsl:function name="tso:GetShortCitation">
		<xsl:param name="legName" as="xs:string?" />
		<xsl:sequence select="tso:GetShortCitation((), (), (), (), $legName)" />
	</xsl:function>
	
	<xsl:function name="tso:GetShortCitation" as="xs:string*">
		<xsl:param name="legType" as="xs:string*" />
		<xsl:param name="legYear" as="xs:string*" />
		<xsl:param name="legNumber" as="xs:string?" />
		<xsl:param name="legSection" as="xs:string?" />
		<xsl:param name="legName" as="xs:string?" />
		<xsl:variable name="type" as="element(tso:legType)*" select="if (exists($legType)) then tso:getType($legType, ()) else if (exists($legName)) then () else ()" />
		<xsl:value-of>
			<xsl:choose>
				<xsl:when test="($type/@class = 'primary' or $type/@abbrev = 'ukci') and not($legType = 'NorthernIrelandOrderInCouncil')">
					<xsl:value-of select="$legYear" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="tso:GetNumberForLegislation($legType, $legYear, $legNumber)" />
					<xsl:if test="$legType = ('NorthernIrelandAct', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct')"> (N.I.)</xsl:if>
				</xsl:when>
				<xsl:when test="($type/@abbrev = 'eut') or $legType = 'EuropeanUnionTreaty'">
					<xsl:value-of select="$legName" />
				</xsl:when>
				<xsl:when test="$type/@class = 'euretained'">
					<xsl:value-of select="$legYear" />
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="$legType = 'EuropeanUnionRegulation'">EUR</xsl:when>
						<xsl:when test="$legType = 'EuropeanUnionDecision'">EUDN</xsl:when>
						<xsl:when test="$legType = 'EuropeanUnionDirective'">EUDR</xsl:when>
						<xsl:otherwise>S.I. </xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="$legNumber" />
				</xsl:when>
				<!-- We are missing affecting Numbers in some cases for EUropeanUnionOther -->
				<xsl:when test="$legType = 'EuropeanUnionOther'">
					<xsl:if test="$legYear != ''">
						<xsl:value-of select="$legYear" />
					</xsl:if>
					<xsl:text>No. </xsl:text>
					<xsl:if test="$legNumber != ''">
						<xsl:value-of select="$legNumber" />
					</xsl:if>
				</xsl:when>
				<xsl:when test="exists($legName) and $legYear = ''">
					<xsl:value-of select="$legName" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$legType = 'WelshStatutoryInstrument'">W.S.I. </xsl:when>
						<xsl:when test="$legType = 'ScottishStatutoryInstrument'">S.S.I. </xsl:when>
						<xsl:when test="$legType = 'NorthernIrelandStatutoryRule'">S.R. </xsl:when>
						<xsl:when test="$legType = 'NorthernIrelandStatutoryRuleOrOrder'">S.R. and O. </xsl:when>
						<xsl:otherwise>S.I. </xsl:otherwise>
					</xsl:choose>
					<xsl:if test="$legYear != ''">
						<xsl:value-of select="$legYear" />
					</xsl:if>
					<xsl:if test="$legNumber != ''">
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$legNumber" />
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:value-of>
	</xsl:function>

<xsl:function name="tso:GetShortOPSIPrefix">
	<xsl:param name="legType" as="xs:string" />
	<xsl:param name="legYear" as="xs:string" />
	<xsl:param name="legNumber" as="xs:string" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($legType, ())" />
	<xsl:choose>
	  <xsl:when test="$type/@class = 'primary' and not($legType = 'NorthernIrelandOrderInCouncil')">
	  	<xsl:value-of select="$legYear" />
	  	<xsl:text> </xsl:text>
	  	<xsl:value-of select="tso:GetNumberForLegislation($legType, $legYear, $legNumber)" />
	  </xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$legType = 'ScottishStatutoryInstrument'">SSI </xsl:when>
				<xsl:when test="$legType = 'NorthernIrelandStatutoryRule'">SR </xsl:when>
				<xsl:when test="$legType = 'NorthernIrelandStatutoryRuleOrOrder'">SRO </xsl:when>
				<xsl:otherwise>SI </xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$legYear" />
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$legNumber" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:httpDateTime" as="xs:string">
	<xsl:param name="dateTime" as="xs:dateTime" />
	<xsl:sequence select="format-dateTime(adjust-dateTime-to-timezone($dateTime, xs:dayTimeDuration('PT0H')), '[FNn,3-3], [D01] [MNn,3-3] [Y] [H01]:[m]:[s] GMT')"/>
</xsl:function>

<xsl:function name="tso:readableDateTime" as="xs:string">
	<xsl:param name="dateTime" as="xs:dateTime" />
	<xsl:choose>
		<xsl:when test="tso:sometimeToday($dateTime)">
			<xsl:sequence select="format-dateTime($dateTime, '[H01]:[m]')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="format-dateTime($dateTime, '[D1] [MNn,3-3] [Y]')" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:sometimeToday" as="xs:boolean">
	<xsl:param name="dateTime" as="xs:dateTime" />
	<xsl:variable name="date" as="xs:date" select="adjust-date-to-timezone(xs:date($dateTime), ())" />
	<xsl:variable name="today" as="xs:date" select="adjust-date-to-timezone(current-date(), ())" />
	<xsl:sequence select="$date = $today" />
</xsl:function>

<!-- ========== File size ========= -->
<xsl:function name="tso:GetFileSize" as="xs:string?">
	<xsl:param name="fileSize" as="xs:integer?"/>
	<xsl:if test="$fileSize castable as xs:integer and $fileSize &gt; 0">
		<xsl:variable name="kb" select="$fileSize div 1024"/>
		<xsl:choose>
			<xsl:when test="$kb > 1000">
				<xsl:sequence select="concat(format-number($kb div 1024, '0.##'), 'MB')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="concat(format-number($kb, '0'), 'kB')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:function>

<xsl:function name="tso:countryType" as="xs:string">
	<xsl:param name="legType" as="xs:string" />
	<xsl:choose>
		<xsl:when test="contains($legType, 'UnitedKingdom')">United Kingdom</xsl:when>
		<xsl:when test="contains($legType, 'Scottish')">Scotland</xsl:when>
		<xsl:when test="contains($legType, 'NorthernIreland') or contains($legType, 'Ireland')">Northern Ireland</xsl:when>
		<xsl:when test="contains($legType, 'Welsh')">Wales</xsl:when>
		<xsl:otherwise>()</xsl:otherwise>
	</xsl:choose>
</xsl:function>	

<!--
<xsl:function name="tso:effectKey" as="xs:string">
	<xsl:param name="effect" as="element()" />
	<xsl:sequence select="$effect/string-join((
		@AffectedClass, @AffectedYear, @AffectedNumber, 
		if (exists(@AffectedSectionRef)) then 
			@AffectedSectionRef
		else if (exists(@AffectedStartSectionRef)) then 
			(@AffectedStartSectionRef, @AffectedEndSectionRef)
		else
			@AffectedProvision,
		@Type,
		if (@CommencingClass) then (
			@CommencingClass, @CommencingYear, @CommencingNumber
		) else (
			@AffectingClass, @AffectingYear, @AffectingNumber
		),
		@Applied,
		@Note
	), '+')" />
</xsl:function>
-->

<xsl:function name="tso:formatISBN" as="xs:string">
	<xsl:param name="strISBN" as="xs:string" />
	<xsl:value-of>
		<xsl:choose>
			<xsl:when test="$strISBN = ''" />
			<xsl:when test="string-length($strISBN) = 13">
				<xsl:value-of select="substring($strISBN, 1, 3)" />
				<xsl:text>-</xsl:text>
				<xsl:value-of select="tso:formatISBN(substring($strISBN, 4))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($strISBN, 1, 1)" />
				<xsl:text>-</xsl:text>
				<xsl:choose>
					<xsl:when test="substring($strISBN, 2, 1) = ('0', '1')">
						<xsl:value-of select="substring($strISBN, 2, 2)" />
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring($strISBN, 4, 6)" />
					</xsl:when>
					<xsl:when test="xs:integer(substring($strISBN, 2, 1)) &lt; 7">
						<xsl:value-of select="substring($strISBN, 2, 3)" />
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring($strISBN, 5, 5)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring($strISBN, 2, 4)" />
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring($strISBN, 6, 4)" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>-</xsl:text>
				<xsl:value-of select="substring($strISBN, 10)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:value-of>
</xsl:function>

<xsl:function name="tso:extentDescription">
	<xsl:param name="extentsToken" as="xs:string+" />
	<xsl:sequence select="tso:extentDescription($extentsToken, ' and ', false())" />
</xsl:function>

<xsl:function name="tso:extentDescription">
	<xsl:param name="extentsToken" as="xs:string+" />
	<xsl:param name="finalSeparator" as="xs:string" />
	<xsl:param name="emphasise" as="xs:boolean" />
	<xsl:for-each select="$extentsToken">
		<xsl:variable name="country" as="xs:string?">
			<xsl:choose>
				<xsl:when test=". = ('uk', 'UK')">the United Kingdom</xsl:when>
				<xsl:when test=". = 'gb'">Great Britain</xsl:when>
				<xsl:when test=". = 'ew'">England &amp; Wales</xsl:when>
				<xsl:when test=". = ('england', 'E')">England</xsl:when>
				<xsl:when test=". = ('wales', 'W')">Wales</xsl:when>
				<xsl:when test=". = ('ni', 'N.I.')">Northern Ireland</xsl:when>
				<xsl:when test=". = ('scotland', 'S')">Scotland</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$emphasise"><strong><xsl:value-of select="$country" /></strong></xsl:when>
			<xsl:otherwise><xsl:value-of select="$country" /></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="position () = (last() - 1)"><xsl:value-of select="$finalSeparator" /></xsl:when>
			<xsl:when test="position() != last()">, </xsl:when>
		</xsl:choose>
	</xsl:for-each>		
</xsl:function>

<xsl:function name="tso:resolveExtentFormatting">
	<xsl:param name="extents" as="xs:string?" />
	<xsl:sequence select="if ($extents) then replace($extents, 'E\+W\+S\+N\.?I\.?', 'U.K.') else ()"/>
</xsl:function>

<xsl:variable name="minorTypeStrings" as="xs:string+" select="('article', 'paragraph', 'regulation', 'rule', 'section', 'order', 'scheme')"/>
<xsl:variable name="minorTypeShortStrings" as="xs:string+" select="('art.', 'para.', 'reg.', 'rule', 's.', 'art.', 's.')"/>
<xsl:variable name="minorTypeRegex" as="xs:string+" select="concat('^(', replace(string-join(($minorTypeShortStrings), '|'), '\.', '\\.'), ')')"/>

	<xsl:function name="tso:get-legitimate-minor-type" as="xs:string">
		<xsl:param name="minortype" as="xs:string" />	
		<xsl:sequence 
			select="if ($minortype = $minorTypeStrings) then
			$minortype
			else ('')"/>
	</xsl:function>
	
<xsl:function name="tso:get-minor-short-type" as="xs:string">
	<xsl:param name="minortype" as="xs:string" />	
	<xsl:sequence 
		select="if ($minortype = $minorTypeStrings) then
					$minorTypeShortStrings[index-of($minorTypeStrings,$minortype)]
				else $minortype"/>
</xsl:function>

<xsl:function name="tso:replace-minor-type" as="xs:string">
	<xsl:param name="provision" as="xs:string" />
	<xsl:param name="minortype" as="xs:string" />	
	<xsl:sequence select="replace($provision, $minorTypeRegex, $minortype)"/>
</xsl:function>

<!-- Maps between some tokens and corresponding text to show. -->
<xsl:variable name="sectionTokens" as="element()+">
	<token token="appendix" text="Appendix" plural="Appendices" />
	<token token="article" text="art." plural="arts." />
	<token token="chapter" text="Ch." plural="Chs." />
	<token token="form" text="Form" plural="Forms" />
	<token token="paragraph" text="para." plural="paras." />
	<token token="part" text="Pt." plural="Pts." />
	<token token="regulation" text="reg." plural="regs." />
	<token token="rule" text="rule" plural="rules" />
	<token token="schedule" text="Sch." plural="Schs." />
	<token token="section" text="s." plural="ss." />
	<token token="contents" text="contents" plural="contents" />
	<token token="annex" text="Annex" plural="Annexes" />
	<token token="title" text="Title" plural="Titles" />
	<token token="signature" text="Signature" plural="Signatures" />
	<token token="introduction" text="Preamble" plural="Preambles" />
</xsl:variable>

<xsl:variable name="numberTokens" as="element()+">
	<token token="first" text="1" />
	<token token="second" text="2" />
	<token token="third" text="3" />
	<token token="fourth" text="4" />
	<token token="fifth" text="5" />
	<token token="sixth" text="6" />
	<token token="seventh" text="7" />
	<token token="eigth" text="8" />
	<token token="ninth" text="9" />
	<token token="tenth" text="10" />
</xsl:variable>

<xsl:function name="tso:formatSection" as="xs:string">
	<xsl:param name="string" as="xs:string"/>
	<xsl:param name="token" as="xs:string"/>
	<xsl:sequence select="tso:formatSection($string, $token, ())" />
</xsl:function>

<xsl:function name="tso:formatSection" as="xs:string">
	<xsl:param name="string" as="xs:string"/>
	<xsl:param name="token" as="xs:string"/>
	<xsl:param name="relativeTo" as="xs:string?" />
	<xsl:sequence select="tso:formatSection($string, $token, $relativeTo, false())" />
</xsl:function>

<!-- Produce readable text of a section reference. -->
<xsl:function name="tso:formatSection" as="xs:string">
	<xsl:param name="string" as="xs:string"/>
	<xsl:param name="token" as="xs:string"/>
	<xsl:param name="relativeTo" as="xs:string?" />
	<xsl:param name="plural" as="xs:boolean" />
	<xsl:variable name="string2"
		            select="if (contains($string, 'cross-heading'))
		                      then replace($string, 'cross-heading', 'crossheading')
		                      else $string"/>
	<xsl:variable name="crossheading"
		            select="if (contains($string2, 'heading'))
		                      then true()
		                      else false()"/> <!-- cross -->
  <xsl:variable name="tokenised" as="xs:string+" select="tokenize($string2, $token)"/>
	<xsl:variable name="relativeToTokenised" select="tokenize($relativeTo, $token)" />
	<xsl:variable name="skip" as="xs:integer*">
		<xsl:for-each select="$tokenised">
			<xsl:variable name="i" select="position()" />
			<xsl:if test="not(. = $relativeToTokenised[$i])">
				<xsl:sequence select="$i" />
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="skip" as="xs:integer" select="if (empty($skip)) then count($tokenised) else $skip[1]" />
	<xsl:variable name="output" select="subsequence($tokenised, $skip)" />
	<xsl:value-of>
		<xsl:for-each select="$output">
			<xsl:variable name="position" select="position()"/>
			<xsl:variable name="previousToken" select="$tokenised[($skip - 1) + ($position - 1)]" />
			<xsl:variable name="remainingTokens" select="$output[position() > $position]" />
			<xsl:choose>
				<xsl:when test="$crossheading">
					<xsl:if test="$position > 1">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test=". = $sectionTokens/@token">
					<!-- sometimes a schedule does not have a number so we do not want a double space - exclude if the previous token is a section token  -->
					<xsl:if test="$position &gt; 1 and not($previousToken = $sectionTokens/@token)">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="$sectionTokens[@token = current()]/(if ($plural and not($remainingTokens = $sectionTokens/@token)) then @plural else @text)" />
					<xsl:if test="$sectionTokens[@token = current()]/@text != 'contents' and not(position() = last())">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$previousToken = $sectionTokens/@token">
					<xsl:value-of select="if (lower-case(.) = $numberTokens/@token) then	
							$numberTokens[@token = lower-case(current())]/@text 
						else ." />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>(</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>)</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:value-of>
</xsl:function>

<xsl:variable name="tso:oneDay" as="xs:dayTimeDuration" select="xs:dayTimeDuration('P1D')" />
<xsl:variable name="tso:oneHour" as="xs:dayTimeDuration" select="xs:dayTimeDuration('PT1H')" />
<xsl:variable name="tso:oneMinute" as="xs:dayTimeDuration" select="xs:dayTimeDuration('PT1M')" />
<xsl:variable name="tso:oneWeek" as="xs:dayTimeDuration" select="xs:dayTimeDuration('P7D')" />
<xsl:variable name="tso:oneMonth" as="xs:dayTimeDuration" select="xs:dayTimeDuration('P31D')" />
<xsl:variable name="tso:oneQuarter" as="xs:dayTimeDuration" select="xs:dayTimeDuration('P123D')" />
<xsl:variable name="tso:oneYear" as="xs:yearMonthDuration" select="xs:yearMonthDuration('P1Y')" />	
<xsl:variable name="dayOfWeek" as="xs:integer" select="xs:integer(format-date(current-date(), '[F1]'))" />

<xsl:function name="tso:scheduleQueryRunTime">
	<xsl:param name="querySchedule" as="xs:string*" />
	<!--<xsl:variable name="nextSunday" as="(current-date() - xs:date('2011-02-06')) div xs:dayTimeDuration('P1D') mod 7 &gt; 6" />-->
	<xsl:choose>
		<xsl:when test="$querySchedule = 'task:onDemand'">
			<xsl:sequence select="adjust-date-to-timezone(current-date() + $tso:oneMinute, ())" />
		</xsl:when>
		<xsl:when test="$querySchedule = 'task:everyHour'">
			<xsl:sequence select="adjust-date-to-timezone(current-date() + $tso:oneHour, ())" />
		</xsl:when>
		<xsl:when test="$querySchedule = 'task:everyDay'">
			<!-- on Dev environment, If it is a Friday then re-schedule the queries to run after the weekend -->
			<xsl:variable name="tso:oneDay" select="if($DEVBOX and $dayOfWeek = 5)  then (xs:dayTimeDuration('P3D')) else $tso:oneDay" />
			<xsl:sequence select="adjust-date-to-timezone(current-date() + $tso:oneDay, ())" />
		</xsl:when>		
		<xsl:when test="$querySchedule = 'task:everyWeek'">
			<xsl:sequence select="adjust-date-to-timezone(current-date() + $tso:oneWeek, ())" />
		</xsl:when>		
		<xsl:when test="$querySchedule = 'task:everyMonth'">
			<xsl:sequence select="xs:date(replace(xs:string(adjust-date-to-timezone(( xs:date(current-date() ) - 
				xs:dayTimeDuration( concat('P', day-from-date(current-date()) - 1, 'D')) 
				+ xs:yearMonthDuration('P1M') - xs:dayTimeDuration('P1D') ) +  xs:dayTimeDuration('P1D'))), 'z','' ))" />
		</xsl:when>		
		<xsl:when test="$querySchedule = 'task:everyQuarter'">
			<xsl:sequence select="adjust-date-to-timezone(current-date() + $tso:oneQuarter, ())" />
		</xsl:when>
		<xsl:when test="$querySchedule = 'task:everyYear'">
			<xsl:sequence select="adjust-date-to-timezone(current-date() + $tso:oneYear, ())" />
		</xsl:when>
		<xsl:otherwise>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
<xsl:function name="tso:formatDuration">
	<xsl:param name="duration" as="xs:dayTimeDuration" />
	<xsl:choose>
		<xsl:when test="$duration > $tso:oneDay">
			<xsl:variable name="days" as="xs:decimal" select="floor($duration div $tso:oneDay)" />
			<xsl:variable name="remainder" as="xs:dayTimeDuration" select="$duration - ($days * $tso:oneDay)" />
			<xsl:choose>
				<xsl:when test="$remainder &lt; xs:dayTimeDuration('PT8H')">
					<xsl:sequence select="concat($days, if ($days > 1) then ' days' else ' day')" />
				</xsl:when>
				<xsl:when test="$remainder > xs:dayTimeDuration('PT16H')">
					<xsl:sequence select="concat($days + 1, ' days')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat($days, '.5 days')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$duration > $tso:oneHour">
			<xsl:variable name="hours" as="xs:decimal" select="floor($duration div $tso:oneHour)" />
			<xsl:variable name="remainder" as="xs:dayTimeDuration" select="$duration - ($hours * $tso:oneHour)" />
			<xsl:choose>
				<xsl:when test="$remainder &lt; xs:dayTimeDuration('PT20M')">
					<xsl:sequence select="concat($hours, if ($hours > 1) then ' hours' else ' hour')" />
				</xsl:when>
				<xsl:when test="$remainder > xs:dayTimeDuration('PT40M')">
					<xsl:sequence select="concat($hours + 1, ' hours')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat($hours, '.5 hours')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="minutes" as="xs:integer" select="xs:integer(format-number($duration div $tso:oneMinute, '#0'))" />
			<xsl:sequence select="concat($minutes, if ($minutes > 1) then ' minutes' else ' minute')" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:slug" as="xs:string">
	<xsl:variable name="milliseconds" as="xs:integer" 
		select="xs:integer(((current-dateTime() - xs:dateTime('2011-01-01T00:00:00')) div xs:dayTimeDuration('PT1S')) * 1000)" />
	<xsl:sequence select="tso:base36($milliseconds)" />
</xsl:function>

<xsl:function name="tso:slug" as="xs:string">
	<xsl:param name="index" as="xs:integer" />
	<xsl:sequence select="tso:slug(tso:slug(), $index)" />
</xsl:function>

<xsl:function name="tso:slug" as="xs:string">
	<xsl:param name="base" as="xs:string" />
	<xsl:param name="index" as="xs:integer" />
	<xsl:sequence select="concat($base, '-', tso:base36($index))" />
</xsl:function>

<xsl:function name="tso:base36" as="xs:string">
	<xsl:param name="number" as="xs:integer" />
	<xsl:sequence select="tso:base36($number, '')" />
</xsl:function>

<xsl:variable name="tso:base36digits" as="xs:string" select="'0123456789abcdefghijklmnopqrstuvwxyz'" />

<xsl:function name="tso:base36" as="xs:string">
	<xsl:param name="number" as="xs:integer" />
	<xsl:param name="result" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$number &lt; 36">
			<xsl:sequence select="concat($result, substring($tso:base36digits, $number + 1, 1))" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="remainder" as="xs:integer" select="$number mod 36" />
			<xsl:sequence select="tso:base36(($number - $remainder) idiv 36, concat(substring($tso:base36digits, $remainder + 1, 1), $result))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- include the default value for this variable which can be overridden from the importing xslt   -->
<!-- by default it is attempting to access an orbeon input document   -->
<xsl:variable name="paramsDoc" as="document-node()?" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
<!-- Resource file to have welsh text - for welsh version of site-->
<xsl:variable name="langResources" as="document-node()" select="doc('resources.xml')"/>
<xsl:variable name="allLangResources" as="element()+" select="$langResources/allResources/resources"/>
<xsl:variable name="currentLangResources" as="element()+" select="$langResources/allResources/resources[@lang=$TranslateLang]"/>
	
<!--WELSH version of site: the prefix attached to URLs of links from this page -->
<xsl:variable name="TranslateLangPrefix" select="leg:LangPrefix()"/>
<xsl:function name="leg:LangPrefix" as="xs:string?">
	<xsl:choose>
		<xsl:when test="$paramsDoc/parameters/wrapper = 'cy' or $paramsDoc/conditions/parameters/wrapper = 'cy' or starts-with($paramsDoc/request/request-path, '/cy')"><xsl:text>/cy</xsl:text></xsl:when>
		<xsl:when test="$paramsDoc/parameters/wrapper = 'en' or $paramsDoc/conditions/parameters/wrapper = 'en' or starts-with($paramsDoc/request/request-path, '/en')"><xsl:text>/en</xsl:text></xsl:when>		
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- the 2 charcater string language used for translation text - if no language prefix specified, default to "en" -->
	<xsl:variable name="TranslateLang" select="if (substring($TranslateLangPrefix,1,1) = '/') then substring($TranslateLangPrefix,2,2) else 'en' "/>

<!-- This is a generic function to pick up english and welsh text for english and welsh version of site
	It will get correct language string for the current language -->
<xsl:function name="leg:TranslateText" as="xs:string">
	<xsl:param name="id" as="xs:string"/>
	<!-- to reduce size of resources.xml, short pieces of English text have the same value as id attribute, so can use that instead -->
	<xsl:choose>
		<xsl:when test="$id = $currentLangResources/resource/@id">
			<xsl:choose>
				<xsl:when test="$TranslateLang = 'en' and not ($currentLangResources/resource[@id=$id]/text())">
					<xsl:value-of select="$id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentLangResources/resource[@id=$id]/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$id"/>
		</xsl:otherwise>	
	</xsl:choose>
</xsl:function>

<!-- So this version takes a sequence of paramater name/value pairs -->
<xsl:function name="leg:TranslateText" as="xs:string">
	<xsl:param name="id" as="xs:string"/>
	<xsl:param name="params" as="xs:string*"/>
	
	<xsl:variable name="paramXML" as="element()*">
		<xsl:for-each select="$params[contains(.,'=')]">
			<tso:param id="{substring-before(.,'=')}">
				<xsl:value-of select="substring-after(.,'=')"/>
			</tso:param>
		</xsl:for-each>
	</xsl:variable>
	<!-- to reduce size of resources.xml, short pieces of English text have the same value as id attribute, so can use that instead -->
	<xsl:value-of>
		<xsl:choose>
			<xsl:when test="$id = $currentLangResources/resource/@id">
				<xsl:choose>
					<xsl:when test="$TranslateLang = 'en' and not ($currentLangResources/resource[@id=$id]/text())">
						<xsl:value-of select="$id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$currentLangResources/resource[@id=$id]/node()" mode="utilsTranslate">
							<xsl:with-param name="paramXML" select="$paramXML"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$id"/>
			</xsl:otherwise>	
		</xsl:choose>
	</xsl:value-of>
</xsl:function>

<xsl:function name="leg:TranslateNode">
	<xsl:param name="id" as="xs:string"/>
	<!-- to reduce size of resources.xml, short pieces of English text have the same value as id attribute, so can use that instead -->
	<xsl:choose>
		<xsl:when test="$id = $currentLangResources/resource/@id">
			<xsl:choose>
				<xsl:when test="$TranslateLang = 'en' and not ($currentLangResources/resource[@id=$id]/text())">
					<xsl:value-of select="$id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$currentLangResources/resource[@id=$id]" mode="translate"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$id"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<!--Copy node without namespace-->
<xsl:template match="*" mode="translate">
	<xsl:element name="{local-name()}">
		<xsl:apply-templates select="@*|node()" mode="translate"/>
	</xsl:element>
</xsl:template>
<!-- only render the appropriate EU exit text -->
<xsl:template match="*[@rel and matches(@rel,'(deal|nodeal|extension|revoke|holding)')]" priority="10" mode="translate">
	<xsl:variable name="scenarios" as="xs:string*" select="if (contains(@rel, ' ')) then tokenize(@rel, ' ') else @rel"/>
	<xsl:if test="$brexitType = $scenarios">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*[not(name() = 'rel')]" mode="translate"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>
<!--Copy Attributes-->
<xsl:template match="@*" mode="translate">
	<xsl:copy />
</xsl:template>
<!--Suppress resource element-->
<xsl:template match="*:resource" mode="translate">
	<xsl:apply-templates select="@*|node()" mode="translate"/>
</xsl:template>

<xsl:template match="*" mode="utilsTranslate">
	<xsl:param name="paramXML" as="element()*"/>
	
	<xsl:choose>
		<xsl:when test="local-name()='param'">
			<xsl:value-of select="$paramXML[@id=current()/@ref-id]"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates select="node()" mode="utilsTranslate">
					<xsl:with-param name="paramXML" select="$paramXML"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
	
<xsl:template match="text()|processing-instruction()" mode="utilsTranslate">
	<xsl:param name="paramXML" as="element()*"/>
	<xsl:value-of select="."/>
</xsl:template>

<!-- Added a function to allow access to a different languages string
	e.g. on english page a message like "switch to welsh" would be in Welsh language (and vice versa) -->
<xsl:function name="leg:TranslateTextToLang" as="xs:string">
	<xsl:param name="id" as="xs:string"/>
	<xsl:param name="lang" as="xs:string"/>
	<xsl:variable name="resources" select="$allLangResources[@lang=$lang]"/>
	<!-- to reduce size of resources.xml, short pieces of English text have the same value as id attribute, so can use that instead -->
	<xsl:choose>
		<xsl:when test="$id = $resources/resource/@id">
			<xsl:choose>
				<xsl:when test="$lang = 'en' and not ($resources/resource[@id=$id]/text())">
					<xsl:value-of select="$id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$resources/resource[@id=$id]/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$id"/>
		</xsl:otherwise>	
	</xsl:choose>
</xsl:function>

	<xsl:function name="leg:base-date" as="xs:date">
		<xsl:param name="type" as="xs:string?"/>
		<xsl:sequence select="if ($type = ('NorthernIrelandOrderInCouncil', 'NorthernIrelandAct', 'NorthernIrelandParliamentAct')) then
								xs:date('2006-01-01')
							(:  we wont use the EU base date as such so choose the earliest date of 1957 when the EU was formed  :)
							else if ($type = ('EuropeanUnionRegulation', 'EuropeanUnionDecision', 'EuropeanUnionDirective', 'EuropeanUnionTreaty')) then
								xs:date('1957-01-01')
							else if ($type = ('NorthernIrelandStatutoryRule', 'UnitedKingdomStatutoryInstrument')) then
								xs:date('1948-01-01')
							else 
								xs:date('1991-02-01')"/>
	</xsl:function>	
	
	<xsl:function name="leg:string-to-date" as="xs:date?">
		<xsl:param name="string" as="xs:string?"/>
			<xsl:sequence 
				select="if ($string castable as xs:date) then 
							xs:date($string)
						else if (matches($string, '[0-9]{2}/[0-9]{2}/[0-9]{4}')) then
							xs:date(concat(substring($string, 7), '-' , substring($string, 4,2), '-' , substring($string, 1,2)))
						else ()
			"/>
	</xsl:function>	
	
	<xsl:function name="leg:revisedLegislationTypes" as="xs:string+">
		<xsl:sequence 
			select="('', 'all', 'primary', 'ukpga', 'ukla', 'apgb', 'aep', 'aosp', 'asp', 'aip', 'apni', 'mnia', 'nia', 'ukcm', 'mwa', 'nisi','anaw', 'asc', 'eudn', 'eur', 'eudr', 'eut', 'uksi', 'ssi', 'wsi', 'nisr', 'eur', 'eudn', 'eudr', 'eut')"/>
	</xsl:function>
	
	<xsl:function name="leg:extents" as="xs:string+">
		<xsl:sequence 
			select="('E+W+S+N.I.', 'E+W+S', 'E+W', 'S', 'N.I.', 'W', 'E', 'E+S', 'E+N.I.', 'W+S', 'W+N.I.', 'S+N.I.', 'E+W+N.I.', 'E+S+N.I.', 'W+S+N.I.')"/>
	</xsl:function>
	
	<xsl:function name="leg:get-extent" as="xs:string?">
		<xsl:param name="node" as="node()?"/>
		<xsl:value-of 
			select="$node/ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent"/>
	</xsl:function>	
	
	<xsl:function name="leg:get-full-extent" as="xs:string?">
		<xsl:param name="node" as="node()?"/>
		<xsl:variable name="fragmentNode" select="$node/ancestor-or-self::*[@RestrictExtent][1]"/>
		<xsl:variable name="fragmentExtent" as="xs:string*" select="tokenize($fragmentNode/@RestrictExtent, '\+')"/>
		<xsl:variable name="versionExtent" as="xs:string*" >
			<xsl:if test="$fragmentNode/@Concurrent = 'true'">
				<xsl:for-each select="tokenize($fragmentNode/@AltVersionRefs, ' ')">
					<xsl:variable name="ref" select="."/>
					<xsl:value-of select="$node/root()//leg:Versions/leg:Version[@id = $ref]/*/@RestrictExtent"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="leg:concatenate-extents(($fragmentExtent, $versionExtent))"/>
	</xsl:function>

	<xsl:function name="leg:concatenate-extents" as="xs:string?">
		<xsl:param name="extents" as="xs:string*"/>
		<xsl:variable name="extentCollationRules" select="'&lt; E &lt; W &lt; S  &lt; N'" />
		<xsl:variable name="sorted" as="xs:string*" >
			<xsl:perform-sort select="$extents">
				<xsl:sort select="." collation="http://saxon.sf.net/collation?alphanumeric=yes&amp;rules={encode-for-uri($extentCollationRules)}"/>			
			</xsl:perform-sort>
		</xsl:variable>
		<xsl:value-of select="string-join(($sorted), '+')"/>
	</xsl:function>
		
	<xsl:template name="deleteTaskWindow">
		<xsl:param name="taskName" as="xs:string?" select="()"/>
		<div class="modWin" id="deleteTask">
			<form action="" method="post" class="submit">
				<div class="title">
					<h3>Delete <xsl:value-of select="if($taskName) then $taskName else 'this'"/> task</h3>
				</div>
				<div class="content">
					<input type="hidden" name="status" value="deleted" />
					<div>
						<label for="return-note">
							Reason for deleting <xsl:value-of select="if($taskName) then concat('this ',$taskName) else 'the'"/> task:
						</label>
						<textarea id="return-note" cols="30" rows="3" name="note-content">
							<xsl:text>&#xA;</xsl:text>
						</textarea>
					</div>
				</div>
				<div class="interface">
					<ul>
						<li class="submit-right">
							<button class="button task" type="submit">
								<span>Delete</span>
							</button>
						</li>
					</ul>
				</div>
			</form>
		</div>
	</xsl:template>	
	
	<xsl:function name="utils:make-imagedata-uri" as="xs:string?">
		<xsl:param name="uri" as="xs:string*"/>
		<xsl:value-of 
			select="if ( matches($uri, '(/[0-9]{4}-[0-9]{2}-[0-9]{2}|/made|/enacted|/created|/adopted)?(/welsh|/english)?(/revision)')) then
						replace($uri, '(/[0-9]{4}-[0-9]{2}-[0-9]{2}|/made|/enacted|/created|/adopted)?(/welsh|/english)?(/revision)', '/imagedata$1$2$3')
					else if ( matches($uri, '(/[0-9]{4}-[0-9]{2}-[0-9]{2}|/made|/enacted|/created|/adopted)?(/welsh|/english)(/revision)?')) then
						replace($uri, '(/[0-9]{4}-[0-9]{2}-[0-9]{2}|/made|/enacted|/created|/adopted)?(/welsh|/english)(/revision)?', '/imagedata$1$2$3')						
					else if ( matches($uri, '(/[0-9]{4}-[0-9]{2}-[0-9]{2}|/made|/enacted|/created|/adopted)$')) then
						replace($uri, '(/[0-9]{4}-[0-9]{2}-[0-9]{2}|/made|/enacted|/created|/adopted)','/imagedata$1') 
					else concat($uri, '/imagedata')"/>
	</xsl:function>
	
</xsl:stylesheet>
