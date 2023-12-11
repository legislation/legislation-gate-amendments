<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:tso="http://www.tso.co.uk/assets/namespaces/functions"
	xmlns:leg="http://www.legislation.gov.uk/def/legislation/"
	xmlns:sparql="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="xs atom leg ukm tso sparql"
	xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:x="urn:schemas-microsoft-com:office:excel"
	xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
	xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:task="http://www.legislation.gov.uk/def/task/"
	xmlns:html="http://www.w3.org/TR/REC-html40">

<xsl:import href="common/toes-utils.xsl" />

<xsl:param name="extentsAndCommencements" as="document-node()?" 
	select="if (doc-available('input:extentsAndCommencements')) then doc('input:extentsAndCommencements') else ()" />
<xsl:param name="direction" as="xs:string+"
	select="if (doc-available('input:direction')) then tokenize(doc('input:direction'), ' ') else ('affected', 'affecting')" />
<xsl:param name="bound" 
	select="if (doc-available('input:bound')) then doc('input:bound') else ()" />
<xsl:param name="extended" 
	select="if (doc-available('input:extended')) then doc('input:extended') else ()" />
<xsl:param name="effectsComments" as="document-node()?" 
		select="if (doc-available('input:effectsComments')) then doc('input:effectsComments') else ()" />	
<xsl:param name="desMarkedUp" as="xs:boolean*" 
		select="if (doc-available('input:desMarkedUp')) then doc('input:desMarkedUp') else false()" />	
	

<xsl:key name="sectionInfo" match="sparql:result" use="sparql:binding[@name = 'section']/sparql:uri" />
<xsl:key name="legislationInfo" match="sparql:result" use="sparql:binding[@name = 'legislation']/sparql:uri" />
<xsl:key name="parent" match="sparql:result/sparql:binding[@name = 'parent']" use="../sparql:binding[@name = 'child']" />

<xsl:output indent="yes"/>

<xsl:variable name="extents" as="xs:string+"
	select="('E+W+S+NI', 'E', 'W', 'S', 'NI', 'E+W', 'E+S', 'E+NI', 'W+S', 'W+NI', 'S+NI', 'E+W+S', 'E+W+NI', 'E+S+NI', 'W+S+NI')" />
<xsl:variable name="effectExtents" as="xs:string+" select="($leg:coextensive-label, $extents)" />
<xsl:variable name="territorialApplications" as="xs:string+" select="('No', $extents)" />
<xsl:variable name="commencementQualifications" as="xs:string+"
	select="(
		$leg:wholly-in-force-label,
		$leg:remainder-in-force-label,
		$leg:specified-purposes-label,
		$leg:ews-commencement-label,
		$leg:ew-commencement-label,
		$leg:e-commencement-label,
		$leg:w-commencement-label,
		$leg:s-commencement-label,
		$leg:ni-commencement-label,
		$leg:ewni-commencement-label,
		$leg:sni-commencement-label,
		$leg:ews-partial-commencement-label,
		$leg:ew-partial-commencement-label,
		$leg:e-partial-commencement-label,
		$leg:w-partial-commencement-label,
		$leg:s-partial-commencement-label,
		$leg:ni-partial-commencement-label,
		$leg:ewni-partial-commencement-label,
		$leg:sni-partial-commencement-label,
		$leg:retrospective-in-force-label,
		$leg:with-effect-label,
		$leg:with-application-label,
		$leg:specified-purposes-and-with-effect-label,
		$leg:specified-purposes-and-with-application-label,
		$leg:retrospective-and-with-effect-label,
		$leg:retrospective-and-with-application-label,
		$leg:gazette-commencement-label,
		'Other'
	)" />
	
