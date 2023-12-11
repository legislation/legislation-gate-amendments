<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:gate="http://www.gate.ac.uk"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	
	exclude-result-prefixes="xs gate leg tso dct dc atom ukm err xhtml">

<xsl:import href="../common/utils.xsl" /> 
<!--xsl:import href = "utils.xsl" />-->
<!--<xsl:import href = "toes.xsl" />-->

<xsl:key name="change" match="ukm:Changes//*[@id]" use="@id" />
<xsl:key name="legislationCitation" match="gate:Legislation | gate:LegRef" use="@id" />
<xsl:key name="action" match="ukm:Action" use="@id" />
<xsl:key name="location" match="gate:Location" use="@id" />

<xsl:variable name="g_affectingType" select="//ukm:Metadata//ukm:DocumentMainType/@Value"/>
<xsl:variable name="g_affectingYear" select="//ukm:Metadata//ukm:Year/@Value"/>
<xsl:variable name="g_affectingNumber" select="//ukm:Metadata//ukm:Number/@Value"/>

<xsl:variable name="DESeffects">
	<ukm:Effects><xsl:apply-templates select="/DesDocument/ukm:Changes//ukm:Effect"/></ukm:Effects>
</xsl:variable>

<xsl:template match="/">
	<xsl:apply-templates mode="Markup"/>
</xsl:template>

<xsl:template match="DesDocument"  mode="Markup">
	<xsl:apply-templates  mode="Markup"/>
</xsl:template>

<xsl:template match="ukm:Changes"  mode="Markup"/>

<xsl:template match="ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata"  mode="Markup" priority="999">
	<xsl:copy>
		<xsl:apply-templates select="node() | @*"  mode="Markup"/>
		<xsl:apply-templates select="following-sibling::ukm:Year" mode="Move" />
		<!-- issue with nia 2011/20 which ends up with duplicated effects as there are versions - get round this by only putting effects into the primary. -->
		<xsl:if test="not(ancestor::leg:Versions)">
			<xsl:call-template name="ProcessEffects"/>
			<xsl:variable name="enablingProvisions" as="element(EnablingProvision)*" select="/(GateDocument|DesDocument)/Changes//EnablingProvision" />
			<xsl:if test="exists($enablingProvisions)">
				<ukm:EnablingProvisions>
					<xsl:apply-templates select="$enablingProvisions" mode="Markup" />
				</ukm:EnablingProvisions>
			</xsl:if>
		</xsl:if>
	</xsl:copy>
</xsl:template>

<xsl:template match="node() | @*"  mode="Markup">
	<xsl:copy>
		<xsl:apply-templates select="node() | @*"  mode="Markup"/>
	</xsl:copy>
</xsl:template>

<xsl:template name="ProcessEffects">
	
	<ukm:EffectsBatch>
		<xsl:for-each-group select="$DESeffects//err:Error" group-by=".">
			<xsl:message>ERROR: <xsl:value-of select="."/></xsl:message>
			<xsl:sequence select="." />
		</xsl:for-each-group>
		<!--
			this si sorted by the AffectingURI 
			this was originally sorted by AffectedURI
			To change simply change the group-by attribute
		-->
		<xsl:for-each-group select="$DESeffects//(ukm:Effect|ukm:UndefinedEffect)" group-by="@AffectingURI">
			<xsl:sort select="current-grouping-key()"/>
			<xsl:choose>
				<xsl:when test="current-grouping-key() = ('', 'http://www.legislation.gov.uk/id')">
					<ukm:UndefinedEffects Id="{current-grouping-key()}">
						<xsl:sequence select="current-group()" />
					</ukm:UndefinedEffects>
				</xsl:when>
				<xsl:otherwise>
					<ukm:Effects Id="{current-grouping-key()}">
						<xsl:sequence select="current-group()" />
					</ukm:Effects>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</ukm:EffectsBatch>
</xsl:template>

