#
# speedbar.tcl
#
# (c) 2007 Wolf-Dieter Busch
# Licence: Bremer Lizenz
# 
# Provides a megawidget as program editor tailored for Tcl.
# Contains 2 megawidgets of class scrolledtext,
# the left of which shows files, procedures, and methods
# and the right of which contains the edited text.
#
# Usage:
# package require speedbar
# Creating a speedbar:
# speedbar .sb
#
# provided commands:
# configure, cget inherits 1st from frame, then from child widget text.
# methods fullpath, keywords, open, element,
# currentProcedure, currentProcedureIndices
# and all methods of child widget text.
#

package require scrolledtext
package provide speedbar 0.1

namespace eval speedbar {
  # indexOfKeywordName:
  # contains index inside line where the name of the item occurs
  array set indexOfKeywordName {
    proc 1
    ::proc 1
    xproc 1
    ::xproc 1
    tclUtil::xproc 1
    ::tclUtil::xproc 1
    method end-2
    ::method end-2

    ::obj::class 1
    ::obj::inscope 1
    ::obj::constructor 1
    ::obj::destructor 1
    ::obj::cgetmethod 2
    ::obj::configuremethod 2
    ::obj::validatemethod 2
    ::obj::method 2
    ::obj::new 1
    obj::class 1
    obj::inscope 1
    obj::constructor 1
    obj::destructor 1
    obj::cgetmethod 2
    obj::configuremethod 2
    obj::validatemethod 2
    obj::method 2
    obj::new 1
    my 1
    our 1    

    snit::method {1 2}
    ::snit::method {1 2}
    itcl::method end-2
    ::itcl::method end-2
    private 2
    protected 2
    public 2
    common 1
    virtual 2
    constructor ""
    destructor {}
    configuremethod 1
    ::configuremethod 1
    itcl::configuremethod 1
    ::itcl::configuremethod 1
    type 1
    ::type 1
    snit::type 1
    ::snit::type 1
    typevariable 1
    variable 1
    component 1
    typecomponent 1
    typeconstructor {}
    typemethod 1

    class 1
    ::class 1
    itcl::class 1
    ::itcl::class 1
    {namespace eval} 2
    {::namespace eval} 2	
    body 1
    itcl::body 1
    ::itcl::body 1

    set 1
    ::set 1
    {array set} 2
    {::array set} 2
    {package require} 2
    {::package require} 2
  }
  
  #
  # ConstructorNames
  # contains keywords
  # where nested keywords occur inside definition
  #
  set ConstructorNames {
    type ::type snit::type ::snit::type
    class ::class itcl::class ::itcl::class
    proc ::proc xproc ::xproc
    namespace ::namespace
    typeconstructor

    ::obj::method
    ::obj::constructor
    ::obj::destructor
    ::obj::cgetmethod
    ::obj::configuremethod
    ::obj::validatemethod
    obj::method
    obj::constructor
    obj::destructor
    obj::cgetmethod
    obj::configuremethod
    obj::validatemethod

    body itcl::body ::itcl::body
  }
  
  array set currentFile {}
  array set currentDirectory {}
  array set cachedFileContents {}
  array set windowState {}
  array set fileState {}
  
  namespace export speedbar
  namespace eval dummy {}
  array set targetWindow {}
}

#
# speedbar::cat file
# return contents of $file
#
proc speedbar::cat file {
  set p [open $file]
  set result [read $p]
  close $p
  set result
}

proc speedbar::method_highlight {win {how toggle}} {
  variable targetWindow
  ::syntaxhighlight::highlight $targetWindow($win) $how
}

proc speedbar::getFileContents file {
  variable currentFile
  foreach win [array names currentFile] {
    if {$currentFile($win) eq $file} then {
      return [$win get 1.0 end-1chars]
    }
  }
  variable cachedFileContents
  foreach filename [array names cachedFileContents] {
    if {$filename eq $file} then {
      return $cachedFileContents($filename)
    }
  }
  cat $file
}

