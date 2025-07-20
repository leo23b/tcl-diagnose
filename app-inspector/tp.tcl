## -*-Tcl-*-
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "tp.tcl"
 #  Description:
 #  enthält Funktionen Tracepunkte mit dem Testling
 #
 # ###################################################################

namespace eval Tp {
   
   # Tracepunkte
   variable tpNr -1  ;# Tracepunktnummer
   
   #--------------- Tabelle TracepunktInfo
   variable tdTpInfo {
      {Nr  Nr 0 right }
      {Proc    }
      {Var     }
      {Aktiv   }
   }
   
   variable tpAktiv     ;# Status-Liste aktive TP (variable ChkBt)
   variable tpVW [list] ;# TP-Verwaltung {{nr proc var aktive} ...}
   variable tpTbl       ;# Tabelle Info
   
   # ------------------------------------------------------------------
   proc CreateChkBt  {onoff tbl row col w } {
      #  erzeugt CheckButton in der TPInfoTabelle
      #  onoff : 1 oder 0 gesetzt
      # ------------------------------------------------------------------
      global
      
      checkbutton $w    \
         -borderwidth 0 \
         -relief solid  \
         -variable ::Tp::tpAktiv($row) \
         -command [list Tp::changeAktiv $w $tbl $row]

      #  Haken setzen/löschen
      if {$onoff} {
         $w select
      } else {
         $w deselect
      }
   }
   
   #-----------------------------------------------------------------------
   proc changeAktiv  {w tbl row} {
      # CB beim Setzen/Löschen CheckButton eines AktivFlags
      #-----------------------------------------------------------------------
      variable tpVW
      
      if {$::Tp::tpAktiv($row)} {
         set ::Tp::tpAktiv($row) 1
         $tbl cellconfigure $row,Aktiv -text 1
      } else {
         set ::Tp::tpAktiv($row) 0
         $tbl cellconfigure $row,Aktiv -text 0
      }
      
      # TPVerwaltung aktualisieren
      set tpVW [$tbl get 0 end]
      
      # zum Testling senden
      SendSyn -- set ::inspector_testling::tpVW [list $tpVW]
   }
   
   #--------------------------------------------------------------------
   proc PutsLevel0 {txtW x y } {
      # im Valuefenster an Folgezeile der Mausposition puts oder debug
      # [info level 0]
      #--------------------------------------------------------------------
      #_proctrace
      
      # Mausposition
      set pos [$txtW index @$x,$y]
      
      set dbgCmd {puts }
      append dbgCmd {[info level 0]}
      $txtW insert "$pos +1l linestart" "$dbgCmd\n"
   }
   #--------------------------------------------------------------------
   proc PutsVariable {txtW varName x y } {
      # Aus einer Selektion oder unter dem InsertZeiger wird eine
      # Variable erfasst.
      # Im Valuefenster an Folgezeile der Mausposition puts $var einfügen
      # oder ins Debugfenster
      # txtW  : Textwidget Value-Fenster
      # varName : selektierte Variable oder unter Mauszeiger
      #--------------------------------------------------------------------
      #_proctrace
      global gd
      
      set varName [string trim $varName]
      if {$varName == {}} {
         set gd(status) {bitte Variable selektieren}
         return
      }
      
      # Mausposition
      set pos [$txtW index @$x,$y]
      set dbgCmd \
         {puts "%varName% = <$%varName%> in Proc [lindex [split [info level 0]] 0]"}
      # nächste Zeile am Anfang
      regsub -all -- {%varName%} $dbgCmd "$varName" dbgCmd
      $txtW insert "$pos +1l linestart" "$dbgCmd\n"
   }
   #--------------------------------------------------------------------
   proc PutsListe {txtW varName x y } {
      # im Valuefeld an Folgezeile der Mausposition
      # ::utils::printliste var einfügen
      #--------------------------------------------------------------------
      #_proctrace
      global gd
      
      if {$varName == {}} {
         set gd(status) {bitte Variable selektieren}
         return
      }
      # Mausposition
      set pos [$txtW index @$x,$y]
      set dbgCmd  "::utils::printliste $varName"
      # nächste Zeile am Anfang
      $txtW insert "$pos +1l linestart" $dbgCmd\n
   }
   
