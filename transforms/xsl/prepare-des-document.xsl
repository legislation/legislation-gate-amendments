<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
  xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
  exclude-result-prefixes="xs leg"
  version="2.0">
  
  <xsl:param name="des_legislation_xml" as="xs:string" required="yes"/>
  <xsl:param name="des_effects_xml" as="xs:string" required="yes"/>
  
  <xsl:template name="main">
    <DesDocument>
      <xsl:copy-of select="doc($des_legislation_xml)/leg:Legislation"/>
      <xsl:copy-of select="doc($des_effects_xml)/ukm:Changes"/>
    </DesDocument>
  </xsl:template>
  
</xsl:stylesheet>
