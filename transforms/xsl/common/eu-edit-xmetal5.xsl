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
	exclude-result-prefixes="xs leg ukm err tso xhtml"
	version="2.0">
	
	<xsl:import href="edit-xml.xsl" />

	<xsl:strip-space elements="leg:Number leg:Text leg:Pnumber leg:Addition leg:Substitution leg:Repeal"/>

	<xsl:output indent="no" />
	
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

</xsl:stylesheet>
