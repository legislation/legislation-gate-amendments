<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI Legislation Table of Contents/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
	>
	
	<!-- ========== Standard code for outputing UI wireframes========= -->
	
	<xsl:import href="statuswarning.xsl"/>
	<xsl:import href="legislation_xhtml_consolidation.xslt"/>
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="uicommon.xsl"/>	
	
	<xsl:output indent="yes" method="xhtml" />
	
	<xsl:variable name="dcIdentifier" select="leg:Legislation/ukm:Metadata/dc:identifier"/>
	
	<xsl:variable name="nstSection" as="element()?"
		select="if ($nstSelectedSection/parent::leg:P1group) then $nstSelectedSection/.. else $nstSelectedSection" />
	
	<xsl:variable name="wholeActURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/act' and @title='whole act']/@href" />
	<xsl:variable name="wholeActWithoutSchedulesURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/body' and @title='body']/@href" />
	<xsl:variable name="schedulesOnlyURI" as="xs:string?" select="(/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/schedules' and @title='schedules']/@href, /leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/annexes' and @title='annexes']/@href)[1]" />
	<xsl:variable name="attachmentsOnlyURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/attachments' and @title='attachments']/@href" />
	<xsl:variable name="introURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/introduction' and @title='introduction']/@href" />
	
	

	<xsl:variable name="language" select="if (/leg:Legislation/@xml:lang) then 
			/leg:Legislation/@xml:lang
		else 'en'"/>
	
	<xsl:variable name="prospDoc" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'prospective']/@href"/>
	<xsl:variable name="signatureURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/signature' and @title='signature']/@href"/>
	<xsl:variable name="noteURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/note']/@href"/>
	<xsl:variable name="earlierOrdersURI" as="xs:string?" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/earlier-orders']/@href"/>
	
	<xsl:variable name="tocURI" as="xs:string?" select="
		if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='cy'] and $language = 'cy') then 
			/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='cy']/@href
			else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='en']) then 
			/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='en']/@href
			else if (/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents']) then 
			/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][1]/@href
		else /leg:Legislation/@DocumentURI
	"/>
	<xsl:variable name="resourceURI" as="xs:string" 
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/resources']/@href" />				
	<xsl:variable name="impactURI" as="xs:string?" 
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/impacts']/@href" />	
	<xsl:variable name="updateFeedURI" as="xs:string?" 
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/updates']/@href" />	
	
	<xsl:variable name="legislationIdURI"  select="/leg:Legislation/@IdURI"/>		

	<xsl:variable name="enURI" as="xs:string?" 
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/notes/toc' and not(@hreflang = 'cy')]/@href | 
		        /leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/executive-note/toc']/@href"/>
	<xsl:variable name="emURI" as="xs:string?"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/memorandum/toc' and not(@hreflang = 'cy')]/@href"/>
		
		

	<xsl:variable name="pnURI" as="xs:string?"
		select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/policy-note/toc']/@href"/>
	
	<xsl:variable name="IsEnAvailable" as="xs:boolean" select="exists($enURI)"/>
	<xsl:variable name="IsEmAvailable" as="xs:boolean" select="exists($emURI)"/>	
	<xsl:variable name="IsPnAvailable" as="xs:boolean" select="exists($pnURI)"/>
	
	<xsl:variable name="IsMoreResourcesAvailable" as="xs:boolean" select="tso:ShowMoreResources(/)" />			
	<xsl:variable name="IsImpactAssessmentsAvailable" as="xs:boolean" select="exists($impactURI)" />
	<xsl:variable name="IsUpdatesFeedAvailable" as="xs:boolean" select="exists($updateFeedURI)" />
	
	<xsl:variable name="IsPDFOnly" as="xs:boolean">
		<xsl:sequence select="leg:IsPDFOnly(.)" />
	</xsl:variable>	

