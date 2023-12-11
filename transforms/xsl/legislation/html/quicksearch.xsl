<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<!-- UI EN Table of Content/Content page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 01/03/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:task="http://www.legislation.gov.uk/def/task/"
	xmlns:process="http://www.legislation.gov.uk/id/process/"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs tso rdf rdfs task process xhtml"
	xmlns="http://www.w3.org/1999/xhtml">
	
<xsl:import href="../../common/utils.xsl" />

<xsl:variable name="searchParams" as="element(parameters)?" select="if (doc-available('input:searchParams')) then doc('input:searchParams')/parameters else ()"/>

<xsl:template name="TSOOutputQuickSearch">
	<xsl:param name="showPrimary" as="xs:boolean" select="true()" />
	<xsl:param name="showSecondary" as="xs:boolean" select="true()" />	
	<xsl:param name="showDraft" as="xs:boolean" select="true()" />		
	<xsl:param name="showUnrevised" as="xs:boolean" select="true()" />
	<xsl:param name="enableTitle" as="xs:boolean" select="true()" />
	<xsl:param name="IsParticipation" as="xs:boolean" select="false()"/>	
	<xsl:param name="showImpacts" as="xs:boolean" select="false()" />

	<form id="contentSearch" method="get" action="{if ($IsParticipation) then '/task' else '/search'}" class="contentSearch contentForm borderBottom">
		<fieldset class="legislationForm">
			<h2>Search<xsl:if test="not($IsParticipation)"> Legislation</xsl:if></h2>
			<xsl:choose>
				<xsl:when test="$IsParticipation">
					<div class="process">
						<label for="process">Task:</label>
						<select name="process" id="process">
							<xsl:call-template name="process:optgroups">
								<xsl:with-param name="selected" as="xs:string?" select="$searchParams/process" />
							</xsl:call-template>
						</select>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="title">
						<label for="title">Title: <em>(or keywords in the title)</em></label>
						<input type="text" id="title" name="title">
							<xsl:if test="$enableTitle=false()">
								<xsl:attribute name="disabled"/>
							</xsl:if>
						</input>
					</div>
				</xsl:otherwise>
			</xsl:choose>
			<div class="year">
				<label for="year">Year<xsl:if test="($IsParticipation)">  / (Start Year-End Year)</xsl:if>:</label>
				<input type="text" id="year" name="year">
					<xsl:if test="$IsParticipation">
						<xsl:attribute name="value" select="$searchParams/year" />
					</xsl:if>
				</input>
			</div>
			<div class="number">
				<label for="number">Number:</label>
				<input type="text" id="number" name="number">
					<xsl:if test="$IsParticipation">
						<xsl:attribute name="value" select="$searchParams/number" />
					</xsl:if>
				</input>
			</div>
			<div class="type">
				<label for="type">Type:</label>
				<xsl:call-template name="tso:TypeSelect">
					<xsl:with-param name="selected" select="if ($IsParticipation and $searchParams/type) then $searchParams/type else ''" />
					<xsl:with-param name="showPrimary" select="$showPrimary" />
					<xsl:with-param name="showSecondary" select="$showSecondary" />	
					<xsl:with-param name="showDraft" select="$showDraft" />		
					<xsl:with-param name="showUnrevised" select="$showUnrevised" />
					<xsl:with-param name="showImpacts" as="xs:boolean" select="$showImpacts" />
				</xsl:call-template>
			</div>				
			<div class="submit-right">
				<!-- added code for different style of Quicksearch button for Participation and Legislation-->
				<xsl:choose>
					<xsl:when test="$IsParticipation">
						<button type="submit" id="contentSearchSubmit" class="button fButton bWidth80">
							<span>Search</span>
						</button>
					</xsl:when>
					<xsl:otherwise>
						<button type="submit" id="contentSearchSubmit" class="fButton bWidth80">
							<span class="btl"></span>
							<span class="btr"></span>Search<span class="bbl"></span>
							<span class="bbr"></span></button>	
					</xsl:otherwise>
				</xsl:choose>
			</div>
			
			<div class="advSearch">
				<a href="/search">Advanced Search</a>
			</div>
		</fieldset>
	</form>	
</xsl:template>

<xsl:template name="process:optgroups">
	<xsl:param name="selected" as="xs:string?" required="yes" />
</xsl:template>

</xsl:stylesheet>
