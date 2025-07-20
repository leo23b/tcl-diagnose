#
# $Id: names.tcl,v 1.4 2002/04/04 23:08:56 patthoyts Exp $
#
#package require Mod
namespace eval names {
   
    namespace export names procs vars prototype value exports
    
    proc unqualify s {
        regsub -all "(^| ):+" $s {\1} result
        return $result
    }
    
    proc names { {name ::}} {
        set result $name
        foreach n [SendSyn --  namespace children $name] {
            append result " " [names  $n]
        }
        return $result
    }
    
    proc procs { {names ""}} {
        if {$names == ""} {
            set names [names ]
        }
        set result {}
        foreach n $names {
            foreach p [SendSyn --  namespace eval $n ::info procs] {
                lappend result "$n\::$p"
            }
        }
        return [unqualify $result]
    }
    
   # pinched from globals_list.tcl
   proc prototype { proc} {
      set result {}
      set args [SendSyn --   ::info args $proc]
      #set defaultvar "__tkinspect:default_arg__"
      foreach arg $args {
         set hatDef [SendSyn -- ::info default $proc $arg ::__tkinspect:default_arg__]
         if {$hatDef} {
            set vorbel [SendSyn --   set ::__tkinspect:default_arg__]
            lappend result [list $arg $vorbel]
         } else {
            lappend result $arg
         }
      }
      
      SendSyn --  catch unset ::__tkinspect:default_arg__
      
      return [list "proc" [namespace tail $proc] $result {} ]
   }
      
    proc vars { {names ""}} {
        if {$names == ""} {
            set names [ names ]
        }
        set result {}
        foreach n $names {
            foreach v [SendSyn --  ::info vars ${n}::*] {
                lappend result $v
            }
        }
        return [unqualify $result]
    }

    proc value { var} {
        set tail [namespace tail $var]
        if {[SendSyn --  array exists $var]=={1}} {
            return "variable $tail ; # is an array\n" ; # dump it out?
        }
        set cmd [list set $var]
        set retcode [catch [list SendSyn --  set $var] msg]
        if {$retcode != 0} {
            return "variable $tail ; # $var not defined\n"
        } else {
            return "variable $tail \"$msg\"\n"
        }
    }
    
    proc exports {  namespace} {
        set result [SendSyn --  "namespace" eval $namespace ::namespace export]
        return [unqualify $result]
    }

    # dump [tk appname]
    proc dump appname {
        puts "names: [names  $appname]"
        puts ""
        puts "procs: [procs  $appname]"
        puts ""
        puts "vars: [vars   $appname]"
        puts ""
        puts "exports: [exports  $appname]"
    }
}
# -*- coding: ISO8859-15 -*-