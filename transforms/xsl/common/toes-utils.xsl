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
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/def/legislation/"
	xmlns:task="http://www.legislation.gov.uk/def/task/"
	xmlns:legacy="http://www.legislation.gov.uk/def/legacy/"
	exclude-result-prefixes="xs tso rdf rdfs dct time void owl sparql trix ukm leg task legacy">

<xsl:import href="rdf-utils.xsl" />

<xsl:variable name="leg:coextensive-label" select="'Same as affected'" />

<xsl:variable name="leg:wholly-in-force-label"           select="'wholly in force'" />
<xsl:variable name="leg:remainder-in-force-label"        select="'in force in so far as not already in force'" />
<xsl:variable name="leg:specified-purposes-label"        select="'for specified purposes'" />
<xsl:variable name="leg:specified-provisions-label"      select="'for specified provisions'" />
<xsl:variable name="leg:unspecified-table-entries-label" select="'for unspecified table entries'" />
<xsl:variable name="leg:retrospective-in-force-label"    select="'retrospective'" />
<xsl:variable name="leg:with-effect-label"               select="'with effect in accordance with'" />
<xsl:variable name="leg:with-application-label"			 select="'with application in accordance with'" />
<xsl:variable name="leg:gazette-commencement-label"      select="'coming into force in accordance with'" />
<xsl:variable name="leg:specifying-with-effect-label"    select="'specifying with effect'" />


<xsl:variable name="leg:specified-purposes-and-with-effect-label" select="'for specified purposes and with effect in accordance with'" />
<xsl:variable name="leg:specified-purposes-and-with-application-label" select="'for specified purposes and with application in accordance with'" />
<xsl:variable name="leg:retrospective-and-with-effect-label" select="'retrospective and with effect in accordance with'" />
<xsl:variable name="leg:retrospective-and-with-application-label" select="'retrospective and with application in accordance with'" />

<xsl:variable name="leg:ews-commencement-label"          select="'for E.W.S.'" />
<xsl:variable name="leg:ew-commencement-label"           select="'for E.W.'" />
<xsl:variable name="leg:e-commencement-label"            select="'for E.'" />
<xsl:variable name="leg:w-commencement-label"            select="'for W.'" />
<xsl:variable name="leg:s-commencement-label"            select="'for S.'" />
<xsl:variable name="leg:ni-commencement-label"           select="'for N.I.'" />
<xsl:variable name="leg:ewni-commencement-label"         select="'for E.W.N.I.'" />
<xsl:variable name="leg:sni-commencement-label"          select="'for S.N.I.'" />

<xsl:variable name="leg:ews-partial-commencement-label"  select="'for E.W.S. for specified purposes'" />
<xsl:variable name="leg:ew-partial-commencement-label"   select="'for E.W. for specified purposes'" />
<xsl:variable name="leg:e-partial-commencement-label"    select="'for E. for specified purposes'" />
<xsl:variable name="leg:w-partial-commencement-label"    select="'for W. for specified purposes'" />
<xsl:variable name="leg:s-partial-commencement-label"    select="'for S. for specified purposes'" />
<xsl:variable name="leg:ni-partial-commencement-label"   select="'for N.I. for specified purposes'" />
<xsl:variable name="leg:ewni-partial-commencement-label" select="'for E.W.N.I. for specified purposes'" />
<xsl:variable name="leg:sni-partial-commencement-label"  select="'for S.N.I. for specified purposes'" />

</xsl:stylesheet>