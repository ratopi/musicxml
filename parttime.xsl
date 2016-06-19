<?xml version="1.0" encoding="UTF-8"?>

<!--
	MusicXML parttime.xsl

	Version 1.0 - 13 January 2004
	
	Copyright © 2004 Recordare LLC.
	http://www.recordare.com/
	
	This MusicXML work is being provided by the copyright
	holder under the MusicXML Document Type Definition 
	Public License Version 1.02, available from:
	
		http://www.recordare.com/dtds/license.html
-->

<!-- 
	Parttime.xsl is an XSLT stylesheet for transforming
	partwise MusicXML scores into timewise scores. Thus
	instead of having measures included within each part,
	the transformed score includes parts within each measure.
	This type of transformation allows the 2-dimensional
	nature of a musical score to be adequately represented
	within a hierarchical format like XML.
-->

<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--
    XML output, with a DOCTYPE refering the timewise DTD.
    Here we use a relative URL for doctype-system. You can
    change this to another relative URL, or to the full
    Internet URL:
		
	 http://www.musicxml.org/dtds/timewise.dtd
  -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"
	omit-xml-declaration="no" standalone="no"
	doctype-system="/musicxml/timewise.dtd"
	doctype-public="-//Recordare//DTD MusicXML 1.0 Timewise//EN" />

  <!--
    For the root, only look for score-partwise and
    score-timewise. Anything else as a root element gets
    ignored.
  -->  
  <xsl:template match="/">
    <xsl:apply-templates select="./score-partwise"/>
    <xsl:apply-templates select="./score-timewise"/>
  </xsl:template>

  <!--
    If we have a timewise score, we really shouldn't be
    applying this stylesheet. Copy everthing as-is without
    triggering templates.
  -->
  <xsl:template match="score-timewise">
    <xsl:copy-of select="." />
  </xsl:template>

  <!-- The identity transformation. Used by default. -->
  <xsl:template match="text()">
    <xsl:value-of select="." />
  </xsl:template>
	
  <!--
    Whitespace within an xsl:copy could cause problems with 
    empty elements.
  -->
  <xsl:template match="*|@*|comment()|processing-instruction()">
    <xsl:copy><xsl:apply-templates
		select="*|@*|comment()|processing-instruction()|text()"
	/></xsl:copy>
  </xsl:template>

  <!--
    We need to take control at the document element level
    explicitly to redo the tree. The header elements should
    all be copied. After that, we loop through the measures
    in part 1, and create the part elements (for part 1 and
    all others) from within that loop.
  -->
  <xsl:template match="score-partwise">
	
    <!-- Create the score-timewise element. -->
    <xsl:element name="score-timewise">
		
      <!--
        Copy the five score header elements and their
        children. The DTD specifies that these occur, if
        present, in a fixed order.
      -->
      <xsl:apply-templates select="work"/>
      <xsl:apply-templates select="movement-number"/>
      <xsl:apply-templates select="movement-title"/>
      <xsl:apply-templates select="identification"/>
      <xsl:apply-templates select="part-list"/>
			
      <!--
        Now loop through all measures in the first part.
      -->
      <xsl:for-each select="part[1]/measure">
		
        <!--
          Bind measure number to a variable for use
          throughout the loop, including inner loop 
          where we will lose the immediate context.
        -->
        <xsl:variable name="measure-number">
          <xsl:value-of select="@number"/>
        </xsl:variable>
				
        <!-- Create the measure element. -->
        <xsl:element name="measure">
				
          <!--
            Now we need to copy the measure attributes.
          -->
          <xsl:attribute name="number">
            <xsl:value-of select="$measure-number"/>
          </xsl:attribute>
          <xsl:if test="@implict[yes]">
            <xsl:attribute name="implicit">
              <xsl:value-of select="@implicit"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@non-controlling[yes]">
            <xsl:attribute name="non-controlling">
              <xsl:value-of select="@non-controlling"/>
            </xsl:attribute>
          </xsl:if>
				
          <!--
            Now for the inner loop. We go back to the root
            ancestor, and loop through each part and
            measure, looking for the ones that match the
            measure number, and add it here.
						
            This is inefficient. but it provides a working
            starting point.
          -->
          <xsl:for-each select="../../part/measure">
            <xsl:if test="@number=$measure-number">
					
              <!-- Create the part element. -->
              <xsl:element name="part">
						
                <!-- Copy the ID from the parent part element. -->
                <xsl:attribute name="id">
                  <xsl:value-of select="parent::part/@id"/>
                </xsl:attribute>

                <!--
                  Now copy all the descendants using
                  identity transforms.
                -->
                <xsl:apply-templates />
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
					
        </xsl:element>
      </xsl:for-each>
    </xsl:element>       
  </xsl:template>
</xsl:stylesheet>