<xsl:template match="ukm:Effect">
	<xsl:if test="empty(ukm:Action)">
		<xsl:message>ERROR: missing Action - see <xsl:value-of select="*[@id][1]/@id"/></xsl:message>
	</xsl:if>
	<xsl:variable name="Affecting" select="leg:processUri(ukm:AffectingProvision/ukm:Section[1]/@URI)"/>
	<xsl:variable name="Affected" select="leg:processUri(ukm:AffectedProvisions//ukm:Section[1]/@URI)"/>
	<ukm:Effect Applied="false" Action="{ukm:Action/@id}"
                           AffectingURI="{$Affecting/@URI}"
                           AffectedURI="{if (matches($Affected/@URI, 'http://www.legislation.gov.uk')) then $Affected/@URI else ()}"
                           Type="{leg:processEffectType(.)}"
							
                           AffectedCitationRef=""
                           >
		<xsl:attribute name="Ref">
			<xsl:text>e</xsl:text>
			<xsl:number count="ukm:Effect" level="any" format="00000" />
		</xsl:attribute>
		<xsl:attribute name="AdditionRef">
			<xsl:value-of select="if (ukm:Action) then ukm:Action/@id else ukm:Legislation/@id"/>
		</xsl:attribute>
		<xsl:attribute name="AffectingClass" select="if ($Affecting/ukm:Type/@Value != '') then $Affecting/ukm:Type/@Value else $g_affectingType"/>
		<xsl:attribute name="AffectingYear" select="if ($Affecting/ukm:Year/@Value != '') then $Affecting/ukm:Year/@Value else $g_affectingYear"/>
		<xsl:attribute name="AffectingNumber" select="if ($Affecting/ukm:Number/@Value != '') then $Affecting/ukm:Number/@Value else $g_affectingNumber"/>
		<xsl:if test="$Affecting/ukm:Section/@Value != ''">
			<xsl:attribute name="AffectingProvisions" select="$Affecting/ukm:Section/@Value"/>
		</xsl:if>
		<xsl:if test="$Affected/ukm:Type/@Value != ''">
			<xsl:attribute name="AffectedClass" select="$Affected/ukm:Type/@Value"/>
		</xsl:if>
		<xsl:if test="$Affected/ukm:Year/@Value != '' and $Affected/ukm:Year/@Value castable as xs:integer">
			<xsl:attribute name="AffectedYear" select="$Affected/ukm:Year/@Value"/>
		</xsl:if>
		<xsl:if test="$Affected/ukm:Number/@Value != '' and $Affected/ukm:Year/@Value castable as xs:integer">
			<xsl:attribute name="AffectedNumber" select="$Affected/ukm:Number/@Value"/>
		</xsl:if>
		<xsl:if test="$Affected/ukm:Name/@Value != ''">
			<xsl:attribute name="AffectedName" select="$Affected/ukm:Name/@Value"/>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="count(ukm:AffectedProvisions) = 1 and count(ukm:AffectedProvisions/ukm:Section) = 1">
				<xsl:variable name="processUri" select="leg:processUri(ukm:AffectedProvisions/ukm:Section/@URI)"/>
				<xsl:attribute name="AffectedProvisions">
					<xsl:value-of select="$processUri/ukm:Section/@Value"/>
					<xsl:value-of select="if ($processUri/ukm:Target/@Value != '') then concat(' ', $processUri/ukm:Target/@Value) else ()"/>
					<xsl:value-of select="if (@affectedExtra) then concat(' ', @affectedExtra) else ()"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="ukm:AffectedProvisions/ukm:Section">
				<!-- start the sequence -->
				<xsl:variable name="section-sequence">
					<xsl:for-each select="ukm:AffectedProvisions/ukm:Section">
						<xsl:sequence select="leg:processUri(@URI)"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="relativeSection" select="$section-sequence//ukm:metadata[1]"/>
				<xsl:variable name="relativeSectionFormat" select="leg:resolveFormatSection($relativeSection/@URI, $relativeSection/@section-id, '-')"/>
				<xsl:variable name="sub-sequence">
					<xsl:for-each select="$section-sequence//ukm:metadata[position() gt 1]">
						<xsl:value-of select="leg:resolveFormatSection(./@URI, ./@section-id, '-', $relativeSection/@section-id)"/>
					</xsl:for-each>
				</xsl:variable>
				<!-- if the sequence are independent provisions then seperate them -->
				<xsl:variable name="joinChar" select="if (starts-with($sub-sequence[1], '(')) then '' else ' '"/>
				<xsl:attribute name="AffectedProvisions">
					<xsl:sequence select="string-join(($relativeSectionFormat, $sub-sequence),$joinChar), if (@affectedExtra) then concat(' ', @affectedExtra) else ()"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="ukm:AffectedProvisions/ukm:SectionRange">
				<xsl:attribute name="AffectedProvisions" select="leg:processSectionRange(ukm:AffectedProvisions/ukm:SectionRange), if (@affectedExtra) then concat(' ', @affectedExtra) else ()"/>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
		<!-- DEBUG
			<xsl:attribute name="debug-AffectingSection" select="ukm:AffectingProvision/ukm:Section/@URI"/>
			<xsl:attribute name="debug-AffectedSection" select="ukm:AffectedProvisions/ukm:Section/@URI"/>
		 END DEBUG -->
	</ukm:Effect>					   
