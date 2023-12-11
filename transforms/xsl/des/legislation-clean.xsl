<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
xmlns:amend="http://amend.com"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:err="http://www.tso.co.uk/assets/namespace/error" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gate="http://www.gate.ac.uk" xmlns:dct="http://purl.org/dc/terms/" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:svg="http://www.w3.org/2000/svg" xmlns:atom="http://www.w3.org/2005/Atom" exclude-result-prefixes="leg ukm math msxsl dc dct ukm fo xsl svg xhtml tso xs err gate amend atom">

	<!--
		GATE needs to have space around empty elements otherwise it results in placing the elements incorrectly
	-->
      
    <xsl:output method="xml" version="1.0" omit-xml-declaration="yes"  indent="no"/>
	
	<xsl:preserve-space elements="*"/>

    <xsl:template match="*">        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ukm:* | leg:BlockAmendment | leg:Tabular | xhtml:table | xhtml:tr | xhtml:col | xhtml:td | xhtml:th | leg:FootnoteRef | leg:Footnote | leg:Appendix | leg:Schedule | leg:Part | leg:Chapter | leg:Pblock | leg:PsubBlock | leg:P1group | leg:P1para | leg:P2para | leg:P3para | leg:P4para | leg:P5para | leg:Pnumber | leg:Text | leg:UnorderedList | leg:ListItem | leg:Title | leg:Number">        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="xhtml:colgroup">        
        <xsl:copy>
           <xsl:copy-of select="@*"/>
           <xsl:text>&#10;</xsl:text>
		   <xsl:apply-templates/>
        </xsl:copy>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="leg:Strong[not(.//text())] | leg:Emphasis[not(.//text())]">        
        <xsl:copy>
           <xsl:copy-of select="@*"/>
           <xsl:apply-templates/>
        </xsl:copy>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>	
	
	
	
	<xsl:template match="leg:P1 | leg:P2 | leg:P3 | leg:P4 | leg:P5">
        <xsl:text>&#10;</xsl:text>        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <!-- GATE has a problem because these are no-width and therefore can't be picked up properly. So insert a temporary space -->
    <xsl:template match="leg:Character[@Name = 'NonBreakingSpace']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy>
		<DesTemporary name="DESremoveStart" xmlns="">
            <xsl:text> </xsl:text>
        </DesTemporary>
    </xsl:template>
    
</xsl:stylesheet>
