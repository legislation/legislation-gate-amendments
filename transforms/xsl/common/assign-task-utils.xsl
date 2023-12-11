<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:leg="http://www.legislation.gov.uk/def/legislation/"
	xmlns:task="http://www.legislation.gov.uk/def/task/"
	xmlns:process="http://www.legislation.gov.uk/id/process/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:sparql="http://www.w3.org/2005/sparql-results#"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:l="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:utils="http://www.legislation.gov.uk/namespaces/utils"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs rdf rdfs sparql tso leg task process"
	xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="number-format-converters.xsl" />
	
	<xsl:param name="assignTaskToc" as="document-node()?" select="if (doc-available('input:assignTaskToc')) then doc('input:assignTaskToc') else ()" />

	<xsl:variable name="provision-names" select="('order', 'rule', 'regulation', 'article', 'section')"/>
	
	<xsl:function name="tso:find-alt-provision-name">
		<xsl:param name="iduri" as="xs:string"/>
		
		<xsl:sequence select="for $prov in $provision-names
								return 
									replace($iduri, 'order|rule|regulation|article|section', $prov)"/>
	
	</xsl:function>	
	
	<xsl:function name="tso:get-section-component">
		<xsl:param name="iduri" as="xs:string"/>
		<xsl:sequence select="tokenize(substring-after($iduri, 'http://www.legislation.gov.uk/id/'), '/')[4]"/>
	</xsl:function>	
	
	<xsl:function name="tso:get-type-component">
		<xsl:param name="iduri" as="xs:string"/>
		<xsl:sequence select="tokenize(substring-after($iduri, 'http://www.legislation.gov.uk/id/'), '/')[1]"/>
	</xsl:function>

	<xsl:function name="tso:is-provision-id" as="xs:boolean">
		<xsl:param name="iduri" as="xs:string"/>
		<xsl:sequence select="matches(tso:get-section-component($iduri), '^(order|rule|regulation|article|section)') "/>
	</xsl:function>	
	
	<xsl:function name="tso:possible-provision-uris" as="xs:string*">
		<xsl:param name="uri" as="xs:string"/>
		<xsl:sequence select="if (tso:is-provision-id($uri) and tso:get-type-component($uri) = ('uksi')) then 
													tso:find-alt-provision-name($uri)
												else $uri"/>
	</xsl:function>	
	
	<xsl:function name="process:get-provison-type">
		<xsl:param name="provison" as="element()?" />
		<xsl:value-of select="$provison[@property='leg:Contains']/@typeof"/>
	</xsl:function> 
	
	<xsl:function name="process:get-provison-metadata">
		<xsl:param name="uri" as="xs:string" />
		<xsl:sequence select="$assignTaskToc//xhtml:li[xhtml:p/xhtml:meta[@property = 'dc:identifier'][@content = $uri]]"/>
	</xsl:function> 	


	<xsl:function name="process:uris-in-a-range" >
		<xsl:param name="uri1" as="xs:string" />
		<xsl:param name="uri2" as="xs:string" />
		<xsl:variable name="uri1meta" select="process:get-provison-metadata($uri1)"/>
		<xsl:variable name="elementname" select="process:get-provison-type($uri1meta)"/>
		<xsl:variable name="followingElements" as="element()*" select="
			if (empty($assignTaskToc) or $assignTaskToc/error) then ()
			else if (process:get-provison-metadata($uri1) &lt;&lt; process:get-provison-metadata($uri2))	then 
			(
				process:get-provison-metadata($uri1)/following::xhtml:li[process:get-provison-type(.) = $elementname][not(process:get-provison-metadata($uri2)  &lt;&lt; .)]
			) else
				()" />
				
		<xsl:sequence select="distinct-values(($uri1, (for $e  in $followingElements return string($e/xhtml:p/xhtml:meta[@property = 'dc:identifier']/@content)), $uri2))"/>
	</xsl:function>	
	
	<xsl:function name="process:get-matched-provision-uris" as="xs:string*">
		<xsl:param name="regex" as="xs:string" />
		<!-- Issue LEGEPP-37: we need to qualify the result to prevent provision name/numbers in crossheadings 
		being incorrectly matched
		Therefore we run the regex pattern across the identifier which isolates hyphen items out -->
		<xsl:variable name="matcheditems" select="$assignTaskToc//xhtml:p[xhtml:meta[@property = 'leg:id'][matches(@content, $regex)]]/xhtml:meta[@property = 'dc:identifier']/@content"/>
		<xsl:sequence select="$matcheditems[not(matches(., $regex))]"/>	
	</xsl:function>
	
	<xsl:function name="process:get-assigned-task-provision" as="xs:string*">
		<xsl:param name="idUri" as="xs:string" />
		<xsl:sequence select="$assignTaskToc//xhtml:p[xhtml:meta[@property = 'leg:provtask'][@content = $idUri]]/xhtml:meta[@property = 'dc:identifier']/@content"/>
	</xsl:function>
	
	<xsl:function name="process:assign-toc-exists" as="xs:boolean">
		<xsl:sequence select="exists($assignTaskToc//xhtml:body)"/>
	</xsl:function>
	
	<xsl:function name="process:provision-exists" as="xs:boolean">
		<xsl:param name="idUri" as="xs:string" />
		<xsl:sequence select="exists($assignTaskToc//xhtml:p/xhtml:meta[@property = 'dc:identifier'][@content = $idUri])"/>
	</xsl:function>

	<xsl:function name="process:provision-has-assigned-tasks" as="xs:boolean">
		<xsl:param name="idUri" as="xs:string" />
		<xsl:sequence select="exists($assignTaskToc//xhtml:p[xhtml:meta[@property = 'dc:identifier'][@content = $idUri]]/xhtml:meta[@property = 'leg:provtask'])"/>
	</xsl:function>
	
	<xsl:function name="process:matchActualProvisionURI" as="xs:string">
		<xsl:param name="idUri" as="xs:string" />
		<xsl:variable name="regex" as="xs:string*" 
				select="utils:make-regex-matcher(substring-after($idUri, 'http://www.legislation.gov.uk/id/'), '/')" />
		<xsl:variable 
				name="matches" 
				as="xs:string*" 
				select="if (exists($assignTaskToc)) then 
							$assignTaskToc//xhtml:p[xhtml:meta[@property = 'dc:identifier'][matches(@content, $regex)]]//@content
						else ()" />
		<xsl:sequence select="if (count($matches) = 1) then $matches else ($idUri)"/>
	</xsl:function>

</xsl:stylesheet>