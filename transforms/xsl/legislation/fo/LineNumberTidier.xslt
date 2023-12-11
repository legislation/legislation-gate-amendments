<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xep="http://www.renderx.com/XEP/xep"
xmlns:tso="http://www.tso.co.uk/xslt"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
exclude-result-prefixes="tso xep xs">

<xsl:output method="xml" version="1.0" indent="no" />

<xsl:variable name="g_flAddTargets" select="true()" as="xs:boolean"/>

<!-- ========== Tidy document ========== -->

<xsl:template match="/">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="*">
	<xsl:choose>
		<xsl:when test="node()">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
			</xsl:copy>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xep:target">
	<xsl:choose>
		<xsl:when test="contains(@id, 'LineNumberID')">
			<xsl:variable name="intX" select="@x"/>
			<xsl:variable name="intY" select="@y"/>
			<xsl:variable name="strID" select="if (starts-with(@id, 'rx:last')) then substring-before(substring-after(@id, '@'), '-') else substring-before(@id, '-')"/>
			<xsl:if test="not(contains(preceding-sibling::*[2][self::xep:target]/@id, $strID) and contains(following-sibling::*[2][self::xep:target]/@id, $strID))">
				<xsl:copy-of select="."/>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
 
