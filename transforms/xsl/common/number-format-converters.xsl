<?xml version="1.0" encoding="UTF-8"?>
<!--
(c)  Crown copyright
 
You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0
 
http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

-->

<!--
	This utils module has several functions to convert between the various number formats
	arabic
	roman
	ordinal
	
	and to produce regular expressions to match a string from an idetnifier or uri

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:utils="http://www.legislation.gov.uk/namespaces/utils"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:err="http://www.tso.co.uk/assets/namespace/error"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:atom="http://www.w3.org/2005/Atom" 
  xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs err tso atom dc leg ukm"
	version="2.0">
	
	
	<xsl:function name="utils:roman-to-integer" as="xs:integer">
		<xsl:param name="roman" as="xs:string" />
		<xsl:sequence select="utils:roman-to-integer($roman, 0, 0)" />
	</xsl:function>
		
	<xsl:function name="utils:roman-to-integer" as="xs:integer">
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
				<xsl:sequence select="utils:roman-to-integer(substring($strNumber, 2), $intFirstCharValue, $intNewValue)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$intValue" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="utils:make-regex-matcher" as="xs:string">
		<xsl:param name="identifer" as="xs:string" />
		<xsl:param name="pattern" as="xs:string" />
		<xsl:variable name="tokens" select="tokenize($identifer, $pattern)"/>
		<xsl:variable name="tokenStrings" as="xs:string*">
			<xsl:for-each select="$tokens">
				<xsl:variable name="token" select="."/>
				<xsl:variable 	name="tokenvariants" as="xs:string*"
								select="if (matches(lower-case($token), '^[xiv]+$')) then 
											string(utils:roman-to-integer($token, 0, 0))
										else if ($token castable as xs:integer) then 
											lower-case(utils:integer-to-roman(xs:integer($token)))
										else if (matches($token, '^([0-9]+)([a-zA-Z])$')) then
											string-join((utils:integer-to-roman(xs:integer(replace($token, '([0-9]+)([a-zA-Z])', '$1'))),replace($token, '([0-9]+)([a-zA-Z])', '$2')), '')
										else (),
										if ($token castable as xs:integer) then 
											(utils:integer-to-ordinal(xs:integer($token)))
										else ()
										"/>
				<xsl:sequence select="if (exists($tokenvariants)) then 
										concat('(', string-join(($token, $tokenvariants), '|'), ')') 
									else $token" />
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="replace(concat(string-join(($tokenStrings), $pattern), '$'), '\.', '\\.')"/>
		
	</xsl:function>
	
	<xsl:function name="utils:roman-number-mod" as="xs:integer">
		<xsl:param name="pair" as="xs:anyAtomicType*"  />
		<xsl:param name="romanUnit" as="xs:string"  />
		<xsl:param name="unit" as="xs:integer"  />
		
		<xsl:variable name="roman" select="concat($pair[1], string-join(for $index in 1 to ($pair[2] idiv $unit) return $romanUnit, ''))"/>
		<xsl:variable name="integer" select="$pair[2] mod $unit"/>
		<xsl:sequence select="($roman, $integer)"/>
	</xsl:function>
	
	<xsl:function name="utils:integer-to-roman" as="xs:string">
		<xsl:param name="integer" as="xs:integer"  />
		
		<xsl:number value="$integer" format="i"/>
	</xsl:function>
	
	<xsl:variable name="ordinals" select="('first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth', 'eleventh', 'twelfth', 'thirteenth', 'fourteenth', 'fifteenth', 'sixteenth', 'seventeenth', 'eighteenth', 'nineteenth', 'twentieth')"/>
	
	<xsl:function name="utils:integer-to-ordinal" as="xs:string?">
		<xsl:param name="integer" as="xs:integer"  />
		<xsl:sequence select="$ordinals[$integer]"/>
	</xsl:function>
	
	
	
</xsl:stylesheet>
