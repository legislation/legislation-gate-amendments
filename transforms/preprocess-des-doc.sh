#!/bin/sh
./saxon.sh "-s:$1.xml" -xsl:xsl/des/des-xml.xsl "-o:$1_pre_des1.xml"
./saxon.sh "-s:$1_pre_des1.xml" -xsl:xsl/des/legislation-clean.xsl "-o:$1_pre_des2.xml"
