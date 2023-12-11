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

<xsl:variable name="strQuote" as="xs:string">"</xsl:variable>

<xsl:variable name="g_flAddTargets" select="false()" as="xs:boolean"/>

<!-- Get the page number containing the start marker for line counting -->
<xsl:variable name="intPageNumberContentStart" select="count(//xep:page[xep:target[@id = 'StartOfContent']]/preceding-sibling::xep:page)"/>

<xsl:variable name="ndsLineNumberTextElements2">
	<Pages>
		<xsl:for-each select="//xep:page">
			<xsl:variable name="intPage" select="count(preceding-sibling::xep:page)" as="xs:integer"/>
			<Page>
				<!-- We need to collate first because heights can be out of sequence -->
				<xsl:variable name="ndsTextElements">
					<xsl:for-each select="xep:text[not(@y &gt; 788000) and not(preceding-sibling::xep:target[@id = 'footnoteBlock' or @id = 'pageFooter'])]">
						<xsl:variable name="intFontSize" select="preceding-sibling::xep:font[1]/@size"/>
						<xsl:variable name="strPastStartMarker">
							<xsl:choose>
								<xsl:when test="$intPage &lt; $intPageNumberContentStart">No</xsl:when>
								<xsl:when test="$intPage &gt; $intPageNumberContentStart">Yes</xsl:when>
								<xsl:when test="$intPage = $intPageNumberContentStart and following-sibling::xep:target[@id = 'StartOfContent']">No</xsl:when>
								<xsl:otherwise>Yes</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>					
						<Line Y="{@y}" Id="{generate-id()}" FontSize="{$intFontSize}" NumberedContent="{$strPastStartMarker}"/>
					</xsl:for-each>
				</xsl:variable>
				<!-- Now sort it into height order -->
				<xsl:for-each select="$ndsTextElements/Line">
					<xsl:sort select="@Y" order="descending" data-type="number"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</Page>
		</xsl:for-each>
	</Pages>
</xsl:variable>

<xsl:variable name="ndsLineNumberTextElements">
	<xsl:apply-templates select="$ndsLineNumberTextElements2" mode="IndexTextElements"/>
</xsl:variable>

<xsl:key name="KeyLinesNumbers" match="Line" use="@Id"/>

<xsl:template match="/">

	<!--<xsl:result-document href="file:///c:/legislationdemo/proofs/linetest.xml">
		<Lines>
			<xsl:copy-of select="$ndsLineNumberTextElements"/>
		</Lines>
	</xsl:result-document>

	<xsl:result-document href="file:///c:/legislationdemo/proofs/linetest2.xml">
		<xsl:copy-of select="$ndsLineNumberTextElements2"/>
	</xsl:result-document>-->

	<xsl:variable name="ndsResultDocument">
		<xsl:apply-templates/>
	</xsl:variable>

	<xsl:result-document href="file:///c:/legislationdemo/proofs/SchemaProofLines.xep">
		<xsl:copy-of select="$ndsResultDocument"/>
	</xsl:result-document>

	<!-- For adding line numbers to XML -->
	<xsl:if test="$g_flAddTargets">
		<xsl:variable name="ndsSourceXML" select="document('file:///c:/legislationdemo/proofs/annotatedxml.xml')"/>
		<xsl:result-document href="file:///c:/legislationdemo/proofs/linenumber.xml">
			<xsl:apply-templates select="$ndsSourceXML" mode="UnAnnotate">
				<xsl:with-param name="ndsLineNumberInfo" select="$ndsResultDocument//processing-instruction()" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:result-document>	
	</xsl:if>

</xsl:template>


<!-- ========== Tidy document ========== -->

<xsl:template match="/" mode="TidyDoc">
	<xsl:apply-templates mode="TidyDoc"/>
</xsl:template>

<xsl:template match="*" mode="TidyDoc">
	<xsl:choose>
		<xsl:when test="node()">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates mode="TidyDoc"/>
			</xsl:copy>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
			</xsl:copy>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xep:target" mode="TidyDoc">
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


