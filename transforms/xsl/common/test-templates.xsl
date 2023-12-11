<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:utils="http://www.legislation.gov.uk/namespaces/utils"
	exclude-result-prefixes="xs leg"
	version="2.0">

	<xsl:import href="number-format-converters.xsl" />

	<!--
		There are inconsistencies in xspec testing of returned strings so this xslt
		addresses the issue by employing a template to wrap the returned strings
		in xml markup
	
	-->
	
	<xsl:template name="test-make-regex-matcher">
		<xsl:param name="identifer" as="xs:string" />
		<xsl:param name="pattern" as="xs:string" />
		<regex><xsl:value-of select="utils:make-regex-matcher($identifer, $pattern)"/></regex>
	</xsl:template>

</xsl:stylesheet>