#
# speedbar::Src2completeExpressions src
# return list of expressions where each expr is [info complete]
# if last expr is not complete, then drop it.
#
proc speedbar::Src2completeExpressions src {
  set result {}
  set currentLine {}
  foreach line [split $src \n] {
    append currentLine $line \n
    if {[info complete $currentLine]} then {
      lappend result $currentLine
      set currentLine {}
    }
  }
  set result
}

#
# Src2itemsWithProperties
# convert line to list of items
# each item has the form:
# {keyword $name line $line content $content}
# where content are sub-expressions such as class -> method.
#
proc speedbar::Src2itemsWithProperties {src args} {
  variable indexOfKeywordName
  variable ConstructorNames
  array set opt [concat {-startingat 1} $args]
  set keywords [array names indexOfKeywordName]
  set result {}
  set currentLine $opt(-startingat)
  foreach expr [Src2completeExpressions $src] {
    if {![catch {set firstEl [lindex $expr 0]}]} then {
      set first2Els [lrange $expr 0 1]
      set key\
        [expr {[lsearch $keywords $first2Els] >= 0 ? $first2Els :
               [lsearch $keywords $firstEl] >= 0 ? $firstEl : ""}]
      if {$key ne ""} then {
        # hard-wired exception for set without value:
        if {$key eq "set" && [llength $expr] <= 2} then continue
        # set name [lindex $expr $indexOfKeywordName($key)]
        set indices $indexOfKeywordName($key)
        set name ""
        foreach index $indices {
          lappend name [lindex $expr $index]
        }	
        if {$key eq "set" && [regexp \\W $name]} then continue
        set props {}
        lappend props lines $currentLine content
        if {[lsearch $ConstructorNames $firstEl] < 0} then {
          lappend props {}
        } else {
          lappend props\
            [Src2itemsWithProperties [lindex $expr end]\
               -startingat $currentLine]
        }
        lappend result [concat [list $firstEl $name] $props]
      }
    }
    incr currentLine [expr {[llength [split $expr \n]] - 1}]
  }
  lsort -dictionary $result
}

#
# speedbar::writeDirectory win dir
# write directory contents,
# switch event bindings such that
# sub-directories are folded out.
#
proc speedbar::writeDirectory {win dir {ext *.tcl}} {
  variable currentDirectory
  set currentDirectory([winfo parent $win]) $dir
  set dir [file normalize $dir]
  set parentDir [file dirname $dir]/
  set parentDirTag [encodedPath $parentDir]
  $win configure -state normal
  $win delete 1.0 end
  $win insert end ../\n $parentDirTag
  $win tag bind $parentDirTag <Double-1>\
    [list ::speedbar::writeDirectory $win $parentDir $ext]
  $win tag bind $parentDirTag <Double-1>\
    +[list cd $parentDir]
  $win tag bind $parentDirTag <Control-1>\
    [list ::speedbar::writeDirectory $win $parentDir $ext]
  $win tag bind $parentDir
  $win tag bind $parentDirTag <Control-1>\
    +[list cd $parentDir]
  set subdirs [lsort -dictionary [glob -nocomplain -directory $dir */]]
  set files [lsort -dictionary [glob -nocomplain -directory $dir $ext]]
  foreach subdir $subdirs {
    set tag [encodedPath $subdir]
    $win insert end [file tail $subdir]/\n $tag
    $win tag bind $tag <1>\
      [list ::speedbar::toggleSubDirectory $win $subdir $ext]
    $win tag bind $tag <Double-1>\
      [list ::speedbar::writeDirectory $win $subdir $ext]
    $win tag bind $tag <Double-1>\
      +[list cd $subdir]
    $win tag bind $tag <Control-1>\
      [list ::speedbar::writeDirectory $win $subdir $ext]
    $win tag bind $tag <Control-1>\
      +[list cd $subdir]
  }
  foreach file $files {
    set tag [encodedPath $file]
    $win insert end [file tail $file]\n $tag
    $win tag bind $tag <1>\
      [list ::speedbar::toggleFile $win $file]
    set textWin [string trimright [winfo parent $win] .].text
    $win tag bind $tag <Double-1>\
      [list ::speedbar::openFile $file $textWin]
    $win tag bind $tag <Control-1>\
      [list ::speedbar::openFile $file $textWin]
  }
  $win configure -state disabled
  after idle [list $win tag remove sel 1.0 end]
}

