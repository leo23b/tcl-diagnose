# ACTIVESTATE TEAPOT-PKG BEGIN TM -*- tcl -*-
# -- Tcl Module

# @@ Meta Begin
# Package fileutil::multi 0.1
# Meta as::build::date 2011-07-14
# Meta as::origin      http://sourceforge.net/projects/tcllib
# Meta category        file utilities
# Meta description     Multi-file operation, scatter/gather, standard
# Meta description     object
# Meta license         BSD
# Meta platform        tcl
# Meta require         {Tcl 8.4}
# Meta require         fileutil::multi::op
# Meta subject         multi-file {file utilities} remove move copy
# Meta summary         fileutil::multi
# @@ Meta End


# ACTIVESTATE TEAPOT-PKG BEGIN REQUIREMENTS

package require Tcl 8.4
package require fileutil::multi::op

# ACTIVESTATE TEAPOT-PKG END REQUIREMENTS

# ACTIVESTATE TEAPOT-PKG BEGIN DECLARE

package provide fileutil::multi 0.1

# ACTIVESTATE TEAPOT-PKG END DECLARE
# ACTIVESTATE TEAPOT-PKG END TM
# ### ### ### ######### ######### #########
##
# (c) 2007 Andreas Kupries.

# Multi file operations. Singleton based on the multiop processor.

# ### ### ### ######### ######### #########
## Requisites

package require fileutil::multi::op

# ### ### ### ######### ######### #########
## API & Implementation

namespace eval ::fileutil {}

# Create the multiop processor object and make its do method the main
# command of this package.
::fileutil::multi::op ::fileutil::multi::obj

proc ::fileutil::multi {args} {
    return [uplevel 1 [linsert $args 0 ::fileutil::multi::obj do]]
}

# ### ### ### ######### ######### #########
## Ready

package provide fileutil::multi 0.1
