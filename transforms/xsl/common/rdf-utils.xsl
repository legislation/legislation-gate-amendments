<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:time="http://www.w3.org/2006/time#"
	xmlns:void="http://rdfs.org/ns/void#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:sparql="http://www.w3.org/2005/sparql-results#"
	xmlns:trix="http://www.w3.org/2004/03/trix/trix-l/"
	xmlns:sioc="http://rdfs.org/sioc/ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/def/legislation/"
	xmlns:task="http://www.legislation.gov.uk/def/task/"
	xmlns:legacy="http://www.legislation.gov.uk/def/legacy/"
	xmlns:role="http://www.legislation.gov.uk/id/role/"
	xmlns:process="http://www.legislation.gov.uk/id/process/"
	exclude-result-prefixes="xs tso rdf rdfs dct time void owl sparql trix ukm leg task legacy sioc skos role">

<xsl:import href="utils.xsl" />

<xsl:variable name="rdf" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#'" />
<xsl:variable name="rdfs" select="'http://www.w3.org/2000/01/rdf-schema#'" />
<xsl:variable name="xsd" select="'http://www.w3.org/2001/XMLSchema#'" />

<xsl:variable name="sioc" select="'http://rdfs.org/sioc/ns#'" />
<xsl:variable name="void" select="'http://rdfs.org/ns/void#'" />
<xsl:variable name="skos" select="'http://www.w3.org/2004/02/skos/core#'" />

<xsl:variable name="leg" select="'http://www.legislation.gov.uk/def/legislation/'" />
<xsl:variable name="task" select="'http://www.legislation.gov.uk/def/task/'" />

<xsl:variable name="role:administrator" select="'http://www.legislation.gov.uk/id/role/administrator'" />
<xsl:variable name="role:superAdministrator" select="'http://www.legislation.gov.uk/id/role/superAdministrator'" />
<xsl:variable name="role:manager" select="'http://www.legislation.gov.uk/id/role/manager'" />
<xsl:variable name="role:queryAdministrator" select="'http://www.legislation.gov.uk/id/role/queryAdministrator'" />
	
<xsl:variable name="sioc:UserAccount" select="concat($sioc, 'UserAccount')" />
<xsl:variable name="sioc:Post" select="concat($sioc, 'Post')" />
<xsl:variable name="task:logEntry" select="concat($task, 'logEntry')" />
<xsl:variable name="sioc:Usergroup" select="concat($sioc, 'Usergroup')" />
<xsl:variable name="sioc:Role" select="concat($sioc, 'Role')" />
	
	
<xsl:variable name="skos:Collection" select="concat($skos, 'Collection')" />

<xsl:variable name="leg:database" select="'http://www.legislation.gov.uk/id/user/legislation.gov.uk/database'" />

<xsl:variable name="void:Dataset" select="concat($void, 'Dataset')" />

<xsl:variable name="leg:LegislationList" select="concat($leg, 'LegislationList')" />
<xsl:variable name="leg:LegislationListItem" select="concat($leg, 'LegislationListItem')" />

<xsl:variable name="leg:Legislation" select="concat($leg, 'Legislation')" />
<xsl:variable name="leg:CommencementOrder" select="concat($leg, 'CommencementOrder')" />
<xsl:variable name="leg:NonPrint" select="concat($leg, 'NonPrint')" />

<xsl:variable name="leg:Introduction" select="concat($leg, 'Introduction')" />
<xsl:variable name="leg:Schedule" select="concat($leg, 'Schedule')" />
<xsl:variable name="leg:Part" select="concat($leg, 'Part')" />
<xsl:variable name="leg:Chapter" select="concat($leg, 'Chapter')" />
<xsl:variable name="leg:Crossheading" select="concat($leg, 'Crossheading')" />
<xsl:variable name="leg:Provision" select="concat($leg, 'Provision')" />
<xsl:variable name="leg:Section" select="concat($leg, 'Section')" />
<xsl:variable name="leg:Article" select="concat($leg, 'Article')" />
<xsl:variable name="leg:Regulation" select="concat($leg, 'Regulation')" />
<xsl:variable name="leg:Rule" select="concat($leg, 'Rule')" />
<xsl:variable name="leg:Paragraph" select="concat($leg, 'Paragraph')" />
<xsl:variable name="leg:IntroductionInterpretation" select="concat($leg, 'IntroductionInterpretation')" />
<xsl:variable name="leg:PartInterpretation" select="concat($leg, 'PartInterpretation')" />
<xsl:variable name="leg:ChapterInterpretation" select="concat($leg, 'ChapterInterpretation')" />
<xsl:variable name="leg:CrossheadingInterpretation" select="concat($leg, 'CrossheadingInterpretation')" />
<xsl:variable name="leg:ProvisionInterpretation" select="concat($leg, 'ProvisionInterpretation')" />
<xsl:variable name="leg:SectionInterpretation" select="concat($leg, 'SectionInterpretation')" />
<xsl:variable name="leg:ArticleInterpretation" select="concat($leg, 'ArticleInterpretation')" />
<xsl:variable name="leg:RegulationInterpretation" select="concat($leg, 'RegulationInterpretation')" />
<xsl:variable name="leg:RuleInterpretation" select="concat($leg, 'RuleInterpretation')" />
<xsl:variable name="leg:ParagraphInterpretation" select="concat($leg, 'ParagraphInterpretation')" />

