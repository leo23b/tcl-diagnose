#doc {cmd cmd_args} cmd {
#	cmd_args cmd options vars args
#} descr {
#	parses the arguments given to a command, deals with options and optional arguments.
#	Options are stored in the array opt, values in the variables given.
#	the list of possible options consists of alternatingly the option
#	and a specification, which is a list of type and description
#	variables in the variable list enclosed in questionmarks are optional.
#	?...? will take all possible extra arguments at that position (if present), and store them in the
#	variable args.
#	Die Optionen dürfen nicht abgekürzt werden und müssen vor den
#	Parametern stehen !
#} example {
#	cmd_args test {
#		-test {any "test value"}
#		-b {switch "true or false"}
#		-o {{oneof a b c} "a, b or c"}
#	} {?a? b} {-b -test try -o b 1 2}
#}
# Beispiel:
#---------------------------------------------------------------
# cmd_args kdo {
# 		-append {switch "append to destination file true/false"}
# 		-overwrite {switch "overwrite destination file true/false"}
# 		-log {channel "channel on which to write logs"}
# 		-lev {int  "Loglevel 1 2 3 .."}
# 		-dbl {double   "double 1 2 3 .."}
# 		-ftkey {any "value of ftkey in new features (dcse formats)"}
# 		-type {any "feature type (dcse formats)"}
#       -num {{oneof a b c} "a b oder c"}
# 	} {db file ?...? resultfile } $argv
#
# kdo -ftkey rRNA -type LSU -log stdout -dbl 1.5 -lev 1 -num a
#    db test a b c  ref
# liefert :
# resultfile:ref
# file:test
# db db
# args a b c   <--- Variable Anzahl args
#
# opt(-dbl)   = 1.5
# opt(-ftkey) = rRNA
# opt(-lev)   = 1
# opt(-log)   = stdout
# opt(-num)   = a
# opt(-type)  = LSU
#---------------------------------------------------------------
proc cmd_args {cmd options vars arg} {
  # Handle options
  #set dovar {}
  #set doval {}
  set pos 0
  if {[llength $options]} {
    upvar opt opt
    array set op $options
    while 1 {
      set curopt [lindex $arg $pos]
      if {[string_equal $curopt --]} {
        incr pos
        break
      }
      if {![info exists op($curopt)]} break
      set type [lindex $op($curopt) 0]
      if {[string_equal [lindex $type 0] switch]} {
        set value 1
        incr pos
      } else {
        set value 1
        incr pos
        set value [lindex $arg $pos]
        incr pos
        switch [lindex $type 0] {
          int {
            if {![isint $value]} {
              return -code error "invalid value \"$value\" for option $curopt: should be an integer"
            }
          }
          double {
            if {![isdouble $value]} {
              return -code error "invalid value \"$value\" for option $curopt: should be a double number"
            }
          }
          oneof {
            if {![inlist [lrange $type 1 end] $value]} {
              return -code error "invalid value \"$value\" for option $curopt: should be one of: [lrange $type 1 end]"
            }
          }
        }
      }
      set opt($curopt) $value
    }
    set arg [lrange $arg $pos end]
  }
  # Handle arguments
  regsub -all {\?[^?]+\?} $vars {} fixedvars
  set numfixed [llength $fixedvars]
  set vartodo [expr {[llength $arg] - $numfixed}]
  set range 0
  set error 0
  if {[llength $arg] < $numfixed} {
    set error 1
  } else {
    set pos 0
    foreach var $vars {
      set value [lindex $arg $pos]
      if {$range} {
        if {!$vartodo} {
          set error 1
          break
        }
        if {"[string index $var [expr {[string length $var]-1}]]" == "?"} {
          lappend dovar [string trimright $var ?]
          set range 0
        } else {
          lappend dovar $var
        }
        lappend doval $value
        incr vartodo -1
        incr pos
      } elseif {"[string index $var 0]" == "?"} {
        if {"[string index $var [expr {[string length $var]-1}]]" == "?"} {
          if {[string_equal $var ?...?]} {
            if {$vartodo} {
              set pos2 [expr {$pos+$vartodo-1}]
              lappend dovar args
              lappend doval [lrange $arg $pos $pos2]
              set vartodo 0
              set pos [expr {$pos2+1}]
            }
          } else {
            if {$vartodo} {
              lappend dovar [string trimleft [string trimright $var ?] ?]
              lappend doval $value
              incr vartodo -1
              incr pos
            }
          }
        } else {
          if {$vartodo} {
            lappend dovar [string trimleft $var ?]
            lappend doval $value
            incr vartodo -1
            incr pos
          }
          set range 1
        }
      } else {
        lappend dovar $var
        lappend doval $value
        incr pos
      }
    }
  }
  if {($error||$vartodo)} {
    if {[llength $options]} {
      set format "$cmd ?options? $vars"
      set opterror "\nPossible options are:"
      foreach {option descr} $options {
        if {[string_equal [lindex $descr 0] switch]} {
          append opterror "\n\t$option \"[lindex $descr end]\""
        } else {
          append opterror "\n\t$option $descr"
        }
      }
    } else {
      set format "$cmd $vars"
      set opterror ""
    }
    if {[regexp ^- [lindex $arg 0]]} {
      return -code "error" "bad option \"[lindex $arg 0]\":$opterror"
    } else {
      return -code "error" "wrong # of args: should be \"$format\"$opterror"
    }
  }
  if {[info exists dovar]} {
    uplevel [list foreach $dovar $doval break]
  }
}


