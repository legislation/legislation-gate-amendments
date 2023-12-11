<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:amend="http://amend.com" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:err="http://www.tso.co.uk/assets/namespace/error"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gate="http://www.gate.ac.uk"
    xmlns:dct="http://purl.org/dc/terms/" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:atom="http://www.w3.org/2005/Atom"
    exclude-result-prefixes="#all">
    

    <xsl:import href="../legislation/html/legislation_xhtml_consolidation.xslt"/>
    
     <xsl:output method="xml" version="1.0" omit-xml-declaration="yes" indent="no"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        exclude-result-prefixes="#all"/>
		
    <xsl:variable name="legUri" select="concat((//leg:Legislation)[1]/@IdURI, '/')"/>
    
    <xsl:variable name="amendsList" as="element()*">
        <xsl:apply-templates select="//Changes/*" mode="calcAmends"/>
    </xsl:variable>
    
    <xsl:variable name="g_ndsMetadata" select="//leg:Legislation/ukm:Metadata"/>
    <xsl:variable name="g_ndsMainDoc" select="//leg:Legislation"/>

    <xsl:template match="/">
        <xsl:message>URI: <xsl:value-of select="$legUri"/></xsl:message>
        <xsl:variable name="legDoc" as="element()*">
            <xsl:if test="not($g_ndsLegisConfigDoc//path[@type='images'])">
                <xsl:message terminate="yes">Configuration file is missing images path</xsl:message>
            </xsl:if>
            <xsl:if test="not($g_ndsLegisConfigDoc//path[@type='CSS'])">
                <xsl:message terminate="yes">Configuration file is missing CSS path</xsl:message>
            </xsl:if>
            <xsl:variable name="this" select="."/>
            <xsl:for-each select="$this//leg:Legislation[1]">
                <xsl:for-each select="$g_ndsTemplateDoc">
                    <xsl:apply-templates/>
                </xsl:for-each>
            </xsl:for-each>              
        </xsl:variable>

        <html>
            <head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <style type="text/css">
                /* Legislation stylesheets - load depending on content type */
                @import "http://www.legislation.gov.uk/styles/legislation.css";<xsl:choose>
                    <xsl:when test="$g_strDocumentType = 'primary'">
                        <xsl:text>@import "http://www.legislation.gov.uk/styles/primarylegislation.css";</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>@import "http://www.legislation.gov.uk/styles/secondarylegislation.css";</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                @import "http://www.legislation.gov.uk/styles/legislationOverwrites.css";
                html {
                    background-color: #ffffff;
                    color: black;
                }
                ul {
                    list-style-image: none
                }
                div.amendsOutput {
                    background-color: white;
                     width: 100%
                }
                div.amendsBlock {
                    color: black;
                    clear: both;
                     margin: 1em
                }
                div.amendsBlock div.amendsBlockInner {
                    position: relative;
                    left: -2px;
                    top: -2px;
                    padding: 5px;
                    color: black;
                    font-size: 0.85em;
                    border: solid 1px #ccc;
                    -moz-border-radius: 5px;
                    -webkit-border-radius: 5px;
                    -moz-box-shadow: 3px 3px 5px #bbb;
                    -webkit-box-shadow: 3px 3px 5px #bbb;
                    background: #C6E2FF;
                    background: -moz-linear-gradient(top, #fff, #C6E2FF);
                    background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#C6E2FF));
                }
                div.amendsBlock div.amendsBlockInner p.amendPara {
                    background: transparent;
                    padding: 0px;
                    margin: 0px;
                    color: black;
                    text-decoration: none;
                    margin: 0px;
                    text-align: left;
                     text-shadow: none
                }
                div.amendsBlock div.amendsBlockInner p.amendParaNested {
                    padding: 5px;
                    margin: 0px;
                    margin-bottom: 3px;
                    color: black;
                    text-decoration: none;
                    -moz-border-radius: 3px;
                    -webkit-border-radius: 3px;
                    background: #eee;
                    background: -moz-linear-gradient(top, #eee, #bbb);
                    background: -webkit-gradient(linear, left top, left bottom, from(#eee), to(#bbb));
                }
                div.amendsBlock div.amendsBlockInner p.amendError {
                    padding: 5px;
                    margin: 0px;
                    margin-bottom: 3px;
                    color: white;
                    text-decoration: none;
                    -moz-border-radius: 3px;
                    -webkit-border-radius: 3px;
                    background: red;
                }
                div.amendsBlock div.amendsComing {
                    background: #FFCCFF;
                    background: -moz-linear-gradient(top, #fff, #FFCCFF);
                    background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#FFCCFF));
                }
                div.amendsBlock div.amendsExtent {
                    background: #FFCC66;
                    background: -moz-linear-gradient(top, #fff, #FFCC66);
                    background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#FFCC66));
                }
                div.amendsBlock div.amendsNT {
                    background: #CCFF99;
                    background: -moz-linear-gradient(top, #fff, #CCFF99);
                    background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#CCFF99));
                }
                div.amendsBlock div.amendsRR {
                    background: #C6E2FF;
                    background: -moz-linear-gradient(top, #fff, #C6E2FF);
                    background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#C6E2FF));
                }
                div.amendsBlock div.amendsBlockInner p.amendPara a {
                    background:transparent
                }
                div.amendsBlock a {
                    text-decoration: none
                }
                div.amendsBlock div.amendsBlockInner div.amendBlockDiv {
                    border: dashed 1px #888;
                    margin-bottom: 5px;
                    opacity: 0.4;
                    -moz-border-radius: 5px;
                    -webkit-border-radius: 5px;
                }
                div.amendsBlock div.amendsBlockInner div.amendBlockDiv div.amendBlockDiv {
                    opacity: 1
                }
                span.gate-LegRef {
                    border: solid 1px red;
                    padding-left: 3px;
                    padding-right: 3px;
                    -moz-border-radius: 2px;
                    -webkit-border-radius: 2px;
                    -moz-box-shadow: 3px 3px 5px #bbb;
                    -webkit-box-shadow: 3px 3px 5px #bbb;
                }
                span.gate-Legislation {
                    border: solid 1px purple;
                    padding-left: 3px;
                    padding-right: 3px;
                    -moz-border-radius: 2px;
                    -webkit-border-radius: 2px;
                    -moz-box-shadow: 3px 3px 5px #bbb;
                    -webkit-box-shadow: 3px 3px 5px #bbb;
                }
                span.gate-Legislation a {
                    text-decoration: none
                }
                span.gate-Location {
                    border: solid 1px green
                }
                span.gate-Anaphor {
                    border: solid 1px pink
                }
                span.gate-Relation {
                    border: solid 1px purple
                }
                span.gate-Quote {
                    border: solid 1px orange
                }
                span.gate-Structure {
                    border: solid 1px brown
                }
                span.gate-ExtendTo {
                    border: solid 1px #cc0033
                }
                span.gate-ExtentCountries {
                    border: solid 1px #ff66ff
                }
                span.gate-CrossRef {
                    border: solid 1px brown
                }
                span.gate-Action {
                    border: solid 1px cyan
                }
                span.gate-NonTextualPhrase {
                    border: solid 1px yellow
                }
                span.gate-Date {
                    border: solid 1px teal
                }
                span.gate-Inline {
                    padding-left: 3px;
                    padding-right: 3px;
                    -moz-border-radius: 2px;
                    -webkit-border-radius: 2px;
                    -moz-box-shadow: 3px 3px 5px #bbb;
                    -webkit-box-shadow: 3px 3px 5px #bbb;
                }
                div.amendsReport {
                    font-family: verdana;
                    border: solid 1px #aaa;
                    margin: 1em;
                    padding-bottom: 20px;
                    margin-bottom: 20px;
                    font-size: 0.8em;
                    -moz-border-radius: 5px;
                    -webkit-border-radius: 5px;
                    -moz-box-shadow: 3px 3px 5px #bbb;
                    -webkit-box-shadow: 3px 3px 5px #bbb;
                }
                div.amendsReport h2 {
                    font-size: 1.2em;
                    color: black;
                    margin: 0em;
                    background: #C6E2FF;
                    padding: 0.5em;
                    background: -moz-linear-gradient(top, #fff, #C6E2FF);
                    background: -webkit-gradient(linear, left top, left bottom, from(#fff), to(#C6E2FF));
                }
                div.amendsReport p.amendsParse {
                    margin-bottom: 1em;
                    margin-top: 1em;
                    color: black;
                    font-weight: bold;
                     padding-left: 1em
                }
                div.amendsReport p.amendsReportPara {
                    margin: 0em;
                     padding-left: 1em
                }
                div.amendsBlock div.amendsBlockInner p.extractedText {
                    color: #888;
                    margin-left: 20px;
                    margin-right: 20px;
                    background:transparent;
                    max-height: 100px;
                    overflow: auto;
                     text-decoration: none
                }
                div.amendsBlock div.amendsBlockInner p.amendQuote {
                    color: #888;
                    margin-left: 20px;
                    margin-right: 20px;
                    background:transparent;
                    max-height: 100px;
                    overflow: auto;
                     text-decoration: none
                }
                div.amendsBlock div.amendsBlockInner div {
                    margin-left: 20px;
                    background:transparent;
                    color: black;
                    text-decoration: none;
                     padding: 5px
                }
                .LegAmendingText {
                    border: dashed 1px #C6E2FF;
                    -moz-border-radius: 2px;
                    -webkit-border-radius: 2px;
                }
                ;</style>
            </head>
			<body>
              <!-- <xsl:sequence  select="$amendsList"/>-->
               <div id="layout2">
				   <div class="amendsReport">
                    <h2>Report</h2>
                    <p class="amendsParse">
                        <xsl:choose>
                            <xsl:when test="//Changes[last()]/@parsed = 'true'">Document textuals
                                parsed</xsl:when>
                            <xsl:otherwise>Document textuals did not parse</xsl:otherwise>
                        </xsl:choose>
                    </p>
                    <xsl:for-each select="tokenize(//Changes[last()]/Report/Description, '&#10;')">
                        <p class="amendsReportPara">
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:for-each>
                    <xsl:if test="//Changes/(NTunder | NTgeneral)">
                        <p class="amendsParse">Document contains extracted non-textual information</p>
                    </xsl:if>
                    <xsl:if test="//Changes//(Commencement | CommencementRef | CommencementPara | CommencementLegislation | CommencementProvision | CommencementProvisions | ComesIntoForce)">
                        <p class="amendsParse">Document contains extracted commencement information</p>
                    </xsl:if>
					<xsl:if test="//Changes//(ExtentGroup | Extent)">
                        <p class="amendsParse">Document contains extracted extent information</p>
                    </xsl:if>
                </div>
                <div class="amendsOutput">
                    <xsl:apply-templates select="$legDoc" mode="applyAmends"/>
                </div>   
			   </div> 
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="DesDocument">
        <xsl:apply-templates select="leg:Legislation"/>
    </xsl:template>

    <xsl:template match="Changes"/>

    <xsl:template match="*" mode="applyAmends">
        <xsl:if
            test="self::xhtml:p[xhtml:span/@class[contains(., 'LegP1No')]] or self::xhtml:a[@class = 'LegAnchorID']">
            <xsl:variable name="id" select="if (self::xhtml:p) then (.//xhtml:span/@id)[1] else @id"/>
            <xsl:if test="$id = ($amendsList | $amendsList//amend:block)/@source">
                <xsl:for-each select="($amendsList | $amendsList//amend:block)[@source = $id]
                        [1 or $id = 'Legislation-Preamble' or preceding-sibling::amend:block[@source = $id]]">
                    <div class="amendsBlock">
                        <div
                            class="amendsBlockInner {@class}">
                            <xsl:if test="ancestor::amend:block">
                                <p class="amendParaNested">Nested context - check parent for details</p>
                            </xsl:if>
                            <xsl:apply-templates
                                select="*"
                                mode="renderAmends"/>
                        </div>
                    </div>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:if test="(self::xhtml:a[@class = 'LegAnchorID'] | self::xhtml:strong)[not(node())]">
                <xsl:comment/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*" mode="renderAmends">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="amend:block" mode="renderAmends">
        <xsl:choose>
            <xsl:when test="not(@source = ancestor::amend:block/@source)">
                <div class="amendBlockDiv">
                    <xsl:apply-templates mode="#current"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="*" mode="calcAmends">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="EnablingPower" mode="calcAmends">
        <xsl:apply-templates select="*" mode="#current"/>
    </xsl:template>

    <xsl:template match="EnablingProvisions" mode="calcAmends">
        <xsl:variable name="leg" select="if (Legislation) then Legislation/@context else ''"/>
        <amend:block source="Legislation-Preamble">
            <p class="amendPara">Enabling Legislation: <a xsl:exclude-result-prefixes="#all"
                    href="{$leg}"><xsl:value-of select="if ($leg != '') then $leg else 'Unknown'"
                    /></a></p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except Legislation" mode="#current">
                    <xsl:with-param name="leg" tunnel="yes" select="Legislation/@context"/>
                    <xsl:with-param name="ref" tunnel="yes" select="Legislation/@sourceRef"/>
                </xsl:apply-templates>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="EnablingProvision" mode="calcAmends">
        <p class="amendPara">Provisions</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="EnablingAccordance" mode="calcAmends">
        <amend:block source="Legislation-Preamble">
            <p class="amendPara">In accordance</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="RR" mode="calcAmends">
        <xsl:variable name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if (Legislation) then Legislation/@context else ''"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsRR">
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Repeal/revocation</p>
            <p class="amendPara">Affected Legislation: <a xsl:exclude-result-prefixes="#all"
                    href="{$leg}"><xsl:value-of select="if ($leg != '') then $leg else 'Unknown'"
                    /></a></p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="RRitem" mode="calcAmends">
        <p class="amendPara">The following item:</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>


    <xsl:template match="Cited" mode="calcAmends">
        <xsl:param name="ref" select="CrossRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if (Legislation) then Legislation/@context else ''"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">Cited as: <a xsl:exclude-result-prefixes="#all" href="{$leg}"><xsl:value-of select="if ($leg != '') then $leg else 'Unknown'"/></a></p>
        </amend:block>
        <xsl:apply-templates select="CommencementProvision | ComesIntoForce | CommencementPara" mode="#current"/>
    </xsl:template>


    <xsl:template match="Cited/ComesIntoForce" mode="calcAmends">
        <xsl:variable name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsComing">
            <xsl:next-match/>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="ProvisionComingIntoForce" mode="calcAmends">
        <xsl:variable name="ref" select="Action[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsComing">
            <p class="amendPara" xsl:exclude-result-prefixes="#all">The following come into
                force</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="CommencementPara | CommencementRef | Commencement | CommencementLegislation | CommencementProvision | CommencementProvisions" mode="calcAmends">
        <xsl:variable name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsComing">
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Come into force</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="CommencementTail" mode="calcAmends"/>

    <xsl:template match="ExtentGroup" mode="calcAmends">
        <xsl:variable name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsExtent">
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Extent for the following group:</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="Extent" mode="calcAmends">
        <xsl:variable name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsExtent">
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Extent</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="ExtentTail" mode="calcAmends"/>
    
    <xsl:template match="LegislationAmendment" mode="calcAmends">
        <xsl:message>Legislation <xsl:value-of select="Legislation/@sourceRef"/></xsl:message>
        <xsl:apply-templates select="* except (Legislation | Action)" mode="#current">
            <xsl:with-param name="leg" tunnel="yes" select="Legislation/@context"/>
            <xsl:with-param name="ref" tunnel="yes" select="Legislation/@sourceRef"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template
        match="InRefChange | InParaChange | InGroupChange | GroupAmendment | RefAmendment | ParaAmendment | TableAmendment | GroupOfLegislationAmendment | RefOfLegislationAmendment | ParaOfLegislationAmendment | InLegislation"
        mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <!-- Note that in some instance stuff will be wrongly nested so check this element for legislation before inheriting -->
        <xsl:variable name="leg"
            select="if (InlineLocationLegislation) then InlineLocationLegislation/Legislation/@context else $leg"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <xsl:apply-templates select="Error" mode="#current"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <xsl:apply-templates select="LegRef | LegConjunction" mode="#current"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except (LegRef | LegConjunction | Error)"
                    mode="#current">
                    <xsl:with-param name="leg" tunnel="yes" select="$leg"/>
                    <xsl:with-param name="ref" tunnel="yes" select="$ref"/>
                </xsl:apply-templates>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="AfterGroupChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">After</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="BeforeGroupChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '') then Legislation/@context else $leg"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Legislation affected: <a
                    href="{$leg}"><xsl:value-of select="$leg"/></a></p>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Before</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <!--<xsl:template match="InlineRefChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <xsl:apply-templates select="LegRef | LegConjunction | InlineHeadingTo" mode="#current"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except (LegRef | LegConjunction | Error | InlineHeadingTo)" mode="#current">
                    <xsl:with-param name="leg" tunnel="yes" select="$leg"/>
                    <xsl:with-param name="ref" tunnel="yes" select="$ref"/>
                </xsl:apply-templates>
            </div>
        </amend:block>
    </xsl:template>    -->

    <xsl:template match="ProvisionAmendment" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg" select="Legislation/@context"/>
        <amend:block source="{amend:calcSource($ref)}">
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template
        match="InSubRefChange | InSubParaChange | InSubParaAnomalyChange | InSubSubParaChange"
        mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:apply-templates select="LegRef" mode="#current"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except LegRef" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="TableChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">In the table in</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="InTableChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:apply-templates select="LegRef" mode="#current"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except LegRef" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template
        match="ActionDeleteGroup | ActionDeleteRef | ActionDeleteSubRef | ActionDeleteSubPara | ActionDeleteSubPara | ActionDeleteSubSubPara | ActionDeleteSubSubSubPara"
        mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">The following are deleted</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="LocationAfterRefAction" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and InlineLocationAfterRefAction/InlineLocationAfterRef/Legislation) then InlineLocationAfterRefAction/InlineLocationAfterRef/Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <xsl:apply-templates mode="#current"/>
        </amend:block>
    </xsl:template>

    <xsl:template match="LocationAtEnd | LocationAtEndGroupAction" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">At the end</p>
            <xsl:apply-templates mode="#current"/>
        </amend:block>
    </xsl:template>


    <xsl:template match="LocationAtBeginning" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <xsl:apply-templates mode="#current"/>
        </amend:block>
    </xsl:template>

    <xsl:template
        match="ProvisionRepeal | ParaRepeal | RefRepeal | LegislationRepeal | ParaOfLegislationRepeal"
        mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and InlineLocationLegislation) then InlineLocationLegislation/Legislation/@context else $leg"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">The following are deleted</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="LegRef" mode="#current"/>
                <div xsl:exclude-result-prefixes="#all">
                    <xsl:apply-templates select="* except LegRef" mode="#current">
                        <xsl:with-param name="leg" tunnel="yes" select="$leg"/>
                        <xsl:with-param name="ref" tunnel="yes" select="$ref"/>
                    </xsl:apply-templates>
                </div>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="InDefinitionLegislation" mode="calcAmends">
        <xsl:param name="ref" select="Quote[1]/@sourceRef"/>
        <xsl:variable name="leg" select="InlineLocationLegislation/Legislation/@context"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">In the definition:</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template
        match="LocationForRef | LocationForPara | LocationForSubPara | LocationForSubSubPara | LocationForSubSubSubPara"
        mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">For the following:</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template
        match="ActionSubtitute"
        mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">Substitute</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    
    <xsl:template match="HeadingChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and InlineLocationLegislation) then InlineLocationLegislation/Legislation/@context else $leg"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">In the heading</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="TocChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and InlineLocationLegislation) then InlineLocationLegislation/Legislation/@context else $leg"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="amend:calcLegislationContext($leg, .)"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara" xsl:exclude-result-prefixes="#all">In the TOC</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="LocationForSubRef" mode="calcAmends">
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:apply-templates select="LegRef" mode="#current"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except LegRef" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="RefHeadingChange" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">In the heading</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="SubRefRepeal | SubParaRepeal" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">The following are deleted</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="LocationForDefinition" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">For the definition</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="AfterEntry" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">After that entry</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template
        match="LocationBeforeRelatedEntry | LocationBeforeRelatedEntryAction | LocationAfterRelatedEntry | LocationAfterRelatedEntryAction | LocationForRelatedEntryAction | LocationAtAppropriatePlace | LocationBeforeRefAction | InDefinition | AtEndOfHeading | AtEndOfDefinition | WordsFrom | LocationBeforeWords | LocationBeforeWordsAction | LocationAfterWords | LocationAfterWordsAction | LocationFor | ActionDelete | ActionInsert | LocationAtEndNoRef | LocationAfterEntryAction | LocationAfterParaAction | LocationAfterSubRefAction | LocationAfterSubParaAction | LocationBeforeSubRefAction | LocationBeforeSubParaAction | LocationBeforeSubSubParaAction | LocationAfterSubSubParaAction | LocationSetOutIn | LocationWordsAfter | LocationWordsFollowing | AfterDefinition | ActionDeleteEntry | LocationAfterHeading | LocationBeforeHeading"
        mode="calcAmends">
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:apply-templates mode="#current"/>
        </amend:block>
    </xsl:template>

    <xsl:template match="InlineActionDeleteEntry" mode="calcAmends">
        <p class="amendPara">The following entries are deleted</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="*" mode="displayAmendItem">
        <xsl:param name="text"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">
                <xsl:value-of select="$text"/>
            </p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="calcAmends"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="AnaphorRef" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//Anaphor)[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="TableEntryChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//Location)[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">In the table entry</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="TableAfterEntryChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//Location)[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">After the table entry</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="LegRef" mode="calcAmends">
        <p class="amendPara">Reference: <xsl:value-of select="@uri"/>, (Text is '<xsl:value-of
                select="."/>')</p>
    </xsl:template>

    <xsl:template match="*[self::ActionDeleteListItem | self::Commencement | self::CommencementProvision | self::CommencementProvisions | self::CommencementPara | self::CommencementLegislation]//InlineLocationLegislation/Legislation"
        mode="calcAmends">
        <div xsl:exclude-result-prefixes="#all">
            <p class="amendPara">Legislation: <a xsl:exclude-result-prefixes="#all"
                    href="{@context}"><xsl:value-of select="@context"/></a> (Text is '<xsl:value-of
                    select="."/>')</p>
        </div>
    </xsl:template>

    <xsl:template match="Date" mode="calcAmends">
        <p class="amendPara">Date: <xsl:value-of select="."/></p>
    </xsl:template>
    
    <xsl:template match="ComesIntoForce" mode="calcAmends">
        <xsl:variable name="ref" select="Action[1]/@sourceRef"/>
        <p class="amendPara" xsl:exclude-result-prefixes="#all">Come into force</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
        
    <xsl:template match="CommencementSubListItem | CommencementSubSubListItem" mode="calcAmends">
        <p class="amendPara">The item</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="LegislationListItem" mode="calcAmends">
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="LegislationListItem/Legislation" mode="calcAmends">
        <xsl:variable name="leg" select="@context"/>
        <p class="amendPara">
            <a href="{$leg}"><xsl:value-of select="if ($leg != '') then $leg else 'Unknown'"
                /></a>
        </p>
    </xsl:template>

    <xsl:template match="Qualifications" mode="calcAmends">
        <p class="amendPara">Qualified by</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template match="ExtentCountries" mode="calcAmends">
        <p class="amendPara">For the countries</p>
        <div xsl:exclude-result-prefixes="#all">
            <p class="amendPara"><xsl:value-of select="."/></p>
        </div>
    </xsl:template>

    <xsl:template match="InlineHeadingTo" mode="calcAmends">
        <p class="amendPara">In the heading to</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="AnaphorRefGroup" mode="calcAmends">
        <xsl:apply-templates select="* except LegRef" mode="#current"/>
    </xsl:template>

    <xsl:template match="Anaphor[@subType = 'Following']" mode="calcAmends">
        <p class="amendPara">After that</p>
    </xsl:template>

    <xsl:template match="Anaphor[@type = 'ThisLegislation']" mode="calcAmends">
        <p class="amendPara">This legislation</p>
    </xsl:template>
    
    <xsl:template match="Anaphor[@type = 'WholeLegislation']" mode="calcAmends">
        <p class="amendPara">The entire item of legislation</p>
    </xsl:template>

    <xsl:template match="InlineAnaphorExistingRef" mode="calcAmends">
        <p class="amendPara">The existing provision becomes</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="LegAmendment" mode="calcAmends">
        <p class="amendPara">The amendment</p>
        <p class="extractedText">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="Quote" mode="calcAmends">
        <p class="amendQuote">
            <xsl:value-of select="."/>
        </p>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="LegRefs | LegParas | LegSubParas | LegSubSubParas | LegSubSubSubParas" mode="calcAmends">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="Relation" mode="calcAmends">
        <div xsl:exclude-result-prefixes="#all">
            <p class="amendQuote">
                <xsl:value-of select="."/>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="LegConjunction" mode="calcAmends">
        <p class="amendPara">And</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Substitution']" mode="calcAmends">
        <p class="amendPara">Substitute</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Insert'][not(parent::InlineActionInsert)]"
        mode="calcAmends">
        <p class="amendPara">Insert</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Repeal']" mode="calcAmends">
        <p class="amendPara">Is repealed</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Delete']" mode="calcAmends"> </xsl:template>

    <xsl:template match="CrossRef" mode="calcAmends">
        <p class="amendPara">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="ProvisionList" mode="calcAmends">
        <p class="amendPara">The list of provisions is</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="ActionDeleteList" mode="calcAmends">
        <p class="amendPara">The list of items is:</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="ActionDeleteListItem" mode="calcAmends">
        <p class="amendPara">The following:</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineWordsTo" mode="calcAmends">
        <p class="amendPara">Up to the words</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template
        match="InlineLocationBeforeWords[not(parent::InlineLocationBeforeWordsAction)] | InlineLocationBeforeWordsAction"
        mode="calcAmends">
        <p class="amendPara">Before the words</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template
        match="InlineLocationAfterWords[not(parent::InlineLocationAfterWordsAction)] | InlineLocationAfterWordsAction"
        mode="calcAmends">
        <p class="amendPara">After the words</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="LocationInEntry | InlineLocationInEntry" mode="calcAmends">
        <p class="amendPara">In the entry for</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAfterRelatedEntry" mode="calcAmends">
        <p class="amendPara">After the entry related to</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAfterEntryAction" mode="calcAmends">
        <p class="amendPara">After the entry</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template
        match="InlineLocationBeforeRelatedEntry[not(parent::InlineLocationBeforeRelatedEntryAction)] | InlineLocationBeforeRelatedEntryAction"
        mode="calcAmends">
        <p class="amendPara">Before the entry related to</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationForRelatedEntry | InlineLocationForRelatedEntryAction"
        mode="calcAmends">
        <p class="amendPara">For the entry related to</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAfterRelatedEntry | InlineLocationAfterRelatedEntryAction"
        mode="calcAmends">
        <p class="amendPara">After the entry related to</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationSetOutIn" mode="calcAmends">
        <p class="amendPara">Set out in</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
   
    <xsl:template match="InlineLocationIn" mode="calcAmends">
        <p class="amendPara">In</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationFor | InlineLocationForRef" mode="calcAmends">
        <p class="amendPara">For</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template
        match="InlineLocationAfterRef[not(parent::InlineLocationAfterRefAction)] | InlineLocationAfterRefAction | InlineLocationAfterPara[not(parent::InlineLocationAfterParaAction)] | InlineLocationAfterParaAction | InlineLocationAfterSubSubPara[not(parent::InlineLocationAfterSubSubParaAction)] | InlineLocationAfterSubSubParaAction | InlineLocationAfterSubRef[not(parent::InlineLocationAfterSubRefAction)] | InlineLocationAfterSubRefAction"
        mode="calcAmends">
        <p class="amendPara">After</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template
        match="InlineLocationBeforeRef[not(parent::InlineLocationBeforeRefAction)] | InlineLocationBeforeRefAction | InlineLocationBeforeSubSubPara[not(parent::InlineLocationBeforeSubSubParaAction)] | InlineLocationBeforeSubSubParaAction | InlineLocationBeforeSubPara[not(parent::InlineLocationBeforeSubParaAction)] | InlineLocationBeforeSubParaAction"
        mode="calcAmends">
        <p class="amendPara">Before</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAtBeginning" mode="calcAmends">
        <p class="amendPara">At the beginning</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>


    <xsl:template match="InlineWordsFrom" mode="calcAmends">
        <p class="amendPara">From the words from</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineWordsAfter" mode="calcAmends">
        <p class="amendPara">The words after</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineWordsFollowing" mode="calcAmends">
        <p class="amendPara">The words</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAtAppropriatePlace" mode="calcAmends">
        <p class="amendPara">At the appropriate place</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineActionInsert" mode="calcAmends">
        <p class="amendPara">Insert</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template match="InlineRefRepeal" mode="calcAmends">
        <p class="amendPara">The following are repealed</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>    

    <xsl:template match="InlineActionDelete | InlineActionDeleteRef | InlineActionDeleteSubRef"
        mode="calcAmends">
        <p class="amendPara">Delete</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineInDefinition" mode="calcAmends">
        <p class="amendPara">In the definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>


    <xsl:template match="InlineDefinition" mode="calcAmends">
        <p class="amendPara">The definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineAfterDefinition" mode="calcAmends">
        <p class="amendPara">After the definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineAtEndOfDefinition" mode="calcAmends">
        <p class="amendPara">At the end of the definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineAtEndOfHeading" mode="calcAmends">
        <p class="amendPara">At the end of the heading</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationForDefinition" mode="calcAmends">
        <p class="amendPara">For the definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineOfDefinition" mode="calcAmends">
        <p class="amendPara">Of the definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAsSubstitutedBy" mode="calcAmends">
        <p class="amendPara">As substituted by</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationAfterHeading" mode="calcAmends">
        <p class="amendPara">After the heading</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="InlineLocationBeforeHeading" mode="calcAmends">
        <p class="amendPara">Before the heading</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="WordsOccurringIn" mode="calcAmends">
        <xsl:apply-templates select="LegRef" mode="#current"/>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates select="* except LegRef" mode="#current"/>
        </div>
    </xsl:template>

    <xsl:template match="Anaphor[@type = 'Words']" mode="calcAmends">
        <p class="amendPara">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="Anaphor[@type = 'OtherRef']" mode="calcAmends">
        <p class="amendPara">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="Anaphor[@type = 'Legislation']" mode="calcAmends">
        <p class="amendPara">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="Anaphor[@type = 'Ref']" mode="calcAmends">
        <p class="amendPara">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="Anaphor[@type = 'Definition']" mode="calcAmends">
        <p class="amendPara">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="Location[@type = 'OfDefinition']" mode="calcAmends">
        <p class="amendPara">Of the definition of</p>
    </xsl:template>

    <xsl:template match="Location[@type = 'NotInForce']" mode="calcAmends">
        <p class="amendPara">Not already in force</p>
    </xsl:template>

    <xsl:template match="Location[@type = 'RelatedEntry']" mode="calcAmends">
        <p class="amendPara">The entries</p>
    </xsl:template>
    
    <xsl:template match="Location[@type = 'SubjectTo']" mode="calcAmends">
        <p class="amendPara">Subject to</p>
    </xsl:template>
    
    <xsl:template match="Location[@type = 'AfterRef'][not(parent::InlineLocationAfterSubSubPara | parent::InlineLocationAfterRef)]"
        mode="calcAmends">
        <p class="amendPara">After</p>
    </xsl:template>

    <xsl:template match="Location[@position]" mode="calcAmends">
        <p class="amendPara">The <xsl:value-of select="@position"/> instance of</p>
    </xsl:template>


    <!-- Non textual processing -->

    <xsl:template match="NTaccordance | NTpurposes | NTunder | NTgeneral | NTapplied | NTexcluded | NTwithModifications" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//NonTextualPhrase)[1]/@sourceRef"/>
        <xsl:variable name="leg"
            select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg"
            select="if ($leg = '') then preceding::Legislation[1]/@context else $leg"/>
        <amend:block source="{amend:calcSource($ref)}" class="amendsNT">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">
                <xsl:text>Non-textual amendment </xsl:text>
                <xsl:if test="self::NTapplied">(applied)</xsl:if>
                <xsl:if test="self::NTexcluded">(excluded)</xsl:if>
                <!-- Under certain circumstances the with modification is picked up in the tail of the effect -->
                <xsl:if test="self::NTwithModifications or .//NonTextualPhrase[@type = 'WithModifications']">(with modifications)</xsl:if>
            </p>
        </amend:block>
    </xsl:template>

    <!-- General code -->

    <xsl:template match="text()" mode="calcAmends"/>

    <xsl:template match="Error" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendError">An error occurred just before this point</p>
        </amend:block>
    </xsl:template>

    <xsl:template
        match="gate:NonTextualPhrase | gate:ExtendTo | gate:ExtentCountries | gate:CrossRef | gate:LegRef | gate:Action | gate:Location | gate:Quote | gate:Relation | gate:Date | gate:Anaphor | gate:Structure"
        mode="#all">
        <span class="gate-Inline gate-{local-name()}">
            <xsl:attribute name="title"
                select="concat(name(), ' - ', string-join(for $att in @* return concat(name($att), ': ', $att), '; '))"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gate:Legislation" mode="#all">
        <span class="gate-{local-name()}">
            <xsl:choose>
                <xsl:when test="@context">
                    <a xsl:exclude-result-prefixes="#all" href="{@context}">
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>

    <xsl:template match="gate:*" mode="#all">
        <!--<span class="gate-{local-name()}">-->
        <xsl:apply-templates/>
        <!--</span>-->
    </xsl:template>

    <xsl:function name="amend:calcSource">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(substring-after($text, $legUri), '/', '-')"/>
    </xsl:function>

    <xsl:function name="amend:outputLeg">
        <xsl:param name="leg"/>
        <p class="amendPara">Legislation affected: <a xsl:exclude-result-prefixes="#all"
                href="{$leg}"><xsl:value-of
                    select="if ($leg != '') then string-join($leg, ', ') else 'Unknown'"/></a></p>
    </xsl:function>

    <xsl:function name="amend:calcLegislationContext">
        <xsl:param name="leg"/>
        <xsl:param name="context"/>
        <xsl:value-of
            select="if ($leg = '') then $context/preceding::Legislation[not(ancestor::ParaRepeal)][1]/@context else $leg"
        />
    </xsl:function>
	
</xsl:stylesheet>
