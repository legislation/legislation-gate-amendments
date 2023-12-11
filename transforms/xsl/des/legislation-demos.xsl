<!-- UI static page output  -->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xhtml xs"
	xmlns="http://www.w3.org/1999/xhtml">
	
<xsl:import href="../legislation/html/quicksearch.xsl"/>

<xsl:template match="/">
	<html>
		<body xml:lang="en" lang="en" dir="ltr" id="doc">
			<xsl:sequence select="@*" />
			<div id="layout2">
				<xsl:call-template name="TSOOutputQuickSearch" />		
				
				<div class="title"><h1 id="pageTitle">Data Enrichment Demonstration</h1></div>
				<div id="content">
					
					<div>
							<p>Use the form below to enter a data.xml URI or select one of the pre-configured URIs.</p>
							<form id="des" name="input" action="/des" method="get">
								<p>XML URI: <input type="text" id="desInput" name="demo" style="width: 400px" />&#160;&#160;<input type="submit" id="desSubmit" value="Process" /></p>
							</form>
					</div>

					<!-- pull in the example links -->
					<ul>
						<xsl:for-each select="document('../../xml/des/legislation-demos-configuration.xml')//demo">
							<li>
								<a href="/des?demo={url}">
									<xsl:value-of select="title"/>
								</a>
								<xsl:text> (</xsl:text>
								<a href="/des?format=xml&amp;demo={url}">XML</a>
								<xsl:text>) </xsl:text>
								<xsl:text>(</xsl:text>
								<a href="/des?format=toes&amp;demo={url}">TOES</a>
								<xsl:text>) </xsl:text>
								<xsl:value-of select="comment"/>
							</li>
						</xsl:for-each>
					</ul>
				
				</div>
			</div>
		</body>
	</html>

</xsl:template>

</xsl:stylesheet>