   #--------------------------------------------------------------------
   proc tpToplevel {} {
      # zeigt das Tracepunkt-Textfeld als Toplevel. In den
      # Registern werden die Tracepunkte und die Tp-Info angezeigt.
      #--------------------------------------------------------------------
      global gd wv
      variable tdTpInfo
      variable tpTbl
      
      # Toplevel schon da ?
      if {[winfo exists $wv(w,top).tp]} {return}
      
      # Toplevel anlegen
      #
      set p $wv(w,top)
      set tl [::widgets::tw $p.tp   \
         -titel "Tracepunkte <$gd(targetProgramm)>" \
         -buttonbox false      \
         -multi    false       \
         -geometry 800x1000    \
         -parent   $wv(w,top)  \
         ]
      set wv(w,tl,tp) $tl
      
      set fr [$tl winfo frame]
      pack $fr -padx 0 -pady 0 -expand true -fill both
      
      # notebook für tp und info
      set nb [::utils::gui::mkNoteBook wv $fr {}]
      pack $nb -padx 0 -pady 0 -expand true -fill both
      
      # ---- Register Tracepunkte -----
      $nb insert end tp -text Tracepunkte
      set frtp [$nb getframe tp]
      
      $nb raise tp
      
      # Frame Tasten
      set fb [frame $frtp.bb -relief ridge -borderwidth 2 \
         -background skyBlue1]
      pack $fb -padx 3 -pady 3 -fill x -expand 0 -side bottom
      
      
      # ---- Textwidget für Ausgen der TP ----
      set wTxt [::utils::gui::mkText wv $frtp "" \
         -wrap none -background white]
      set wv(w,txt,tp) $wTxt
      
      # ---- Register Tracepunkt-Info ------
      $nb insert end info -text Info
      set frinfo [$nb getframe info]
      
      # Tabelle Tracepunkte
      set tpTbl [::utils::gui::mkTable wv $frinfo tbltpinfo \
         -tdx $tdTpInfo]
      $tpTbl configure -selecttype row
      $tpTbl columnconfigure Aktiv -editwindow checkbutton -editable yes
      $tpTbl columnconfigure Aktiv -formatcommand Tp::emptyStr
      proc emptyStr {val} { return "" }
      
      
      # Tasten
      set fb [frame $fb.bb -relief ridge -borderwidth 2 \
         -background skyBlue1]
      pack $fb -padx 3 -pady 3 -fill x -expand 0 -side bottom
      
      set btclear [::utils::gui::mkButton wv $fb ""       \
         -image       [::utils::gui::ic 22 edit-clear-3]  \
         -command     [list     $wTxt    delete 1.0 end]  \
         -borderwidth 1       \
         -relief      groove  \
         -helptext    "Text  löschen"  \
         -background  skyBlue1]
      
      pack $btclear -padx 3 -pady 3 -fill x -expand 0 -side left
      
      return
   }
   
   
   #--------------------------------------------------------------------
   proc tpSetzen {txtW x y selection typ } {
      # Setzt im Vuluefeld-Proc einen Tracepunkt unterhalb
      # der Mausposition.
      # Typ Var:
      #   Eine Variable muss sich unter dem Mauszeiger oder vorher
      #   selektiert werden.
      # Typ liste:
      #   Variable muss eine Liste sein
      # Typ level0:
      #   Es wird [level 0] ausgegeben
      #
      # txtW      : Textwidget Value-Fenster
      # selection : selektiert Variable
      # typ       : var |liste|level0
      # rProc     : rufende Proc
      #--------------------------------------------------------------------
      global gd wv
      variable tpNr
      variable tpVW
      
      # Aufruf aus ValueNB oder Valuefeld im Hauptfenster
      #
      if {[string match {*value*} $txtW]} {
         # Value Notebook
         set nb $wv(w,nb,$gd(targetProgramm))
         set procName [$nb itemcget [$nb raise] -text]
      } else {
         # Valuefeld
         set cb $wv(w,cb,val,Proc)
         set procName [$cb cget -text]
      }
      
      # Registername Proc Name
      lassign [split $procName] liste pName
      set rProc "??"
      if {$liste eq "Proc"} {
         set rProc $pName
      }
      
      # Mausposition
      set pos [$txtW index @$x,$y]
      incr tpNr
      
      if {$typ eq "var" || $typ eq "liste"} {
         set varName [string trim $selection]
         if {$varName == {}} {
            set gd(status) {bitte Variable selektieren}
            return
         }
         
         # ggf $ entfernen
         if {[string range $varName 0 0] eq {$}} {
            set varName [string range $varName 1 end]
         }
         
         set tpCmd "::inspector_testling::tp $tpNr $typ $rProc $varName"
         
      } elseif {$typ eq "level0" } {
         set varName ""
         set tpCmd "::inspector_testling::tp $tpNr level0 $rProc"
      }
      
      # ggf Tl anzeigen
      tpToplevel
      
      $txtW insert "$pos +1l linestart" "$tpCmd\n"
      
      # TpVerwaltung aktuali. und anzeigen
      lappend tpVW [list $tpNr $rProc $varName 1]
      
      # zum Testling senden
      SendSyn -- set ::inspector_testling::tpVW [list $tpVW]
      
      fillTpInfo
   }
   
   #-----------------------------------------------------------------------
   proc tpDisplay {msg} {
      # zeigt Tracepunkt-Info . Zuvor wird ggf Fenster geöffnet
      #-----------------------------------------------------------------------
      global wv
      
      # ggf Fenster öffnen
      tpToplevel
      set wTxt $wv(w,txt,tp)
      
      $wTxt insert end $msg
      $wTxt see end
      return
   }
   
   #-----------------------------------------------------------------------
   proc fillTpInfo {} {
      # die Tp-Verwaltung in die Tabelle schreiben
      #-----------------------------------------------------------------------
      variable tpTbl
      variable tpVW
      variable tpAktiv
      
      $tpTbl delete 0 end
      foreach tp $tpVW {
         $tpTbl insert  end $tp
         lassign $tp nr pr va aktiv
         $tpTbl cellconfigure end,Aktiv \
            -window [list ::Tp::CreateChkBt $aktiv]
      }
      return
   }
   
#-----------------------------------------------------------------------
proc tpClean {} {
   # alle TP inaktiv setzen am Ende von inspector
   #-----------------------------------------------------------------------
   global gd
   variable tpVW
 
   if {$gd(target) eq ""} {
      return
   }
   
   set tpVW1 [list]
   foreach tp $tpVW {
      lassign $tp nr p m aktiv
      lappend tpVW1 [list $nr $p $m 0]
   }
   # zum Testling senden
 
   set tpVW $tpVW1  
   SendSyn -- set ::inspector_testling::tpVW [list $tpVW1]
   return
}

   
   
} ;# Ende NS