</xsl:template>


<xsl:function name="leg:processUri">
	<xsl:param name="uri" as="xs:string?"/>
	
	<xsl:variable name="regex" select="'/(sub-heading|cross-heading|heading|table|form|and-[a-z]+|(group|step|note)[/\w]*)$'"/>
	<xsl:variable name="isStructureComponent" select="matches($uri, $regex)"/>
	<!--<xsl:variable name="structureComponent" select="replace($uri,concat('^(.*)',$regex),'$2')"/>
	<xsl:variable name="target" select="if ($isStructureComponent) then translate($structureComponent, '/-', ' ') else ''"/>-->
	<xsl:variable name="resolveduri" select="replace($uri, $regex, '')"/>
	<xsl:variable name="targetRaw" select="if ($isStructureComponent) then translate(substring-after($uri, $resolveduri), '/-', ' ') else ''"/>
	<xsl:variable name="target" select="leg:processTarget($targetRaw)"/>
	<xsl:variable name="uri" select="if ($isStructureComponent) then $resolveduri else $uri"/>
	
	<xsl:variable name="stripuri" select="if (matches($uri, '/id/')) then substring-after($uri, '/id/') else (substring-after($uri, 'gov/'))"/>
	<xsl:variable name="tokens" select="tokenize($stripuri, '/')"/>
	<xsl:variable name="section-id" select="if (starts-with($uri, '/')) then replace(substring-after($uri, '/'), '/', '-') else string-join(($tokens[position() gt 3]), '-')"/>
	
	<!-- NOTE 
	
	Stephen to add the heading as /heading at the end of the uri 
	once this is done we will need to filter it out of the uri for processing and add in to the effectedProvision attr s.1 heading -->
	
	<xsl:choose>
		<xsl:when test="matches($uri, '/eut/')">
			<xsl:variable name="section" select="string-join(($tokens[position() gt 2]), '-')"/>
			<ukm:metadata URI="{if (exists($tokens[1]) and exists($tokens[2]) and exists($tokens[3])) then string-join(('http://www.legislation.gov.uk/id', $tokens[position() lt 4]), '/') else $uri}" section-id="{$section-id}">
				<ukm:Type Value="{if (exists($tokens[1])) then tso:getClass($tokens[1]) else ()}"/>
				<ukm:Year Value=""/>
				<ukm:Name Value="{$tokens[2]}"/>
				<ukm:Section Value="{leg:resolveFormatSection($uri, $section)}"/>
				<ukm:Target Value="{$target}" />
			</ukm:metadata>
		</xsl:when>
		<xsl:when test="matches($uri, '/id/') and not(matches($uri, '(ukpga|ukla|ukppa|gbla|gbppa|apgb|aep|aosp|asp|aip|apni|mnia|nia|ukcm|mwa|anaw|asc)/[0-9]{4}/[0-9]+')) and matches($uri, '(ukpga|ukla|ukppa|gbla|gbppa|apgb|aep|aosp|asp|aip|apni|mnia|nia|ukcm|mwa|anaw|asc)/([^/]+)/([^/]+)/([0-9]+)')">
			<xsl:message>Regnal year <xsl:value-of select="$uri"/></xsl:message>
			
			<xsl:variable name="section" select="string-join(($tokens[position() gt 4]), '-')"/>
			
			<ukm:metadata URI="{if (exists($tokens[1]) and exists($tokens[2]) and exists($tokens[3]) and exists($tokens[4])) then string-join(('http://www.legislation.gov.uk/id', $tokens[position() lt 5]), '/') else $uri}" section-id="{$section-id}">
				<ukm:Type Value="{if (exists($tokens[1])) then tso:getClass($tokens[1]) else ()}"/>
				<ukm:AlternativeNumber Value="{$tokens[3]}_{$tokens[2]}"/>
				<ukm:Number Value="{$tokens[4]}"/>
				<ukm:Section Value="{leg:resolveFormatSection($uri, $section)}"/>
				<ukm:Target Value="{$target}" />
			</ukm:metadata>
		</xsl:when>
		<xsl:when test="matches($uri, '/id/')">
			<xsl:variable name="section" select="string-join(($tokens[position() gt 3]), '-')"/>
			<ukm:metadata URI="{if (exists($tokens[1]) and exists($tokens[2]) and exists($tokens[3])) then string-join(('http://www.legislation.gov.uk/id', $tokens[position() lt 4]), '/') else $uri}" section-id="{$section-id}">
				<ukm:Type Value="{if (exists($tokens[1])) then tso:getClass($tokens[1]) else ()}"/>
				<ukm:Year Value="{$tokens[2]}"/>
				<ukm:Number Value="{$tokens[3]}"/>
				<ukm:Section Value="{leg:resolveFormatSection($uri, $section)}"/>
				<ukm:Target Value="{$target}" />
			</ukm:metadata>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="section" select="if (starts-with($uri, '/')) then replace(substring-after($uri, '/'), '/', '-') else replace($uri, '/', '-')"/>
			<ukm:metadata URI="{if (exists($tokens[1]) and exists($tokens[2]) and exists($tokens[3])) then string-join(('http://www.legislation.gov.uk/id', $tokens[position() lt 4]), '/') else $uri}" section-id="{$section-id}">
					<ukm:Section Value="{leg:resolveFormatSection($uri, $section)}"/>
					<ukm:Target Value="{$target}" />
				</ukm:metadata>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:resolveFormatSection">
	<xsl:param name="uri" as="xs:string?"/>
	<xsl:param name="section" as="xs:string?"/>
	<xsl:sequence select="leg:resolveFormatSection($uri, $section, '-', ())"/>
