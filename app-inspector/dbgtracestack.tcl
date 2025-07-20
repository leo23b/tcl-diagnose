## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "dbgtracestack.tcl"
 #  Description:
 #  enthält Utilities für die Trace- und Debugfunktion
 #
 # ###################################################################

#--------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc DebugInit {} {
#    # init. Debugfunktion
#    # gerufen von connect
#    # holt dbg-Infos vom Ziel
#    #--------------------------------------------------------------------
#    global gd wv
#    _proctrace
#    
#    if {![SendSyn --  info exists ::utils::dbg::len]} {
#       set gd(status) "DBG-Schnittstelle nicht vorhanden"
#       $wv(w,tb,dbg) configure -state disabled
#       return
#    }
#    
#    set prg [SendSyn -- set ::utils::dbg::prg]
#    set wv(v,en,dbgprg) $prg
#    set gd(dbgPrgK) $prg
#    
#    set pkg [SendSyn -- set ::utils::dbg::packages]
#    set wv(v,en,dbgpkg) $pkg
#    set gd(dbgPkgK) $pkg
#    
#    set levels [SendSyn -- set ::utils::dbg::levels]
#    set wv(v,en,dbglev) $levels
#    set gd(dbgLevelsK) $levels
#    
#    set len [SendSyn -- set ::utils::dbg::len]
#    set wv(v,en,dbglen) $len
#    set gd(dbgLenK) $len
#    
#    $wv(w,tb,dbg) configure -state normal
# }
# 
###-----------------------------------------------------------------------------
#--------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc DebugReInit {} {
#    # init. Debugfunktion
#    # gerufen  reconnect
#    # holt dbg-Infos vom Ziel
#    #--------------------------------------------------------------------
#    global gd wv
#    _proctrace
#    
#    if {![SendSyn --  info exists ::utils::dbg::len]} {
#       set gd(status) "DBG-Schnittstelle nicht vorhanden"
#       return
#    }
#    
#    set prg [SendSyn -- set ::utils::dbg::prg $gd(dbgPrgK)]
#    
#    set pkg [SendSyn -- set ::utils::dbg::packages $gd(dbgPkgK)]
#    
#    set levels [SendSyn -- set ::utils::dbg::levels $gd(dbgLevelsK)]
#    
#    set len [SendSyn -- set ::utils::dbg::len  $gd(dbgLenK)]
#    
#    $wv(w,tb,dbg) configure -state normal
# }
# #--------------------------------------------------------------------
###-----------------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc DebugView {} {
#    # TL Debug anzeigen
#    #--------------------------------------------------------------------
#    global gd wv
#    _proctrace
#    
#    # Dialog kreiern
#    set p $wv(w,top)
#    catch {destroy $p.dbg}
#    set dlg [Dialog $p.dbg  \
#       -modal none          \
#       -parent $p           \
#       -title "Debug-View"  \
#       -separator true      \
#       -transient 0         \
#       -cancel  0           \
#       ]
#    set f [$dlg getframe]
#    
#    set fo [frame $f.o -relief flat -borderwidth 1 -relief ridge]
#    pack $fo -padx 3 -pady 3 -fill both -expand 0 -side top
#    
#    set hlp [::utils::gui::mkButton wv $fo bt,bthlp \
#       -image [::utils::gui::ic 16 help-hint] \
#       -command [list DebugHelp]]
#    
#    set prg [::utils::gui::mkLabelEntry wv $fo en,dbgprg \
#       -label Programm \
#       -command [list DebugSetPrg]]
#    
#    set lev [::utils::gui::mkLabelEntry wv $fo en,dbglev \
#       -label Levels -width 10 \
#       -command [list DebugSetLevels]]
#    
#    set pkg [::utils::gui::mkLabelEntry wv $fo en,dbgpkg \
#       -label Packages \
#       -command [list DebugSetPackages]]
#    
#    set len [::utils::gui::mkLabelEntry wv $fo en,dbglen \
#       -label Länge -width 5 \
#       -command [list DebugSetLen]]
#    pack $hlp $prg $lev $pkg $len \
#       -padx 3 -pady 3 -side left
#    
#    set txt [::utils::gui::mkText wv $f txt,dbg -wrap none]
#    bind $txt <Control-f> [list ::utils::suchen::findDialog %W %W]
#    
#    # Tasten
#    $dlg add -image [::utils::gui::ic 22 process-stop] -helptext {Dialog abbrechen} \
#       -command [list $dlg withdraw]
#    $dlg add -text "Löschen" -helptext {Dbg-Datei löschen} \
#       -command [list DebugLoeschen]
#    $dlg add -text "Lesen" -helptext {DBG-Info anzeigen} \
#       -command [list DebugLesen]
#    
#    $dlg draw
#    # bind $len <Return> {DebugSetLevels}
# }
# 
###-----------------------------------------------------------------------------
#--------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc DebugLesen {} {
#    # Debugdatei im TL anzeigen
#    #--------------------------------------------------------------------
#    global wv gd
#    _proctrace
#    #::Connect::testTarget $gd(target)
#    if {$gd(target) eq ""} {return}
#    
#    # Debugdatei lesen
#    set prg $wv(v,en,dbgprg)
#    set dbgFile [file join ~ dbg_$prg.tmp]
#    set ok [SendSyn -- file readable $dbgFile]
#    if {!$ok} {
#       #::utils::gui::msg error Dateifehler
#       set gd(status) "Debugdatei nicht vorhanden"
#       return
#    }
#    set FIN [SendSyn -- open $dbgFile r]
#    _leer $FIN {return}
#    
#    # Debugdatei anzeigen
#    $wv(w,txt,dbg) insert end "\n-----------------------------\n"
#    set inh 1
#    while {$inh != {}} {
#       set inh [SendSyn -- read $FIN 2000]
#       $wv(w,txt,dbg) insert end $inh
#    }
#    SendSyn -- close $FIN
#    $wv(w,txt,dbg) see end
# }
# proc DebugLoeschen {} {
###-----------------------------------------------------------------------------
###-----------------------------------------------------------------------------
#    # Debugdatei durch den Testling löschen
#    #--------------------------------------------------------------------
#    global wv gd
#    _proctrace
#    #::Connect::testTarget $gd(target)
#    if {$gd(target) eq ""} {return}
#    
#    set prg $wv(v,en,dbgprg)
#    set dbgFile [file join ~ dbg_$prg.tmp]
#    SendSyn --  file delete -force $dbgFile
#    $wv(w,txt,dbg) delete 0.0 end
# }
# #--------------------------------------------------------------------
###-----------------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc DebugHelp {} {
#    # Debuginfo für packages anzeigen
#    #--------------------------------------------------------------------
#    global wv gd
#    _proctrace
#    
#    set prg  $wv(v,en,dbgprg)
#    set pkgs $wv(v,en,dbgpkg)
#    set procs {debuginfo}
#    foreach pkg $pkgs {
#       if {$pkg == $prg} {continue}
#       lappend procs ${pkg}::debuginfo
#    }
#    set info {}
#    foreach proc $procs {
#       if {[catch {SendSyn --  "info" body $proc} msg]} {
#          ::utils::gui::msg "info" \
#             DebugInfo "keine Debug-Info vorhanden" 
#          return
#       }
#       append info "$proc\n"
#       set zeilen [split $msg "\n"]
#       set erg {}
#       foreach z $zeilen {
#          if {[regexp -- {^\s*#\s*(\d+)\s*:(.+)\s*$} $z dum nr txt]} {
#             _leer $txt continue
#             append info " $nr:\t$txt\n"
#          }
#       }
#       append info "---------------------\n"
#    }
#    _leer $info return
#    ::widgets::tw $wv(w,top).dbghlp  \
#       -widget text \
#       -titel Debug-Info \
#       -buttonbox 0      \
#       -text $info
# }
# #--------------------------------------------------------------------
###-----------------------------------------------------------------------------
proc DebugSetLen {} {
   # setzt ::utils::debug:len im Zielprogramm
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   #::Connect::testTarget $gd(target)
   if {$gd(target) eq ""} {return}
   
   set len $wv(v,en,dbglen)
   set msg [SendSyn -- set ::utils::dbg::len $len]
   set gd(dbgLenK) $len
   set gd(status) "Debug Länge $len gesetzt"
}
#--------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc DebugSetLevels {} {
#    # setzt ::utils::debug:levels im Zielprogramm
#    #--------------------------------------------------------------------
#    global wv gd
#    _proctrace
#    #::Connect::testTarget $gd(target)
#    if {$gd(target) eq ""} {return}
#    
#    set levels [list $wv(v,en,dbglev)]
#    set msg [SendSyn -- set ::utils::dbg::levels $levels]
#    set gd(dbgLevelsK) $levels
#    set gd(status) "Debug Levels $levels gesetzt"
# }
# #--------------------------------------------------------------------
# proc DebugSetPackages {} {
#    # setzt ::utils::debug:levels im Zielprogramm
#    #--------------------------------------------------------------------
#    global wv gd
#    _proctrace
#    #::Connect::testTarget $gd(target)
#    if {$gd(target) eq ""} {return}
#    
#    set pkgs [list $wv(v,en,dbgpkg)]
#    set msg [SendSyn -- set ::utils::dbg::packages $pkgs]
#    set gd(dbgPkgK) $pkgs
#    set gd(status) "Debug Packages $pkgs gesetzt"
# }
# #--------------------------------------------------------------------
###-----------------------------------------------------------------------------
proc TraceDialog {} {
   # Dialog für Variable anzeigen
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   # Dialog kreiern
   set p $wv(w,top)
   catch {destroy $p.tracestart}
   set dlg [Dialog $p.tracestart \
      -modal none          \
      -parent $p           \
      -title "Trace a Global"  \
      -separator true      \
      -cancel  0           \
      ]
   set f [$dlg getframe]
   set en [::utils::gui::mkLabelEntry wv $f en,trace \
      -label "Variable, Array oder Arr-Element: " \
      -command [list TraceItem]]
   pack $en -padx 3 -pady 3 -fill x -expand 1
   
   # Checkbuttons write read ?
   set fchk [frame $f.chk -relief ridge -borderwidth 2]
   pack $fchk -padx 3 -pady 3 -fill both -expand 1 -side bottom
   
   set chkwrite [checkbutton $fchk.write -variable gd(traceWrite) \
      -text write -anchor w -offvalue "" -onvalue write]
   pack $chkwrite -side left -padx 1 -pady 3
   set chkunset [checkbutton $fchk.unset -variable gd(traceUnset) \
      -text unset -anchor w -offvalue "" -onvalue unset]
   pack $chkunset -side left -padx 1 -pady 3
   set chkread [checkbutton $fchk.read -variable gd(traceRead) \
      -text read -anchor w -offvalue "" -onvalue read]
   pack $chkread -side left -padx 1 -pady 3
   set chkarray [checkbutton $fchk.array -variable gd(traceArray) \
      -text array -anchor w -offvalue "" -onvalue array]
   pack $chkarray -side left -padx 1 -pady 3
   
   # Selektion in global Register vorbelegen ?
   set wLb $wv(w,lb,Global)
   set sel [$wLb selection get]
   if {$sel ne ""} {
      set item [$wLb itemcget $sel -text]
      set wv(v,en,trace) $item
   }
   
   # Tasten
   $dlg add -image [::utils::gui::ic 22 process-stop] -helptext {Dialog abbrechen} \
      -command [list $dlg withdraw]
   $dlg add -text "Trace Item" -helptext {Variable angeben} \
      -command [list TraceItem]
   
   set wv(w,tracedlg) $dlg
   $dlg draw
}

