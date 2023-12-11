<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs leg ukm err tso xhtml"
	version="2.0">

<xsl:output indent="no" />

<xsl:variable name="legId" select="/leg:Legislation/ukm:IndexMetadata/@URI" />

<xsl:template match="ukm:IndexMetadata" priority="10" />
<xsl:template match="ukm:EffectsBatch" priority="10" />
<xsl:template match="leg:Contents" priority="10" />
<xsl:template match="dc:modified" priority="10" />
<xsl:template match="dct:valid" priority="10" />

<xsl:template match="err:*">
	<xsl:element name="err:{local-name(.)}">
		<xsl:apply-templates select="@*|node()" mode="#current" />
	</xsl:element>
</xsl:template>

<xsl:template match="@AltDates" />
<xsl:template match="@ValidDates" />
<xsl:template match="@xml:base" />
<xsl:template match="@err:*" />

<xsl:template match="node()|@*">
	<xsl:copy>
		<xsl:apply-templates select="." mode="idURI" />
		<xsl:apply-templates select="@*|node()" mode="#current" />
	</xsl:copy>
</xsl:template>


<xsl:template match="leg:Fragment">
	<leg:Legislation>
		<xsl:apply-templates select="." mode="idURI" />
		<xsl:apply-templates select="@*|node()" mode="#current" />
	</leg:Legislation>
</xsl:template>


<xsl:template match="leg:Legislation" mode="idURI">
	<xsl:attribute name="IdURI" select="$legId" />
</xsl:template>

<xsl:template match="leg:Body" mode="idURI">
	<xsl:attribute name="IdURI" select="concat($legId, '/body')" />
</xsl:template>

<xsl:template match="leg:PrimaryPrelims | leg:SecondaryPrelims" mode="idURI">
	<xsl:attribute name="IdURI" select="concat($legId, '/introduction')" />
</xsl:template>

<xsl:template match="leg:SignedSection" mode="idURI">
	<xsl:attribute name="IdURI" select="concat($legId, '/signature')" />
</xsl:template>

<xsl:template match="leg:ExplanatoryNotes" mode="idURI">
	<xsl:attribute name="IdURI" select="concat($legId, '/note')" />
</xsl:template>

<xsl:template match="leg:EarlierOrders" mode="idURI">
	<xsl:attribute name="IdURI" select="concat($legId, '/earlier-orders')" />
</xsl:template>

<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Schedule | leg:Appendix | leg:P1 | leg:P2 | leg:P3 | leg:P4 | leg:P5 | leg:P6 | leg:P7 | leg:P" mode="idURI">
	<xsl:if test="@id">
		<xsl:attribute name="IdURI" select="concat($legId, '/', translate(@id, '-', '/'))" />
	</xsl:if>
</xsl:template>

<xsl:template match="leg:Pblock | leg:PsubBlock" mode="idURI">
	<xsl:if test="@id">
		<xsl:attribute name="IdURI" select="concat($legId, '/', translate(substring-before(@id, '-crossheading-'), '-', '/'), '/crossheading/', substring-after(@id, '-crossheading-'))" />
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="idURI" />


</xsl:stylesheet>
