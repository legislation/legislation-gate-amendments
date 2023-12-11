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
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:m="http://www.w3.org/1998/Math/MathML"
	exclude-result-prefixes="xs leg ukm err tso xhtml"
	version="2.0">

	<xsl:key name="change" match="leg:Addition | leg:Repeal | leg:Substitution" use="@ChangeId" />
	
	<!-- any supplied welsh language commentary will be in this doc -->
	<xsl:param name="commentary" as="element()?" select="if (doc-available('input:commentary')) then doc('input:commentary')/* else ()" />
	
	<xsl:variable name="isWelshLang" as="xs:boolean" select="/leg:Fragment/@xml:lang = 'cy'"/>
	
	<xsl:template match="ukm:IndexMetadata" priority="10" />
	<xsl:template match="leg:Contents" priority="10" />
	<xsl:template match="dc:modified" priority="10" />
	<xsl:template match="dct:valid" priority="10" />
	<xsl:template match="ukm:Correction" priority="10" />
	
	<!-- EU metadata -->
	<xsl:template match="ukm:EURLexIdentifiers" priority="10" />
	<xsl:template match="ukm:EURLexModified" priority="10" />
	<xsl:template match="ukm:EURLexExtracted" priority="10" />
	<xsl:template match="ukm:XMLGenerated" priority="10" />
	<xsl:template match="ukm:XMLImported" priority="10" />
	<xsl:template match="ukm:Treaty" priority="10" />
	<xsl:template match="ukm:CreatedBy" priority="10" />
	<xsl:template match="ukm:Subject" priority="10" />
	<xsl:template match="ukm:EURLexMetadata" priority="10" />


	<xsl:template match="@AltDates" />
	<xsl:template match="@ValidDates" />
	<xsl:template match="@ProspStartDate" />
	<xsl:template match="@RestrictOutput" />	
	<xsl:template match="leg:*/@FragmentId" />
	<xsl:template match="leg:*/@Version" />
	<xsl:template match="@xml:base" />
	<xsl:template match="@err:*" />
	<xsl:template match="@IdURI" />	
	
	
	<xsl:template match="err:*">
		<!-- we need to retain the err namespace elements but dont want them in the editable xml, therefore we will convert them to PI's on the way out, then reconvert on the way back in -->
		<xsl:processing-instruction name="err-{local-name()}">
		   <xsl:for-each select="@*">
				<xsl:value-of select="name()"/>
				<xsl:text>="</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>" </xsl:text>
		   </xsl:for-each>
		   <xsl:text>content="</xsl:text>
		   <xsl:value-of select='.'/>
		   <xsl:text>"</xsl:text>
		</xsl:processing-instruction>
	</xsl:template>

<xsl:template match="leg:Tasks" priority="15">
	<xsl:copy>
		<xsl:apply-templates select="node() | @*"/>		
	</xsl:copy>
</xsl:template>

<xsl:template match="leg:Tasks/leg:Effect" priority="15">
	<xsl:variable name="effectid" select="for $id in $effects//parameter[name = 'effect']/*:value return ($id)"/>
	<!--<xsl:message>
		value: <xsl:value-of select="@URI"/>
		matches: <xsl:sequence select="$effectid"/>
	</xsl:message>-->
	
	<xsl:choose>
		<xsl:when test="exists($effectid) and not(@URI = ($effectid))">
			
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates select="node() | @*"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>

<!-- accommodate links to welsh legislation -->	
<xsl:template match="leg:Tasks/leg:Effect/leg:Amendment/leg:Description//leg:CitationSubRef | 
leg:Tasks/leg:Effect/leg:AffectingProvisions//leg:CitationSubRef" priority="15">	
	<xsl:choose>
		<xsl:when test="$isWelshLang">
			<xsl:copy>
				<xsl:attribute name="URI">
					<xsl:value-of select="leg:make-welsh-uri(@URI)"/>
				</xsl:attribute>
				<xsl:apply-templates select="(@* except @URI)|node()"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates select="node() | @*"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<!-- substitute any welsh language commentaries -->	
<xsl:template match="leg:Tasks/leg:Effect/leg:Commentary" priority="15">	
	<xsl:variable name="thisId" select="@id"/>
	<xsl:choose>
		<xsl:when test="$isWelshLang and exists($commentary//leg:Commentary[@id = $thisId])">
			<xsl:sequence select="$commentary//leg:Commentary[@id = $thisId]"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates select="node() | @*"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:function name="leg:make-welsh-uri">
	<xsl:param name="uri"/>
	<xsl:variable name="type" select="tokenize(substring-after($uri, '/id/'), '/')[1]"/>
	<xsl:variable name="welshtypes" as="xs:string+" select="('anaw', 'mwa', 'wsi','asc')"/>
	<xsl:variable name="finalType" as="xs:string" select="if ($type = 'wsi') then 'made' else 'enacted'"/>
	<xsl:value-of select="
					if ($type = $welshtypes) then 
						concat(replace($uri, '/id/', '/'), '/', $finalType, '/', 'welsh') 
					else $uri"/>
</xsl:function>

</xsl:stylesheet>
