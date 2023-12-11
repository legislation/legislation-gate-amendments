<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
    xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:err="http://www.tso.co.uk/assets/namespace/error"
    xmlns:tso="http://www.tso.co.uk/assets/namespace/function"
	xmlns:atom="http://www.w3.org/2005/Atom"
xmlns:dc="http://purl.org/dc/elements/1.1/"
version="2.0">
	<!-- this is basically legislation_xhtml_toc.xsl -->
	
	<xsl:param name="strIncludeExtent">false</xsl:param>
	
	<xsl:variable name="booIncludeExtent" as="xs:boolean" select="if ($strIncludeExtent = 'true') then true() else false()"/>
	
	<xsl:variable name="paramsDoc" select="if (doc-available('input:request')) then doc('input:request') else ()"/>
	<xsl:variable name="task" select="if (doc-available('input:task')) then doc('input:task') else ()"/>

	<xsl:variable name="linkPathTokens" select="tokenize(substring-after($task, 'id'),'/')"/>
	<xsl:variable name="linkPath" select="string-join(($linkPathTokens[not(position() = last())]),'/')"/>
	<xsl:variable name="pit" select="$linkPathTokens[last()]"/>

	<xsl:variable name="identifier" select="(/leg:Legislation/ukm:IndexMetadata/@URI, /leg:Legislation/ukm:Metadata/dc:identifier)[1]"/>
	<xsl:variable name="self" select="/leg:Legislation/ukm:Metadata/atom:link[@rel='self']/@href"/>
	
	<xsl:variable name="schematype" select="/leg:Legislation/ukm:Metadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value"/>
	<xsl:variable name="basedate" select="leg:base-date($schematype)"/>
	
	<xsl:key name="versions" match="leg:Version" use="@id"/>

	<xsl:variable name="commentaries" select="//leg:Commentaries"/>

	<xsl:variable name="commentaryRefs" select="distinct-values(//leg:CommentaryRef/@Ref)"/>

	<xsl:variable name="inotes" select="for $i in $commentaryRefs return (if ($commentaries//leg:Commentary[@id = $i]/@Type = 'I') then $i else ())"/>

	<xsl:template match="/">
		<html>
			<head>
				<link rel="stylesheet" href="/styles/screen.css" type="text/css" />
				
				<!--<script type="text/javascript" src="/scripts/jquery-1.6.2.js"/>
		<script type="text/javascript" src="/scripts/CentralConfig.js"/>
		<script type="text/javascript" src="/scripts/survey/survey.js"/>
		<script type="text/javascript" src="/scripts/chrome.js"/>
		<script type="text/javascript" src="/scripts/jquery.cookie.js"/>-->
				
				<!--<style type="text/css" media="screen, print">@import "/styles/legislation.css";</style>-->
				<style type="text/css">/* Legislation stylesheets - load depending on content type */
@import "/styles/legislation.css";
@import "/styles/legislation.css";
@import "/styles/primarylegislation.css";
@import "/styles/legislationOverwrites.css";
/* End of Legislation stylesheets */
				</style>
				<style type="text/css">
				#layout2 {margin: 0em auto 0;}
.LegSnippet .LegAnnotations, .legToc .LegAnnotations {margin:1em !important; padding:0.3em !important;}
.LegSnippet .LegContentsHeading {font-size:1.2em}

.LegSnippet .LegContents ol ol ol {
    background: none repeat scroll 0 0 rgba(0, 0, 0, 0) !important;
    margin-left: 2em !important;
    padding-left: 0 !important;
}
				</style>


				<!--<style type="text/css" media="screen, print">@import "/styles/legislation.css";
			
			.LegContentsPart .info, .LegContentsPblock .info, .LegContentsWhole .info,
			.LegContentsBody .info,  .LegContentsIntroduction .info {margin-left:20%;margin-right:20%}
			.LegProvision .info {margin-left:24px;margin-right:24px}
			</style>-->	
			</head>
			<body class="browse">
