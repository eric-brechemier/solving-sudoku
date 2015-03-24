<xsl:transform
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="2.0"

 xmlns="http://eric.brechemier.name/game/sudoku"
 xmlns:sudoku="http://eric.brechemier.name/game/sudoku"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 exclude-result-prefixes="sudoku xs"
>
  <!-- *.impl.xsl: all code but imports.
  See corresponding *.xsl for full description -->

  <xsl:key name="row-square-with-allowed-values" match="sudoku:square"
    use="concat(@row,'/',sudoku:allowed)"
  />
  <xsl:key name="col-square-with-allowed-values" match="sudoku:square"
    use="concat(@col,'/',sudoku:allowed)"
  />
  <xsl:key name="region-square-with-allowed-values" match="sudoku:square"
    use="concat(@region,'/',sudoku:allowed)"
  />

  <xsl:key name="row-square" match="sudoku:square" use="@row" />
  <xsl:key name="col-square" match="sudoku:square" use="@col" />
  <xsl:key name="region-square" match="sudoku:square" use="@region" />

  <xsl:key name="row-value" match="sudoku:square/@value" use="../@row" />
  <xsl:key name="col-value" match="sudoku:square/@value" use="../@col" />
  <xsl:key name="region-value" match="sudoku:square/@value" use="../@region" />

  <xsl:variable name="allSymbols"
    select="/sudoku:sudoku/sudoku:symbols/sudoku:symbol"
  />
  <xsl:variable name="allSymbolsCount" select="count($allSymbols)" />

  <xsl:function
    name="sudoku:value-or-allowed-value-on-different-square-in-row"
    as="node()*"
  >
    <xsl:param name="contextNode" as="node()" />
    <xsl:param name="row" as="xs:string" />
    <xsl:param name="col" as="xs:string" />
    <xsl:for-each select="$contextNode">
      <xsl:for-each select="key('row-square',$row)[not(@col=$col)]">
        <xsl:copy-of select="@value | sudoku:allowed/sudoku:symbol"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:function>

  <xsl:function
    name="sudoku:value-or-allowed-value-on-different-square-in-col"
    as="node()*"
  >
    <xsl:param name="contextNode" as="node()" />
    <xsl:param name="row" as="xs:string" />
    <xsl:param name="col" as="xs:string" />
    <xsl:for-each select="$contextNode">
      <xsl:for-each select="key('col-square',$col)[not(@row=$row)]">
        <xsl:copy-of select="@value | sudoku:allowed/sudoku:symbol"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:function>

  <xsl:function
    name="sudoku:value-or-allowed-value-on-different-square-in-region"
    as="node()*"
  >
    <xsl:param name="contextNode" as="node()" />
    <xsl:param name="row" as="xs:string" />
    <xsl:param name="col" as="xs:string" />
    <xsl:param name="region" as="xs:string" />
    <xsl:for-each select="$contextNode">
      <xsl:for-each
        select="key('region-square',$region)[not(@row=$row and @col=$col)]"
      >
        <xsl:copy-of select="@value | sudoku:allowed/sudoku:symbol"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:function>



  <xsl:template mode="print" match="node()" />
  <xsl:template mode="print" match="sudoku:sudoku">
    <current>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>-------------------------------------&#xA;</xsl:text>
      <xsl:for-each select="sudoku:square">
        <xsl:sort select="@row" />
        <xsl:sort select="@col" />
        <xsl:if test="@col='A'">
          <xsl:text>| </xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@value">
            <xsl:value-of select="@value" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@col='I'">
            <xsl:text> |&#xA;</xsl:text>
            <xsl:text>-------------------------------------&#xA;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> | </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </current>
  </xsl:template>

  <xsl:template priority="3"
    match="
      sudoku:sudoku[
            not(@step=1)
        and @missing = count( sudoku:square[not(@value)] )
      ]
    "
  >
    <sudoku
      step="{@step}"
      missing="{count(sudoku:square[not(@value)])}"
      status="stalled"
    >
      <xsl:apply-templates mode="print" select="." />
      <xsl:copy-of select="child::node()" />
    </sudoku>
  </xsl:template>

  <xsl:template priority="1" match="sudoku:sudoku">
    <sudoku step="{@step}" missing="0" status="solved">
      <xsl:apply-templates mode="print" select="." />
      <xsl:copy-of select="child::node()" />
    </sudoku>
  </xsl:template>
  <xsl:template priority="2"
    match="sudoku:sudoku[ sudoku:square[not(@value)] ]"
  >
    <xsl:variable name="step">
      <xsl:choose>
        <xsl:when test="@step">
          <xsl:value-of select="@step +1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'1'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <sudoku status="in progress" missing="{count(sudoku:square[not(@value)])}" step="{$step}">
      <xsl:apply-templates mode="print" select="." />
      <xsl:apply-templates>
        <xsl:with-param name="step" select="$step"/>
      </xsl:apply-templates>
    </sudoku>
  </xsl:template>

  <xsl:template match="sudoku:symbols">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template priority="2" match="sudoku:square[@value]">
    <square>
      <xsl:copy-of select="@region|@col|@row|@value|@method|@step"/>
    </square>
  </xsl:template>
  <xsl:template priority="1" match="sudoku:square">
    <xsl:param name="step" />
    <square>
      <xsl:copy-of select="@region|@col|@row"/>
      <xsl:apply-templates mode="scanning" select=".">
        <xsl:with-param name="step" select="$step"/>
      </xsl:apply-templates>
    </square>
  </xsl:template>

  <xsl:template mode="scanning" match="node()"/>
  <xsl:template mode="scanning" priority="2"
    match="
      sudoku:square[
          $allSymbolsCount
        - count(
            distinct-values(
                key('row-value',@row)
              | key('col-value',@col)
              | key('region-value',@region)
            )
          )
        = 1
      ]
    "
  >
    <xsl:param name="step" />
    <xsl:variable name="thisRow" select="@row"/>
    <xsl:variable name="thisCol" select="@col"/>
    <xsl:variable name="thisRegion" select="@region"/>
    <xsl:attribute name="value">
      <xsl:value-of
        select="
          $allSymbols[
            not(
              .
              =
              (
                  key('row-value',$thisRow)
                | key('col-value',$thisCol)
                | key('region-value',$thisRegion)
              ) 
            )
          ]
        "
      />
    </xsl:attribute>
    <xsl:attribute name="method">1-scanning</xsl:attribute>
    <xsl:attribute name="step"><xsl:value-of select="$step"/></xsl:attribute>
  </xsl:template>
  <xsl:template mode="scanning" priority="1" match="sudoku:square">
    <xsl:param name="step" />
    <xsl:apply-templates mode="marking-up" select=".">
      <xsl:with-param name="step" select="$step"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="marking-up" match="node()"/>
  <!-- USELESS: found before by "1-scanning" mode
  <xsl:template mode="marking-up" priority="3"
    match="sudoku:square[count(sudoku:allowed/sudoku:symbol)=1 ]"
  >
    <xsl:param name="step" />
    <xsl:attribute name="value">
      <xsl:value-of select="sudoku:allowed/sudoku:symbol"/>
    </xsl:attribute>
    <xsl:attribute name="method">2-marking-up</xsl:attribute>
    <xsl:attribute name="step"><xsl:value-of select="$step"/></xsl:attribute>
  </xsl:template>
  -->
  <xsl:template mode="marking-up" priority="2"
    match="
      sudoku:square[
        sudoku:allowed/sudoku:symbol[
             not(
               .
               =
               sudoku:value-or-allowed-value-on-different-square-in-row(
                 .,
                 ../../@row,
                 ../../@col
               )
             )
          or not(
               .
               =
               sudoku:value-or-allowed-value-on-different-square-in-col(
                 .,
                 ../../@row,
                 ../../@col
               )
             )
          or not(
               .
               =
               sudoku:value-or-allowed-value-on-different-square-in-region(
                 .,
                 ../../@row,
                 ../../@col,
                 ../../@region
               )
             )
        ]
      ]
    "
  >
    <xsl:param name="step" />
    <xsl:attribute name="value">
      <xsl:value-of
        select="
          sudoku:allowed/sudoku:symbol[
               not(
                 .
                 =
                 sudoku:value-or-allowed-value-on-different-square-in-row(
                   .,
                   ../../@row,
                   ../../@col
                 )
               )
            or not(
                 .
                 =
                 sudoku:value-or-allowed-value-on-different-square-in-col(
                   .,
                   ../../@row,
                   ../../@col
                 )
               )
            or not(
                 .
                 =
                 sudoku:value-or-allowed-value-on-different-square-in-region(
                   .,
                   ../../@row,
                   ../../@col,
                   ../../@region
                 )
               )
          ]
        "
      />
    </xsl:attribute>
    <xsl:attribute name="method">2-marking-up</xsl:attribute>
    <xsl:attribute name="step"><xsl:value-of select="$step"/></xsl:attribute>
  </xsl:template>
  <xsl:template mode="marking-up" match="sudoku:square" priority="1">
    <xsl:param name="step" />
    <xsl:variable name="thisRow" select="@row"/>
    <xsl:variable name="thisCol" select="@col"/>
    <xsl:variable name="thisRegion" select="@region"/>
    <xsl:apply-templates mode="pattern-matching" select=".">
      <xsl:with-param name="step" select="$step"/>
    </xsl:apply-templates>
    <allowed>
      <xsl:apply-templates mode="marking-up"
        select="
          $allSymbols[
            not(
              .
              =
              (
                  key('row-value',$thisRow)
                | key('col-value',$thisCol)
                | key('region-value',$thisRegion)
              )
            )
          ]
        "
      />
    </allowed>
  </xsl:template>
  <xsl:template mode="marking-up" match="sudoku:symbol" priority="1">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template mode="pattern-matching" match="node()"/>
  <xsl:template mode="pattern-matching" priority="2"
    match="
      sudoku:square[
        count(
          sudoku:allowed/sudoku:symbol[
            not( . = ../../sudoku:forbidden/sudoku:symbol )
          ]
        )
        = 1
      ]
    "
  >
    <xsl:param name="step" />
    <xsl:attribute name="value">
      <xsl:value-of
        select="
          sudoku:allowed/sudoku:symbol[
            not( . = ../../sudoku:forbidden/sudoku:symbol )
          ]
        "
      />
    </xsl:attribute>
    <xsl:attribute name="method">3-pattern-matching</xsl:attribute>
    <xsl:attribute name="step"><xsl:value-of select="$step"/></xsl:attribute>
  </xsl:template>
  <xsl:template mode="pattern-matching" priority="1" match="sudoku:square">
    <xsl:variable name="thisRow" select="@row"/>
    <xsl:variable name="thisCol" select="@col"/>
    <xsl:variable name="thisRegion" select="@region"/>
    <forbidden>
      <xsl:apply-templates mode="pattern-matching" select="$allSymbols">
        <xsl:with-param name="thisRow" select="@row"/>
        <xsl:with-param name="thisCol" select="@col"/>
        <xsl:with-param name="thisRegion" select="@region"/>
        <xsl:with-param name="thisMarks" select="sudoku:allowed"/>
      </xsl:apply-templates>
    </forbidden>
  </xsl:template>
  <xsl:template mode="pattern-matching" priority="1" match="sudoku:symbol">
    <xsl:param name="thisRow" />
    <xsl:param name="thisCol" />
    <xsl:param name="thisRegion" />
    <xsl:param name="thisMarks" />

    <xsl:variable name="thisSymbol" select="."/>

    <xsl:if test="
        key('row-square',$thisRow)[
              not( sudoku:allowed=$thisMarks )
          and contains( sudoku:allowed, $thisSymbol )
          and count( sudoku:allowed/sudoku:symbol )
              =
              count(
                key(
                  'row-square-with-allowed-values',
                  concat($thisRow,'/',sudoku:allowed)
                )
              )
        ]
      | key('col-square',$thisCol)[
              not( sudoku:allowed=$thisMarks )
          and contains( sudoku:allowed,$thisSymbol )
          and count( sudoku:allowed/sudoku:symbol )
              =
              count(
                key(
                  'col-square-with-allowed-values',
                  concat($thisCol,'/',sudoku:allowed)
                )
              )
        ]
      | key('region-square',$thisRegion)[
              not( sudoku:allowed=$thisMarks )
          and contains( sudoku:allowed,$thisSymbol )
          and count( sudoku:allowed/sudoku:symbol )
              =
              count(
                key(
                  'region-square-with-allowed-values',
                  concat($thisRegion,'/',sudoku:allowed)
                )
              )
        ]
      "
    >
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy />
  </xsl:template>
  <!--xsl:template match="text()[normalize-space(.)='']"/-->

</xsl:transform>
