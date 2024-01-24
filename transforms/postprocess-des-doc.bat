
cls

call saxon.bat -xsl:xsl/prepare-des-document.xsl -it:main "des_legislation_xml=%CD:\=/%/%1_doc.xml" "des_effects_xml=%CD:\=/%/%1_effects.xml" -o:%1_des.xml

call saxon.bat -s:%1_des.xml -xsl:xsl/des/markup.xsl -o:%1_des2.xml %2 %3

call saxon.bat -s:%1_des2.xml -xsl:xsl/legislation/fo/legislation_schema_FO.xslt -o:%1_fo.xml  %2 %3

call saxon.bat -s:%1_fo.xml -xsl:xsl/legislation/fo/legislation_schema_cleanup_FO.xslt -o:%1.fo

echo generating %1.pdf

call fop\fop\fop.bat -c fop/sls.conf -fo %1.fo -pdf %1.pdf

echo generating %1.xls

call saxon.bat -s:%1_des2.xml -xsl:xsl/toes-feed-to-extended-worksheet.xsl -o:%1_spreadsheet.xls 