</xsl:function>

<xsl:function name="leg:resolveFormatSection">
	<xsl:param name="uri" as="xs:string?"/>
	<xsl:param name="section" as="xs:string?"/>
	<xsl:param name="token" as="xs:string?" />
	<xsl:sequence select="leg:resolveFormatSection($uri, $section, $token, ())"/>
</xsl:function>

<xsl:function name="leg:resolveFormatSection">
	<xsl:param name="uri" as="xs:string?"/>
	<xsl:param name="section" as="xs:string?"/>
	<xsl:param name="token" as="xs:string?" />
	<xsl:param name="relativeTo" as="xs:string?"/>
	
	<xsl:variable name="getSection" select="if (exists($section) and $section != '') then tso:formatSection($section, $token, $relativeTo) else $section"/>
	<xsl:choose>
		<xsl:when test="matches($section, 'signature|introduction')">
			<xsl:sequence select="concat(upper-case(substring($section, 1, 1)),substring($section, 2))"/>
		</xsl:when>
		<xsl:when test="empty($getSection)">
		</xsl:when>
		<xsl:when test="matches($uri, '/(eur|eudn|eudr|eut)/') and matches($getSection, 'art(s)?\.')">
			<xsl:sequence select="replace($getSection, 'art(s)?\.', 'Art$1.')"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$getSection"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:processProvision">
	<xsl:param name="section"/>
		<xsl:choose>
			<xsl:when test="matches($section, '^(regulation|section|rule|order|part|chapter|schedule|article|paragraph)', 'i')">
				<xsl:variable name="provs" select="tokenize($section, '-')"/>
				<xsl:value-of select="'reg. '"/>
				<xsl:value-of select="$provs[2]"/>
				<xsl:for-each select="$provs[position() gt 2]">
					<xsl:value-of select="concat('(', ., ')')"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$section"/></xsl:otherwise>
		</xsl:choose>
</xsl:function>

