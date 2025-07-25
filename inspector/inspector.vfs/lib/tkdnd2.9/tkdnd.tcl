#
# tkdnd.tcl --
#
#    This file implements some utility procedures that are used by the TkDND
#    package.
#
# This software is copyrighted by:
# George Petasis, National Centre for Scientific Research "Demokritos",
# Aghia Paraskevi, Athens, Greece.
# e-mail: petasis@iit.demokritos.gr
#
# The following terms apply to all files associated
# with the software unless explicitly disclaimed in individual files.
#
# The authors hereby grant permission to use, copy, modify, distribute,
# and license this software and its documentation for any purpose, provided
# that existing copyright notices are retained in all copies and that this
# notice is included verbatim in any distributions. No written agreement,
# license, or royalty fee is required for any of the authorized uses.
# Modifications to this software may be copyrighted by their authors
# and need not follow the licensing terms described here, provided that
# the new terms are clearly indicated on the first page of each file where
# they apply.
#
# IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
# ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
# DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
# IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
# NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
#

package require Tk

namespace eval ::tkdnd {
  variable _topw ".drag"
  variable _tabops
  variable _state
  variable _x0
  variable _y0
  variable _platform_namespace
  variable _drop_file_temp_dir
  variable _auto_update 1

  variable _windowingsystem

  bind TkDND_Drag1 <ButtonPress-1> {tkdnd::_begin_drag press  1 %W %s %X %Y %x %y}
  bind TkDND_Drag1 <B1-Motion>     {tkdnd::_begin_drag motion 1 %W %s %X %Y %x %y}
  bind TkDND_Drag2 <ButtonPress-2> {tkdnd::_begin_drag press  2 %W %s %X %Y %x %y}
  bind TkDND_Drag2 <B2-Motion>     {tkdnd::_begin_drag motion 2 %W %s %X %Y %x %y}
  bind TkDND_Drag3 <ButtonPress-3> {tkdnd::_begin_drag press  3 %W %s %X %Y %x %y}
  bind TkDND_Drag3 <B3-Motion>     {tkdnd::_begin_drag motion 3 %W %s %X %Y %x %y}

  # ----------------------------------------------------------------------------
  #  Command tkdnd::initialise: Initialise the TkDND package.
  # ----------------------------------------------------------------------------
  proc initialise { dir PKG_LIB_FILE PACKAGE_NAME} {
    variable _platform_namespace
    variable _drop_file_temp_dir
    variable _windowingsystem
    global env

    switch [tk windowingsystem] {
      x11 {
        set _windowingsystem x11
      }
      win32 -
      windows {
        set _windowingsystem windows
      }
      aqua  {
        set _windowingsystem aqua
      }
      default {
        error "unknown Tk windowing system"
      }
    }

    ## Get User's home directory: We try to locate the proper path from a set of
    ## environmental variables...
    foreach var {HOME HOMEPATH USERPROFILE ALLUSERSPROFILE APPDATA} {
      if {[info exists env($var)]} {
        if {[file isdirectory $env($var)]} {
          set UserHomeDir $env($var)
          break
        }
      }
    }

    ## Should use [tk windowingsystem] instead of tcl platform array:
    ## OS X returns "unix," but that's not useful because it has its own
    ## windowing system, aqua
    ## Under windows we have to also combine HOMEDRIVE & HOMEPATH...
    if {![info exists UserHomeDir] &&
        [string equal $_windowingsystem windows] &&
        [info exists env(HOMEDRIVE)] && [info exists env(HOMEPATH)]} {
      if {[file isdirectory $env(HOMEDRIVE)$env(HOMEPATH)]} {
        set UserHomeDir $env(HOMEDRIVE)$env(HOMEPATH)
      }
    }
    ## Have we located the needed path?
    if {![info exists UserHomeDir]} {
      set UserHomeDir [pwd]
    }
    set UserHomeDir [file normalize $UserHomeDir]

    ## Try to locate a temporary directory...
    foreach var {TKDND_TEMP_DIR TEMP TMP} {
      if {[info exists env($var)]} {
        if {[file isdirectory $env($var)] && [file writable $env($var)]} {
          set _drop_file_temp_dir $env($var)
          break
        }
      }
    }
    if {![info exists _drop_file_temp_dir]} {
      foreach _dir [list "$UserHomeDir/Local Settings/Temp" \
                         "$UserHomeDir/AppData/Local/Temp" \
                         /tmp \
                         C:/WINDOWS/Temp C:/Temp C:/tmp \
                         D:/WINDOWS/Temp D:/Temp D:/tmp] {
        if {[file isdirectory $_dir] && [file writable $_dir]} {
          set _drop_file_temp_dir $_dir
          break
        }
      }
    }
    if {![info exists _drop_file_temp_dir]} {
      set _drop_file_temp_dir $UserHomeDir
    }
    set _drop_file_temp_dir [file native $_drop_file_temp_dir]

    source $dir/tkdnd_generic.tcl
    switch $_windowingsystem {
      x11 {
        source $dir/tkdnd_unix.tcl
        set _platform_namespace xdnd
      }
      win32 -
      windows {
        source $dir/tkdnd_windows.tcl
        set _platform_namespace olednd
      }
      aqua  {
        source $dir/tkdnd_macosx.tcl
        set _platform_namespace macdnd
      }
      default {
        error "unknown Tk windowing system"
      }
    }
    load $dir/$PKG_LIB_FILE $PACKAGE_NAME
    source $dir/tkdnd_compat.tcl
    ${_platform_namespace}::initialise
  };# initialise

