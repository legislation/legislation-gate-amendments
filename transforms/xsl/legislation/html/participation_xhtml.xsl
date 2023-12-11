<!-- UI Legislation Participation page output  -->
<!-- Created by Jeni Tennison -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="http://www.w3.org/1999/xhtml"  
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	exclude-result-prefixes="xhtml xs tso dc db ukm dct atom leg">
	
	<!-- ========== Standard code for outputing UI wireframes========= -->
	<xsl:import href="toc_xhtml.xsl"/>	
	
	<xsl:output indent="yes" method="xhtml" />

	<xsl:variable name="PDFonly" as="xs:boolean">
		<xsl:sequence select="if (//ukm:Statistics) then false() else true()"/>
	</xsl:variable>
	
	
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title" />
				</title>
				<xsl:apply-templates select="/leg:Legislation/ukm:Metadata" mode="HTMLmetadata" />
				
				<script type="text/javascript" src="/scripts/view/tabs.js"></script>				
				<xsl:call-template name="TSOOutputAddLegislationStyles" />
				
			</head>
			<body xml:lang="en" lang="en" dir="ltr" id="leg" about="{$dcIdentifier}" class="resources">
			
				<div id="layout2" class="legParticipation">
				
					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>
				
					<!-- adding the title of the legislation-->
					<xsl:call-template name="TSOOutputLegislationTitle"/>
					
					 <!-- breadcrumb -->
					<xsl:call-template name="TSOOutputBreadcrumbItems"	/>
					
					 <!-- tabs -->
					<xsl:call-template name="TSOOutputSubNavTabs"/>			
						
					<div class="interface"/>
					<!--./interface -->
					
					<div id="content">
					
						<!-- outputing the legislation content-->
						<xsl:apply-templates select="/leg:Legislation" mode="TSOOutputLegislationContent"/>

						<p class="backToTop">
							<a href="#top">Back to top</a>
						</p>
						
					</div>
					<!--/content-->
					
				</div>
				<!--layout2 -->
			
				<!-- help tips -->
				<xsl:call-template name="TSOOutputHelpTips"/>					
					
			</body>
		</html>
	
	</xsl:template>
	
	
	<!-- ========== Standard code for outputing legislation content ========= -->
	 <xsl:template match="leg:Legislation" mode="TSOOutputLegislationContent">
		 <xsl:variable name="theTitle">
				<xsl:choose>
					<xsl:when test="count(/leg:Legislation/ukm:Metadata/dc:title) = 1">
						<xsl:value-of select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title, 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title)"/>
					</xsl:when>
					<xsl:when test="$language = 'cy'">
						<xsl:value-of select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title[@xml:lang='cy'], 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title[@xml:lang='cy'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(if (starts-with(/leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang='cy')], 'The ')) then '' else 'the ', /leg:Legislation/ukm:Metadata/dc:title[not(@xml:lang='cy')])"/>	
					</xsl:otherwise>
				</xsl:choose>	 
		 </xsl:variable>
	 	<xsl:variable name="versions" as="element()*" select="/leg:Legislation/ukm:Metadata/atom:link[@rel = 'http://purl.org/dc/terms/hasVersion']" />
	 	<xsl:variable name="itemURI" as="xs:string">
	 		<xsl:choose>
	 			<xsl:when test="$versions[@title castable as xs:date] or $versions[@title = 'prospective']">
	 				<xsl:sequence select="$wholeActURI" />
	 			</xsl:when>
	 			<xsl:otherwise>
	 				<xsl:sequence select="$versions[1]/@href" />
	 			</xsl:otherwise>
	 		</xsl:choose>
	 	</xsl:variable>
	 	<xsl:variable name="itemURI" as="xs:string" select="leg:FormatURL($itemURI)" />
		<div class="innerContent">
			<h2 class="accessibleText">
				<xsl:text>Participation for </xsl:text>
				<xsl:value-of select="$theTitle"/>
			</h2>
			
			<div class="colSection p_one s_12">
				<div class="markup">
					<h3>Markup</h3>
					<div class="p_one s_7">
						<xsl:choose>
							<xsl:when test="$PDFonly">
								<ul class="plainList">
									<li>This document is only available as a PDF and cannot be enriched</li>
								</ul>
							</xsl:when>
							<xsl:otherwise>
								<ul class="plainList">
									<li>
										<a href="{$itemURI}/enriched">
											<strong>Enriched version of <xsl:value-of select="$theTitle" /></strong>
										</a>
										<span class="pageLinkIcon"/>
									</li>
									<li>
										<a href="{$itemURI}/enriched/data.xml">
											<strong>Enriched XML version of <xsl:value-of select="$theTitle" /></strong>
										</a>
										<span class="pageLinkIcon"/>
									</li>
									<li>
										<a href="{$itemURI}/enriched/data.xls">
											<strong>Excel spreadsheet of effects from <xsl:value-of select="$theTitle" /></strong>
										</a>
										<span class="pageLinkIcon"/>
									</li>
									<li>
										<a href="{$itemURI}/enriched/data.pdf">
											<strong>Marked up PDF version of <xsl:value-of select="$theTitle" /></strong>
										</a>
										<span class="pageLinkIcon"/>
									</li>
								</ul>
							</xsl:otherwise>
						</xsl:choose>
						
					</div>
					<xsl:if test="not($PDFonly)">
						<div class="p_two s_4">
							<form action="{$itemURI}" method="post">
								<div class="p_one s_3">
									<label for="markupSubmit">Create a marked up revision of <xsl:value-of select="$theTitle" /></label>
								</div>
								<div class="p_two s_1">
									<button class="userFunctionalElement" id="markupSubmit" type="submit" name="revise" value="markup">Markup</button>
								</div>
							</form>
						</div>
					</xsl:if>
				</div>
			</div>
			
			<xsl:variable name="legislationURIcomponent" as="xs:string"
				select="concat($uriPrefix, '/', ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Year/@Value, '/', ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:Number/@Value)" />
			<div class="colSection p_one s_12">
				<div class="participationTasks">
					<h3>Participation Tasks</h3>
					<ul class="plainList">
						<xsl:if test="/leg:Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata)/ukm:UnappliedEffects">
							<li>
								<a href="/changes/unapplied/affected/{$legislationURIcomponent}">
									<strong>Unapplied effects on <xsl:value-of select="$theTitle"/></strong>
								</a>
								<span class="pageLinkIcon"/>
							</li>
							<li>
								<a href="/changes/unapplied/affected/{$legislationURIcomponent}/data.xls">
									<strong>Unapplied effects on <xsl:value-of select="$theTitle"/> as a spreadsheet (for update)</strong>
								</a>
								<span class="pageLinkIcon"/>
							</li>
						</xsl:if>
						<li>
							<a href="/changes/affected/{$legislationURIcomponent}/data.xls?extended=true">
								<strong>All effects made on <xsl:value-of select="$theTitle"/> as an extended spreadsheet (for update)</strong>
							</a>
							<span class="pageLinkIcon"/>
						</li>
						<li>
							<a href="/changes/affecting/{$legislationURIcomponent}/data.xls?extended=true&amp;sort=affecting-year-number">
								<strong>Effects made by <xsl:value-of select="$theTitle" /> as a spreadsheet (for research)</strong>
							</a>
							<span class="pageLinkIcon"/>
						</li>
						<li>
							<a href="/admin/toes-research">
								<strong>Upload research for <xsl:value-of select="$theTitle" /></strong>
							</a>
							<span class="pageLinkIcon"/>
						</li>
						<li>
							<a href="/task/research/extent/{$legislationURIcomponent}">
								<strong>Research extents for <xsl:value-of select="$theTitle"/></strong>
							</a>
							<span class="pageLinkIcon"/>
						</li>
					</ul>
				</div>
			</div>
			
			<div class="colSection p_one s_12">
				<div class="proposedVersions">
					<h3>
						<xsl:text>Proposed Versions </xsl:text>
						<a class="helpItem helpItemToMidRight" href="#proposedVersionsHelp">
							<img alt="Help about Proposed Versions" src="/images/chrome/helpIcon.gif"/>
						</a>
					</h3>
					<ul class="plainList">
						<li>
							<a href="{leg:FormatURL($wholeActURI)}/proposed">
								<strong>Proposed versions of <xsl:value-of select="$theTitle"/></strong>
							</a>
							<span class="pageLinkIcon"/>
						</li>
					</ul>
					<form action="{leg:FormatURL($wholeActURI)}/proposed" method="post">
						<input name="type" type="hidden" value="{$paramsDoc/parameters/type}" />
						<input name="year" type="hidden" value="{$paramsDoc/parameters/year}" />
						<input name="number" type="hidden" value="{$paramsDoc/parameters/number}" />
						<div class="p_one s_6">
							<div class="p_one s_1">
								<label for="proposedTitle">
									<xsl:text>Title:</xsl:text>
								</label>
							</div>
							<div class="p_two s_5">
								<input type="text" id="proposedTitle" name="title" value="Proposed Change" />
							</div>
						</div>			
						<div class="p_two s_5">
							<div class="p_one s_2">
								<label for="proposedURIcomponent">
									<xsl:text>URL Component:</xsl:text>
								</label>
							</div>
							<div class="p_two s_3">
								<input type="text" id="proposedURIcomponent" name="slug" value="proposed-change" />
							</div>
						</div>
						<div class="p_three s_1">
							<button class="userFunctionalElement" id="createProposalSubmit" type="submit">Create</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	 </xsl:template>
	
	<!-- ========== Standard code for breadcrumb ========= -->
	<xsl:template name="TSOOutputBreadcrumbItems">
		  <!--/#breadcrumbControl --> 
			<div id="breadCrumb">
				<h3 class="accessibleText">You are here:</h3>		
				<ul>
					<xsl:apply-templates select="/leg:Legislation" mode="TSOBreadcrumbItem"/>
					<li class="activetext">Participation</li>
				</ul>
		</div>
	</xsl:template>
	
	<!-- ========== Standard code for help tips ========= -->	
	<xsl:template name="TSOOutputHelpTips">
		<xsl:call-template name="TSOOutputENsHelpTips"/>
		
		<div class="help" id="proposedVersionsHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3>Proposed Versions</h3>
				<p>Proposed versions are versions of items of legislation that indicate how that legislation would look were some proposed changes to that legislation to be made on it. A typical case is a version of an Act following the enactment of a Bill that affects it.</p>
				<p>You can create a new proposed version of legislation by completing the form. You need to give:</p>
				<ul>
					<li>Title: the title of the proposal, often the name of the Bill that is giving rise to the new version</li>
					<li>URL component: a URL component that will be used to address the proposal, which should contain only letters, numbers and hyphens</li>
				</ul>
				<p>After submitting the form, a new revision of the legislation will be made based on the most up to date version available, which can then be edited. When it is ready, this version can be submitted for publication on the site.</p>
			</div>
		</div>		

	</xsl:template>	
	
</xsl:stylesheet>