<xsl:variable name="IsRevisedPDFOnly" as="xs:boolean">
		<xsl:sequence select="leg:IsRevisedPDFOnly(.)" />
	</xsl:variable>		
	
	<xsl:variable name="paragraphThreshold" select="200"/>
	
	<!--  let $showTimeline be true if the timeline parameter is 'true', otherwise false  -->
	<xsl:param name="paramTimeline" as="xs:string" select="'false'" />	
	<xsl:variable name="showTimeline" as="xs:boolean" 
		select="contains(leg:get-query('timeline'), 'true') or $paramTimeline = 'true'"  />
		
	<xsl:param name="paramShowRepeals" as="xs:string" select="'false'" />			
	<xsl:variable name="showRepeals" as="xs:boolean" 
		select="contains(leg:get-query('repeals'), 'true') or $paramShowRepeals = 'true'"  />		
		
	<xsl:variable name="whatVersionScenario" as="xs:string">
		<xsl:call-template name="TSOGetScenarios">
			<xsl:with-param name="type" select="'whatversion'"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="showENinterweaveOption" as="xs:boolean"
			select="tso:ENInterweavedAllowed(leg:GetDocumentMainType(.))  and
				($IsEnAvailable or $IsEmAvailable) and
				(if ($whatVersionScenario = ('B','D') or ($whatVersionScenario = 'A' and leg:IsCurrentOriginal(.) )) then true() else false())"/>
	
	<xsl:variable name="showENinterweave" as="xs:boolean" 
		select="$showENinterweaveOption and contains(leg:get-query-param('view'), 'interweave')"  />		
	
	<xsl:variable name="showTextualEffects" as="xs:boolean"
		select="tokenize(leg:get-query-param('view'), '\+') = 'textualEffects'" />
	<xsl:variable name="showCommencementEffects" as="xs:boolean"
		select="tokenize(leg:get-query-param('view'), '\+') = 'commencementEffects'" />
	<xsl:variable name="showExtentEffects" as="xs:boolean"
		select="tokenize(leg:get-query-param('view'), '\+') = 'extentEffects'" />
	
	<xsl:variable name="forceShowExtent" as="xs:boolean"
		select="(exists($nstSection[@AltVersionRefs]) and $nstSection/(self::leg:P1group or self::leg:P1)) or $searchingByExtent" />
	<xsl:variable name="showExtent" as="xs:boolean"
		select="$forceShowExtent or tokenize(leg:get-query-param('view'), '\+') = 'extent'" />

	<xsl:variable name="correctionSlipTitle" as="xs:string"
			select="if ($g_strDocumentType = $g_strEUretained) then 'Corrigendum' else 'Correction Slip'" />
			
	<xsl:variable name="isLarge" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$wholeActURI = $dcIdentifier and /leg:Legislation/@NumberOfProvisions &gt; 800"><xsl:value-of select="true()"/></xsl:when>					
			<xsl:when test="$nstSection/@NumberOfProvisions &gt; 800"><xsl:value-of select="true()"/></xsl:when>			
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:function name="tso:IncludeInlineTooltip" as="xs:boolean">
		<xsl:sequence select="not($isLarge)" />
	</xsl:function>

	<!--  let $selectedSection be the (XML element of the) section that's being looked at, which you already get hold of  -->
		<xsl:variable name="selectedSection" as="element()?"
		select="
			if ($wholeActURI = $dcIdentifier) then /leg:Legislation
			else if ($dcIdentifier = ($introURI, $signatureURI,  $earlierOrdersURI, $noteURI, $wholeActWithoutSchedulesURI)) then  /leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)//*[@DocumentURI = $strCurrentURIs]
			else if ($dcIdentifier = $schedulesOnlyURI)  then /leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)/leg:Schedules
			else $nstSection" />
	
	<!--  let $startDate be the latest value of RestrictStartDate on $selectedSection or any of its descendants -->
	<xsl:variable name="restrictStartDate" select="max(($selectedSection/descendant-or-self::*[not(@Match = 'false')]/@RestrictStartDate/xs:date(.), key('g_keyNodeIDs', tokenize($selectedSection/@AltVersionRefs, ' '))/*/descendant-or-self::*[not(@Match = 'false')]/@RestrictStartDate/xs:date(.)) )"/>
	<!-- if there's no valid start date (on a section without @Match = 'false') then look at the RestrictStartDate attribute of the section that's actually been requested	 -->
	<xsl:variable name="startDate" select="if (empty($restrictStartDate)) then $selectedSection/@RestrictStartDate/xs:date(.) else $restrictStartDate"/>
	
	<!--  let $dead be true if the $selectedSection is Dead -->
	<xsl:variable name="dead" as="xs:boolean" select="$selectedSection/@Status = 'Dead'" />
	<!--  let $endDate be the earliest value of the RestrictEndDate on $selectedSection or any of its descendants -->
	<xsl:variable name="endDate" 
		select="if ($dead) then
							$selectedSection/@RestrictEndDate
		        else
		          string(min(($selectedSection/descendant-or-self::*[not(@Match = 'false')]/@RestrictEndDate/xs:date(.),  key('g_keyNodeIDs', tokenize($selectedSection/@AltVersionRefs, ' '))/*/descendant-or-self::*[not(@Match = 'false')]/@RestrictEndDate/xs:date(.))))"/>		
	<!--  let $prospective be true if the Status attribute on $selectedSection is 'Prospective' or 'Dead' and $selectedSection has not RestrictStartDate-->
	<xsl:variable name="prospective" as="xs:boolean" 
		select="$dead or (not($selectedSection/@RestrictStartDate) and $selectedSection/@Status = 'Prospective') or ($selectedSection//*[not(@Match = 'false') and not(@RestrictStartDate) and @Status = 'Prospective'])"/>		
	<!--  let $repealed be true if the Match attribute on $selectedSection is false and either the $version is 'prospective' and there is an $endDate or the $endDate is before or equal to $version -->
	<xsl:variable name="repealed" as="xs:boolean" select="$dead or (($endDate castable as xs:date) and $selectedSection/@Match = 'false' and ( $version = 'prospective' or  xs:date($endDate) &lt;= leg:GetVersionDate($version)))"/>				
	<!--  let $notYetInForce be true if the Match attribute on $selectedSection is false and the $startDate is after $version  -->
	<xsl:variable name="notYetInForce" as="xs:boolean"  select="($startDate castable as xs:date) and $selectedSection/@Match = 'false' and xs:date($startDate) &gt; leg:GetVersionDate($version) "/>							
	
	<!--  flag for arranging the pointers equally -->
	<xsl:variable name="arrangePointersEqually" as="xs:boolean" select="true()"/>			
	
	<!-- getting the document type -->
	<xsl:function name="leg:GetDocumentMainType" as="xs:string">
		<xsl:param name="legislation" as="document-node()" />
		<xsl:sequence select="$legislation/*/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
	</xsl:function>	
	
	<!-- uri Prefix-->
	<xsl:variable name="uriPrefix" as="xs:string"><xsl:value-of select="tso:GetUriPrefixFromType(leg:GetDocumentMainType(.), /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:Year/@Value)"/></xsl:variable>
	<xsl:variable name="documentMainType" as="xs:string" select="leg:GetDocumentMainType(.)"/>

	<!-- Construct a list of the ContentRefs of the items that have MatchText="true" up front -->
	<xsl:variable name="searchingByText" as="xs:string?" select="$paramsDoc/parameters/text[. != '']" />
	<xsl:variable name="searchingByExtent" as="xs:string?" select="($paramsDoc/parameters/extent[. != ''], $paramsDoc/parameters/extent-query[. != ''])[1]" />
	<xsl:variable name="matchTextEntries" as="xs:string*" select="tokenize(/leg:Legislation/leg:Contents/@MatchTextEntries, ' ')" />
	<xsl:variable name="matchExtentEntries" as="xs:string*" select="tokenize(/leg:Legislation/leg:Contents/@MatchExtentEntries, ' ')" />
	<xsl:variable name="matchEntries" as="xs:string*" select="distinct-values(($matchTextEntries, $matchExtentEntries))" />
	<xsl:variable name="matchRefs" 
		select="if ($searchingByText and $searchingByExtent) then (
							if ($matchTextEntries = 'introduction' and $matchExtentEntries = 'introduction') then 'introduction' else (),
							//leg:ContentsItem[@MatchText = 'true' and @MatchExtent = 'true']/@ContentRef,
							for $entry in ('signature', 'note', 'earlier-orders')[$matchTextEntries = . and $matchExtentEntries = .]
							return
								$entry
						) else if ($searchingByText or $searchingByExtent) then 
							($matchEntries[. = 'introduction'], //leg:Contents//*[@MatchText = 'true' or @MatchExtent = 'true']/@ContentRef, $matchEntries[. != 'introduction'])
						else
							()"/>
	<xsl:variable name="linkFragment" as="xs:string?"
		select="if ($searchingByExtent or $searchingByText) then 
		          concat('#', encode-for-uri(string-join((
		            if ($searchingByText) then concat('text=', $searchingByText) else (), 
		            if ($searchingByExtent) then concat('extent=', $searchingByExtent) else () 
		          ), '&amp;'))) 
		        else 
		          ()" /> 
	
	
	<xsl:variable name="isDraft" as="xs:boolean" select="leg:IsDraft(.)"/>
	
	<!-- initializing the introductory text & signature text-->
	<xsl:variable name="introductoryText">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
					<xsl:text>Testun rhagarweiniol</xsl:text>
			</xsl:when>
			<xsl:otherwise>
					<xsl:text>Introductory Text</xsl:text>			
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>
	<xsl:variable name="signatureText">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
					<xsl:text>Llofnod</xsl:text>
			</xsl:when>
			<xsl:otherwise>
					<xsl:text>Signature</xsl:text>			
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:variable>
	<xsl:variable name="noteText">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
				<xsl:text>Nodyn Esboniadol</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Explanatory Note</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="earlierOrdersText">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
				<xsl:text>Nodyn Orchymyn Cychwyn Blaenorol</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Note as to Earlier Commencement Orders</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="scheduleText">
		<xsl:value-of select="if ($g_strDocumentType = $g_strEUretained) then 'Annex' else 'Schedule'"/>
	</xsl:variable>
	
	<xsl:variable name="schedulesText">
		<xsl:value-of select="if ($g_strDocumentType = $g_strEUretained) then 'Annexes' else 'Schedules'"/>
	</xsl:variable>
	
	<xsl:variable name="attachmentsText">
		<xsl:value-of select="'Attachments'"/>
	</xsl:variable>
	
	<xsl:variable name="dc-title" as="element(dc:title)*" select="/leg:Legislation/ukm:Metadata/dc:title"/>
	
	<xsl:variable name="title">
		<xsl:choose>
			<xsl:when test="$language = 'cy' and count($dc-title) &gt; 1">
				<xsl:value-of select="$dc-title[@xml:lang='cy']" />
			</xsl:when>
			<xsl:when test="$language = 'cy' and count($dc-title) = 1 ">
				<xsl:value-of select="$dc-title" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dc-title[not(@xml:lang='cy')]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:choose>
						<xsl:when test="$language = 'cy'">
							<xsl:value-of select="$dc-title[@xml:lang='cy']" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dc-title[not(@xml:lang='cy')]" />
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<!--<meta name="DC.Date.Modified" content="{/leg:Legislation/ukm:Metadata/dc:modified}" />-->
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata" />
				
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
				
				<xsl:if test="$showTimeline">
					<link rel="stylesheet" href="/styles/view/changesOverTime.css" type="text/css" />
					<script type="text/javascript" src="/scripts/jquery-ui-1.8.24.custom.min.js"></script>
					<script type="text/javascript" src="/scripts/view/jquery.ui.slider.min.js"></script>
					<script type="text/javascript" src="/scripts/view/scrollbar.js"></script>
				</xsl:if>
				
				<xsl:if test="$showENinterweave and 
						exists(/leg:Legislation/ukm:Metadata/atom:link[@rel=
								('http://www.legislation.gov.uk/def/navigation/notes', 'http://www.legislation.gov.uk/def/navigation/memorandum')])
						">
					<script type="text/javascript" src="/scripts/eniw/eniw_leg.gov.uk.js"></script>	
					<link rel="stylesheet" href="/styles/explanatoryNotesInterweave.css" type="text/css"/>			
				</xsl:if>
				
				<xsl:if test="$showTextualEffects or $showCommencementEffects or $showExtentEffects">
					<script type="text/javascript" src="/scripts/jquery-ui-1.8.1.custom.min.js"></script>
					<script type="text/javascript" src="/scripts/participation/jquery.ui.autocomplete.min.js"></script>
					<script type="text/javascript" src="/scripts/participation/effects.js"></script>
					<link rel="stylesheet" href="/styles/advancedsearch/jquery-ui.css" type="text/css" />
					<link rel="stylesheet" href="/styles/participation/interweave.css" type="text/css" />
				</xsl:if>
				
				<xsl:if test="$showTextualEffects">
					<script type="text/javascript" src="/scripts/participation/textualEffects.js"></script>
					<link rel="stylesheet" href="/styles/participation/legislation/textualEffects.css" type="text/css" />
				</xsl:if>
				
				<xsl:if test="$showCommencementEffects">
					<script type="text/javascript" src="/scripts/participation/commencementEffects.js"></script>
					<script type="text/javascript" src="/scripts/advancedsearch/jquery.ui.datepicker.min.js"></script>
					<link rel="stylesheet" href="/styles/participation/legislation/commencementEffects.css" type="text/css" />
					<link rel="stylesheet" href="/styles/advancedsearch/jquery.ui.datepicker.css" type="text/css" />
				</xsl:if>
				
				<xsl:if test="$showExtentEffects">
					<script type="text/javascript" src="/scripts/participation/extentEffects.js"></script>
					<link rel="stylesheet" href="/styles/participation/legislation/extentEffects.css" type="text/css" />
				</xsl:if>
				
				<!-- commenting out the highlighting
				<xsl:if test="leg:IsContentTabDisplaying()">
					
					<xsl:comment><![CDATA[[if IE]><script type="text/javascript" src="/scripts/json2.js"></script><![endif]]]></xsl:comment>
					<script type="text/javascript">
					
						var varType;
						var varUrl;
						var varData;
						var varContentType;
						var varDataType;
						var varProcessData;          
						//Generic function to call AXMX/WCF  Service        
						function CallService() 
						{
								$.ajax({
									type        : varType, //GET or POST or PUT or DELETE verb
									url         : varUrl, // Location of the service
									data        : varData, //Data sent to server
									contentType : varContentType, // content type sent to server
									dataType    : varDataType, //Expected data format from server
									processdata : varProcessData, //True or False
									success     : function(msg) {//On Successfull service call
									ServiceSucceeded(msg);                    
									},
									error: ServiceFailed// When Service call fails
								});
						}
				
						function ServiceSucceeded(result) {//When service call is sucessful
							$('#viewLegSnippet').html($(result).find("string").text());
							varType=null;varUrl = null;varData = null;varContentType = null;varDataType = null;varProcessData = null;     
						}
						function ServiceFailed(result) {
							//alert('Service call failed: ' + result.status + '' + result.statusText);
							varType = null; varUrl = null; varData = null; varContentType = null; varDataType = null; varProcessData = null;     
						}
	
						function RunHighlight()
						{
							var hash = unescape(window.location.hash);
							
							if (hash.substring(0,6) == "#text=")
							{
								<xsl:variable name="view" as="xs:string*" select="tokenize(leg:get-query-param('view'),'\+')"/>
								<xsl:variable name="href"  as="xs:string"
									select="leg:set-query-params('view', 
													string-join( ($view, 'hits'), '+') )"/>
								<xsl:variable name="highlightURI" as="xs:string">
									<xsl:value-of select="concat('/highlightdatasnippet.htm', '?', $href)"/>
								</xsl:variable>							
								
								varType = 'POST';
								varUrl = '<xsl:value-of select="$highlightURI"/>' ;
								varData = JSON.stringify({sourceText: $('#viewLegSnippet').html(), searchText: hash.substring(hash.indexOf("text=")+5)});
								varContentType = "application/json; charset=utf-8"; 
								varDataType = "xml"; 
								varProcessData = true;
								CallService();
							}
						}
					</script>				
				</xsl:if>-->
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}" class="{concat('browse', if ($showExtent) then ' geoExtShowing' else '', if ($pointInTimeView and $version != 'prospective') then ' pointInTimeView' else '', if ($repealed) then ' hideChangestoLegislation' else '', if ($isLarge) then ' removeScripting' else '')}">
				<!-- commenting out the highlighting
					<xsl:if test="leg:IsContentTabDisplaying()">
						<xsl:attribute name="onload">RunHighlight();</xsl:attribute>
					</xsl:if>
				 -->
			
				<div id="layout2">
					<xsl:choose>
						<xsl:when test="leg:IsTOC()"><xsl:attribute name="class">legToc</xsl:attribute></xsl:when>
						<xsl:when test="$IsPDFOnly"><xsl:attribute name="class">legToc</xsl:attribute></xsl:when>
						
						<xsl:when test="$dcIdentifier = ($signatureURI, $noteURI, $earlierOrdersURI)"><xsl:attribute name="class">legContent</xsl:attribute></xsl:when>
						<xsl:when test="leg:IsContent()"><xsl:attribute name="class">legContent</xsl:attribute></xsl:when>						
						<xsl:when test="$dcIdentifier = ($wholeActURI, $wholeActWithoutSchedulesURI, $schedulesOnlyURI, $attachmentsOnlyURI) or matches($dcIdentifier, '[0-9]+/(ni|england|scotland|wales)')"><xsl:attribute name="class">legComplete</xsl:attribute></xsl:when>												
						<xsl:otherwise/>
					</xsl:choose>
					
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
				
					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>
				
					 <!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"	/>
					
					<!-- Sub Navigation tabs-->
					<xsl:call-template name="TSOOutputSubNavTabs" />
					
					<div class="interface">
				  
						<!-- adding the links for previous and next links-->
						<xsl:call-template name="TSOOutputPreviousNextLinks"/>

						<!-- adding the links for view print links-->
						<xsl:call-template name="TSOOutputViewPrintLinks"/>

					</div>
					<!--./interface -->

					<div id="tools">
						<!-- what version functionality-->
						<xsl:call-template name="TSOOutputWhatVersionScenario" />
						
						<!-- advanced search-->
						<xsl:call-template name="TSOOutputAdvancedSearch" />					
						
						<!-- opening options functionality-->					
						<xsl:call-template name="TSOOutputOpeningOptions" />
						
						<!-- editing effects functionality -->
						<xsl:call-template name="TSOOutputEffectsOptions" />
						
						<!-- more resources functionality-->
						<xsl:call-template name="TSOOutputMoreResources" />

						<!-- versioning functionality -->
						<xsl:call-template name="TSOOutputRevisionOptions" />
					</div>
					 <!--/tools-->				
				 
					<div id="content">
					
						<!-- outputing the legislation status and timeline-->
						<xsl:call-template name="TSOOutputLegislationStatusTimeline" />
								
						<!-- outputing the legislation content-->
						<xsl:call-template name="TSOOutputLegislationContent" />

                        <div class="contentFooter">
                            
                            <div class="interface">

                                <!-- adding the links for previous and next links-->
                                <xsl:call-template name="TSOOutputPreviousNextLinks"/>

                            </div>
                            
                        </div>

						<p class="backToTop">
							<a href="#top">Back to top</a>
						</p>

					</div>
					<!--/content-->
					
				</div>
				<!--layout2 -->
			
				<!-- Where all of the Help divs and modal windows are loaded -->
				<h2 class="interfaceOptionsHeader">Options/Help</h2>

				<!-- adding the view/print options-->
				<xsl:call-template name="TSOOutputPrintOptions"	/>
				
				<!-- opening options model -->
				<xsl:call-template name="TSOOutputOpeningOptionsWarning"/>
				
				<!-- help tips -->
				<xsl:call-template name="TSOOutputHelpTips"/>					
					
			</body>
		</html>
	
	</xsl:template>
	
	
	<!-- ========== CSS Styles for Legislation =============-->
	<xsl:template name="TSOOutputAddLegislationStyles">
		<style type="text/css">
			<xsl:text>/* Legislation stylesheets - load depending on content type */&#xA;</xsl:text>
			<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="$uriPrefix ='ukpga' or  $uriPrefix ='ukla'  or  $uriPrefix ='cukla'  or  $uriPrefix ='ukcm'  ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>				
				<xsl:when test="$uriPrefix ='apgb' or  $uriPrefix ='aosp'  or  $uriPrefix ='aip'  or  $uriPrefix ='mnia'  or  $uriPrefix ='apni'  or  $uriPrefix ='mwa'  or  $uriPrefix ='anaw'">
					<xsl:text>@import "/styles/SPOprimarylegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/SPOlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='aep' or  $uriPrefix ='asp' ">
					<xsl:text>@import "/styles/SPOlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/primarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix ='nia' ">
					<xsl:text>@import "/styles/NIlegislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix = ('uksi', 'ukmd', 'ssi', 'wsi', 'nisr', 'ukci', 'nisi', 'ukmo', 'uksro', 'nisr')">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>												
				<xsl:when test="$uriPrefix ='ukdsi' or  $uriPrefix ='sdsi'  or  $uriPrefix ='wdsi'  or  $uriPrefix ='nidsr'">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/secondarylegislation.css";&#xA;</xsl:text>
				</xsl:when>
				<xsl:when test="$uriPrefix = ('eudr', 'eudn', 'eur', 'eut') ">
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
					<xsl:text>@import "/styles/eulegislation.css";&#xA;</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:text>@import "/styles/legislationOverwrites.css";&#xA;</xsl:text>			
			<xsl:text>/* End of Legislation stylesheets */&#xA;</xsl:text>	
		</style>							

		<xsl:comment><![CDATA[[if IE 6]>
	<style type="text/css">
		@import "/styles/IE/ie6LegAdditions.css";
	</style>
<![endif]]]></xsl:comment>
		<xsl:comment><![CDATA[[if IE 7]>
	<style type="text/css">
		@import "/styles/IE/ie7LegAdditions.css";
	</style>
<![endif]]]></xsl:comment>		
	</xsl:template>
	
	
	<!-- ========== Standard code for what version ========= -->
	<!-- outputting the what version box based on the scenarios-->			
	<xsl:template name="TSOOutputWhatVersionScenario">
		<xsl:choose>
			<xsl:when test="$whatVersionScenario='A' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="true()"/>
					<xsl:with-param name="selectRevisedVersion" select="leg:IsCurrentRevised(.)"/>
					<xsl:with-param name="enableOriginalVersion" select="true()"/>
					<xsl:with-param name="selectOriginalVersion" select="leg:IsCurrentOriginal(.)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$whatVersionScenario='B' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="false()"/>
					<xsl:with-param name="selectRevisedVersion" select="false()"/>
					<xsl:with-param name="enableOriginalVersion" select="true()"/>
					<xsl:with-param name="selectOriginalVersion" select="true()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$whatVersionScenario='C' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="true()"/>
					<xsl:with-param name="selectRevisedVersion" select="leg:IsCurrentRevised(.)"/>
					<xsl:with-param name="enableOriginalVersion" select="false()"/>
					<xsl:with-param name="selectOriginalVersion" select="false()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$whatVersionScenario='D' ">
				<xsl:call-template name="TSOOutputWhatVersion">
					<xsl:with-param name="enableRevisedVersion" select="false()"/>
					<xsl:with-param name="selectRevisedVersion" select="false()"/>
					<xsl:with-param name="enableOriginalVersion" select="true()"/>
					<xsl:with-param name="selectOriginalVersion" select="true()"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- outputting the whatversion box with the selected properties-->			
	<xsl:template name="TSOOutputWhatVersion">
		<xsl:param name="enableRevisedVersion" as="xs:boolean"/>
		<xsl:param name="selectRevisedVersion" as="xs:boolean"/>
		<xsl:param name="enableOriginalVersion" as="xs:boolean"/>
		<xsl:param name="selectOriginalVersion" as="xs:boolean"/>
		<div class="section" id="whatVersion">
			<div class="title">
			  <h2>What Version</h2>
					<a href="#whatversionHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about what version"/>
				</a>
			</div>
			<div class="content">
				<ul class="toolList">
					<xsl:choose>
						<xsl:when test="leg:IsDraft(.)">
							<li>
								<span class="userFunctionalElement active" >
									<span class="background">
										<span class="btl"/>
										<span class="btr"/>Draft legislation<span class="bbl"/>
										<span class="bbr"/>
									</span>
								</span>
							</li>
						</xsl:when>
						<xsl:when test="leg:IsProposedVersion(.)">
							<li>
								<span class="userFunctionalElement active" >
									<span class="background">
										<span class="btl"/>
										<span class="btr"/>Proposed legislation<span class="bbl"/>
										<span class="bbr"/>
									</span>
								</span>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li>
						<xsl:variable name="ndsLatestAvailable">
							<span class="background">
								<span class="btl"/>
								<span class="btr"/>Latest available (Revised)<span class="bbl"/>
								<span class="bbr"/>
							</span>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$enableRevisedVersion">
								<xsl:choose>
									<xsl:when test="$selectRevisedVersion and not($pointInTimeView)">
										<span class="userFunctionalElement active" >
											<xsl:copy-of select="$ndsLatestAvailable" />
										</span>
									</xsl:when>
									<xsl:otherwise>
										<a href="{leg:FormatURL(//atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title='current']/@href)}" class="userFunctionalElement">
											<xsl:copy-of select="$ndsLatestAvailable" />
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<span class="userFunctionalElement disabled">
									<xsl:copy-of select="$ndsLatestAvailable" />
								</span>
							</xsl:otherwise>
						</xsl:choose>
				</li>
				<li>
					<xsl:variable name="ndsOriginal">
					<span class="background">
						<span class="btl"/>
						<span class="btr"/>
						<xsl:text>Original (As </xsl:text>
						<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
						<xsl:text>)</xsl:text>
						<xsl:if test="leg:IsWelshExists(.)"><xsl:text> - English</xsl:text></xsl:if>
						<span class="bbl"/>
						<span class="bbr"/>
					</span>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$enableOriginalVersion = true()">
							<xsl:choose>
								<xsl:when test="$selectOriginalVersion = true() and not($pointInTimeView)">
									<xsl:choose>
										<xsl:when test="not(leg:IsCurrentWelsh(.))">
											<span class="userFunctionalElement active">
												<xsl:copy-of select="$ndsOriginal" />
											</span>
										</xsl:when>
										<xsl:otherwise>
											<a href="{leg:FormatURL(//atom:link[@rel='alternate' and @hreflang='en']/@href)}" class="userFunctionalElement" >
												<xsl:copy-of select="$ndsOriginal" />
											</a>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
												<xsl:variable name="enactedLink" as="element(atom:link)?" select="//atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = ('enacted', 'made', 'created', 'adopted') and (not(@hreflang) or @hreflang='en')]" />
												<!-- this changes the link if we're looking a PDF-only revised version to go to the as-enacted ToC -->
												<xsl:variable name="enactedLink" as="xs:string?"
													select="if ($IsPDFOnly and not(contains($enactedLink/@href,'/contents/'))) then
													          replace($enactedLink/@href, concat('/', $enactedLink/@title), concat('/contents/', $enactedLink/@title))
													        else
													        	$enactedLink/@href" />
												<a href="{leg:FormatURL($enactedLink)}" class="userFunctionalElement" >
										<xsl:copy-of select="$ndsOriginal" />
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<span class="userFunctionalElement disabled">
								<xsl:copy-of select="$ndsOriginal" />
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</li>			
			
				<xsl:if test="leg:IsWelshExists(.)">
					<li>
						<xsl:variable name="ndsOriginal">
						<span class="background">
							<span class="btl"/>
							<span class="btr"/>
							<xsl:text>Original (As </xsl:text>
							<xsl:value-of select="leg:GetCodeSchemaStatus(.)"/>
							<xsl:text>) - Welsh</xsl:text>
							<span class="bbl"/>
							<span class="bbr"/>
						</span>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$enableOriginalVersion = true()">
								<xsl:choose>
									<xsl:when test="$selectOriginalVersion = true() and not($pointInTimeView)">
										<xsl:choose>
											<xsl:when test="leg:IsCurrentWelsh(.)">
												<span class="userFunctionalElement active">
													<xsl:copy-of select="$ndsOriginal" />
												</span>
											</xsl:when>
											<xsl:otherwise>
												<a href="{leg:FormatURL(//atom:link[@rel='alternate' and @hreflang='cy']/@href)}" class="userFunctionalElement" >
													<xsl:copy-of select="$ndsOriginal" />
												</a>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<a href="{leg:FormatURL(//atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = ('enacted', 'made', 'created', 'adopted') and @hreflang='cy']/@href)}" class="userFunctionalElement" >
											<xsl:copy-of select="$ndsOriginal" />
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<span class="userFunctionalElement disabled">
									<xsl:copy-of select="$ndsOriginal" />
								</span>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:if>
							<xsl:choose>
								<xsl:when test="leg:IsProposedVersion(.)">
									<li>
										<span class="userFunctionalElement active" >
											<span class="background">
												<span class="btl"/>
												<span class="btr"/>Proposed legislation<span class="bbl"/>
												<span class="bbr"/>
											</span>
										</span>
									</li>
								</xsl:when>
								<!-- 
									If $pointInTimeView is true then add a button that says "Point in Time (DD/MM/YYYY)" if the $version is castable to xs:date or "Point in Time Prospective" if the $version is 'prospective'.
								-->
								<xsl:when test="$pointInTimeView">
									<li>
										<span class="userFunctionalElement active">
											<span class="background">
											<span class="btl"/>
												<span class="btr"/> 
											<xsl:choose>
													<xsl:when test="$version castable as xs:date">Point in Time (<xsl:value-of select="leg:FormatDate($version)"/>)</xsl:when>
													<xsl:when test="$version ='prospective' ">Latest with prospective</xsl:when>
											</xsl:choose> 
											<span class="bbl"/>
											<span class="bbr"/>
											</span>
										</span>
									</li>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
		</div> 
	</xsl:template>	

	<!-- outputting the whatversion box with the selected properties-->			
	<xsl:template name="TSOOutputMoreResources">
		<xsl:if test="exists(/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative) or exists(/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip)">
			<div class="section" id="moreResources">
				<div class="title">
				  <h2>More Resources</h2>
						<a href="#moreResourcesHelp" class="helpItem helpItemToMidRight">
							<img src="/images/chrome/helpIcon.gif" alt=" Help about more resources"/>
					</a>
				</div>
				<div class="content">
					<ul class="toolList">
						<xsl:variable name="status" select="leg:GetCodeSchemaStatus(/)" />
					<!-- Chunyu:Added pdfs links for DWP -->
						<xsl:for-each select="/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[not(@Revised)]">
							<xsl:sort select="@Title = 'Print Version'" order="descending" />
							<xsl:sort select="@Title"/>
							<!-- put English first -->
							<xsl:sort select="exists(@Language)" />
							<xsl:sort select="@Language = 'English'" order="descending" />
							<!-- put Mixed language last -->
							<xsl:sort select="@Language = 'Mixed'" />
							<xsl:variable name="strLanguageSuffix">
								<xsl:if test="(not(@Title) and count(../ukm:Alternative[not(@Title)]) > 1) or
									(if (@Title = ('', 'Print Version', 'Mixed Language Measure')) then
										count(../ukm:Alternative[@Title = ('', 'Print Version', 'Mixed Language Measure')]) > 1
									else
										count(../ukm:Alternative[@Title = current()/@Title]) > 1)">
									<xsl:choose>
										<xsl:when test="@Language = 'Mixed'"> - Mixed Language</xsl:when>
										<xsl:when test="exists(@Language)">
											<xsl:text> - </xsl:text>
											<xsl:value-of select="@Language" />
										</xsl:when>
										<xsl:when test="matches(@URI, '_en(_[0-9]{3})?.pdf$')"> - English</xsl:when>
										<xsl:when test="matches(@URI, '_we(_[0-9]{3})?.pdf$')"> - Welsh</xsl:when>
										<xsl:when test="matches(@URI, '_mi(_[0-9]{3})?.pdf$')"> - Mixed Language</xsl:when>
									</xsl:choose>
								</xsl:if>
							</xsl:variable>
							<xsl:variable name="title" as="xs:string">
								<xsl:choose>
									<!-- if there is no title then display the download label-->
									<xsl:when test="@Title = '' or not(@Title)"><xsl:value-of select="$strLanguageSuffix" /></xsl:when>
									<!-- if the title is print then display the Download label-->
									<xsl:when test="@Title = 'Print Version' or @Title = 'Mixed Language Measure'"><xsl:value-of select="$strLanguageSuffix" /></xsl:when>
									<!-- for anything else display the title -->
									<xsl:otherwise><xsl:value-of select="concat(@Title, $strLanguageSuffix)"/></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<li>
								<a class="pdfLink" href="{@URI}">
									<xsl:choose>
										<!--added revised version-->
										<xsl:when test="exists(@Revised)">Revised Version</xsl:when>
										<xsl:otherwise><xsl:text>Original Print PDF</xsl:text></xsl:otherwise>
									</xsl:choose>
									
									<xsl:if test="string-length($title) ne 0">
										<xsl:value-of select="concat(' ', $title)"/>
									</xsl:if>
								</a>	
							</li>
						</xsl:for-each>
						<!-- Chunyu:Added pdfs links for DWP -->
						<xsl:for-each select="/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative[@Revised]">
							<li>
								<a class="pdfLink" href="{@URI}">
									<xsl:text>Revised Version</xsl:text>
								</a>	
							</li>	
						</xsl:for-each>
	
						<xsl:for-each select="/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip">
							<li>
								<a class="pdfLink" href="{@URI}">
									<xsl:value-of select="$correctionSlipTitle"/>
									<xsl:text> - </xsl:text>
									<xsl:value-of select="leg:FormatDate(@Date)"/>
								</a>	
							</li>					
						</xsl:for-each>
					</ul>
				</div>
				<p class="viewMoreLink">
					<a href="{leg:FormatURL($resourceURI, false())}">View more
						<span class="pageLinkIcon"></span>				
					</a>
				</p>				
			</div> 



		</xsl:if>
	</xsl:template>	


	<!-- ========== Standard code for outputing legislation content ========= -->
	
	 <xsl:template name="TSOOutputLegislationContent">
				<div id="viewLegContents">
					<div class="LegSnippet" id="viewLegSnippet">
						
						<!-- adding the tocControlsAddress to the table of contents when it is not PDFOnly-->
						<xsl:if test="count(//leg:ContentsPart[* except (leg:ContentsNumber, leg:ContentsTitle)]) > 0 or count(//leg:ContentsSchedule[* except (leg:ContentsNumber, leg:ContentsTitle)]) >0">
							<xsl:attribute name="id">tocControlsAdded</xsl:attribute>								
						</xsl:if>
						
						<xsl:choose>
							<xsl:when test="$IsPDFOnly ">
								<!-- If legislation is only available in PDFOnly then display PDF link -->
								<xsl:variable name="alternatives" as="element(ukm:Alternative)+"
									select="/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative" />
								<xsl:variable name="versiondate" as="xs:date?"
									select="if ($version castable as xs:date) then xs:date($version) else ()" />
								<xsl:variable name="alternative" as="element(ukm:Alternative)?"
									select="if (exists($versiondate)) then 
												 $alternatives[@Revised = max($alternatives/@Revised/xs:date(.)[. le $versiondate])]
											else if (leg:IsCurrentRevised(.)) then
									          $alternatives[@Revised = max($alternatives/@Revised/xs:date(.))]
									        else if ($language = 'cy') then
									        	($alternatives[@Language = 'Welsh'])[1]
									        else
									        	$alternatives[not(@Language = 'Welsh')][not(@Revised)][1]" />
								<!-- make sure we get one -->
								<xsl:variable name="alternative" as="element(ukm:Alternative)"
									select="if ($alternative) then $alternative else $alternatives[1]" />
								<xsl:variable name="title"
									select="if ($language = 'cy') then
									          (/leg:Legislation/ukm:Metadata/dc:title[@xml:lang = 'cy'])[1]
									        else
									        	/leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang = 'cy')][1]" />
								<p class="downloadPdfVersion">
									<a class="pdfLink" href="{$alternative/@URI}">
											<img class="imgIcon" alt="" src="/images/chrome/pdfIconMed.gif"/>										
												 	<xsl:text>View PDF</xsl:text>
											<img class="pdfThumb"  src="{replace(replace(substring-after($alternative/@URI, 'http://www.legislation.gov.uk'), '/pdfs/', '/images/'), '.pdf', '.jpg')}" 
												  title="{$title}" 
												  alt="{$title}" />
										</a>
								</p>
							</xsl:when>
							
							<xsl:otherwise>
								<!-- adding the crest logo if introduction or whole act-->
								<xsl:if test=" $introURI = $dcIdentifier or $wholeActURI = $dcIdentifier">
									<xsl:variable name="uriPrefix" as="xs:string" select="tso:GetUriPrefixFromType(leg:GetDocumentMainType(.), /leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:Year/@Value)"/>
									<xsl:if test="$uriPrefix = ('aep', 'aip', 'apgb' , 'apni' , 'asp' , 'mnia' , 'ukcm' , 'ukla' , 'ukpga' , 'mwa', 'aosp','anaw') ">
										<p class="crest">
										<a href="{leg:FormatURL($introURI)}">
												<img alt="" src="/images/crests/{$uriPrefix}.gif" />
											</a>
										</p>
									</xsl:if>
								</xsl:if>
								
							
								<!-- output the legislation content-->
								<xsl:call-template name="TSOOutputContent"/>
								
							</xsl:otherwise>
						</xsl:choose>

						<!-- add a break -->
						<span class="LegClearFix" />
					</div>
				</div>

	 </xsl:template>
	
	<!-- title heading of the legislation-->
	<xsl:template name="TSOOutputLegislationTitle">
		<xsl:variable name="category" as="xs:string" select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
		<xsl:variable name="mainType" as="xs:string" select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
		<xsl:variable name="number" as="xs:string" select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:Number/@Value" />
		<xsl:variable name="year" as="xs:integer?" select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:Year/@Value" />
		<xsl:variable name="altNumbers" as="element(ukm:AlternativeNumber)*" select="leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:AlternativeNumber" />
		
		<h1 class="pageTitle{if ($isDraft) then ' draft' else if (leg:IsProposedVersion(.)) then ' proposed' else ''}">
			<xsl:value-of select="$title"/>
		</h1>	
	</xsl:template>
	
	<xsl:template name="TSOOutputLegislationNumber">
		<xsl:choose>
			<xsl:when test="/leg:Legislation/ukm:Metadata/ukm:SecondaryMetadata">
				<xsl:variable name="nstMetadata" as="element()"
					select="/leg:Legislation/ukm:Metadata/ukm:SecondaryMetadata" />
				<h1 class="LegNo">
					<xsl:value-of select="$nstMetadata/ukm:Year/@Value" />
					<xsl:text> </xsl:text>
					<xsl:value-of select="tso:GetNumberForLegislation($nstMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, $nstMetadata/ukm:Year/@Value, $nstMetadata/ukm:Number/@Value)" />
					<xsl:for-each select="$nstMetadata/ukm:AlternativeNumber">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="@Category"/>
						<xsl:text>. </xsl:text>
						<xsl:value-of select="@Value"/>
						<xsl:text>)</xsl:text>
					</xsl:for-each>
				</h1>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FuncOutputPrimaryPrelimsPreContents" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- outputing the content -->
	<xsl:template name="TSOOutputContent">
		<xsl:apply-templates select="leg:Legislation">
			<xsl:with-param name="showSection" select="$nstSection" tunnel="yes" />
			<xsl:with-param name="matchRefs" select="$matchRefs" tunnel="yes" />			
			<xsl:with-param name="includeTooltip" select="tso:IncludeInlineTooltip()" tunnel="yes"/>
			<xsl:with-param name="linkFragment" select="$linkFragment" tunnel="yes" />
			<xsl:with-param name="showRepeals" select="$showRepeals" tunnel="yes" />			
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="leg:Contents/leg:ContentsTitle" priority="1000">
		<!-- legislation titles will not be displayed on the table of content page -->
		<!--<xsl:choose>
			<xsl:when test="/leg:Legislation/ukm:Metadata/ukm:PrimaryMetadata">
		<xsl:next-match />
		<xsl:call-template name="TSOOutputLegislationNumber" />
			</xsl:when>
			<xsl:when test="/leg:Legislation/ukm:Metadata/ukm:SecondaryMetadata">
				<xsl:call-template name="FuncOutputSecondaryPrelims" />
				<xsl:call-template name="TSOOutputLegislationNumber" />
				<p class="LegSubject"><xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:subject[last()]" /></p>
				<xsl:next-match />
			</xsl:when>
		</xsl:choose>-->
	</xsl:template>

	<!-- adding the Introductory Text -->
	<!-- Chunyu:adding 'not(ancestor::leg:Schedules)' for introductory text, signature and explanatory note to prevent them appering on the tocs for schedules -->
	<xsl:template match="leg:Contents/*[not(self::leg:ContentsTitle) and not(ancestor::leg:Schedules) and not(ancestor::leg:BlockAmendment)][1] " priority="1000">
		<xsl:param name="matchRefs" tunnel="yes" select="''" />
		<xsl:variable name="matchIndex" as="xs:integer?" select="index-of($matchRefs, 'introduction')[1]" />
		<li class="LegContentsEntry">
			<p class="LegContentsItem LegClearFix">
				<span class="LegDS LegContentsTitle{if (exists($matchIndex)) then ' LegSearchResult' else ()}">
					<xsl:if test="exists($matchIndex)">
						<xsl:attribute name="id" select="concat('match-', $matchIndex)" />
					</xsl:if>
					<a href="{leg:FormatURL($introURI, false())}{$contentsLinkParams}{$linkFragment}">
						<xsl:value-of select="$introductoryText"/>
					</a>
				</span>
				<xsl:call-template name="matchLinks">
					<xsl:with-param name="matchIndex" select="$matchIndex" />
				</xsl:call-template>
			</p>
		</li>
		<xsl:next-match />
	</xsl:template>

	<!-- adding the Signature Text -->
	<xsl:template match="leg:Contents/*[not(self::leg:ContentsTitle) and not(ancestor::leg:Schedules) and not(ancestor::leg:BlockAmendment) and not(self::leg:ContentsSchedules) and not(self::leg:ContentsAttachments)][position()=last()]" priority="1000">
		<xsl:param name="matchRefs" tunnel="yes" select="''" />
		<xsl:next-match />
		<xsl:if test="$signatureURI">
			<xsl:variable name="matchIndex" as="xs:integer?" select="index-of($matchRefs, 'signature')[1]" />
			<li class="LegContentsEntry">
				<p class="LegContentsItem LegClearFix">
					<span class="LegDS LegContentsNo{if (exists($matchIndex)) then ' LegSearchResult' else ()}">
						<xsl:if test="exists($matchIndex)">
							<xsl:attribute name="id" select="concat('match-', $matchIndex)" />
						</xsl:if>
						<a href="{leg:FormatURL($signatureURI, false())}{$contentsLinkParams}{$linkFragment}">
							<xsl:value-of select="$signatureText"/>
						</a>
					</span>
					<xsl:call-template name="matchLinks">
						<xsl:with-param name="matchIndex" select="$matchIndex" />
					</xsl:call-template>
				</p>
			</li>		
		</xsl:if>
	</xsl:template>
	
	<!-- adding the Explanatory Notes link -->
	<xsl:template match="leg:Contents/*[not(self::leg:ContentsTitle) and not(ancestor::leg:Schedules) and not(ancestor::leg:BlockAmendment)][position()=last()]" priority="2000">
		<xsl:param name="matchRefs" tunnel="yes" select="''" />
		<xsl:next-match />
		<xsl:if test="$noteURI">
			<xsl:variable name="matchIndex" as="xs:integer?" select="index-of($matchRefs, 'note')[1]" />
			<li class="LegContentsEntry">
				<p class="LegContentsItem LegClearFix">
					<span class="LegDS LegContentsNo{if (exists($matchIndex)) then ' LegSearchResult' else ()}">
						<xsl:if test="exists($matchIndex)">
							<xsl:attribute name="id" select="concat('match-', $matchIndex)" />
						</xsl:if>
						<a href="{leg:FormatURL($noteURI, false())}{$contentsLinkParams}{$linkFragment}">
							<xsl:value-of select="$noteText"/>
						</a>
					</span>
					<xsl:call-template name="matchLinks">
						<xsl:with-param name="matchIndex" select="$matchIndex" />
					</xsl:call-template>
				</p>
			</li>		
		</xsl:if>
	</xsl:template>
	
	<!-- adding the Earlier ORders link -->
	<xsl:template match="leg:Contents/*[not(self::leg:ContentsTitle) and not(ancestor::leg:BlockAmendment)][position()=last()]" priority="3000">
		<xsl:param name="matchRefs" tunnel="yes" select="''" />
		<xsl:next-match />
		<xsl:if test="$earlierOrdersURI">
			<xsl:variable name="matchIndex" as="xs:integer?" select="index-of($matchRefs, 'earlier-orders')[1]" />
			<li class="LegContentsEntry">
				<p class="LegContentsItem LegClearFix">
					<span class="LegDS LegContentsNo{if (exists($matchIndex)) then ' LegSearchResult' else ()}">
						<xsl:if test="exists($matchIndex)">
							<xsl:attribute name="id" select="concat('match-', $matchIndex)" />
						</xsl:if>
						<a href="{leg:FormatURL($earlierOrdersURI, false())}{$contentsLinkParams}{$linkFragment}">
							<xsl:value-of select="$earlierOrdersText"/>
						</a>
					</span>
					<xsl:call-template name="matchLinks">
						<xsl:with-param name="matchIndex" select="$matchIndex" />
					</xsl:call-template>
				</p>
			</li>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="leg:ContentsPart[* except (leg:ContentsNumber, leg:ContentsTitle)] | leg:ContentsEUPart[* except (leg:ContentsNumber, leg:ContentsTitle)]">
		<xsl:variable name="html" as="element()">
			<xsl:next-match />
		</xsl:variable>
		<li class="{$html/@class} tocDefault{
			if ($searchingByText and $searchingByExtent) then
				if (exists(descendant-or-self::*[@MatchText='true' and @MatchExtent='true'])) then 'Expanded' else 'Collapse'
			else if ($searchingByText or $searchingByExtent) then 
				if (exists(descendant-or-self::*[@MatchText='true' or @MatchExtent='true'])) then 'Expanded' else 'Collapse'
			else 			
			if (ancestor::leg:ContentsSchedule) then 'Expanded' else 'Expanded'}"><!-- updaed by Yashashri call HA050984 Expand and Collapse labels are coming out the wrong way round for some documents --><!-- updated by yash - call HA051711 - default view should be expanded for parts -->
			<xsl:sequence select="$html/*" />
		</li>
	</xsl:template>

	<xsl:template match="leg:ContentsSchedule[* except (leg:ContentsNumber, leg:ContentsTitle)]">
		<xsl:variable name="html" as="element()">
			<xsl:next-match />
		</xsl:variable>
		<li class="{$html/@class} tocDefault{
			if ($searchingByText and $searchingByExtent) then
				if (exists(descendant-or-self::*[@MatchText='true' and @MatchExtent='true'])) then 'Expanded' else 'Collapse'
			else if ($searchingByText or $searchingByExtent) then 
				if (exists(descendant-or-self::*[@MatchText='true' or @MatchExtent='true'])) then 'Expanded' else 'Collapse'
			else 
				'Collapse'}">
			<xsl:sequence select="$html/*" />
		</li>
	</xsl:template>

	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		  <!--/#breadcrumbControl --> 
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:choose>
						<xsl:when test="$wholeActURI = $strCurrentURIs">
							<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
							<li class="activetext">Whole <xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/></li>
						</xsl:when>						
						<xsl:when test="$wholeActWithoutSchedulesURI = $strCurrentURIs">
							<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
							<li class="activetext">Whole <xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/> without <xsl:value-of select="$schedulesText"/></li>
						</xsl:when>						
						<xsl:when test="$strCurrentURIs = $schedulesOnlyURI">
							<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
							<li class="activetext"><xsl:value-of select="$schedulesText"/> only</li>
						</xsl:when>											
						<xsl:when test="leg:IsTOC()">
							<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
							<li class="activetext">Table of Contents</li>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
							<xsl:choose>
								<xsl:when test="exists($nstSection)">
									<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOBreadcrumbItem"/>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
		</div>
	</xsl:template>
	
	
	<!-- creating link for the whole act  -->
	<xsl:template match="leg:Legislation" mode="TSOBreadcrumbItem" priority="20">
		<xsl:variable name="nstMetadata" as="element()"
			select="/leg:Legislation/ukm:Metadata/(ukm:SecondaryMetadata|ukm:PrimaryMetadata|ukm:EUMetadata)" />
		<li class="first">
			<a href="{@DocumentURI}">
				<xsl:choose>
					<xsl:when test="$nstMetadata/ukm:Number">
				<xsl:value-of select="$nstMetadata/ukm:Year/@Value"/>&#160;<xsl:value-of select="tso:GetNumberForLegislation($nstMetadata/ukm:DocumentClassification/ukm:DocumentMainType/@Value, $nstMetadata/ukm:Year/@Value, $nstMetadata/ukm:Number/@Value)" /><xsl:apply-templates select="$nstMetadata/ukm:AlternativeNumber" mode="series"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>ISBN </xsl:text>
						<xsl:value-of select="tso:formatISBN($nstMetadata/ukm:ISBN/@Value)" />
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</li>
	</xsl:template>
	
	<!-- hiding the text for the body-->
	<xsl:template match="leg:Body | leg:EUBody" mode="TSOBreadcrumbItem" priority="20"/>	
	
	<xsl:template match="*[@DocumentURI]" mode="TSOBreadcrumbItem" priority="10">
		<li>
			<xsl:choose>
				<xsl:when test="$strCurrentURIs = @DocumentURI">
					<xsl:attribute name="class" select="'active'"/>
					<xsl:next-match />
				</xsl:when>
				<xsl:otherwise>
					<a href="{leg:FormatURL(@DocumentURI)}">
						<xsl:next-match />
					</a>
				</xsl:otherwise>
			</xsl:choose>		
		</li>
	</xsl:template>
	
	<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims" mode="TSOBreadcrumbItem" priority="5">
		<xsl:choose>
			<xsl:when test="leg:IsCurrentWelsh(/)">
					<xsl:text>Cyflwyniad</xsl:text>
			</xsl:when>
			<xsl:otherwise>
					<xsl:text>Introduction</xsl:text>			
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="leg:SignedSection" mode="TSOBreadcrumbItem" priority="5">
		<xsl:value-of select="$signatureText"/>	
	</xsl:template>	

	<xsl:template match="leg:ExplanatoryNotes" mode="TSOBreadcrumbItem" priority="5">
		<xsl:value-of select="$noteText"/>	
	</xsl:template>	

	<xsl:template match="leg:EarlierOrders" mode="TSOBreadcrumbItem" priority="5">
		<xsl:value-of select="$earlierOrdersText"/>	
	</xsl:template>	
	
	<xsl:template match="leg:Attachment[@DocumentURI]" mode="TSOBreadcrumbItem"  priority="5">
		<xsl:value-of select="translate(@id, '-', ' ')"/>	
	</xsl:template>
	
	<xsl:template match="leg:Attachment//*[@DocumentURI]" mode="TSOBreadcrumbItem" priority="15"/>
	
	<xsl:template match="*[leg:Pnumber]" mode="TSOBreadcrumbItem" priority="5">
		<xsl:param name="nstDocumentClassification" select="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:DocumentClassification" />
		<xsl:choose>
			<xsl:when test="self::leg:P1">
				<xsl:variable name="strCategory"
					select="$nstDocumentClassification/ukm:DocumentCategory/@Value" />
				<xsl:variable name="strMainType"
					select="$nstDocumentClassification/ukm:DocumentMainType/@Value" />
				<xsl:variable name="strMinorType"
					select="$nstDocumentClassification/ukm:DocumentMinorType/@Value" />
				<xsl:choose>
					<xsl:when test="$g_strDocumentType = $g_strEUretained"></xsl:when>
					<xsl:when test="$strMainType = 'NorthernIrelandOrderInCouncil'">Article </xsl:when>
					<xsl:when test="$strMinorType = 'rule'">Rule </xsl:when>
					<xsl:when test="$strMinorType = 'regulation'">Regulation </xsl:when>
					<xsl:when test="$strCategory = 'secondary'">Article </xsl:when>
					<xsl:otherwise>Section </xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
		<!-- Create the relevant 'Section' or 'Subsection' or 'Subsubsection' -->
		<xsl:text>S</xsl:text>
		<xsl:for-each select="ancestor-or-self::*[leg:Pnumber]">
			<xsl:choose>
				<xsl:when test="position() = last()">ection </xsl:when>
				<xsl:otherwise>ubs</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="leg:Pnumber" />
	</xsl:template>
	
	<!-- FM: Fixing the breadcrumb to display the 'leg:Title' if leg:Number is empty -->
	<xsl:template match="*[leg:Number != '' ]" mode="TSOBreadcrumbItem" priority="3">
		<xsl:choose>
			<xsl:when test="self::leg:Division">
				<xsl:variable name="prefix" 
								select="
									if (@Type = 'EUTitle' and not(matches(leg:Number, 'title', 'i'))) then 'Title'
									else if (@Type = 'EUPart' and not(matches(leg:Number, 'part', 'i'))) then 'Part'
									else if (@Type = 'EUChapter' and not(matches(leg:Number, 'chapter', 'i'))) then 'Chapter'
									else if (@Type = 'EUSection' and not(matches(leg:Number, 'section', 'i'))) then 'Section'
									else if (@Type = 'EUSubsection' and not(matches(leg:Number, 'section', 'i'))) then 'Sub-Section'
									else if (@Type = 'Annotations' and not(matches(leg:Number, 'annotation', 'i'))) then 'Annotations'
									else if (@Type = 'Annotation' and not(matches(leg:Number, 'annotation', 'i'))) then 'Annotation'
									else if (@Type = ('EUTitle', 'EUPart', 'EUChapter', 'EUSection', 'EUSubsection', 'Annotations', 'Annotation')) then ()
									else 'Division'
									"/>
				<xsl:value-of select="concat($prefix, ' ', leg:Number)" />				
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:Number" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[leg:Title]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:choose>
			<xsl:when test="leg:Title = ''">
				<xsl:value-of select="local-name(if (. instance of element(leg:TitleBlock)) then .. else .)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="leg:abridgeContent(leg:Title, 4)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[leg:TitleBlock]" mode="TSOBreadcrumbItem" priority="1">
		<!-- This will pick up the Title from the TitleBlock -->
		<xsl:apply-templates select="leg:TitleBlock" mode="TSOBreadcrumbItem" />
	</xsl:template>

	<xsl:template match="leg:P1group[leg:Title = '']" mode="TSOBreadcrumbItem" priority="3">Paragraphs</xsl:template>
	
	<!-- Container Divisions without any specific content -->
	<xsl:template match="leg:Division[not(leg:Number)][not(leg:Title)]" mode="TSOBreadcrumbItem" priority="2">
		<xsl:variable name="idtokens" as="xs:string*" select="tokenize(@id, '-')"/>
		<xsl:variable name="tokencount" as="xs:integer?" select="count($idtokens)"/>
		<xsl:value-of select="if (matches($idtokens[last()], '[0-9]+')) then 
					concat($idtokens[$tokencount - 1], ' ', $idtokens[$tokencount])
					else $idtokens[$tokencount]"/>
	</xsl:template>
	
	<!-- prevent other matches extending the breadcrumb trail-->
	<xsl:template match="*" mode="TSOBreadcrumbItem" priority="1"></xsl:template>
	

	<!-- ========== Standard code for previous and next ========= -->
	<xsl:template name="TSOOutputPreviousNextLinks">
		<xsl:choose>
			<xsl:when test="not(leg:IsTOC())">
				<xsl:variable name="prev" as="element(atom:link)?" select="leg:Legislation/ukm:Metadata/atom:link[@rel='prev']" />
				<xsl:variable name="next" as="element(atom:link)?" select="leg:Legislation/ukm:Metadata/atom:link[@rel='next']" />
				<div class="prevNextNav">
					<ul>
						<li class="prev">
							<xsl:element name="{if (exists($prev)) then 'a' else 'span'}">
								<xsl:choose>
									<xsl:when test="exists($prev)">
										<xsl:attribute name="href" select="leg:FormatURL($prev/@href)" />
										<xsl:attribute name="class" select="concat('userFunctionalElement', if (tokenize(leg:get-query-param('view'), '\+') = 'plain') then '' else ' nav')" />
										<xsl:attribute name="title">
											<xsl:choose>
												<xsl:when test="exists($prev/@title)">
													<xsl:value-of select="substring-after(lower-case($prev/@title), ';')" />
												</xsl:when>
											</xsl:choose>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class" select="'userFunctionalElement disabled'" />
									</xsl:otherwise>
								</xsl:choose>
								<span class="background">
								<span class="btl"/>
								<span class="btr"/>
								<xsl:text>Previous</xsl:text>
									<xsl:if test="exists($prev)">: <xsl:value-of select="substring-before($prev/@title, ';')" /></xsl:if>
								<span class="bbl"/>
								<span class="bbr"/>
								</span>
							</xsl:element>
						</li>
						<li class="next">
							<xsl:element name="{if (exists($next)) then 'a' else 'span'}">
								<xsl:choose>
									<xsl:when test="exists($next)">
										<xsl:attribute name="href" select="leg:FormatURL($next/@href)" />
										<xsl:attribute name="class" select="concat('userFunctionalElement', if (tokenize(leg:get-query-param('view'), '\+') = 'plain') then '' else ' nav')" />
										<xsl:attribute name="title">
											<xsl:choose>
												<xsl:when test="exists($next/@title)">
													<xsl:value-of select="substring-after(lower-case($next/@title),';')" />
												</xsl:when>
											</xsl:choose>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class" select="'userFunctionalElement disabled'" />
									</xsl:otherwise>
								</xsl:choose>
								<span class="background">
								<span class="btl"/>
								<span class="btr"/>
								<xsl:text>Next</xsl:text>
									<xsl:if test="exists($next)">: <xsl:value-of select="substring-before($next/@title, ';')" /></xsl:if>
								<span class="bbl"/>
								<span class="bbr"/>
								</span>
							</xsl:element>
						</li>
					</ul>
				  </div>
				  <!--/.prevNextNav-->						
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>				  
	</xsl:template>
	
	 <!-- trimming previous and next sections titles-->			
	<xsl:function name="tso:OutputNextPreviousSection">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="string-length($text)>50">
				<xsl:value-of select="substring($text, 1,50)"/>...</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- ========== Standard code for view/print ========= -->	
	<xsl:template name="TSOOutputViewPrintLinks">
		<ul id="viewPrintControl">
			<!--
			<li class="view">
				<xsl:element name="{if ($IsPDFOnly) then 'span' else 'a'}">		
					<xsl:choose>
						<xsl:when test="$IsPDFOnly">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>						
							<xsl:attribute name="target">_blank</xsl:attribute>
							<xsl:attribute name="href">?<xsl:choose>
									<xsl:when test="tokenize(leg:get-query-param('view'), '\+') = 'extent'"><xsl:value-of select="leg:set-query-params('view', 'edit+extent')"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="leg:set-query-params('view', 'edit')"/></xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>												
						</xsl:otherwise>
					</xsl:choose>
					<span class="btl"/>
					<span class="btr"/>
					<xsl:text>Edit View</xsl:text>
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
			-->
			<li class="view">
				<xsl:element name="{if ($IsPDFOnly) then 'span' else 'a'}">		
					<xsl:choose>
						<xsl:when test="$IsPDFOnly">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>						
							<xsl:attribute name="href">?<xsl:choose>
									<xsl:when test="tokenize(leg:get-query-param('view'), '\+') = 'extent'"><xsl:value-of select="leg:set-query-params('view', 'plain+extent')"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="leg:set-query-params('view', 'plain')"/></xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>												
						</xsl:otherwise>
					</xsl:choose>
					<span class="btl"/>
					<span class="btr"/>
					<xsl:text>Plain View</xsl:text>
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
			<li class="print">
				<xsl:element name="{if ($IsPDFOnly) then 'span' else 'a'}">			
					<xsl:choose>
						<xsl:when test="$IsPDFOnly">
							<xsl:attribute name="class">userFunctionalElement disabled</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
							<xsl:attribute name="href">#printOptions</xsl:attribute>					
						</xsl:otherwise>
					</xsl:choose>				
					<span class="btl"/>
					<span class="btr"/>Print Options
					<span class="bbl"/>
					<span class="bbr"/>
				</xsl:element>
			</li>
		</ul>	
		  <!--/#viewPrintControl-->		
	</xsl:template>
	
	<!-- for print options -->
	<xsl:template match="leg:Legislation" mode="TSOPrintOptions" priority="1000">
		<xsl:if test="leg:IsTOC()">
			<li class="printToc">
				<h4><span class="accessibleText">Print </span>Table of Contents</h4>
				<ul>
					<li><a href="{leg:FormatPDFDataURL($dcIdentifier)}" target="_blank" class="pdfLink">PDF<span class="accessibleText"> table of contents</span></a></li>
					<li><a href="{leg:FormatHTMLDataURL($dcIdentifier)}" target="_blank" class="htmLink">Web page<span class="accessibleText"> table of contents</span></a></li>
				</ul>
			</li>
		</xsl:if>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template match="leg:Legislation | leg:Body | leg:EUBody | leg:Part | leg:Chapter | leg:Schedules | leg:Schedule | leg:Pblock | leg:P1 | leg:SecondaryPrelims | leg:PrimaryPrelims | leg:EUPrelims | leg:SignedSection | leg:Secondary/leg:ExplanatoryNotes | leg:EarlierOrders | leg:EUPart | leg:EUTitle  | leg:EUChapter  | leg:EUSection  | leg:EUSubsection  | leg:Division  | leg:Attachments | leg:Attachment" mode="TSOPrintOptions" >
		<li class="printWhole">
			<xsl:variable name="displayText">
				 <xsl:choose>
						<xsl:when test="self::leg:Body or self::leg:EUBody">The <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/></xsl:when>
						<xsl:when test="self::leg:Schedules">The <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>						
						<xsl:when test="self::leg:P1 and parent::leg:P1group/@AltVersionRefs">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>												
						<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:Legislation)">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>
						<xsl:otherwise>The Whole <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/></xsl:otherwise>						
				</xsl:choose>			
			</xsl:variable>			
	
			<xsl:variable name="provisions" as="xs:integer">
				<xsl:choose>
					<xsl:when test="@NumberOfProvisions"><xsl:value-of select="xs:integer(@NumberOfProvisions)"/></xsl:when>					
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- If the current node is Schedules then get $schedulesOnlyURI-->
			<xsl:variable name="documentURI">
				<xsl:choose>
					<xsl:when test="self::leg:Schedules"><xsl:value-of select="$schedulesOnlyURI"/></xsl:when>
					<xsl:when test="self::leg:Attachments"><xsl:value-of select="$attachmentsOnlyURI"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="@DocumentURI"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
	
			<h4><span class="accessibleText">Print </span><xsl:value-of select="$displayText"/></h4>
			<ul>
				<li>
					<a class="pdfLink">
						<xsl:choose>
							<xsl:when test="$provisions > $paragraphThreshold">
								<xsl:attribute name="href" select="concat ('#print',  name(), 'ModPdf')"/>
								<xsl:attribute name="class" select="'pdfLink warning'"/>							
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="href" select="leg:FormatPDFDataURL($documentURI)"/>
								<xsl:attribute name="target">_blank</xsl:attribute>							
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:text>PDF</xsl:text>
						<span class="accessibleText">
							<xsl:text> </xsl:text>
							<xsl:value-of select="$displayText"/>
						</span>
					</a>
				</li>
				<li>
					<a class="htmLink">
						<xsl:choose>
							<xsl:when test="$provisions > $paragraphThreshold">
								<xsl:attribute name="href" select="concat ('#print',  name(), 'ModHtm')"/>
								<xsl:attribute name="class" select="'htmLink warning'"/>							
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="href" select="leg:FormatHTMLDataURL($documentURI)"/>
								<xsl:attribute name="target">_blank</xsl:attribute>							
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:text>Web page</xsl:text>
						<span class="accessibleText">
							<xsl:text> </xsl:text>
							<xsl:value-of select="$displayText"/>
						</span>
					</a>
				</li>
			</ul>
		</li>		
	</xsl:template>	
	<xsl:template match="*" mode="TSOPrintOptions"/>	
	
	<xsl:template match="leg:Legislation | leg:Body | leg:EUBody | leg:Schedules | leg:Attachments | leg:Attachment | leg:Part | leg:Chapter | leg:Schedule | leg:Pblock | leg:P1" mode="TSOPrintOptionsWarnings" >
		<xsl:if test="@NumberOfProvisions > $paragraphThreshold">
		
			<xsl:variable name="displayText">
				 <xsl:choose>
						<xsl:when test="@DocumentURI = $dcIdentifier and not(self::leg:Legislation)">This <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/> only</xsl:when>
						<xsl:otherwise>The Whole <xsl:apply-templates select="." mode="TSOPrintOptionsXXX"/></xsl:otherwise>						
				</xsl:choose>					
			</xsl:variable>		
					
		<xsl:call-template name="TSOOutputWarningMessage">
				<xsl:with-param name="messageId" select="concat('print',  name(), 'ModHtm')"/>	
			<xsl:with-param  name="messageType" select=" 'webWarning' " />
				<xsl:with-param  name="messageHeading" >You have chosen to open <xsl:value-of select="$displayText" /></xsl:with-param>
				<xsl:with-param  name="message"><xsl:value-of select="$displayText"/> you have selected contains over <xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download. You may also experience some issues with your browser, such as an alert box that a script is taking a long time to run.</xsl:with-param>		
				<xsl:with-param  name="continueURL" select="leg:FormatHTMLDataURL(@DocumentURI)" />							
		</xsl:call-template>	
		 
		<xsl:call-template name="TSOOutputWarningMessage">
				<xsl:with-param name="messageId" select="concat('print',  name(), 'ModPdf')"/>	
			<xsl:with-param  name="messageType" select=" 'pdfWarning' " />
				<xsl:with-param  name="messageHeading" >You have chosen to open <xsl:value-of select="$displayText" /> as a PDF</xsl:with-param> 
				<xsl:with-param  name="message"><xsl:value-of select="$displayText"/> you have selected contains over <xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download.</xsl:with-param>		
				<xsl:with-param  name="continueURL" select="leg:FormatPDFDataURL(@DocumentURI)" />							
		</xsl:call-template>	
			
		</xsl:if>
	</xsl:template>
	<xsl:template match="*" mode="TSOPrintOptionsWarnings"/>			
			
	<xsl:template match="leg:Legislation" mode="TSOPrintOptionsXXX"><xsl:value-of select="tso:GetCategory($ndsLegislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata )/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/></xsl:template>	
	<xsl:template match="leg:Body | leg:EUBody" mode="TSOPrintOptionsXXX"><xsl:value-of select="tso:GetCategory($ndsLegislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata )/ukm:DocumentClassification/ukm:DocumentMainType/@Value)"/> without <xsl:value-of select="$schedulesText"/></xsl:template>		
	<xsl:template match="leg:Part | leg:EUPart | leg:Division[@Type='EUPart']" mode="TSOPrintOptionsXXX">Part</xsl:template>
	<xsl:template match="leg:EUTitle | leg:Division[@Type='EUTitle']" mode="TSOPrintOptionsXXX">Title</xsl:template>
	<xsl:template match="leg:EUSection | leg:Division[@Type='EUSection']" mode="TSOPrintOptionsXXX">Section</xsl:template>
	<xsl:template match="leg:EUSubsection | leg:Division[@Type='EUSubsection']" mode="TSOPrintOptionsXXX">Sub-section</xsl:template>
	<xsl:template match="leg:Attachment" mode="TSOPrintOptionsXXX">Attachment</xsl:template>
	<xsl:template match="leg:Attachments" mode="TSOPrintOptionsXXX">Attachments</xsl:template>
	<xsl:template match="leg:Schedule" mode="TSOPrintOptionsXXX"><xsl:value-of select="$scheduleText"/></xsl:template>
	<xsl:template match="leg:Schedules" mode="TSOPrintOptionsXXX"><xsl:value-of select="$schedulesText"/></xsl:template>
	<xsl:template match="leg:Pblock" mode="TSOPrintOptionsXXX">Cross Heading</xsl:template>
	<xsl:template match="leg:Chapter | leg:EUChapter | leg:Division[@Type='EUChapter']" mode="TSOPrintOptionsXXX">Chapter</xsl:template>	
	<xsl:template match="leg:Division[not(@Type=('EUPart','EUTitle','EUChapter','EUSection','EUSubsection'))]" mode="TSOPrintOptionsXXX">Division</xsl:template>
	<xsl:template match="leg:P1[$g_strDocumentType = $g_strEUretained]" mode="TSOPrintOptionsXXX">Article</xsl:template>
	<xsl:template match="leg:P1[not($g_strDocumentType = $g_strEUretained)]" mode="TSOPrintOptionsXXX">Section</xsl:template>		
	<xsl:template match="leg:SecondaryPrelims | leg:PrimaryPrelims | leg:EUPrelims" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$introductoryText"/>
	</xsl:template>
	<xsl:template match="leg:SignedSection" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$signatureText"/>
	</xsl:template>
	<xsl:template match="leg:ExplanatoryNotes" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$noteText"/>
	</xsl:template>
	<xsl:template match="leg:EarlierOrders" mode="TSOPrintOptionsXXX">
		<xsl:value-of select="$earlierOrdersText"/>
	</xsl:template>
	<xsl:template match="*" mode="TSOPrintOptionsXXX"/>
							

	<xsl:template name="TSOOutputPrintOptions">
		<div id="printOptions" class="interfaceOptions ">
			<h3 class="accessibleText">Print Options</h3>
			<ul class="optionList">
				<xsl:choose>
					<xsl:when test="leg:IsTOC()">
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/> <!-- displaying print options as 'Whole Act', 'Table of Content' -->
					</xsl:when>				
					<xsl:when test="$dcIdentifier = $schedulesOnlyURI"> <!-- displaying print options as 'Whole Act', 'The Schedules only' for Schedules only -->
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
						<xsl:apply-templates select="leg:Legislation/(leg:Primary|leg:Secondary|leg:EURetained)/leg:Schedules" mode="TSOPrintOptions"/>						
					</xsl:when>
					<xsl:when test="$dcIdentifier = $attachmentsOnlyURI"> <!-- displaying print options as 'Whole Act', 'The Schedules only' for Schedules only -->
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
						<xsl:apply-templates select="leg:Legislation/leg:EURetained/leg:Attachments" mode="TSOPrintOptions"/>						
					</xsl:when>
					<xsl:when test="$wholeActWithoutSchedulesURI = $dcIdentifier"><!-- displaying print options as 'Whole Act', 'Act without Schedules' for Schedules without Act only -->
						<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
						<xsl:apply-templates select="leg:Legislation/(leg:Primary|leg:Secondary)/leg:Body | leg:Legislation/leg:EURetained/leg:EUBody" mode="TSOPrintOptions"/>						
					</xsl:when>				
					<xsl:otherwise>
						<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
						<xsl:choose>
							<xsl:when test="exists($nstSection)">