#
# speedbar::normalisePath path
# return path with trailing / if it is a directory
#
proc speedbar::normalisePath path {
  set path [file normalize $path]
  if {[file isdir $path]} then {
    set path [string trimright $path /]/
  } else {
    set path
  }
}

#
# speedbar::encodedPath path
# return path with spaces hex-encoded 
#
proc speedbar::encodedPath path {
  string map [list % %25 " " %20] [normalisePath $path]
}

#
# speedbar::decodedPath path
# decode hex-encoded spaces, return decoded path
#
proc speedbar::decodedPath path {
  string map [list %25 % %20 " "] $path
}

#
# speedbar::dirEmpty? dir ?ext?
# return true if dir has neither subdir nor *.tcl
#
# proc speedbar::dirEmpty? {dir {ext *.tcl}} {
#     set dirs [glob -nocomplain -type d $dir/*]
#     set files [glob -nocomplain -type f $dir/$ext]
#     expr {[llength $dirs]+[llength $files] == 0 ? yes : no}
# }

#
# speedbar::incrIndent win index ?howmuch?
# return (indent level + 2) at win & index
#
proc speedbar::incrIndent {win index {howmuch 2}} {
  set lineStart [$win index "$index linestart"]
  if {[$win compare $lineStart == 1.0]} then {
    return 0
  }
  set start [$win index $lineStart-1lines]
  set end [$win index "$start lineend"]
  set contents [$win get $start $end]
  set trimmedContents [string trimleft $contents]
  set spaces [expr {[string length $contents] -
                    [string length $trimmedContents]}]
  incr spaces $howmuch
}

#
# speedbar::toggleSubDirectory  win dir
# If subdirectory is not yet there, then
# write it below its parent directory, indented +2.
# If subdirectory is there, then hide it.
# If subdirectory is hidden, then show it.
#
proc speedbar::toggleSubDirectory {win dir {ext *.tcl}} {
  set subDirTag subdir:[encodedPath $dir]
  set ranges [$win tag ranges $subDirTag]
  if {[llength $ranges] > 0} then {
    if {[$win tag cget $subDirTag -elide] == ""} then {
      $win tag configure $subDirTag -elide 1
    } else {
      $win tag configure $subDirTag -elide ""
    }
    return
  }
  $win configure -state normal
  set dirTag [encodedPath $dir]
  set ranges [$win tag ranges $dirTag]
  if {[llength $ranges] == 0} then return
  set startIndex [lindex $ranges end]
  set currentTags {}
  foreach tagName [$win tag names $startIndex-1chars] {
    if {[string range $tagName 0 6] eq "subdir:"} then {
      lappend currentTags $tagName
    }
  }
  $win mark set insert $startIndex
  set directories [glob -nocomplain -type d [file join $dir *]]
  set files [glob -nocomplain -type f [file join $dir *.tcl]]
  eval lappend files [glob -nocomplain -type f [file join $dir *.tm]]
  set level [incrIndent $win insert]
  foreach subdir [lsort -dictionary $directories] {
    set subdir [file normalize $subdir]
    set str [string repeat " " $level]
    append str [file tail $subdir] / \n
    set pathTag [encodedPath $subdir]
    $win insert insert $str $currentTags
    $win tag add $pathTag insert-1lines insert
    $win tag bind $pathTag <1>\
      [list ::speedbar::toggleSubDirectory $win $subdir]
    $win tag bind $pathTag <Double-1>\
      [list ::speedbar::writeDirectory $win $subdir $ext]
    $win tag bind $pathTag <Control-1>\
      [list ::speedbar::writeDirectory $win $subdir $ext]
  }
  foreach file [lsort -dictionary $files] {
    set str [string repeat " " $level]
    append str [file tail $file] \n
    set pathTag [encodedPath $file]
    $win insert insert $str $currentTags
    $win tag add $pathTag insert-1lines insert
    set textWin [string trimright [winfo parent $win] .].text
    $win tag bind $pathTag <1>\
      [list ::speedbar::toggleFile $win $file]
    $win tag bind $pathTag <Double-1>\
      [list ::speedbar::openFile $file $textWin]
    $win tag bind $pathTag <Control-1>\
      [list ::speedbar::openFile $file $textWin]
  }
  $win tag add $subDirTag $startIndex [$win index insert]
  $win tag configure $subDirTag -elide ""
  $win configure -state disabled
}

