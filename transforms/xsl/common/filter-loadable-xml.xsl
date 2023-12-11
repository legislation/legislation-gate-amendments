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
	exclude-result-prefixes="xs leg ukm err tso xhtml l"
	version="2.0">

<xsl:output indent="no" />

<xsl:template match="/">
	<xsl:apply-templates/>
</xsl:template>


<xsl:template match="* | comment() | processing-instruction()">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<xsl:template match="leg:P1 | leg:P2 | leg:P3 | leg:P4 | leg:P5 | leg:P6">
	<xsl:variable name="blsRepealed" as="xs:boolean"
		select="every $t in .//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber) and not(./ancestor::err:Warning)] satisfies $t/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false']" />
	<xsl:variable name="bAnyRepealedTagExists" as="xs:boolean"
		select="exists(.//text()[not(normalize-space(.) = '')]/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false'])" />
	
	<xsl:variable name="blsSubstituted" as="xs:boolean"
		select="if (exists(.//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber)])) then every $t in .//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber)] satisfies $t/ancestor::leg:Substitution else false()" />
	<xsl:variable name="blsSubstitutedExists" as="xs:boolean"
		select="every $t in .//text()[not(normalize-space(.) = '')] satisfies $t/ancestor::leg:Substitution" />	
		
	<xsl:choose>
		<xsl:when test="$blsRepealed and $bAnyRepealedTagExists">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<!--<xsl:copy-of select="leg:Pnumber">-->
				<xsl:element name="leg:Pnumber">
					<xsl:copy-of select="leg:Pnumber/@*"/>
					<xsl:element name="CommentaryRef">
						<xsl:variable name="legRepeal" select=".//text()[not(normalize-space(.) = '')]/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false'][1]"/>
						<xsl:attribute name="Ref" select="$legRepeal[1]/@CommentaryRef"/>
					</xsl:element>
					<xsl:apply-templates select="leg:Pnumber/node()"/>
				</xsl:element>
				<xsl:variable name="nodeName" select="concat(name(current()), 'para' )"/>
				<!-- we do not need to add the dots if the section title text node has already been populated by dots by a previous repeal -->
				<xsl:if test="not(matches(parent::leg:P1group/leg:Title,'. . . . . . . . . . . . . .'))">
					<!--  are there any nested repeals with retained text  -->
					<xsl:variable name="blsRepealedretaintext" as="xs:boolean"
						select="every $t in .//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber) and not(./ancestor::err:Warning)] satisfies $t/ancestor::leg:Repeal[@RetainText='true']" />
					<xsl:element name="{$nodeName}">
						<xsl:choose>
							<xsl:when test="$blsRepealedretaintext">
								<!-- this will catch any retained text repeal that has been added by a higher level - see 2001 SI 3210 reg. 4 2005-10-31 -->
								<!-- in such instances we will need the end bracket to go after the whole repeal, hence the inclusion of its repeal elements -->
								<xsl:variable name="repealelement" select="(.//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber) and not(./ancestor::err:Warning)]/ancestor::leg:Repeal[ @RetainText='true'])[1]"/>
								<xsl:element name="Text">
									<xsl:element name="Repeal">
									<xsl:copy-of select="$repealelement/@*"/>
										<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>		
									</xsl:element>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="Text">
									<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>		
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
				</xsl:element>
				</xsl:if>
			</xsl:copy>
		</xsl:when>
		<xsl:when test="$blsSubstituted and not($blsSubstitutedExists)">
			<xsl:variable name="nstsub" as="element(leg:Substitution)" select="(.//leg:Substitution)[1]"/>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:element name="leg:Pnumber">
					<xsl:copy-of select="leg:Pnumber/@*"/>
					<xsl:element name="Substitution">
						<xsl:copy-of select="$nstsub/@*"/>
						<!--<xsl:element name="CommentaryRef">
							<xsl:attribute name="Ref" select="$nstsub/@CommentaryRef"/>
						</xsl:element>-->
						<xsl:apply-templates select="leg:Pnumber/node()"/>
					</xsl:element>
				</xsl:element>
				<xsl:variable name="nodeName" select="concat(name(current()), 'para' )"/>
				<xsl:apply-templates select="*[not(self::leg:Pnumber)]"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:P1para">
	<xsl:variable name="blsRepealed" as="xs:boolean"
		select="every $t in .//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber) and not(./ancestor::err:Warning)] satisfies $t/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false']" />
	<xsl:variable name="bAnyRepealedTagExists" as="xs:boolean"
		select="exists(.//text()[not(normalize-space(.) = '')]/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false'])" />
	
	<xsl:choose>
		<xsl:when test="$blsRepealed and $bAnyRepealedTagExists">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
					<xsl:element name="Text">
						<xsl:element name="CommentaryRef">
							<xsl:variable name="legRepeal" select=".//text()[not(normalize-space(.) = '')]/ancestor::leg:Repeal[1]"/>
							<xsl:attribute name="Ref" select="$legRepeal[1]/@CommentaryRef"/>
						</xsl:element>
						<xsl:text>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</xsl:text>		
					</xsl:element>			
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- handle repealed table cells -->
<xsl:template match="xhtml:td">
	<xsl:variable name="blsRepealed" as="xs:boolean"
		select="every $t in .//text()[not(normalize-space(.) = '') and not(./ancestor::leg:Pnumber) and not(./ancestor::err:Warning)] satisfies $t/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false']" />
	<xsl:variable name="bAnyRepealedTagExists" as="xs:boolean"
		select="exists(.//text()[not(normalize-space(.) = '')]/ancestor::leg:Repeal[not(@RetainText) or @RetainText='false'])" />
	
	<xsl:choose>
		<xsl:when test="$blsRepealed and $bAnyRepealedTagExists">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:element name="CommentaryRef">
					<xsl:variable name="legRepeal" select=".//text()[not(normalize-space(.) = '')]/ancestor::leg:Repeal[1]"/>
					<xsl:attribute name="Ref" select="$legRepeal[1]/@CommentaryRef"/>
				</xsl:element>
				<xsl:text>. . .</xsl:text>		
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- handle inline repeals  -->
<xsl:key name="repealChanges" match="leg:Repeal" use="@ChangeId"/>
<xsl:key name="additionChanges" match="leg:Addition" use="@ChangeId"/>

