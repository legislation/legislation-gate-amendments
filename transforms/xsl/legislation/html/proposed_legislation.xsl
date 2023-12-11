<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"  version="2.0" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:db="http://docbook.org/ns/docbook"	
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"	
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/"
	>
	
<xsl:import href="searchcommon_xhtml.xsl" />
	
<xsl:template name="heading">
	<h1>Proposed Versions</h1>
</xsl:template>

<xsl:template match="atom:feed" mode="summary">
	<h2>Existing proposed versions of this legislation.</h2>
	<p>You can create a new proposed version of this item of legislation:</p>
	<form action="" method="post">
		<input name="type" type="hidden" value="{$paramsDoc/parameters/type}" />
		<input name="year" type="hidden" value="{$paramsDoc/parameters/year}" />
		<input name="number" type="hidden" value="{$paramsDoc/parameters/number}" />
		<div class="searchTitle searchFieldCategory">
			<div class="searchCol1">
				<label for="proposedTitle">
					<xsl:text>Title:</xsl:text>
				</label>
			</div>
			<div class="searchCol2">
				<div class="searchFieldGroup">
					<input type="text" id="proposedTitle" name="title" value="Proposed Change" />
				</div>
			</div>
			<div class="searchCol3">
				<!--
				<a class="helpIcon helpItem helpItemToRight" href="#titleHelp">
					<img alt=" Help about Title searching" src="/images/chrome/helpIcon.gif"/>
				</a>
				-->
			</div>				
		</div>			
		<div class="searchTitle searchFieldCategory">
			<div class="searchCol1">
				<label for="proposedURIcomponent">
					<xsl:text>URL Component:</xsl:text>
				</label>
			</div>
			<div class="searchCol2">
				<div class="searchFieldGroup">
					<input type="text" id="proposedURIcomponent" name="slug" value="proposed-change" />
				</div>
			</div>
			<div class="searchCol3">
				<!--
				<a class="helpIcon helpItem helpItemToRight" href="#titleHelp">
					<img alt=" Help about Title searching" src="/images/chrome/helpIcon.gif"/>
				</a>
				-->
			</div>
		</div>
		<div class="submit">
			<button class="userFunctionalElement" id="createProposalSubmit" type="submit">Create</button>
		</div>
	</form>
</xsl:template>

</xsl:stylesheet>