<!-- ========== Unannotate source XML and populate line numbers ========== -->

<xsl:template match="/" mode="UnAnnotate">
	<xsl:apply-templates mode="UnAnnotate"/>
</xsl:template>

<xsl:template match="*" mode="UnAnnotate">
	<xsl:choose>
		<xsl:when test="node()">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates mode="UnAnnotate"/>
			</xsl:copy>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
			</xsl:copy>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="text()" mode="UnAnnotate">
	<xsl:param name="ndsLineNumberInfo" tunnel="yes"/>
	<xsl:variable name="strId" select="preceding-sibling::processing-instruction()[1]"/>
	<xsl:variable name="strPiAttribute">
		<xsl:text>NodeId="</xsl:text>
		<xsl:value-of select="$strId"/>
		<xsl:text>"</xsl:text>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="$ndsLineNumberInfo[contains(., $strPiAttribute)]">
			<xsl:call-template name="tso:AddLineNumbers">
				<xsl:with-param name="strText" select="." as="xs:string"/>
				<xsl:with-param name="ndsLineInfo">
					<!-- This will generate a list of character positions in this text node starting new lines -->
					<xsl:for-each select="$ndsLineNumberInfo[contains(., $strPiAttribute)]">
						<Line>
							<xsl:attribute name="InitialPosition" select="substring-before(substring-after(., concat('CharacterPositions=', $strQuote)), ' ')"/>
							<xsl:attribute name="Number" select="substring-before(substring-after(., concat('LineNumber=', $strQuote)), $strQuote)"/>
							<xsl:attribute name="Page" select="substring-before(substring-after(., concat('PageNumber=', $strQuote)), $strQuote)"/>
						</Line>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="tso:AddLineNumbers">
	<xsl:param name="strText" as="xs:string"/>
	<xsl:param name="ndsLineInfo"/>
	
	<xsl:for-each select="1 to string-length($strText)">
		<xsl:variable name="intLinePosition" select="position()" as="xs:integer"/>
		<xsl:for-each select="$ndsLineInfo/Line[number(@InitialPosition) = $intLinePosition][1]">
			<xsl:processing-instruction name="LineDetails" select="'Page', @Page, 'Line', @Number"/>
		</xsl:for-each>
		<xsl:value-of select="substring($strText, position(), 1)"/>
	</xsl:for-each>
	
</xsl:template>


<!-- ========== Line Number Logic ========= -->

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

<xsl:template match="xep:target[contains(@id, 'LineNumberID')]"/>

