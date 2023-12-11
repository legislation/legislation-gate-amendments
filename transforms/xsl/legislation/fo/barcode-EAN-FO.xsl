<?xml version="1.0" encoding="iso-8859-1"?>

<!-- =========================================================== -->
<!--                                                             -->
<!-- © 2000, RenderX.                                            -->
<!--                                                             -->
<!-- Author: Nikolai Grigoriev <grig@renderx.com>                -->
<!--                                                             -->
<!-- Permission is granted to use this document, copy and        -->
<!-- modify free of charge, provided that every derived work     -->
<!-- bear a reference to the present document.                   -->
<!--                                                             -->
<!-- This document contains a computer program written in        -->
<!-- XSL Transformations Language. It is published with no       -->
<!-- warranty of any kind about its usability, as a mere         -->
<!-- example of XSL technology. RenderX shall not be considered  -->
<!-- liable for any damage or loss of data caused by use         -->
<!-- of this program.                                            -->
<!--                                                             -->
<!-- =========================================================== -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">


<!-- =========================================================== -->
<!--                                                             -->
<!-- This stylesheet exports a named template to draw barcodes   -->
<!-- using EAN-13, EAN-8, UPC-A, or UPC-E encoding scheme. The   -->
<!-- stylesheet produces a barcode pattern as an XSL Formatting  -->
<!-- Objects table (<fo:table>). The formatting objects version  -->
<!-- is XSL CR-2000-11-21.                                       -->
<!--                                                             -->
<!-- =========================================================== -->
<!-- Template arguments have the following meaning:              -->
<!--                                                             -->
<!--    $module - a numeric value of a narrowest bar width       -->
<!--    $unit   - measurement unit for $module                   -->
<!--                                                             -->
<!-- Example: if the narrowest bar is 0.33mm,                    -->
<!--          then $unit="mm", $module="0.33"                    -->
<!-- These two parameters serve to provide an easy scaling of    -->
<!-- barcode picture. All widths inside the template are         -->
<!-- measured in modules; to convert such a relative value to an -->
<!-- absolute length, it is necessary to multiply it by $module  -->
<!-- and concatenate the result of multiplication with $unit.    -->
<!--                                                             -->
<!--    $height - short bar width (measured in $modules)         -->
<!--                                                             -->
<!-- It is expected that guard bars will be longer than this.    -->
<!--                                                             -->
<!--    $bar-and-space-widths - a string of widths (in $modules) -->
<!--                                                             -->
<!-- This string of digits specifies a complete pattern for all  -->
<!-- bars and spaces in the barcode - including guard bars. Odd  -->
<!-- positions correspond to bars, even positions correspond to  -->
<!-- spaces between them. In UPC/EAN, bars and spaces can only   -->
<!-- be 1, 2, 3, or 4 modules wide.                              -->
<!--                                                             -->
<!--    $bar-heights - a string of '|' and '.' symbols.          -->
<!--                                                             -->
<!-- This string specifies the pattern of long and short bars.   -->
<!-- It has a character for every bar; if the character is '|',  -->
<!-- the bar should be longer than $height - it is a guard bar;  -->
<!-- if the character is '.', the bar is a regular one. This     -->
<!-- pattern depends on the EAN/UPC variant; for example, UPC-A  -->
<!-- has the pattern of "||||..........||..........||||".        -->
<!--                                                             -->
<!--    $first-digit - digit before the leading guard bars       -->
<!--    $last-digit - digit after the trailing guard bars        -->
<!--    $left-digits - left group of bottom digits               -->
<!--    $right-digits - right group of bottom digits             -->
<!--                                                             -->
<!-- This string specifies digits to be written at the bottom.   -->
<!-- $left-digits is always present, others may be empty.        -->
<!--                                                             -->
<!--    $leading-guards-width                                    -->
<!--    $center-guards-width                                     -->
<!--    $trailing-guards-width                                   -->
<!--    $left-short-bars-width                                   -->
<!--    $right-short-bars-width                                  -->
<!--                                                             -->
<!-- These parameters specify widths of correspondent parts of   -->
<!-- the picture in $modules. The first three measure distance   -->
<!-- from the left edge of the leftmost long bar in the group to -->
<!-- the right edge of the rightmost long bar. The last two      -->
<!-- measure the distance between the guard bars that delimit    -->
<!-- the corresponding string, i.e. include the surrounding      -->
<!-- white space also. The sum of the five parameters is always  -->
<!-- equal to the total width of the bar pattern. If a group     -->
<!-- of bars is missing in a particular code, its width is 0.    -->
<!--                                                             -->
<!--    $short-bars-in-group                                     -->
<!--                                                             -->
<!-- Number of short bars in a single group, either right or     -->
<!-- left. This parameter is useful for table representations.   -->