<xsl:variable name="leg:provisionTypes" as="xs:string+" select="($leg:Paragraph, $leg:Section, $leg:Article, $leg:Regulation, $leg:Rule, $leg:Provision)" />

<xsl:variable name="leg:highlevelTypes" as="xs:string+" select="($leg:Introduction, $leg:Schedule, $leg:Part, $leg:Chapter, $leg:Crossheading, $leg:provisionTypes, $leg:Legislation)" />

<xsl:variable name="leg:DatedInterpretation" select="concat($leg, 'DatedInterpretation')" />
<xsl:variable name="leg:OriginalInterpretation" select="concat($leg, 'OriginalInterpretation')" />
<xsl:variable name="leg:ProspectiveInterpretation" select="concat($leg, 'ProspectiveInterpretation')" />

<xsl:variable name="leg:Range" select="concat($leg, 'Range')" />

<xsl:variable name="leg:NorthernIrelandNumber" select="concat($leg, 'NorthernIrelandNumber')" />
<xsl:variable name="leg:CommencementNumber" select="concat($leg, 'CommencementNumber')" />

<xsl:variable name="leg:affecting-extent" select="concat($leg, 'affecting-extent')" />
<xsl:variable name="leg:coextensive" select="concat($leg, 'coextensive')" />

<xsl:variable name="leg:prospective" select="concat($leg, 'prospective')" />
<xsl:variable name="leg:royal-assent-date" select="concat($leg, 'royal-assent-date')" />
<xsl:variable name="leg:wholly-in-force" select="concat($leg, 'wholly-in-force')" />
<xsl:variable name="leg:remainder-in-force" select="concat($leg, 'remainder-in-force')" />
<xsl:variable name="leg:specified-purposes" select="concat($leg, 'specified-purposes')" />
<xsl:variable name="leg:retrospective-in-force" select="concat($leg, 'retrospective-in-force')" />

<xsl:variable name="leg:specified-provisions" select="concat($leg, 'specified-provisions')" />
<xsl:variable name="leg:unspecified-table-entries" select="concat($leg, 'unspecified-table-entries')" />
<xsl:variable name="leg:with-effect" select="concat($leg, 'with-effect')" />
<xsl:variable name="leg:with-application" select="concat($leg, 'with-application')" />
<xsl:variable name="leg:gazette-commencement" select="concat($leg, 'gazette-commencement')" />
<xsl:variable name="leg:specifying-with-effect" select="concat($leg, 'specifying-with-effect')" />

<xsl:variable name="leg:primary-effects" select="concat($leg, 'primary-effects')" />
<xsl:variable name="leg:secondary-effects" select="concat($leg, 'secondary-effects')" />
<xsl:variable name="leg:eu-effects" select="concat($leg, 'eu-effects')" />
<xsl:variable name="leg:no-primary-effects" select="concat($leg, 'no-primary-effects')" />
<xsl:variable name="leg:no-secondary-effects" select="concat($leg, 'no-secondary-effects')" />
<xsl:variable name="leg:no-eu-effects" select="concat($leg, 'no-eu-effects')" />
	
<xsl:variable name="leg:ResearchResult" select="concat($leg, 'ResearchResult')" />
<xsl:variable name="leg:EffectsSummary" select="concat($leg, 'EffectsSummary')" />
<xsl:variable name="leg:ExtentAssignment" select="concat($leg, 'ExtentAssignment')" />
<xsl:variable name="leg:EffectExtentAssignment" select="concat($leg, 'EffectExtentAssignment')" />
<xsl:variable name="leg:TerritoryAssignment" select="concat($leg, 'TerritoryAssignment')" />
<xsl:variable name="leg:Commencement" select="concat($leg, 'Commencement')" />

<xsl:variable name="leg:CommencementScope" select="concat($leg, 'CommencementScope')" />
<xsl:variable name="leg:TableEntriesCommencementScope" select="concat($leg, 'TableEntriesCommencementScope')" />
<xsl:variable name="leg:ProvisionsCommencementScope" select="concat($leg, 'ProvisionsCommencementScope')" />
<xsl:variable name="leg:WithEffectCommencementScope" select="concat($leg, 'WithEffectCommencementScope')" />
<xsl:variable name="leg:WithApplicationCommencementScope" select="concat($leg, 'WithApplicationCommencementScope')" />
<xsl:variable name="leg:GazetteCommencementScope" select="concat($leg, 'GazetteCommencementScope')" />

<xsl:variable name="leg:Effect" select="concat($leg, 'Effect')" />
<xsl:variable name="leg:Amendment" select="concat($leg, 'Amendment')" />
<xsl:variable name="leg:TextualAmendment" select="concat($leg, 'TextualAmendment')" />
<xsl:variable name="leg:Repeal" select="concat($leg, 'Repeal')" />
<xsl:variable name="leg:Substitution" select="concat($leg, 'Substitution')" />
<xsl:variable name="leg:Insertion" select="concat($leg, 'Insertion')" />
<xsl:variable name="leg:NonTextualAmendment" select="concat($leg, 'NonTextualAmendment')" />
<xsl:variable name="leg:HavingEffectAsSpecified" select="concat($leg, 'HavingEffectAsSpecified')" />


