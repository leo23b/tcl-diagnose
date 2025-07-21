# listutil.tcl --
#
#        Utilities to operate on Tcl lists
#
# (c) 2001 Glenn Jackman
#
# "Competitors:"
#       http://mini.net/tcl/43.html
#       ExtraL: http://rrna.uia.ac.be/extral/doc/listcommands.html
#       Juf: http://www.han.de/~racke/jultaf/jultaf.html#LISTS
#       Pool: http://www.oche.de/~akupries/soft/pool/f_base_lists.tcl.html
#       TclX: http://www.neosoft.com/TclX/man/TclX.n.html
#
#       http://mini.net/tcl/67.html
#

namespace eval ::listutil {
    namespace export lassign lremove lsearchx lreverse 
    namespace export pop push shift unshift
    namespace export columnize 

    # shamelessly stolen from TclX
    namespace export union intersect intersect3 lrmdups lempty
    # TODO - keyed lists
    namespace export keylset keylget keyldel keylkeys

    # helper procedures
    proc K {x y} {set x}
}

package provide listutil 0.1

###############################################################################
#
#
# lassign -- lassign list varName ?varName ...?
#
#       Assign elements of a list to specified variables
#
# Arguments:
#       list    The list of elements
#       var ... One or more variable names
#
# Results:
#       If there are more variable names than fields, the remaining variables
#       are set to the empty string.  If there are more elements than
#       variables, a list of the unassigned elements is returned.
#
# Example:
#       lassign {dave 100 200 {Dave Foo}} name uid gid longName
#       set name        ;# ==> dave
#       set uid         ;# ==> 100
#       set gid         ;# ==> 200
#       set longName    ;# ==> Dave Foo
#
#       set leftover [lassign {1 2 3 4 5 6} one two three four]
#       set one         ;# ==> 1
#       set two         ;# ==> 2
#       set three       ;# ==> 3
#       set four        ;# ==> 4
#       set leftover    ;# ==> 5 6
#
#       set leftover [lassign {1 2 3} one two three four]
#       set one         ;# ==> 1
#       set two         ;# ==> 2
#       set three       ;# ==> 3
#       set four        ;# ==> ""
#       set leftover    ;# ==> ""

proc ::listutil::lassign {list args} {
    if {[llength $args] == 0} {
        return -code error "wrong # args: lassign list varname ?varname ...?"
    }
    foreach varName $args {
        upvar 1 $varName _tmp_$varName
        lappend vars _tmp_$varName
    }
    foreach $vars $list {break}
    return [lrange $list [llength $vars] end]
}

################################################################################
#
# lremove -- lremove ?options? varName pattern
#
#       Delete elements in a list matching a pattern.
#
# Arguments:
#       args    ?options?  These are lsearchx options
#               varName    This variable holds a list
#               pattern    Defines which items to remove.
#
# Results:
#       Modifies the list, deleting any elements matching the pattern.
#
# Example:
#       set list {apple pear orange peach banana pineapple guava grape}
#       lremove -all -regexp list ap
#       set list        ;# ==> pear orange peach banana guava

proc ::listutil::lremove {args} {
    set lsearchx_opt [list]
    while {[string match -* [set arg [shift args]]]} {
        lappend lsearchx_opt $arg
    }
    upvar 1 $arg list
    if {[llength $args] != 1} {
        return -code error "wrong # args: lremove ?options? varname pattern"
    }
    set pattern [shift args]
    set cmd [concat lsearchx $lsearchx_opt [list $list] [list $pattern]]
    set indices [eval $cmd]
    foreach index [lreverse $indices] {
        set list [lreplace [K $list [unset list]] $index $index]
    }
}

###############################################################################
#
#
# lsearchx -- lsearchx ?-all? ?options? list pattern
#
#       Extend [lsearch] to return all matching indices.
#
# Superceded by:
#       Tcl 8.4 -- lsearch -all
#
# Arguments:
#       args    ?-all?    If specified, return all matching indices.
#               ?options? These options are passed directory to [lsearch]
#               list      The list in which to search
#               pattern   Defines which items to remove.
#
# Results:
#       Return a list of indices, or an empty list if no matches found.
#
# Example:
#       set list {zero one two three four five six seven eight nine ten}
#       lsearchx -all $list *i*         ;# ==> 5 6 8 9