<!--							<xsl:for-each select="$nstSection/ancestor-or-self::*[@DocumentURI]">
								<br/>		
								[<xsl:value-of select="position()"/> : <xsl:value-of select="name()" />]
							</xsl:for-each>
							<br/>			-->				
								<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI and not(self::leg:Body or self::leg:EUBody)] " mode="TSOPrintOptions"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptions"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</ul>
		</div>	
		
		<xsl:choose>
			<xsl:when test="leg:IsTOC()">
				<xsl:apply-templates select="leg:Legislation" mode="TSOPrintOptionsWarnings"/>
			</xsl:when>				
			<xsl:otherwise>
				<xsl:variable name="nstSection" as="element()?" select="(//*[@DocumentURI = $strCurrentURIs])[1]" />
				<xsl:if test="exists($nstSection)">
					<xsl:apply-templates select="$nstSection/ancestor-or-self::*[@DocumentURI]" mode="TSOPrintOptionsWarnings"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<!-- ========== Standard code for advanced search ========= -->		
	<xsl:template name="TSOOutputAdvancedSearch">
		<!-- advance -->
		<xsl:if test="not(leg:IsTOC()) and (leg:IsCurrentRevised(.) or $showENinterweaveOption or leg:IsProposedVersion(.)) and not($IsPDFOnly)">
			<div id="advFeatures" class="section">
				<div class="title">
					<h2>Advanced Features</h2>
					<a href="#advFeaturesHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about advanced features"/>
					</a>											
				</div>
				<div id="advFeaturesContent" class="content">
					<ul class="toolList">
						<xsl:if test="leg:IsCurrentRevised(.)">
							<li class="concVers geoExtent first">
								<xsl:choose>
									<xsl:when test="$forceShowExtent">
										<span class="userFunctionalElement close">Show Geographical Extent</span>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="view" as="xs:string*" select="tokenize(leg:get-query-param('view'),'\+')"/>
										<xsl:variable name="href" 
											select="leg:set-query-params('view', string-join(
																	if ($view[. = 'extent']) then $view[. != 'extent']
																	else ($view, 'extent')
																	, '+') )"/>
																		
										<a>
											<xsl:choose>
												<xsl:when test="$showExtent">
													<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											
											<xsl:attribute name="href">
												<xsl:choose>
													<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
													<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<xsl:text>Show Geographical Extent</xsl:text>
										</a>
									</xsl:otherwise>
								</xsl:choose>
								<span>(e.g. <b>E</b>ngland, <b>W</b>ales, <b>S</b>cotland, <b>N</b>orthern <b>I</b>reland)</span>										
							</li>						
							
							<!-- 
							The checkbox for "Show Timeline of Changes" should be checked if $showTimeline is true and unchecked if $showTimeline is false.
							 The link, when you click on that, should take you to the same URI as the page you are on but with ?timeline=true (if $showTimeline is false) or without the timeline parameter in the URI (if $showTimeline is true).
							-->
							<li>
							<xsl:choose>
								<xsl:when test="$showTimeline">
									<a class="userFunctionalElement close">
										<xsl:attribute name="href">
											<xsl:variable name="href" select="leg:set-query-params('timeline', '' )"/>
											<xsl:choose>
												<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
												<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<xsl:text>Show Timeline of Changes </xsl:text>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="userFunctionalElement" href="?{leg:set-query-params('timeline', 'true' )}">Show Timeline of Changes </a>
								</xsl:otherwise>
							</xsl:choose>
						 </li>
						 </xsl:if>
						 <xsl:if test="$showENinterweaveOption">
							<li>
								<xsl:variable name="view" as="xs:string*" select="tokenize(leg:get-query-param('view'),'\+')"/>
								<xsl:variable name="href" 
									select="leg:set-query-params('view', string-join(
															if ($view[. = 'interweave']) then $view[. != 'interweave']
															else ($view, 'interweave')
															, '+') )"/>
								<a>
									<xsl:choose>
										<xsl:when test="$showENinterweave">
											<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="href">
										<xsl:choose>
											<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
											<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:text>Show Explanatory Notes for Sections </xsl:text>
								</a>
							</li>
						</xsl:if>	 
						<xsl:if test="leg:IsProposedVersion(.)">
							<li>
								<xsl:choose>
									<xsl:when test="$showRepeals">
										<a class="userFunctionalElement close">
											<xsl:attribute name="href">
												<xsl:variable name="href" select="leg:set-query-params('repeals', '' )"/>
												<xsl:choose>
													<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
													<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<xsl:text>Show Repeals </xsl:text>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a class="userFunctionalElement" href="?{leg:set-query-params('repeals', 'true' )}">Show Repeals </a>
									</xsl:otherwise>
								</xsl:choose>						
							</li>
						</xsl:if>	 
							
					</ul>
				</div>
			</div>	
		</xsl:if>
	</xsl:template>
	
	<!-- ========== Standard code for opening options ========= -->	
	<xsl:template name="TSOOutputOpeningOptions">
		<xsl:if test="(leg:IsTOC() or leg:IsContentTabDisplaying()) and not($IsPDFOnly)">
		<div class="section" id="openingOptions">
			<div class="title">
				 <h2>Opening Options</h2>
				<a href="#openingOptionsHelp" class="helpItem helpItemToMidRight">
					<img src="/images/chrome/helpIcon.gif" alt=" Help about opening options"/>
				</a>									
			</div>
			<div id="openingOptionsContent" class="content">
				<ul class="toolList">		
					<xsl:if test="$wholeActURI != ''">
						<li class="whole">
								<a>
									<xsl:choose>
										<xsl:when test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:TotalParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingWholeMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href" select="concat(leg:FormatURL($wholeActURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($wholeActURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:variable name="wholeActText">
										<xsl:text>Open whole </xsl:text>
										<xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/>
									</xsl:variable>
									<xsl:value-of select="leg:TranslateText($wholeActText)"/>
								</a>
						</li>
					</xsl:if>
					
					<xsl:if test="$wholeActWithoutSchedulesURI != '' and ($schedulesOnlyURI != '' or $attachmentsOnlyURI != '')">
						<li class="minusSched">
								<a>
									<xsl:choose>
										<xsl:when test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:BodyParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingWholeWithoutSchedulesMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href" select="concat(leg:FormatURL($wholeActWithoutSchedulesURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($wholeActWithoutSchedulesURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:variable name="wholeActText">
										<xsl:text>Open </xsl:text>
										<xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/>
										<xsl:text> without </xsl:text>
										<xsl:if test="$schedulesOnlyURI != ''">
											<xsl:value-of select="$schedulesText"/>
										</xsl:if>
										<xsl:if test="$schedulesOnlyURI != '' and $attachmentsOnlyURI != ''">
											<xsl:text> or </xsl:text>
										</xsl:if>
										<xsl:if test="$attachmentsOnlyURI != ''">
											<xsl:text> Attachments</xsl:text>
										</xsl:if>
									</xsl:variable>
									<xsl:value-of select="leg:TranslateText($wholeActText)"/>
								</a> 
						</li>
					</xsl:if>
					
					<xsl:if test="$schedulesOnlyURI != ''">
						<li class="onlySched">
								<a>
									<xsl:choose>
										<xsl:when test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:ScheduleParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingSchedulesOnlyMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href" select="concat(leg:FormatURL($schedulesOnlyURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($schedulesOnlyURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="leg:TranslateText(concat('Open ', $schedulesText, ' only'))"/>
								</a>
						</li>
					</xsl:if>
					
					<xsl:if test="$attachmentsOnlyURI != ''">
						<li class="onlySched">
								<a>
									<xsl:choose>
										<xsl:when test="xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:AttachmentParagraphs/@Value) > $paragraphThreshold">
											<xsl:attribute name="href" select="'#openingAttachmentsOnlyMod'"/>
											<xsl:attribute name="class" select="'warning'"/>
										</xsl:when>
										<xsl:when test="leg:IsTOC()">
											<xsl:attribute name="href" select="concat(leg:FormatURL($attachmentsOnlyURI, false()), $contentsLinkParams, $linkFragment)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="href" select="leg:FormatURL($attachmentsOnlyURI)"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="leg:TranslateText(concat('Open ', $attachmentsText, ' only'))"/>
								</a>
						</li>
					</xsl:if>
				</ul>
			</div>
		</div>
		</xsl:if>
	
	  
	</xsl:template>	
	
	<xsl:template name="TSOOutputOpeningOptionsWarning">
		<xsl:if test="((leg:IsTOC() or leg:IsContent()) and not($IsPDFOnly)) or ($wholeActURI = $dcIdentifier or $wholeActWithoutSchedulesURI = $dcIdentifier or $schedulesOnlyURI = $dcIdentifier or $attachmentsOnlyURI = $dcIdentifier)">
			<xsl:if test="$wholeActURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:TotalParagraphs/@Value) > $paragraphThreshold ">
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingWholeMod' "/>	
					<xsl:with-param  name="messageType" select=" 'openingWholeWarning' " />
					<xsl:with-param  name="messageHeading" >You have chosen to open the Whole <xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/>
					</xsl:with-param>
					<xsl:with-param  name="message">The Whole <xsl:value-of select="tso:GetCategory(leg:GetDocumentMainType(.))"/> you have selected contains over <xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download. You may also experience some issues with your browser, such as an alert box that a script is taking a long time to run.</xsl:with-param>		
					<xsl:with-param  name="continueURL" select="if (leg:IsTOC()) then concat(leg:FormatURL($wholeActURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($wholeActURI)" />
				</xsl:call-template>
			</xsl:if>
			
			<xsl:if test="$wholeActWithoutSchedulesURI != '' and $schedulesOnlyURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:BodyParagraphs/@Value) > $paragraphThreshold">
			
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingWholeWithoutSchedulesMod' "/>	
					<xsl:with-param  name="messageType" select=" 'openingWholeWithoutSchedulesWarning' " />
					<xsl:with-param  name="messageHeading" select="concat(leg:TranslateText('You have chosen to open'),' ', leg:TranslateText(concat('the Whole ', tso:GetCategory(leg:GetDocumentMainType(.)))),' ',leg:TranslateText(concat('without ',$schedulesText)))"/>
					<xsl:with-param  name="message" select="
						concat(
						leg:TranslateText(concat('The Whole ',tso:GetCategory(leg:GetDocumentMainType(.)))),
						' ',
						leg:TranslateText(concat('without ', $schedulesText)),
						' ',
						leg:TranslateText('EN_selected_count', concat('count=',$paragraphThreshold)),
						leg:TranslateText('Browser_warning')
						)"/>	
					<xsl:with-param  name="continueURL" select="if (leg:IsTOC()) then concat(leg:FormatURL($wholeActWithoutSchedulesURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($wholeActWithoutSchedulesURI)" />
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$schedulesOnlyURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:ScheduleParagraphs/@Value) > $paragraphThreshold">
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingSchedulesOnlyMod' "/>	
					<xsl:with-param  name="messageType" select=" 'openingSchedulesOnlyWarning' " />
					<xsl:with-param  name="messageHeading" >You have chosen to open Schedules only 
					</xsl:with-param>
					<xsl:with-param  name="message">The Schedules only you have selected contains over <xsl:value-of select="$paragraphThreshold"/> provisions and might take some time to download. You may also experience some issues with your browser, such as an alert box that a script is taking a long time to run.</xsl:with-param>		
					<xsl:with-param  name="continueURL" select="if (leg:IsTOC()) then concat(leg:FormatURL($schedulesOnlyURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($schedulesOnlyURI)" />
				</xsl:call-template>			
			</xsl:if>
			<xsl:if test="$attachmentsOnlyURI != '' and xs:integer(/leg:Legislation/ukm:Metadata/ukm:Statistics/ukm:AttachmentParagraphs/@Value) > $paragraphThreshold">
				<xsl:call-template name="TSOOutputWarningMessage">
					<xsl:with-param name="messageId" select="'openingAttachmentsOnlyMod' "/>	
					<xsl:with-param  name="messageType" select=" 'openingAttachmentsOnlyWarning' " />
					<xsl:with-param  name="messageHeading" select="leg:TranslateText('Attachments_only')"/>	
					<xsl:with-param  name="message" select="
						concat(
						leg:TranslateText('The Attachments'),
						' ',
						leg:TranslateText('EN_selected_count', concat('count=',$paragraphThreshold)),
						leg:TranslateText('Browser_warning')
						)"/>
					<xsl:with-param  name="continueURL" select="if (leg:IsTOC()) then concat(leg:FormatURL($attachmentsOnlyURI, false()), $contentsLinkParams, $linkFragment) else leg:FormatURL($attachmentsOnlyURI)" />
				</xsl:call-template>			
			</xsl:if>
		</xsl:if>
	</xsl:template>	
	
	<!-- ========== Code for effects options ========= -->	
	<xsl:template name="TSOOutputEffectsOptions">
		<xsl:variable name="view" as="xs:string*" select="tokenize(leg:get-query-param('view'),'\+')"/>
		<xsl:if test="not(leg:IsTOC())">
			<div class="section" id="viewEffects">
				<div class="title">
					<h2><xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" /> Effects</h2>
					<a href="#viewEffectsHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about viewing effects"/>
					</a>
				</div>
				<div id="viewEffectsContent" class="content">
					<ul class="toolList">
						<li>
							<xsl:variable name="href" 
								select="leg:set-query-params('view', string-join(
														if ($view[. = 'textualEffects']) then $view[. != 'textualEffects']
														else ($view, 'textualEffects')
														, '+') )"/>
							<a>
								<xsl:choose>
									<xsl:when test="$showTextualEffects">
										<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="href">
									<xsl:choose>
										<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" />
								<xsl:text> Textual Effects</xsl:text>
							</a>
						</li>
						<li>
							<xsl:variable name="href" 
								select="leg:set-query-params('view', string-join(
														if ($view[. = 'commencementEffects']) then $view[. != 'commencementEffects']
														else ($view, 'commencementEffects')
														, '+') )"/>
							<a>
								<xsl:choose>
									<xsl:when test="$showCommencementEffects">
										<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="href">
									<xsl:choose>
										<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" />
								<xsl:text> Commencements</xsl:text>
							</a>
						</li>
						<li>
							<xsl:variable name="href" 
								select="leg:set-query-params('view', string-join(
														if ($view[. = 'extentEffects']) then $view[. != 'extentEffects']
														else ($view, 'extentEffects')
														, '+') )"/>
							<a>
								<xsl:choose>
									<xsl:when test="$showExtentEffects">
										<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="href">
									<xsl:choose>
										<xsl:when test="$href != ''">?<xsl:value-of select="$href"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$requestInfoDoc/request/request-path"/></xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:value-of select="if ($supportParticipation) then 'Edit' else 'View'" />
								<xsl:text> Extent Effects</xsl:text>
							</a>
						</li>
					</ul>
				</div>
			</div>
		</xsl:if>
	</xsl:template>	
	
	<!-- ========== Standard code for versioning options ========= -->	
	<xsl:template name="TSOOutputRevisionOptions">
		<xsl:if test="leg:IsRevision(.)">
			<xsl:variable name="isCheckedOut" as="xs:boolean" select="leg:IsCheckedOut(.)" />
			<div class="section" id="revisionOptions">
				<div class="title">
					<h2>Revision Options</h2>
					<a href="#revisionOptionsHelp" class="helpItem helpItemToMidRight">
						<img src="/images/chrome/helpIcon.gif" alt=" Help about versioning options"/>
					</a>
				</div>
				<div id="revisionOptionsContent" class="content">
					<ul class="toolList">
						<xsl:choose>
							<xsl:when test="leg:IsTOC()">
								<li class="first">
									<form action="" method="post">
										<input type="hidden" name="revise" value="publish" />
										<button type="submit">Publish</button>
									</form>
								</li>
							</xsl:when>
							<xsl:when test="/leg:Legislation/ukm:Metadata/ukm:Revisions/*">
								<li class="first">
									<form action="" method="post">
										<input type="hidden" name="revise" value="{if ($isCheckedOut) then 'checkin' else 'checkout'}" />
										<button type="submit">
											<xsl:choose>
												<xsl:when test="$isCheckedOut">
													<xsl:attribute name="class">userFunctionalElement close</xsl:attribute>
													<xsl:text>Checked out </xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="class">userFunctionalElement</xsl:attribute>
													<xsl:text>Check out </xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</button>
										<xsl:if test="$isCheckedOut">
											<xsl:variable name="checkout" select="/leg:Legislation/ukm:Metadata/ukm:Checkout" />
											<span>(checked out by <xsl:value-of select="$checkout/ukm:CheckedOutBy/@Value" /> at <xsl:value-of select="format-dateTime(xs:dateTime($checkout/ukm:CheckedOutAt/@DateTime), '[D1]/[M1]/[Y0001] [H01]:[m01]')" />)</span>	
										</xsl:if>
									</form>
								</li>
								<xsl:if test="$isCheckedOut">
									<li>
										<a href="revision/data.xml?view=edit">Download</a>
									</li>
									<li>
										<form action="" method="post" enctype="multipart/form-data">
											<input type="hidden" name="revise" value="update" />
											<label for="revisionOptionsFile">Choose File:<xsl:text>&#160;</xsl:text></label>
											<input id="revisionOptionsFile" name="file" type="file" />
											<button type="submit">Update</button>
										</form>
									</li>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasPart']">
									<li>
										<xsl:if test="position() = 1"><xsl:attribute name="class" select="'first'" /></xsl:if>
										<a href="{leg:FormatURL(@href)}">Select <xsl:value-of select="@title" /> extent</a>
									</li>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</ul>
				</div>
			</div>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template name="TSOOutputHelpTips">
		<div class="help" id="whatversionHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3>Legislation is available in different versions:</h3>
				
				<p>
					<b>Latest Available (revised):</b>
					 <xsl:text>The latest available updated version of the legislation incorporating changes made by subsequent legislation and applied by our editorial team. Changes we have not yet applied to the text, can be found in the ‘Changes to Legislation’ area.</xsl:text>
					 <xsl:if test="leg:IsWelshExists(.)">
						 <xsl:text> The revised version is currently only available in English.</xsl:text>
					</xsl:if>
				</p>
				<p>
					<b>Original (As Enacted or Made)<xsl:if test="leg:IsWelshExists(.)"> - English</xsl:if>:</b>
					<xsl:text>The original </xsl:text>
					<xsl:if test="leg:IsWelshExists(.)">
							<xsl:text>English language </xsl:text>
					</xsl:if> 
					<xsl:text>version of the legislation as it stood when it was enacted or made. No changes have been applied to the text.</xsl:text>
				</p>
				<xsl:if test="leg:IsWelshExists(.)">
					<p>
						<b>Original (As Enacted or Made) - Welsh:</b>
						<xsl:text>The original Welsh language version of the legislation as it stood when it was enacted or made. No changes have been applied to the text.</xsl:text>
					</p>				
				</xsl:if>
				<xsl:if test="$pointInTimeView">
					<xsl:choose>
						<xsl:when test="$version castable as xs:date">
							<p>
								<b>Point in Time: </b>
								 <xsl:text>This becomes available after navigating to view revised legislation as it stood at a certain point in time via Advanced Features > Show Timeline of Changes or via a point in time advanced search.</xsl:text>
								 <xsl:if test="leg:IsWelshExists(.)">
									 <xsl:text> A point in time version is only available in English.</xsl:text>
								</xsl:if>											    
							</p>				
						</xsl:when>
						<xsl:when test="$version ='prospective' ">
							<p>
								<b>Latest with prospective:</b>
								<xsl:text>Latest with prospective is the latest available (revised) version of the legislation but includes the prospective versions of individual provisions where they exist. This point in time view of the legislation becomes available after clicking a prospective version of a provision via Advanced Features > Show Timeline of Changes.</xsl:text>
							</p>				
						</xsl:when>
					</xsl:choose> 
				</xsl:if>
			</div>
		</div>

		<xsl:if test="not(leg:IsTOC()) and (leg:IsCurrentRevised(.) or $showENinterweaveOption or leg:IsProposedVersion(.))">
			<div class="help" id="advFeaturesHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>See additional information alongside the content</h3>
					<xsl:choose>
						<xsl:when test="$showENinterweaveOption">
							<p>
								<b>Show Explanatory Notes for Sections: </b>
								<xsl:text>Displays relevant parts of the explanatory notes interweaved within the legislation content.</xsl:text>
							</p>
						</xsl:when>
						<xsl:when test="leg:IsProposedVersion(.)">
							<p>
								<b>Show Repeals: </b>
								<xsl:text>Displays the repeals</xsl:text>
							</p>						
						</xsl:when>
						<xsl:otherwise>
							<p>
								<b>Geographical Extent: </b>
								<xsl:text>Indicates the geographical area that this provision applies to. For further information see ‘Frequently Asked Questions’.</xsl:text>
							</p>
							<p>
								<b>Show Timeline of Changes: </b>
								<xsl:text>See how this legislation has or could change over time. Turning this feature on will show extra navigation options to go to these specific points in time. Return to the latest available version by using the controls above in the What Version box.</xsl:text>
							 </p>					
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>				
		</xsl:if>					

		<xsl:if test="(leg:IsTOC() or leg:IsContentTabDisplaying()) and not($IsPDFOnly)">
			<div class="help" id="openingOptionsHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>Opening Options</h3>
					<p>Different options to open legislation in order to view more content on screen at once</p>
				</div>
			</div>				
		</xsl:if>					

		<xsl:if test="not(leg:IsTOC())">
			<div class="help" id="viewEffectsHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>View effects described within this legislation</h3>
					<p>
						<b>Textual Effects: </b>
						<xsl:text>Effects that affect the content of other items of legislation.</xsl:text>
					</p>
					<p>
						<b>Commencements: </b>
						<xsl:text>Effects that bring this item or other items into force.</xsl:text>
					</p>
					<p>
						<b>Extent Effects: </b>
						<xsl:text>Effects that determine where this legislation applies.</xsl:text>
					</p>
				</div>
			</div>
		</xsl:if>

		<!-- displaying the output help tips for EN/EM tabs -->
		<xsl:call-template name="TSOOutputENsHelpTips"/>
		
		<xsl:if test="$showTimeline and leg:IsCurrentRevised(.)">
			<div class="help" id="timelineHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3>Timeline of Changes</h3>
					<p>
						This timeline shows the different points in time where a change occurred. The dates will coincide with the earliest date on which the change (e.g an insertion, a repeal or a substitution) that was applied came into force. The first date in the timeline will usually be the earliest date when the provision came into force.  In some cases the first date is 01/02/1991 (or for Northern Ireland legislation 01/01/2006). This date is our basedate.  No versions before this date are available. For further information see the Editorial Practice Guide and Glossary under Help.					
					</p>	
				</div>
			</div>	
		</xsl:if>
		
		<xsl:if test="exists(/leg:Legislation/ukm:Metadata/ukm:Alternatives/ukm:Alternative) or exists(/leg:Legislation/ukm:Metadata/ukm:CorrectionSlips/ukm:CorrectionSlip)">
			<div class="help" id="moreResourcesHelp">
				<span class="icon"/>
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif"/>
					</a>
					<h3>More Resources</h3>
					<p>Use this menu to access essential accompanying documents and information for this legislation item. Dependent on the legislation item being viewed this may include:</p>
					<ul>
						<li>the original print PDF of the as <xsl:value-of select="leg:GetCodeSchemaStatus(.)"/> version that was used for the print copy</li>
						<li>correction slips</li>
					</ul>
					<p></p>
					<p>Click 'View More' or select 'More Resources' tab for additional information including:</p>
					<ul>
						<li>lists of changes made by and/or affecting this legislation item</li>
						<li>confers power and blanket amendment details</li>
						<li>all formats of all associated documents</li>
						<li>links to related legislation and further information resources</li>																														
					</ul>
				</div>
			</div>			
		</xsl:if>
		
	</xsl:template>	

	<!-- ========== Standard code for outputing legislation status/timeline ========= -->
	<xsl:template name="TSOOutputLegislationStatusTimeline">
		<xsl:if test="leg:IsCurrentRevised(.)">
			<!-- Status messages for Revised -->
			<xsl:call-template name="TSOOutputStatusMessage">
				<xsl:with-param name="includeTooltip" select="tso:IncludeInlineTooltip()"/>
				<xsl:with-param name="includeTimeline" select="not($showTimeline)"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="leg:IsContent() or $wholeActURI = $dcIdentifier or $wholeActWithoutSchedulesURI = $dcIdentifier or $schedulesOnlyURI = $dcIdentifier">
			<!-- adding the changes over time -->
			<xsl:call-template name="TSOOutputChangesOverTime"/>
		</xsl:if>
		
		<!-- adding the update status warning-->
		<xsl:call-template name="TSOOutputUpdateStatusMessage">
			<xsl:with-param name="AddAppliedEffects" select="leg:IsContent()"/>
			<xsl:with-param name="includeTooltip" select="tso:IncludeInlineTooltip()"/>			
		</xsl:call-template>
		
		<!-- adding search information box -->
		<xsl:if test="$searchingByExtent or $searchingByText">
			<xsl:call-template name="TSOOutputSearchInformationMessage" />
		</xsl:if>
	</xsl:template>
	<xsl:template name="TSOOutputChangesOverTime">
	
		<!-- If $showTimeline is true then the Status area should be above the Changes to legislation area, and the timeline should be visible. --> 
	
		<!-- The timeline is only shown if $showTimeline is true. --> 
		<xsl:if test="$showTimeline and leg:IsCurrentRevised(.)">
		
			<!-- default link of the item-->
			<xsl:variable name="linkHRef" as="xs:string?" 
				select="(/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, /leg:Legislation/ukm:Metadata/dc:identifier)[1]"/>
			
			
			<!-- let $otherVersions be a list of versions that are available for the section -->
			<xsl:variable name="otherVersions" as="element()*">
				<xsl:variable name="links" as="element(atom:link)*">
					<xsl:copy-of select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and tokenize(@title, ' ')[. castable as xs:date or . = 'prospective']]"/>
				</xsl:variable>
				
				<xsl:variable name="links" as="element(atom:link)*">
				
					<xsl:for-each select="$links">

						<xsl:variable name="currentPos" select="position()" as="xs:integer"/>
						<xsl:variable name="linkVersion" select="tokenize(@title, ' ')[. castable as xs:date or . = 'prospective']" />
						<xsl:variable name="repealedVersion" as="xs:boolean" select="tokenize(@title, ' ') = 'repealed'" />
						<xsl:variable name="previousLink" select="$links[$currentPos - 1]" as="element(atom:link)?"/>
						<xsl:variable name="previousVersion" select="tokenize($previousLink/@title, ' ')[. castable as xs:date or . = 'prospective']" />
				
					
						<!-- add $startDate if the current title is valid and and greater than $startDate and preceding date is less than $startDate -->
						<xsl:if test="($startDate castable as xs:date) 
							and ($linkVersion castable as xs:date) 
							and xs:date($linkVersion) > xs:date($startDate) 
							and ( 
								not($previousVersion castable as xs:date) or 
								xs:date($previousVersion) &lt; xs:date($startDate) 
							)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion" 
								href="{leg:generateLinkHref($linkHRef, xs:string($startDate))}" 
								title="{$startDate}" iscurrent="true" />
						</xsl:if>
						
						<!-- add $startDate if the current is prospective and preceding date is less than $startDate -->
						<xsl:if test="($startDate castable as xs:date) 
							and $linkVersion = 'prospective' 
							and (
								not($previousVersion castable as xs:date)
								or xs:date($previousVersion) &lt; xs:date($startDate)
							)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion" 
								href="{leg:generateLinkHref($linkHRef, xs:string($startDate))}" 
								title="{$startDate}" iscurrent="true"/>
						</xsl:if>
						
						<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{@href}" title="{$linkVersion}">
							<xsl:if test="$repealedVersion"><xsl:attribute name="repealed" select="'true'" /></xsl:if>
						</atom:link>
						
						<!-- add $startDate in the last if it is not added -->
						<xsl:if test="($startDate castable as xs:date) 
							and ($linkVersion castable as xs:date) 
							and (xs:date($linkVersion) &lt; xs:date($startDate)
							and position() = last()
						)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion" 
								href="{leg:generateLinkHref($linkHRef, xs:string($startDate))}" 
									title="{$startDate}" iscurrent="true"/>
						</xsl:if>						
					</xsl:for-each>
			
				</xsl:variable>
				
				<!-- if  there are no links available and startDate is valid  --> 
				<xsl:if test="$startDate castable as xs:date and count($links) = 0">
					<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( $linkHRef, '/', $startDate)}" title="{$startDate}" iscurrent="true"/>
				</xsl:if>
				
				<!-- if $startdate is not provided and there is not 'Prospective' status and $baseDate is not in the $links then add the base date --> 
				<xsl:if test="empty($startDate) and not($prospective) and not(exists($links[@title = $baseDate]) )">
					<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat($linkHRef, '/', $baseDate)}" title="{$baseDate}"/>
				</xsl:if>
				
				<!-- if repealed then ignore all the @title castable as xs:date and greater than $enddate --> 
				<xsl:choose>
					<xsl:when test="$repealed">
						<xsl:sequence select="$links[not(tokenize(@title, ' ')[. castable as xs:date]) or xs:date(tokenize(@title, ' ')[. castable as xs:date]) &lt;= xs:date($endDate)]" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$links" />
					</xsl:otherwise>
				</xsl:choose>	
				 		
			</xsl:variable> 
			
			<!-- minimum width of each bar-->
			<xsl:variable name="minWidth" select="140"/>
			
				<!-- 
			  - pointers for each available version of the section ($versions), which will include
				- normal pointers for each date listed in $versions
				- a pointer for the prospective version, if there is one
				- if $repealed is true, a pointer for the $endDate
			-->
			<xsl:variable name="pointers">
				<xsl:for-each select="$otherVersions">
					<xsl:variable name="pos" select="position()" />
					<!-- finding the number of the between the current and previous version-->
					<xsl:variable name="numberOfDays">
						<xsl:choose>
							<xsl:when test="@title castable as xs:date and $otherVersions[$pos+1]/@title castable as xs:date">
								<xsl:variable name="versionDate" as="xs:date" select="xs:date(@title)" />
								<xsl:variable name="nextVersionDate" as="xs:date" select="xs:date($otherVersions[$pos+1]/@title)" />
								<xsl:variable name="numberOfDaysFormatted" select="translate(xs:string($nextVersionDate - $versionDate ), 'PD', '')" />
								<xsl:choose>
									<xsl:when test="$numberOfDaysFormatted castable as xs:integer">
											<xsl:value-of select="xs:integer($numberOfDaysFormatted)"/>
									</xsl:when>
									<xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
				
					<leg:pointer numberOfDays="{$numberOfDays}">
						<xsl:copy-of select="@*"/>
					</leg:pointer>
	
				</xsl:for-each>
				
				<!-- if $prospective and prospective is not in the versions --> 
				<xsl:if test="$prospective and not($otherVersions[@title = 'prospective'])">
					<leg:pointer href="{concat($linkHRef, '/', if ($repealed) then (xs:date($endDate) - xs:dayTimeDuration('P1D')) else 'prospective' )}" title="prospective" numberOfDays="0"/>
				</xsl:if>
				
				<!-- if the current section is repealed and there is no repealed exists in the versions then add it  -->
				<xsl:if test="$repealed and not($otherVersions[@repealed])">
					<leg:pointer href="{concat($linkHRef, '/', $endDate)}" title="{$endDate}" repealed="true" numberOfDays="0" />
				</xsl:if>
			</xsl:variable>			
						
			<xsl:if test="false()">
				Debug 
				<ul>
					<li>showTimeline : <xsl:value-of select="$showTimeline"/></li>
					<li>version : <xsl:value-of select="$version"/></li>
					<li>pointInTimeView : <xsl:value-of select="$pointInTimeView"/></li>
					
					<li>startDate : <xsl:value-of select="$startDate"/></li>
					<li>conurrent startDate: <xsl:value-of select="key('g_keyNodeIDs', tokenize($selectedSection/@AltVersionRefs, ' '))/*/@RestrictStartDate/xs:date(.)"/></li>
					<li>exists startDate : <xsl:value-of select="exists($startDate)"/></li>	
			
					<li>endDate : <xsl:value-of select="$endDate"/></li>
					<li>exists endDate : <xsl:value-of select="exists($endDate)"/></li>					
					
					<li>prospective : <xsl:value-of select="$prospective"/></li>
					<li>repealed : <xsl:value-of select="$repealed"/></li>
					<li>notYetInForce : <xsl:value-of select="$notYetInForce"/></li>
					<li>otherVersions : 
						<ul>
							<xsl:for-each select="$otherVersions">
								<li><xsl:value-of select="concat('        ', @title)"/></li>
							</xsl:for-each>
						</ul>
						<ul>
							<li>
								- <xsl:copy-of select="$otherVersions"/>
							</li>
						</ul>
					</li>
					<li>pointers: 
						<ul>
							<xsl:for-each select="$pointers/*">
								<li><a href="{@href}"><xsl:value-of select="concat('        ', @title)" /></a></li>
							</xsl:for-each>
						</ul>
						<ul>
							<li>
								- <xsl:copy-of select="$pointers"/>
							</li>
						</ul>						
					</li>					
					<ul>
						Processing:
						<xsl:variable name="links" as="element(atom:link)*">
							<xsl:copy-of select="/leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and (@title castable as xs:date or @title='prospective')]"/>
						</xsl:variable>						
							
					<xsl:for-each select="$links">
					
						<xsl:variable name="currentPos" select="position()" as="xs:integer"/>
					
						<!-- add the $start in the required location-->
						<xsl:if test="($startDate castable as xs:date) 
							and (@title castable as xs:date) 
							and xs:date(@title) > xs:date($startDate) 
							and ( 
								not($links[$currentPos - 1]/@title castable as xs:date) or 
								xs:date($links[$currentPos - 1]/@title) &lt; xs:date($startDate) 
							)">
							<!--<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( /leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, '/', $startDate)}" title="{$startDate}" iscurrent="true" />-->
							<li>add -1 - <xsl:value-of select="$startDate" /></li>
						</xsl:if>
						
						<!-- add the $start in the required location-->
						<xsl:if test="($startDate castable as xs:date) 
							and @title = 'prospective' 
							and ( 
								not($links[$currentPos - 1]/@title castable as xs:date) or 
								xs:date($links[$currentPos - 1]/@title) &lt; xs:date($startDate) 
							)">
							<!--	
					<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( /leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, '/', $startDate)}" title="{$startDate}" iscurrent="true" />-->
							<li>add -1 - <xsl:value-of select="$startDate" /></li>
						</xsl:if>						
		
						<li>
							Current:<xsl:value-of select="@title"/>, Previous:<xsl:value-of select="$links[$currentPos - 1]/@title"/>
						</li>	
						<xsl:copy-of select="."/>
						
						<!-- add $startDate in the last if it is not added -->
						<xsl:if test="($startDate castable as xs:date) 
							and (@title castable as xs:date) 
							and (xs:date(@title) &lt; xs:date($startDate)
							and position() = last()
						)">
							<atom:link rel="http://purl.org/dc/terms/hasVersion" href="{concat( /leg:Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion' and @title = 'current']/@href, '/', $startDate)}" title="{$startDate}" iscurrent="true"/>
							<li>add in end <xsl:value-of select="$startDate"/></li>
						</xsl:if>						
					</xsl:for-each>
				</ul>
				</ul>
			</xsl:if>
						
				<div id="changesOverTime">
					<!-- The title of the timeline should be "Changes over time for: {section name}". -->
					<h2><xsl:text>Changes over time for:  </xsl:text>
						<xsl:choose>
							<xsl:when test="$nstSelectedSection">
						<xsl:apply-templates select="$nstSelectedSection" mode="CurrentSectionName" />
							</xsl:when>
							<xsl:when test="$introURI = $dcIdentifier">
								<xsl:value-of select="$introductoryText"/>
							</xsl:when>
							<xsl:when test="$wholeActURI = $dcIdentifier">
								<xsl:value-of select="$dc-title"/>
							</xsl:when>
							<xsl:when test="$wholeActWithoutSchedulesURI = $dcIdentifier">
								<xsl:value-of select="$dc-title"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="leg:TranslateText(concat('without ', $schedulesText))"/>
								<xsl:text>)</xsl:text>
							</xsl:when>
							<xsl:when test="$schedulesOnlyURI = $dcIdentifier">
								<xsl:value-of select="$dc-title"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="leg:TranslateText(concat($schedulesText, ' only'))"/>
								<xsl:text>)</xsl:text>
							</xsl:when>							
						</xsl:choose>
					</h2>
					<div class="timelineHelp"> <a href="#timelineHelp" class="helpItem helpItemToMidLeft"><img src="/images/chrome/helpIcon.gif" alt=" Help about opening options" /></a></div>
					
					
					<!-- If $pointInTimeView is true, under the title will be some text saying:
					
					  - if $repealed is true, "No longer has effect: {$endDate}"
					  - if $notYetInForce is true, "No versions valid at: {$version}"
					  - if there is no $endDate, nothing
					  - otherwise, "Version Superseded: {$endDate}"
					-->					
					<xsl:if test="$pointInTimeView">
						<xsl:choose>
							<xsl:when test="$repealed">
								<p class="warning">No longer has effect: <xsl:value-of select="leg:FormatDate($endDate)"/></p>
							</xsl:when>
							<xsl:when test="$notYetInForce">
								<p class="warning">No versions valid at: <xsl:value-of select="leg:FormatDate($version)"/></p>
							</xsl:when>
							<xsl:when test="string-length($endDate)= 0"/>
							<xsl:otherwise>
								<p class="warning">Version Superseded: <xsl:value-of select="leg:FormatDate($endDate)"/></p>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>		
								
					<!-- total width of the timeline -->
					<xsl:variable name="totalWidth" as="xs:integer+">
						<xsl:if test="$notYetInForce">
							<xsl:sequence select="$minWidth"/>
						</xsl:if>
									
						<xsl:for-each select="$pointers/*">
							<xsl:if test="@title castable as xs:date and xs:date(@title) &gt; current-date()">
								<xsl:sequence select="$minWidth"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="count($pointers/*) &lt;= 4">
									<xsl:sequence select="xs:integer( (minWidth * 4) div count(pointers/*) )"/>													
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="leg:GetWidthInPixels(@numberOfDays, $minWidth)"/>
								</xsl:otherwise>
							</xsl:choose>							
						</xsl:for-each>
					
						<!-- default width for the <ul>-->
						<xsl:sequence select="50"/>
					</xsl:variable>
					
					<!-- total content width of the timeline -->
					<xsl:variable name="contentWidth" as="xs:integer+">
						<!-- default width for the timeline-->
						<xsl:sequence select="if (sum($totalWidth) &lt; 677) then 677 else sum($totalWidth)"/>									
					
						<xsl:if test="$notYetInForce">
							<xsl:sequence select="- $minWidth"/>
						</xsl:if>
									
						<xsl:for-each select="$pointers/*">
							<xsl:if test="@title castable as xs:date and xs:date(@title) &gt; current-date()">
								<xsl:sequence select="- $minWidth"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<div id="timeline">
						<div id="timelineData" style="width:{if (sum($totalWidth) &lt; 677) then 677 else sum($totalWidth) }px">					
						
							<h3 class="accessibleText">Alternative versions:</h3>
						
							<!-- The timeline needs to include the following: -->
							<ul>

								<!-- the bar along which the pointers are positioned, which will include -->

								<!-- - if $notYetInForce is true, a leading solid bar -->
								<xsl:if test="$notYetInForce">
									<li style="width: {$minWidth}px"/>
								</xsl:if>

								<xsl:for-each select="$pointers/*">
								
										<!-- if any $versions are after the current date, a dashed bar before the pointers for those versions -->
										<xsl:if test="@title castable as xs:date and xs:date(@title) &gt; current-date()">
											<li style="width: {$minWidth}px" class="dash"/>
										</xsl:if>
								
										<!-- width of the bar -->
										<xsl:variable name="liWidth" select="xs:integer( sum($contentWidth) div count($pointers/*) )" as="xs:integer"/>
										
										<!-- 
										  one of these pointers (and the timeline bar to the right of it) will be highlighted as indicating the current version of the provision:
											- if $notYetInForce is true, this will be the first pointer
											- if $repealed is true, this will be the last pointer
											- if $prospective is true, this will be the prospective pointer
											- otherwise, it will be the pointer representing the date that is closest (most recently in the past) to the $version
										-->
										<xsl:variable name="isCurrentVersion" as="xs:boolean">
											<xsl:choose>
												<xsl:when test="$notYetInForce and position() = 1">
													<xsl:sequence select="true()"/>												
												</xsl:when>
												<xsl:when test="$repealed">
													<xsl:choose>
														<xsl:when test="position() = last() - 1"><xsl:sequence select="true()"/></xsl:when>
														<xsl:otherwise><xsl:sequence select="false()" /></xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:when test="$prospective and @title = 'prospective'">
													<xsl:sequence select="true()"/>
												</xsl:when>
												<xsl:when test="@iscurrent">
													<xsl:sequence select="true()"/>													
												</xsl:when>
												<xsl:when test="@title = $version">
													<xsl:sequence select="true()"/>
												</xsl:when>
												<xsl:otherwise>
													<!--
														finding the pointer closest(most recently in the path) to the $version
														i = current index
														if (i+1 is date )
														{
															if (i+1 > $version and (i is not date or i < $version)) then 
															  currentVersion
														}
														else
														{
														   if (
															if ((i is date and  i < $version) )
																  currentVersion
														}	
													--> 
													<xsl:choose>
														<xsl:when test="following-sibling::*[1]/@title castable as xs:date">
															<xsl:choose>
																<xsl:when test="xs:date(following-sibling::*[1]/@title) &gt; leg:GetVersionDate($version) and ( not(@title castable as xs:date) or xs:date(@title) &lt; leg:GetVersionDate($version)) ">
																	<xsl:sequence select="true()"/>
																</xsl:when>
																<xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:when test="following-sibling::*[1]/@title = 'prospective' and $prospective">
															<xsl:sequence select="false()" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:choose>
																<xsl:when test="(@title castable as xs:date) and xs:date(@title) &lt; leg:GetVersionDate($version)">
																	<xsl:sequence select="true()"/>
																</xsl:when>
																<xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
															</xsl:choose>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>
											
											<!-- 
											- if $repealed is true, a trailing solid bar with no arrow at the end
											- if $version is 'prospective' and $prospective is false, a trailing dashed bar with no arrow at the end
												otherwise it is last then add an error
										-->											
										<xsl:variable name="addArrow" as="xs:boolean">
											<xsl:choose>
												<xsl:when test="$repealed and position() = last()">
													<xsl:sequence select="false()"/>
												</xsl:when>
												<xsl:when test="$version = 'prospective' and not($prospective) and position() = last()">
													<xsl:sequence select="false()"/>
												</xsl:when>
												<xsl:when test="position() = last()">
													<xsl:sequence select="true()"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:sequence select="false()"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
											
										<xsl:variable name="liWidth" select="if ($addArrow) then ($liWidth - 20) else $liWidth" />
											
										<li style="width: {$liWidth}px;">
											
											<xsl:variable name="class">
												<xsl:choose>
													<xsl:when test="$isCurrentVersion and @title = 'prospective'">currentVersion currentProspective</xsl:when>
													<xsl:when test="$isCurrentVersion">currentVersion</xsl:when>
													<xsl:when test="@title ='prospective'">prospective</xsl:when>
												</xsl:choose>
												<xsl:if test="@repealed = true() or ($repealed and position() = last())">
													<xsl:text>stopDate</xsl:text>
													<xsl:if test="@repealed = 'true' and position() != last()"> dash</xsl:if>
												</xsl:if>
											</xsl:variable>
											
											<xsl:if test="string-length($class) ne 0">
												<xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
											</xsl:if>
											
											<xsl:choose>
												<xsl:when test="@repealed = true() or ($repealed and position() = last())">
													<span class="stop">		
														<span class="pointer"/>
														<span class="label">
															<xsl:text>Stop date </xsl:text>
															<xsl:value-of select="leg:FormatDate(@title)"/><em class="accessibleText"> - Amendment</em>
														</span>
													</span>
												</xsl:when>
												<!--  Prevent a link to a prosp doc if none exists but retain the timeline icons  -->
												<xsl:when test="lower-case(@title) = 'prospective' and empty($prospDoc)">
													<a href="#">		
														<span class="pointer"/>
														<span>
															<xsl:value-of select="leg:FormatDate(@title)"/><em class="accessibleText"> - Amendment</em>
														</span>
													</a>
												</xsl:when>
												<xsl:otherwise>
													<a href="{leg:FormatURL(@href)}">		
														<span class="pointer"/>
														<span>
															<xsl:value-of select="leg:FormatDate(@title)"/><em class="accessibleText"> - Amendment</em>
														</span>
													</a>
												</xsl:otherwise>
											</xsl:choose>

											<a href="{leg:FormatURL(@href)}"/>
											
											<xsl:if test="$addArrow">
												<span class="end"/>
											</xsl:if>
										</li>
										
										<!-- 
										  - if $pointInTimeView is true, an indicator showing the current point in time:
										- if $notYetInForce is true then this will be before any of the pointers
											- if $repealed is true, this will be after the pointer for the $endDate
											- if $version is 'prospective' but $prospective is false, this will be on the trailing dashed bar
											- if $version exactly matches one of the $versions, it will be directly above that version pointer
											- otherwise, it will be between the pointers for the versions either side, positioned roughly
										-->									
										<xsl:if test="$pointInTimeView">
											<xsl:variable name="displayStyle">
												<xsl:choose>
													<xsl:when test="$notYetInForce and position()=1">margin-left: <xsl:value-of select="-53*2 - $liWidth"/>px;</xsl:when>
													<xsl:when test="$repealed and $endDate = @title">margin-left: <xsl:value-of select="-53 - $liWidth"/>px;</xsl:when>
													<xsl:when test="$version = @title">margin-left: <xsl:value-of select="-53 - $liWidth"/>px;</xsl:when>
													<xsl:when test="$isCurrentVersion and $repealed"/> 													
													<xsl:when test="($isCurrentVersion) or ($version ='prospective' and $prospective = false() and position() = last())">
														<xsl:text>margin-left: </xsl:text>
														<xsl:value-of select="-53 - xs:integer($liWidth div 2)"/>
														<xsl:text>px;</xsl:text>
													</xsl:when>
												</xsl:choose>
											</xsl:variable>

										<xsl:if test="string-length($displayStyle) ne 0 or $version = @title">
											<li class="pointInTime{if ($version castable as xs:date) then '' else ' prospectivePIT'}" style="{$displayStyle}">
												<span>
													<strong>	
														<xsl:choose>
															<xsl:when test="$version castable as xs:date">
																<xsl:value-of select="leg:FormatDate($version)"/>
															</xsl:when>
															<xsl:otherwise>
																<xsl:text>Latest with prospective</xsl:text>
															</xsl:otherwise>
														</xsl:choose>
													</strong>
													<br/>
													<em>Point in time</em>
												</span>
											</li>		
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
							</ul>	
						</div>
					</div>
				</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="TSOOutputSearchInformationMessage">
		<xsl:variable name="messages" as="document-node()*">
			<xsl:if test="$searchingByText">
				<xsl:document>contain the text '<strong><xsl:value-of select="$searchingByText" /></strong>'</xsl:document>
			</xsl:if>
			<xsl:if test="$searchingByExtent">
				<xsl:document>
					<xsl:choose>
						<xsl:when test="starts-with($searchingByExtent, '=')">
							<xsl:text>exclusively extend to </xsl:text>
							<xsl:sequence select="tso:extentDescription(tokenize(substring($searchingByExtent, 2), '\+'), ' and ', true())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>are applicable to </xsl:text>
							<xsl:sequence select="tso:extentDescription(tokenize($searchingByExtent, '\+'), ' or ', true())" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:document>
			</xsl:if>
		</xsl:variable>
		<div id="infoSection">
			<h2>Information:</h2>
			<p class="intro">
				<xsl:text>You searched for provisions that </xsl:text>
				<xsl:for-each select="$messages">
					<xsl:sequence select="node()" />
					<xsl:if test="position() != last()"> and </xsl:if>
				</xsl:for-each>
				<xsl:text>. The matching provisions are highlighted below.</xsl:text>
			</p>
		</div>
	</xsl:template>

	
	<xsl:function name="leg:GetWidthInPixels">
		<xsl:param name="numberOfDays" as="xs:decimal" />
		<xsl:param name="minWidth" as="xs:integer" />		


		<xsl:variable name="minRangeWidth" select="20"/>			
		<xsl:variable name="minRange" select="1"/>					
		
		<xsl:variable name="numberOfYears" as="xs:decimal" select="$numberOfDays div 365"/>
		<xsl:choose>
			<xsl:when test="$arrangePointersEqually"><xsl:value-of select="$minWidth"/></xsl:when>											
			<xsl:when test="$numberOfYears &lt;= 0.5 "><xsl:value-of select="xs:integer($minWidth div 1.5)"/></xsl:when>			
			<xsl:when test="$numberOfYears &lt;= $minRange">
				<xsl:value-of select="xs:integer($numberOfYears * $minWidth)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="xs:integer(($minRange * $minWidth) + ($numberOfYears - $minRange) * $minRangeWidth)"/>
			</xsl:otherwise>
		</xsl:choose>		

	</xsl:function>

	<xsl:function name="leg:FormatHTMLDataURL" as="xs:string">
		<xsl:param name="url"/>
		
		<xsl:sequence select="concat(tso:remove-extent(substring-after($url,'http://www.legislation.gov.uk')), '/data.xht','?view=snippet&amp;wrap=true') "/>
	</xsl:function>	
	
	<xsl:function name="leg:FormatPDFDataURL" as="xs:string">
		<xsl:param name="url"/>
		<!-- #395 we need to carry the extent query through so that the PDF generation knows about it -->
		<xsl:variable name="strQuery" as="xs:string?">
			<xsl:choose>
				<xsl:when test="tokenize(leg:get-query-param('view'), '\+') = 'extent' and contains(leg:get-query('repeals'), 'true')">
					<xsl:text>?view=extent&amp;repeals=true</xsl:text>
				</xsl:when>
				<xsl:when test="tokenize(leg:get-query-param('view'), '\+') = 'extent'">
					<xsl:text>?view=extent</xsl:text>
				</xsl:when>
				<xsl:when test="contains(leg:get-query('repeals'), 'true')">
					<xsl:text>?repeals=true</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="concat( tso:remove-extent(substring-after($url,'http://www.legislation.gov.uk')), '/data.pdf',$strQuery)"/>
		
		
	</xsl:function>	

	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:sequence select="leg:FormatURL($url, true())" />
	</xsl:function>
	<xsl:function name="leg:FormatURL" as="xs:string">
		<xsl:param name="url"/>
		<xsl:param name="addQueryString" as="xs:boolean" />
		<xsl:choose>
			<xsl:when test="string-length($url) ne 0">
				<!-- todo: post launch <xsl:value-of select="string-join((substring-after($url,'http://www.legislation.gov.uk'), $requestInfoDoc/request/request-querystring), '?')"/>-->
				<xsl:value-of select="concat(substring-after($url,'http://www.legislation.gov.uk'), if ($requestInfoDoc/request/query-string != '' and $addQueryString) then concat('?',$requestInfoDoc/request/query-string) else '') "/>
			</xsl:when>
			<xsl:otherwise>
				<!-- if the $url is not available then link to the same page -->
				<xsl:value-of select="string-join(($requestInfoDoc/request/request-url, if ($addQueryString) then $requestInfoDoc/request/request-querystring else ()), '?')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- removing the extent information from the  PDF/HTM URL-->
	<xsl:function name="tso:remove-extent">
		<xsl:param name="url" as="xs:string"/>
		<xsl:variable name="removeExtent" as="xs:string+" >
			<xsl:variable name="tokens" as="xs:string+" select="tokenize($url, '/')" />
			<xsl:for-each select="$tokens">
				<xsl:choose>
					<!-- Chunyu HA049961 Added the condition for crossheading which need to keep the extent see http://www.legislation.gov.uk/ukpga/1997/40/crossheading/england-and-wales -->
					<xsl:when test="position() = last() and matches(., '^(england|wales|scotland|ni)(\+(england|wales|scotland|ni))*$') and not($tokens[position() - 1] = 'crossheading')"/>
					<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="string-join($removeExtent, '/')"/>
	</xsl:function>
	
	
	<xsl:function name="leg:GetVersionDate" as="xs:date">
		<xsl:param name="versionDate" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="$versionDate castable as xs:date"><xsl:sequence select="xs:date($versionDate)"/></xsl:when>
			<xsl:otherwise><xsl:sequence select="current-date()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="leg:IsContentTabDisplaying" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="leg:IsContent() or $wholeActURI = $dcIdentifier or $wholeActWithoutSchedulesURI = $dcIdentifier or $schedulesOnlyURI = $dcIdentifier"><xsl:value-of select="true()"/></xsl:when>						
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="leg:generateLinkHref" as="xs:string">
		<xsl:param name="linkHRef" as="xs:string"/>
		<xsl:param name="startDate" as="xs:string"/>
		<xsl:value-of select="if (ends-with($linkHRef, '/revision')) then 
								concat(substring-before($linkHRef, '/revision'), '/', $startDate, '/revision') 
							else concat($linkHRef, '/', $startDate)"/>
	</xsl:function>	
	<!-- Hiding the legislation notifications as requested by TNA Issue 234 -->
	<xsl:template name="FuncLegNotification" />
	
</xsl:stylesheet>
