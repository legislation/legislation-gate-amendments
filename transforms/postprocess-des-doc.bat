
cls

call saxon.bat -s:%1.xml -xsl:xsl/des/markup.xsl -o:%1_des.xml %2 %3

call saxon.bat -s:%1_des.xml -xsl:xsl/legislation/fo/legislation_schema_FO.xslt -o:%1_fo.xml  %2 %3

call saxon.bat -s:%1_fo.xml -xsl:xsl/legislation/fo/legislation_schema_cleanup_FO.xslt -o:%1.fo

echo generating %1.pdf

call fop-1.0\fop.bat -c fop/sls.conf -fo %1.fo -pdf %1.pdf

echo generating %1.xls

call saxon.bat -s:%1_des.xml -xsl:xsl/toes-feed-to-extended-worksheet.xsl -o:%1_spreadsheet.xls 
