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
	exclude-result-prefixes="xs leg ukm err tso xhtml l dc dct"
	version="2.0">
	

	<!--<xsl:import href="load-commentary.xsl" />-->
	<xsl:import href="../augment-welsh.xsl" />
	
	<!-- we need the identifier to generate the URI links on th ecitations -->
	<xsl:param name="identifier" select="/leg:Commentaries/@identifier"/>


	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="leg:Commentary/leg:Para/leg:Text">
		<leg:Text>
			<xsl:choose>
				<xsl:when test="leg:Citation | leg:CitationSubRef">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise><xsl:message>Marking up</xsl:message>
					<xsl:apply-templates mode="Markup"/>
				</xsl:otherwise>
			</xsl:choose>
		</leg:Text>
	</xsl:template>

	<xsl:template match="*|@*" mode="Markup">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" mode="Markup"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="leg:Commentary//text()" mode="Markup">
		<xsl:variable name="markedUp">
			<xsl:apply-templates select="." mode="MarkupCitations" />
		</xsl:variable>
		<xsl:variable name="linked" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="$markedUp" mode="LinkCitations" />
			</xsl:document>
		</xsl:variable>
		
		<xsl:variable name="AnnotateCitations">
			<xsl:apply-templates select="$linked" mode="AnnotateCitations">
			<xsl:with-param name="strIdentifier" tunnel="yes" select="$identifier" />	
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:apply-templates select="$AnnotateCitations" mode="ChangeCitationIDs" >
			<xsl:with-param name="strIdentifier" tunnel="yes" select="$identifier" />
		</xsl:apply-templates>
	</xsl:template>

</xsl:stylesheet>