<xsl:variable name="leg:welshType" as="xs:string+">
	<xsl:sequence select="('WelshStatutoryInstrument', 'WelshAssemblyMeasure','WelshNationalAssemblyAct','WelshParliamentAct')"/>
</xsl:variable>
	
<xsl:variable name="task:Task" select="concat($task, 'Task')" />
<xsl:variable name="task:Stage" select="concat($task, 'Stage')" />
<xsl:variable name="task:Assignment" select="concat($task, 'Assignment')" />
<xsl:variable name="task:Query" select="concat($task, 'Query')" />

<xsl:key name="descriptions" match="*[@rdf:about]" use="@rdf:about" />
<xsl:key name="nodeID" match="*[@rdf:nodeID and not(parent::*/(@rdf:about or @rdf:nodeID))]" use="@rdf:nodeID" />

<xsl:key name="notes" match="rdf:Description[sioc:about]" use="sioc:about/@rdf:resource" />
<xsl:key name="research" match="rdf:Description" use="leg:affected/@rdf:resource" />

<xsl:template match="rdf:Description" mode="legislationLink">
	<xsl:param name="link" as="xs:string" select="substring-after(@rdf:about, 'http://www.legislation.gov.uk')" />
	<a href="{$link}">
		<xsl:apply-templates select="." mode="legislationTitle" />
	</a>
</xsl:template>

<xsl:template match="rdf:Description[leg:year and leg:number]" mode="legislationTitle" priority="10">
	<xsl:param name="lang" as="xs:string" select="'en'" />
	<xsl:choose>
		<xsl:when test="leg:title">
			<xsl:apply-templates select="(leg:title[lower-case(@xml:lang) = $lang], leg:title[empty(@xml:lang)], leg:title)[1]" mode="legislationTitle" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="leg:year[1]" />
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:value-of select="tso:GetNumberForLegislation(leg:legislationType(.), leg:year[1], leg:number[1])" />
</xsl:template>

<xsl:template match="leg:title" mode="legislationTitle">
	<xsl:value-of select="." />
	<xsl:if test="not(ends-with(., ../leg:year[1]))">
		<xsl:text> </xsl:text>
		<xsl:value-of select="../leg:year[1]" />
	</xsl:if>
</xsl:template>

<xsl:template match="rdf:Description[leg:title]" mode="legislationTitle" priority="5">
	<xsl:param name="lang" as="xs:string" select="'en'" />
	<xsl:if test="exists(leg:structureNumber)">
		<xsl:value-of select="leg:structureNumber" />
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:value-of select="(leg:title[lower-case(@xml:lang) = $lang], leg:title[empty(@xml:lang)], leg:title)[1]" />
</xsl:template>

<xsl:template match="rdf:Description[leg:citation]" mode="legislationTitle" priority="4">
	<xsl:value-of select="leg:citation[1]" />
</xsl:template>

<xsl:template match="rdf:Description[rdfs:label]" mode="legislationTitle">
	<xsl:value-of select="rdfs:label" />
</xsl:template>

<xsl:template match="rdf:Description" mode="legislationTitle">
	<xsl:variable name="type" as="xs:string*" select="rdf:type/@rdf:resource" />
	<xsl:variable name="type" select="substring-after($type[1], $leg)" />
	<xsl:choose>
		<xsl:when test="ends-with($type, 'Interpretation')">
			<xsl:value-of select="substring-before($type, 'Interpretation')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$type[1]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="rdf:Description[leg:year and leg:number]" mode="legislationCitation" priority="10">
	<xsl:param name="lang" as="xs:string" select="'en'" />
	<xsl:value-of select="tso:GetShortCitation(leg:legislationType(.), leg:year[1], leg:number[1])" />
</xsl:template>

<xsl:template match="rdf:Description[leg:citation]" mode="legislationCitation" priority="5">
	<xsl:value-of select="leg:citation[1]" />
</xsl:template>

<xsl:template match="rdf:Description[rdfs:label]" mode="legislationCitation" priority="4">
	<xsl:value-of select="rdfs:label[1]" />
</xsl:template>

<xsl:template match="rdf:Description[rdf:type/@rdf:resource = $leg:Range]" mode="legislationCitation" priority="3">
	<xsl:apply-templates select="rdf:get(., xs:QName('leg:start'))" mode="legislationCitation" />
	<xsl:text> - </xsl:text>
	<xsl:apply-templates select="rdf:get(., xs:QName('leg:end'))" mode="legislationCitation" />
</xsl:template>

<xsl:template match="rdf:Description[leg:legislation]" mode="legislationCitation" priority="2">
	<xsl:sequence select="tso:formatSection(substring-after(@rdf:about, concat(leg:legislation/@rdf:resource, '/')), '/')" />
</xsl:template>

<xsl:template match="rdf:Description" mode="legislationCitation">
	<xsl:apply-templates select="." mode="legislationTitle" />
</xsl:template>

