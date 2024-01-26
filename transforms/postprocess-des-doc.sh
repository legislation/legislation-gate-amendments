#!/bin/sh
input_fn="$1"
shift

./saxon.sh -xsl:xsl/prepare-des-document.xsl -it:main "des_legislation_xml=`readlink -f ${input_fn}_doc.xml`" "des_effects_xml=`readlink -f ${input_fn}_effects.xml`" "-o:${input_fn}_des.xml"

./saxon.sh "-s:${input_fn}_des.xml" -xsl:xsl/des/markup.xsl "-o:${input_fn}_des2.xml" "$@"
./saxon.sh "-s:${input_fn}_des2.xml" -xsl:xsl/legislation/fo/legislation_schema_FO.xslt "-o:${input_fn}_fo.xml" "$@"
./saxon.sh "-s:${input_fn}_fo.xml" -xsl:xsl/legislation/fo/legislation_schema_cleanup_FO.xslt "-o:${input_fn}.fo"

echo "generating ${input_fn}.pdf"
fop/fop/fop --execdebug -c fop/sls.conf -fo "${input_fn}.fo" -pdf "${input_fn}.pdf"

echo "generating ${input_fn}.xls"
./saxon.sh "-s:${input_fn}_des2.xml" -xsl:xsl/toes-feed-to-extended-worksheet.xsl "-o:${input_fn}_spreadsheet.xls" 
