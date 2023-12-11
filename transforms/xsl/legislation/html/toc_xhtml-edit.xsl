<!-- UI Legislation Table of Contents/Plain View page output  -->

<!-- Version 0.01 -->
<!-- Created by Faiz Muhammad -->
<!-- Last changed 17/02/2010 by Faiz Muhammad -->
<!-- Change history

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:atom="http://www.w3.org/2005/Atom" 
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xforms="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
	>

	<xsl:import href="toc_xhtml.xsl"/>

	<xsl:template match="/">
		<html>
			<head>
				<meta name="robots" content="noindex"/>
				<title>Legislation Xopus Preview</title>
				
				<xsl:call-template name="TSOOutputAddLegislationStyles"/>
				
				<!-- Start Xopus -->
				<link rel="stylesheet" type="text/css" href="/scripts/xopus-tna/css/wysiwyg.css"/>
				<link rel="stylesheet" type="text/css" href="/scripts/xopus-tna/css/tagson.css"/>
				<script type="text/javascript" src="/scripts/xopus/xopus.js"></script>
			</head>
			<body>
					<div id="page">
					<!-- The Xopus Canvas -->
					<div xopus="true">
						<xml>
						  <x:config version="1.0" xmlns:x="http://www.xopus.com/xmlns/config">
								<x:miscellaneous>
									<x:debugMode>true</x:debugMode>
							    </x:miscellaneous>
								<x:javascript src="/scripts/xopus-tna/js/save.js"/>
								<x:pipeline xml="{/leg:Fragment/@DocumentURI}/data.xml?view=edit">
								<!--<x:pipeline xml="/scripts/xopus-tna/xml/ukpga-1985-67-section-6-england-wales-edit-simple-master.xml">-->
								<!--<x:pipeline xml="{/leg:Legislation/ukm:Metadata/atom:link[@rel = 'self']/@href}" >-->
								  <x:view name="WYSIWYG View">
									<x:transform xsl="/scripts/xopus-tna/xsl/html/legislation_xhtml_vanilla.xslt"/>
								  </x:view>
								  <x:view name="Tags On View">
									<x:transform xsl="/scripts/xopus-tna/xsl/html/legislation_xhtml_vanilla_tagson.xslt"/>
								  </x:view>
								  <x:view name="XML View">
									<x:treeTransform/>
								  </x:view>
								</x:pipeline>
								<x:import src="/scripts/xopus-tna/config/config.xml"/>
						  </x:config>
						</xml>
					</div> 
				</div>					
			</body>
		</html>
	</xsl:template>
	
	
</xsl:stylesheet>