<xsl:template match="rdf:Description" mode="legislationSubject">
	<xsl:variable name="subjects" as="element(rdf:Description)*" select="rdf:get(., xs:QName('leg:subject'))" />
	<xsl:variable name="SIFgroup" as="element(rdf:Description)*" select="$subjects[rdf:type/@rdf:resource = 'http://www.legislation.gov.uk/def/sif-group/Group']" />
	<xsl:value-of select="$SIFgroup/skos:prefLabel" separator=" / " />
</xsl:template>

<xsl:template match="rdf:Description[leg:pages]" mode="legislationSize">
	<xsl:value-of select="leg:pages" /> pages
</xsl:template>

<xsl:template match="rdf:Description" mode="legislationSize">
	<xsl:value-of select="tso:GetFileSize(leg:size)" />
</xsl:template>

<xsl:template match="sparql:binding" mode="rdf:toTriX">
	<xsl:apply-templates mode="rdf:toTriX" />
</xsl:template>

<xsl:template match="sparql:uri" mode="rdf:toTriX">
	<trix:uri>
		<xsl:value-of select="." />
	</trix:uri>
</xsl:template>

<xsl:template match="sparql:literal[@datatype]" mode="rdf:toTriX">
	<trix:typedLiteral datatype="{@datatype}">
		<xsl:value-of select="." />
	</trix:typedLiteral>
</xsl:template>

<xsl:template match="sparql:literal" mode="rdf:toTriX">
	<trix:plainLiteral>
		<xsl:sequence select="@xml:lang" />
		<xsl:value-of select="." />
	</trix:plainLiteral>
</xsl:template>

<xsl:template match="sparql:bnode" mode="rdf:toTriX">
	<trix:id>
		<xsl:value-of select="." />
	</trix:id>
</xsl:template>

<xsl:template match="*[@rdf:about]" mode="rdf:toTriX">
	<xsl:variable name="subject" as="xs:string" select="@rdf:about" />
	<xsl:for-each select="*">
		<trix:triple>
			<trix:uri><xsl:value-of select="$subject" /></trix:uri>
			<trix:uri><xsl:value-of select="concat(namespace-uri(.), local-name(.))" /></trix:uri>
			<xsl:apply-templates select="." mode="rdf:toTriX" />
		</trix:triple>
	</xsl:for-each>
	<xsl:apply-templates select="*/*[@rdf:about]" mode="rdf:toTriX" />
</xsl:template>

<xsl:template match="*[@rdf:resource]" mode="rdf:toTriX">
	<trix:uri>
		<xsl:value-of select="@rdf:resource" />
	</trix:uri>
</xsl:template>

<xsl:template match="*[@rdf:datatype]" mode="rdf:toTriX">
	<trix:typedLiteral datatype="{@rdf:datatype}">
		<xsl:value-of select="." />
	</trix:typedLiteral>
</xsl:template>

<xsl:template match="*[*/@rdf:about]" mode="rdf:toTriX">
	<trix:uri>
		<xsl:value-of select="*/@rdf:about" />
	</trix:uri>
</xsl:template>

<xsl:template match="*" mode="rdf:toTriX">
	<trix:plainLiteral>
		<xsl:sequence select="@xml:lang" />
		<xsl:value-of select="." />
	</trix:plainLiteral>
</xsl:template>

<!-- NOTE: this conversion from RDF/XML only supports a very simple, flattened version of RDF/XML -->
<xsl:template match="rdf:Description" mode="rdf:toTurtle">
	<xsl:apply-templates mode="rdf:toTurtle">
		<xsl:with-param name="subject" select="@rdf:about" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="rdf:toTurtle">
	<xsl:param name="subject" as="xs:string?" required="yes" />
	<xsl:param name="nested" as="xs:boolean" select="false()" />
	<xsl:if test="not($nested)">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="rdf:turtleEscapeURI($subject)" />
		<xsl:text>&gt;</xsl:text>
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="rdf:turtleEscapeURI(concat(namespace-uri(.), local-name(.)))" />
	<xsl:text>&gt;</xsl:text>
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@rdf:resource">
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="rdf:turtleEscapeURI(@rdf:resource)" />
			<xsl:text>&gt;</xsl:text>
		</xsl:when>
		<xsl:when test="*/@rdf:about">
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="rdf:turtleEscapeURI(*/@rdf:about)" />
			<xsl:text>&gt;</xsl:text>
		</xsl:when>
		<xsl:when test="@rdf:parseType = 'Literal'">
			<xsl:text>"""</xsl:text>
			<xsl:apply-templates mode="rdf:xmlLiteral" />
			<xsl:text>"""^^&lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral&gt;</xsl:text>
		</xsl:when>
		<xsl:when test="*">
			<xsl:text>[ </xsl:text>
			<xsl:if test="node-name(*) != xs:QName('rdf:Description')">
				<xsl:text>a &lt;</xsl:text>
				<xsl:value-of select="rdf:turtleEscapeURI(concat(namespace-uri(*), local-name(*)))" />
				<xsl:text>&gt; ; </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="*/*" mode="rdf:toTurtle">
				<xsl:with-param name="subject" select="()" />
				<xsl:with-param name="nested" select="true()" />
			</xsl:apply-templates>
			<xsl:text> ]</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>"""</xsl:text>
			<xsl:value-of select="rdf:turtleEscapeString(.)" />
			<xsl:text>"""</xsl:text>
			<xsl:choose>
				<xsl:when test="@rdf:datatype">
					<xsl:text>^^&lt;</xsl:text>
					<xsl:value-of select="rdf:turtleEscapeURI(@rdf:datatype)" />
					<xsl:text>&gt;</xsl:text>
				</xsl:when>
				<xsl:when test="@xml:lang">
					<xsl:text>@</xsl:text>
					<xsl:value-of select="@xml:lang" />
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$nested"> ; </xsl:when>
		<xsl:otherwise> . </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="trix:triple" mode="rdf:toTurtle">
	<xsl:apply-templates select="trix:*[1]" mode="rdf:toTurtle" />
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="trix:*[2]" mode="rdf:toTurtle" />
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="trix:*[3]" mode="rdf:toTurtle" />
	<xsl:text> . </xsl:text>