<xsl:template name="draw-barcode-EAN">
  <xsl:param name="module"/>
  <xsl:param name="height"/>
  <xsl:param name="unit"/>
  <xsl:param name="bar-and-space-widths"/>
  <xsl:param name="bar-heights"/>
  <xsl:param name="first-digit"/>
  <xsl:param name="last-digit"/>
  <xsl:param name="left-digits"/>
  <xsl:param name="right-digits"/>
  <xsl:param name="leading-guards-width"/>   <!-- unused -->
  <xsl:param name="trailing-guards-width"/>  <!-- unused -->
  <xsl:param name="center-guards-width"/>    <!-- unused -->
  <xsl:param name="left-short-bars-width"/>  <!-- unused -->
  <xsl:param name="right-short-bars-width"/> <!-- unused -->
  <xsl:param name="short-bars-in-group"/>

  <!-- Select font height (in modules) and family. -->
  <xsl:variable name="font-height" select="11"/>
  <xsl:variable name="font-family" select="'Helvetica'"/>

  <!-- Build up a table -->
  <fo:table keep-together.within-column="always" text-align="right">

    <!-- Column specifiers -->
    <!-- First digit -->
    <xsl:if test="string-length($first-digit) != 0">
      <fo:table-column column-width="{$font-height * $module}{$unit}"/>
    </xsl:if>

    <!-- Column widths -->
    <xsl:call-template name="emit-column-widths">
      <xsl:with-param name="module" select="$module"/>
      <xsl:with-param name="unit" select="$unit"/>
      <xsl:with-param name="bar-and-space-widths" select="$bar-and-space-widths"/>
    </xsl:call-template>

    <!-- Last digit -->
    <xsl:if test="string-length($last-digit) != 0">
      <fo:table-column column-width="{$font-height * $module}{$unit}"/>
    </xsl:if>

    <!-- Table body -->
    <fo:table-body>
      <!-- Bars -->
      <fo:table-row height="{$height * $module}{$unit}">

        <!-- Empty space above first digit  -->
        <xsl:if test="string-length($first-digit) != 0">
          <fo:table-cell><fo:block/></fo:table-cell>
        </xsl:if>

        <!-- Cells that correspond to bars and spaces -->
        <xsl:call-template name="emit-bar-cells">
          <xsl:with-param name="bar-heights" select="$bar-heights"/>
        </xsl:call-template>

        <!-- Empty space above last digit  -->
        <xsl:if test="string-length($last-digit) != 0">
          <fo:table-cell><fo:block/></fo:table-cell>
        </xsl:if>
      </fo:table-row>

      <!-- Digit symbols -->
      <fo:table-row height="{($font-height * $module) div 2}{$unit}"
                    font-size="{$font-height * $module}{$unit}"
                    font-family="{$font-family}"
                    text-align="center">

        <!-- First digit -->
        <xsl:if test="string-length($first-digit)!= 0">
          <fo:table-cell number-rows-spanned="2">
            <fo:block padding="{$module}{$unit}">
              <xsl:value-of select="$first-digit"/>
            </fo:block>
          </fo:table-cell>
        </xsl:if>

        <!-- Left side -->
        <fo:table-cell number-columns-spanned="{2 * $short-bars-in-group + 1}"
                       number-rows-spanned="2">
          <fo:block padding="{$module}{$unit}">
            <xsl:value-of select="$left-digits"/>
          </fo:block>
        </fo:table-cell>

        <!-- Right side -->
        <xsl:if test="string-length($right-digits) != 0">
          <fo:table-cell number-columns-spanned="{2 * $short-bars-in-group + 1}"
                         number-rows-spanned="2">
            <fo:block padding="{$module}{$unit}">
              <xsl:value-of select="$right-digits"/>
            </fo:block>
          </fo:table-cell>
        </xsl:if>

        <!-- Last digit -->
        <xsl:if test="string-length($last-digit) != 0">
          <fo:table-cell number-rows-spanned="2">
            <fo:block padding="{$module}{$unit}">
              <xsl:value-of select="$last-digit"/>
            </fo:block>
          </fo:table-cell>
        </xsl:if>
      </fo:table-row>

    </fo:table-body>
  </fo:table>

</xsl:template>

<!-- =========================================================== -->
<!-- Recursive template that prints out column widths            -->
<xsl:template name="emit-column-widths">
  <xsl:param name="module"/>
  <xsl:param name="unit"/>
  <xsl:param name="bar-and-space-widths"/>

  <xsl:if test="string-length($bar-and-space-widths)!= 0">
    <xsl:variable name="width" select="number(substring($bar-and-space-widths,1,1))"/>
    <fo:table-column column-width="{$module * $width}{$unit}"/>
    <xsl:call-template name="emit-column-widths">
      <xsl:with-param name="module" select="$module"/>
      <xsl:with-param name="unit" select="$unit"/>
      <xsl:with-param name="bar-and-space-widths" select="substring($bar-and-space-widths,2)"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- =========================================================== -->
<!-- Recursive template that prints out cells with background    -->
<xsl:template name="emit-bar-cells">
  <xsl:param name="bar-heights"/>

  <fo:table-cell background-color="black">
    <xsl:if test="starts-with($bar-heights, '|')"> <!-- long bar -->
      <xsl:attribute name="number-rows-spanned">2</xsl:attribute>
    </xsl:if>
    <fo:block/>
  </fo:table-cell>

  <xsl:if test="string-length(substring($bar-heights,2)) != 0">
    <fo:table-cell>
      <xsl:if test="starts-with($bar-heights, '||')"> <!-- long space -->
        <xsl:attribute name="number-rows-spanned">2</xsl:attribute>
      </xsl:if>
      <fo:block/>
    </fo:table-cell>

    <xsl:call-template name="emit-bar-cells">
      <xsl:with-param name="bar-heights" select="substring($bar-heights,2)"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="draw-error-message">
  <fo:block font-weight="bold">INVALID BARCODE PARAMETERS</fo:block>
</xsl:template>

</xsl:stylesheet>
