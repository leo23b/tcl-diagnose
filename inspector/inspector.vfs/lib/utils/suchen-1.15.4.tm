## -*-Tcl-*-
# ###################################################################
#  Dialog zur Textsuche
#
#  FILE: "utils_suchen.tcl"
#                                    created: 2004-03-12 05:21:04
#                                last update: 2005-05-11 07:39:09
#
#  Description:
#  Prozeduren zum Drucken in Spectrum
#  - druckDialog
#
#  History
package provide utils::suchen 1.15.4
#
#  modified   by   rev  reason
#  ---------- ---  ---- -----------
#  02.03.24   mlrd 1.15 cbFinden|tbl:see result+Länge, findAlle
#  29.06.19   mlrd 1.14 Doku
#  19.04.19   mlrd 1.13 cbFindenLB ind-> index
#  31.12.15   mlrd 1.12 iconsDirList
#  16.10.15   mlrd 1.11 Doku mit ND
#  18.09.15   mlrd 1.10 suchen in einer LB
#  01.08.15   mlrd 1.9  entry mit exportselection 0
#  31.07.15   mlrd 1.8  Suchmuster mit paste und clear Taste
#  15.01.15   mlrd 1.7  dialog immer löschen, dlgWindow left
#  12.12.14   mlrd 1.6  select übernehmen, findfail in combobox
#  19.03.14   mlrd 1.5  Dialog Suchen mit Combobox
#  18.02.14   mlrd 1.4  Findergebnis besser sichtbar
#  14.02.14   mlrd 1.3  F FindEntry
#  11.04.13   mlrd 1.2  Design wie Drucken
#  15.12.12   mlrd 1.1  auch mit TABULAR
#  22.06.06    1.3
#  - Dialogfenster immer kreiern, wg XP
#  10.05.05    1.2
#  - gefundener Text mit dickem Rand, dass unter Selektion sichtbar
# ###################################################################


namespace eval utils::suchen {
   #---------- Variable ------------------------------------------------
   variable test           0
   variable log            0
   #variable iconsDir       $::utils_dir_icons
   variable lastResult     {}
   variable findDirection
   variable findType
   variable oldPat ""
   variable results ""
   variable resListe [list] ;# Ergebnisliste tbl suchen
   variable packagename    {utils::suchen}
   
