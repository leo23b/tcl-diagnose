set prog {inspector}
package ifneeded app-$prog 1.0 [list source [file join $dir $prog.tcl]]