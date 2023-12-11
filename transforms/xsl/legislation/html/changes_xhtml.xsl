<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml" version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:db="http://docbook.org/ns/docbook"
	xmlns:sls="http://sls" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:atom="http://www.w3.org/2005/Atom" xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/">
	<xsl:import href="quicksearch.xsl"/>
	<xsl:import href="../../common/utils.xsl"/>
	<xsl:import href="unapplied_effects_xhtml.xsl"/>
	<xsl:import href="searchcommon_xhtml.xsl"/>



	<xsl:variable name="paramsDoc" as="document-node()">
		<xsl:choose>
			<xsl:when test="doc-available('input:request')">
				<xsl:sequence select="doc('input:request')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:document>
					<parameters xmlns="">
						<type>aep</type>
					</parameters>
				</xsl:document>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="requestInfoDoc" as="document-node()?">
		<xsl:if test="doc-available('input:request-info')">
			<xsl:sequence select="doc('input:request-info')"/>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="g_nstCodeLists" select="document('../../codelists.xml')/CodeLists/CodeList"/>

	<xsl:variable name="sort" as="xs:string?" select="$paramsDoc/parameters/sort"/>
	<xsl:variable name="order" as="xs:string?" select="$paramsDoc/parameters/order"/>

	<xsl:variable name="worksheetUri" as="xs:string" 
		select="substring-after(replace(/atom:feed/atom:link[@rel = 'self']/@href, '.feed', '.xls'), 'http://www.legislation.gov.uk')" />

	<xsl:template match="/">
		<html>
			<head>
				<!--
				<xsl:variable name="lastModified" as="xs:dateTime?" select="max((/atom:feed/atom:updated, /atom:feed/atom:entry/atom:updated)/xs:dateTime(.))" />
				<xsl:variable name="lastModified" as="xs:dateTime" select="if (exists($lastModified)) then $lastModified else current-dateTime()" />
 				<meta name="DC.Date.Modified" content="{adjust-date-to-timezone(xs:date($lastModified), ())}" />
				<meta http-equiv="Last-Modified" content="{tso:httpDateTime($lastModified)}" />