  proc GetDropFileTempDirectory { } {
    variable _drop_file_temp_dir
    return $_drop_file_temp_dir
  }
  proc SetDropFileTempDirectory { dir } {
    variable _drop_file_temp_dir
    set _drop_file_temp_dir $dir
  }
 
};# namespace ::tkdnd

# ----------------------------------------------------------------------------
#  Command tkdnd::drag_source
# ----------------------------------------------------------------------------
proc ::tkdnd::drag_source { mode path { types {} } { event 1 } } {
  set tags [bindtags $path]
  set idx  [lsearch $tags "TkDND_Drag*"]
  switch -- $mode {
    register {
      if { $idx != -1 } {
        bindtags $path [lreplace $tags $idx $idx TkDND_Drag$event]
      } else {
        bindtags $path [concat $tags TkDND_Drag$event]
      }
      set types [platform_specific_types $types]
      set old_types [bind $path <<DragSourceTypes>>]
      foreach type $types {
        if {[lsearch $old_types $type] < 0} {lappend old_types $type}
      }
      bind $path <<DragSourceTypes>> $old_types
    }
    unregister {
      if { $idx != -1 } {
        bindtags $path [lreplace $tags $idx $idx]
      }
    }
  }
};# tkdnd::drag_source

# ----------------------------------------------------------------------------
#  Command tkdnd::drop_target
# ----------------------------------------------------------------------------
proc ::tkdnd::drop_target { mode path { types {} } } {
  variable _windowingsystem
  set types [platform_specific_types $types]
  switch -- $mode {
    register {
      switch $_windowingsystem {
        x11 {
          _register_types $path [winfo toplevel $path] $types
        }
        win32 -
        windows {
          _RegisterDragDrop $path
          bind <Destroy> $path {+ tkdnd::_RevokeDragDrop %W}
        }
        aqua {
          macdnd::registerdragwidget [winfo toplevel $path] $types
        }
        default {
          error "unknown Tk windowing system"
        }
      }
      set old_types [bind $path <<DropTargetTypes>>]
      set new_types {}
      foreach type $types {
        if {[lsearch -exact $old_types $type] < 0} {lappend new_types $type}
      }
      if {[llength $new_types]} {
        bind $path <<DropTargetTypes>> [concat $old_types $new_types]
      }
    }
    unregister {
      switch $_windowingsystem {
        x11 {
        }
        win32 -
        windows {
          _RevokeDragDrop $path
        }
        aqua {
          error todo
        }
        default {
          error "unknown Tk windowing system"
        }
      }
      bind $path <<DropTargetTypes>> {}
    }
  }
};# tkdnd::drop_target

# ----------------------------------------------------------------------------
#  Command tkdnd::_begin_drag
# ----------------------------------------------------------------------------
proc ::tkdnd::_begin_drag { event button source state X Y x y } {
  variable _x0
  variable _y0
  variable _state

  switch -- $event {
    press {
      set _x0    $X
      set _y0    $Y
      set _state "press"
    }
    motion {
      if { ![info exists _state] } {
        # This is just extra protection. There seem to be
        # rare cases where the motion comes before the press.
        return
      }
      if { [string equal $_state "press"] } {
        if { abs($_x0-$X) > 3 || abs($_y0-$Y) > 3 } {
          set _state "done"
          _init_drag $button $source $state $X $Y $x $y
        }
      }
    }
  }
};# tkdnd::_begin_drag

