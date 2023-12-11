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
	
<xsl:include href="edit-xml-common.xsl" />

<xsl:param name="tasks" as="element(leg:Tasks)?" select="if (doc-available('input:tasks')) then doc('input:tasks')/leg:Tasks else ()" />
<xsl:param name="task" as="xs:string?" select="if (doc-available('input:task')) then doc('input:task') else ()" />
<xsl:param name="slug" as="xs:string?" select="if (doc-available('input:slug')) then doc('input:slug') else ()" />
<xsl:param name="effects" as="node()*" select="if (doc-available('input:effects')) then doc('input:effects') else ()" />
<xsl:param name="server-name" as="xs:string" select="if (doc-available('input:server-name')) then doc('input:server-name') else ''" />
<xsl:param name="request-uri" as="xs:string" select="if (doc-available('input:request-uri')) then doc('input:request-uri') else ''" />
<xsl:param name="version" as="xs:string" select="if (doc-available('input:version')) then doc('input:version') else ''" />
<xsl:param name="parameters" as="element()?" select="if (doc-available('input:parameters')) then doc('input:parameters')/* else ()"/>
<xsl:param name="absolute-schema" as="xs:boolean" select="if (doc-available('input:absolute-schema')) then doc('input:absolute-schema') = 'true' else false()" />

<xsl:function name="tso:sourceUriBuilder">
	<xsl:value-of select="
		string-join((
			'https:/',
			$server-name,
			'task',
			$parameters/task,
			$parameters/subtask,
			'version'[$parameters/task='correct'],
			$parameters/type,
			$parameters/year,
			$parameters/number,
			$parameters/section,
			if(exists($version[.= 'prospective']) and $parameters/task='correct') then $version else $parameters/date,
			$slug[$parameters/task='correct']
		),'/')
	"/>
</xsl:function>

<xsl:template match="leg:Addition | leg:Repeal | leg:Substitution" priority="10">
	<xsl:variable name="others" as="element()+" select="key('change', @ChangeId)" />
	<xsl:variable name="first" as="element()" select="$others[1]" />
	<xsl:variable name="last" as="element()" select="$others[last()]" />
	<xsl:variable name="followingChangeElements" select="count(child::*[self::leg:Addition | self::leg:Repeal | self::leg:Substitution])" />
		
	<xsl:if test="((. is $first) and (not(ancestor::m:math or ancestor::math:math)))">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<!--  allowance for old sld retain text repeals where there is no explicit method to state that the text should be retained
					therefore deduce such a state from the descendant text nodes -->
			<xsl:if test="self::leg:Repeal and not(@RetainText) and (every $text in .//text() satisfies not(normalize-space(replace($text, '[\.\s]' , '')) = ''))">
				<xsl:attribute name="RetainText">true</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="Mark" select="'Start'" />
		</xsl:copy>
	</xsl:if>
	
	<xsl:apply-templates />
	
	<xsl:if test="((. is $last) and (not(ancestor::m:math or ancestor::math:math)))">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:attribute name="Mark" select="'End'" />
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="m:math|math:math" priority="20">
		
	<xsl:for-each select="descendant::*[self::leg:Addition | self::leg:Repeal | self::leg:Substitution]">		
		<xsl:variable name="others" as="element()+" select="key('change', @ChangeId)" />
		<xsl:variable name="first" as="element()" select="$others[1]" />		
		
		<xsl:if test="(. is $first)">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:attribute name="Mark" select="'Start'" />
				<xsl:if test="self::leg:Repeal and not(@RetainText) and (every $text in .//text() satisfies not(normalize-space(replace($text, '[\.\s]' , '')) = ''))">
					<xsl:attribute name="RetainText">true</xsl:attribute>
				</xsl:if>
			</xsl:copy>
		</xsl:if>		
		
	</xsl:for-each>
	
	<xsl:next-match/>
	
	<xsl:for-each select="descendant::*[self::leg:Addition | self::leg:Repeal | self::leg:Substitution]">		
		<xsl:sort select="position()" order="descending"/>
		<xsl:variable name="others" as="element()+" select="key('change', @ChangeId)" />		
		<xsl:variable name="last" as="element()" select="$others[last()]" />		
		
		<xsl:if test="(. is $last)">
			<xsl:copy>
				<xsl:copy-of select="@*" />
				<xsl:attribute name="Mark" select="'End'" />
			</xsl:copy>
		</xsl:if>
		
	</xsl:for-each>
	
</xsl:template>

<!--
<xsl:template match="err:*">
	<xsl:element name="err:{local-name(.)}">
		<xsl:apply-templates select="@*|node()" mode="#current" />
	</xsl:element>
</xsl:template>-->


<xsl:template match="leg:Citation/@URI | leg:CitationSubRef/@URI | leg:Citation/@UpTo | leg:CitationSubRef/@UpTo">
	<!--<xsl:if test="ancestor::leg:Tasks">-->
		<xsl:next-match />
	<!--</xsl:if>-->
</xsl:template>

