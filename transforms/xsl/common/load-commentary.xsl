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
	
	<xsl:import href="../augment.xsl" />

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

	<xsl:template match="leg:CitationSubRef" mode="ChangeCitationIDs">
		<xsl:param name="context" tunnel="yes" as="xs:string?" select="()" />
		<xsl:param name="strIdentifier" tunnel="yes" select="()" />
		<xsl:variable name="citation" as="element()?" select="key('citations', @CitationRef)[1]" />
		<xsl:variable name="is_I-note_CommencingProv" as="xs:boolean" 
			select="ancestor::leg:Commentary/@Type eq 'I' and not( following-sibling::node() )"/>
		<xsl:choose>
			<xsl:when test="exists(@URI)">
				<xsl:next-match/>
			</xsl:when>
			<xsl:when test="(exists($context) or 
				(exists(@SectionRef) and matches(@SectionRef, '^[a-z]{2,}')) or 
				(exists(@StartSectionRef) and matches(@StartSectionRef, '^[a-z]{2,}'))) 
				and 
				(exists($citation) or $is_I-note_CommencingProv)">
				<xsl:next-match/>
			</xsl:when>
			<xsl:when test="exists(self::*[not(preceding-sibling::leg:Citation) and empty($citation) and not(@CitationRef)])">
				<CitationSubRef>
					<xsl:apply-templates select="." mode="createId" />
					<xsl:choose>
						<xsl:when test="@SectionRef">
							<xsl:apply-templates select="." mode="createLink">
								<xsl:with-param name="section" select="string-join(($context, @SectionRef), '-')" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="@StartSectionRef">
							<xsl:apply-templates select="." mode="createLink">
								<xsl:with-param name="section" select="string-join(($context, @StartSectionRef), '-')" />
							</xsl:apply-templates>
							<xsl:apply-templates select="." mode="createLink">
								<xsl:with-param name="attribute" select="'UpTo'" />
								<xsl:with-param name="section" select="string-join(($context, @EndSectionRef), '-')" />
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates select="(@* except (@id))|node()" mode="ChangeCitationIDs" />
				</CitationSubRef>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="ChangeCitationIDs" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