   #--------- interne Funktionen ------------------------------------------
   ###-----------------------------------------------------------------------------
   #    proc debuginfo {} {
   #       set str {
   #          # ---------------Debug -----------------
   #          # 1 : Trace proc
   #          # 2 :
   #          # 3 :
   #          # 4 : Trace Result
   #          # 5 : interner Ablauf
   #          
   #          # 10:
   #          # 15:
   #          #-------------------------------------
   #       }
   #       puts $str
   #       exit
   #    }
   #    #--------------------------------------------------------------------
   #    proc _dbg {num titel {script {}} } {
   #       # erzeugt eine Debug-Ausgabe
   #       #--------------------------------------------------------------------
   #       variable packagename
   #       ::utils::dbg::debug $num $packagename $titel $script
   #    }
   #    #--------------------------------------------------------------------
   #    proc #_proctrace {} {
   #       #--------------------------------------------------------------------
   #       set infoLev [info level -1]
   #       _dbg 1 Proctrace {set infoLev}
   #    }
   #    #--------------------------------------------------------------------
   #    proc _resulttrace {msg} {
   #       #--------------------------------------------------------------------
   #       variable packagename
   #       set infolevel [info level -1]
   #       ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
   #    }
   #    
   #    #--------------------------------------------------------------------
   ###-----------------------------------------------------------------------------
   #        Hauptprozeduren
   #--------------------------------------------------------------------
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: findDialog
   #
   # *::utils::suchen::findDialog p inp*
   #
   #  zeigt ein Dialog-Fenster zum Suchen
   #
   # Parameter:
   #     p: Parentwidget
   #     inp: Es kann wahlweise in einem Text- Tablelist-
   #          Tabular- oder ListBoxwidget gesucht werden.
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::suchen::findDialog { p inp } {
      #_proctrace
      variable findDirection
      variable findType
      variable entryW
      variable comboboxW
      variable findIgnoreCase
      variable lastResult
      variable findString
      variable findStringListe
      variable findAlle
      variable wDlg
      
      if {![info exists findStringListe]} {
         set findStringListe ""
      }
      
      catch {destroy $p.fndDlg}
      
      # Dialog kreiern
      set wDlg [Dialog $p.fndDlg    \
         -modal none                \
         -parent $p                 \
         -title "Suchen"            \
         -separator true            \
         -cancel 0                  \
         -default 1                 \
         -anchor w                  \
         -image  [::utils::gui::ic 32 edit-find] \
         -place left \
         ]
      set f [$wDlg getframe]
      
      # Meldezeilen
      set mld [Label $f.mld -relief sunken -anchor w]
      pack $mld -side bottom -fill x -padx 3 -pady 4
      
      # Rahmen um alle Optionen
      set fop [frame $f.fop -bd 1 -relief sunken]
      pack $fop -padx 3 -pady 3 -fill both -expand yes -side top
      
      set fpat [frame $fop.fpat -relief ridge -borderwidth 1]
      pack $fpat -padx 3 -pady 3 -fill x -expand 1 -side top
      
      set comboboxW [ComboBox $fpat.pat     \
         -editable 1      \
         -values $findStringListe       \
         -textvariable ::utils::suchen::findString \
         -helptext { Textmuster zum Suchen }]
      
      $comboboxW.e configure -exportselection 0
      
      set btPaste [::utils::gui::mkButton wv $fpat {}  \
         -command [list ::utils::suchen::paste $comboboxW.e]    \
         -helptext "Selection einfügen"            \
         -image [::utils::gui::ic 16 edit-paste-4] \
         ]
      set btClr [::utils::gui::mkButton wv $fpat {}       \
         -command [list ::utils::suchen::clearEntry $comboboxW.e]  \
         -helptext "Eingabefeld löschen"              \
         -image [::utils::gui::ic 16 edit-clear-locationbar-rtl] \
         ]
      pack $btPaste    -padx 2 -pady 3  -side left
      pack $comboboxW  -padx 2 -pady 3 -fill x -expand yes -side left
      pack $btClr      -padx 2 -pady 3  -side left
      
      set sep1 [Separator $f.s1]
      pack $sep1 -fill x -padx 3 -pady 3 -in $fop -side top
      
      if {![info exists ::utils::suchen::findIgnoreCase]} {
         set ::utils::suchen::findIgnoreCase 1
      }
      
      frame $f.case -padx 3 -pady 3
      pack $f.case  -in $fop -padx 3 -pady 3 -fill both -side bottom
      
      
      checkbutton $f.searchCase\
         -text "  gross/klein egal"\
         -offvalue 0\
         -onvalue 1\
         -indicatoron true\
         -anchor w \
         -variable ::utils::suchen::findIgnoreCase
      pack $f.searchCase -in $f.case -padx 3 -pady 3 -fill none -side left -anchor w
      
      checkbutton $f.alle\
         -text "  alle Fundstellen"\
         -offvalue 0\
         -onvalue  1\
         -indicatoron true\
         -anchor w \
         -variable ::utils::suchen::findAlle
      pack $f.alle -in $f.case -padx 10 -pady 3 -fill none -side left -anchor w
      
      frame $f.richt -padx 3 -pady 3
      pack $f.richt -in $fop -padx 3 -pady 3 -fill both -side bottom
      
      label $f.directionLabel\
         -text "Richtung:"\
         -anchor e -width 8
      if {![info exists ::utils::suchen::findDirection]} {
         set ::utils::suchen::findDirection {-forward}
      }
      radiobutton $f.directionForward\
         -indicatoron true\
         -text "Vorwaerts"\
         -value "-forward"\
         -variable ::utils::suchen::findDirection
      radiobutton $f.directionBackward\
         -text "Rueckwaerts"\
         -value "-backward"\
         -indicatoron true\
         -variable ::utils::suchen::findDirection
      pack $f.directionLabel    -in $f.richt -padx 3 -pady 3 -fill both -side left
      pack $f.directionForward  -in $f.richt -padx 3 -pady 3 -fill both -side left
      pack $f.directionBackward -in $f.richt -padx 3 -pady 3 -fill both -side left
      
      frame $f.art -padx 3 -pady 3
      pack $f.art -in $fop -padx 3 -pady 3 -fill both -side bottom
      
      label $f.searchLabel\
         -text "Such-Art:"\
         -anchor e -width 8
      if {![info exists ::utils::suchen::findType]} {
         set ::utils::suchen::findType {-exact}
      }
      
      radiobutton $f.searchExact\
         -indicatoron true\
         -text "Exakt"\
         -value "-exact"\
         -variable ::utils::suchen::findType
      radiobutton $f.searchGlob\
         -indicatoron true\
         -text "Glob"\
         -value "-glob"\
         -variable ::utils::suchen::findType
      radiobutton $f.searchRegexp\
         -text "Regexp"\
         -value "-regexp"\
         -indicatoron true\
         -variable ::utils::suchen::findType
      
      pack $f.searchLabel  -in $f.art -padx 3 -pady 3 -fill both -side left
      pack $f.searchExact  -in $f.art -padx 3 -pady 3 -fill both -side left
      pack $f.searchGlob   -in $f.art -padx 3 -pady 3 -fill both -side left
      pack $f.searchRegexp -in $f.art -padx 3 -pady 3 -fill both -side left
      
      $wDlg add \
         -image [::utils::gui::ic 22 edit-delete] \
         -helptext {Abbruch} \
         -command [list $wDlg withdraw]
      $wDlg add \
         -image [::utils::gui::ic 22 edit-find] \
         -helptext {suchen} \
         -command [list ::utils::suchen::cbFinden $mld $inp]
      $wDlg itemconfigure 0 -width 32
      $wDlg draw
      set entryW $comboboxW.e
      bind $fpat.pat <Return> "::utils::suchen::cbFinden $mld $inp"
   }
   