<xsl:template match="@xsi:schemaLocation">
	<xsl:attribute name="xsi:schemaLocation">
		<xsl:text>http://www.legislation.gov.uk/namespaces/legislation </xsl:text>
		<xsl:text>http://</xsl:text>
		<xsl:value-of select="if (matches($server-name, 'localhost')) then 'editorial.test.legislation.gov.uk' else $server-name"/>				
		<xsl:text>/schema/fragment.rld</xsl:text>
    <!--<xsl:choose>
      <xsl:when test="$absolute-schema">http://<xsl:value-of select="$server-name" /></xsl:when>
        FM: temporarily serving the schema from legislation.gov.uk for TNA to test and confirm 
        We will need to put saperate URLs based on Staging & Test Legislation.gov.uk
      <xsl:when test="$absolute-schema">http://www.legislation.gov.uk</xsl:when>
			<xsl:otherwise>..</xsl:otherwise>
		</xsl:choose>-->
   <!-- <xsl:text>http://www.legislation.gov.uk/editorial</xsl:text>
    <xsl:choose>
      <xsl:when test="$DEVBOX or contains($server-name, 'test-editorial.legislation.gov.uk')">
        <xsl:text>/schema/test</xsl:text>
      </xsl:when>
      <xsl:when test="contains($server-name, 'staging-editorial.legislation.gov.uk')">
        <xsl:text>/schema/staging</xsl:text>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:text>/schema/fragment.rld</xsl:text>-->
	</xsl:attribute>
</xsl:template>

<!-- indent element-only content to make it easier to read -->
<!-- leave inline elements untouched - formatting may cause space issues if they are nested  -->
<xsl:template match="*[not(text()) and exists(*[not(self::err:* or self::leg:Addition or self::leg:Repeal or self::leg:Substitution or self::leg:Abbreviation  or self::leg:Acronym or self::leg:Proviso or self::leg:Definition or self::leg:Character or self::leg:Citation or self::leg:CitationSubRef or self::leg:CitationListRef  or self::leg:Emphasis or self::leg:ExternalLink or self::leg:FootnoteRef or self::leg:CommentaryRef or self::leg:Inferior or self::leg:InlineAmendment or self::leg:InternalLink or self::leg:MarginNoteRef or self::leg:SmallCaps or self::leg:Span or self::leg:Strong or self::leg:Superior or self::leg:Term or self::leg:Underline)])]">
	<xsl:variable name="contents" as="node()*">
		<xsl:apply-templates select="node()" mode="#current" />
	</xsl:variable>
	<xsl:copy>
		<xsl:apply-templates select="@*" mode="#current" />
		<xsl:if test="self::leg:Fragment">
			<xsl:namespace name="leg" select="'http://www.legislation.gov.uk/namespaces/legislation'"/>
		</xsl:if>
		<xsl:text>&#xA;</xsl:text>
		<xsl:for-each select="$contents">
			<xsl:sequence select="." />
			<xsl:text>&#xA;</xsl:text>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="self::leg:Fragment and exists($tasks/*)">
				<xsl:apply-templates select="$tasks" />
				<xsl:if test="exists($tasks)"><xsl:text>&#xA;</xsl:text></xsl:if>
			</xsl:when>
			<xsl:when test="self::ukm:Metadata and contains($request-uri, '/act/') and not($parameters/task='correct')">
				<dc:source>https://<xsl:value-of select="$server-name" /><xsl:value-of select="if (contains($request-uri,'/prov/data.xml')) then substring-before($request-uri,'/prov/data.xml') else substring-before($request-uri,'/data.xml')"/></dc:source>
			</xsl:when>
			<xsl:when test="self::ukm:Metadata and contains($request-uri, '/basedate/step')">
				<dc:source>https://<xsl:value-of select="$server-name" /><xsl:value-of select="if (contains($request-uri,'/prov/data.xml')) then substring-before($request-uri,'/prov/data.xml') else substring-before($request-uri,'/data.xml')"/></dc:source>
			</xsl:when>
			<xsl:when test="self::ukm:Metadata[parent::leg:Fragment] and $parameters/task[.='correct']">
				<dc:source><xsl:value-of select="tso:sourceUriBuilder()"/></dc:source>
			</xsl:when>
			<xsl:when test="self::ukm:Metadata[parent::leg:Fragment] and $parameters/task[.='correct']">
				<dc:source><xsl:value-of select="tso:sourceUriBuilder()"/></dc:source>
			</xsl:when>
			<xsl:when test="self::ukm:Metadata and ends-with(/leg:Fragment/@DocumentURI, '/revision')">
				<dc:source>https://<xsl:value-of select="$server-name" /><xsl:value-of select="if (exists($task) and $task = 'correct') then '/task/correct/legislation-provision/version/'  else if (contains($request-uri, 'welsh-')) then (if (contains($request-uri, 'review')) then '/task/review/update/welsh-step/' else '/task/update/welsh-step/') else if (contains($request-uri, 'review')) then '/task/review/update/step/' else '/task/update/step/'"/><xsl:value-of select="substring-before(substring-after(/leg:Fragment/@DocumentURI, 'http://www.legislation.gov.uk/'), '/revision')" /><xsl:value-of select="if (exists($version) and $task = 'correct' and $version = 'prospective') then '/prospective' else ()"/><xsl:value-of select="if (exists($slug) and $task = 'correct') then concat('/',$slug) else ()"/></dc:source>
			</xsl:when>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<xsl:template match="node()|@*">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="#current" />
	</xsl:copy>
</xsl:template>



</xsl:stylesheet>
