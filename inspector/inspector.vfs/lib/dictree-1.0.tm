#===============================================================================
#  dictree widget        display and edit dictionary data in ttk::treeview
#
#  21.12.2012, Alexander Mlynski-Wiese
#===============================================================================

package require Tcl                8.5
package require Tk
package require Ttk

package provide dictree                1.0

#-------------------------------------------------------------------------------
#  dictree w d
#  create a treeview widget with the pathname $w
#  and fill it with the dictionary data $d
#-------------------------------------------------------------------------------
proc dictree { w d args } {

     # frame $w
      #pack $w -expand 1 -fill both
    ttk::treeview $w.t -columns {key value} -displaycolumns value        \
                -yscroll "${w}.sby set" -xscroll "${w}.sbx set"

    if {[tk windowingsystem] ne "aqua"} {
        ttk::scrollbar ${w}.sby -orient vertical   -command "$w.t yview"
        ttk::scrollbar ${w}.sbx -orient horizontal -command "$w.t xview"
    } else {
        scrollbar ${w}.sby -orient vertical   -command "$w.t yview"
        scrollbar ${w}.sbx -orient horizontal -command "$w.t xview"
    }

    $w.t heading \#0   -text "Directory Key(s)"
    $w.t heading value -text "Value"

    entry $w.e                                        ;# widget used for editing

    grid $w.t    -row 0 -column 0 -sticky news
    grid $w.sby  -row 0 -column 1 -sticky ns        ;# arrange the scrollbars
    grid $w.sbx  -row 1 -column 0 -sticky ew
    grid rowconfigure          $w 0 -weight 1
    grid columnconfigure $w 0 -weight 1

    dictree::bindings $w.t                        ;# create the bindings

    dict for {key val} $d {                        ;# populate the treeview
        dictree::addNode $w.t "" $key $val
    }

    #-----------------------------------------------------------------------
    #  "overload" the widget proc to support additional commands
    #-----------------------------------------------------------------------
    rename $w _$w
    proc $w {cmd args} {
        set self [lindex [info level 0] 0] ;# get name I was called with
        switch -- $cmd {
            reap    {uplevel 1 dictree::reap $self.t $args }
            default {
                if { [catch {
                    uplevel 1 _$self $cmd $args
                } ] } {
                    uplevel 1 $self.t $cmd $args
                }
            }
        }
    }

    return $w
}

