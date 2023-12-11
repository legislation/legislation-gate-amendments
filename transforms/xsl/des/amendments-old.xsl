<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
xmlns:amend="http://amend.com"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:err="http://www.tso.co.uk/assets/namespace/error"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:gate="http://www.gate.ac.uk"
xmlns:dct="http://purl.org/dc/terms/"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
xmlns:svg="http://www.w3.org/2000/svg"
xmlns:atom="http://www.w3.org/2005/Atom"
exclude-result-prefixes="#all">

    <xsl:import href="../legislation/html/legislation_xhtml_consolidation.xslt"/>
    <xsl:import href="../legislation/html/quicksearch.xsl"/>
    
    <xsl:output method="xml" version="1.0" omit-xml-declaration="yes"  indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" exclude-result-prefixes="#all"/>

    <xsl:variable name="legUri" select="concat(//leg:Legislation[1]/@IdURI, '/')"/>
    
    <xsl:variable name="amendsList" as="element()*">
        <xsl:apply-templates select="//Changes/*" mode="calcAmends"/>
    </xsl:variable>
    
    <xsl:variable name="g_ndsMetadata" select="//leg:Legislation/ukm:Metadata"/>
    <xsl:variable name="g_ndsMainDoc" select="//leg:Legislation"/>
    
	<!-- input parameter doc -->
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request-info')) then doc('input:request-info') else ()"/>

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
				<title>Legislation.gov.uk</title>
				<style type="text/css">
					/* Legislation stylesheets - load depending on content type */
					@import "http://www.legislation.gov.uk/styles/legislation.css";
					<xsl:choose>
						<xsl:when test="$g_strDocumentType = 'primary'">
							<xsl:text>@import "http://www.legislation.gov.uk/styles/primarylegislation.css";</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>@import "http://www.legislation.gov.uk/styles/secondarylegislation.css";</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					@import "http://www.legislation.gov.uk/styles/legislationOverwrites.css";
	
					html {background-color: #ffffff; color: black}
					div.amendsOutput {background-color: white; width: 100%; margin: 0px}
					div.amendsBlock {border-bottom: solid 3px #808080; border-right: solid 3px #808080; background-color: #C6E2FF; color: black; clear: both; margin: 1em}
					div.amendsBlock div.amendsBlockInner {position: relative; left: -2px; top: -2px; padding: 5px; background-color: #C6E2FF; color: black; font-size: 0.85em; border: solid 1px #e0e0e0}
					div.amendsBlock div.amendsBlockInner p.amendPara {background-color: #C6E2FF; padding: 0px; margin: 0px; color: black; text-decoration: none}
					div.amendsBlock div.amendsBlockInner p.amendParaNested {background-color: #C6E2FF; padding: 3px; margin: 0px; color: black; text-decoration: none; border: dashed 1px #888}
					div.amendsBlock div.amendsBlockInner p.amendError {background-color: #C6E2FF; padding: 0px; margin: 0px; color: red; text-decoration: none; font-weight: bold}
					div.amendsBlock div.amendsBlockInner p.amendPara a {background-color: #C6E2FF}
					div.amendsBlock div.amendsBlockInner div.amendBlockDiv {border: dashed 1px #888; margin-bottom: 5px; opacity: 0.4}
					div.amendsBlock div.amendsBlockInner div.amendBlockDiv div.amendBlockDiv {opacity: 1}
					span.gate-LegRef {border: solid 1px red; padding-left: 3px; padding-right: 3px}
					span.gate-Legislation {border: solid 1px purple; padding-left: 3px; padding-right: 3px}
					span.gate-Legislation a {text-decoration: none}
					span.gate-Location {border: solid 1px green; padding-left: 3px; padding-right: 3px}
					span.gate-Relation {border: solid 1px purple; padding-left: 3px; padding-right: 3px}
					span.gate-Quote {border: solid 1px orange; padding-left: 3px; padding-right: 3px}
					span.gate-Action {border: solid 1px cyan; padding-left: 3px; padding-right: 3px}
					div.amendsReport {font-family: verdana; border-top: solid 1px #C6E2FF; padding-top: 10px; margin-top: 20;x; border-bottom: solid black 1px; padding-bottom: 20px; margin-bottom: 20px; font-size: 0.8em}
					div.amendsReport h2 {font-size: 1.2em; color: black}
					div.amendsReport p.amendsParse {margin-bottom: 1em; margin-top: 1em; color: black; font-weight: bold; padding: 0em}
					div.amendsReport p.amendsReportPara {margin: 0em; padding: 0em}
					div.amendsBlock div.amendsBlockInner p.extractedText {color: green; margin-left: 20px; margin-right: 20px; background-color: #C6E2FF; max-height: 100px; overflow: auto; text-decoration: none}
					div.amendsBlock div.amendsBlockInner p.amendQuote {color: green; margin-left: 20px; margin-right: 20px; background-color: #C6E2FF; max-height: 100px; overflow: auto; text-decoration: none}
					div.amendsBlock div.amendsBlockInner div {margin-left: 20px; background-color: #C6E2FF; color: black; text-decoration: none; border-left: solid 1px #c0c0c0; border-bottom: solid 1px #c0c0c0; padding: 5px}
				</style>
           	</head>
            <body id="doc"> 
               <!--<xsl:sequence  select="$amendsList"/>-->
               <!-- 

					This stuff is the report - maybe we don't need it

					<div class="amendsReport">
                   <h2>Report</h2>
                   <p class="amendsParse">
                       <xsl:choose>
                           <xsl:when test="//Changes/@parsed = 'true'"></xsl:when>
                           <xsl:otherwise>
							   <xsl:text>Unable to process - DES service reports that document did not parse</xsl:text>
                           </xsl:otherwise>
                       </xsl:choose>
                   </p>
                   <xsl:for-each select="tokenize(//Changes/Report/Description, '&#10;')">
                       <p class="amendsReportPara"><xsl:value-of select="."/></p>
                   </xsl:for-each>

               </div>-->
				<div id="layout2" >
					<xsl:call-template name="TSOOutputQuickSearch" />		
					<div class="title">
						<h1 id="pageTitle">
							<xsl:text>Data Enrichment Demonstration</xsl:text>
						</h1>
					</div>
					<div id="content">
						<p>
							<b>Source: </b>
							<xsl:variable name="demoUri" select="$paramsDoc/request/parameters/parameter[name ='demo']/value" as="xs:string?"/>
							<xsl:value-of select="$demoUri"/>
						</p>
					   <xsl:if test="not(//Changes/@parsed = 'true')">
						   <p>Unable to process - DES service reports that document did not parse</p>
					   </xsl:if>
					   <div class="amendsOutput">
							<xsl:apply-templates select="$legDoc" mode="applyAmends"/>
					   </div>    
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
        <xsl:if test="self::xhtml:p[xhtml:span/@class[contains(., 'LegP1No')]] or self::xhtml:a[@class = 'LegAnchorID']">
            <xsl:variable name="id" select="if (self::xhtml:p) then (.//xhtml:span/@id)[1] else @id"/>
            <xsl:if test="$id = ($amendsList | $amendsList//amend:block)/@source">
                <div class="amendsBlock">
                    <div class="amendsBlockInner">
                        <xsl:if test="($amendsList//amend:block)[@source = $id]">
                            <p class="amendParaNested">Nested context - check parent for details</p>
                        </xsl:if>
                        <xsl:apply-templates select="($amendsList | $amendsList//amend:block)[@source = $id][1]/*" mode="renderAmends"/>
                    </div>
                </div>
            </xsl:if>
        </xsl:if>            
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:if test="(self::xhtml:a[@class = 'LegAnchorID'] | self::xhtml:strong)[not(node())]">
                <xsl:comment></xsl:comment>
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

    <xsl:template match="LegislationAmendment | InLegislation" mode="calcAmends">
        <xsl:message>Legislation <xsl:value-of select="Legislation/@sourceRef"/></xsl:message>
        <xsl:apply-templates select="* except (Legislation | Action)" mode="#current">
            <xsl:with-param name="leg" tunnel="yes" select="Legislation/@context"/>
            <xsl:with-param name="ref" tunnel="yes" select="Legislation/@sourceRef"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="InRefChange | InParaChange | InGroupChange | RefAmendment | ParaAmendment | TableAmendment | GroupOfLegislationAmendment | RefOfLegislationAmendment" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '' and LocationLegislation) then LocationLegislation/Legislation/@context else $leg"/>        
        <xsl:variable name="leg" select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="if ($leg = '') then preceding::Legislation[1]/@context else $leg"/>
        <xsl:apply-templates select="Error" mode="#current"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <xsl:apply-templates select="LegRef | LegConjunction" mode="#current"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="* except (LegRef | LegConjunction | Error)" mode="#current">
                    <xsl:with-param name="leg" tunnel="yes" select="$leg"/>
                    <xsl:with-param name="ref" tunnel="yes" select="$ref"/>
                </xsl:apply-templates>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="AfterRefChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="if ($leg = '') then preceding::Legislation[1]/@context else $leg"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">After</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="BeforeRefChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '') then Legislation/@context else $leg"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">Legislation affected: <a href="{$leg}"><xsl:value-of select="$leg"/></a></p>
            <p class="amendPara">Before</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="InlineRefChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="if ($leg = '') then preceding::Legislation[1]/@context else $leg"/>        
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
    </xsl:template>    

    <xsl:template match="ProvisionAmendment" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef/@sourceRef"/>
        <xsl:variable name="leg" select="Legislation/@context"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates select="*" mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>

    <xsl:template match="InSubRefChange | InSubParaChange | InSubParaAnomalyChange | InSubSubParaChange[not(parent::InSubRefChange)]" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef/@sourceRef"/>
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

    <xsl:template match="ActionDeleteRef | ActionDeleteSubRef" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara">The following are deleted</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="LocationAfterRefAction | LocationAtEnd" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select=".//LegRef[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <xsl:apply-templates mode="#current"/>            
        </amend:block>
    </xsl:template>

    <xsl:template match="RefRepeal" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select=".//LegRef[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">The following:</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>                
        </amend:block>
    </xsl:template>

    <xsl:template match="InDefinition" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">In the definition:</p>
            <xsl:apply-templates mode="#current"/>            
        </amend:block>
    </xsl:template>

    <xsl:template match="InDefinitionLegislation" mode="calcAmends">
        <xsl:param name="ref" select="Quote[1]/@sourceRef"/>
        <xsl:variable name="leg" select="LocationLegislation/Legislation/@context"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">In the definition:</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>                
        </amend:block>
    </xsl:template>

    <xsl:template match="LocationForRef" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="LegRef[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">For the following:</p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>            
        </amend:block>
    </xsl:template>

    <xsl:template match="InlineGroupChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" tunnel="yes"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>            
        </amend:block>
    </xsl:template>

    <xsl:template match="HeadingChange" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="(.//LegRef)[1]/@sourceRef"/>
        <xsl:variable name="leg" select="if ($leg = '' and LocationLegislation) then LocationLegislation/Legislation/@context else $leg"/>        
        <xsl:variable name="leg" select="if ($leg = '' and Legislation) then Legislation/@context else $leg"/>
        <xsl:variable name="leg" select="if ($leg = '') then preceding::Legislation[1]/@context else $leg"/>        
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:copy-of select="amend:outputLeg($leg)"/>
            <p class="amendPara">In the heading</p>
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

    <xsl:template match="AfterParaChange | AfterSubRefChange | AfterSubParaChange" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">After</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="RefHeadingChange" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">In the heading</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>    

    <xsl:template match="BeforeSubRefChange" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">Before</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="SubRefRepeal | SubParaRepeal" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">The following:</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>   
    
    <xsl:template match="LocationForDefinition" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">For the definition</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>        

    <xsl:template match="AfterDefinition" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">After the definition</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>      

    <xsl:template match="WordsFrom" mode="calcAmends">
        <xsl:apply-templates select="." mode="displayAmendItem">
            <xsl:with-param name="text">For the words from</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template> 

    <xsl:template match="LocationFor | LocationAfterSubRefAction | ActionDelete" mode="calcAmends">
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <xsl:apply-templates mode="#current"/>
        </amend:block>        
    </xsl:template>

    <xsl:template match="*" mode="displayAmendItem">
        <xsl:param name="text"/>
        <xsl:param name="ref" select="(.//*[@sourceRef])[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendPara"><xsl:value-of select="$text"/></p>
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="calcAmends"/>
            </div>            
        </amend:block>
    </xsl:template>        

    <xsl:template match="AnaphorRef" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select=".//Anaphor[1]/@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <div xsl:exclude-result-prefixes="#all">
                <xsl:apply-templates mode="#current"/>
            </div>            
        </amend:block>
    </xsl:template>
    
    <xsl:template match="LegRef" mode="calcAmends">
        <p class="amendPara">Reference: <xsl:value-of select="@uri"/>, (Text is '<xsl:value-of select="."/>')</p>            
    </xsl:template>

    <xsl:template match="TableEntryChange" mode="calcAmends">
        <p class="amendPara">In the table entry</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
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

    <xsl:template match="LegAmendment" mode="calcAmends">
        <p class="amendPara">The amendment</p>
        <p class="extractedText"><xsl:value-of select="."/></p>
    </xsl:template>

    <xsl:template match="InlineLocationFor" mode="calcAmends">
        <p class="amendPara">For the text</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>

    <xsl:template match="Quote" mode="calcAmends">
        <p class="amendQuote"><xsl:value-of select="."/></p>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="InlineInDefinition" mode="calcAmends">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="InlineOfDefinition" mode="calcAmends">
        <p class="amendPara">Of the definition</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>    

    <xsl:template match="LegRefs" mode="calcAmends">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="Relation" mode="calcAmends">
        <div xsl:exclude-result-prefixes="#all">
            <p class="amendQuote"><xsl:value-of select="."/></p>
        </div>
    </xsl:template>

    <xsl:template match="LegConjunction" mode="calcAmends">
        <p class="amendPara">And</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Substitution']" mode="calcAmends">
        <p class="amendPara">Substitute</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Repeal']" mode="calcAmends">
        <p class="amendPara">Are repealed</p>
    </xsl:template>

    <xsl:template match="Action[@type = 'Delete']" mode="calcAmends">
    </xsl:template>

    <xsl:template match="CrossRef" mode="calcAmends">
        <p class="amendPara"><xsl:value-of select="."/></p>
    </xsl:template>

    <xsl:template match="PriovisionList" mode="calcAmends">
        <p class="amendPara">The list of provisions is</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>

    <xsl:template match="ActionDeleteEntry" mode="calcAmends">
        <p class="amendPara">The following entries are deleted</p>
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

    <xsl:template match="InlineLocationAfterWords" mode="calcAmends">
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

    <xsl:template match="AfterEntry" mode="calcAmends">
        <p class="amendPara">After that entry</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>

    <xsl:template match="InlineLocationAfterRelatedEntry" mode="calcAmends">
        <p class="amendPara">After the entry related to:</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>

    <xsl:template match="InlineLocationBeforeRelatedEntry" mode="calcAmends">
        <p class="amendPara">Before the entry related to:</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>

    <xsl:template match="InlineLocationForRef" mode="calcAmends">
        <p class="amendPara">For</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>

    <xsl:template match="InlineLocationAfterRef[not(parent::InlineLocationAfterRefAction)] | InlineLocationAfterRefAction" mode="calcAmends">
        <p class="amendPara">After</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>    

    <xsl:template match="InlineLocationBeforeRef[not(parent::InlineLocationBeforeRefAction)] | InlineLocationBeforeRefAction" mode="calcAmends">
        <p class="amendPara">Before</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>    

    <xsl:template match="InlineLocationAtEnd[not(parent::InlineLocationAtEndAction)] | InlineLocationAtEndNoRef | InlineLocationAtEndAction" mode="calcAmends">
        <p class="amendPara">At the end of</p>
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

    <xsl:template match="InlineLocationAfterSubRef[not(parent::InlineLocationAfterSubRefAction)] | InlineLocationAfterSubRefAction" mode="calcAmends">
        <p class="amendPara">After</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates mode="#current"/>
        </div>            
    </xsl:template>    

    <xsl:template match="InlineLocationAfterSubSubPara[not(parent::InlineLocationAfterSubSubParaAction)] | InlineLocationAfterSubSubParaAction" mode="calcAmends">
        <p class="amendPara">After</p>
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

    <xsl:template match="InlineActionDelete" mode="calcAmends">
        <p class="amendPara">Delete</p>
        <div xsl:exclude-result-prefixes="#all">
            <xsl:apply-templates select="* except LegRef" mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template match="Anaphor[@type = 'Words']" mode="calcAmends">
        <p class="amendPara"><xsl:value-of select="."/></p>
    </xsl:template>

    <xsl:template match="text()" mode="calcAmends"/>

    <xsl:template match="Error" mode="calcAmends">
        <xsl:param name="leg" tunnel="yes"/>
        <xsl:param name="ref" select="@sourceRef"/>
        <amend:block source="{amend:calcSource($ref)}">
            <p class="amendError">An error occurred just before this point</p>
        </amend:block>
    </xsl:template>
    
    <xsl:template match="gate:LegRef | gate:Action | gate:Location | gate:Quote | gate:Relation" mode="#all">
        <span class="gate-{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="gate:Legislation" mode="#all">
        <span class="gate-{local-name()}">
            <xsl:choose>
                <xsl:when test="@context">
                    <a href="{@context}">
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
       <p class="amendPara">Legislation affected: <a href="{$leg}"><xsl:value-of select="if ($leg != '') then $leg else 'Unknown'"/></a></p>

    </xsl:function>

</xsl:stylesheet>