#doc {listcommands inlist} cmd {
#inlist list value
#} descr {
#returns 1 if $value is an element of list $list
#returns 0 if $value is not an element of list $list
#}
proc inlist {list value} {
  if {[lsearch $list $value]==-1} {
    return 0
  } else {
    return 1
  }
}

# File containing the Tcl part of the Extral extension
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc stringcommands title {
#Extra string manipulation commands
#}

#doc {stringcommands string_split} cmd {
#string__split string splitstring
#} descr {
# split string on exact occurence off splitstring<br>
#} example {
#	% string_split "test1||test2" "||"
#	test1 test2
#}
proc string_split {string splitstring} {
  set result ""
  set len [string length $splitstring]
  while 1 {
    set pos [string first $splitstring $string]
    if {$pos == -1} {
      lappend result $string
      break
    }
    lappend result [string range $string 0 [expr {$pos-1}]]
    set string [string range $string [expr {$pos+$len}] end]
  }
  return $result
}

#doc {stringcommands string_equal} cmd {
#string_equal s1 s2
#} descr {
# returns 1 if the strings are equal, 0 if the are not
#}
proc string_equal {s1 s2} {
  if {[string length $s1] != [string length $s2]} {
    return 0
  }
  if {"$s1" == "$s2"} {
    return 1
  } else {
    return 0
  }
}

#doc {stringcommands string_fill} cmd {
#string_fill string number
#} descr {
# returns a string consisting of the argument string number times repeated
#}
proc string_fill {string number} {
  set result ""
  for {set i 0} {$i < $number} {incr i} {
    append result $string
  }
  return $result
}


# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc validatecommands title {
# Validation commands
#} shortdescr {
#isint, isdouble
#}

#doc {validatecommands isint} cmd {
#isint value
#} descr {
#returns 1 if value is an integer, 0 if it is not
#} example {
#	% isint 1
#	1
#	% isint a
#	0
#	% isint 1.2
#	0
#}
proc isint {value} {
  if {[catch {expr {1 >> $value}}]} {
    return 0
  } else {
    return 1
  }
}

#doc {validatecommands isdouble} cmd {
#isdouble value
#} descr {
#returns 1 if value is a real number, 0 if it is not
#} example {
#	% isdouble 1.2
#	1
#	% isdouble 1
#	1
#	% isdouble a
#	0
#}
proc isdouble {value} {
  if { [catch { expr { $value } } ] } {
    return 0
  } else {
    return 1
  }
}

# File containing the Tcl part of the list commands in the Extral extension
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc cmd title {
#Command manipulation commands
#}

#doc {cmd cmd_get} cmd {
#	cmd_get channelId
#} descr {
#	get one complete Tcl command, in the sense of having no unclosed quotes,
#	braces, brackets or array element names, from the open file given by channelId
#}
proc cmd_get {channelId} {
  if {[eof $channelId]} {return ""}
  set line {}
  while 1 {
    append line "[gets $channelId]"
    if {[info complete $line]} break
    if {[eof $channelId]} {
      error "file end: \"$line\" is incomplete"
    }
    append line "\n"
  }
  return $line
}

#doc {cmd cmd_split} cmd {
#	cmd_split data
#} descr {
#	split data into complete Tcl commands in the sense of having no unclosed quotes,
#	braces, brackets or array element names.
#}
proc cmd_split {data} {
  set result ""
  set current ""
  foreach line [split $data "\n"] {
    if {"$current" != ""} {
      append current "\n"
    }
    append current $line
    set end [string length $line]
    incr end -1
    if {![regexp {\\$} $current]} {
      if {[info complete $current]} {
        lappend result $current
        set current ""
      }
    }
  }
  return $result
}

#proc splitesccomplete {data} {
#	set result ""
#	set current ""
#	foreach line [split $data "\n"] {
#		if {"$current" != ""} {
#			append current "\n"
#		}
#		append current $line
#		if ![regexp {\\$} $current] {
#			if [info complete $current] {
#				lappend result $current
#				set current ""
#			}
#		}
#	}
#	return $result
#}

#doc {cmd cmd_parse} cmd {
#	cmd_parse line
#} descr {
#	parses a cmdline. it returns a list where each element is the part of the cmdline that
#	will result in one element when the cmdline would be evaluated.
#	eg.
#	% cmd_parse {set test [format "%2.2f" 4.3]}
#	set test {[format "%2.2f" 4.3]}
#}
proc cmd_parse {line {recurse 0}} {
  regsub -all "\\\\\n" $line {} line
  set len [string length $line]
  set i $recurse
  while {$i < $len} {
    if {![regexp "\[ \t\]" [string index $line $i]]} break
    incr i
  }
  set prev $i
  set result ""
  while {$i < $len} {
    switch -- [string index $line $i] {
      " " - "\n" {
        lappend result [string range $line $prev [expr {$i-1}]]
        while {$i < $len} {
          incr i
          set char [string index $line $i]
          if {("$char" != " ")&&("$char" != "\t")} {
            set prev $i
            incr i -1
            break
          }
        }
      }
      "\\" {
        incr i
      }
      "\{" {
        set level 1
        while 1 {
          incr i
          if {$i == $len} break
          switch -- [string index $line $i] {
            "\{" {
              incr level
            }
            "\}" {
              incr level -1
              if {$level == 0} break
            }
          }
        }
      }
      "\"" {
        while 1 {
          incr i
          if {$i == $len} {
            error "missing \""
          }
          switch -- [string index $line $i] {
            "\\" {incr i}
            "\"" break
            "\[" {
              incr i
              set i [cmd_parse $line $i]
            }
          }
        }
      }
      "\[" {
        incr i
        set i [cmd_parse $line $i]
      }
      "\]" {
        if {$recurse} {
          return $i
        }
      }
    }
    incr i
  }
  lappend result [string range $line $prev end]
  return $result
}
#set line "\t \$window.try configure \t -title \[puts \"\[tk appname\]\"\] \\\n-command \"\$window command\\\"\\n\\\"\" -test \{try \nit \"\"\}"
#cmd_parse $line

#doc {cmd cmd_load} cmd {
#	cmd_load filename
#} descr {
#	returns the contents of the given file als a list of complete Tcl commands.
#
#}
proc cmd_load {filename} {
  set f [open $filename "r"]
  set result {}
  while {[eof $f] != 1} {
    lappend result [cmd_get $f]
  }
  close $f
  return $result
}