<!-- StartOfContent indicates the point at which line counting should start in the document -->
<xsl:template match="xep:text[not(@y &gt; 788000) and not(preceding-sibling::xep:target[@id = 'footnoteBlock' or @id = 'pageFooter'])]">

	<xsl:variable name="ndsTextNode" select="."/>

	<!-- Extract the line number from index for this text -->			
	<xsl:variable name="strLineNumberTemp">
		<xsl:for-each select="$ndsLineNumberTextElements">
			<xsl:variable name="ndsLineElement" select="key('KeyLinesNumbers', generate-id($ndsTextNode))"/>
			<xsl:choose>
				<xsl:when test="not($ndsLineElement)">0</xsl:when>
				<xsl:when test="$g_flAddTargets">
					<xsl:if test="$ndsLineElement/preceding-sibling::Line[@Number = $ndsLineElement/@Number]">
						<xsl:text>Copy </xsl:text>
					</xsl:if>
					<xsl:value-of select="$ndsLineElement/@Number"/>
				</xsl:when>				
				<xsl:when test="not($ndsLineElement/preceding-sibling::Line[@Number = $ndsLineElement/@Number])">
					<xsl:value-of select="$ndsLineElement/@Number"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="intLineNumber" as="xs:integer">
		<xsl:choose>
			<xsl:when test="starts-with($strLineNumberTemp, 'Copy ')">
				<xsl:value-of select="substring-after($strLineNumberTemp, 'Copy ')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$strLineNumberTemp"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
			
	<!-- At this point we will generate a PI contain the linenumber information, the original text node id and all the character positions related to that line number -->
	<xsl:if test="$g_flAddTargets and $intLineNumber &gt; 0">
		<xsl:message terminate="no">Process line <xsl:value-of select="count(parent::*/preceding-sibling::xep:page)"/> ... <xsl:value-of select="$intLineNumber"/></xsl:message>
		<xsl:variable name="ndsNode" select="preceding-sibling::xep:target[contains(@id, 'LineNumber')][1]"/>
		<xsl:variable name="intX" select="$ndsNode/@x"/>
		<xsl:variable name="intY" select="$ndsNode/@y"/>
		<xsl:for-each-group select="$ndsNode[not(starts-with(@id, 'StartOfContent') or starts-with(@id, 'rx:last'))] |
			 $ndsNode/preceding-sibling::xep:target[@x = $intX and @y = $intY and not(starts-with(@id, 'StartOfContent'))]
				 [not(starts-with(@id, 'rx:last')) or
					 (position() = last() and 
						 starts-with(following-sibling::*[1][self::xep:target]/@id, substring-before(substring-after(@id, '@'), '-')))]"
						 group-by="if (starts-with(@id, 'rx:last')) then substring-before(substring-after(@id, '@'), '-') else substring-before(@id, '-')">
			<xsl:processing-instruction name="LineNumberList">
				<xsl:text>LineNumber="</xsl:text>
				<xsl:value-of select="$intLineNumber"/>
				<xsl:text>" PageNumber="</xsl:text>
				<xsl:value-of select="count(parent::*/preceding-sibling::xep:page) + 1"/>
				<xsl:text>" NodeId="</xsl:text>
				<xsl:value-of select="if (starts-with(@id, 'rx:last')) then substring-before(substring-after(@id, '@'), '-') else substring-before(@id, '-')"/>
				<xsl:text>" CharacterPositions="</xsl:text>
				<xsl:for-each select="current-group()">
					<xsl:value-of select="substring-after(@id, 'LineNumberID-')"/>
					<!-- This space is important -->
					<xsl:text> </xsl:text>
				</xsl:for-each>
				<xsl:text>"</xsl:text>
			</xsl:processing-instruction>
		</xsl:for-each-group>
	</xsl:if>

	<!-- Make sure we output text! -->
	<xsl:copy>
		<xsl:copy-of select="@*"/>
	</xsl:copy>			
	
	<!-- Output line number -->
	<xsl:if test="$intLineNumber mod 5 = 0 and $intLineNumber &gt; 0 and not(starts-with($strLineNumberTemp, 'Copy '))">
		<xep:rgb-color red="0.0" green="0.0" blue="0.0" />
		<xep:font family="Times" weight="400" style="italic" variant="normal" size="10000" />
		<xsl:choose>
			<xsl:when test="count(ancestor::xep:page/preceding-sibling::xep:page) mod 2 = 0">
				<xep:text value="{$intLineNumber}" x="50000" y="{@y}" width="100000"/>
			</xsl:when>
			<xsl:otherwise>
				<xep:text value="{$intLineNumber}" x="530000" y="{@y}" width="100000"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="preceding-sibling::xep:rgb-color or preceding-sibling::xep:gray-color">
				<xsl:copy-of select="preceding-sibling::*[self::xep:rgb-color or self::xep:gray-color][1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xep:rgb-color red="0.0" green="0.0" blue="0.0" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:copy-of select="preceding-sibling::xep:font[1]"/>
	</xsl:if>

</xsl:template>


<!-- ========== Generate index of items and their line numbers ========== -->

<xsl:template match="Pages" mode="IndexTextElements">
	<xsl:apply-templates mode="IndexTextElements"/>
</xsl:template>