</xsl:template>

<xsl:template match="trix:uri" mode="rdf:toTurtle">
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="rdf:turtleEscapeURI(.)" />
	<xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="trix:id" mode="rdf:toTurtle">
	<xsl:text>_:</xsl:text>
	<xsl:value-of select="." />
</xsl:template>

<xsl:template match="trix:typedLiteral" mode="rdf:toTurtle">
	<xsl:text>"""</xsl:text>
	<xsl:value-of select="rdf:turtleEscapeString(.)" />
	<xsl:text>"""</xsl:text>
	<xsl:text>^^&lt;</xsl:text>
	<xsl:value-of select="rdf:turtleEscapeURI(@datatype)" />
	<xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="trix:plainLiteral" mode="rdf:toTurtle">
	<xsl:text>"""</xsl:text>
	<xsl:value-of select="rdf:turtleEscapeString(.)" />
	<xsl:text>"""</xsl:text>
	<xsl:if test="@xml:lang">
		<xsl:text>@</xsl:text>
		<xsl:value-of select="@xml:lang" />
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="rdf:xmlLiteral">
	<xsl:param name="namespaces" as="node()*" select="()" />
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="name()" />
	<xsl:for-each select="namespace::*">
		<xsl:variable name="prefix" as="xs:string" select="name()" />
		<xsl:variable name="value" as="xs:string" select="." />
		<xsl:if test="empty($namespaces[name() = $prefix and . = $value])">
			<xsl:text> xmlns:</xsl:text>
			<xsl:value-of select="$prefix" />
			<xsl:text>="</xsl:text>
			<xsl:value-of select="rdf:xmlLiteralEscape($value, true())" />
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:for-each>
	<xsl:apply-templates select="@*" mode="rdf:xmlLiteral" />
	<xsl:choose>
		<xsl:when test="node()">
			<xsl:text>&gt;</xsl:text>
			<xsl:apply-templates mode="rdf:xmlLiteral">
				<xsl:with-param name="namespaces" select="$namespaces | namespace::*" />
			</xsl:apply-templates>
			<xsl:text>&lt;/</xsl:text>
			<xsl:value-of select="name()" />
			<xsl:text>&gt;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text> /&gt;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@*" mode="rdf:xmlLiteral">
	<xsl:text> </xsl:text>
	<xsl:value-of select="name()" />
	<xsl:text>="</xsl:text>
	<xsl:sequence select="rdf:xmlLiteralEscape(., true())" />
	<xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="text()" mode="rdf:xmlLiteral">
	<xsl:sequence select="rdf:xmlLiteralEscape(., false())" />
</xsl:template>

<xsl:template match="comment()" mode="rdf:xmlLiteral">
	<xsl:text>&lt;--</xsl:text>
	<xsl:value-of select="rdf:turtleEscape(.)" />
	<xsl:text>--&gt;</xsl:text>
</xsl:template>

<xsl:template match="processing-instruction()" mode="rdf:xmlLiteral">
	<xsl:text>&lt;?</xsl:text>
	<xsl:value-of select="name()" />
	<xsl:text> </xsl:text>
	<xsl:value-of select="rdf:turtleEscape(.)" />
	<xsl:text>?&gt;</xsl:text>
</xsl:template>

<xsl:function name="rdf:xmlLiteralEscape">
	<xsl:param name="string" as="xs:string" />
	<xsl:param name="escapeAll" as="xs:boolean" />
	<xsl:variable name="string" select="replace($string, '&amp;', '&amp;amp;')" />
	<xsl:variable name="string" select="replace($string, '&lt;', '&amp;lt;')" />
	<xsl:variable name="string" select="if ($escapeAll) then replace($string, '&gt;', '&amp;gt;') else $string" />
	<xsl:variable name="string" select="if ($escapeAll) then replace($string, '''', '&amp;apos;') else $string" />
	<xsl:variable name="string" select="if ($escapeAll) then replace($string, '&quot;', '&amp;quot;') else $string" />
	<xsl:sequence select="rdf:turtleEscape($string)" />
</xsl:function>