   #-----------------------------------------------------------------------
   proc clearEntry { entry } {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      
      $entry delete 0 end
      focus $entry
      #Resulttrace
   }
   
   #-----------------------------------------------------------------------
   proc paste {entry} {
      # kopiert Selection in das Eingabefeld
      #-----------------------------------------------------------------------
      #_proctrace
      
      set selection ""
      catch {set selection [selection get]}
      if {$selection != ""} {
         $entry configure -text $selection
         focus $entry
      }
      
      #Resulttrace
   }
   
   #-----------------------------------------------------------------------
   proc cbFinden {mld inp} {
      # search for the pattern in the find dialog
      # inp : Textwidget|tablelist|tabular
      # mld : Labelwidget für Statusmeldung
      #-----------------------------------------------------------------------
      variable findDirection ;#$::utils::suchen::findDirection
      variable findType      ;#$::utils::suchen::findType
      variable entryW
      variable comboboxW
      variable findIgnoreCase ;#$::utils::suchen::findIgnoreCase
      variable lastIndex
      variable findString     ;#$::utils::suchen::findString
      variable findStringListe
      variable findAlle
      variable oldPat
      variable results
      
      set class [winfo class $inp]
      if {$class == {Text}} {
         set win $inp
      } elseif {$class == {Tabular}} {
         set win $inp.body
      } elseif {$class == {Tablelist}} {
         cbFindenTbl $mld $inp
         return
      } elseif {$class == {Listbox} || $class == {ListBox}} {
         cbFindenLB $inp
         return
      } else {
         return -code error \
            "Class <$class> !! Text|Tabular|Tablelist|Listbox"
      }
      
      # glob umbiegen, da -glob in search fehlt
      if {$findType eq "-glob"} {set findType -exact}
      
      $win tag configure gefunden -font TkHeadingFont  \
         -foreground aquamarine -background black \
         -borderwidth 2 -relief ridge
      
      # neuer String , Index zurücksetzten
      if {$oldPat ne $findString } {
         set lastIndex -1
      }
      
      # immer suchen, wegen Wechsel vorw rückw
      #
      if {$findIgnoreCase} {
         set results [$win search $findDirection $findType\
            -all -nocase -- $findString 1.0]
      } else {
         set results [$win search $findDirection $findType\
            -all -- $findString 1.0]
      }
      set anzResult [llength $results]
      
      # Fundstellen anzeigen, einzeln oder alles
      #
      if {$anzResult > 0} {
         $win tag remove gefunden 1.0 end
         set oldPat $findString
         if {$findAlle} {
            set umfang $results
            $mld configure -text " $anzResult gefunden"
         } else {
            # blättern
            if {$lastIndex == -1} {
               $win tag remove gefunden 1.0 end
            }
            incr lastIndex
            if {$lastIndex >= $anzResult} {
               set lastIndex 0
            }
            set umfang [lindex $results $lastIndex ]
            set findNr [expr {$lastIndex +1 }]
            $mld configure -text "$findNr von $anzResult"
         }
         
         # Schleife über alle oder einzeln
         #
         foreach pos $umfang {
            # if this is a regular expression search, get the whole line and try
            # to figure out exactly what matched; otherwise we know we must
            # have matched the whole string...
            if {$findType == "-regexp"} {
               set line [$win get $pos "$pos lineend"]
               set matchVar {}
               regexp $findString $line matchVar
               set length [string length $matchVar]
            } else {
               set length [string length $findString]
            }
            
            $win mark set insert $pos
            $win tag add gefunden $pos "$pos + ${length}c"
            $win tag raise gefunden
            $win see "$pos + ${length}c"
            
            $entryW configure -background white
            if {[lsearch $findStringListe $findString] <0} {
               lappend findStringListe $findString
               $comboboxW configure -values $findStringListe
            }
         }
         
      } else {
         $entryW configure -background pink
         $mld configure -text " nichts gefunden"
         
         bell
      }
   }
   
   
   #-----------------------------------------------------------------------
   proc cbFindenTbl {mld tbl} {
      # search for the pattern in the find dialog, class tablelist
      # mld  : Labelwidget für Statusmeldungen
      # tbl  : Tabelle in der gesucht wird
      #-----------------------------------------------------------------------
      
      variable findDirection ;#$::utils::suchen::findDirection
      variable findType      ;#$::utils::suchen::findType
      variable entryW
      variable comboboxW
      variable findIgnoreCase ;#$::utils::suchen::findIgnoreCase
      variable lastResult
      variable findString     ;#$::utils::suchen::findString
      variable findStringListe
      variable findAlle
      
      variable results
      variable oldPat
      variable resListe   ;# alle Fundstellen in tbl
      variable bgListe    ;# alte bg-Farbe von den Fundstellen
      variable tbl2       ;# globale Variable für after-Aufruf
      variable wDlg
      set tbl2 $tbl
      set secs 10000   ;# Dauer Grünmarkierung
      
      ::utils::gui::setClock on $wDlg
      
      # Index Fundstelle normieren
      if {$oldPat ne $findString} {
         set lastResult -1
      }
      
      # zuerst alle suchen, danach anzeigen
      #
      set resListe [list]
      set bgListe  [list]
      set liste    [$tbl get 0 end]
      
      $mld configure -text { suchen ...}
      $entryW configure -background white
      
      # tbl liefert Blanks links und rechts der Zelle
      if {$findType eq {-exact}} {
         set findType {-glob}
      }
      
      # sucht in allen Zeilen
      if {$findIgnoreCase} {
         ##nagelfar ignore
         set result [lsearch -nocase $findType -all $liste *$findString*]
      } else {
         ##nagelfar ignore
         set result [lsearch $findType -all $liste *$findString*]
      }
      
      # in allen Spalten suchen
      #
      set resListe {}
      set bgListe  {}
      
      foreach z $result {
         set zeile [lindex $liste $z]
         ##nagelfar ignore
         if {$findIgnoreCase} {
            ##nagelfar ignore
            set spalten [lsearch -nocase $findType -all $zeile *$findString*]
         } else {
            ##nagelfar ignore
            set spalten [lsearch $findType -all $zeile *$findString*]
         }
         #puts "sp:$spalten"
         # Position z,sp speichern, alte background
         foreach sp $spalten {
            lappend resListe $z,$sp
            lappend bgListe [$tbl cellcget $z,$sp -background]
         }
      }
      
      set oldPat     $findString
      set resListe  [lsort -dictionary $resListe]
      set bgListe   [lsort -dictionary $bgListe]
      set anzResult [llength $resListe]
  
      if {$anzResult == 0} {
         $entryW configure -background pink
         bell
         $mld configure -text " nichts gefunden"
         ::utils::gui::setClock off $wDlg
         return
      }
      # alle Stellen anzeigen
      #
      if {$findAlle} {
         $mld configure -text " $anzResult Stellen gefunden"
         foreach bg $::utils::suchen::bgListe pos $resListe {
            $tbl cellconfigure $pos -background aquamarine
         }
         # auf letzte Stelle posit.
         $tbl seecell [lindex $resListe end]
         
         # grüne Markierung löschen
         after $secs {
            foreach bg $::utils::suchen::bgListe pos $::utils::suchen::resListe {
               $::utils::suchen::tbl2 cellconfigure $pos -background $bg
            }
         }
      } else {
         # Fundstellen blättern
         if {$findDirection eq {-forward}} {
            incr lastResult
            if {$lastResult >= $anzResult} {set lastResult 0}
         } else {
            incr lastResult -1
            if {$lastResult < 0} {set lastResult $anzResult; incr lastResult -1}
         }
       
         set pos [lindex $resListe $lastResult]
         if {$pos ne {} } {
            catch {
               $tbl cellconfigure $pos -background aquamarine
               $tbl seecell $pos
            }
            set fundNr [expr {$lastResult + 1}]
            $mld configure \
               -text "Fundort $fundNr von [llength $resListe]"
            after $secs {
               set wo [lindex $::utils::suchen::resListe $::utils::suchen::lastResult]
               set bg [lindex $::utils::suchen::bgListe $::utils::suchen::lastResult]
               catch { $::utils::suchen::tbl2 \
                     cellconfigure $wo -background $bg
               }
            }
         }
      }
      
      # rundrum
      #     set lastResult -1
      #    cbFindenTbl $mld $tbl
      #
      
      
      ::utils::gui::setClock off $wDlg
      return
   }
   