-->
				<script type="text/javascript" src="/scripts/formFunctions/common.js"></script>
				<script type="text/javascript" src="/scripts/changesLeg/search.js"></script>
				<link type="text/css" href="/styles/per/changeLeg.css" rel="stylesheet"/>
				
				<link rel="alternate" type="application/vnd.ms-excel" href="{$worksheetUri}" title="Excel Worksheet" />
				
				<xsl:apply-templates select="/atom:feed/atom:link" mode="HTMLmetadata"/>
			</head>

			<body lang="en" xml:lang="en" dir="ltr" id="doc" class="changeLeg">

				<div id="layout2">
					<!-- <span class="debug">
						[Title is: <xsl:value-of select="$paramsDoc/parameters/title"/>]
						[Year is: <xsl:value-of select="$paramsDoc/parameters/year"/>]
						[Number is: <xsl:value-of select="$paramsDoc/parameters/number"/>]
						[Type is: <xsl:value-of select="$paramsDoc/parameters/type"/>]
						[ID is: <xsl:value-of select="$id"/>]
						[Class is: <xsl:value-of select="$class"/>]
					</span> -->

					<!-- adding quick search  -->
					<xsl:call-template name="TSOOutputQuickSearch"/>

					<div>
						<div class="info">
						
							<h1 id="pageTitle">
								<xsl:text>Changes to Legislation</xsl:text>
								<xsl:if test="atom:feed"> <xsl:text> Results</xsl:text></xsl:if>
							</h1>

							<!-- adding search summary -->
							<xsl:apply-templates select="atom:feed" mode="summary"/>
						</div>
					</div>

					<div id="content">
						<xsl:if test="not(atom:feed)">
							<div class="s_12 p_one introWrapper">
								<h2>Changes made by legislation enacted from 2002 &#8211; present</h2>
								<p>The search form below provides access to lists detailing changes made by all legislation enacted from 2002 &#8211; present to the revised legislation held on legislation.gov.uk. Changes made by legislation enacted prior to 2002 have already been incorporated into the content and are not available as searchable lists. These lists provide details of changes including repeals, amendments and other effects (e.g. modifications and commencement information).</p>
								<p>The lists are updated with changes made by new legislation as soon as possible after the legislation is received by the legislation.gov.uk editorial team. There will usually, however, be some delay between the publication of new legislation to the website and the effects of it appearing in these tables. In most cases the delay will be less than two weeks.</p>
								<p>Note: Where changes and effects have yet to be applied to the legislation you are viewing on this site by the legislation.gov.uk editorial team then any &#8216;Changes to Legislation&#8217; are also displayed alongside the content of the legislation at provision level.</p>
							</div>
						</xsl:if>
						<div class="s_12 p_one tabWrapper createNewSearchOpt">
							<h2 class="accessibleText">Search</h2>
							<xsl:choose>
								<xsl:when test="atom:feed">
									<div id="existingSearch">
										<div id="newSearch" class="interface">
											<a id="modifySearch" href="#searchChanges"
												class="userFunctionalElement">
												<span class="btl"/><span class="btr"/>Modify existing
													search<span class="bbl"/><span class="bbr"/>
											</a>
										</div>
										<xsl:call-template name="TSOOutputChangesSearch"/>
									</div>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="TSOOutputChangesSearch"/>
								</xsl:otherwise>							
							</xsl:choose>
						</div>
						
						<xsl:if test="not(atom:feed)">
							<div class="s_12 p_one introWrapper">
								<h2>Changes to Local and Private and Personal Acts</h2>
								<p>The Chronological Tables list changes to Local, Private and Personal Acts dating from 1797 &#8211; 2008. They are updated each year and as the title suggests, the tables list Local, Private and Personal Acts in their chronological sequence along with details about repeals of, and changes (including amendments and substitutions) made to those Acts. They have been published in parts to make navigation easier.</p>
								<ul class="linkList">
									<li>
										<a href="http://www.legislation.gov.uk/changes/chron-tables/local">Chronological Table of Local Acts <span class="pageLinkIcon"></span></a>
									</li>
									<li>
										<a href="http://www.legislation.gov.uk/changes/chron-tables/private">Chronological Table of Private and Personal Acts <span class="pageLinkIcon"></span></a>
									</li>
								</ul>
							</div>
						</xsl:if>

						<!-- displaying the search results-->
						<xsl:apply-templates select="atom:feed" mode="results"/>
						<!--/#content-->
					</div>
					<!--/#layout1-->
					
					<xsl:call-template name="TSOOutputTooltips"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<!-- ========== Standard code for search summary========= -->
	<xsl:template match="atom:feed" mode="summary">
		<h2>
			<xsl:text>Your search for</xsl:text>
			<xsl:apply-templates select="$paramsDoc/parameters/applied" mode="summary"/>
			<xsl:text> that affect</xsl:text>
			<xsl:apply-templates select="$paramsDoc/parameters/affected-type" mode="summary"/>
			<xsl:apply-templates select="$paramsDoc/parameters/affected-year" mode="summary"/>			
			<xsl:apply-templates select="$paramsDoc/parameters/affected-number" mode="summary"/>			
			<xsl:text> made by</xsl:text>			
			<xsl:apply-templates select="$paramsDoc/parameters/affecting-type" mode="summary"/>
			<xsl:apply-templates select="$paramsDoc/parameters/affecting-year" mode="summary"/>			
			<xsl:apply-templates select="$paramsDoc/parameters/affecting-number" mode="summary"/>		
			<xsl:text> has returned </xsl:text>

			<xsl:variable name="pageSize" as="xs:integer" select="20"/>
			<xsl:choose>
				<xsl:when test="openSearch:totalResults > 200">more than 200</xsl:when>
				<xsl:when test="openSearch:totalResults">
					<xsl:value-of select="openSearch:totalResults" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="round-half-to-even((leg:page + leg:morePages) * $pageSize, -1) > 200">  more than 200 </xsl:when>
						<xsl:otherwise> about <xsl:value-of select="round-half-to-even((leg:page + leg:morePages) * $pageSize, -1)"/></xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>			
			<xsl:text> results:</xsl:text>
		</h2>
	</xsl:template>
	<xsl:template match="affected-type | affecting-type" mode="summary">
		<xsl:choose>
			<xsl:when test="string-length(.) > 0 and . != 'all' and . != '*' ">
				<xsl:variable name="type" select="."/>
				<xsl:text> </xsl:text>
				<strong><xsl:value-of select="$tso:legTypeMap[@abbrev=$type]/@plural"/></strong>
			</xsl:when>		
			<xsl:otherwise>
				<xsl:text> all legislation</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="affected-year | affecting-year" mode="summary">
		<xsl:choose>
			<xsl:when test="contains(., '-')">
				<xsl:text> between </xsl:text>
				<strong><xsl:value-of select="substring-before(.,'-')"/>
				<xsl:text> and </xsl:text>
				<xsl:value-of select="substring-after(.,'-')"/></strong>
			</xsl:when>
			<xsl:when test=". = '*' "/>
			<xsl:when test="string-length(.) > 0">
				<xsl:text> in </xsl:text>
				<strong><xsl:value-of select="."/></strong>
			</xsl:when>
		</xsl:choose>
	</xsl:template>	
	<xsl:template match="affected-number | affecting-number" mode="summary">
		<xsl:if test="string-length(.) > 0">
			<xsl:text> numbered </xsl:text>
			<strong><xsl:value-of select="."/></strong>
		</xsl:if>
	</xsl:template>	
	<xsl:template match="applied" mode="summary">
		<xsl:choose>
			<xsl:when test=". = 'applied' ">
				<strong>
					<xsl:text> applied</xsl:text>
				</strong>
			</xsl:when>	
			<xsl:when test=". = 'unapplied' ">
				<strong>
					<xsl:text> unapplied</xsl:text>
				</strong>
			</xsl:when>	
		</xsl:choose>	
		<xsl:text> changes</xsl:text>
	</xsl:template>


	<!-- ========== Standard code for search form========= -->
	<xsl:template name="TSOOutputChangesSearch">
		<form action="/changes" id="searchChanges" class="s_12 p_one">
			<xsl:if test="/errorsearching">
				<div id="errorBar" class="error errorMessage">Please check the form fields which are highlighted in red</div>		
			</xsl:if>
			<fieldset id="affect" class="s_5 p_one">
				<div>
					<a class="helpItem helpItemToTop" href="#changesThatAffectHelp">
						<img alt="Changes that affect help" src="/images/chrome/helpIcon.gif" />
					</a>
					<legend>Changes that affect:</legend>						
				</div>
				<div class="title">
					<label for="affected-title">Title:</label>
					<input id="affected-title" name="affected-title" type="text" value="{$paramsDoc/parameters/affected-title}"/>
				</div>
				<div class="typeChoice">
					
					<xsl:variable name="invalidAffectedType" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-type[not(. = ('', 'all',$g_nstCodeLists[@name = 'DocumentMainType']/Code[@status='revised']/@uri) )])"/>
						
					<label for="affected-type">
						<xsl:if test="$invalidAffectedType">
							<xsl:attribute name="class">error</xsl:attribute>						
						</xsl:if>
						<xsl:text>Legislation type:</xsl:text>
					</label>
					<select id="affected-type" name="affected-type">
						<xsl:if test="$invalidAffectedType">
							<xsl:attribute name="class">error</xsl:attribute>						
						</xsl:if>					
						<option value="">Any</option>
						<xsl:for-each
							select="$g_nstCodeLists[@name = 'DocumentMainType']/Code[@status='revised']">
							<option value="{@uri}">
								<xsl:if test="$paramsDoc/parameters/affected-type = @uri">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="tso:GetTitleFromType(@schema,'')"/>
							</option>
						</xsl:for-each>
					</select>
					<xsl:if test="$invalidAffectedType">
						<span class="error errorMessage">Not a valid revised legislation type</span>									
					</xsl:if>					
				</div>



				<div class="yearChoice">
				
					<xsl:variable name="invalidAffectedYear" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-year[. castable as xs:integer
									and xs:integer(.) &gt; year-from-date(current-date())])"/>
													
					<input type="radio" name="affected-year-choice" id="affected-year-specific"
						value="specific" class="yearChoice radio" checked="checked">
						<xsl:if test="$paramsDoc/parameters/affected-year-choice = 'specific'
							or $paramsDoc/parameters/affected-year[not(contains(., '-'))]">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affected-year-specific">Specific year and number</label>
					<div class="yearChoiceFields" id="affectsSingleYear">
						<div class="from">
							<label for="affected-year">
								<xsl:if test="$invalidAffectedYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>Year:</xsl:text>
							</label>
							
							<input id="affected-year" name="affected-year" type="text"
								value="{if ($paramsDoc/parameters/affected-year[contains(.,'-') or . = '*']) then '' else $paramsDoc/parameters/affected-year}">
								<xsl:if test="$invalidAffectedYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>								
							</input>
							
							<xsl:if test="$invalidAffectedYear">
								<span class="error errorMessage">Year must be before or equal to <xsl:value-of select="year-from-date(current-date())"/></span>									
							</xsl:if>	
							
						</div>
						<div class="number">
							<label for="affected-number">Number:</label>
							<input id="affected-number" name="affected-number" type="text"
								value="{$paramsDoc/parameters/affected-number}"/>
						</div>
					</div>
				</div>
				<div class="yearChoice">
				
					<xsl:variable name="invalidAffectedYearStart" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-year[
										contains(., '-') and substring-before(., '-') castable as xs:integer  
										and 
										(
										xs:integer(substring-before(., '-')) &gt; year-from-date(current-date())
											 or 
											 (
												 substring-after(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>
	
					<xsl:variable name="invalidAffectedYearEnd" as="xs:boolean"
						select="exists($paramsDoc/parameters/affected-year[
										contains(., '-') and substring-after(., '-') castable as xs:integer  
										and 
										(
										xs:integer(substring-after(., '-')) &gt; year-from-date(current-date())
											 or 
											 (
												 substring-before(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>									
										
					<input type="radio" name="affected-year-choice" id="affected-year-choice-range"
						value="range" class="yearChoice radio">
						<xsl:if test="$paramsDoc/parameters/affected-year-choice = 'range'
							or $paramsDoc/parameters/affected-year[contains(., '-')]
						 ">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affected-year-choice-range">Range of years</label>
					<div class="yearChoiceFields" id="affectedRangeYears">
						<div class="from">
							<label for="affected-start-year">
								<xsl:if test="$invalidAffectedYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>From:</xsl:text>
							</label>
							<input id="affected-start-year" name="affected-start-year" type="text"
								value="{
								if ($paramsDoc/parameters/affected-start-year[. != '']) then  $paramsDoc/parameters/affected-start-year
								else if ($paramsDoc/parameters/affected-year[contains(.,'-')]) then substring-before($paramsDoc/parameters/affected-year, '-')
								else ''}">
								<xsl:if test="$invalidAffectedYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>										
							</input>
						</div>
						<div class="to">
							<label for="affected-end-year">
								<xsl:if test="$invalidAffectedYearEnd">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>To:</xsl:text>							
							</label>
							<input id="affected-end-year" name="affected-end-year" type="text"
								value="{
								if ($paramsDoc/parameters/affected-end-year[. != '']) then  $paramsDoc/parameters/affected-end-year
								else if ($paramsDoc/parameters/affected-year[contains(.,'-')]) then substring-after($paramsDoc/parameters/affected-year, '-')
								else ''}">
									<xsl:if test="$invalidAffectedYearEnd">
										<xsl:attribute name="class">error</xsl:attribute>
									</xsl:if>									
							</input>
						</div>

						<xsl:if test="$invalidAffectedYearStart or $invalidAffectedYearEnd">
							<span class="error errorMessage">Year range must be before or equal to <xsl:value-of select="year-from-date(current-date())"/> and the From year must be an earlier date than the To year</span>									
						</xsl:if>	
					</div>
				</div>
			</fieldset>
			<fieldset id="affecting" class="s_5 p_two">
				<div>
					<a class="helpItem helpItemToTop" href="#madeByHelp">
						<img alt="Made by help" src="/images/chrome/helpIcon.gif" />
					</a>	
					<legend>made by:</legend>										
				</div>
				<div class="title">
					<label for="affecting-title">Title:</label>
					<input id="affecting-title" name="affecting-title" type="text" value="{$paramsDoc/parameters/affecting-title}"/>
				</div>
				<div class="typeChoice">
					<xsl:variable name="invalidAffectingType" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-type[not(. = ('', 'all',tso:GetEffectingTypes()/@abbrev) )])"/>
										
					<label for="affecting-type">
						<xsl:if test="$invalidAffectingType">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:if>
						<xsl:text>Legislation type:</xsl:text>
					</label>
					<select id="affecting-type" name="affecting-type">
						<xsl:if test="$invalidAffectingType">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:if>
						<option value="">Any</option>
						<xsl:for-each select="tso:GetEffectingTypes()">
							<option value="{@abbrev}">
								<xsl:if test="$paramsDoc/parameters/affecting-type = @abbrev">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@plural"/>
							</option>
						</xsl:for-each>
					</select>
					<xsl:if test="$invalidAffectingType">
						<span class="error errorMessage">Not a valid legislation type</span>									
					</xsl:if>					
				</div>
				<div class="yearChoice">
					<xsl:variable name="invalidAffectingYear" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-year[. castable as xs:integer
									and (xs:integer(.) &gt; year-from-date(current-date()) or xs:integer(.) &lt; 1000)])"/>
				
					<input type="radio" name="affecting-year-choice"
						id="affecting-year-choice-specific" value="specific"
						class="yearChoice radio" checked="checked">
						<xsl:if test="$paramsDoc/parameters/affecting-year-choice = 'specific'
							or $paramsDoc/parameters/affecting-year[not(contains(., '-'))]">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affecting-year-choice-specific">Specific year and number</label>
					<div class="yearChoiceFields" id="affectingSingleYear">
						<div class="from">
							<label for="affecting-year">
								<xsl:if test="$invalidAffectingYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>										
								<xsl:text>Year:</xsl:text>
							</label>
							<select name="affecting-year" id="affecting-year">
								<xsl:if test="$invalidAffectingYear">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>										
								<option value="" selected="selected">Any</option>
								<xsl:for-each select="2002 to year-from-date(current-date())">
									<option value="{.}">
										<xsl:if
											test="$paramsDoc/parameters/affecting-year castable as xs:integer and . = xs:integer($paramsDoc/parameters/affecting-year)">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>
							
							<xsl:if test="$invalidAffectingYear">
								<span class="error errorMessage">Year must be between 2002 and <xsl:value-of select="year-from-date(current-date())"/></span>									
							</xsl:if>	
														
						</div>
						<div class="number">
							<label for="affecting-number">Number:</label>
							<input id="affecting-number" name="affecting-number" type="text"
								value="{$paramsDoc/parameters/affecting-number}"/>
						</div>
					</div>
				</div>
				<div class="yearChoice">
				
					<xsl:variable name="invalidAffectingYearStart" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-year[
										contains(., '-') and substring-before(., '-') castable as xs:integer  
										and 
										(
										 (xs:integer(substring-before(., '-')) &gt; year-from-date(current-date()) or xs:integer(substring-before(., '-')) &lt; 1000)
											 or 
											 (
												 substring-after(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>
	
					<xsl:variable name="invalidAffectingYearEnd" as="xs:boolean"
						select="exists($paramsDoc/parameters/affecting-year[
										contains(., '-') and substring-after(., '-') castable as xs:integer  
										and 
										(
										  (xs:integer(substring-after(., '-')) &gt; year-from-date(current-date()) or xs:integer(substring-after(., '-')) &lt; 1000)
											 or 
											 (
												 substring-before(., '-') castable as xs:integer  
												 and 	xs:integer(substring-before(., '-')) &gt; xs:integer(substring-after(., '-'))
											 )
										 )
										 ])"/>
										 									
										 
					<input type="radio" name="affecting-year-choice"
						id="affecting-year-choice-range" value="range" class="yearChoice radio">
						<xsl:if test="$paramsDoc/parameters/affecting-year-choice = 'range' 
											or $paramsDoc/parameters/affecting-year[contains(., '-')]">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<label for="affecting-year-choice-range">Range of years</label>
					<div class="yearChoiceFields" id="affectingRangeYears">
						<div class="from">
							<label for="affecting-start-year">
								<xsl:if test="$invalidAffectingYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>From:</xsl:text>
							</label>
							<select name="affecting-start-year" id="affecting-start-year">
								<xsl:if test="$invalidAffectingYearStart">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<option value="" selected="selected">YYYY</option>
								<xsl:for-each select="1000 to year-from-date(current-date())">
									<option value="{.}">
										<xsl:if
											test="($paramsDoc/parameters/affecting-start-year castable as xs:integer and . = xs:integer($paramsDoc/parameters/affecting-start-year))
													or ($paramsDoc/parameters/affecting-year[contains(., '-') and substring-before(.,'-') castable as xs:integer] and . = xs:integer(substring-before($paramsDoc/parameters/affecting-year,'-')))
											">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>
						</div>
						<div class="to">
							<label for="affecting-end-year">
								<xsl:if test="$invalidAffectingYearEnd">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								<xsl:text>To:</xsl:text>
							</label>
							<select name="affecting-end-year" id="affecting-end-year">
								<xsl:if test="$invalidAffectingYearEnd">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
							
								<option value="" selected="selected">YYYY</option>
								<xsl:for-each select="1000 to year-from-date(current-date())">
									<option value="{.}">
										<xsl:if
											test="($paramsDoc/parameters/affecting-end-year castable as xs:integer and . = xs:integer($paramsDoc/parameters/affecting-end-year))
													or ($paramsDoc/parameters/affecting-year[contains(., '-') and substring-after(.,'-') castable as xs:integer] and . = xs:integer(substring-after($paramsDoc/parameters/affecting-year,'-')))
											">									
												<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="."/>
									</option>
								</xsl:for-each>
							</select>
						</div>
						
						<xsl:if test="$invalidAffectingYearStart or $invalidAffectingYearEnd">
							<span class="error errorMessage">Year range must be between 2002 and <xsl:value-of select="year-from-date(current-date())"/> and the From year must be an earlier date than the To year</span>									
						</xsl:if>						
					</div>
				</div>
			</fieldset>
			<div id="searchInfo">
				<p/>
				<!-- hook availabale for the JavaScript -->
				<fieldset id="effectsOptions" class="s_6">
					<div>
						<a class="helpItem helpItemToMidRight" href="#resultsShowingHelp">
							<img alt="Results showing help" src="/images/chrome/helpIcon.gif" />
						</a>						
						<legend>Results showing</legend>
					</div>
					<div>
						<input type="radio" id="appliedAll" value="all" name="applied" class="radio"
							checked="checked">
							<xsl:if test="$paramsDoc/parameters/applied = 'all' ">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="appliedAll">All changes</label>
						
						<input type="radio" id="applied" value="applied" name="applied" class="radio">
							<xsl:if test="$paramsDoc/parameters/applied = 'applied' ">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="applied">Applied changes</label>
						
						<input type="radio" id="unapplied" value="unapplied" name="applied"
							class="radio">
							<xsl:if test="$paramsDoc/parameters/applied = 'unapplied' ">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</input>
						<label for="unapplied">Unapplied changes</label>
						<button type="submit" id="legChangesSearchSubmit" class="userFunctionalElement">
							<span class="btl"/>
							<span class="btr"/>Get Results<span class="bbl"/>
							<span class="bbr"/>
						</button>
					</div>
				</fieldset>
			</div>
		</form>
	</xsl:template>

	<!-- ========== Standard code for search results========= -->
	<xsl:template match="atom:feed" mode="results">

		<!-- Show the table only if there's results. -->
			<xsl:variable name="link" as="xs:string?" select="//atom:link[@rel = 'first']/@href"/>
			<div class="results s_12 p_one">
				<div id="topPager" class="interface">

					<xsl:apply-templates select="/" mode="pagesummary"/>				
					
					<!-- adding the paging details -->
					<xsl:apply-templates select="/" mode="links">
						<xsl:with-param name="maxPageSetSize" select="10"/>
					</xsl:apply-templates>
					
					<div class="subscribe">
						<xsl:apply-templates select="//atom:link[@rel = 'alternate']" mode="subscribe"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="exists(atom:entry)">
				<table>
					<thead>
						<tr class="headerRow1">
							<th colspan="4">Changes that affect</th>
							<th colspan="3" class="centralCol">Made by</th>
							<td colspan="2" />							
						</tr>
						<tr class="headerRow2">
							<th>
								<xsl:call-template name="TSOOutputColumnHeader">
									<xsl:with-param name="link" select="$link"/>
									<xsl:with-param name="fieldName" select="'affected-title'"/>
									<xsl:with-param name="fieldTitle" select="'Changed Legislation'" />
								</xsl:call-template>
							</th>
							<th>
								<xsl:call-template name="TSOOutputColumnHeader">
									<xsl:with-param name="link" select="$link"/>
									<xsl:with-param name="fieldName" select="'affected-year-number'"/>
									<xsl:with-param name="fieldTitle" select="'Year and Number'"/>
								</xsl:call-template>
							</th>
							<th>Changed Provision</th>
							<th>
								Type of effect
								<a class="helpItem helpItemToMidRight" href="#typeofEffectHelp">
									<img alt="Type of effect help" src="/images/chrome/helpIcon.gif" />
								</a>	
							
							</th>							
							<th class="centralCol">
								<xsl:call-template name="TSOOutputColumnHeader">
									<xsl:with-param name="link" select="$link"/>
									<xsl:with-param name="fieldName" select="'affecting-title'"/>
									<xsl:with-param name="fieldTitle"
										select="'Affecting Legislation Title'"/>
								</xsl:call-template>
							</th>
							<th class="centralCol">
								<xsl:call-template name="TSOOutputColumnHeader">
									<xsl:with-param name="link" select="$link"/>
									<xsl:with-param name="fieldName"
										select="'affecting-year-number'"/>
									<xsl:with-param name="fieldTitle" select="'Year and Number'"/>
								</xsl:call-template>
							</th>
							<th class="centralCol">Affecting Provision</th>
							<th class="applied">
							
								<xsl:call-template name="TSOOutputColumnHeader">
									<xsl:with-param name="link" select="$link"/>
									<xsl:with-param name="fieldName" select="'applied'"/>
									<xsl:with-param name="fieldTitle" select="'Applied'"/>
								</xsl:call-template>
									
								<a class="helpItem helpItemToMidLeft" href="#appliedHelp">
									<img alt="Amendment applied help" src="/images/chrome/helpIcon.gif" />
								</a>
							</th>
							<th>Note</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="atom:entry/ukm:Effect" />
					</tbody>
				</table>
				<div class="contentFooter">
					<div class="interface">					
						<!-- adding the paging details -->
						<xsl:apply-templates select="/" mode="links"/>
					</div>
				</div>
					</xsl:when>
					<xsl:otherwise>
						<div>
							<br/>
							<p>This may be because either:</p>
							<ul>
								<li>There are no changes listed in relation to the legislation you specified. </li>
								<li>Changes have not yet been recorded by the legislation.gov.uk editorial team for the legislation you specified</li>
							</ul>
							<p>Next steps:</p>
							<ul>
								<xsl:if test="exists($requestInfoDoc/request/headers/header[name='referer' and contains(value, '/resources')])">
									<li>
										 <a href="{$requestInfoDoc/request/headers/header[name='referer']/value}">Back to legislation</a>
									 </li>
								</xsl:if>
								<li><a href="/changes">New Search</a></li>
								<li>
									<a href="{atom:link[@rel = 'self']/@href}">
									Subscribe to feed in order to be alerted if/when changes are recorded in related to this legislation item
								</a> </li>
								<li><a href="/changes">Learn more about changes to legislation</a></li>
							</ul>
							
						</div>
					</xsl:otherwise>
				</xsl:choose>

				<p class="backToTop">
					<a href="#top">Back to top</a>
				</p>
			</div>
	</xsl:template>

	<xsl:template match="ukm:Effect">
		<xsl:variable name="odd" as="xs:boolean" select="position() mod 2 = 1" />
		<tr>
			<xsl:if test="$odd">
				<xsl:attribute name="class">oddRow</xsl:attribute>
			</xsl:if>

			<xsl:apply-templates select="." mode="resultsAffectedTitle" />
			<xsl:apply-templates select="." mode="resultsAffectedYearNumber" />
			<xsl:apply-templates select="." mode="resultsChangedProvision" />
			<xsl:apply-templates select="." mode="resultsEffect"/>			
			<xsl:apply-templates select="." mode="resultsAffectingTitle"/>
			<xsl:apply-templates select="." mode="resultsAffectingYearNumber"/>
			<xsl:apply-templates select="." mode="resultsAffectingProvision"/>
			<xsl:apply-templates select="." mode="resultsApplied"/>
			<xsl:apply-templates select="." mode="resultsNote"/>
		</tr>
	</xsl:template>

	<!-- Affected -->
	<!-- Title -->
	<xsl:template match="ukm:Effect" mode="resultsAffectedTitle">
		<td>
			<xsl:choose>
				<xsl:when test="not(ukm:AffectedTitle)">
					<span>not available</span>
				</xsl:when>
				<xsl:when test="ukm:AffectedTitle[1]">
					<strong>
						<xsl:value-of select="ukm:AffectedTitle[1]"/>
					</strong>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsAffectedYearNumber">
		<!-- Year and Number-->
		<td>
			<xsl:choose>
				<xsl:when test="contains(lower-case(@AffectedName), 'various ')">
					<xsl:value-of select="@AffectedName"/>
				</xsl:when>
				<xsl:when test="@AffectedClass = 'EuropeanUnionTreaty' and exists(@AffectedName)">
					<xsl:value-of select="@AffectedName"/>
					<!-- link to "EEA Agreement" will be disabled when this is put on live like all the other links to EU legislation -->
					<!-- <xsl:variable name="link" select="concat('/id/', tso:GetUriPrefixFromType(@AffectedClass, @AffectedYear), '/', lower-case(@AffectedName))"/>
					<xsl:sequence select="leg:makeLink(@AffectedClass, $link, @AffectedName)"/> -->
				</xsl:when>
				<xsl:when test="exists(@AffectedClass)">
					<xsl:variable name="effectedYearNumber">
						<xsl:value-of select="@AffectedYear"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="tso:ResolveNumberForLegislation(@AffectedClass, @AffectedYear, @AffectedNumber)"/>
					</xsl:variable>
					<!-- for now we will not link to EU legisaltin as we do not currently hold it -->
					<xsl:variable name="link" select="concat('/id/', tso:GetUriPrefixFromType(@AffectedClass, @AffectedYear), '/', @AffectedYear, '/', @AffectedNumber)"/>
					<xsl:sequence select="leg:makeLink(@AffectedClass, $link, $effectedYearNumber)"/>
				</xsl:when>
				<xsl:otherwise>
				
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsChangedProvision">
		<!-- Changed Provision-->
		<td>
			<xsl:choose>
				<!-- RH at TNA: we won't want the links to the affected provs showing on live Changes at the moment for EEA Agreement and Various Legislation-->
				<xsl:when test="contains(lower-case(@AffectedName), 'various ')">
					<xsl:value-of select="@AffectedProvisions"/>
				</xsl:when>
				<xsl:when test="@AffectedClass = 'EuropeanUnionTreaty' and exists(@AffectedName)">
					<!-- link to "EEA Agreement" will be disabled when this is put on live like all the other links to EU legislation -->
					<xsl:value-of select="@AffectedProvisions"/>
				</xsl:when>
				<xsl:when test="ukm:AffectedProvisions//ukm:Section">
					<xsl:apply-templates select="ukm:AffectedProvisions" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="link" select="concat('/', substring-after(@AffectedURI, 'www.legislation.gov.uk/'))"/>
					<xsl:sequence select="leg:makeLink(@AffectedClass, $link, @AffectedProvisions)"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<!-- Affecting -->

	<!-- Affecting Legislation Title -->
	<xsl:template match="ukm:Effect" mode="resultsAffectingTitle">
		<td class="centralCol">
			<xsl:choose>
				<xsl:when test="not(ukm:AffectingTitle)">
					<span>not available</span>
				</xsl:when>
				<xsl:otherwise>
					<strong>
						<xsl:value-of select="ukm:AffectingTitle[1]"/>
					</strong>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<!-- Affecting Year and Number-->
	<xsl:template match="ukm:Effect" mode="resultsAffectingYearNumber">
		<td class="centralCol">
			<xsl:choose>
				<xsl:when test="exists(@AffectingClass)">
					<xsl:variable name="link" select="concat('/id/', tso:GetUriPrefixFromType(@AffectingClass, @AffectingYear), '/', @AffectingYear, '/', @AffectingNumber)"/>
					<xsl:variable name="value">
						<xsl:value-of select="@AffectingYear"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="tso:ResolveNumberForLegislation(@AffectingClass, @AffectingYear, @AffectingNumber)" />
					</xsl:variable>
					<xsl:sequence select="leg:makeLink(@AffectingClass, $link, $value)"/>
				</xsl:when>
				<xsl:otherwise>
				
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<!-- Affecting Provision-->
	<xsl:template match="ukm:Effect" mode="resultsAffectingProvision">
		<td class="centralCol">
			<xsl:choose>
				<xsl:when test="ukm:AffectingProvisions//ukm:Section">
					<xsl:apply-templates select="ukm:AffectingProvisions" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="link" select="concat('/', substring-after(@AffectingURI, 'www.legislation.gov.uk/'))"/>
					<xsl:sequence select="leg:makeLink(@AffectingClass, $link, @AffectingProvisions)"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsEffect">
		<!-- Type of Effect-->
		<td>
			<xsl:value-of select="@Type"/>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsApplied">
		<!-- Applied Yes-->
		<td>
			<xsl:if test="@Applied eq 'true'">
				<img src="/images/chrome/tickIcon.gif" alt="Yes"/>
			</xsl:if>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Effect" mode="resultsNote">
		<!-- Note-->
		<td>
			<xsl:if test="not(empty(@Notes))">
				<a class="helpItem hover" href="#note{generate-id(.)}">
					<img alt="Note" src="/images/chrome/noteIcon.gif"/>
				</a>
				<div id="note{generate-id(.)}" class="help">
					<span class="icon"/>
					<div class="content">
						<a href="#" class="close">
							<img alt="Close" src="/images/chrome/closeIcon.gif"/>
						</a>
						<xsl:choose>
							<xsl:when test="exists(ukm:Commenced)">
								<xsl:apply-templates select="ukm:Commenced" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@Notes"/>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
		</td>
	</xsl:template>

	<xsl:template match="ukm:Section">
		<xsl:choose>
			<xsl:when test="@Missing = 'true'">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a href="/{substring-after(@URI, 'www.legislation.gov.uk/')}">
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ukm:Citation">
		<xsl:choose>
			<xsl:when test="exists(@URI)">
				<a href="/{substring-after(@URI, 'www.legislation.gov.uk/')}">
					<xsl:apply-templates />
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ukm:AffectedProvisions//text() | ukm:AffectingProvisions//text() | ukm:Commenced//text()">
		<xsl:value-of select="." />
	</xsl:template>
	
	<!-- for now we will not link to EU legisaltin as we do not currently hold it -->
	<xsl:function name="leg:makeLink">		
		<xsl:param name="class" as="xs:string?"/>
		<xsl:param name="link" as="xs:string?"/>
		<xsl:param name="value" as="xs:string?"/>
		<xsl:choose>
			<xsl:when test="$class = $leg:euretained">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<a href="{$link}">
					<xsl:value-of select="$value"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- ========== Standard code for search results========= -->

	<xsl:template match="atom:feed" mode="pagesummary">
		<div class="resultsInfo">
			<xsl:choose>
				<xsl:when test="exists(atom:entry)">
			<xsl:value-of select="openSearch:startIndex"/>
			<xsl:text> to </xsl:text>
			<xsl:value-of
				select="openSearch:startIndex + min((openSearch:itemsPerPage, count(atom:entry))) - 1"/>
			<xsl:text> of </xsl:text>
			<xsl:choose>
				<xsl:when test="openSearch:totalResults">
					<xsl:value-of select="openSearch:totalResults"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>over </xsl:text>
					<xsl:value-of select="openSearch:itemsPerPage * leg:morePages"/>
				</xsl:otherwise>
			</xsl:choose>
					<xsl:text> results</xsl:text>						
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Your search returned 0 results </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</div>			
	</xsl:template>

	<xsl:function name="sls:year-from-uri" as="xs:string">
		<xsl:param name="uri" as="xs:string?"/>
		<xsl:value-of
			select="tokenize(substring-after($uri, 'http://www.legislation.gov.uk/id/'), '/')[2]"/>
	</xsl:function>

	<xsl:function name="sls:number-from-uri" as="xs:string">
		<xsl:param name="uri" as="xs:string?"/>
		<xsl:value-of
			select="tokenize(substring-after($uri, 'http://www.legislation.gov.uk/id/'), '/')[3]"/>
	</xsl:function>

	<xsl:function name="ukm:PreviousAffected" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../preceding-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectedLegislation(., $effect)]"
		/>
	</xsl:function>

	<xsl:function name="ukm:NextAffected" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../following-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectedLegislation(., $effect)]"
		/>
	</xsl:function>

	<!-- Returns true() when two ukm:Effect afe for the same affected
	     legislation. -->
	<xsl:function name="ukm:SameAffectedLegislation" as="xs:boolean">
		<xsl:param name="a" as="element(ukm:Effect)"/>
		<xsl:param name="b" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$a/@AffectedNumber = $b/@AffectedNumber and
								$a/@AffectedYear = $b/@AffectedYear and
								$a/@AffectedClass = $b/@AffectedClass"
		/>
	</xsl:function>

	<xsl:function name="ukm:PreviousAffecting" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../preceding-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectingLegislation(., $effect)]"
		/>
	</xsl:function>

	<xsl:function name="ukm:NextAffecting" as="element(ukm:Effect)?">
		<xsl:param name="effect" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="$effect/../following-sibling::atom:entry[1]/ukm:Effect[ukm:SameAffectingLegislation(., $effect)]"
		/>
	</xsl:function>

	<!-- Returns true() when two ukm:Effect afe for the same affecting
	     legislation. -->
	<xsl:function name="ukm:SameAffectingLegislation" as="xs:boolean">
		<xsl:param name="a" as="element(ukm:Effect)"/>
		<xsl:param name="b" as="element(ukm:Effect)"/>

		<xsl:sequence
			select="if (exists($a/@CommencingClass)) then
									($a/@CommencingNumber = $b/@CommencingNumber and
									 $a/@AffectingYear = $b/@AffectingYear and
									 $a/@CommencingClass = $b/@CommencingClass)
								else
									($a/@AffectingNumber = $b/@AffectingNumber and
									 $a/@AffectingYear = $b/@AffectingYear and
									 $a/@AffectingClass = $b/@AffectingClass)"
		/>
	</xsl:function>

	<!-- For the first ukm:Effect among possibly multiple ukm:Effect for
	     the same affecting legislation, returns the number of
	     ukm:Effect with the same value for $attribute as $effect.  For
	     following ukm:Effect with the same value for $attribute,
	     returns 0.  Non-zero indicates the number of rows to span, and
	     zero indicates to omit the table cell. -->
	<xsl:function name="ukm:ResultsAffectingSpan" as="xs:integer">
		<xsl:param name="effect" as="element(ukm:Effect)"/>
		<xsl:param name="attribute" as="xs:string"/>

		<xsl:variable name="previousEffect" select="ukm:PreviousAffecting($effect)"
			as="element(ukm:Effect)?"/>
		<xsl:variable name="nextEffect" select="ukm:NextAffecting($effect)"
			as="element(ukm:Effect)?"/>
		<xsl:choose>
			<xsl:when
				test="exists($previousEffect) and
								$previousEffect/@*[local-name() = $attribute] = $effect/@*[local-name() = $attribute]">
				<xsl:sequence select="0"/>
			</xsl:when>
			<xsl:when
				test="exists($nextEffect) and
								$nextEffect/@*[local-name() = $attribute] = $effect/@*[local-name() = $attribute]">
				<xsl:sequence select="ukm:ResultsAffectingSpanWorker($nextEffect, $attribute, 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Not meant to be called except by ukm:ResultsAffectingSpan(). -->
	<xsl:function name="ukm:ResultsAffectingSpanWorker" as="xs:integer">
		<xsl:param name="effect" as="element(ukm:Effect)"/>
		<xsl:param name="attribute" as="xs:string"/>
		<xsl:param name="subtotal" as="xs:integer"/>

		<xsl:variable name="nextEffect" select="ukm:NextAffecting($effect)"
			as="element(ukm:Effect)?"/>
		<xsl:choose>
			<xsl:when
				test="exists($nextEffect) and
					$nextEffect/@*[local-name() = $attribute] = $effect/@*[local-name() = $attribute]">
				<xsl:sequence
					select="ukm:ResultsAffectingSpanWorker($nextEffect, $attribute, $subtotal + 1)"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$subtotal + 1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="TSOOutputColumnHeader">
		<xsl:param name="link" as="xs:string"/>
		<xsl:param name="fieldName" as="xs:string"/>
		<xsl:param name="fieldTitle" as="xs:string"/>
		
		<!--<xsl:variable name="link" select="if (string-length($requestInfoDoc/request/query-string) >0) then concat($link,'?', $requestInfoDoc/request/query-string) else $link"/>-->
		<!--[<xsl:value-of select="$link"/>][<xsl:value-of select="$order"/>][<xsl:value-of select="$fieldName"/>][<xsl:value-of select="$sort"/>]-->
		
		<a title="Sort {$order} by {$fieldTitle}">
			<xsl:variable name="fieldLink"
				select="if (contains($link, 'sort=')) then replace($link, 'sort=[-a-z]+', concat('sort=', $fieldName) ) 
							else concat($link, if (contains($link, '?')) then '&amp;' else '?', 'sort=', $fieldName)"/>
			<xsl:choose>
				<xsl:when test="$sort = $fieldName">
					<xsl:choose>
						<xsl:when test="$order = ('ascending', '') "> 
							<xsl:attribute name="class">sortAsc active</xsl:attribute>
							<xsl:variable name="fieldLinkOrder"
								select="if (contains($fieldLink, 'order=')) then replace($fieldLink, 'order=[-a-z]+', 'order=descending') else concat($fieldLink,  '&amp;order=descending')"/>
							<xsl:attribute name="href" select="leg:GetLink($fieldLinkOrder)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">sortDesc active</xsl:attribute>
							<xsl:attribute name="href"
								select="leg:GetLink(replace($fieldLink, 'order=[-a-z]+', 'order=ascending'))"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">sortAsc</xsl:attribute>
					<xsl:attribute name="href"
						select="leg:GetLink(replace($fieldLink, 'order=[-a-z]+', 'order=ascending'))"/>
				</xsl:otherwise>
			</xsl:choose>
			<span class="accessibleText">Sort <xsl:value-of select="$order"/> by </span>
			<xsl:value-of select="$fieldTitle"/>
		</a>
	</xsl:template>
	
	<!-- adding the subscription links -->
	<xsl:template match="atom:link" mode="subscribe">
		<a href="{@href}" class="userFunctionalElement">
			<span class="background">
				<span class="btl"/>
				<span class="btr"/> <span class="accessibleText">Subscribe to </span><xsl:value-of select="@title" /> <span class="bbl"/>
				<span class="bbr"/>
			</span>
		</a>
		<!--<a href="#" class="helpItem helpToLeftMid">
			<img src="../../images/chrome/helpIcon.gif" alt="List subscription help"/>
		</a>-->
	</xsl:template>

	<xsl:template name="TSOOutputTooltips">
		
		<div class="help" id="changesThatAffectHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3>Changes that affect</h3>
				<p>Use this facility to search for changes that affect one or more items of legislation based on the criteria below. Alternatively you can leave this side of the form blank to find the changes and effects on any revised legislation.</p>
				<ul>
					<li>Legislation type: This optional field allows you to narrow down your search to changes affecting the legislation type you are interested in. The drop down list only includes those legislation types for which we hold revised versions for on legislation.gov.uk.</li>
					<li>Specific year/Range of years: These optional fields allow you to restrict your search to changes that affect legislation of a particular year or over a range of years.</li>
					<li>Number: If you are looking for changes that affect a specific item of legislation and you know its series number you can enter it in the number field.</li>
				</ul>
			</div>
		</div>		

		<div class="help" id="madeByHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3>Made by</h3>
				<p>Narrow down your search for changed legislation by entering details about the legislation that made the effects using this side of the form. Alternatively, leave his side of the form blank for effects and changes made by any legislation.</p>
				<ul>
					<li>Legislation type: This optional field allows you to narrow down your search to the legislation type you are interested in using the drop down box.</li>
					<li>Specific year/Range of years: These optional fields allow you to restrict your search to changes made by legislation in a particular year or over a range of years. Tip: to search for all changes made by all legislation in a particular year, enter the year in this side of the form, leaving the â€˜Changes that affectâ€™ side blank.</li>
					<li>Number: If you are looking for changes that are made by a specific item of legislation and you know its series number you can enter it in the number field.</li>
				</ul>
			</div>
		</div>	
		
		<div class="help" id="resultsShowingHelp">
			<span class="icon" />
			<div class="content">
				<a href="#" class="close">
					<img alt="Close" src="/images/chrome/closeIcon.gif" />
				</a>
				<h3>Use the tick boxes to see either: </h3>
				<ul>
					<li>All changes: All the changes and effects that match your search</li>
					<li>Applied changes: Those changes and effects that match your search criteria and have been applied to the text of legislation held on this website by the legislation.gov.uk editorial team.</li>
					<li>Unapplied changes: Those changes and effects that match your search criteria but have not yet been applied to the legislation held on this website by the legislation.gov.uk editorial team.</li>
				</ul>
			</div>
		</div>		
		
		<xsl:if test="exists(/atom:feed/atom:entry)">
			<div class="help" id="appliedHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3>Applied</h3>
					<p>A green tick indicates that the change has been applied to the text of the legislation on this site by the legislation.gov.uk editorial team.</p>
					<p>Where there is no green tick, the changes and effects have not yet been applied and they are also displayed alongside the content of the legislation at provision level in the â€˜Changes to Legislationâ€™ red box.</p>
				</div>
			</div>		
			
			<div class="help" id="typeofEffectHelp">
				<span class="icon" />
				<div class="content">
					<a href="#" class="close">
						<img alt="Close" src="/images/chrome/closeIcon.gif" />
					</a>
					<h3>Type of effect</h3>
					<p>
						There are many different types of effects. An â€œeffectâ€ can denote any way in which legislation impacts on or changes other legislation. There are three main types of effect which result in the text of the legislation changing: insertions (text is added), substitutions (text is replaced) and repeals (where existing text ceases to have effect and may also be removed from the legislation). In addition there are some effects that we record that do not result in a change to the text of the legislation e.g. â€œAppliedâ€ which is used where provisions of existing legislation are applied to new legislation or to some set of circumstances specified in the applying legislation.
					</p>
				</div>
			</div>	
		</xsl:if>		
			
	</xsl:template>


</xsl:stylesheet>
