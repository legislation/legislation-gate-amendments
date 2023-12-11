<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	version="2.0"
	exclude-result-prefixes="xs">


<xsl:import href="../common/utils.xsl"/>	


<xsl:template match="ukm:Effect | ukm:UndefinedEffect" mode="effect">
	<xsl:choose>
		<xsl:when test="@AffectedClass = ('primary','secondary')">
			<xsl:value-of select="concat('Undetermined ',@AffectedClass, ' legislation')" />
		</xsl:when>
		<xsl:when test="@AffectedClass = ('euretained', 'euretainedother','EuropeanUnionOther')">
			<xsl:value-of select="concat('EU Undetermined ',@AffectedClass, ' legislation')" />
		</xsl:when>
		<xsl:when test="@AffectedClass and @AffectedYear and @AffectedNumber">
			<xsl:value-of select="tso:toesReference(@AffectedClass,@AffectedYear,@AffectedNumber)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="substring-after(@AffectedURI, 'http://www.legislation.gov.uk/id/')" />
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:value-of select="translate(@AffectedProvisions,' ','&#160;')" />
	<xsl:text>&#160;</xsl:text>
	<xsl:value-of select="@Type" />
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@Type = 'inserted'">
			<xsl:apply-templates select="ukm:InsertionPoint"  mode="effect"/>
		</xsl:when>
		<xsl:when test="@Type = 'text amended'">
			<xsl:choose>
				<xsl:when test="ukm:InsertionPoint">
					<xsl:apply-templates select="ukm:Insertion" mode="effect" />
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="ukm:InsertionPoint"  mode="effect"/>
				</xsl:when>
				<xsl:when test="ukm:SubstitutedRange">
					<xsl:apply-templates select="ukm:Substitution"  mode="effect"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="ukm:SubstitutedRange"  mode="effect"/>
				</xsl:when>
				<xsl:when test="ukm:OmittedRange">
					<xsl:apply-templates select="ukm:OmittedRange"  mode="effect"/>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="ukm:Insertion | ukm:Substitution" mode="effect">
	<xsl:apply-templates mode="effect" />
</xsl:template>

<xsl:template match="ukm:InsertionPoint" mode="effect">
	<xsl:if test="ancestor::ukm:Effect/@Type != 'inserted'"><xsl:text>inserted </xsl:text></xsl:if>
	<xsl:apply-templates  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:SubstitutedRange" mode="effect">
	<xsl:text>substituted for </xsl:text>
	<xsl:apply-templates  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:OmittedRange" mode="effect">
	<xsl:text>omitted </xsl:text>
	<xsl:apply-templates  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:FromStart" mode="effect">
	<xsl:text>the text from the start of </xsl:text>
	<xsl:apply-templates select="*[1]"  mode="effect"/>
	<xsl:text> to </xsl:text>
	<xsl:apply-templates select="*[2]" mode="effect" />
</xsl:template>

<xsl:template match="ukm:ToEnd" mode="effect">
	<xsl:text>the text from </xsl:text>
	<xsl:apply-templates select="*[2]"  mode="effect"/>
	<xsl:text> to the end of </xsl:text>
	<xsl:apply-templates select="*[1]"  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:Range" mode="effect">
	<xsl:text>the text from </xsl:text>
	<xsl:apply-templates select="*[1]"  mode="effect"/>
	<xsl:text> to </xsl:text>
	<xsl:apply-templates select="*[2]"  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:After | ukm:Before" mode="effect">
	<xsl:value-of select="lower-case(local-name(.))" />
	<xsl:text> </xsl:text>
	<xsl:apply-templates  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:AppropriatePlaceIn" mode="effect">
	<xsl:text>at the appropriate place in </xsl:text>
	<xsl:text> </xsl:text>
	<xsl:apply-templates  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:Match" mode="effect">
	<xsl:apply-templates select="*[2]"  mode="effect"/>
	<xsl:if test="ancestor::ukm:Effect/@Type != 'text amended'">
		<xsl:text> in </xsl:text>
		<xsl:apply-templates select="*[1]" mode="effect" />
	</xsl:if>
</xsl:template>

<xsl:template match="ukm:Definition" mode="effect">
	<xsl:text>the definition of </xsl:text>
	<xsl:apply-templates select="*[2]"  mode="effect"/>
	<xsl:text> in </xsl:text>
	<xsl:apply-templates select="*[1]" mode="effect"/>
</xsl:template>

<xsl:template match="ukm:Heading" mode="effect">
	<xsl:text>the heading of </xsl:text>
	<xsl:apply-templates select="*"  mode="effect"/>
</xsl:template>

<xsl:template match="ukm:Text" mode="effect">
	<xsl:text>"</xsl:text>
	<xsl:value-of select="." />
	<xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="ukm:Section | ukm:SectionRange" mode="effect">
	<xsl:value-of select="." />
</xsl:template>

<xsl:template match="ukm:SectionGroup" mode="effect">
	<xsl:for-each select="*">
		<xsl:apply-templates select="."  mode="effect"/>
		<xsl:choose>
			<xsl:when test="position() = last() - 1"> and </xsl:when>
			<xsl:when test="position() != last()">, </xsl:when>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<xsl:template match="text()[normalize-space() = '']"  mode="effect"/>

<xsl:template match="*" mode="effect">
	<xsl:message>Unmatched: <xsl:value-of select="name()" /></xsl:message>
</xsl:template>

</xsl:stylesheet>