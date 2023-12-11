<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs atom"
	version="2.0">
	
	<xsl:import href="quicksearch.xsl"/>
		
	
	
	<xsl:variable name="entries" select=".//atom:entry"/>  
	
	<xsl:variable name="introURI" as="xs:string?" select="/atom:feed/atom:link[@rel='http://www.legislation.gov.uk/def/navigation/introduction' and @title='introduction']/@href" />
	
	<xsl:variable name="tocURI" as="xs:string?" select="
		if (/atom:feed/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='en']) then 
			/atom:feed/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][@hreflang='en']/@href
			else if (/atom:feed[@rel='http://purl.org/dc/terms/tableOfContents']) then 
			/atom:feed/atom:link[@rel='http://purl.org/dc/terms/tableOfContents'][1]/@href
		else ()
	"/>
	
	
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Updates</title>
				<meta name="DC.Date.Modified" content="{/atom:feed/atom:updated}" />
				<link href="/styles/source/pages/editorial/updates-lists.css" rel="stylesheet" type="text/css" />
				
				<style type="text/css">
					<xsl:text>/* Legislation stylesheets - load depending on content type */&#xA;</xsl:text>
					<xsl:text>@import "/styles/legislation.css";&#xA;</xsl:text>
				
						
					<xsl:text>@import "/styles/legislationOverwrites.css";&#xA;</xsl:text>			
					<xsl:text>/* End of Legislation stylesheets */&#xA;</xsl:text>	
				</style>
				<script type="text/javascript" src="/scripts/participation/view/revisionUpdates.js"></script>
				
				
			</head>
			
			<body xml:lang="en" lang="en" dir="ltr" id="leg" >
				<!-- commenting out the highlighting
					<xsl:if test="leg:IsContentTabDisplaying()">
						<xsl:attribute name="onload">RunHighlight();</xsl:attribute>
					</xsl:if>
				 -->
				
				<div id="layout2" class="legContent updatesList">
					
					<div class="contentTitle statistics">
						<h1><xsl:value-of select="if (/atom:feed/atom:title) then /atom:feed/atom:title else 'Outstanding Updates' "/></h1>
					</div>
					<ul id="legSubNav">
						<li id="legTocLink">
							<span class="presentation"></span>
							<a href="{$tocURI}">Table of Contents</a>
						</li>
						<li id="legUpdatesLink">
							<span class="presentation"></span>
								<xsl:choose>
									<xsl:when test="exists($introURI)">
										<a href="{$introURI}" >Content</a>							
									</xsl:when>
									<xsl:otherwise>
										<span>Content</span>
									</xsl:otherwise>
								</xsl:choose>
						</li>
						
							<li id="legContentLink">
								<span class="presentation"></span>
								<a href="{/updates}"  class="disabled">Outstanding Updates</a>
								<!--<a href="#moreResourcesTabHelp" class="helpItem helpItemToBot">
									<img src="/images/chrome/helpIcon.gif" alt=" Help about More Resources"/>
								</a>-->
							</li>
						
				</ul>
					<!--<xsl:choose>
						<xsl:when test="leg:IsTOC()"><xsl:attribute name="class">legToc</xsl:attribute></xsl:when>
						<xsl:when test="$IsPDFOnly"><xsl:attribute name="class">legToc</xsl:attribute></xsl:when>
						
						<xsl:when test="$dcIdentifier = ($signatureURI, $noteURI, $earlierOrdersURI)"><xsl:attribute name="class">legContent</xsl:attribute></xsl:when>
						<xsl:when test="leg:IsContent()"><xsl:attribute name="class">legContent</xsl:attribute></xsl:when>						
						<xsl:when test="$wholeActURI = $dcIdentifier "><xsl:attribute name="class">legComplete</xsl:attribute></xsl:when>
						<xsl:when test="$wholeActWithoutSchedulesURI = $dcIdentifier "><xsl:attribute name="class">legComplete</xsl:attribute></xsl:when>						
						<xsl:when test="$schedulesOnlyURI = $dcIdentifier "><xsl:attribute name="class">legComplete</xsl:attribute></xsl:when>												
						<xsl:otherwise/>
					</xsl:choose>-->
					
					<!-- adding quick search  
					<xsl:call-template name="TSOOutputQuickSearch"/>-->
					
					<!-- adding the title of the legislation
					<xsl:call-template name="TSOOutputLegislationTitle"/>-->
					
					<!-- breadcrumb
					<xsl:call-template name="TSOOutputBreadcrumbItems"	/> -->
					
					<!-- Sub Navigation tabs
					<xsl:call-template name="TSOOutputSubNavTabs" />-->
					
					<!--./interface -->
					
					<table class="updatesTable">
						<thead class="tableGroup accessibleText">
							<tr class="accessibleText">
								<th id="updates-id">&#160;</th>
								<th id="updates-version">Versions</th>
								<th id="updates-toApply">Updates to Apply</th>
								<th id="updates-action">Action</th>
								<th id="updates-lasr">&#160;</th>
							</tr>
						</thead>
						<tbody class="tableGroup2">
							<tr class="newSection">
								<th colspan="5">
									<span class="accessibleText"></span>
								</th>
							</tr>
							<tr class="tableHeadings">
								<th id="updates-id">&#160;</th>
								<th id="updates-version">Versions</th>
								<th id="updates-toApply">Updates to Apply</th>
								<th id="updates-action">Action</th>
								<th id="updates-lasr">&#160;</th>
							</tr>
							<xsl:for-each select="distinct-values(//atom:entry/atom:link/@href)">
								<xsl:sort select="xs:date(if (matches(., '_sld_[0-9]')) then
										substring-before(substring-after(., '_sld_'), '.xml')
										else if (matches(., '_ed_')) then
										substring-before(substring-after(., '_ed_'), '.xml')
										else if (matches(., 'snapshot')) then
										tokenize(substring-before(., '/snapshot'), '/')[last()]
										else ())" />
								<xsl:variable name="pit" select="."/>
								<xsl:variable name="pit-date" select="if (matches($pit, '_sld_')) then
										substring-before(substring-after($pit, '_sld_'), '.xml')
										else if (matches($pit, '_ed_')) then
										substring-before(substring-after($pit, '_ed_'), '.xml')
										else if (matches($pit, 'snapshot')) then
										tokenize(substring-before($pit, '/snapshot'), '/')[last()]
										else ."/>
								<xsl:variable name="version" select="replace($pit-date, '.xml', '')"/>
								<xsl:variable name="odd" as="xs:boolean" select="position() mod 2 = 1" />
								<tr class="updateLists">
									<xsl:if test="$odd">
										<xsl:attribute name="class">oddRow updateLists</xsl:attribute>
									</xsl:if>
									<td header="updates-id" >&#160;</td>
									<td headers="updates-version" class="icon"><xsl:value-of select="$pit-date"/></td>
									<td headers="updates-toApply" class="icon"><xsl:value-of select="count($entries[atom:link/@href = $pit])"/> </td>
									<td headers="updates-action" class="icon">
										<form action="" method="post" >
											<input type="hidden" name="version" value="{$version}" />
											<button name="action" class="progressRequestLink" type="submit" value="applyUpdate">Apply Update</button>
										</form>
									</td>
									<td header="updates-last">&#160;</td>
								</tr>
							</xsl:for-each>
							<!--<tr>
								<td colspan="5"><xsl:apply-templates select="//atom:entry"/></td>
							</tr>-->
							
						</tbody>
					</table>
					
				</div>			
				
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="atom:entry">
		<h2><xsl:value-of select="atom:title"/></h2>
	</xsl:template>
	
</xsl:stylesheet>