namespace eval dictree {        ;# "private" functions
#-------------------------------------------------------------------------------
#  bindings                create the bindings for the treeview
#-------------------------------------------------------------------------------
proc bindings { w { debug 0 } } {

    bind $w <plus>              { dictree::setopen %W [%W selection] 1 }
    bind $w <minus>             { dictree::setopen %W [%W selection] 0 }

    bind $w <Alt-plus>          { dictree::expand   %W [%W selection] }
    bind $w <Alt-minus>         { dictree::collapse %W [%W selection] }

    bind $w <Alt-ButtonPress-1> { dictree::toggle %W [%W identify item %x %y] }
    bind $w <Alt-Return>        { dictree::toggle %W [%W selection]; break }

    bind $w <F2>                { dictree::edit %W [%W selection] "#0" }
    bind $w <Shift-F2>          { dictree::edit %W [%W selection] "value" }

    bind $w <Alt-Up>            { dictree::move %W [%W selection] -1; break }
    bind $w <Alt-Down>          { dictree::move %W [%W selection]  1; break }

    bind $w <Alt-Left>          { dictree::rise %W [%W selection]  1; break }
    bind $w <Alt-Right>         { dictree::rise %W [%W selection] -1; break }

    bind $w <Delete>            { dictree::delete %W [%W selection] }
    bind $w <Insert>            { dictree::insert %W [%W selection] }
    bind $w <Alt-Insert>        { dictree::insert %W [%W selection] 1 }

    if { $debug } {
        # to aid developing additional bindings:
        bind $w <ButtonPress-1> {
            set item [%W identify item %x %y]
            puts "%x,%y: %W item $item: [%W item $item]"
        }
        bind $w <KeyPress> { puts %K }
    }

    return $w
}

#-------------------------------------------------------------------------------
#  addNode                recursive proc to create and fill the nodes
#-------------------------------------------------------------------------------
proc addNode { w parent title d } {
    set node [$w insert $parent end -text $title]
    set isdict 0
    catch {
        if { [dict get $d] == $d } {
            set isdict 1
        }
    }
    if { $isdict} {
        # interpret data $d as a dictionary and create a subnode
        dict for {key val} $d {
            addNode $w $node $key $val
        }
    } else {
        # $d is not a dictionary: make this node a leaf
        $w set $node value $d
    }
}

#-------------------------------------------------------------------------------
#  setopen                open/close node(s)
#-------------------------------------------------------------------------------
proc setopen { w items mode } {
    foreach item $items {
        $w item $item -open $mode
    }
}

#-------------------------------------------------------------------------------
#  collapse                collapse all child nodes and make node $item a leaf
#-------------------------------------------------------------------------------
proc collapse { w items } {
    foreach item $items {
        set children ""
        catch { set children [$w children $item] }
        if { $children != "" } {
            set value ""
            foreach child [$w children $item] {
                collapse $w $child
                lappend value [$w item $child -text]
                lappend value [$w set $child value]
                $w delete $child
            }
            $w set $item value $value
        }
    }
}

#-------------------------------------------------------------------------------
#  expand                if possible, expand leaf value to child nodes
#-------------------------------------------------------------------------------
proc expand { w items } {
    global errorInfo
    foreach item $items {
        if { [$w children $item] == "" } {
            set d [$w set $item value]
            set isdict 0
            catch {
                if { [dict get $d] == $d } {
                    set isdict 1
                }
            }
            if { $isdict} {
                dict for {key val} $d {
                    addNode $w $item $key $val
                }
                $w set $item value ""
            }
        }
    }
}

#-------------------------------------------------------------------------------
#  toggle                toggle node(s) between collapsed / expanded
#-------------------------------------------------------------------------------
proc toggle { w items } {
    foreach item $items {
        if { [$w children $item] != "" } {
            collapse $w $item
        } else {
            expand $w $item
        }
    }
}

#-------------------------------------------------------------------------------
#  move                        move node up/down among siblings, i.e. keep parent node
#-------------------------------------------------------------------------------
proc move { w item increment } {
    if { $item == "" || [llength $item] != 1 } { return }
    set parent [$w parent $item]
    set index  [$w index  $item]
    incr index $increment
    $w move $item $parent $index
}

#-------------------------------------------------------------------------------
#  adopt                move item to new parent
#-------------------------------------------------------------------------------
proc adopt { w item newparent newindex } {
    set name [$w item $item -text]
    set children [$w children $newparent]
    if { $children == "" } {
        return 0
    }
    foreach child $children {
        if { $name == [$w item $child -text] } {
            # not allowed: parent already has a child with that name
            return 0
        }
    }
    $w move $item $newparent $newindex
    $w item $newparent -open 1
    return 1
}

#-------------------------------------------------------------------------------
#  rise                 rise/fall one level in the hierarchy
#-------------------------------------------------------------------------------
proc rise { w item increment } {
    if { $item == "" || [llength $item] != 1 } { return }
    set parent  [$w parent $item]

    if { $increment > 0 } {
        # rise in the hierarchy, make my grandpa my new parent
        set newparent [$w parent $parent]        ;# grandpa
        set newindex  [$w index  $parent]
        incr newindex                                ;# behind my old parent
        adopt $w $item $newparent $newindex

    } else {
        # fall in the hierarchy, make a brother my new parent
        set index    [$w index $item]
        set brothers [$w children $parent]
        set brother  [lindex $brothers [expr $index-1]]

        if { $brother != "" } {
            if { [adopt $w $item $brother end] } {
                return
            }
        }
        foreach brother $brothers {
            if { $brother != $item } {
                if { [adopt $w $item $brother end] } {
                    return
                }
            }
        }
    }
}

#-------------------------------------------------------------------------------
#  edit                 edit node text or value
#-------------------------------------------------------------------------------
proc edit { w item column { next "" } } {
    global dictree
    if { $item == "" || [llength $item] != 1 } { return }
    foreach {bx by bw bh} [$w bbox $item $column] {}
    set ym [expr $by + $bh/2]
    while { $bx < 50 && [$w identify element $bx $ym] != "text" } {
        incr bx
        incr bw -1
    }

    if { $column == "#0" } {
        set dictree($w,text) [$w item $item -text]
    } elseif { [$w children $item] != "" } {
        return
    } else {
        set dictree($w,text) [$w set $item $column]
    }
    set parent [winfo parent $w ] 
    if { [catch {
        place $parent.e -x $bx -y $by -width $bw -height $bh
    } ] } {
        return
    }
    $parent.e configure -textvariable dictree($w,text)        \
                       -validate key         \
                       -validatecommand "dictree::edit_check $parent $item $column %P"
    if { $dictree($w,text) == "(new)" } {
        $parent.e selection range 0 end
    } else {
        $parent.e selection clear
    }
    $parent.e configure -background white
    $parent.e icursor end
    focus $parent.e
    grab  $parent.e
    bind  $parent.e <Return> "dictree::edit_done $w $item $column $next"
    bind  $parent.e <Escape> "dictree::edit_done $w $item {} $next"
}

#-------------------------------------------------------------------------------
#  edit_check                check if name is allowed
#-------------------------------------------------------------------------------
proc edit_check { w item column value } {
    global dictree
    set ok 1
    if { $column == "#0" } {
        set parent [$w parent $item]
        foreach child [$w children $parent] {
            if { $child != $item &&
                    [$w item $child -text] == $value } {
                    set ok 0
            }
        }
        set parent [winfo parent $w ] 
        if { ! $ok } {
            $w.e configure -background red
        } else {
            $w.e configure -background white
        }
    }
    return 1
}

#-------------------------------------------------------------------------------
#  edit_done                finish editing
#-------------------------------------------------------------------------------
proc edit_done { w item {column "" } { next "" } } {
    global dictree
    set parent [winfo parent $w ] 
    if { $column != "" && [$parent.e cget -background] == "red" } {
        return
    }

    grab release $parent.e
    focus $w
    if { $column == "#0" } {
        $w item $item -text $dictree($w,text)
    } elseif { $column != "" } {
        $w set $item $column $dictree($w,text)
    }
    place forget $parent.e
    if { $next != "" } {
        if { $column == "" } {
            $w delete $item
            $w selection set $dictree($w,selection)
        } else {
            edit $w $item $next
        }
    }
    unset dictree($w,text)
    catch { unset dictree($w,selection) }
}

#-------------------------------------------------------------------------------
#  delete                delete node(s) (after confirmation)
#-------------------------------------------------------------------------------
proc delete { w items } {
    set count [llength $items]
    set msg "Do you really want to delete the following "
    if { $count > 1 } {
        append msg "$count nodes:\n"
    } else {
        append msg "node:\n"
    }
    foreach item $items {
        append msg " [$w item $item -text]"
    }
    append msg "?"
    if { [tk_messageBox -title "Delete nodes" \
                    -icon warning -message $msg -type yesno] == "yes" } {
                $w delete $items
    }
}

#-------------------------------------------------------------------------------
#  insert                insert & edit new node before/after given node
#-------------------------------------------------------------------------------
proc insert { w item { offset 0 } } {
    global dictree
    if { $item == "" || [llength $item] != 1 } { return }

    set dictree($w,selection) [$w selection]

    set parent [$w parent $item]
    set index  [$w index  $item]

    set newidx [expr $index + $offset]
    set node [$w insert $parent $newidx -text "(new)"]
    $w set $node value "(new)"
    $w selection set $node
    edit $w $node "#0" "value"
}

#-------------------------------------------------------------------------------
#  reap                        return the content of the treeview as dictionary
#-------------------------------------------------------------------------------
proc reap { w { node "" } } {
    set children [$w children $node]
    if { [llength $children] == 0 } {
        set value [$w set $node value]
        dict set d [$w item $node -text] $value
    } else {
        foreach child $children {
            set value [reap $w $child]
            if { $node == "" } {
                lappend d {*}$value
            } else {
                dict lappend d [$w item $node -text] {*}$value
            }
        }
    }
    return $d
}

#-------------------------------------------------------------------------------
#  dictdir                generate example dict with filesystem info
#-------------------------------------------------------------------------------
proc dictdir { dir } {
    set d ""
    file stat $dir fstat
    foreach item [lsort [array names fstat]] {
        dict set d . $item $fstat($item)
    }
    foreach subdir [lsort [glob -directory $dir -nocomplain -types d "*"]] {
        dict set d {*}[dictdir $subdir]
    }
    foreach fname [lsort [glob -directory $dir -nocomplain -types f "*"]] {
        file stat $fname fstat
        # sorted:
        foreach item [lsort [array names fstat]] {
            dict set d [file tail $fname] $item $fstat($item)
        }
        # faster but unsorted:
        # dict set d [file tail $fname] [array get fstat]
    }
    return [list [file tail $dir]/ $d]
}

#-------------------------------------------------------------------------------
#  main                        "main" for demo program
#-------------------------------------------------------------------------------
proc main { args } {
    set fname [pwd]                                ;# default to current dir
    if { [llength $args] >= 1 } {                ;# check for commandline arg
        set fname [lindex $args 0]
    }
    if { [file isdirectory $fname] } {                ;# directory was given:
        set d [dictdir $fname]                        ;# parse directory

    } else {                                        ;# file was given:
        set h [open [lindex $args 0] "r"]        ;# read dict from file
        set d [read $h]
        close $h
    }

    # create dictree control:
    dictree .t $d
    pack .t -expand yes -fill both
}

#-------------------------------------------------------------------------------
#  end of namespace dict::
#-------------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
#  "main" function: run demo if this module is called rather than sourced
#-------------------------------------------------------------------------------
if { [info exist argv0] && [info script] == $argv0 } {
    dictree::main {*}$argv
}

#-------------------------------------------------------------------------------
#  end of file
#-------------------------------------------------------------------------------