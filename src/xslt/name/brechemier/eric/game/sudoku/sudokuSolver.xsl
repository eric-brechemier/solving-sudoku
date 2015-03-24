<xsl:transform
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 version="2.0"
>
  <!--
  Sudoko Solver
  Try to solve a sudoku puzzle using step by step transforms
  based on basic resolution methods.

  Created by: Eric Bréchemier
  Date: 2006-01-10
  License: LGPL

  *****************************************************************************
  * This library is free software; you can redistribute it and/or             *
  * modify it under the terms of the GNU Lesser General Public                *
  * License as published by the Free Software Foundation; either              *
  * version 2.1 of the License, or (at your option) any later version.        *
  *                                                                           *
  * This library is distributed in the hope that it will be useful,           *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU         *
  * Lesser General Public License for more details.                           *
  *                                                                           *
  * You should have received a copy of the GNU Lesser General Public          *
  * License along with this library; if not, write to the Free Software       *
  * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA *
  *****************************************************************************

  Change History
  2006-01-10 - v0 - creation
  2006-02-10 - v0.1 - first solver using only modes 1+3 (2 not working)
  2006-02-14 - v0.3 - new solver using all 3 modes,
                      modified sudoku annotations
                      (allowed/forbidden as elements)

  Reference
  http://en.wikipedia.org/wiki/Sudoku
  -->

  <xsl:output method="xml" indent="yes" />

  <xsl:include href="sudokuSolver.impl.xsl" />

</xsl:transform>
