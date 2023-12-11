<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:import href="../legislation/html/quicksearch.xsl"/>

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" exclude-result-prefixes="#all"/>
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>

    <xsl:template match="ukm:EffectsBatch">
        <html>
            <head>
                <title>Legislation.gov.uk</title>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                <style type="text/css">   
                    .amendToes th {background-color: #e0e0e0; height: 3em; text-align: left; padding: 5px}
                    .amendToes tr:nth-child(odd) {background-color:#f0f0f0;}
                    .amendToes tr:nth-child(even) {background-color:#fff;}
                    .amendToes td {padding: 5px}
                </style>
            </head>
            <body id="doc">

				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch" />		
					<div class="title">
						<h1 id="pageTitle">
							<xsl:text>Data Enrichment Demonstration - TOES</xsl:text>
						</h1>
					</div>
					<div id="content">
						<p>
							<b>Source: </b>
							<xsl:variable name="demoUri" select="$paramsDoc/request/parameters/parameter[name ='demo']/value" as="xs:string?"/>
							<xsl:value-of select="$demoUri"/>
						</p>
						<table class="amendToes">
							<thead>
								<tr>
									<th colspan="3">Changes that Affect</th>
									<th colspan="2">Made By</th>
								</tr>
								<tr>
									<th>Changed Legislation</th>
									<th>Changed Provision</th>
									<th>Type of Effect</th>
									<th>Affecting Legislation</th>
									<th>Affecting Provision</th>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="*"/>
							</tbody>
						</table>
					</div>
				</div>               

            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="ukm:Effects">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="ukm:Effect">
        <tr>
            <td>
                <a href="{@AffectedURI}"><xsl:value-of select="@AffectedURI"/></a>
            </td>
            <td>
                <xsl:for-each select="ukm:AffectedProvisions/(ukm:Section | ukm:SectionRange)">
                    <xsl:choose>
                        <xsl:when test="self::ukm:Section">
                            <xsl:if test="preceding-sibling::*[1][self::ukm:Section]">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <a href="{@URI}"><xsl:value-of select="."/></a>
                        </xsl:when>
                        <xsl:otherwise>-</xsl:otherwise>
                    </xsl:choose>                        
                </xsl:for-each>
            </td>
            <td>
                <xsl:value-of select="@Type"/>
            </td>
            <td>
                <a href="{@AffectingURI}"><xsl:value-of select="@AffectingURI"/></a>
            </td>
            <td>
                <a href="{ukm:AffectingProvisions/ukm:Section/@URI}"><xsl:value-of select="ukm:AffectingProvisions/ukm:Section"/></a>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
