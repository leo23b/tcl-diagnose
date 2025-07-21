# Standalone version of Opts for use without Mod.
#
# Copyright 2007 - Peter MacDonald   (See http://pdqi.com/)
# RCS: @(#) $Id: Opts.tcl,v 1.1.1.1 2009/05/09 16:23:07 pcmacdon Exp $
package provide Opts 1.0
namespace eval ::Opt {

    variable check [expr {[info exists ::env(TCL_CHECK)]?$::env(TCL_CHECK):0}]
    interp alias {} ::Opts {} ::Opt::opts

    proc opt {v a l} {
        # Fallback-version of Opts with no args or -- processing.
        upvar 1 $v p; foreach i $l { set p([lindex $i 0]) [lindex $i 1] }; array set p $a
    }    
    
    proc opts {var vals lst args} {
        # Minimal emulated version of Opts for use in standalone programs.
        # Does not support -type extensions.
        upvar $var v
        upvar ::Opt::check check
        set q(-init) 1
        set q(-check) $check
        array set q $args
        if {$q(-init)} {
            foreach i $lst { set v([lindex $i 0]) [lindex $i 1] }    
        }
        set tl 0
        if {![info exists v(--)]} {
            foreach {nam val} $vals {
                if {[info exists v($nam)]} { set v($nam) $val } else { lappend bad $nam }
            }
        } else {
            if {[lindex [lindex $lst end] 0] != "--"} {
                uplevel 1 [list tclLog "-- not last"]
            }    
            set n 0
            foreach {nam val} $vals {
                if {$nam == "--"} {
                    set v(--) [lrange $vals [incr n] end]
                    set tl 1
                    break
                }
                incr n 2
                if {[info exists v($nam)]} { set v($nam) $val } else { lappend bad $nam }
            }
        }
        if {[info exists bad]} {
            set msg "Args '$bad' not in '$lst' from '$vals'"
        } elseif {!$tl && [llength $vals]%2} {
            set msg "odd length for '$vals'"
        }
        if {[info exists msg] && $q(-check)>=1} {
            if {$q(-check)>1} { append msg " in [lindex [info level -1] 0]" }
            if {$q(-check)>=10} {
                return -code 1 $msg
            } else {
                tclLog $msg
            }
        }
    }
    
    proc usage {opts {vopts 0}} {
        # Return text describing the correct options usage.
        # Formats for Vopts if vopts is 1.
        set rc "Valid options and default values are as follows:\n\n"
        set s [expr {$vopts ? "?":""}]
        foreach i $opts {
            append rc [format "  $s%-25s$s %-6s %s %s\n" [lindex $i 0] "[list [lindex $i 1]]" [lindex $i 2] [lrange $i 3 end]]
        }
        return $rc
    }
    
    proc bodyopts {body} {
        # Extract the Opts/Vopts list from body string ala [info body].
        # On success returns the list {opts line1 isvopts} wherein:
        #
        #   - $opts has the option list at [lindex 0] plus any parameters.
        #   - $line1 contains the first line, minus trailing curley brace & spaces.
        #   - $isvopts is 1 if this was a Vopts.
        if {[set o [string first " Opts " $body]]<0 &&
        [set o [set v [string first " Vopts " $body]]]<0} return
        set ib [split [string range $body $o end] \n]
        if {[string index [set b [string trim [lindex $ib 0]]] end] != "\{"} return
        set b [string range $b 0 end-1]
        set opts "\{"
        foreach i [lrange $ib 1 end] {
            append opts $i
            if {[info complete $opts]} { return [list $opts $b [info exists v]] }
        }
        return
    }
    
    proc cmdusage {cmd args} {
        # Return formatted leading comment, args, Opts/Vopts definitions for cmd.
        # The cmd is looked up in the callers level.
        Opts p $args {
            { -pattern {[a-zA-Z]*}  "Pattern of commands to match in ns" }
        }
        set cmt {}
        set ncmd [uplevel 1 [list namespace which -command $cmd]]
        if {$ncmd != {}} { set ncmd [namespace origin $ncmd] }
        if {$ncmd == {}} {
            set cmt "Unknown proc '$cmd' not one of:"
            set ic [lsort [info procs [uplevel 1 [list namespace current]]::$p(-pattern)]]
            foreach i $ic { append cmt " " [namespace tail $i] }
            return $cmt
        }
        set body [info body $ncmd]
        set ib [lrange [set iib [split $body \n]] 1 end]
        foreach i $ib {
            if {![string match #* [set i [string trim $i]]]} break
            append cmt [string trim [string range $i 1 end]] \n
        }
        append cmt "\nproc $cmd"
        set ic {}
        foreach i [info args $ncmd] {
            lappend ic [expr {[info default $ncmd $i ii]? [list $i $ii] : $i}]
        }
        append cmt " [list $ic]\n"
        if {[set rc [bodyopts $body]] == {}} { return $cmt }
        foreach {opts line1 isvopts} $rc break
        append cmt \n [usage [lindex $opts 0] $isvopts]
        return $cmt
    }


}