<xsl:function name="rdf:turtleEscape">
	<xsl:param name="string" as="xs:string" />
	<xsl:variable name="string" select="replace($string, '\\', '\\\\')" />
	<xsl:variable name="string" select="replace($string, '&#xD;', '\\r')" />
	<xsl:variable name="string" select="replace($string, '&#xA;', '\\n')" />
	<xsl:variable name="string" select="replace($string, '&#x9;', '\\t')" />
	<xsl:sequence select="$string" />
</xsl:function>

<xsl:function name="rdf:turtleEscapeURI">
	<xsl:param name="uri" as="xs:string" />
	<xsl:variable name="uri" select="rdf:turtleEscape($uri)" />
	<xsl:variable name="uri" select="replace($uri, '&gt;', '\\&gt;')" />
	<xsl:sequence select="$uri" />
</xsl:function>

<xsl:function name="rdf:turtleEscapeString">
	<xsl:param name="string" as="xs:string" />
	<xsl:variable name="string" select="rdf:turtleEscape($string)" />
	<xsl:variable name="string" select="replace($string, '&quot;', '\\&quot;')" />
	<xsl:sequence select="$string" />
</xsl:function>

<xsl:function name="rdf:get" as="element()*">
	<xsl:param name="descriptions" as="element()*" />
	<xsl:param name="propertyChain" as="xs:QName+" />
	<xsl:variable name="properties" as="element()*" select="$descriptions/*[node-name(.) = $propertyChain[1]]" />
	<xsl:variable name="values" as="element()*">
		<xsl:for-each select="$properties">
			<xsl:choose>
				<xsl:when test="@rdf:resource">
					<xsl:sequence select="key('descriptions', @rdf:resource, root())" />
				</xsl:when>
				<xsl:when test="@rdf:nodeID">
					<xsl:sequence select="key('nodeID', @rdf:nodeID, root())" />
				</xsl:when>
				<xsl:when test="*[@rdf:about or @rdf:nodeID]">
					<xsl:sequence select="*" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="values" as="element()*" select="$values | $values" />
	<xsl:choose>
		<xsl:when test="exists($values) and count($propertyChain) > 1">
			<xsl:sequence select="rdf:get($values, subsequence($propertyChain, 2))" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$values" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- this returns an element so the results can be cast implicitly -->
<xsl:function name="sparql:binding" as="element()?">
	<xsl:param name="result" as="element(sparql:result)" />
	<xsl:param name="binding" as="xs:string" />
	<xsl:sequence select="$result/sparql:binding[@name = $binding]/*" />
</xsl:function>

<xsl:function name="leg:legislationType" as="xs:string">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:variable name="type" as="xs:string+" 
		select="$legislation/rdf:type/@rdf:resource[starts-with(., $leg)]/substring-after(., $leg)" />
	<xsl:sequence select="$type[. = $tso:legTypeMap/@schemaType][1]" />
</xsl:function>
	
<xsl:function name="leg:welshDocument" as="xs:boolean">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:variable name="type" as="xs:string+" 
		select="$legislation/rdf:type/@rdf:resource[starts-with(., $leg)]/substring-after(., $leg)" />
	<xsl:sequence select="$type = $leg:welshType" />
</xsl:function>

<xsl:function name="leg:legislationClass" as="xs:string">
	<xsl:param name="type" as="xs:string" />
	<xsl:sequence select="$tso:legTypeMap[@schemaType = $type]/@class" />
</xsl:function>

<xsl:function name="leg:commencementOrder" as="xs:boolean">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:sequence select="$legislation/rdf:type/@rdf:resource = $leg:CommencementOrder" />
</xsl:function>

<xsl:function name="leg:nonPrint" as="xs:boolean">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:sequence select="($legislation/rdf:type/@rdf:resource = $leg:NonPrint or 
		($legislation/leg:year = ('2010', '2011')) and not($legislation/leg:pages))" />
</xsl:function>