<div id="preloadBg">
			<script type="text/javascript">		
					$("body").addClass("js");
			</script>
		</div>
				<div id="layout1">
					<div id="layout2" class="legToc">
						<!--<h1 class="pageTitle">
						<a href="{$linkPath}">
							<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title"/>
							</a>
						</h1>
						<div class="info" style="font-size:0.6em; font-weight:normal">
							<xsl:call-template name="startdate">
								<xsl:with-param name="element" select="/leg:Legislation"/>
							</xsl:call-template>
							<xsl:call-template name="commentary">
								<xsl:with-param name="element" select="/leg:Legislation"/>
							</xsl:call-template>
						</div>-->

						<div id="content">
							<div id="viewLegContents">
								<div class="LegSnippet" id="tocControlsAdded">
									<div class="LegContents LegClearFix">

										<!--<div id="ContentMain" class="LegSnippet">-->
										<xsl:variable name="docPath" select="concat('/', substring-before($paramsDoc/parameters/path, '/contents'))"/>
										<!--<div class="LegContentsWhole">
											<p class="LegTitle">
												<a href="{$linkPath}">
													<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title"/>
												</a>
											</p>
											<div class="info" style="font-size:0.6em; font-weight:normal">
												<xsl:call-template name="startdate">
													<xsl:with-param name="element" select="/leg:Legislation"/>
												</xsl:call-template>
												<xsl:call-template name="commentary">
													<xsl:with-param name="element" select="/leg:Legislation"/>
												</xsl:call-template>
											</div>
										</div>-->
											
											<ol>
											<li class="LegContentsEntry">
													<p class="LegContentsHeading LegClearFix">
														<span class="LegDS LegContentsTitle">
															<a href=".">
							<xsl:value-of select="/leg:Legislation/ukm:Metadata/dc:title"/>
							</a>
														</span>
													</p>
													<div class="info">
							<xsl:call-template name="startdate">
								<xsl:with-param name="element" select="/leg:Legislation"/>
							</xsl:call-template>
							<xsl:call-template name="commentary">
								<xsl:with-param name="element" select="/leg:Legislation"/>
							</xsl:call-template>
						</div>
												</li>
											<ol>
											
												<li class="LegContentsEntry">
													<p class="LegContentsItem LegClearFix">
														<span class="LegDS LegContentsTitle">
															<a href="{tso:GenTocLink('introduction')}">Introductory Text</a>
														</span>
													</p>
													<div class="info">
													<xsl:call-template name="startdate">
														<xsl:with-param name="element" select="/leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)/(leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims)"/>
													</xsl:call-template>
													<xsl:call-template name="commentary">
														<xsl:with-param name="element" select="/leg:Legislation/(leg:Primaryy | leg:Secondary | leg:EURetained)/(leg:PrimaryPrelims | leg:SecondaryPrelims | leg:EUPrelims)"/>
													</xsl:call-template>
												</div>
												</li>
												
											<!--<div class="LegContentsIntroduction">
												<p class="LegContentsIntroduction">
													<a href="{$linkPath}/introduction/{$pit}">Introductory Text</a>
												</p>
												
											</div>
											<div class="LegContentsBody">
												<p class="LegContentsBody">
													<a href="{$linkPath}/body/{$pit}">Main Body</a>
												</p>
												<div class="info">
													<xsl:call-template name="startdate">
														<xsl:with-param name="element" select="/leg:Legislation/leg:Primary/leg:Body"/>
													</xsl:call-template>
													<xsl:call-template name="commentary">
														<xsl:with-param name="element" select="/leg:Legislation/leg:Primary/leg:Body"/>
													</xsl:call-template>
												</div>
											</div>-->
											<li>
												
													<xsl:apply-templates select="/leg:Legislation/(leg:Primary | leg:Secondary | leg:EURetained)/*" mode="GenerateTOC"/>
												
											</li>
										</ol>
										</ol>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

			</body>
		</html>
	</xsl:template>

	<xsl:template  match="leg:Body" mode="GenerateTOC">
		<xsl:apply-templates select="*" mode="#current"/>
	</xsl:template>

	<xsl:template match="leg:Group | leg:Part | leg:Chapter | leg:Pblock | EUPart | EUTitle | EUChapter | EUSection | EUSubsection | Division" mode="GenerateTOC">
		<xsl:variable name="altdates" as="xs:date*" 
				select="for $a in tokenize(@AltDates,' ') 
						return (
							if ($a castable as xs:date) then xs:date($a) else ()
						)
				"/>
		<li class="LegClearFix LegContents{local-name()}">
			<p class="{if (self::leg:Pblock)  then 'LegContentsTitle' else 'LegContentsNo'}">
				<xsl:apply-templates select="leg:Number, leg:Title" mode="#current"/>
			</p>
			<div class="info">
				<xsl:call-template name="startdate">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
				<xsl:call-template name="commentary">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
			</div>
			<ol>
				<xsl:apply-templates select="*[not(self::leg:Number or self::leg:Title)]" mode="#current"/>
			</ol>
		</li>
	</xsl:template>

	<xsl:template match="leg:Group/leg:Number | leg:Part/leg:Number | leg:Chapter/leg:Number | EUPart/leg:Number | EUTitle/leg:Number | EUChapter/leg:Number | EUSection/leg:Number | EUSubsection/leg:Number | Division/leg:Number" mode="GenerateTOC">
		<span class="LegContentsNumber">
			<a href="{tso:GenTocLink(parent::*/@id)}">
				<xsl:apply-templates/>
			</a>
		</span>
	</xsl:template>

	<xsl:template match="leg:Pblock/leg:Number" mode="GenerateTOC">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="leg:Group/leg:Title | leg:Part/leg:Title | leg:Chapter/leg:Title | EUPart/leg:Title | EUTitle/leg:Title | EUChapter/leg:Title | EUSection/leg:Title | EUSubsection/leg:Title | Division/leg:Title" mode="GenerateTOC">
		<span class="LegContentsTitle">
			<a href="{tso:GenTocLink(parent::*/@id)}">
				<xsl:apply-templates/>
			</a>
		</span>
	</xsl:template>

	<xsl:template match="leg:Pblock/leg:Title" mode="GenerateTOC">
		<span class="LegContentsTitle">
			<a href="{tso:GenBlockTocLink(parent::*/@id)}">
				<xsl:apply-templates/>
			</a>
		</span>
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:Number" mode="GenerateTOC">
		<span class="LegContentsNumber">
			<a href="{tso:GenTocLink(parent::*/@id)}">
				<xsl:apply-templates/>
			</a>
		</span>
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:TitleBlock/leg:Title" mode="GenerateTOC">
		<span class="LegContentsTitle">
			<a href="{tso:GenTocLink(parent::*/parent::*/@id)}">
				<xsl:apply-templates/>
			</a>
		</span>
	</xsl:template>

	<xsl:template match="leg:P1group" mode="GenerateTOC">
		<li class="LegContentsEntry">
			<p>
				<a href="{tso:GenTocLink(leg:P1[1]/@id)}">
					<xsl:value-of select="leg:P1[1]/leg:Pnumber"/>
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="leg:Title"/>
					<xsl:if test="@RestrictExtent and $booIncludeExtent">
						<span class="LegExtentRestriction">
							<xsl:text> [</xsl:text>
							<xsl:value-of select="@RestrictExtent"/>
							<xsl:text>]</xsl:text>
						</span>
					</xsl:if>
				</a>
			</p>
			<div class="info">
				<xsl:call-template name="startdate">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
				<xsl:call-template name="commentary">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
			</div>
		</li>
		<xsl:if test="not(ancestor::leg:Version)">
			<xsl:apply-templates select="key('versions', tokenize(@AltVersionRefs, ' '))/*" mode="GenerateTOC"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:P1[not(parent::leg:P1group)]" mode="GenerateTOC">
		<li class="LegContentsEntry">
			<p>
				<a href="{tso:GenTocLink(@id)}">
					<xsl:value-of select="leg:Pnumber"/>
					<xsl:text>. </xsl:text>
					<xsl:apply-templates select="leg:Title"/>
					<xsl:if test="@RestrictExtent and $booIncludeExtent">
						<span class="LegExtentRestriction">
							<xsl:text> [</xsl:text>
							<xsl:value-of select="@RestrictExtent"/>
							<xsl:text>]</xsl:text>
						</span>
					</xsl:if>
				</a>
			</p>
			<div class="info">
				<xsl:call-template name="startdate">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
				<xsl:call-template name="commentary">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
			</div>
		</li>
		<xsl:if test="not(ancestor::leg:Version)">
			<xsl:apply-templates select="key('versions', tokenize(@AltVersionRefs, ' '))/*" mode="GenerateTOC"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="leg:Schedules" mode="GenerateTOC">
		<li class="LegClearFix LegContentsSchedules">
			<p class="LegContentsHeading">
				<xsl:text>SCHEDULES</xsl:text>
			</p>
			<ol>
				<xsl:apply-templates select="*[not(self::leg:Title)]" mode="#current"/>
			</ol>
		</li>
	</xsl:template>

	<xsl:template match="leg:Schedule" mode="GenerateTOC">
		<li class="LegContentsSchedule">
			<p class="LegContentsNo">
				<xsl:apply-templates select="leg:Number, leg:TitleBlock" mode="#current"/>
			</p>
			<div class="info">
				<xsl:call-template name="startdate">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
				<xsl:call-template name="commentary">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
			</div>
			<ol>
				<xsl:apply-templates select="*[not(self::leg:Number or self::leg:TitleBlock)]" mode="#current"/>
			</ol>
		</li>
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:TitleBlock" mode="GenerateTOC">
		<xsl:apply-templates select="leg:Title" mode="#current"/>
	</xsl:template>

	<xsl:template match="leg:Schedule/leg:ScheduleBody" mode="GenerateTOC">
		<xsl:apply-templates mode="GenerateTOC"/>
	</xsl:template>

	<xsl:template match="*" mode="GenerateTOC"/>

	<xsl:function name="tso:GenTocLink" as="xs:string">
		<xsl:param name="id"/>
		<xsl:sequence select="replace($self, 'skeleton', translate($id, '-', '/'))"/>
	</xsl:function>

	<xsl:function name="tso:GenBlockTocLink" as="xs:string">
		<xsl:param name="id"/>
		<xsl:variable name="crossheadingURI">
			<xsl:value-of>
				<xsl:sequence select="translate(substring-before($id, 'crossheading-'), '-', '/')"/>
				<xsl:text>crossheading/</xsl:text>
				<xsl:sequence select="substring-after($id, 'crossheading-')" />
			</xsl:value-of>
		</xsl:variable>
		<xsl:sequence select="replace($self, 'skeleton', $crossheadingURI)"/>
	</xsl:function>

	<xsl:template name="startdate">
		<xsl:param name="element"/>
		<xsl:variable name="altdates" as="xs:date*" 
				select="for $a in tokenize($element/@AltDates,' ') 
						return (
							if ($a castable as xs:date) then xs:date($a) else ()
						)
				"/>
		<div class="LegAnnotations">
			<div class="LegAnnotationsHeading">Points in Time:</div>
			<p class="LegCommentaryPara">
				<xsl:variable name="inheritedRestrictStartDate" as="xs:date*" select="max(($element/descendant-or-self::*[not(@Match = 'false')]/@RestrictStartDate/xs:date(.)))"/>
				
							
				
				<xsl:text>Start Date: </xsl:text>
				<xsl:value-of select="	if ($element/@Match = 'false' and $element/@RestrictStartDate) then 
										concat('Valid from ', $element/@RestrictStartDate)
									else if ($element/@RestrictStartDate) then
										$element/@RestrictStartDate 
									else if ($element/@Match = 'false' and not($element/@RestrictStartDate) and $element/@Status = 'Prospective') then
										'prospective'
									else if (exists($inheritedRestrictStartDate)) then 
										concat(string($inheritedRestrictStartDate), ' - inherited')
									else 
										concat($basedate, ' - implied from base date')"/>
			</p>
			<p class="LegCommentaryPara">
				<xsl:text>Alt Dates: </xsl:text>
				<xsl:for-each select="$altdates">
					<xsl:sort select="."/>
					<a href="{string-join((substring-after($identifier, '/id'), 'skeleton',  xs:string(.), if (ends-with($self, 'revision')) then 'revision' else ()), '/')}">
						<xsl:sequence select="."/>
					</a>
					<xsl:text>&#160; &#160;</xsl:text>
				</xsl:for-each>
				<xsl:if test="matches($element/@AltDates, 'prospective')">
					<xsl:text>prospective</xsl:text>
				</xsl:if>
			</p>
			<p class="LegCommentaryPara">
				<xsl:variable name="inheritedExtent" select="$element/ancestor-or-self::*[@RestrictExtent][1]/@RestrictExtent"/>
				<xsl:text>Extent: </xsl:text>
				<xsl:value-of select="	if ($element/@RestrictExtent) then 
										$element/@RestrictExtent
									else concat($inheritedExtent, ' - inherited')"/>
			</p>
			<xsl:if test="$element/@ConfersPower">
				<p class="LegCommentaryPara">
					<xsl:text>Confers Power: true</xsl:text>
				</p>
			</xsl:if>
			<xsl:if test="$element/@BlanketAmendment">
				<p class="LegCommentaryPara">
					<xsl:text>Blanket Amendments: true</xsl:text>
				</p>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="commentary">
		<xsl:param name="element"/>
		<xsl:variable name="commentaryrefs" 
				select="if ($element instance of element(leg:P1group) or $element instance of element(leg:P1)) then 
							$element//leg:CommentaryRef/@Ref
						else $element/(leg:Number | leg:Title | leg:TitleBlock)//leg:CommentaryRef/@Ref"/>
		<xsl:if test="some $c in $commentaryrefs satisfies $commentaries//leg:Commentary[@id = $c][@Type='I']">
			<div class="LegAnnotations">
				<div class="LegAnnotationsHeading">Annotations:</div>
				<p class="LegAnnotationsGroupHeading">Commencement Information</p>
				<xsl:for-each select="distinct-values($commentaryrefs)">
					<xsl:variable name="commentary" select="$commentaries//leg:Commentary[@id = current()]"/>
					<xsl:if test="$commentary/@Type='I'">
						<div class="LegCommentaryItem" id="commentary-c737066">
							<p class="LegCommentaryPara">
								<span class="LegCommentaryType">
									<xsl:value-of select="$commentary/@Type"/>
									<xsl:value-of select="index-of($inotes, current())"/>
								</span>
								<span class="LegCommentaryText">
									<xsl:value-of select="$commentary"/>
								</span>
							</p>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>



		</xsl:if>



	</xsl:template>

	
	
	<xsl:function name="leg:base-date">
		<xsl:param name="type" as="xs:string"/>
		<xsl:sequence select="if ($type = ('NorthernIrelandOrderInCouncil', 'NorthernIrelandAct', 'NorthernIrelandParliamentAct')) then
								xs:date('2006-01-01')
							(:  we wont use the EU base date as such so choose the earliest date of 1957 when the EU was formed  :)
							else if ($type = ('EuropeanUnionRegulation', 'EuropeanUnionDecision', 'EuropeanUnionDirective', 'EuropeanUnionTreaty')) then
								xs:date('1957-01-01')
							else 
								xs:date('1991-02-01')"/>
	</xsl:function>


</xsl:stylesheet>
