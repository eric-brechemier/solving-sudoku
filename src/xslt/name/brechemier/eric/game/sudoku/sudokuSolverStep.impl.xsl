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

  <!-- FIXME: a sudoku:square is a cell.
  It should be renamed to sudoku:cell -->

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

  <!--
  Get the list of symbols identified or allowed in other cells of the row
  for the cell at given row/column position
  FIXME: replace square with cell in function name
  -->
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

  <!--
  Get the list of symbols identified or allowed in other cells of the column
  for the cell at given row/column position
  FIXME: replace square with cell in function name
  -->
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

  <!--
  Get the list of symbols identified or allowed in other cells of the box
  for the cell at given row/column position
  FIXME: replace square with cell in function name
  -->
  <xsl:function
    name="sudoku:value-or-allowed-value-on-different-square-in-region"
    as="node()*"
  >
    <xsl:param name="contextNode" as="node()" />
    <xsl:param name="row" as="xs:string" />
    <xsl:param name="col" as="xs:string" />
    <!--
    region identifies the box
    FIXME: it should be renamed to box
    -->
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

  <!--
  Scanning Strategy [4] [3]
  also known as Cross-Hatching Strategy [2]

  Difficulty Level: Easy

 "Scanning is performed at the outset and periodically throughout the solution.
  Scans may have to be performed several times in between analysis periods.
  Scanning consists of two basic techniques:

  * Cross-hatching: the scanning of rows (or columns) to identify
    which line in a particular region may contain a certain number
    by a process of elimination.
    This process is then repeated with the columns (or rows).
    For fastest results, the numbers are scanned in order of their frequency.
    It is important to perform this process systematically,
    checking all of the digits 1-9.

  * Counting 1-9 in regions, rows, and columns to identify missing numbers.
    Counting based upon the last number discovered may speed up the search.
    It also can be the case (typically in tougher puzzles)
    that the easiest way to ascertain the value of an individual cell
    is by counting in reverse-that is,
    by scanning the cell's region, row, and column for values it cannot be,
    in order to see which is left.

  (...)" [4]

  Related term: "Hidden Single"
 "A hidden single is a single candidate remaining for a specific digit
  in a row, column or box." [1]

 "Cross-Hatching is a simple method
  by which players can find Hidden Singles in a Sudoku puzzle.
  It is one of the few methods
  that does not depend on the presence of pencilmarks.

  The primary target of Cross-Hatching are the boxes,
  but the method will also work with rows and columns.

  How it Works

  The player selects a digit
  that has already been placed several times in the grid,
  but not all (9) instances have been placed.
  The player then focuses on a single box or line,
  drawing imaginary lines from the cells outside this box or line
  which contain this digit.
  The lines mark the invalid positions for this digit.
  Cells already containing another digit are also excluded." [2]

 "Scanning has the same results as Cross-Hatching,
  but it is more methodical." [3]

  TODO: cross-hatching limited to boxes is the most common strategy;
  it should be tried first, before generalizing it to rows and columns.

  References:
  [1] Hidden Single
  https://web.archive.org/web/20070227151830/
    http://www.sudopedia.org/wiki/Hidden_Single

  [2] Cross-Hatching
  https://web.archive.org/web/20070228184758/
    http://www.sudopedia.org/wiki/Cross-Hatching

  [3] Scanning
  https://web.archive.org/web/20070618102527/
    http://www.sudopedia.org/wiki/Scanning

  [4] Scanning
  http://sud0ku.com/scanning.php
  -->
  <xsl:template mode="scanning" match="node()"/>
  <!--
  The expression aims to check whether the cell contains a "Hidden single" [1],
  i.e. if the cell "is the only one in a row, column or block
  that can take a particular value" [1].

  FIXME:
  However, it actually checks whether the cell contains a "naked single" [2],
  i.e. if the cell "can only possibly take a single value,
  when the contents of the other cells in the same row, column and block
  are considered. This is when, between them, the row, column and block
  use eight different digits, leaving only a single digit available
  for the cell." [2]:

  it counts the number of distinct symbols which appear in any house
  (row, column or box) that the cell belongs to.

  When only 1 symbol is left out, this is the "naked single".

 "So why is this technique called naked single?
  Simply because if you use a computer assistant (such as SadMan Sudoku)
  that gives you the full and complete candidate listing for all cells,
  these cells stand out because they only have a single candidate each.
  Contrast this to hidden single." [2]

 "So why is this technique called hidden single?
  Simply because if you use a computer assistant (such as SadMan Sudoku)
  that gives you the full and complete candidate listing for all cells,
  these cells are the only ones to have a certain digit each,
  but they're hidden amongst the other candidates for the cell.
  Contrast this to naked single." [1]

  The check for a "hidden single" should be:
  for the row, the column and the box of the cell,
  is this cell the only one where a specific digit is allowed?

  References:

  [1] Hidden Single (Unique Candidate)
  http://www.sadmansoftware.com/sudoku/hiddensingle.php

  [2] Naked Single (Singleton, Sole Candidate)
  http://www.sadmansoftware.com/sudoku/nakedsingle.php
  -->
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

  <!-- Marking-Up Strategy [1]

  Difficulty Level: Medium

 "When using marking, additional analysis can be performed.
  For example, if a digit appears only one time in the mark-ups
  written inside one region, then it is clear that the digit should be there,
  even if the cell has other digits marked as well." [1]

  This description corresponds to a "Hidden Single" [2]:

 "So why is this technique called hidden single?
  Simply because if you use a computer assistant (such as SadMan Sudoku)
  that gives you the full and complete candidate listing for all cells,
  these cells are the only ones to have a certain digit each,
  but they're hidden amongst the other candidates for the cell.
  (...)" [2]

  However, this analysis is already in the scope of the scanning step.
  Therefore, the marking-up strategy, which can also identify "Hidden Singles",
  should focus on "Naked Singles" instead:

 "So why is this technique called naked single?
  Simply because if you use a computer assistant (such as SadMan Sudoku)
  that gives you the full and complete candidate listing for all cells,
  these cells stand out because they only have a single candidate each.
  (...)" [3]

  Reference:
  [1] Marking up
  http://sud0ku.com/marking-up.php

  [2] Hidden Single (Unique Candidate)
  http://www.sadmansoftware.com/sudoku/hiddensingle.php

  [3] Naked Single (Singleton, Sole Candidate)
  http://www.sadmansoftware.com/sudoku/nakedsingle.php
  -->
  <xsl:template mode="marking-up" match="node()"/>
  <!--
  This template matches cells where only a single symbol is allowed,
  i.e. a "naked single".
  FIXME: they are currently captured by the scanning process,
  but should not. This rule should be enabled again when
  the scanning focuses on "hidden singles" instead.
  -->
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
  <!--
  This expression checks whether a square allows a symbol which is
  not allowed in any other cell of one of the houses (column, row or box)
  that the cell belongs to, i.e. a "Hidden Single".

  FIXME: this check should be done in the scanning step,
  and the check for "Naked Singles" should be done here instead
  (i.e. probably, the two steps should be exchanged, and perhaps
  the <allowed> element should be abstracted, i.e. only computed,
  or created in a separate, preliminary step).

  References:
  [1] Hidden Single
  https://web.archive.org/web/20070227151830/
    http://www.sudopedia.org/wiki/Hidden_Single

  [2] Hidden Single (Unique Candidate)
  http://www.sadmansoftware.com/sudoku/hiddensingle.php
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
  <!--
  This step does the actual "marking-up" also called "pencilling in",
  in reference to the marks made by players to keep tracked of allowed
  and or forbidden symbols in each cell.

  Here, the allowed symbols are listed in the element <allowed>,
  by filtering out all symbols already used in the same row,
  column or box as the cell.

  This list of allowed values is then used at the analysis step
  (pattern-matching) to produce the list of forbidden elements.
  -->
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

  <!--
  Pattern-Matching Strategy
  also known as Analysis [1]

 "The two main approaches to analysis are "candidate elimination"
  and "what-if".

  In elimination, progress is made by successively eliminating
  candidate numbers from one or more cells to leave just one choice.
  After each answer has been achieved, another scan may be performed
  -usually checking to see the effect of the latest number.
  There are a number of elimination tactics,
  all of which are based on the simple rules given above,
  which have important and useful corollaries, including:

  * A given set of n cells in any particular block, row, or column
    can only accommodate n different numbers.
    This is the basis for the "unmatched candidate deletion" technique,
    discussed below.

  * Each set of candidate numbers, 1-9, must ultimately be
    in an independently self-consistent pattern.
    This is the basis for advanced analysis techniques
    that require inspection of the entire set of possibilities
    for a given candidate number.
    Only certain "closed circuit" or "n×n grid" possibilities exist
    (which have acquired peculiar names such as "X-wing" and "Swordfish",
    among others; see List of Sudoku terms and jargon for more information).
    If these patterns can be identified, elimination of candidate
    possibilities external to the grid framework can sometimes be achieved.

  One of the most common elimination tactics is "unmatched candidate deletion".
  Cells with identical sets of candidate numbers are said to be matched
  if the quantity of candidate numbers in each
  is equal to the number of cells containing them;
  essentially, these are perfectly coincident contingencies.
  For example, cells are said to be matched
  within a particular row, column, or region (scope)
  if two cells contain the same pair of candidate numbers (p,q) and no others,
  or if three cells contain the same triplet of candidate numbers (p,q,r)
  and no others.
  The placement of these numbers anywhere else in the matching scope
  would make a solution for the matched cells impossible;
  thus, the candidate numbers (p,q,r) appearing in unmatched cells
  in the row, column or region scope can be deleted.
  This principle also works with candidate number subsets
  -if three cells have candidates (p,q,r), (p,q), and (q,r)
  or even just (p,r), (q,r), and (p,q),
  all of the set (p,q,r) elsewhere in the scope can be deleted.
  The principle is true for all quantities of candidate numbers.

  A second related principle is also true
  - if each cell within a set of cells
  (in a row, column or region scope)
  contains the same set of candidate numbers,
  and if the number of cells
  is equal to the quantity of candidate numbers,
  the cells and numbers are matched
  and only those numbers can appear in matched cells.
  Other candidates in the matched cells can be eliminated.
  For example, if (p,q) can only appear in 2 cells
  (within a specific row, column, region scope),
  other candidates in the 2 cells can be eliminated.

  The first principle is based on cells where only matched numbers appear.
  The second is based on numbers that appear only in matched cells.
  The validity of either principle is demonstrated by posing the question
  'Would entering the eliminated number
  prevent completion of the other necessary placements?'
  If the answer to the question is 'Yes,'
  then the candidate number in question can be eliminated.
  Advanced techniques carry these concepts further
  to include multiple rows, columns, and blocks.
  (See "X-wing" and "Swordfish" above.)

  In the what-if approach,
  a cell with only two candidate numbers is selected,
  and a guess is made.
  The steps above are repeated unless a duplication is found
  or a cell is left with no possible candidate,
  in which case the alternative candidate is the solution.
  In logical terms, this is known as reductio ad absurdum.
  Nishio is a limited form of this approach:
  for each candidate for a cell, the question is posed:
  will entering a particular number
  prevent completion of the other placements of that number?
  If the answer is yes, then that candidate can be eliminated.
  The what-if approach requires a pencil and eraser.
  This approach may be frowned on by logical purists as trial and error
  (and most published puzzles are built to ensure
  that it will never be necessary to resort to this tactic,)
  but it can arrive at solutions fairly rapidly.

  (...)"

  Difficulty Level: Hard

  References:

  [1] Analysis
  http://sud0ku.com/analysis.php

  [2] Look for Patterns
  http://sudokugarden.de/en/solve/pattern

  [3] Analyzing techniques, in Sudoku techniques
  http://www.conceptispuzzles.com/index.aspx?uri=puzzle/sudoku/techniques

  [4] X-Wing
  http://www.sadmansoftware.com/sudoku/xwing.php

  [5] Swordfish
  http://www.sadmansoftware.com/sudoku/swordfish.php

  [6] Trial and Error (Ariadne's Thread, Backtracking, Guessing)
  http://www.sadmansoftware.com/sudoku/trialanderror.php
  -->
  <xsl:template mode="pattern-matching" match="node()"/>
  <!--
  This expression matches a cell where only a single symbol is allowed
  that is not forbidden. The core of the analysis is to produce the list
  of forbidden values by identifying groups of cells that "capture" a value.
  This is done by the code further below that fills the values listed in the
  <forbidden> element.
  -->
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
  <!--
  This part is responsible for identifying forbidden values for a cell,
  which will be listed in the <forbidden> element.
  -->
  <xsl:template mode="pattern-matching" priority="1" match="sudoku:symbol">
    <!-- row, column and box of the current cell -->
    <xsl:param name="thisRow" />
    <xsl:param name="thisCol" />
    <xsl:param name="thisRegion" />
    <!-- list of allowed values for the cell
    FIXME: rename to thisCellMarks or cellMarks or allowedValues -->
    <xsl:param name="thisMarks" />

    <!-- the symbol to test (each one in turn) -->
    <xsl:variable name="thisSymbol" select="."/>

    <!--
    The expression below matches the given symbol
    by checking whether in one of the houses of the cell (row, column or box),
    there is at least one cell, with distinct 'marks' (allowed values)
    from the current cell (FIXME: is this a test for a different cell? In
    this case, the position should be used instead...), which allows this
    symbol (FIXME: contains() should be replaced with an equality of symbol)
    and the total number of allowed values in the cell is equal to the number
    of cells with the exact same allowed values.

    FIXME: as expected in TODO.txt, the pattern-matching as implemented here
    is limited to the particular case of sets with identical 'marks'; the
    general case is to have a combination of n 'marks' present among n cells,
    but necessarily in every cell, e.g. '1,4' '3,4', '1,3'.

    FIXME: optionally keep this special case and generalize patterns.
    -->
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