<xsl:template match="Page" mode="IndexTextElements">
	<Page>
		<xsl:apply-templates select="Line[1]" mode="IndexTextElements"/>
	</Page>
</xsl:template>

<xsl:template match="Line" mode="IndexTextElements">
	<xsl:call-template name="tso:IndexLines">
		<xsl:with-param name="ndsTextElement" select="."/>
		<xsl:with-param name="intBaselineY" select="@Y"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="tso:IndexLines">
	<xsl:param name="ndsTextElement"/>
	<xsl:param name="intLineNumber" select="if (count($ndsTextElement/parent::Page/preceding-sibling::Page) &lt;= $intPageNumberContentStart) then 0 else 1" as="xs:integer"/>
	<!-- Holds the baseline of the last y value counted as a line - we need to be quite a bit below that to count another line -->
	<xsl:param name="intBaselineY" select="0" as="xs:integer"/>
	
	<xsl:variable name="intThisY" select="$ndsTextElement/@Y" as="xs:integer"/>
	<xsl:variable name="intFontSize" select="$ndsTextElement/@FontSize"/>
	<xsl:variable name="flAddLine" select="$ndsTextElement/preceding-sibling::*[@Y != $intThisY and @Y &gt;= $intBaselineY][1]/@Y &gt; $intThisY + $intFontSize" as="xs:boolean"/>
	
	<xsl:variable name="strLineAlreadyOccurred" as="xs:string">
		<xsl:choose>
			<xsl:when test="$g_flAddTargets">
				<xsl:choose>
					<xsl:when test="$ndsTextElement/preceding-sibling::Line[1][@Y = $intThisY]">
						<xsl:text>Yes</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>No</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NotApplicable</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<Line>
		<xsl:attribute name="Number">
			<xsl:choose>
				<xsl:when test="$flAddLine and $ndsTextElement/@NumberedContent = 'Yes' and $strLineAlreadyOccurred != 'Yes'">
					<xsl:value-of select="$intLineNumber + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$intLineNumber"/>
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:attribute>
		<xsl:attribute name="Id" select="$ndsTextElement/@Id"/>
	</Line>
	
	<xsl:choose>
		<xsl:when test="$g_flAddTargets">
			<xsl:variable name="ndsNextText" select="$ndsTextElement/following-sibling::*[1]"/>
			<xsl:choose>
				<xsl:when test="$flAddLine and $ndsNextText and $ndsTextElement/@NumberedContent = 'Yes' and $strLineAlreadyOccurred != 'Yes'">
					<xsl:call-template name="tso:IndexLines">
						<xsl:with-param name="ndsTextElement" select="$ndsNextText"/>
						<xsl:with-param name="intLineNumber" select="$intLineNumber + 1"/>
						<xsl:with-param name="intBaselineY" select="$intThisY"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$ndsNextText">
					<xsl:call-template name="tso:IndexLines">
						<xsl:with-param name="ndsTextElement" select="$ndsNextText"/>
						<xsl:with-param name="intLineNumber" select="$intLineNumber"/>
						<xsl:with-param name="intBaselineY" select="$intBaselineY"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="ndsNextText" select="$ndsTextElement/following-sibling::*[@Y != $intThisY][1]"/>
			<xsl:choose>
				<xsl:when test="$flAddLine and $ndsNextText and $ndsTextElement/@NumberedContent = 'Yes'">
					<xsl:call-template name="tso:IndexLines">
						<xsl:with-param name="ndsTextElement" select="$ndsNextText"/>
						<xsl:with-param name="intLineNumber" select="$intLineNumber + 1"/>
						<xsl:with-param name="intBaselineY" select="$intThisY"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$ndsNextText">
					<xsl:call-template name="tso:IndexLines">
						<xsl:with-param name="ndsTextElement" select="$ndsNextText"/>
						<xsl:with-param name="intLineNumber" select="$intLineNumber"/>
						<xsl:with-param name="intBaselineY" select="$intBaselineY"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

</xsl:stylesheet>
 
