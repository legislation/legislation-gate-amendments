<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	version="2.0"
	exclude-result-prefixes="xs">

<xsl:import href="utils.xsl"/>	
	
<xsl:output method="text" />

<xsl:template match="/">
	<xsl:apply-templates select="//ukm:Effects[@Id = 'http://www.legislation.gov.uk/id/ukpga/2000/8']/ukm:Effect"  mode="effect"/>
</xsl:template>



</xsl:stylesheet>