<xsl:template match="leg:Repeal[not(@RetainText) or @RetainText='false']">
	<xsl:variable name="changes" select="key('repealChanges', @ChangeId)"/>
	<xsl:variable name="firstChange" as="element()?" select="$changes[1]" />
	<xsl:variable name="lastChange" as="element()?" select="$changes[last()]" />
	
	
	<xsl:choose>
		<xsl:when test="$firstChange is .">
			<xsl:variable name="thisRepeal" as="element()" select="." />
			<xsl:variable name="containedAdditions" as="element()*" select="$changes//leg:Addition" />
			<xsl:element name="CommentaryRef">
				<xsl:attribute name="Ref" select="@CommentaryRef"/>
			</xsl:element>
			<xsl:text>...</xsl:text>
		</xsl:when>
		<xsl:otherwise>
				
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:variable name="inlineElements" select="('Term', 'Abbreviation', 'Acronym','CommentaryRef')"/>

<xsl:template match="*[self::*/local-name() = $inlineElements][leg:Repeal[not(@RetainText) or @RetainText='false']]">
	<!-- work out if this is a new repeal -->
	<xsl:variable name="changes" select="key('repealChanges', leg:Repeal/@ChangeId)"/>
	<xsl:variable name="firstChange" as="element()?" select="$changes[1]" />
	<xsl:variable name="lastChange" as="element()?" select="$changes[last()]" />
	<!--  if the first child repeal element is the first markup of that repeal then we keep the inline elmeent  -->
	<xsl:choose>
		<xsl:when test="$firstChange is leg:Repeal[1]">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- PT64453352 filter out all unreferenced footnotes --> 
<xsl:template match="leg:FootnoteRef[not(@Ref = root()//leg:Footnote/@id)]"/>

</xsl:stylesheet>