#
# speedbar::toggleFile win file
# If file content is not yet there, write it below file name.
# If file content is there, delete it.
#
proc speedbar::toggleFile {win file} {
  set tag [encodedPath $file]
  set ranges [$win tag ranges $tag]
  if {$ranges eq {}} then return
  set index [lindex $ranges end]
  $win mark set insert $index
  $win configure -state normal
  if {[$win tag ranges content:$tag] eq {}} then {
    set index [$win index insert]
    writeFile $win $file
    $win tag add content:$tag $index insert
  } else {
    $win delete content:$tag.first content:$tag.last
  }
  $win configure -state disabled
}

#
# speedbar::writeFile win file
# Write contents of file at mark insert.
# Content means here:
# keep num of leading spaces of filename above,
# then + or - sign (depending on empty or not),
# then the keyword proc, class, method, etc.,
# then appropriate name, followed by newline.
#
proc speedbar::writeFile {win file} {
  set toplevel [winfo toplevel $win]
  set cursor [$toplevel cget -cursor]
  $toplevel configure -cursor watch
  update
  set index [$win index insert]
  set tag [encodedPath $file]
  set currentTags {}
  foreach tagName [$win tag names insert-1chars] {
    if {[string range $tagName 0 6] eq "subdir:"} then {
      lappend currentTags $tagName
    }
  }
  set level [incrIndent $win insert 0]
  foreach el [Src2itemsWithProperties [getFileContents $file]] {
    writeItem $win $level $file $el
  }
  foreach tagName $currentTags {
    $win tag add $tagName $index insert
  }
  $toplevel configure -cursor $cursor
}

#
# speedbar::nextItemTag win
# return text tag name which is not yet in use.
#
proc speedbar::nextItemTag win {
  set count 0
  while {[$win tag ranges item$count] ne {}} {
    incr count
  }
  set tag item$count
  foreach propL [$win tag configure $tag] {
    catch [list $win tag configure $tag [lindex $propL 0] ""]
  }
  foreach bind [$win tag bind $tag] {
    $win tag bind $tag $bind ""
  }
  set tag
}