<xsl:function name="leg:containsEffects" as="xs:boolean?">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:choose>
		<xsl:when test="$legislation/leg:effects/@rdf:resource = $leg:eu-effects">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$legislation/leg:effects/@rdf:resource = $leg:no-primary-effects and $legislation/leg:effects/@rdf:resource = $leg:no-secondary-effects">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="count($legislation/leg:effects) = 2">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="effectsSummary" as="element(rdf:Description)*" 
				select="$legislation/root()/rdf:RDF/rdf:Description[rdf:type/@rdf:resource = $leg:EffectsSummary and leg:affected/@rdf:resource = $legislation/@rdf:about]" />
			<xsl:variable name="effectsSummary" as="element(rdf:Description)?"
				select="($effectsSummary[ends-with(@rdf:about, '/review')], $effectsSummary)[1]" />
			<xsl:choose>
				<xsl:when test="$effectsSummary/(leg:effects/@rdf:resource = $leg:no-primary-effects and leg:effects/@rdf:resource = $leg:no-secondary-effects)">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="count($effectsSummary/leg:effects) = 2">
					<xsl:sequence select="true()" />
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:containsPrimaryEffects" as="xs:boolean?">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:choose>
		<xsl:when test="$legislation/leg:effects/@rdf:resource = $leg:no-primary-effects">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="$legislation/leg:effects/@rdf:resource = $leg:primary-effects">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="effectsSummary" as="element(rdf:Description)*" 
				select="$legislation/root()/rdf:RDF/rdf:Description[rdf:type/@rdf:resource = $leg:EffectsSummary and leg:affected/@rdf:resource = $legislation/@rdf:about]" />
			<xsl:variable name="effectsSummary" as="element(rdf:Description)?"
				select="($effectsSummary[ends-with(@rdf:about, '/review')], $effectsSummary)[1]" />
			<xsl:choose>
				<xsl:when test="$effectsSummary/leg:effects/@rdf:resource = $leg:no-primary-effects">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="$effectsSummary/leg:effects/@rdf:resource = $leg:primary-effects">
					<xsl:sequence select="true()" />
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:containsSecondaryEffects" as="xs:boolean?">
	<xsl:param name="legislation" as="element(rdf:Description)" />
	<xsl:choose>
		<xsl:when test="$legislation/leg:effects/@rdf:resource = $leg:no-secondary-effects">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="$legislation/leg:effects/@rdf:resource = $leg:secondary-effects">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="effectsSummary" as="element(rdf:Description)*" 
				select="$legislation/root()/rdf:RDF/rdf:Description[rdf:type/@rdf:resource = $leg:EffectsSummary and leg:affected/@rdf:resource = $legislation/@rdf:about]" />
			<xsl:variable name="effectsSummary" as="element(rdf:Description)?"
				select="($effectsSummary[ends-with(@rdf:about, '/review')], $effectsSummary)[1]" />
			<xsl:choose>
				<xsl:when test="$effectsSummary/leg:effects/@rdf:resource = $leg:no-secondary-effects">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="$effectsSummary/leg:effects/@rdf:resource = $leg:secondary-effects">
					<xsl:sequence select="true()" />
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:inheritedResearch" as="element(rdf:Description)*">
	<xsl:param name="items" as="element(rdf:Description)+" />
	<xsl:param name="inherited" as="element(rdf:Description)*" />
	<xsl:param name="class" as="xs:string" />
	<xsl:variable name="item" as="xs:string" select="$items[1]/leg:interpretationOf/@rdf:resource" />
	<xsl:variable name="research" as="element(rdf:Description)*" select="key('research', $item, $items/root())" />
	<xsl:variable name="research" as="element(rdf:Description)*" select="$research[rdf:type/@rdf:resource = $class]" />
	<xsl:choose>
		<xsl:when test="exists($research)">
			<xsl:sequence select="$research" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$inherited" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:provision" as="element(rdf:Description)?">
	<xsl:param name="item" as="element(rdf:Description)" />
	<xsl:variable name="hierarchy" as="element(rdf:Description)+"
		select="if ($item/leg:within) then rdf:get($item, xs:QName('leg:within')) else rdf:get($item, (xs:QName('leg:start'), xs:QName('leg:within'))), $item" />
	<xsl:variable name="provisions" as="element(rdf:Description)*"
		select="$hierarchy[rdf:type/@rdf:resource = $leg:provisionTypes]" />
	<xsl:sequence select="$provisions[not(leg:within/@rdf:resource = $provisions/@rdf:about)][1]" />
</xsl:function>

<xsl:function name="leg:highlevel" as="element(rdf:Description)?">
	<xsl:param name="item" as="element(rdf:Description)" />
	<xsl:variable name="hierarchy" as="element(rdf:Description)+"
		select="if ($item/leg:within) then rdf:get($item, xs:QName('leg:within')) else rdf:get($item, (xs:QName('leg:start'), xs:QName('leg:within'))), $item" />
	<!--<xsl:variable name="provisions" as="element(rdf:Description)*"
		select="$hierarchy[rdf:type/@rdf:resource = $leg:highlevelTypes]" />-->
	<xsl:variable name="provisions" as="element(rdf:Description)*">
		<xsl:for-each select="$hierarchy[rdf:type/@rdf:resource = $leg:provisionTypes]">
			<xsl:sequence select="."/>
		</xsl:for-each>
		<xsl:for-each select="$hierarchy[rdf:type/@rdf:resource = ($leg:Crossheading, $leg:Chapter, $leg:Part, $leg:Introduction )]">
			<xsl:sequence select="."/>
		</xsl:for-each>
		<xsl:for-each select="$hierarchy[rdf:type/@rdf:resource = $leg:Schedule]">
			<xsl:sequence select="."/>
		</xsl:for-each>
		<xsl:for-each select="$hierarchy[rdf:type/@rdf:resource = $leg:Legislation]">
			<xsl:sequence select="."/>
		</xsl:for-each>
	</xsl:variable>
		
	<xsl:sequence select="$provisions[1]" />
</xsl:function>

<xsl:function name="role:isAdministrator" as="xs:boolean">
	<xsl:param name="user" as="element(rdf:Description)?" />
	<xsl:sequence select="$user/sioc:has_function/@rdf:resource = $role:administrator" />
</xsl:function>
	
<xsl:function name="role:isSuperAdministrator" as="xs:boolean">
	<xsl:param name="user" as="element(rdf:Description)?" />
	<xsl:sequence select="$user/sioc:has_function/@rdf:resource = $role:superAdministrator" />
</xsl:function>
	