#-----------------------------------------------------------------------
proc TraceItem {} {
   # eingegebene Variable tracen
   #--------------------------------------------------------------------
   global wv gd
   
   set item $wv(v,en,trace)
   _leer $item {return}
   set ops "$gd(traceWrite) $gd(traceRead) $gd(traceUnset) $gd(traceArray) "
   if {[string trim $ops] eq ""} {
      return
   }
   
   TraceStart $item variable $ops
   $wv(w,tracedlg) withdraw
}

#--------------------------------------------------------------------
proc TraceStart {item typ ops} {
   # Trace starten , TraceFenster anzeigen
   # item : Name einer Variable oder Proc
   # typ  : variable | execution
   # opts : bei Proc :  enter|leave
   # opts : bei Var  : {write unset}
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
     
   _leer $gd(target) return
   _leer $item return
   
   # Trace-Verwaltung
   #
   lappend gd(traces) [list $item $typ]
   
   # beim TraceCB-Aufruf fehlt ggf. ns der Variable
   # deshalb bei traceCB mitgeben
   # 
   set namespace1 ""
   # Variable oder execution
   if {$typ eq "variable"} {
      set fkt var
      set namespace1 [namespace qualifiers $item]
      # puts "namespace1 :$namespace1"
   } elseif {$typ eq "execution"} {
      set fkt cmd
   } else {
      return -code error "F-TraceStart typ <$typ> ??"
   }

   # Trace-Toplevel anzeigen
   #
   set p $wv(w,top)
   incr gd(traceNr)
   set traceview [toplevel $p.trace$gd(traceNr)]
   wm title  $traceview "Trace $gd(target) $typ $ops <$item >"
   set wtxt [::utils::gui::mkText wv $traceview "" -wrap none]
   set fb [frame $traceview.fb -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $fb -padx 3 -pady 3 -fill x -expand 1 -side bottom

   # Tasten save end
   #
   set btsave [::utils::gui::mkButton wv $fb "" \
      -text "Trace speichern"]
   set btend [::utils::gui::mkButton wv $fb "" \
      -text "Trace Ende"]
   pack $btsave $btend -padx 3 -pady 3 -fill x -expand 1 -side left

   set traceCB [list ::inspector_testling::traceCB $fkt $wtxt $namespace1]
   SendSyn -- trace add $typ $item [list $ops] [ list $traceCB]

   $btsave configure -command [list TraceSave $wtxt $item ]
   $btend  configure -command \
      [list TraceEnde $traceview $item $typ $ops [ list $traceCB]]
    
   $wtxt insert end "[::utils::dz::heute]\n"
   
   
}


#--------------------------------------------------------------------
proc TraceSave { wText item} {
   # TraceInhalt in Datei speichern
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   # :: umbiegen
   regsub -all -- {::} $item {__} item
   
   set zeit [clock format [clock seconds] -format "%Y_%m_%d-%X"]
   set pf [::utils::file::getsavefile            \
      -title "Trace $item speichern"     \
      -initialdir ~                      \
      -initialfile "${item}-$zeit.trace" \
      -parent $wText
   ]
   
   if {$pf == {}} {return}
   
   ::utils::file::writefile $pf [$wText get 1.0 end]
   set gd(status)  "Trace saved to \"$pf\"."
}

#--------------------------------------------------------------------
proc TraceEnde { top item typ ops cmd {w {}} } {
   # Trace beenden Fenster schliessen
   # typ: Variable|Proc
   # item : Name von Variable oder Proc
   # ops  : {read unset} | enter |leave
   #--------------------------------------------------------------------
   global gd wv 
   #_proctrace
   
   if {$w !={}} {
      if {[winfo class $w]!={Toplevel}} return
   }
   switch -exact -- $typ  {
      variable {
         SendSyn -- trace remove variable $item [list $ops] $cmd
      }
      execution {
        # puts "trace remove execution $item [list $ops] $cmd"
         SendSyn -- trace remove execution $item [list $ops] $cmd
      }
      default {
         return -code error "F-Switch TraceEnde typ <$typ> ??"
      }
   } ; # end switch
   
   destroy $top
}

#-----------------------------------------------------------------------
proc TraceClean {} {
   # alle Trace aufräumen am Ende von inspector
   #-----------------------------------------------------------------------
   #_proctrace
   global gd
   
   if {$gd(target) eq ""} {
      return
   }
   
   foreach tr $gd(traces) {
      lassign $tr name typ
      set info [SendSyn -- trace info $typ $name]
      if {$info ne ""} {
         foreach trAuftr $info {
            lassign $trAuftr ops cmd
            SendSyn -- trace remove $typ $name [list $ops] [list $cmd]
         }
      }
   }
   return
}


#------------------------------------------------------------------
proc AnalyzeTrace {widget} {
   # Anzeige TraceStack zur Anwahl der betroffenen Prozeduren
   #---------------------------------------------------------------
   global gd wv
   #_proctrace
   
   _leer $widget     return
   _leer $gd(target) return
   
   
   # Toplevel vom Fehlerstack
   set tl [SendSyn -- winfo toplevel $widget]
   
   # zwei Varianten zur Stackausgabe
   # 
   # tk__messagebox  : errText in Label tl.msg
   if {[string match {*tk__messagebox} $tl]} {
      if {[catch {SendSyn -- $tl.msg cget -text} errText]} {
         return
      }
   } else {
      # .bgerrorDialog.top.info.text
      if {[catch {SendSyn -- $tl.top.info.text get 1.0 end } errText]} {
         return
      }
   }
   
   # Stack zerlegen
   set matr [Bt2levels $errText 1 1]
   #::utils::printliste matr Matrix
   
   StackTop $errText $matr
}

#---------------------------------------------------------------
proc StackTop {str traceMatr} {
   # Anzeige TraceStack zur Anzeige der betroffenen Prozeduren
   #---------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set p $wv(w,top)
   catch {destroy $p.stacktop}
   
   set topview [toplevel $p.stacktop]
   wm group $p $topview
   wm title $topview Stack
   wm geometry $topview 630x370
   
   set erg [::utils::gui::mkPanedWindow wv $topview "" -wts {1,2} -richt -]
   lassign $erg pw fo fu
   pack $pw -padx 0 -pady 0 -fill both -expand 1
   
   set tbl [::utils::gui::mkTable wv $fo "" -tdx $gd(tdStack)]
   pack $tbl -padx 0 -pady 0 -fill both -expand 1
   bind [$tbl bodypath] <ButtonRelease-1> [list SelectStackProc %W %x %y]
   
   set txt [::utils::gui::mkText  wv $fu "" -wrap none]
   $txt insert end $str
   
   $txt tag add zeile1 1.0 1.end
   $txt tag configure zeile1 -background red
   
   # Tabelle füllen
   set nr -1
   array unset ar
   foreach liste $traceMatr {
      incr nr
      foreach {na wert} $liste {
         #puts "$nr : name:$na wert:$wert"
         if {$na eq "line" && $wert ne ""} {
            incr wert
         }
         set ar($nr,$na) $wert
      }
   }
   #parray ar
   set max $nr
   set nr 0
   for {set i 0} {$i <=$max } {incr i} {
      set z $i
      foreach key {cmd ns proc line name type} {
         if {[info exists ar($i,$key)]} {
            set  wert $ar($i,$key)
         } else {
            set wert ""
         }
         set z [concat $z [list $wert]]
      }
      $tbl insert end $z
   }
   
}

#---------------------------------------------------------------
proc SelectStackProc {tbl_body x y} {
   # in der Tabelle TraceStack wurde eine Zeile selektiert
   #---------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set tbl [winfo parent $tbl_body]
   lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
   if {$zeile == -1} {return}
   
   set xp [winfo pointerx .]
   set yp [winfo pointery .]
   
   # kein Text ?
   set inh [$tbl get $zeile]
   _leer $inh {return}
   lassign $inh lev ruf ns procc line name typ
   
   if {$name == {}} {return}
   UpdateListe Proc
   if {$name ni $gd(Proc,inhalt)} {
      set name "::$name"
      if {$name ni $gd(Proc,inhalt)} {
         return
      }
   }
   incr line -1
   SelectListe -liste Proc -item  $name -zeile $line -top top
}
#----------------------------------------------------------------
# Bt2levels errorInfo
# zerlegt den Stacktrace in eine Liste {procaufruf namespace Datei Zeile}
#---------------------------------------------------------------
proc Bt2levels { str {retlst 0} {localbt 1}} {
   # Unravel the Tcl error traceback into a list of stack level messages.
   # Principly this means looking up the file name and real line number
   # for procs and blocks of code.
   set rc {}
   set n -1
   set lst [split $str \n]
   set emsg {}
   set clst {}
   set alst {}
   
   # Create list of stack-level units.
   while {[incr n]<[llength $lst]} {
      set i [lindex $lst $n]
      # Levels are dumped in the triplets: prefix command descr
      # Breakup backtrace into it's constituent units.
      switch -- $i {
         {    while executing} {
            set emsg [join $clst \n]
            set clst {}
         }
         {    invoked from within} {
            lappend alst $clst
            set clst {}
         }
         {    while compiling} {
            lappend alst $clst
            set clst {}
         }
         default {
            lappend clst $i
         }
      }
   }
   if {[llength $clst]} {
      lappend alst $clst
   }
   
   # Iterate over the stack-levels list to extract proc, file and line numbers.
   foreach clst $alst {
      set tc [lindex $clst end]
      set eidx [expr {[llength $clst]-1}]
      
      # Identify the description eg. "  (procedure .. line ..)"
      while {[string index $tc end] != ")"
         && [string range $tc 0 4] != "    ("
         && $eidx>=0} {
         set ntc [lindex $clst $eidx]
         append ntc \n $tc
         set tc $ntc
         incr eidx -1
      }
      set cmd [string trim [join [lrange $clst 0 [incr eidx -1]] \n] \"]
      # Extract trimmed first line of cmd trying to avoid list uglification.
      set scmd [lindex [split $cmd \n] 0]
      # TODO: look for \ at eol.
      while {![info complete $scmd] && [string length $scmd]} {
         set scmd [string range $scmd 0 end-1]
      }
      set lc [list "cmd" $cmd]
      if {$cmd != $scmd} { lappend lc "scmd" $scmd }
      set line [string trim $tc]
      set ln ""
      
      # Parse specific descriptions:
      #puts "\nZ:$line"
      # eg. (procedure "tod::New" line 88)
      if {[regexp {\(procedure \"([^\"]*)\" line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type proc "name" $name "line" [incr ln -1] proc $name
         
      } elseif {[regexp {\(file \"([^\"]*)\" line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type file file $name "line" [incr ln -1]
         
         # eg. (in namespace eval "::pdqi::edit" script line 1)
      } elseif {[regexp {\(in namespace eval \"([^\"]*)\" script line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type ns "name" $name ns $name "line" [incr ln -1]
         
         # eg. (in namespace inscope "::pdqi::edit" script line 1)
      } elseif {[regexp {\(in namespace inscope \"([^\"]*)\" script line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type nsinscope "name" $name "line" [incr ln -1]
         
         # eg. ("eval" body line 1)  or  "uplevel" or "while" or "foreach" ...
      } elseif {[regexp {\(\"([^\"]*)\" body line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type eval "name" $name "line" [incr ln -1]
         if {$name == "uplevel"} { lappend lc proc {} }
         
         # eg. ("if" then script line 1)
      } elseif {[regexp {\(\"([^\"]*)\" then script line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type ifthen "name" $name "line" [incr ln -1]
         
         # eg. (file "apps/edit.tcl" line 7)
      } elseif {[regexp {\(file \"([^\"]*)\" line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type file "name" $name "line" [incr ln -1]
         
         # eg. ("default" arm line 2)
      } elseif {[regexp {\(\"([^\"]*)\" arm line ([0-9]*)\)} $tc {} name ln]} {
         lappend lc type arm "name" $name "line" [incr ln -1]
         
         
         # eg. (compiling %s \"%.*s%s\", line %d)
      } elseif {[regexp {\(compiling ([^\"]*)\"([^\"]*)\", line ([0-9]*)\)} $tc {} descr name ln]} {
         lappend lc type compile "name" $name "line" [incr ln -1] desc $descr
         if {[string first "body of proc" $descr]>=0} {
            lappend lc proc $name
         }
         
         # ALL THE REMAINING CASES DO NOT CONTAIN LINE NUMBER INFO ...
      } elseif {$line == "(command bound to event)"} {
         lappend lc type event
         
      } elseif {$line == "invoked from within"} {
         lappend lc type none
         
         # eg. (parsing index for array \"%.*s\")
      } elseif {[regexp {\(parsing index for array \"([^\"]*)\"\)} $tc {} name]} {
         lappend lc type arrayname "name" $name
         
      } elseif {$line == "(\"after\" script)"} {
         # Note this could be an TOD call eg. "::pdqi::edit::_obj_0 Bar"
         lappend lc type after
         
      } elseif {$line == "(reading value of variable to increment)"} {
         continue
      } elseif {$line == "\(\"for\" initial command)"} {
         continue
      } elseif {$line == "\(\"for\" loop-end command"} {
         continue
      } elseif {$line == "\(\"for\" test expresion"} {
         continue
      } elseif {$line == "\(\"if\" test expresion"} {
         continue
      } elseif {[string match "\(remainder of *" $line]} {
         continue
         
      } else {
         # NOTE THERE MAY WELL BE MORE IN TCL SOURCE???
         #.Error "UNKNOWN($n): $tc"
         continue
      }
      lappend rc $lc
      #puts "lc:$lc"
   }
   
   # Reverse-traverse the stack levels resolving ns/file/proc/line numbers.
   set lrc {}
   set trc {}
   array set a {file {} proc {} line {} ns :: cmd {} aline 0}
   array unset q
   set q(ns) ::
   set lproc {}
   set lline 0
   set lfile {}
   for {set i [expr {[llength $rc]-1}]} { $i>=0} {incr i -1} {
      #puts "rc [lindex $rc $i]"
      set gotline 0
      array unset r
      array set r [lindex $rc $i]
      array set q [lindex $rc $i]
      if {!$localbt} {
         # If the file is not in current interp, then need to lookup proc,
         # using string search of file.
         if {[info exists r(line)]} {
            set gotline 1
            if {![info exists r(file)]} {
               set r(file) $a(file)
            }
            if {$q(type) == "proc"} {
               set ii fdata:$r(file)
               set data {}
               if {![info exists a($ii)]} {
                  if {[file exists $q(file)]} {
                     set data [set a($ii) [read [set fp [open $q(file)]]]]
                     close $fp
                  }
               } else {
                  ##nagelfar ignore
                  set data a($ii)
               }
               #set pline [::Mod stat procline $q(proc) $data $q(ns)]
               set pline -1
               if {$pline<0} {
                  set gotline 0
                  set a(aline) 0
               } else {
                  set a(aline) [expr {$pline+$q(line)}]
               }
            } elseif {$lfile == $r(file) || $r(file) == {}} {
               set a(aline) [expr {$a(aline)+$q(line)}]
            } else {
               set a(aline) $q(line)
            }
            set lfile $r(file)
            set q(aline) $a(aline)
         }
      }
      
      switch -- $q(type) {
         
         proc {
            if {![info exists q(ns)]} {
               set q(ns) $a(ns)
            }
            set a(proc) $q(proc)
            if {0} {
               if {[set nproc [Mod stat procname $q(proc) $q(ns)]] != {}} {
                  set q(proc) $nproc
                  set q(ns) [namespace qualifiers $nproc]
               } elseif {$q(ns) != {}} {
                  set ncmd [namespace eval $q(ns) [list ::namespace which $q(proc)]]
                  if {$ncmd != {} && [set nns [namespace qualifiers $ncmd]] != {}} {
                     set q(ns) $nns
                  }
               }
            }
            if {$q(proc) == {}} continue
            if {!$gotline} {
               # set file [Mod stat procfile $q(proc) $q(ns) 0]
               set file {}
               if {$file != {}} {
                  set q(file) $file
               }
            }
            set a(ns) $q(ns)
         }
      }
      if {[info exists q(proc)]} {
         if {$lproc != {}  && $lproc == $q(proc) && $q(line) != {}} {
            set q(line) [expr {$q(line)+$lline}]
         } else {
            set lline 0
         }
         set lline $q(line)
         set lproc $q(proc)
      } else {
         set lproc {}
         set lline 0
      }
      set q(aline) $a(aline)
      
      set lrc [concat [list [array get q]] $lrc]
   }
   if {$retlst} {
      return $lrc
   }
   
   if 1 {
      set xrc {}
      set n -1
      set q(file) {}
      #  parray ::Mod::procs
      foreach i $lrc {
         array unset q
         array set q {file {} ns {} line {}}
         array set q $i
         lappend i "file" $q(file)
         append xrc "#[incr n]: '$q(cmd)' in ns '$q(ns)' in file '$q(file)':$q(line)\n"
      }
      append xrc \n $str
      return $xrc
   }
   return $trc
}