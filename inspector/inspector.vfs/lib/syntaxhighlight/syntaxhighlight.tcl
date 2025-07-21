package require Tk

package provide syntaxhighlight 0.2

namespace eval syntaxhighlight {

  variable charName
#  array set charName [list \" quotes \{ brace \[ bracket \( paren < event]
  array set charName [list \" quotes \{ brace \[ bracket \( paren]
  variable specialChars [array names charName]
  variable closingChar
  array set closingChar\
    [list \" \" \{ \} \[ \] \( \) < >]
  variable transList
  set transList [list \[ \{ \] \} \( \{ \) \} < \{ > \}]
  variable errorMessage ""
  variable nextEvent
  array set nextEvent {}
  variable keywords [list then elseif else until while]
  namespace export highlight {escaped[?]} findClosingBrace
  array set active {}
  variable currentlyRunning no
}

proc syntaxhighlight::escaped? {win index} {
  # return true is char at $index is backslashed
  set count 1
  while {[$win get $index-${count}chars] eq "\\"} {
    incr count
  }
  expr {($count - 1) % 2}
}

proc syntaxhighlight::nonEscapedLineEnd {win index {limit end}} {
  # return end index of logical line
  # i.e. if non-escaped \ at line end,
  # then continue to next line.
  while true {
    if {[$win compare $index >= $limit]} then break
    set index [$win index "$index linestart + 1 lines"]
    if {![escaped? $win $index-1chars]} then break
  }
  $win index $index
}

proc syntaxhighlight::nextTypeRange {win index} {
  # return list of type, start, end,
  # e.g. comment 1.0 2.0,
  # or command 2.0 3.0
  if {![info complete [$win get $index end]]} then return
  set start [$win search -regexp \\S $index end]
  if {$start eq "" || [$win compare $start < $index]} then return
  if {[$win get $start] eq "\#"} then {
    list comment $start [nonEscapedLineEnd $win $start end]
  } else {
    set newLine [$win index "$start linestart"]
    while true {
      set newLine [$win index $newLine+1lines]
      if {[$win compare $newLine >= end]} then break
      if {[info complete [$win get $start $newLine]]} then break
    }
    set semIdx $start
    while true {
      set semIdx [$win search {;} $semIdx+1chars $newLine]
      if {$semIdx eq ""} then {
        set semIdx $newLine
        break
      } elseif {[info complete [$win get $start $semIdx]]} then {
        set semIdx [$win index $semIdx+1chars]
        break
      }
    }
    list command $start $semIdx
  }
}

proc syntaxhighlight::typeRanges {win start end} {
  # return list of types and ranges, e.g.
  # comment 1.0 2.0 command 2.0 2.27 command 2.29 3.0
  set result {}
  while true {
    set typeRange [nextTypeRange $win $start]
    if {$typeRange eq ""} then break
    eval lappend result $typeRange
    set start [lindex $typeRange end]
    if {[$win get $start-1c] ne "\n"} then {
      set start [$win index $start+1chars]
    }
    if {[$win compare $start >= $end]} then break
  }
  set result
}

proc syntaxhighlight::nextBlankIndex {win start} {
  set end [$win index "$start lineend"]
  set result [$win search -regexp \\s $start $end]
  if {$result eq ""} then {
    set end
  } elseif {[$win compare $result >= $start]} then {
    set result
  } else {
    set end
  }
}

proc syntaxhighlight::nextTokenRange {win start end} {
  variable charName
  variable specialChars
  set startIdx [$win search -regexp \\S $start $end]
  if {$startIdx eq ""} then return
  set stopIdx [nextBlankIndex $win $startIdx]
  set char [$win get $startIdx]
  if {[lsearch -exact $specialChars $char] < 0} then {
    set result chars
  } else {
    set result $charName($char)
    set stopIdx [findClosingBrace $win $startIdx $char]
  }
  if {$result eq "brace"} then {
    if {[regexp \[\[\{\$\] [$win get $stopIdx]]} then {
      set result expand
    }
  }
  lappend result $startIdx $stopIdx
}

proc syntaxhighlight::tokenRanges {win start end} {
    set index $start
    set result {}
    while {[set nameFromTo [nextTokenRange $win $index $end]] ne ""} {
	eval lappend result $nameFromTo
	set index [lindex $nameFromTo end]
    }
    set result
}

proc syntaxhighlight::findClosingBrace {win start {char \{}} {
  variable closingChar
  set index $start
  while true {
    set index [$win search $closingChar($char) $index end-1chars]
    if {$index eq ""} then break
    set index [$win index $index+1chars]
    if {[info complete [$win get $start $index]]} then {
      return $index
    }
  }
}

proc syntaxhighlight::nextSpecialChar {win from to} {
    set i 0
    foreach char [split [$win get $from $to] ""] {
	switch -exact -- $char {
	    \[ - \$ {
		return [$win index $from+${i}chars]
	    }
	}
	incr i
    }
}

proc syntaxhighlight::nextTokenSubRange {win from to} {
    set from [$win index $from]
    set to [$win index $to]
    set idx [nextSpecialChar $win $from $to]
    if {$idx eq "" || [$win compare $idx > $to]} then {
	list chars $from $to
    } elseif {[$win compare $idx > $from]} then {
	list chars $from $idx
    } else {
	set char [$win get $idx]
	switch -exact -- $char {
	    \$ {
		set char1 [$win get $idx+1chars]
		if {$char1 eq "\{"} then {
		    set range [nextTokenSubRange $win $from+1chars $to]
		    if {$range eq ""} then {
			list chars $from [$win index $from+1chars]
		    } else {
			list string $idx [$win index [lindex $range end]]
		    }
		} elseif {$char1 ne "\(" && [regexp \\W $char1]} then {
		    list chars $from [$win index $from+1chars]
		} else {
		    set result string
		    lappend result $from
		    $win search -count num -regexp \\w* $from+1chars $to
		    set idx1 [$win index $from+1chars+${num}chars]
		    if {[$win get $idx1] ne "\("} then {
			lappend result $idx1
		    } else {
			set idx2 [$win index $idx1+1chars]
			while true {
			    set idx2 [$win search "\)" $idx2 $to]
			    if {$idx2 eq "" ||
				[$win compare $idx2 > $to]} then break
			    set txt [$win get $idx1 $idx2+1chars]
			    if {[info complete\
				     [string map\
					  [list \{ - \} - \[ - \] - ]\
					  $txt]]} then break
			}
			if {$idx2 eq ""} then {
			    lappend result $idx1
			} else {
			    lappend result [$win index $idx2+1chars]
			}
		    }
		}
	    }
	    \[ {
		variable charName
		set closingIndex [findClosingBrace $win $idx $char]
		if {$closingIndex eq "" ||
		    [$win compare $closingIndex > $to]} then {
		    list chars $from $to
		} else {
		    list $charName($char) $from $closingIndex
		}
	    }
	    default {
		list chars $from $to
	    }
	}
    }
}

proc syntaxhighlight::tokenSubRanges {win from to} {
  set result {}
  while true {
    set range [nextTokenSubRange $win $from $to]
    if {$range eq ""} then break
    set from [lindex $range end]
    eval lappend result $range
    if {[$win compare $from >= $to]} then break
  }
  set result
}

proc syntaxhighlight::highlightWinFromTo {win from to} {
  variable keywords
  variable active
  if {![winfo exists $win] || 
      ![info exists active($win)] ||
      !$active($win)} then return
  if {![info complete [$win get $from $to]]} then return
  foreach tag [$win tag names] {
    if {$tag ne "sel"} then {
      $win tag remove $tag $from $to
    }
  }
  foreach {typeRange from1 to1} [typeRanges $win $from $to] {
    if {$typeRange eq "comment"} then {
      $win tag add comment $from1 $to1
    } else {
      set first yes
      set expand no
      foreach {tokenRange from2 to2} [tokenRanges $win $from1 $to1] {
        if {$first} then {
          if {[$win get $from2] ne "\}"} then {
            $win tag add command $from2 $to2
          }
          set first no
        }
        switch -exact -- $tokenRange {
          chars {
            if {$expand} then {
              $win tag add expand $from2 $to2
              set expand no
            }
          }
          expand {
            $win tag add $tokenRange $from2 $to2
            $win tag add brace $from2 $to2
            set expand yes
          }
          brace {
            if {[$win search -regexp \\S $from2+1chars "$from2 lineend"] ne ""} then {
              $win tag add $tokenRange $from2 $to2
            } else {
              $win tag add $tokenRange $from2 $from2+1chars $to2-1chars $to2
              set from3 [$win index "$from2 linestart + 1 lines"]
              set to3 [$win index "$to2 linestart"]
              highlightWinFromTo $win $from3 $to3
            }
          }
          bracket {
            if {[string first \n [string map [list \\\n ""] [$win get $from2 $to2]]]<0} then {
              $win tag add $tokenRange $from2 $to2
            } else {
              $win tag add $tokenRange $from2 $from2+1chars $to2-1chars $to2
              highlightWinFromTo $win $from2+1chars $to2-1chars
            }
          }
          default {
            $win tag add $tokenRange $from2 $to2
            if {$expand} then {
              $win tag add expand $from2 $to2
              set expand no
            }
          }
        }
        switch -exact -- $tokenRange {
          chars - quotes {
            foreach {
              subType from3 to3
            } [tokenSubRanges $win $from2 $to2] {
              switch -exact -- $subType {
                chars {}
                default {
                  $win tag add $subType $from3 $to3
                }
              }
            }
          }
        }
      }
    }
  }
}

proc syntaxhighlight::rangeStartIndex {win index} {
  set index [$win index "$index linestart"]
  while {![info complete [$win get 1.0 $index]]} {
    set index [$win index $index-1lines]
  }
  set index
}

proc syntaxhighlight::rangeEndIndex {win from} {
  if {![info complete [$win get $from end]]} then return
  set to [$win index "$from linestart + 1 lines"]
  while {![info complete [$win get $from $to]]} {
    set to [$win index $to+1lines]
  }
  set to
}

proc syntaxhighlight::highlightOnIdle {win args} {
  variable active
  if {![winfo exists $win] || 
      ![info exists active($win)] ||
      !$active($win)} then return
  if {$args eq ""} then {
    set from 1.0
  } else {
    set from [rangeStartIndex $win [lindex $args 0]]
  }
  set to [rangeEndIndex $win $from]
  if {$to eq "" || [$win compare $from >= end-1chars]} then return
  highlightWinFromTo $win $from $to
  tagTrailingBackslash $win $from $to
  set src [list [namespace origin [lindex [info level 0] 0]] $win $to]
  update
  after cancel $src
  after idle $src
}

proc syntaxhighlight::highlightOnKey win {
  variable currentlyRunning
  if {$currentlyRunning} then return
  set from [rangeStartIndex $win insert]
  set to [rangeEndIndex $win $from]
  if {$to eq ""} then return
  set currentlyRunning yes
  highlightWinFromTo $win $from $to
  tagTrailingBackslash $win $from $to
  if {[$win compare insert-1chars < $from]} then {
    $win mark set insert insert-1chars
    highlightOnKey $win
    $win mark set insert insert+1chars
  } elseif {[$win compare insert+1chars > $to]} then {
    $win mark set insert insert+1chars
    highlightOnKey $win
    $win mark set insert insert-1chars
  }
  set currentlyRunning no
}

proc syntaxhighlight::tagTrailingBackslash {win from to} {
  set index [$win search \\ $from+1chars $to]
  if {$index ne ""} then {
    set str [$win get $index $index+2chars]
    if {$str eq "\\\n"} then {
      $win search -regexp -count num \\s* $index+2chars $to
      set index2 [$win index $index+2chars+${num}chars]
      foreach tag [$win tag names $index] {
        $win tag add trailingBackslash $index $index2
      }
    }
    # continue
    [lindex [info level 0] 0] $win $index $to
  }
}

[proc "" {} {
  set script "::syntaxhighlight::highlightOnKey %W"
  set script [list after idle $script]
  set timer "after cancel {$script}\nafter 1000 {$script}"
  bind SyntaxHighlight <Key> $timer
}]

proc syntaxhighlight::highlight {win {how yes}} {
  variable active

  # bold Font
  if {[lsearch -exact [font names] winFontBold] <0} {
     set winFont [$win cget -font ]
     font create winFontBold {*}[font configure  $winFont]
     font configure winFontBold -weight bold
   }
  set bindTagIndex [lsearch [bindtags $win] SyntaxHighlight]
  if {[winfo class $win] eq "Scrolledtext"} then {
    highlight [$win element text] $how
  } elseif {[string is false -strict $how]} then {
    if {$bindTagIndex >= 0} then {
      bindtags $win [lreplace [bindtags $win] $bindTagIndex $bindTagIndex]
    }
    foreach tag [$win tag names] {
      if {$tag ne "sel"} then {
        $win tag remove $tag 1.0 end
      }
      set active($win) 0
    }
  } elseif {[string is true -strict $how]} then {
    if {$bindTagIndex < 0} then {
      bindtags $win [concat SyntaxHighlight [bindtags $win]]
    }
    $win tag configure command -foreground #000077 \
      -font  winFontBold
    $win tag configure comment -foreground \#aa0000 \
      -font winFontBold
    $win tag configure quotes -foreground "" -background \#ffffaa
    $win tag configure brace -foreground \#007700
    $win tag configure expand -foreground "" -underline yes
    $win tag configure string -foreground \#770000
    $win tag configure bracket -foreground red
    $win tag configure event -foreground blue
    $win tag configure sel -foreground black
    $win tag configure trailingBackslash\
      -foreground [$win cget -foreground]\
      -background [$win cget -background]\
      -font [$win cget -font]
    $win tag raise trailingBackslash
    $win tag raise sel
    set active($win) 1
    [namespace current]::highlightOnIdle $win
    set active($win)
  } else {
    # toggle
    if {![info exists active($win)] || !$active($win)} then {
      highlight $win off
    } else {
      highlight $win on
    }
  }
}