#
# speedbar::writeItem win level file el parentlist
# write an item line (procedure, class, etc).
#
proc speedbar::writeItem {win level file el} {
  set keyword [lindex $el 0]
  set itemName [lindex $el 1]
  array set prop [lrange $el 2 end]
  $win insert insert [string repeat " " $level]
  #
  set plusItemTag [nextItemTag $win]
  $win insert insert + $plusItemTag
  set minusItemTag [nextItemTag $win]
  $win insert insert - $minusItemTag
  if {[llength $prop(content)] > 0} then {
    $win tag configure $minusItemTag -elide yes
  } else {
    $win tag configure $plusItemTag -elide yes
  }
  set index [$win index insert]
  $win insert insert " $keyword"
  # set tag constructorname
  if {$itemName ne ""} then {
    $win tag add constructorname $index insert
  }
  $win insert insert " $itemName\n"
  # set tag pathname
  set indices [regexp -inline -indices {^.*([:])} $itemName]
  if {[llength $indices] > 0} then {
    set from [$win index insert-[string length "$itemName\n"]chars]
    set to [$win index $from+[lindex $indices end end]chars+1chars]
    $win tag add pathname $from $to
  }
  set itemTag [nextItemTag $win]
  set textWin [string trimright [winfo parent $win] .].text
  $win tag add $itemTag insert-1lines insert
  $win tag bind $itemTag <Double-1>\
    [list ::speedbar::openFileAtLine $file $textWin $prop(lines)]
  $win tag bind $itemTag <Control-1>\
    [list ::speedbar::openFileAtLine $file $textWin $prop(lines)]
  set level2 [expr {$level + 2}]
  foreach el $prop(content) {
    writeItem $win $level2 $file $el
  }
  set subItemTag [nextItemTag $win]
  $win tag add $subItemTag $itemTag.last insert
  if {[$win tag ranges $subItemTag] ne ""} then {
    $win tag configure $subItemTag -elide yes
    $win tag bind $itemTag <1> [subst -nocommand {
        if {[$win tag cget $subItemTag -elide] eq ""} then {
          $win tag configure $subItemTag -elide yes
          $win tag configure $plusItemTag -elide ""
          $win tag configure $minusItemTag -elide yes
        } else {
          $win tag configure $subItemTag -elide ""
          $win tag configure $plusItemTag -elide yes
          $win tag configure $minusItemTag -elide ""
        }
      }]
  }
}

#
# speedbar::openFileAtLine file win line
# Write contents of $file to $win, if not yet done
# then set insert to start of $line.
#
proc speedbar::openFileAtLine {file win line} {
  variable targetWindow
  openFile $file $win
  set speedbar [winfo parent $win]
  set text $targetWindow($speedbar)
  $text mark set insert $line.0
  $text see insert
  focus -force $text
}

#
# speedbar::openFile file win
# Write contents of $file to $win.
#
proc speedbar::openFile {file win} {
  variable targetWindow
  # focus -force [$win element text]
  set speedbar [winfo parent $win]
  set text $targetWindow($speedbar)
  #
  set file [file normalize $file]
  variable currentFile
  variable cachedFileContents
  variable fileState
  set inst [winfo parent $win]
  foreach obj [array names currentFile] {
    if {$obj eq $inst} then continue
    if {$currentFile($obj) eq $file} then {
      return -code error\
        [list $file already opened by speedbar $obj -- sorry]
    }
  }
  if {$currentFile($inst) ne $file} then {
    if {$currentFile($inst) ne ""} then {
      # set cachedFileContents($currentFile($inst))\
        [[winfo parent $win].text get 1.0 end-1chars]
      set cachedFileContents($currentFile($inst))\
        [$text get 1.0 end-1chars]
      set fileState([list $currentFile($inst) xview])\
        [lindex [$text xview] 0]
      set fileState([list $currentFile($inst) yview])\
        [lindex [$text yview] 0]
      set fileState([list $currentFile($inst) insert])\
        [$text index insert]
      set fileState([list $currentFile($inst) modified])\
        [$text edit modified]
      set tags {}
      foreach tag [$text tag names] {
        if {[$text tag ranges $tag] ne ""} then {
          lappend tags "(widget) tag add $tag [$text tag ranges $tag]"
        }
      }
      set fileState([list $currentFile($inst) tagCmd]) [join $tags \n]
    }
    set undoBefore [$text cget -undo]
    aloud $text configure -undo no
    $text delete 1.0 end
    if {[info exists cachedFileContents($file)]} then {
      $text insert 1.0 $cachedFileContents($file)
      unset cachedFileContents($file)
      $text xview moveto $fileState([list $file xview])
      $text yview moveto $fileState([list $file yview])
      $text mark set insert $fileState([list $file insert])
      $text edit reset
      $text edit modified $fileState([list $file modified])
      eval [string map\
              [list (widget) $text]\
              $fileState([list $file tagCmd])]
    } else {
      $text insert 1.0 [cat $file]
      $text mark set insert 1.0
      $text edit reset
      $text edit modified no
      catch {
        if {$::preferences(highlight)} then {
          method_highlight [winfo parent $win]
        }
      }
    }
    $text configure -undo $undoBefore
  }
  event generate [$speedbar element text] <<Change>>
  set currentFile($speedbar) $file
}