<xsl:function name="leg:processEffectType">
	<xsl:param name="effect" as="element(ukm:Effect)"/>
	<xsl:choose>
		<xsl:when test="$effect/ukm:SubstitutedProvisions/ukm:Section">
			<xsl:variable name="section-sequence">
				<xsl:for-each select="$effect/ukm:SubstitutedProvisions/ukm:Section">
					<xsl:sequence select="leg:processUri(@URI)"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="relativeSection" select="$section-sequence//ukm:metadata[1]"/>
			<xsl:variable name="relativeSectionFormat" select="leg:resolveFormatSection($relativeSection/@URI, $relativeSection/@section-id, '-')"/>
			<xsl:variable name="sub-sequence">
				<xsl:for-each select="$section-sequence//ukm:metadata[position() gt 1]">
					<xsl:value-of select="leg:resolveFormatSection(./@URI, ./@section-id, '-', $relativeSection/@section-id)"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$effect/@effectType = 'renumbered'">
					<xsl:variable name="affected-sequence">
						<xsl:for-each select="$effect/ukm:AffectedProvisions/ukm:Section">
							<xsl:sequence select="leg:processUri(@URI)"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="relativeAffectedSection" select="$affected-sequence//ukm:metadata[1]"/>
					<xsl:variable name="relativeAffectedSectionFormat" select="leg:resolveFormatSection($relativeAffectedSection/@URI, $relativeAffectedSection/@section-id, '-')"/>
					<xsl:variable name="affected-sub-sequence">
						<xsl:for-each select="$affected-sequence//ukm:metadata[position() gt 1]">
							<xsl:value-of select="leg:resolveFormatSection(./@URI, ./@section-id, '-', $relativeSection/@section-id)"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="string-join(($relativeSectionFormat, $sub-sequence, ' renumbered as ', $relativeAffectedSectionFormat, $affected-sub-sequence),'')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="string-join(('substituted for ', $relativeSectionFormat, $sub-sequence),'')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$effect/ukm:SubstitutedProvisions/ukm:SectionRange">
			<xsl:value-of select="concat('substituted for ', leg:processSectionRange($effect/ukm:SubstitutedProvisions/ukm:SectionRange))"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="lower-case($effect/@effectType)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:processSectionRange" as="xs:string">
	<xsl:param name="sectionRange" as="element(ukm:SectionRange)?"/>
	<xsl:variable name="section-from">
		<xsl:sequence select="leg:processUri($sectionRange/ukm:Section[1]/@URI)"/>
	</xsl:variable>
	<xsl:variable name="section-to">
		<xsl:variable name="section" select="leg:processUri($sectionRange/ukm:Section[2]/@URI)"/>
		<xsl:value-of select="if (exists($section//@section-id)) then leg:resolveFormatSection($section//@URI, $section//@section-id, '-', $section-from//@section-id) else ()"/>
	</xsl:variable>
	<xsl:sequence select="string-join(($section-from//ukm:Section/@Value, $section-to), '-')"/>
</xsl:function>

<xsl:function name="leg:processTarget" as="xs:string">
	<xsl:param name="target" as="xs:string"/>
	<xsl:choose>
		<xsl:when test="matches($target, 'sub[-\s]?heading')">
			<xsl:value-of select="'sub-heading'"/>
		</xsl:when>
		<xsl:when test="matches($target, 'cross[-\s]?heading')">
			<xsl:value-of select="'cross-heading'"/>
		</xsl:when>
		<xsl:when test="$target = '' or not(matches($target, 'table|group|step|note'))">
			<xsl:value-of select="$target"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="targettokens" select="tokenize($target, ' ')"/>
			<xsl:variable name="targetTransform" as="xs:string*">
				<xsl:for-each select="$targettokens">
					<xsl:choose>
						<xsl:when test=". = ('table', 'group', 'step', 'note')">
							<xsl:value-of select="concat(upper-case(substring(., 1, 1)),substring(., 2))"/>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:variable>
			<xsl:sequence select="string-join(($targetTransform), ' ')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:template match="Acronym">
	<xsl:apply-templates/>
</xsl:template>





<!-- ================================================ -->
<!-- ==============ORIGINAL PROCESSING=============== -->

<xsl:template match="ukm:Metadata//gate:*" mode="Markup" priority="10">
	<xsl:apply-templates mode="#current" />
</xsl:template>

<xsl:template match="@IdURI" mode="Markup" />

<xsl:template match="ukm:Year | ukm:Number | ukm:AlternativeNumber" mode="Move">
	<xsl:copy>
		<xsl:sequence select="@*" />
	</xsl:copy>
	<xsl:apply-templates mode="Move" />
</xsl:template>