proc ::listutil::lsearchx {args} {
    set all [regexp {^-a(ll?)?$} [lindex $args 0]]
    if {$all} {shift args}
    # Try to find the first match.  Let the Tcl core test for syntax errors.
    if {[set code [catch {eval lsearch $args} result]] != 0} {
        regsub lsearch $result {&x ?-all?} result
        return -code $code $result
    }
    # if we get here, [lsearch] is OK with $args
    if {$result == -1} {
        set result {}
    } elseif {$all} {
        set pattern [pop args]
        set list [lindex [pop args] 0]
        # following switches untested in Tcl 8.4...
        switch -regexp -- $args {
            {-s(o(r(t(ed?)?)?)?)?} -
            {-e(x(a(ct?)?)?)?}     -
            {-r(e(g(e(xp?)?)?)?)?} {
                # this is NOT glob-style matching
                set result [_lsearchx_all_notglob $list $pattern $args $result]
            }
            default {
                # optimization for -glob matching
                set result [_lsearchx_all_glob $list $pattern]
            }
        }
    }
    return $result
}

# repeatedly perform lsearch on the list until no more matches found
#
proc ::listutil::_lsearchx_all_notglob {list pattern lsearch_args first} {
    set result [list $first]
    set nremoved [expr {1 + $first}]
    shift list $nremoved
    while {[set index [eval lsearch $lsearch_args [list $list] $pattern]] != -1} {
        lappend result [expr {$nremoved + $index}]
        incr index
        shift list $index
        incr nremoved $index
    }
    return $result
}

# find all matching indices in the list using temporary array storage
#
proc ::listutil::_lsearchx_all_glob {list pattern} {
    set i 0
    foreach element $list {
        lappend tmp($element) $i
        incr i
    }
    set result [list]
    foreach matching_element [array names tmp $pattern] {
        set result [concat $result $tmp($matching_element)]
    }
    return [lsort -integer $result]
}

###############################################################################
#
# pop / shift -- pop varName ?num?
#
#       Remove the last / first element(s) of the list.
#       Admittedly, the names are perlesque
#
# Arguments:
#       listName        The name of the list
#       num             The number of elements to remove
#
# Results:
#       The list is modified.
#       The removed elements are returned in a list.
#
# Example:
#       set list {zero {one two} three four {5 6} 7 8}
#       shift list 2    ;# ==> zero {one two}
#       pop list 3      ;# ==> {5 6} 7 8
#       set list        ;# ==> three four

proc ::listutil::pop {listName {num 1}} {
    if {$num > 0} {
        upvar 1 $listName list
        set index [expr {[llength $list] - $num}]
        set elements [lrange $list $index end]
        set list [lreplace [K $list [unset list]] $index end]
        return $elements
    }
}

proc ::listutil::shift {listName {num 1}} {
    if {$num > 0} {
        upvar 1 $listName list
        incr num -1
        set elements [lrange $list 0 $num]
        set list [lreplace [K $list [unset list]] 0 $num]
        return $elements
    }
}

###############################################################################
#
# push / unshift -- push varName item ?item ...?
#
#       Append / prepend elements to the list
#
# Arguments:
#
#       listName        The name of the list
#       args            The elements to add to the list
#
# Results:
#       The list is modified.  It is also returned.
#
# Example:
#       set list {three four}
#       unshift list zero {one two}
#       push list {5 6} 7 8
#       set list                ;# ==> zero {one two} three four {5 6} 7 8

proc ::listutil::push {listName args} {
    upvar 1 $listName list
    set list [concat $list $args]
}

proc ::listutil::unshift {listName args} {
    upvar 1 $listName list
    set list [eval linsert [list $list] 0 $args]
}

###############################################################################
#
# lreverse -- lreverse list
#
#       Reverse the order of elements of the list
#
# Arguments:
#       list            A list
#
# Results:
#       The reversed list.
#
# Example:
#       set list {apple pear orange peach banana pineapple guava grape}
#       set tsil [lreverse $list]
#       set tsil     ;# ==> grape guava pineapple banana peach orange pear apple