<xsl:function name="role:isManager" as="xs:boolean">
	<xsl:param name="user" as="element(rdf:Description)?" />
	<xsl:sequence select="$user/sioc:has_function/@rdf:resource = $role:manager" />
</xsl:function>

<xsl:function name="role:isQueryAdministrator" as="xs:boolean">
	<xsl:param name="user" as="element(rdf:Description)?" />
	<xsl:sequence select="$user/sioc:has_function/@rdf:resource = $role:queryAdministrator" />
</xsl:function>
	
<xsl:function name="role:isActiveUser" as="xs:boolean">
	<xsl:param name="user" as="element(rdf:Description)?" />
	<xsl:sequence select="$user/task:userStatus ='Active'" />
</xsl:function>

<xsl:function name="leg:translateRomanToArabic" as="xs:string+" >
	<xsl:param name="roman" as="xs:string+" />
	<xsl:choose>
		<xsl:when test="matches($roman, '^[IVXivx]+$')"><xsl:sequence select="xs:string(leg:romanToInt($roman))" /></xsl:when>
		<xsl:otherwise><xsl:value-of select="$roman" /></xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="leg:romanToInt" as="xs:integer">
	<xsl:param name="roman" as="xs:string" />
	<xsl:sequence select="leg:romanToInt($roman, 0, 0)" />
</xsl:function>
	
<xsl:function name="leg:romanToInt" as="xs:integer">
	<xsl:param name="strNumber" as="xs:string" />
	<xsl:param name="intPreviousCharValue" as="xs:integer" />
	<xsl:param name="intValue" as="xs:integer" />
	<xsl:choose>
		<xsl:when test="$strNumber != ''">
			<xsl:variable name="strFirstChar" as="xs:string" select="substring($strNumber, 1, 1)" />
			<xsl:variable name="intFirstCharValue" as="xs:integer">
				<xsl:choose>
					<xsl:when test="$strFirstChar = ('i', 'I')">1</xsl:when>
					<xsl:when test="$strFirstChar = ('v', 'V')">5</xsl:when>
					<xsl:when test="$strFirstChar = ('x', 'X')">10</xsl:when>
					<xsl:when test="$strFirstChar = ('l', 'L')">50</xsl:when>
					<xsl:when test="$strFirstChar = ('c', 'C')">100</xsl:when>
					<xsl:when test="$strFirstChar = ('d', 'D')">500</xsl:when>
					<xsl:when test="$strFirstChar = ('m', 'M')">1000</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="intNewValue" as="xs:integer">
				<xsl:choose>
					<xsl:when test="$intPreviousCharValue = 0 or
						              $intPreviousCharValue >= $intFirstCharValue">
						<xsl:value-of select="$intValue + $intFirstCharValue" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$intValue + $intFirstCharValue -
							                    ($intPreviousCharValue * 2)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:sequence select="leg:romanToInt(substring($strNumber, 2), $intFirstCharValue, $intNewValue)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$intValue" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:get-month-name" as="xs:string">
	<xsl:param name="month" as="xs:integer"/>
	<xsl:choose>
		<xsl:when test="$month = 1">January</xsl:when>
		<xsl:when test="$month = 2">February</xsl:when>
		<xsl:when test="$month = 3">March</xsl:when>
		<xsl:when test="$month = 4">April</xsl:when>
		<xsl:when test="$month = 5">May</xsl:when>
		<xsl:when test="$month = 6">June</xsl:when>
		<xsl:when test="$month = 7">July</xsl:when>
		<xsl:when test="$month = 8">August</xsl:when>
		<xsl:when test="$month = 9">September</xsl:when>
		<xsl:when test="$month = 10">October</xsl:when>
		<xsl:when test="$month = 11">November</xsl:when>
		<xsl:when test="$month = 12">December</xsl:when>
		<xsl:otherwise>error: <xsl:value-of select="$month"/></xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
	<xsl:function name="tso:section-uri-to-identifier" as="xs:string?">
		<xsl:param name="sectionURI"/>
		<xsl:param name="legislationId"/>
		
		<xsl:variable name="section" select="if (starts-with($sectionURI, $legislationId)) then substring-after($sectionURI, concat(substring-after($legislationId, 'id'),'/')) else $sectionURI"/>
		<xsl:choose>
			<xsl:when test="$section = ''"></xsl:when>
			<xsl:when test="matches($section, ('crossheading/(\c)+/(section|article|rule|regulation|order|paragraph)'))">
				<xsl:variable name="prexheading" select="substring-before($section,'crossheading/')"/>
				<xsl:variable name="xheading" select="substring-before(substring-after($section,'crossheading/'),'/')"/>
				<xsl:variable name="postxheading" select="substring-after(substring-after($section,'crossheading/'),'/')"/>
				<xsl:sequence select="concat(translate($prexheading, '/', '-'), 'crossheading-', translate($xheading, '/', '-'), '_', translate($postxheading, '/', '-'))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="translate($section, '/', '-')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="tso:section-uri-from-uri" as="xs:string?">
		<xsl:param name="sectionURI"/>
		<xsl:param name="legislationId"/>
		
		<xsl:sequence select="substring-after($sectionURI, concat(substring-after($legislationId, 'id'),'/'))"/>
	</xsl:function>	
	

</xsl:stylesheet>