# ----------------------------------------------------------------------------
#  Command tkdnd::_init_drag
# ----------------------------------------------------------------------------
proc ::tkdnd::_init_drag { button source state rootX rootY X Y } {
  # Call the <<DragInitCmd>> binding.
  set cmd [bind $source <<DragInitCmd>>]
  if {[string length $cmd]} {
    set cmd [string map [list %W $source %X $rootX %Y $rootY %x $X %y $Y \
                              %S $state  %e <<DragInitCmd>> %A \{\} %% % \
                              %t [bind $source <<DragSourceTypes>>]] $cmd]
    set code [catch {uplevel \#0 $cmd} info options]
    switch -exact -- $code {
      0 {}
      3 - 4 {
        # FRINK: nocheck
        return
      }
      default {
        return -options $options $info
      }
    }

    set len [llength $info]
    if {$len == 3} {
      foreach { actions types _data } $info { break }
      set types [platform_specific_types $types]
      set data [list]
      foreach type $types {
        lappend data $_data
      }
      unset _data
    } elseif {$len == 2} {
      foreach { actions _data } $info { break }
      set data [list]; set types [list]
      foreach {t d} $_data {
        foreach t [platform_specific_types $t] {
          lappend types $t; lappend data $d
        }
      }
      unset _data t d
    } else {
      if {$len == 1 && [string equal [lindex $actions 0] "refuse_drop"]} {
        return
      }
      error "not enough items in the result of the <<DragInitCmd>>\
             event binding. Either 2 or 3 items are expected."
    }
    set action refuse_drop
    variable _windowingsystem
    switch $_windowingsystem {
      x11 {
        set action [xdnd::_dodragdrop $source $actions $types $data $button]
      }
      win32 -
      windows {
        set action [_DoDragDrop $source $actions $types $data $button]
      }
      aqua {
        set action [macdnd::dodragdrop $source $actions $types $data $button]
      }
      default {
        error "unknown Tk windowing system"
      }
    }
    ## Call _end_drag to notify the widget of the result of the drag
    ## operation...
    _end_drag $button $source {} $action {} $data {} $state $rootX $rootY $X $Y
  }
};# tkdnd::_init_drag

# ----------------------------------------------------------------------------
#  Command tkdnd::_end_drag
# ----------------------------------------------------------------------------
proc ::tkdnd::_end_drag { button source target action type data result
                          state rootX rootY X Y } {
  set rootX 0
  set rootY 0
  # Call the <<DragEndCmd>> binding.
  set cmd [bind $source <<DragEndCmd>>]
  if {[string length $cmd]} {
    set cmd [string map [list %W $source %X $rootX %Y $rootY %x $X %y $Y %% % \
                              %S $state %e <<DragEndCmd>> %A \{$action\}] $cmd]
    set info [uplevel \#0 $cmd]
    # if { $info != "" } {
    #   variable _windowingsystem
    #   foreach { actions types data } $info { break }
    #   set types [platform_specific_types $types]
    #   switch $_windowingsystem {
    #     x11 {
    #       error "dragging from Tk widgets not yet supported"
    #     }
    #     win32 -
    #     windows {
    #       set action [_DoDragDrop $source $actions $types $data $button]
    #     }
    #     aqua {
    #       macdnd::dodragdrop $source $actions $types $data
    #     }
    #     default {
    #       error "unknown Tk windowing system"
    #     }
    #   }
    #   ## Call _end_drag to notify the widget of the result of the drag
    #   ## operation...
    #   _end_drag $button $source {} $action {} $data {} $state $rootX $rootY
    # }
  }
};# tkdnd::_end_drag

# ----------------------------------------------------------------------------
#  Command tkdnd::platform_specific_types
# ----------------------------------------------------------------------------
proc ::tkdnd::platform_specific_types { types } {
  variable _platform_namespace
  ${_platform_namespace}::platform_specific_types $types
}; # tkdnd::platform_specific_types

# ----------------------------------------------------------------------------
#  Command tkdnd::platform_independent_types
# ----------------------------------------------------------------------------
proc ::tkdnd::platform_independent_types { types } {
  variable _platform_namespace
  ${_platform_namespace}::platform_independent_types $types
}; # tkdnd::platform_independent_types

# ----------------------------------------------------------------------------
#  Command tkdnd::platform_specific_type
# ----------------------------------------------------------------------------
proc ::tkdnd::platform_specific_type { type } {
  variable _platform_namespace
  ${_platform_namespace}::platform_specific_type $type
}; # tkdnd::platform_specific_type

# ----------------------------------------------------------------------------
#  Command tkdnd::platform_independent_type
# ----------------------------------------------------------------------------
proc ::tkdnd::platform_independent_type { type } {
  variable _platform_namespace
  ${_platform_namespace}::platform_independent_type $type
}; # tkdnd::platform_independent_type

# ----------------------------------------------------------------------------
#  Command tkdnd::bytes_to_string
# ----------------------------------------------------------------------------
proc ::tkdnd::bytes_to_string { bytes } {
  set string {}
  foreach byte $bytes {
    append string [binary format c $byte]
  }
  return $string
};# tkdnd::bytes_to_string

# ----------------------------------------------------------------------------
#  Command tkdnd::urn_unquote
# ----------------------------------------------------------------------------
proc ::tkdnd::urn_unquote {url} {
  set result ""
  set start 0
  while {[regexp -start $start -indices {%[0-9a-fA-F]{2}} $url match]} {
    foreach {first last} $match break
    append result [string range $url $start [expr {$first - 1}]]
    append result [format %c 0x[string range $url [incr first] $last]]
    set start [incr last]
  }
  append result [string range $url $start end]
  return $result
};# tkdnd::urn_unquote

#-----------------------------------------------------------------------
proc ::tkdnd::addType {name mime} {
   # erg�nzt das tkDND-dict um einen DND_Typ <name> und mime
   # mime ist frei w�hlbar, muss bei target und source
   # �bereinstimmen und in einem Programm eindeutig sein
   #-----------------------------------------------------------------------
   
   dict set ::tkdnd::generic::_tkdnd2platform $name $mime
   dict set ::tkdnd::generic::_platform2tkdnd $mime $name
   return
}
# -*- coding: ISO8859-15 -*-