# Some notes and timings of various implementations:
#
# set l [list]
# for {set i 0} {$i < 10000} {incr i} {lappend l $i}
#
# # iterate over the list elements, shifting elements into a new list
# proc lreverse1 {list} {
#     set rev [list]
#     foreach element $list {
#         set rev [linsert $rev 0 $element]
#     }
#     return $rev
# }
# time {lreverse1 $l} 100 ;# 573899.43 microseconds per iteration
#
# # iterate over the list elements, shifting elements into a new list,
# # with a sophistication
# proc lreverse2 {list} {
#     set rev [list]
#     foreach element $list {
#         set rev [linsert [K $rev [unset rev]] 0 $element]
#     }
#     return $rev
# }
# time {lreverse2 $l} 100 ;# 98657.78 microseconds per iteration
#
# # step through the list backwards, pushing elements onto a new list
# proc lreverse3 {list} {
#     set rev [list]
#     for {set i [expr {[llength $list] - 1}]} {$i >= 0} {incr i -1} {
#         lappend rev [lindex $list $i]
#     }
#     return $rev
# }
# time {lreverse3 $l} 10000 ;# 2842.63 microseconds per iteration
#
# # step through the list backwards, pushing elements onto a new list
# proc lreverse4 {list} {
#     set rev [list]
#     for {set i [llength $list]} {$i > 0} {} {
#         lappend rev [lindex $list [incr i -1]]
#     }
#     return $rev
# }
# time {lreverse4 $l} 10000 ;# 2721.86 microseconds per iteration

proc ::listutil::lreverse {list} {
    set rev [list]
    for {set i [llength $list]} {$i > 0} {} {
        lappend rev [lindex $list [incr i -1]]
    }
    return $rev
}

################################################################################
################################################################################
#
# setfuncs --
#
# Perform set functions on lists.  Also has a procedure for removing duplicate
# list entries.
#------------------------------------------------------------------------------
# Copyright 1992-1999 Karl Lehenbauer and Mark Diekhans.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted, provided
# that the above copyright notice appear in all copies.  Karl Lehenbauer and
# Mark Diekhans make no representations about the suitability of this
# software for any purpose.  It is provided "as is" without express or
# implied warranty.
#------------------------------------------------------------------------------
# glennj: Based on:
# $Id: setfuncs.tcl,v 1.1 2001/10/24 23:31:48 hobbs Exp $
#------------------------------------------------------------------------------
#

#@package: TclX-set_functions union intersect intersect3 lrmdups

#
# return the logical union of two lists, removing any duplicates
#
proc ::listutil::union {lista listb} {
    return [lrmdups [concat $lista $listb]]
}

#
# is the list empty?
#
proc ::listutil::lempty list {
    return [expr {[llength $list] == 0}]
}

#
# sort a list, returning the sorted version minus any duplicates
#

proc ::listutil::lrmdups list {
    # use core lsort, if available
    if {[catch {lsort -uniq {}}] == 0} {
        set result [lsort -uniq $list]
    } else {
        if [lempty $list] {
            return {}
        }
        set list [lsort $list]
        set last [shift list]
        lappend result $last
        foreach element $list {
            if {[string compare $last $element] != 0} {
                lappend result $element
                set last $element
            }
        }
    }
    return $result
}

#
# intersect3 - perform the intersecting of two lists, returning a list
# containing three lists.  The first list is everything in the first
# list that wasn't in the second, the second list contains the intersection
# of the two lists, the third list contains everything in the second list
# that wasn't in the first.
#

proc ::listutil::intersect3 {list1 list2} {
    set la1(0) {} ; unset la1(0)
    set lai(0) {} ; unset lai(0)
    set la2(0) {} ; unset la2(0)
    foreach v $list1 {
        set la1($v) {}
    }
    foreach v $list2 {
        set la2($v) {}
    }
    foreach elem [concat $list1 $list2] {
        if {[info exists la1($elem)] && [info exists la2($elem)]} {
            unset la1($elem)
            unset la2($elem)
            set lai($elem) {}
        }
    }
    list [lsort [array names la1]] [lsort [array names lai]] \
         [lsort [array names la2]]
}

#
# intersect - perform an intersection of two lists, returning a list
# containing every element that was present in both lists
#
proc ::listutil::intersect {list1 list2} {
    set intersectList ""

    set list1 [lsort $list1]
    set list2 [lsort $list2]

    while {1} {
        if {[lempty $list1] || [lempty $list2]} break

        set compareResult [string compare [lindex $list1 0] [lindex $list2 0]]

        if {$compareResult < 0} {
            shift list1
            continue
        }

        if {$compareResult > 0} {
            shift list2
            continue
        }

        lappend intersectList [shift list1]
        shift list2
    }
    return $intersectList
}