<xsl:variable name="knockonIFsCount" as="xs:integer?" select="if (//ukm:Effect/ukm:InForceDates/ukm:InForce) then max(//ukm:Effect/ukm:InForceDates/count(ukm:InForce[not(@CommencingURI)])) else 1" />	
<xsl:variable name="knockonIFCOsCount" as="xs:integer?" select="if (//ukm:Effect/ukm:InForceDates/ukm:InForce) then max(//ukm:Effect/ukm:InForceDates/count(ukm:InForce[@CommencingURI])) else 1" />
<!-- hide the welsh amendment applied column for non welsh documents -->
<xsl:variable name="welshDocument" as="xs:boolean?" select="if (//ukm:Effect/@AffectedClass) then ($leg:welshType = distinct-values(//ukm:Effect/@AffectedClass)) else false()" />
<xsl:template match="/*">
	<!-- we do not want the coming into force effects to be shown in the excel  -->
	<!-- AF: removed about restriction on Richards request-->
	<xsl:variable name="nEffects" as="xs:integer" select="count(//ukm:Effect | //ukm:UndefinedEffect[not(@Type = 'coming into force' and @AffectedURI = @AffectingURI)])" />
	<xsl:variable name="rows" as="xs:integer" select="$nEffects + 1" />
    <!-- IF IFCO columns are more than 15 then slightly different logic . if($knockonIFCOsCount > 15) then ($knockonIFCOsCount - 1  -->
	<xsl:variable name="cols" as="xs:integer" select="if ($extended='full-with-co') then  (228 + (if($knockonIFCOsCount > 15) then ($knockonIFCOsCount - 1 ) else ($knockonIFCOsCount - 10))) else if ($direction = 'affected' and $direction = 'affecting') then 54 else if ($direction = 'affected') then 30 else 51" />
	<xsl:variable name="worksheet" as="xs:string">
		<xsl:choose>
			<xsl:when test="$desMarkedUp">Effect Research</xsl:when>
			<xsl:when test="$direction = 'affected' and $direction = 'affecting'">Effect Corrections</xsl:when>
			<xsl:when test="$direction = 'affected'">Affected Extent Research</xsl:when>
			<xsl:otherwise>Effect Research</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="requiredCols" as="xs:integer" select="max(($cols, count($effectExtents), count($territorialApplications), count($commencementQualifications)))" />
	<xsl:variable name="saveDate" as="xs:string" select="format-dateTime(if (atom:updated) then xs:dateTime(atom:updated) else current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')" />
	<xsl:text>&#xA;</xsl:text>
	<xsl:processing-instruction name="mso-application">progid="Excel.Sheet"</xsl:processing-instruction>
	<xsl:text>&#xA;</xsl:text>
	<Workbook>
		<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
			<Author>legislation.gov.uk</Author>
			<Created><xsl:value-of select="$saveDate" /></Created>
			<LastSaved><xsl:value-of select="$saveDate" /></LastSaved>
			<Version>12.00</Version>
		</DocumentProperties>
		<CustomDocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
		  <Identifier><xsl:value-of select="(//ukm:Metadata/dc:identifier[starts-with(.,'http://www.legislation.gov.uk/id/')])[1]"/></Identifier>
		  <Bound><xsl:value-of select="$bound"/></Bound>
		 </CustomDocumentProperties>
		<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
			<WindowHeight>5550</WindowHeight>
			<WindowWidth>19260</WindowWidth>
			<WindowTopX>-15</WindowTopX>
			<WindowTopY>-15</WindowTopY>
			<ProtectStructure>False</ProtectStructure>
			<ProtectWindows>False</ProtectWindows>
		</ExcelWorkbook>
		<Styles>
			<Style ss:ID="Default" ss:Name="Normal">
				<Alignment ss:Vertical="Bottom" />
				<Borders />
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="12" ss:Color="#000000" />
				<Interior />
				<NumberFormat />
				<Protection />
			</Style>
			<Style ss:ID="s62">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders />
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s68">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Bold="1" />
				<Interior ss:Color="#A5A5A5" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s70">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Bold="1" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s71">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Bold="1" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s72">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="3" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Bold="1" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s73">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Bold="1" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s74">
				<Alignment ss:Horizontal="Right" ss:Vertical="Center" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#A5A5A5" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s75">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s76">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s77">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#FCD5B4" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s78">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#E6B9B8" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s79">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#D7E4BC" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s80">
				<Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#BFBFBF" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s81">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#B6DDE8" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s82">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="3" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#B6DDE8" ss:Pattern="Solid" />
				<NumberFormat ss:Format="Short Date" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s83">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#B6DDE8" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s84">
				<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
				<Borders>
					<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
					<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3" />
					<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
				</Borders>
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior ss:Color="#B6DDE8" ss:Pattern="Solid" />
				<Protection ss:Protected="0" />
			</Style>
			<Style ss:ID="s88">
				<Alignment ss:Horizontal="Right" ss:Vertical="Center" />
				<Borders />
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
				<Interior />
				<Protection />
			</Style>
		 	<!-- non-bold link -->
			<Style ss:ID="s89" ss:Parent="s78">
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Bold="0" />
				<Protection/>
			</Style>
		 	<!-- italic link -->
			<Style ss:ID="s90" ss:Parent="s78">
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Italic="1" ss:Bold="0" />
				<Protection/>
			</Style>
			
			<xsl:if test="$extended='full-with-co'">
				<!-- new styles for alternate IF -->
				<Style ss:ID="s92">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="3" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#8DB4E2" ss:Pattern="Solid" />
					<Protection ss:Protected="0" />
				</Style>				
				<Style ss:ID="s94">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#8DB4E2" ss:Pattern="Solid" />
					<Protection ss:Protected="0" />
				</Style>			
				<Style ss:ID="s95">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#8DB4E2" ss:Pattern="Solid" />
					<NumberFormat ss:Format="Short Date" />
					<Protection ss:Protected="0" />
				</Style>			
				<Style ss:ID="s96">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#8DB4E2" ss:Pattern="Solid" />
					<Protection ss:Protected="0" />
				</Style>		
				
				<!-- new styles for alternate IF -->
				<Style ss:ID="s97">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="3" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#B8CCE4" ss:Pattern="Solid" />
					<Protection ss:Protected="0" />
				</Style>				
				<Style ss:ID="s98">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#B8CCE4" ss:Pattern="Solid" />
					<Protection ss:Protected="0" />
				</Style>			
				<Style ss:ID="s99">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#B8CCE4" ss:Pattern="Solid" />
					<NumberFormat ss:Format="Short Date" />
					<Protection ss:Protected="0" />
				</Style>			
				<Style ss:ID="s100">
					<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1" />
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" />
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="3" />
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" />
					</Borders>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" />
					<Interior ss:Color="#B8CCE4" ss:Pattern="Solid" />
					<Protection ss:Protected="0" />
				</Style>
			</xsl:if>
			<Style ss:ID="s101" ss:Parent="s78">
				<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="9" ss:Color="#FF0000" />
			</Style>
		</Styles>
		<Worksheet ss:Name="{$worksheet}">
			<Names>
				<NamedRange ss:Name="_FilterDatabase" ss:RefersTo="='{$worksheet}'!R4C2:R4C{$cols}"
					ss:Hidden="1" />
			</Names>
			<Table ss:ExpandedColumnCount="{$requiredCols}" ss:ExpandedRowCount="{$rows + 3}" x:FullColumns="1" x:FullRows="1"
				ss:StyleID="s62" ss:DefaultColumnWidth="60" ss:DefaultRowHeight="12">
				<Column ss:StyleID="s74" ss:AutoFitWidth="0" ss:Width="69" />
				<Column ss:StyleID="s75" ss:AutoFitWidth="0" ss:Width="69.75" />
				<Column ss:StyleID="s76" ss:AutoFitWidth="0" ss:Width="110.25" />
				<Column ss:StyleID="s77" ss:AutoFitWidth="0" ss:Width="99" />
				<xsl:if test="$direction = 'affected'">
					<Column ss:StyleID="s78" ss:AutoFitWidth="0" ss:Width="56.25" />
					<Column ss:StyleID="s78" ss:AutoFitWidth="0" ss:Width="56.25" />
					<Column ss:StyleID="s78" ss:AutoFitWidth="0" ss:Width="56.25" />
				</xsl:if>
				<xsl:if test="$direction = 'affecting'">
					<Column ss:Hidden="1" ss:StyleID="s79" ss:AutoFitWidth="0" ss:Width="56.25" />
					<Column ss:StyleID="s79" ss:AutoFitWidth="0" ss:Width="81" />
					<Column ss:StyleID="s79" ss:AutoFitWidth="0" ss:Width="69" />
				</xsl:if>
				<Column ss:StyleID="s76" ss:AutoFitWidth="0" ss:Width="90" />
				<Column ss:StyleID="s76" ss:AutoFitWidth="0" ss:Width="115.5" />
				<xsl:if test="$direction = 'affecting'">
					<Column ss:StyleID="s76" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="57.75" />
					<Column ss:StyleID="s77" ss:AutoFitWidth="0" ss:Width="94.5" />
					<Column ss:StyleID="s76" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="27.75" />
					<Column ss:StyleID="s76" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="27.75" />
					<Column ss:StyleID="s80" ss:AutoFitWidth="0" ss:Width="88.5" />
					<Column ss:StyleID="s80" ss:AutoFitWidth="0" ss:Width="88.5" />
					<Column ss:StyleID="s76" ss:AutoFitWidth="0" ss:Width="67.5" />
					<xsl:choose>
						<xsl:when test="$welshDocument">
							<Column ss:StyleID="s76" ss:AutoFitWidth="0" ss:Width="88.5" /></xsl:when>
						<xsl:otherwise>
							<Column ss:StyleID="s76" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="88.5" /></xsl:otherwise>
					</xsl:choose>
					<Column ss:StyleID="s77" ss:AutoFitWidth="0" ss:Width="93.75" />
					<Column ss:StyleID="s77" ss:AutoFitWidth="0" ss:Width="93.75" />
					<Column ss:StyleID="s81" ss:AutoFitWidth="0" ss:Width="81.75" />
					
					<xsl:for-each select="1 to $knockonIFsCount">
						<Column ss:StyleID="s82" ss:AutoFitWidth="0" ss:Width="55.5" />
						<Column ss:StyleID="s83" ss:AutoFitWidth="0" ss:Width="78.75" />
						<Column ss:StyleID="s84" ss:AutoFitWidth="0" ss:Width="78.75" />
					</xsl:for-each>
					
					<xsl:for-each select="($knockonIFsCount + 1) to 10">
						<Column ss:StyleID="s82" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="55.5" />
						<Column ss:StyleID="s83" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="78.75" />
						<Column ss:StyleID="s84" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="78.75" />
					</xsl:for-each>
					
					<xsl:if test="$extended='full-with-co'">
						<xsl:for-each select="1 to $knockonIFCOsCount">
							<xsl:choose>
								<xsl:when test="position() mod  2 = 0"> <!-- odd -->
									<Column ss:StyleID="s92" ss:AutoFitWidth="0" ss:Width="90" />
									<Column ss:StyleID="s94" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:AutoFitWidth="0" ss:Width="83.25" />					
									<Column ss:StyleID="s95" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:AutoFitWidth="0" ss:Width="83.25" />								
									<Column ss:StyleID="s96" ss:AutoFitWidth="0" ss:Width="95.25" />							
								</xsl:when>
								<xsl:otherwise> <!-- even -->
									<Column ss:StyleID="s97" ss:AutoFitWidth="0" ss:Width="90" />
									<Column ss:StyleID="s98" ss:AutoFitWidth="0" ss:Width="78.75" />
									<Column ss:StyleID="s98" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:AutoFitWidth="0" ss:Width="83.25" />								
									<Column ss:StyleID="s99" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:AutoFitWidth="0" ss:Width="83.25" />								
									<Column ss:StyleID="s100" ss:AutoFitWidth="0" ss:Width="95.25" />						
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<xsl:for-each select="($knockonIFCOsCount + 1) to ($knockonIFCOsCount + 5)">
							<xsl:choose>
								<xsl:when test="position() mod  2 = 0"> <!-- odd -->
									<Column ss:StyleID="s92" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="90" />
									<Column ss:StyleID="s94" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />					
									<Column ss:StyleID="s95" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s94" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />								
									<Column ss:StyleID="s96" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="95.25" />							
								</xsl:when>
								<xsl:otherwise> <!-- even -->
									<Column ss:StyleID="s97" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="90" />
									<Column ss:StyleID="s98" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="78.75" />
									<Column ss:StyleID="s98" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />								
									<Column ss:StyleID="s99" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />
									<Column ss:StyleID="s98" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="83.25" />								
									<Column ss:StyleID="s100" ss:Hidden="1" ss:AutoFitWidth="0" ss:Width="95.25" />						
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
				<xsl:for-each select="$cols to $requiredCols - 1">
					<Column ss:AutoFitWidth="1" />
				</xsl:for-each>
				<Row ss:Hidden="1">
					<xsl:for-each select="$effectExtents">
						<Cell><Data ss:Type="String"><xsl:value-of select="." /></Data></Cell>
					</xsl:for-each>
				</Row>
				<Row ss:Hidden="1">
					<xsl:for-each select="$territorialApplications">
						<Cell><Data ss:Type="String"><xsl:value-of select="." /></Data></Cell>
					</xsl:for-each>
				</Row>
				<Row ss:Hidden="1">
					<xsl:for-each select="$commencementQualifications">
						<Cell><Data ss:Type="String"><xsl:value-of select="." /></Data></Cell>
					</xsl:for-each>
				</Row>
				<Row ss:AutoFitHeight="0" ss:Height="36">
					<Cell ss:StyleID="s68">
						<Data ss:Type="String">Id</Data>
					</Cell>
					<Cell ss:StyleID="s70">
						<Data ss:Type="String">Affected Legislation</Data>
						<NamedCell ss:Name="_FilterDatabase" />
					</Cell>
					<Cell ss:StyleID="s70">
						<Data ss:Type="String">Affected provision(s)</Data>
						<NamedCell ss:Name="_FilterDatabase" />
					</Cell>
					<Cell ss:StyleID="s70">
						<Data ss:Type="String">Type of Effect</Data>
						<NamedCell ss:Name="_FilterDatabase" />
					</Cell>
					<xsl:if test="$direction = 'affected'">
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Affected Extent</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Affected Effects Extent</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Affected Territorial Application</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
					</xsl:if>
					<xsl:if test="$direction = 'affecting'">
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Affecting Provision Extent</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Affecting Extent</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Affecting Territorial Application</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
					</xsl:if>
					<Cell ss:StyleID="s70">
						<Data ss:Type="String">Affecting Legislation</Data>
						<NamedCell ss:Name="_FilterDatabase" />
					</Cell>
					<Cell ss:StyleID="s70">
						<Data ss:Type="String">Affecting Provision </Data>
						<NamedCell ss:Name="_FilterDatabase" />
					</Cell>
					<xsl:if test="$direction = 'affecting'">
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">RA Date</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Sav</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">U</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">R</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String"
								>COMMENTS for Editor</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Notes</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Amendment applied to Database</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Welsh Amendment applied to Database</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Suggested Commentary</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>
						<Cell ss:StyleID="s70">
							<Data ss:Type="String">Appended Commentary</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>						
						<Cell ss:StyleID="s71">
							<Data ss:Type="String">Commencement Authority</Data>
							<NamedCell ss:Name="_FilterDatabase" />
						</Cell>	
						<xsl:for-each select="1 to 10">
							<xsl:variable name="n" as="xs:integer" select="." />
							<Cell ss:StyleID="s72">
								<Data ss:Type="String">IF Date<xsl:value-of select="$n"/></Data>
								<NamedCell ss:Name="_FilterDatabase" />
							</Cell>
							<Cell ss:StyleID="s70">
								<Data ss:Type="String">IF Date<xsl:value-of select="$n"/> Qualification</Data>
								<NamedCell ss:Name="_FilterDatabase" />
							</Cell>
							<Cell ss:StyleID="s73">
								<Data ss:Type="String">IF Date<xsl:value-of select="$n"/>Other Qualification</Data>
								<NamedCell ss:Name="_FilterDatabase" />
							</Cell>
						</xsl:for-each>
						<xsl:if test="$extended='full-with-co'">
							<xsl:for-each select="1 to ($knockonIFCOsCount + 5)">
								<xsl:variable name="n" as="xs:integer" select="." />
								<Cell ss:StyleID="s72">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>Commencing Legislation</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>Commencing Provision</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>Sav</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>COMMENTS for Editor</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>								
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>Notes</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>									
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/></Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/> Qualification</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>
								<Cell ss:StyleID="s70">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>Other Qualification</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>
								<Cell ss:StyleID="s73">
									<Data ss:Type="String">IFCO Date<xsl:value-of select="$n"/>Appended Commentary</Data>
									<NamedCell ss:Name="_FilterDatabase" />
								</Cell>							
							</xsl:for-each>
						</xsl:if>
					</xsl:if>
				</Row>
				<xsl:choose>
					<xsl:when test="$desMarkedUp">
						<xsl:apply-templates select="//ukm:Effect | //ukm:UndefinedEffect[not(@Type = 'coming into force' and @AffectedURI = @AffectingURI)]" >
							<xsl:sort select="@AffectingProvisions" collation="http://saxon.sf.net/collation?alphanumeric=yes" />						
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="//ukm:Effect | //ukm:UndefinedEffect[not(@Type = 'coming into force' and @AffectedURI = @AffectingURI)]" />
					</xsl:otherwise>
				</xsl:choose>
			</Table>
			<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
				<PageSetup>
					<Header x:Margin="0.3" />
					<Footer x:Margin="0.3" />
					<PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75" />
				</PageSetup>
				<Unsynced />
				<Print>
					<ValidPrinterInfo />
					<PaperSizeIndex>9</PaperSizeIndex>
					<HorizontalResolution>600</HorizontalResolution>
					<VerticalResolution>0</VerticalResolution>
				</Print>
				<Zoom>110</Zoom>
				<Selected />
				<FreezePanes />
				<FrozenNoSplit />
				<SplitHorizontal>1</SplitHorizontal>
				<TopRowBottomPane>1</TopRowBottomPane>
				<ActivePane>2</ActivePane>
				<Panes>
					<Pane>
						<Number>3</Number>
					</Pane>
					<Pane>
						<Number>2</Number>
						<ActiveRow>11</ActiveRow>
						<ActiveCol>2</ActiveCol>
					</Pane>
				</Panes>
				<ProtectObjects>False</ProtectObjects>
				<ProtectScenarios>False</ProtectScenarios>
				<AllowInsertRows />
				<AllowDeleteRows />
				<AllowSort />
				<AllowFilter />
			</WorksheetOptions>
			<!-- affecting and affected extents -->
			<DataValidation xmlns="urn:schemas-microsoft-com:office:excel">
				<Range>
					<xsl:choose>
						<xsl:when test="$direction = 'affected' and $direction = 'affecting'">C5,C8</xsl:when>
						<xsl:otherwise>C5</xsl:otherwise>
					</xsl:choose>
				</Range>
				<Type>List</Type>
				<Value>R1C2:R1C16</Value>
			</DataValidation>
			<!-- affecting and affected effect extents -->
			<DataValidation xmlns="urn:schemas-microsoft-com:office:excel">
				<Range>
					<xsl:choose>
						<xsl:when test="$direction = 'affected' and $direction = 'affecting'">C6,C9</xsl:when>
						<xsl:otherwise>C6</xsl:otherwise>
					</xsl:choose>
				</Range>
				<Type>List</Type>
				<Value>R1C1:R1C<xsl:value-of select="count($effectExtents)" /></Value>
			</DataValidation>
			<!-- territorial extents -->
			<DataValidation xmlns="urn:schemas-microsoft-com:office:excel">
				<Range>
					<xsl:choose>
						<xsl:when test="$direction = 'affected' and $direction = 'affecting'">C7,C10</xsl:when>
						<xsl:otherwise>C7</xsl:otherwise>
					</xsl:choose>
				</Range>
				<Type>List</Type>
				<Value>R2C1:R2C<xsl:value-of select="count($territorialApplications)" /></Value>
			</DataValidation>
			<xsl:if test="$direction = 'affecting'">
				<!-- RA and IF dates -->
				<DataValidation xmlns="urn:schemas-microsoft-com:office:excel">
					<Range>
						<xsl:variable name="startIF" as="xs:integer" select="if($direction = 'affected') then 24 else 21"/>
						
						<xsl:variable name="columns" as="xs:string+">
							<xsl:for-each select="1 to 10">
								<xsl:variable name="n" as="xs:integer" select="." />											
								<xsl:value-of select="concat('C', $startIF + ($n * 3))"/>
							</xsl:for-each>
							<xsl:if test="$extended='full-with-co'">
								<xsl:for-each select="1 to ($knockonIFCOsCount + 5)">
									<xsl:variable name="n" as="xs:integer" select="." />											
									<xsl:value-of select="concat('C', $startIF + (10 * 3) + ($n * 9) - 4)"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						
						<xsl:value-of select="string-join((concat('C', $startIF - 11), concat('C', $startIF), $columns), ',')"/>
					</Range>
					<Type>Date</Type>
					<Qualifier>Greater</Qualifier>
					<Value>33270</Value>
					<ErrorStyle>Warn</ErrorStyle>
					<ErrorMessage>Dates should either be prosp or in the format dd/mm/yyyy.</ErrorMessage>
					<ErrorTitle>IF Date</ErrorTitle>
				</DataValidation>
				<!-- IF qualifications -->
				<DataValidation xmlns="urn:schemas-microsoft-com:office:excel">
					<Range>
						<xsl:variable name="startIF" as="xs:integer" select="if($direction = 'affected') then 22 else 19"/>
						
						<xsl:variable name="columns" as="xs:string+">
							<xsl:for-each select="1 to 10">
								<xsl:variable name="n" as="xs:integer" select="." />											
								<xsl:value-of select="concat('C', $startIF + ($n * 3))"/>
							</xsl:for-each>
							<xsl:if test="$extended='full-with-co'">
								<xsl:for-each select="1 to ($knockonIFCOsCount + 5)">
									<xsl:variable name="n" as="xs:integer" select="." />											
									<xsl:value-of select="concat('C', $startIF + (10 * 3) + ($n * 9) - 1)"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						
						<xsl:value-of select="string-join(($columns), ',')"/>
						
						<!--<xsl:choose>
							<xsl:when test="$direction = 'affected'">C24,C27,C30,C33,C36,C39,C42,C45,C48,C51</xsl:when>
							<xsl:otherwise>C21,C24,C27,C30,C33,C36,C39,C42,C45,C48</xsl:otherwise>
						</xsl:choose>-->
					</Range>
					<Type>List</Type>
					<Value>R3C1:R3C<xsl:value-of select="count($commencementQualifications)" /></Value>
					<ErrorMessage>Select an option from the list</ErrorMessage>
					<ErrorTitle>Qualification</ErrorTitle>
				</DataValidation>
			</xsl:if>
			<!-- effect ids -->
			<DataValidation xmlns="urn:schemas-microsoft-com:office:excel">
				<Range>C1</Range>
				<Type>Custom</Type>
				<ComboHide />
				<Value>FALSE</Value>
				<InputHide />
				<ErrorMessage>Do not change effect IDs. When you create a new effect, leave the ID blank. A new ID will be automatically created for it.</ErrorMessage>
				<ErrorTitle>Effect IDs</ErrorTitle>
			</DataValidation>
			<AutoFilter x:Range="R4C2:R4C{$cols}" xmlns="urn:schemas-microsoft-com:office:excel"> </AutoFilter>
			<ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">
				<Range>C1</Range>
				<Condition>
					<Value1>AND(COUNTIF(R5C1:R<xsl:value-of select="$rows + 3" />C1, RC)&gt;1,NOT(ISBLANK(RC)))</Value1>
					<Format Style="color:#9C0006" />
				</Condition>
			</ConditionalFormatting>
		</Worksheet>
		<Worksheet ss:Name="Effects">
			<Table  ss:ExpandedRowCount="{$nEffects}" x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="60" ss:DefaultRowHeight="15">
				<Column ss:AutoFitWidth="0" ss:Width="77.25" />
				<xsl:for-each select="//ukm:Effect | //ukm:UndefinedEffect">
					<xsl:variable name="uri" as="xs:string?">
						<xsl:apply-templates select="." mode="uri" />
					</xsl:variable>
					<xsl:if test="exists($uri)">
						<Row ss:AutoFitHeight="0">
							<Cell>
								<Data ss:Type="String">
									<xsl:value-of select="$uri" />
								</Data>
							</Cell>
						</Row>
					</xsl:if>
				</xsl:for-each>
			</Table>
			<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
				<Visible>SheetVeryHidden</Visible>
			</WorksheetOptions>
		</Worksheet>
	</Workbook>
</xsl:template>

<xsl:template match="atom:entry">
	<xsl:apply-templates select="ukm:Effect" />
</xsl:template>

<xsl:template match="ukm:Effect | //ukm:UndefinedEffect[not(@Type = 'coming into force' and @AffectedURI = @AffectingURI)]">
	<xsl:variable name="affectedSections" as="element(ukm:Section)*" select="ukm:AffectedProvisions//ukm:Section[not(some $s in (../ukm:Section except .) satisfies starts-with($s/@Ref, @Ref))]" />
	<xsl:variable name="affectingSections" as="element(ukm:Section)*" select="ukm:AffectingProvisions//ukm:Section[not(some $s in (../ukm:Section except .) satisfies starts-with($s/@Ref, @Ref))]" />
	<xsl:variable name="affectedExtentInfo" as="element(sparql:result)*" select="$affectedSections/tso:sectionInfo(@URI, 'extent')" />
	<xsl:variable name="affectingExtentInfo" as="element(sparql:result)*" select="$affectingSections/tso:sectionInfo(@URI, 'extent')" />
	<xsl:variable name="effectExtentInfo" as="element(sparql:result)*" select="$affectingSections/tso:sectionInfo(@URI, 'effectExtent')" />
	<xsl:variable name="territoryInfo" as="element(sparql:result)*" select="$affectingSections/tso:sectionInfo(@URI, 'territory')" />
	<xsl:variable name="commencementInfo" as="element(sparql:result)*" select="tso:sectionInfo($affectingSections)[sparql:binding[@name = ('commencement', 'commencementAuthority')]]" />
	<xsl:variable name="affectedExtent" as="xs:string*" select="distinct-values($affectedExtentInfo/sparql:binding[@name = 'extent'])" />
	<xsl:variable name="affectedExtentContext" as="xs:string*" select="distinct-values($affectedExtentInfo/sparql:binding[@name = 'section'])" />
	<xsl:variable name="affectingExtent" as="xs:string*" select="distinct-values($affectingExtentInfo/sparql:binding[@name = 'extent'])" />
	<xsl:variable name="affectingExtentContext" as="xs:string*" select="distinct-values($affectingExtentInfo/sparql:binding[@name = 'section'])" />
	<xsl:variable name="effectExtent" as="xs:string*" select="distinct-values($effectExtentInfo/sparql:binding[@name = 'effectExtent'])" />
	<xsl:variable name="effectExtentContext" as="xs:string*" select="distinct-values($effectExtentInfo/sparql:binding[@name = 'section'])" />
	<xsl:variable name="territory" as="xs:string*" select="distinct-values($territoryInfo/sparql:binding[@name = 'territory'])" />
	<xsl:variable name="territoryContext" as="xs:string*" select="distinct-values($territoryInfo/sparql:binding[@name = 'section'])" />
	<xsl:variable name="effectId" as="xs:string?" select="@EffectId" />
	<xsl:variable name="rdfComments" as="element(rdf:Description)*" select="$effectsComments//rdf:Description[substring-after(@rdf:about , 'http://www.legislation.gov.uk/id/effect/') = $effectId]" />
	<xsl:variable name="comm" as="xs:string*" select="@Comments" />
	<xsl:variable name="effectsCommentsValues" as="xs:string*" >
		<xsl:value-of select="$comm" />
		<xsl:for-each select="$rdfComments/task:editorComments">
			<xsl:value-of select="if ($comm != '') then concat(' - ', .) else ." />
		</xsl:for-each>
	</xsl:variable>
	<Row ss:AutoFitHeight="0">
		<!-- 1: URI -->
		<Cell>
			<Data ss:Type="String"><xsl:apply-templates select="." mode="uri" /></Data>
		</Cell>
		<!-- 2: Affected Legislation -->
		<xsl:choose>
			<xsl:when test="@RequiresApplied = 'true' and $effectsComments/rdf:RDF and @Applied = 'false'">
				<Cell ss:StyleID="s101">
					<Data ss:Type="String">
						<xsl:choose>
							<xsl:when test="@AffectedClass and @AffectedYear and @AffectedNumber">
								<xsl:value-of select="tso:toesReference(@AffectedClass, @AffectedYear, @AffectedNumber)" />
							</xsl:when>
							<xsl:when test="@AffectedName">
								<xsl:value-of select="@AffectedName" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-after(@AffectedURI, 'http://www.legislation.gov.uk/id/')" />
							</xsl:otherwise>
						</xsl:choose>
					</Data>
				</Cell>
			</xsl:when>
			<xsl:otherwise>
				<Cell>
					<Data ss:Type="String">
						<xsl:choose>
							<xsl:when test="@AffectedClass and @AffectedYear and @AffectedNumber">
								<xsl:value-of select="tso:toesReference(@AffectedClass, @AffectedYear, @AffectedNumber)" />
							</xsl:when>
							<xsl:when test="@AffectedName">
								<xsl:choose>
									<xsl:when test="@AffectedClass='EuropeanUnionTreaty'"><xsl:value-of select="tso:TitleCase(translate(@AffectedName,'-', ' '))" /></xsl:when>
									<xsl:otherwise><xsl:value-of select="tso:TitleCase(replace(@AffectedName,'-', ' '))" /></xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-after(@AffectedURI, 'http://www.legislation.gov.uk/id/')" />
							</xsl:otherwise>
						</xsl:choose>
					</Data>
				</Cell>
			</xsl:otherwise>
		</xsl:choose>
		<!-- 3: Affected Provision -->
		<Cell>
			<Data ss:Type="String">
				<xsl:apply-templates select="@AffectedProvisions" />
			</Data>
		</Cell>
		<!-- 4: Type -->
		<Cell>
			<Data ss:Type="String">
				<xsl:apply-templates select="@Type" />
			</Data>
		</Cell>
		<xsl:if test="$direction = 'affected'">
			<!-- 5: Affected Extent -->
			<Cell>
				<xsl:variable name="link" as="xs:string?"
					select="if ($affectedExtentInfo/sparql:binding[@name = 'extentAuthority']) then 
					          ($affectedExtentInfo/sparql:binding[@name = 'extentAuthority']/sparql:uri)[1] 
					        else if (@AffectedExtentSections) then 
					          tokenize(@AffectedExtentSections, ' ')[1] else ()" />
				<xsl:choose>
					<xsl:when test="@AffectedExtent">
						<xsl:apply-templates select="@AffectedExtent" />
					</xsl:when>
					<xsl:when test="$affectedExtentInfo">
						<Comment>
							<ss:Data>
								<xsl:text>From research</xsl:text>
								<xsl:if test="exists($affectedExtentContext)">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="for $c in $affectedExtentContext return tso:sectionReference($c, @AffectedURI)" separator=", " />
									<xsl:text> has an extent of </xsl:text>
									<xsl:value-of select="for $e in $affectedExtent return substring-after($e, $leg)" separator=" / " />
								</xsl:if>
							</ss:Data>
						</Comment>
						<Data ss:Type="String">
							<xsl:for-each select="$affectedExtent">
								<xsl:variable name="extent" as="xs:string" select="substring-after(., $leg)" />
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:value-of select="$extent" />
							</xsl:for-each>
						</Data>
					</xsl:when>
					<xsl:when test="ukm:AffectedProvisions//ukm:Section/@Extent">
						<xsl:choose>
							<xsl:when test="$affectedSections/@ExtentStatus = 'Annotated'" />
							<xsl:when test="$affectedSections/@ExtentStatus = 'Inherited'">
								<xsl:if test="exists($link)">
									<xsl:attribute name="ss:StyleID" select="'s89'" />
									<xsl:attribute name="ss:HRef" select="$link" />
								</xsl:if>
								<Comment><ss:Data>Inherited from ancestor section</ss:Data></Comment>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="exists($link)">
									<xsl:attribute name="ss:StyleID" select="'s90'" />
									<xsl:attribute name="ss:HRef" select="$link" />
								</xsl:if>
								<Comment><ss:Data>Derived from type of legislation</ss:Data></Comment>
							</xsl:otherwise>
						</xsl:choose>
						<Data ss:Type="String">
							<xsl:for-each select="distinct-values($affectedSections/@Extent)">
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:value-of select="replace(., 'N.I.', 'NI')" />
							</xsl:for-each>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 6: Affected Effects Extent -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@AffectedEffectsExtent">
						<xsl:apply-templates select="@AffectedEffectsExtent" />
					</xsl:when>
					<xsl:when test="$effectExtentInfo">
						<Comment>
							<ss:Data>
								<xsl:text>From research</xsl:text>
								<xsl:if test="exists($effectExtentContext)">
									<xsl:text>: effects within </xsl:text>
									<xsl:value-of select="for $c in $effectExtentContext return tso:sectionReference($c, @AffectedURI)" separator=", " />
									<xsl:text> have </xsl:text>
									<xsl:for-each select="$effectExtent">
										<xsl:choose>
											<xsl:when test=". = $leg:coextensive">the same extent as the affected provision</xsl:when>
											<xsl:otherwise><xsl:value-of select="substring-after(., $leg)" /></xsl:otherwise>
										</xsl:choose>
										<xsl:if test="position() != last()"> / </xsl:if>
									</xsl:for-each>
								</xsl:if>
							</ss:Data>
						</Comment>
						<Data ss:Type="String">
							<xsl:for-each select="$affectingExtent">
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:choose>
									<xsl:when test=". = $leg:coextensive">Same as affected</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="extent" as="xs:string" select="substring-after(., $leg)" />
										<xsl:value-of select="$extent" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 7: Affected Territorial Extent -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@AffectedTerritorialApplication">
						<xsl:apply-templates select="@AffectedTerritorialApplication" />
					</xsl:when>
					<xsl:when test="$territoryInfo">
						<Comment>
							<ss:Data>
								<xsl:text>From research</xsl:text>
								<xsl:if test="exists($territoryContext)">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="for $c in $effectExtentContext return tso:sectionReference($c, @AffectedURI)" separator=", " />
									<xsl:text> has a territorial application of </xsl:text>
									<xsl:value-of select="for $e in $territory return substring-after($e, $leg)" separator=" / " />
								</xsl:if>
							</ss:Data>
						</Comment>
						<Data ss:Type="String">
							<xsl:for-each select="$affectingExtent">
								<xsl:variable name="extent" as="xs:string" select="substring-after(., $leg)" />
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:value-of select="$extent" />
							</xsl:for-each>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
		</xsl:if>
		<xsl:if test="$direction = 'affecting'">
			<!-- 8: Affecting Provision Extent -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@AffectingExtent">
						<xsl:apply-templates select="@AffectingExtent" />
					</xsl:when>
					<xsl:when test="$affectingExtentInfo">
						<Comment>
							<ss:Data>
								<xsl:text>From research</xsl:text>
								<xsl:if test="exists($affectingExtentContext)">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="for $c in $affectingExtentContext return tso:sectionReference($c, @AffectingURI)" separator=", " />
									<xsl:text> has an extent of </xsl:text>
									<xsl:value-of select="for $e in $affectingExtent return substring-after($e, $leg)" separator=" / " />
								</xsl:if>
							</ss:Data>
						</Comment>
						<Data ss:Type="String">
							<xsl:for-each select="$affectingExtent">
								<xsl:variable name="extent" as="xs:string" select="substring-after(., $leg)" />
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:value-of select="$extent" />
							</xsl:for-each>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 9: Affecting Extent -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@AffectingEffectsExtent">
						<xsl:apply-templates select="@AffectingEffectsExtent" />
					</xsl:when>
					<xsl:when test="$effectExtentInfo">
						<Comment>
							<ss:Data>
								<xsl:text>From research</xsl:text>
								<xsl:if test="exists($effectExtentContext)">
									<xsl:text>: effects within </xsl:text>
									<xsl:value-of select="for $c in $effectExtentContext return tso:sectionReference($c, @AffectingURI)" separator=", " />
									<xsl:text> have </xsl:text>
									<xsl:for-each select="$effectExtent">
										<xsl:choose>
											<xsl:when test=". = $leg:coextensive">the same extent as the affected provision</xsl:when>
											<xsl:otherwise><xsl:value-of select="substring-after(., $leg)" /></xsl:otherwise>
										</xsl:choose>
										<xsl:if test="position() != last()"> / </xsl:if>
									</xsl:for-each>
								</xsl:if>
							</ss:Data>
						</Comment>
						<Data ss:Type="String">
							<xsl:for-each select="$affectingExtent">
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:choose>
									<xsl:when test=". = $leg:coextensive">Same as affected</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="extent" as="xs:string" select="substring-after(., $leg)" />
										<xsl:value-of select="$extent" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 10: Affecting Territorial Application -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@AffectingTerritorialApplication">
						<xsl:apply-templates select="@AffectingTerritorialApplication" />
					</xsl:when>
					<xsl:when test="$territoryInfo">
						<Comment>
							<ss:Data>
								<xsl:text>From research</xsl:text>
								<xsl:if test="exists($territoryContext)">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="for $c in $effectExtentContext return tso:sectionReference($c, @AffectingURI)" separator=", " />
									<xsl:text> has a territorial application of </xsl:text>
									<xsl:value-of select="for $e in $territory return substring-after($e, $leg)" separator=" / " />
								</xsl:if>
							</ss:Data>
						</Comment>
						<Data ss:Type="String">
							<xsl:for-each select="$affectingExtent">
								<xsl:variable name="extent" as="xs:string" select="substring-after(., $leg)" />
								<xsl:if test="position() > 1"> / </xsl:if>
								<xsl:value-of select="$extent" />
							</xsl:for-each>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
		</xsl:if>
		<!-- 11: Affecting Legislation -->
		<Cell>
			<Data ss:Type="String">
				<xsl:choose>
					<xsl:when test="@AffectingClass='EuropeanUnionOther'">
						<xsl:value-of select="concat(@AffectingURI, '?legislation=',@AffectingClass,':', @AffectingYear,':', @AffectingNumber)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="tso:toesReference(@AffectingClass, @AffectingYear, @AffectingNumber)" />
					</xsl:otherwise>
				</xsl:choose>
			</Data>
		</Cell>
		<!-- 12: Affecting Provision -->
		<Cell>
			<Data ss:Type="String">
				<xsl:apply-templates select="@AffectingProvisions" />
			</Data>
		</Cell>
		<xsl:if test="$direction = 'affecting'">
			<!-- 13: RA Date -->
			<Cell>
				<xsl:variable name="legislationInfo" as="element(sparql:result)*" select="tso:legislationInfo(@AffectingURI)[sparql:binding[@name = 'creation']]" />
				<xsl:choose>
					<xsl:when test="exists($legislationInfo)">
						<Data ss:Type="DateTime">
							<xsl:value-of select="($legislationInfo/sparql:binding[@name = 'creation'])[1]" />
							<xsl:text>T00:00:00.000</xsl:text>
						</Data>
					</xsl:when>
					<xsl:when test="@AffectingRoyalAssent">
						<Data ss:Type="DateTime">
							<xsl:value-of select="@AffectingRoyalAssent" />
							<xsl:text>T00:00:00.000</xsl:text>
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 14: Savings -->
			<Cell>
				<Data ss:Type="String">
					<xsl:apply-templates select="ukm:Savings" />
				</Data>
			</Cell>
			<!-- 15: U -->
			<Cell />
			<!-- 16: R -->
			<Cell />
			<!-- 17: Comments for editor -->
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="$effectsCommentsValues" />
				</Data>
			</Cell>
			<!-- 18: Notes -->
			<Cell>
				<xsl:apply-templates select="@Notes" />
			</Cell>
			<!-- 19: Amendment applied -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@RequiresApplied = 'false' ">
						<Data ss:Type="String">N</Data>
					</xsl:when>
					<xsl:when test="@Applied = 'true' ">
						<Data ss:Type="String">Y</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 20: Welsh Amendment applied -->
			<Cell>
				<xsl:choose>
					<xsl:when test="@RequiresWelshApplied = 'false' ">
						<Data ss:Type="String">N</Data>
					</xsl:when>
					<xsl:when test="@WelshApplied = 'true' ">
						<Data ss:Type="String">Y</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<!-- 21: Suggested commentary -->
			<Cell>
				<xsl:apply-templates select="@SuggestedCommentary" />
			</Cell>
			<!-- 22: Appended commentary -->
			<Cell>
				<xsl:apply-templates select="@AppendedCommentary" />
			</Cell>			
			<!-- 23: Commencement authority -->
			<Cell>
				<xsl:choose>
					<xsl:when test="ukm:CommencementAuthority">
						<Data ss:Type="String">
							<xsl:apply-templates select="ukm:CommencementAuthority" />
						</Data>
					</xsl:when>
					<xsl:when test="$commencementInfo">
						<Data ss:Type="String">
							<xsl:value-of select="for $c in distinct-values($commencementInfo/sparql:binding[@name = 'commencementAuthority']) return tso:sectionReference($c, @AffectingURI)" />
						</Data>
					</xsl:when>
				</xsl:choose>
			</Cell>
			<xsl:choose>
				<xsl:when test="ukm:InForceDates/ukm:InForce">
					<xsl:apply-templates select="ukm:InForceDates" mode="inForce" />
				</xsl:when>
				<xsl:when test="exists($commencementInfo)">
					<xsl:for-each select="1 to 10">
						<xsl:variable name="n" as="xs:integer" select="." />
						<xsl:variable name="commencementInfo" as="element(sparql:result)?" select="$commencementInfo[$n]" />
						<xsl:choose>
							<xsl:when test="exists($commencementInfo)">
								<!-- IF Date -->
								<Cell>
									<xsl:choose>
										<xsl:when test="$commencementInfo/sparql:binding['commencementDate']">
											<Data ss:Type="DateTime">
												<xsl:value-of select="$commencementInfo/sparql:binding['commencementDate']" />
											</Data>
										</xsl:when>
										<xsl:otherwise>
											<Data ss:Type="String">prosp</Data>
										</xsl:otherwise>
									</xsl:choose>
								</Cell>
								<!-- IF Date Qualification --> 
								<Cell>
									<!-- TODO -->
								</Cell>
								<!-- IF Date Other Qualification -->
								<Cell>
									<!-- TODO -->
								</Cell>
							</xsl:when>
							<xsl:otherwise>
								<Cell />
								<Cell />
								<Cell />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
					<Cell />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</Row>
</xsl:template>

<!--
So, sections have 4 digits – 0001, 0001A, A1 (NB provision numbers beginning with letters are not given extra zeroes and letters at the end of provision numbers don’t affect the number of zeroes before it (e.g. 0001A, 0001ZA, 0001XYZA)
Other provisions (i.e. arts., regs., paras.) have 3 digits – 001, 001A, A1
Parent provisions (e.g. Schs., Pts., Chs.) have two digits – 01, 01A, A1 (so, for example, it would be Sch. 01 para. 001(01))
And other miscellaneous provisions (e.g. Tables, Appendices, Notes, Groups, Matters, Fields, Items, etc) have 2 digits – 01, 01A, A1
All sub-provisions have 2 digits – (01), (01A), (A1)
-->

<xsl:template match="@AffectingProvisions | @AffectedProvisions | @Type | ukm:Savings | ukm:CommencementAuthority | ukm:CommencingProvisions/ukm:Section">
	<xsl:if test="preceding-sibling::ukm:Section"><xsl:text> </xsl:text></xsl:if>	
	<xsl:analyze-string select="normalize-space(.)" regex="((Pts?\.|Chs?\.|Schs?\.|Annexe?s?)|(ss?\.)|(paras?\.|regs?\.|arts?\.|Arts?\.|rules?)) ([0-9]+)">
		<xsl:matching-substring>
			<xsl:variable name="format" as="xs:string"
				select="if (regex-group(2) != '') then '00'
				        else if (regex-group(3) != '') then '0000' 
				        else '000'" />
			<xsl:value-of select="regex-group(1)" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="format-number(xs:integer(regex-group(5)), $format)" />
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:analyze-string select="." regex="\(([0-9]+)([^)]*)\)">
				<xsl:matching-substring>
					<xsl:text>(</xsl:text>
					<xsl:value-of select="format-number(xs:integer(regex-group(1)), '00')" />
					<xsl:value-of select="regex-group(2)" />
					<xsl:text>)</xsl:text>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="." />
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:template>

<!-- Seperate template for commencingsavings to start with-->
<xsl:template match="ukm:CommencingSavings//ukm:Section">
	<xsl:if test="preceding-sibling::ukm:SectionRange"><xsl:text> </xsl:text></xsl:if>	
	<xsl:if test="preceding-sibling::ukm:Section"><xsl:text> </xsl:text></xsl:if>
	<xsl:analyze-string select="normalize-space(.)" regex="((Pts?\.|Chs?\.|Schs?\.)|(ss?\.)|(paras?\.|regs?\.|arts?\.|rules?)) ([0-9]+)">
		<xsl:matching-substring>
			<xsl:variable name="format" as="xs:string"
				select="if (regex-group(2) != '') then '00'
				        else if (regex-group(3) != '') then '0000' 
				        else '000'" />
			<xsl:value-of select="regex-group(1)" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="format-number(xs:integer(regex-group(5)), $format)" />
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:analyze-string select="." regex="\(([0-9]+)([^)]*)\)">
				<xsl:matching-substring>
					<xsl:text>(</xsl:text>
					<xsl:value-of select="format-number(xs:integer(regex-group(1)), '00')" />
					<xsl:value-of select="regex-group(2)" />
					<xsl:text>)</xsl:text>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:analyze-string select="." regex="([0-9]+)">
					<xsl:matching-substring><xsl:variable name="format" as="xs:string"
					select="if (regex-group(2) != '') then '00'
							else if (regex-group(3) != '') then '0000' 
							else '000'" /><xsl:text> </xsl:text><xsl:value-of select="format-number(xs:integer(regex-group(1)), $format)" /></xsl:matching-substring>
					<xsl:non-matching-substring><xsl:value-of select="." /></xsl:non-matching-substring>
				</xsl:analyze-string>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:template>

<xsl:template match="@AffectedExtent | @AffectedEffectsExtent | @AffectedTerritorialApplication |
	                   @AffectingExtent | @AffectingEffectsExtent | @AffectingTerritorialApplication |
	                   @Comments | @Notes | @SuggestedCommentary | @AppendedCommentary | @Qualification | @OtherQualification">
	<Data ss:Type="String">
		<xsl:value-of select="." />
	</Data>
</xsl:template>

<xsl:template match="ukm:Effect[@URI] | ukm:UndefinedEffect[@URI]" mode="uri" priority="10">
	<xsl:choose>
		<xsl:when test="@EffectId"><xsl:value-of select="@EffectId"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="substring-after(@URI, '/id/effect/')" /></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ukm:Effect[@Row] | ukm:UndefinedEffect[@Row]" mode="uri">
	<xsl:choose>
		<xsl:when test="@EffectId"><xsl:value-of select="@EffectId"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="concat('toes-', @AffectingYear, '-', @Row)" /></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ukm:Effect | ukm:UndefinedEffect" mode="uri" />

<xsl:template match="ukm:InForceDates" mode="inForce">
	<xsl:variable name="inForceDates" select=".[ukm:InForce[not(@CommencingURI)]]" />
	<xsl:variable name="inForce" as="element(ukm:InForce)*" select="$inForceDates/ukm:InForce[not(@CommencingURI)]" />
	
	<xsl:for-each select="1 to 10">
		<xsl:variable name="n" as="xs:integer" select="." />
		<xsl:variable name="inForce" as="element(ukm:InForce)?" select="$inForce[$n]" />
		<xsl:choose>
			<xsl:when test="exists($inForce)">
				<!-- IF Date -->
				<Cell>
					<xsl:choose>
						<xsl:when test="$inForce/@Date">
							<Data ss:Type="DateTime">
								<xsl:value-of select="$inForce/@Date" />
							</Data>
						</xsl:when>
						<xsl:otherwise>
							<Data ss:Type="String">prosp</Data>
						</xsl:otherwise>
					</xsl:choose>
				</Cell>
				<!-- IF Date Qualification --> 
				<Cell>
					<xsl:apply-templates select="$inForce/@Qualification" />
				</Cell>
				<!-- IF Date Other Qualification -->
				<Cell>
					<xsl:apply-templates select="$inForce/@OtherQualification" />
				</Cell>
			</xsl:when>
			<xsl:otherwise>
				<!-- IF Date -->
				<Cell />
				<!-- IF Date Qualification --> 
				<Cell />
				<!-- IF Date Other Qualification -->
				<Cell />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
	
	<xsl:if test="$extended='full-with-co'">
		<xsl:variable name="inForceCommencing" as="element(ukm:InForce)*" select="ukm:InForce[@CommencingURI]" />
			<xsl:variable name="inForceCommencingSorted" as="element(ukm:InForce)*">
				<xsl:for-each-group select="$inForceCommencing" group-by="concat(@Date, ' ', @CommencingURI, ' ', /ukm:CommencingProvisions/node(), ' ', @Qualification, ' ', @OtherQualification, ' ', @Comments)" >
						<xsl:sort select="xs:date(@Date)" />
						<xsl:sequence select="." />
					</xsl:for-each-group>
			</xsl:variable>

		<xsl:for-each select="1 to ($knockonIFCOsCount + 5)">
			<xsl:variable name="n" as="xs:integer" select="." />
			<!-- to display the IFCO in chronological order of IFCO dates-->
		
			<xsl:variable name="inForce" as="element(ukm:InForce)?" select="$inForceCommencingSorted[$n]" />
			<xsl:choose>
				<xsl:when test="exists($inForce)">
					<!-- IFCO Date Commencing Legislation -->
					<!-- commencing legislations should include correct legislation type. or it will end up in error-->
					<Cell>
						
						<Data ss:Type="String">
							<xsl:choose>
								<xsl:when test="$inForce/@CommencingClass and $inForce/@CommencingYear and $inForce/@CommencingNumber">
									<xsl:value-of select="tso:toesReference($inForce/@CommencingClass, $inForce/@CommencingYear, $inForce/@CommencingNumber)" />
								</xsl:when>
								<xsl:when test="$inForce/@AffectingClass and $inForce/@CommencingYear and $inForce/@CommencingNumber">
									<xsl:value-of select="tso:toesReference($inForce/@AffectingClass, $inForce/@CommencingYear, $inForce/@CommencingNumber)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-after($inForce/@CommencingURI, 'http://www.legislation.gov.uk/id/')" />
								</xsl:otherwise>
							</xsl:choose>
						</Data>
					</Cell>
					<!-- IFCO Date Commencing Provision --> 
					<Cell>
						<Data ss:Type="String">
							<xsl:choose>
								<xsl:when test="$inForce/ukm:CommencingProvisions/ukm:Section" ><xsl:apply-templates select="$inForce/ukm:CommencingProvisions/ukm:Section" /></xsl:when>
								<xsl:otherwise><xsl:value-of select="$inForce/ukm:CommencingProvisions" /></xsl:otherwise>
							</xsl:choose>
							
						</Data>
					</Cell>
					<!-- IFCO Date Savings -->
					<Cell>
						<Data ss:Type="String">
							<xsl:variable name="commencingSavings" ><xsl:apply-templates select="$inForce/ukm:CommencingSavings" /></xsl:variable>
							<xsl:value-of select="normalize-space($commencingSavings)" />
								
						</Data>
					</Cell>
					<!-- IFCO Date Comments for Editor -->
					<Cell>
						<xsl:apply-templates select="$inForce/@Comments" />
					</Cell>
					<!-- IFCO Date Notes -->
					<Cell>
						<xsl:apply-templates select="$inForce/@Notes" />
					</Cell>
					<!-- IFCO Date -->
					<Cell>
						<Data ss:Type="DateTime">
							<xsl:apply-templates select="$inForce/@Date" />
						</Data>
					</Cell>
					<!-- IFCO Date Qualification -->
					<Cell>
						<xsl:apply-templates select="$inForce/@Qualification" />
					</Cell>
					<!-- IFCO Date Other Qualification -->
					<Cell>
						<xsl:apply-templates select="$inForce/@OtherQualification" />
					</Cell>
					<!-- IFCO Date Appended Commentary -->
					<Cell>
						<xsl:apply-templates select="$inForce/@AppendedCommentary" />
					</Cell>
				</xsl:when>
				<xsl:otherwise>
					<!-- IFCO Date Commencing Legislation -->
					<Cell />
					<!-- IFCO Date Commencing Provision --> 
					<Cell />
					<!-- IFCO Date Savings -->
					<Cell />
					<!-- IFCO Date Comments for Editor -->
					<Cell />
					<!-- IFCO Date Notes -->
					<Cell />
					<!-- IFCO Date -->
					<Cell />
					<!-- IFCO Date Qualification -->
					<Cell />
					<!-- IFCO Date Other Qualification -->
					<Cell />
					<!-- IFCO Date Appended Commentary -->
					<Cell />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:function name="tso:sectionReference" as="xs:string">
	<xsl:param name="uri" as="xs:string" />
	<xsl:param name="legislation" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$uri = $legislation">
			<xsl:variable name="type" as="xs:string" select="substring-before(substring-after($legislation, '/id/'), '/')" />
			<xsl:sequence select="concat('the ', tso:GetCategory(tso:getClass($type)))" />
		</xsl:when>
		<xsl:when test="starts-with($uri, $legislation)">
			<xsl:sequence select="tso:formatSection(substring-after($uri, concat($legislation, '/')), '/')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$uri" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:toesReference">
	<xsl:param name="class" as="xs:string" />
	<xsl:param name="year" as="xs:integer" />
	<xsl:param name="number" as="xs:integer" />
	<xsl:variable name="type" as="element(tso:legType)?" select="tso:getType($class, ())" />
	<xsl:value-of select="$year" />
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="$class = 'UnitedKingdomPublicGeneralAct'">c. </xsl:when>
		<xsl:when test="$class = 'UnitedKingdomLocalAct'">c. </xsl:when>
		<xsl:when test="$class = 'UnitedKingdomPrivateOrPersonalAct'">c. </xsl:when>
		<xsl:when test="$class = 'GreatBritainPrivateOrPersonalAct'">c. </xsl:when>
		<xsl:when test="$class = 'GreatBritainLocalAct'">c. </xsl:when>
		<xsl:when test="$class = 'GreatBritainAct'">c. </xsl:when>
		<xsl:when test="$class = 'EnglandAct'">c. </xsl:when>
		<xsl:when test="$class = 'ScottishAct'">asp</xsl:when>
		<xsl:when test="$class = 'IrelandAct'">c. </xsl:when>
		<xsl:when test="$class = 'ScottishOldAct'">c. </xsl:when>
		<xsl:when test="$class = 'WelshAssemblyMeasure'">nawm</xsl:when>
		<xsl:when test="$class = 'UnitedKingdomChurchMeasure'">gsm</xsl:when>
		<xsl:when test="$class = 'NorthernIrelandAct'">c. </xsl:when>
		<xsl:when test="$class = 'NorthernIrelandAssemblyMeasure'">c. </xsl:when>
		<xsl:when test="$class = 'NorthernIrelandParliamentAct'">c. </xsl:when>
		<xsl:when test="$class = 'UnitedKingdomStatutoryInstrument'">SI</xsl:when>
		<xsl:when test="$class = 'UnitedKingdomStatutoryRuleOrOrder'">SRO</xsl:when>
		<xsl:when test="$class = 'WelshStatutoryInstrument'">WSI</xsl:when>
		<xsl:when test="$class = 'ScottishStatutoryInstrument'">SSI</xsl:when>
		<xsl:when test="$class = 'NorthernIrelandOrderInCouncil'">SI</xsl:when>
		<xsl:when test="$class = 'NorthernIrelandStatutoryRule'">SR</xsl:when>
		<xsl:when test="$class = 'UnitedKingdomChurchInstrument'">AI</xsl:when>
		<xsl:when test="$class = 'WelshNationalAssemblyAct'">anaw</xsl:when>
		<xsl:when test="$class = 'WelshParliamentAct'">asc</xsl:when>
		<xsl:when test="$class = 'EuropeanUnionTreaty'">EUT</xsl:when>
		<xsl:when test="$class = 'EuropeanUnionRegulation'">EUR</xsl:when>
		<xsl:when test="$class = 'EuropeanUnionDecision'">EUDN</xsl:when>
		<xsl:when test="$class = 'EuropeanUnionDirective'">EUDR</xsl:when>
		<xsl:when test="$class = 'EuropeanUnionOther'">EUO</xsl:when>
		<xsl:when test="$class = 'EuropeanUnionCorrigendum'">EUC</xsl:when>
		<xsl:when test="$class = 'UnitedKingdomMinisterialDirection'">MD</xsl:when>
		<xsl:when test="$class = 'NorthernIrelandStatutoryRuleOrOrder'">SR</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">Unknown class: <xsl:value-of select="$class" /></xsl:message>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$class = ('UnitedKingdomLocalAct', 'UnitedKingdomPrivateOrPersonalAct')">
			<xsl:number value="$number" format="i" />
		</xsl:when>
		<xsl:when test="$type/@class = 'primary' and not($class = 'NorthernIrelandOrderInCouncil')">
			<xsl:value-of select="format-number($number, '000')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="$number"><xsl:value-of select="format-number($number, '0000')" /></xsl:if>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$class = ('NorthernIrelandOrderInCouncil', 'NorthernIrelandAct', 'NorthernIrelandParliamentAct')"> (N.I.)</xsl:if>
	<xsl:if test="$class = ('ScottishOldAct')"> (S.)</xsl:if>
	<xsl:if test="$class = ('IrelandAct')"> (I.)</xsl:if>
</xsl:function>

<xsl:function name="tso:sectionInfo" as="element(sparql:result)*">
	<xsl:param name="section" as="xs:string" />
	<xsl:param name="filter" as="xs:string+" />
	<xsl:if test="exists($extentsAndCommencements)">
		<xsl:variable name="extent" as="element(sparql:result)*" select="key('sectionInfo', $section, $extentsAndCommencements)[sparql:binding[@name = $filter]]" />
		<xsl:choose>
			<xsl:when test="exists($extent)">
				<xsl:sequence select="$extent" />
			</xsl:when>
			<xsl:otherwise>
				<!-- there may be one or two parents, one coming from the item level assertions and some from the interpretation level assertions -->
				<!-- pick the one that doesn't start this URI out of preference -->
				<xsl:variable name="parent" as="xs:string*" select="distinct-values(key('parent', $section, $extentsAndCommencements))" />
				<xsl:variable name="parent" as="xs:string?" select="($parent[not(starts-with($section, .))], $parent)[1]" />
				<xsl:if test="exists($parent)">
					<xsl:sequence select="tso:sectionInfo($parent, $filter)" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:function>

<xsl:function name="tso:legislationInfo" as="element(sparql:result)*">
	<xsl:param name="legislation" as="xs:string" />
	<xsl:if test="exists($extentsAndCommencements)">
		<xsl:sequence select="key('legislationInfo', $legislation, $extentsAndCommencements)" />
	</xsl:if>
</xsl:function>

<xsl:function name="tso:sectionInfo" as="element(sparql:result)*">
	<xsl:param name="sections" as="element(ukm:Section)*" />
	<xsl:if test="exists($extentsAndCommencements)">
		<xsl:sequence select="key('sectionInfo', $sections/@URI, $extentsAndCommencements)" />
	</xsl:if>
</xsl:function>

<xsl:function name="tso:extentDiff" as="xs:string*">
	<xsl:param name="supersetExtentURIs" as="xs:string+" />
	<xsl:param name="subsetExtentURIs" as="xs:string+" />
	<xsl:choose>
		<xsl:when test="$subsetExtentURIs = $leg:coextensive">
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="supersetExtents" as="xs:string+" select="distinct-values(for $e in $supersetExtentURIs return tso:extents($e))" />
			<xsl:variable name="subsetExtents" as="xs:string+" select="distinct-values(for $e in $subsetExtentURIs return tso:extents($e))" />
			<xsl:sequence select="$supersetExtents[not(. = $subsetExtents)]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="tso:extents" as="xs:string*">
	<xsl:param name="extentURI" as="xs:string" />
	<xsl:variable name="extents" as="xs:string+" select="tokenize(substring-after($extentURI, $leg), '\+')" />
	<xsl:for-each select="$extents">
		<xsl:choose>
			<xsl:when test=". = 'UK'">
				<xsl:sequence select="('E', 'W', 'S', 'N.I.')" />
			</xsl:when>
			<xsl:when test=". = 'GB'">
				<xsl:sequence select="('E', 'W', 'S')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:function>
</xsl:stylesheet>
