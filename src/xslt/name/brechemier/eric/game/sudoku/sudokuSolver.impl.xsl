<xsl:transform
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="2.0"
 
 xmlns:saxon="http://saxon.sf.net/"
 xmlns="http://eric.brechemier.name/game/sudoku"
 xmlns:sudoku="http://eric.brechemier.name/game/sudoku"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 exclude-result-prefixes="saxon sudoku xs"
>
  <!-- *.impl.xsl: all code but imports. See corresponding *.xsl for full description -->
  <xsl:param name="numeric" select="'009005800030480000408000000040007000700301006000900010000000607000079080003800400'" />
  
  <xsl:template match="/">
    <xsl:apply-templates mode="loop" select="sudoku:sudoku">
      <xsl:with-param name="transform" select="saxon:compile-stylesheet( document('sudokuSolverStep.xsl')  )" />
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="loop" match="node()" />
  <xsl:template mode="loop" match="sudoku:sudoku">
    <xsl:param name="transform" />
    <xsl:apply-templates mode="loop" select="saxon:transform($transform,.)">
      <xsl:with-param name="transform" select="$transform" />
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template mode="loop" match="sudoku:sudoku[@status='solved' or @status='stalled']" priority="2">
    <!-- TODO: report error when symbol out of list is detected -->
    <xsl:copy-of select="." />
  </xsl:template>
  
  <xsl:template name="startFromNumeric">
    <xsl:variable name="template" select="document('sudokuTemplate.xml')"/>
    <xsl:variable name="init">
      <xsl:apply-templates mode="fillTemplateFromNumeric" select="$template"/>
    </xsl:variable>
    <xsl:apply-templates select="$init" />
  </xsl:template>
  
  
  <xsl:template mode="fillTemplateFromNumeric" match="sudoku:square/@position">
    <xsl:variable name="value" select="substring($numeric,.,1)"/>
    <xsl:if test="not($value='0')">
      <xsl:attribute name="value"><xsl:value-of select="$value"/></xsl:attribute>
      <xsl:attribute name="method">0-given</xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="fillTemplateFromNumeric" match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates mode="fillTemplateFromNumeric" select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:transform>