################################################################################
################################################################################
# keyed lists
#
# A keyed list is a list in which each element contains a key and value pair.
# These element pairs are stored as lists themselves, where the key is the
# first element of the list, and the value is the second. The key-value pairs
# are referred to as fields.
#
#    keyldel  listVar key
#    keylget  listVar ?key? ?retVar | {}?
#    keylkeys listVar ?key?
#    keylset  listVar key value ?key2 value2 ...?

proc kltest {} {
    set example {{NAME {joe shmoe}} {FAMILY {{PARENTS {{MOTHER {bobby sue}} {FATHER {bobby joe}}}} {WIFE {wendy shmendy}} {KIDS {benny betty billy}}}}}

    array set ex2 {NAME {joe shmoe} FAMILY.PARENTS.MOTHER {bobby sue} FAMILY.PARENTS.FATHER {bobby joe} FAMILY.WIFE {wendy shmendy} FAMILY.KIDS {benny betty billy}}
    puts "Array 2 KeyedList:"
    parray ex2
    puts "[_array2keyedlist ex2]"
    puts "root keys: '[keylkeys ex2]'"
    puts "name keys: '[keylkeys ex2 NAME]'"
    puts "family keys:'[keylkeys ex2 FAMILY]'"
    puts "parent keys:'[keylkeys ex2 FAMILY.PARENTS]'"

    array set ex3 {a.b.c.d.e.f.g.h.i j}
    puts "Array 2 KeyedList:"
    parray ex3
    puts "[_array2keyedlist ex3]"
    puts "root keys: '[keylkeys ex3]'"
    set key a
    puts "$key keys: '[keylkeys ex3 $key]'"
    foreach addition {b c d e f g h i j} {
        append key .$addition
        puts "$key keys: '[keylkeys ex3 $key]'"
    }
}

proc keylset {arrayName args} {
    upvar 1 $arrayName arr
    foreach {key value} $args {
        #set arr($key) $value
        # careful:  if key NAME has value "my name", we can't assign
        # NAME.FIRST!  and vice versa.
        # example:
        #     % keylset t key1 val1 key1.subkey1 val2 key2 val3 key2.subkey1
        #     % parray t
        #     t(key1)         = val1
        #     t(key1.subkey1) = val2
        #     t(key2)         = val3
        #     t(key2.subkey1) = 
        #     % _array2keyedlist t
        #     {key2 {val3 {subkey1 {}}}} {key1 {val1 {subkey1 val2}}} 
    }
}

proc keylkeys {arrayName {key {}}} {
    upvar 1 $arrayName arr
    set names [array names arr ${key}*]
    if {[string length $key] == 0} {
        if {[llength $names] == 0} {
            return {} ;# empty keyed list
        }
        set depth 0
    } else {
        if {[llength $names] == 0} {
            error "no such key: $key"
        } elseif {[string compare $key $names] == 0} {
            return {}
        }
        set depth [expr {1 + [regexp -all {[.]} $key]}]
    }
    array set result {}
    foreach name $names {
        set result([lindex [split $name .] $depth]) ""
    }
    return [array names result]
}

proc _array2keyedlist {arrayName} {
    upvar 1 $arrayName original
    array set tmp [array get original]
    set keyedlist [list]
    while {[llength [set names [array names tmp]]] > 0} {
        set keys [lsort -command _lsort_by_depth -decreasing $names]
        foreach key $keys {
            set keyparts [split $key .]
            set parentkey [join [lrange $keyparts 0 end-1] .]
            set childkey [lindex $keyparts end]
            if {[string length $parentkey] > 0} {
                lappend tmp($parentkey) [list $childkey $tmp($key)]
            } else {
                lappend keyedlist [list $key $tmp($key)]
            }
            unset tmp($key)
        }
    }
    return $keyedlist
}
proc _lsort_by_depth {key1 key2} {
    set d1 [llength [split $key1 .]]
    set d2 [llength [split $key2 .]]
    if {$d1 == $d2} {
        return [string compare $key1 $key2]
    } elseif {$d1 < $d2} {
        return -1
    } else {
        return 1
    }
}
