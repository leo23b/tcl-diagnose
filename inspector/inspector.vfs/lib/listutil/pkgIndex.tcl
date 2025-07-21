#if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded listutil 0.1 [list source [file join $dir listutil.tcl]]