   #-----------------------------------------------------------------------
   proc cbFindenLB { inp } {
      # search for the pattern in the find dialog
      # inp : Textwidget|tablelist|tabular
      #-----------------------------------------------------------------------
      variable findDirection
      variable findType
      variable entryW
      variable comboboxW
      variable findIgnoreCase
      variable lastResult
      variable findString
      variable findStringListe
      variable oldPat
      variable results
      
      #_proctrace
      set class [winfo class $inp]
      set lb $inp
      
      # Listboxinhalt
      set lbListe {}
      if {$class eq "ListBox"} {
         foreach i [$lb items] {
            lappend lbListe [$lb itemcget $i -text]
         }
      } else {
         set lbListe [$lb get 0 end]
      }
      set lenLB [llength $lbListe]
      # Pat gefunden , blättern
      if {$results ne "" && $oldPat eq $findString} {
         set start $lastResult
         if {$findDirection eq "-forward"} {
            incr start
            if {$start >= [llength $results]} {
               set start 0
            }
         } else {
            incr start -1
            if {$start < 0 } {
               set start [llength $results]
               incr start -1
            }
         }
         
         set ind [lindex $results $start]
         # bei ListBox nr -> index
         if {$class eq "ListBox"} {
            set ind [lindex [$lb items] $ind]
         }
         
         $lb selection clear
         $lb selection set $ind
         $lb see $ind
         set lastResult $start
         return
      }
      
      if {$findIgnoreCase} {
         ##nagelfar ignore
         set results [lsearch \
            -nocase \
            $findType \
            -all \
            $lbListe $findString]
      } else {
         ##nagelfar ignore
         set results [lsearch \
            $findType  \
            -all       \
            $lbListe $findString]
      }
      $lb selection clear
      if {$results ne ""} {
         set lastResult ""
         set start 0
         set ind [lindex $results $start]
         # bei ListBox nr -> index
         if {$class eq "ListBox"} {
            set ind [lindex [$lb items] $ind]
         }
         $lb selection clear
         $lb selection set $ind
         $lb see $ind
         set lastResult $start
         $entryW configure -background white
         if {[lsearch $findStringListe $findString] <0} {
            lappend findStringListe $findString
            $comboboxW configure -values $findStringListe
         }
      } else {
         $entryW configure -background pink
         set lastResult ""
         bell
      }
      set oldPat $findString
   }
}