<!-- uses the DES legislation element to idetnify effects -->
<!-- This currently resolves a bug where no Action element is added to the Effect -->
<xsl:template match="gate:Legislation" mode="Markup">
	<xsl:choose>
		<!-- we cannot render gate elements that are in the rows of a table
		for now we will ignore them -->
		<xsl:when test="parent::xhtml:tr">
			<xsl:apply-templates mode="#current" />
		</xsl:when>
		<xsl:when test="contains(@context, '/')">
			<xsl:variable name="refs" as="xs:string*" select="($DESeffects//ukm:Effect[@AdditionRef = current()/@id]/@Ref, @id)"/>
			<xsl:variable name="uriTokens" as="xs:string+" select="tokenize(@context, '/')" />
			<xsl:variable name="year" as="xs:string" select="$uriTokens[position() = last() - 1]" />
			<xsl:variable name="class" as="xs:string?" select="if (@type) then tso:getClass(@type) else ()" />
			<Citation id="{$refs[1]}" URI="{@context}" Class="{$class}" Number="{$uriTokens[position() = last()]}" markup="Gate">
				<xsl:if test="matches($year, '\d{4}')">
					<xsl:attribute name="Year" select="$year" />
				</xsl:if>
				<xsl:apply-templates mode="#current" />
			</Citation>
		</xsl:when>			
		<xsl:otherwise>
			<Span Class="legislation" markup="Gate" ><xsl:apply-templates mode="#current" /></Span>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- this will highlight legisaltion references with yellow background in pdf
<xsl:template match="gate:LegRef[contains(@uri, ',')]" mode="Markup">
	<xsl:variable name="parentCitation" as="element()?" select="gate:parentCitation(.)" />
	<Span Class="legaislation" markup="Gate">
		<xsl:choose>
			<xsl:when test="exists($parentCitation)">
				<xsl:apply-templates mode="#current">
					<xsl:with-param name="parentCitation" as="element()?" select="$parentCitation" tunnel="yes" />
					<xsl:with-param name="minorType" as="xs:string?" select="@minorType" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="#current" />
			</xsl:otherwise>
		</xsl:choose>
	</Span>
</xsl:template> -->

<xsl:template match="gate:Anaphor" mode="Markup">
	<Span>
		<xsl:apply-templates mode="#current" />
	</Span>
</xsl:template>

<!-- Main template for generating the boxed annotations in PDF/html -->
<xsl:template match="gate:Action" mode="Markup">
	<xsl:choose>
		<xsl:when test="$DESeffects//ukm:Effect[@AdditionRef = current()/@id]">
			<xsl:variable name="refs" as="xs:string*" select="$DESeffects//ukm:Effect[@AdditionRef = current()/@id]/@Ref"/>
			<Span markup="gate">
				<xsl:attribute name="id">
					<xsl:value-of select="$refs[1]" />
				</xsl:attribute>
				<xsl:apply-templates mode="#current" />
			</Span>
			<xsl:for-each select="$refs[position() gt 1]">
				<Span markup="gate">
					<xsl:attribute name="id">
						<xsl:value-of select="." />
					</xsl:attribute>
				</Span>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="#current" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="leg:InlineAmendment/gate:Quote" mode="Markup">
	<xsl:apply-templates mode="#current" />
</xsl:template>

<xsl:template match="gate:* | ukm:Metadata//gate:*" mode="Markup">
	<xsl:apply-templates mode="#current" />
</xsl:template>

<!-- Year sometimes appears in the wrong place -->
<xsl:template match="ukm:Metadata/ukm:Year" mode="Markup" />

<xsl:function name="gate:parentCitation" as="element()?">
	<xsl:param name="citation" as="element()" />
	<xsl:variable name="id" as="xs:string?" select="if ($citation instance of element(gate:SubLocation) or $citation instance of element(gate:SubLocationGroup)) then $citation/ancestor::gate:LegRef[1]/@id else $citation/@id" />
	<xsl:variable name="changeLegRef" as="element()?" select="key('change', $id, $citation/root())[1]" />
	<xsl:choose>
		<xsl:when test="empty($changeLegRef)">
			<xsl:choose>
				<xsl:when test="$citation/ancestor::leg:ComingIntoForce">
					<xsl:sequence select="$citation/root()/(DesDocument|GateDocument)/leg:Legislation" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>INFO: missing LegRef for <xsl:value-of select="$id" /></xsl:message>
					<xsl:sequence select="()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="count($changeLegRef) &gt; 1">
			<xsl:message>more than one LegRef for <xsl:value-of select="$id" /></xsl:message>
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:otherwise>
			
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>





</xsl:stylesheet>