java -jar C:\Development\opsi\SLS\saxon\saxon9.jar -s:C:\temp\ukpga-1985-67.xml -xsl:legislation_xhtml_consolidation.xslt -o:c:\temp\leg\leg.htm -TP 2> c:\temp\profile.xml

java -jar C:\Development\opsi\SLS\saxon\saxon9.jar -s:C:\temp\profile.xml -xsl:c:\temp\timing-profile.xsl -o:c:\temp\leg\profile.htm