#
# method call:
# $obj keywords 
# => returns true if full path of namespaces in navi window are visible
# $obj keywords yes
# => shows up full path of namespaces in navi window
# $obj keywords no
# => hides full path of namespaces in navi window
#
proc speedbar::method_keywords {win {what ""}} {
  variable windowState
  if {[lsearch [$win.navi tag names] constructorname] < 0}  then {
    $win tag add constructorname 1.0
    $win tag remove constructorname 1.0
  }
  if {$what eq ""} then {
    expr {[$win.navi tag cget constructorname -elide] eq "" ? yes : no}
  } else {
    if {$what eq "toggle"} then {
      if {[method_keywords $win]} then {
        method_keywords $win no
      } else {
        method_keywords $win yes
      }
    } elseif {$what} then {
      $win.navi tag configure constructorname -elide ""
    } else {
      $win.navi tag configure constructorname -elide yes
    }
    set windowState([list $win keywords]) [method_keywords $win]
  }
}

#
# method call:
# $obj fullnamespace 
# => returns true if full path of namespaces in navi window are visible
# $obj fullnamespace yes
# => shows up full path of namespaces in navi window
# $obj fullnamespace no
# => hides full path of namespaces in navi window
#
proc speedbar::method_fullnamespace {win {what ""}} {
  variable windowState
  if {[lsearch [$win.navi tag names] pathname] < 0}  then {
    $win tag add pathname 1.0
    $win tag remove pathname 1.0
  }
  if {$what eq ""} then {
    expr {[$win.navi tag cget pathname -elide] eq "" ? yes : no}
  } else {
    if {$what eq "toggle"} then {
      if {[method_fullnamespace $win]} then {
        method_fullnamespace $win no
      } else {
        method_fullnamespace $win yes
      }
    } elseif {$what} then {
      $win.navi tag configure pathname -elide ""
    } else {
      $win.navi tag configure pathname -elide yes
    }
    set windowState([list $win fullnamespace]) [method_fullnamespace $win]
  }
}

#
# method call:
# $obj currentProcedureIndices ?index?
# returns start end end indices of procedure in text widget
# where index is contained
#
#
proc speedbar::method_currentProcedureIndices {win {index insert}} {
  set startIndex [$win index "$index linestart"]
  set endIndex $startIndex+1lines
  while {[$win compare $startIndex > 1.0] &&
         ![info complete [$win get 1.0 "$startIndex lineend"]]} {
    set startIndex [$win index $startIndex-1lines]
  }
  while {![info complete [$win get $startIndex $endIndex]]} {
    if {[$win compare $endIndex >= end]} then {
      return -code error\
        [list incomplete expression\
           in speedbar $win at $startIndex]
    }
    set endIndex [$win index $endIndex+1lines]
  }
  if {[$win compare $startIndex > 1.0] &&
      [$win compare $startIndex > $endIndex]} then {
    set startIndex [$win index $startIndex+1lines]
  }
  if {[$win compare "$startIndex linestart" == "$startIndex lineend"] ||
      [string index [string trim\
                       [$win get\
                          "$startIndex linestart"\
        "$startIndex lineend"]] 0] eq "\#"} {
    set startIndex [$win index $startIndex+1lines]
  }
  list $startIndex $endIndex
}

#
# method call:
# $obj currentProcedure ?index?
# => contents of procedure in text window
# containing index, if given, else insert mark
#
proc speedbar::method_currentProcedure {win {index insert}} {
    string trim [eval $win get [method_currentProcedureIndices $win $index]]
}

