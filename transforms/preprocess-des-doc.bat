
cls

call saxon.bat -s:%1.xml -xsl:xsl/des/des-xml.xsl -o:%1_pre_des1.xml

call saxon.bat -s:%1_pre_des1.xml -xsl:xsl/des/legislation-clean.xsl -o:%1_pre_des2.xml