#
# method call:
# $obj open directory/
# => writes directory to navi window 
# $obj open file.tcl
# => writes file.tcl to text window,
# writes containing directory to navi window, if still empty
# Previous contents of text window are copied to cache.
#
proc speedbar::method_open {win fileOrDir} {
  if {[file isdir $fileOrDir]} then {
    writeDirectory $win.navi $fileOrDir
    cd $fileOrDir
  } else {
    openFile $fileOrDir $win.text
    if {[string trim [$win.navi get 1.0 end-1chars]] eq ""} then {
      method_open $win [file dirname $fileOrDir]
    }
  }
  file normalize $fileOrDir
}

#
# method call:
# $obj close => clears widget
# $obj close cache => clears cached files
# $obj close all => clears own and all cached files
#
proc speedbar::method_close {win {which own}} {
  variable currentFile
  variable cachedFileContents
  variable targetWindow
  switch $which {
    own {
      $targetWindow($win) delete 1.0 end
      set currentFile($win) ""
    }
    all {
      method_close $win own
      method_close $win cache
    }
    cache {
      foreach fileName [array names cachedFileContents] {
        method_open $win $fileName
        method_close $win own
      }
      foreach fileName [array names cachedFileContents] {
        method_open $win $fileName
      }
    }
  }
}

#
# method call:
# $obj save => writes widget contents back to file
# $obj save filename => writes widget to file $filename
#
proc speedbar::method_save {win {file ""}} {
  variable currentFile
  if {$file eq ""} then {
    set file $currentFile($win)
  }
  if {$file eq ""} then return
  set port [open $file w]
  puts -nonewline $port [$win get 1.0 end-1chars]
  close $port
  set currentFile($win) [file normalize $file]
}

#
# method call:
# $obj methods
# => list of possible methods of speedbar obj
# except those inherited from text widget
#
proc speedbar::method_methods {win {pat *}} {
  set result {}
  foreach cmd [info command ::speedbar::method_*] {
    set cmd [string map {::speedbar::method_ ""} $cmd]
    if {[string match $pat $cmd]} then {
      lappend result $cmd
    }
  }
  set result
}

#
# method call:
# $obj instances
# => list of all speedbar widgets
#
proc speedbar::method_instances win {
  variable currentFile
  array names currentFile
}

#
# method call:
# $obj cache
# => filenames of all cached files
#
proc speedbar::method_cache {win args} {
  array set opt [concat {
      -mode info 
      -files {}
    } $args]
  variable cachedFileContents
  variable fileState
  set files [array names cachedFileContents]
  switch -- $opt(-mode) {
    info {
      set files
    }
    detail {
      set result {}
      foreach file $files {
        lappend result\
          [list file $file\
             insert $fileState([list $file insert])\
             xview $fileState([list $file xview])\
             yview $fileState([list $file yview])\
             tagCmd $fileState([list $file tagCmd])]
      }
      set result
    }
    read {
      array unset cachedFileContents
      array unset fileState
      foreach list $opt(-files) {
        array set item $list
        set file $item(file)
        if {[catch {
              set cachedFileContents($file) [cat $file]
            } err]} then continue
        foreach {key val} [lreplace $list 0 1 modified 0] {
          set fileState([list $file $key]) $val
        }
      }
    }
  } 
}

#
# method call:
# $obj filename
# => name of currently opened file
# $obj filename newname
# => changes currently opened filename
#
proc speedbar::method_filename {win {name ""}} {
  variable currentFile
  if {$name eq ""} then {
    set currentFile($win)
  } else {
    set currentFile($win) [file normalize $name]
  }
}

proc speedbar::method_dirname win {
  variable currentDirectory
  set currentDirectory($win)
}

proc speedbar::method_element {win element args} {
  switch -exact -- $element {
    names {
      list navi text
    }
    navi - text {
      uplevel 1 $win.$element element text $args
    }
    default {
      return -code error\
        [list wrong sub-command $element -- should be\
           one of names navi text]
    }
  }
}

proc speedbar::method_commentRegion win {
  if {[$win tag ranges sel] eq {}} then return
  set start [$win index "sel.first linestart"]
  set end [$win index "sel.last lineend"]
  set txt [$win get $start $end]
  $win mark set insert $start
  $win insert insert \#[string map [list \n \n\#\ ] $txt]
  $win delete insert insert+[string length $txt]chars
}

proc speedbar::method_unCommentRegion win {
  if {[$win tag ranges sel] eq {}} then return
  set start [$win index "sel.first linestart"]
  set end [$win index "sel.last lineend"]
  set txt [$win get $start $end]
  $win mark set insert $start
  $win insert insert [regsub -all (^|\\n)\\s*\#\ ? $txt \\1]
  $win delete insert insert+[string length $txt]chars
}

proc speedbar::method_target {win {target {}}} {
  variable targetWindow
  if {$target eq {}} then {
    pack forget $win.navi
    pack $win.pane -expand yes -fill both
    $win.pane add $win.navi $win.text
    set targetWindow($win) 
    return
  } else {
    set targetWindow($win) $target
    $win.pane forget $win.navi $win.text
    pack forget $win.pane
    pack $win.navi -expand yes -fill both
  }
}

# proc speedbar::initTags win {
#   set text [$win element text]
#   $text tag configure comment -foreground \#aa0000 -font {Courier -12 bold}
#   $text tag configure quotes -foreground "" -background \#ffffaa
#   $text tag configure brace -foreground \#007700
#   $text tag configure expand -foreground "" -underline yes
#   $text tag configure string -foreground \#770000
#   $text tag configure bracket -foreground red
#   $text tag configure event -foreground blue
#   $text tag configure command -foreground \#000077 -font {Courier -12 bold}
#   $text tag configure sel -foreground white
#   $text tag raise sel
# }

#
# speedbar::speedbar f args
# create megawidget speedbar which contains
# on left the navigation (directory, files, file items),
# and on right the file contents.
#
proc speedbar::speedbar {f args} {
  variable currentFile
  variable targetWindow
  set currentFile($f) ""
  set currentDirectory($f) ""
  set frame [frame $f -class Speedbar]
  pack [panedwindow $frame.pane\
          -opaqueresize yes\
          -width 600]\
    -expand yes\
    -fill both
  $frame.pane add\
    [scrolledtext $frame.navi -wrap none]\
    [set scrolledText\
       [scrolledtext $frame.text -wrap none -undo yes]]
  set targetWindow($f) $scrolledText
  foreach opt [$frame.navi tag configure sel] {
    catch [list $frame.navi tag configure sel [lindex $opt 0] ""]
  }
  after idle [list catch [list $frame.pane sash place 0 150 0]]
  bind $frame.navi <Destroy> [list ::unset ::speedbar::currentFile($f)]
  set src [subst -nocommand {proc $frame {cmd args} {
        if {[info command ::speedbar::method_\$cmd] ne ""} then {
          return [uplevel 1 ::speedbar::method_\$cmd $f \$args]
        }
        switch -- \$cmd {
          configure - cget {
            if {[catch {
                  set result\
                    [uplevel 1 "::speedbar::dummy::$f \$cmd" \$args]
                }]} then {
              # uplevel 1 [list $f.text] \$cmd \$args
              uplevel 1 [list \$::speedbar::targetWindow($f) \$cmd] \$args
            } else {
              set result
            }
          }
          default {
            uplevel 1 [list \$::speedbar::targetWindow($f) \$cmd] \$args
          }
        }
      }}]
  uplevel \#0 rename $f ::speedbar::dummy::$f
  uplevel \#0 $src
  uplevel \#0 [list $f configure] $args
  uplevel \#0 [list $f fullnamespace yes]
  uplevel \#0 [list $f keywords yes]
  bind $f.pane <Destroy>\
    [list array unset ::speedbar::windowState [list $f *]]
  bind $f.pane <Destroy> +[list rename ::speedbar::dummy::$f ""]
  bind $f.pane <Destroy> +[list rename $f ""]
  # initTags $f
  set f
}

namespace import speedbar::speedbar







