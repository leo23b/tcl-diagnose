## -*-Tcl-*-
# ###################################################################
#  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
#  lib - Library-Funktionen für TCL/TK
#
#  FILE: "value.tcl"
#  Description:
#  enthält allgemeine Utilities für value ...
#  bearbeitet die Resourcen des Testlings
#
# ###################################################################


#----------------------------------------------------------------------
proc PopupValue {nb w x y} {
   # Popup-Menu im Value-Feld
   # nb : Notebookwidget mainNB |valueTL -> liefert Liste
   # ------------------------------------------------------------------
   global wv
   set xp [winfo pointerx .]
   set yp [winfo pointery .]
   
   # Valuetext leer ?
   _leer [$w get 1.0 end] {return}
   
   # Selections ?
   set sels [$w tag ranges sel]
   if {$sels != {}} {
      set seltext [$w get {*}$sels]
   } else {
      # wenn keine Selektion ausgewählt, Wort unter INSERT
      set seltext [$w get "@$x,$y wordstart" "@$x,$y wordend"]
   }
   
   # welche Liste angezeigt
   set nbText [$nb itemcget [$nb raise] -text]
   # text = Liste | Liste name
   set liste [lindex $nbText 0]
   
   # Menu
   set menuName .valueMenu
   catch {destroy $menuName}
   set menubar [menu $menuName -tearoff 0 -borderwidth 2 -relief ridge]
   
   if {$liste eq "Proc"} {
      $menubar add cascade -label "Debug puts ..." -menu $menubar.puts
      menu $menubar.puts \
         -tearoff 0 \
         -borderwidth 3 \
         -relief groove
      $menubar.puts add command -label {Variable } \
         -command [list ::Tp::PutsVariable $w $seltext $x $y ]
      $menubar.puts add command -label {Liste} \
         -command [list ::Tp::PutsListe $w $seltext $x $y ]
      $menubar.puts add command -label {_proctrace} \
         -command [list ::Tp::PutsLevel0 $w $x $y ]
      
      $menubar add cascade -label "Tracepunkte ..." -menu $menubar.tp
      menu $menubar.tp  \
         -tearoff 0     \
         -borderwidth 3 \
         -relief groove
      $menubar.tp add command -label {Variable} \
         -command [list ::Tp::tpSetzen $w $x $y $seltext var]
      $menubar.tp add command -label {Liste} \
         -command [list ::Tp::tpSetzen $w $x $y $seltext "liste"]
      $menubar.tp add command -label {_proctrace} \
         -command [list ::Tp::tpSetzen $w $x $y $seltext level0]
   }
   
   # bei Global Dict anzeigen
   if {$liste eq "Global"} {
      $menubar add command -label {Dictionary anzeigen} \
         -command [list ::ShowDict $w $x $y]
      $menubar add command -label {Liste anzeigen} \
         -command [list ::ShowList $w $x $y]
      $menubar add separator
   }
   
   # bei Register Quelle Procs anzeigen
   if {$liste eq "Quelle"} {
      $menubar add command -label {Procs ...} \
         -command [list ::ShowProcs $w]
      $menubar add separator
   }
   
   $menubar add command -label {suchen...} \
      -command [list ::utils::suchen::findDialog $w $w]
   
   
   tk_popup $menubar $xp $yp
}

#--------------------------------------------------------------------
proc ValueTL {orgStr args} {
   #  zeigt das Send-Value-Textfeld als Toplevel mit dyn. Register
   #  orgStr   : Originalinhalt (String)
   #--------------------------------------------------------------------
   global gd wv
   
   ::Opt::opts par $args {
      { -liste    {}    "Name der Liste" }
      { -item     {}    "Item aus der Liste" }
      { -zeile    {}    "Zeilennr zum Markieren" }
      { -source   {}    "Pfad Quelle bei Proc oder ProcName" }
   }
   set liste  $par(-liste)
   set item   $par(-item)
   set zeile  $par(-zeile)
   set source $par(-source)
   
   # Toplevel schon da ?
   if {![winfo exists $wv(w,top).value]} {
      # Toplevel Value anlegen
      set tl [::widgets::tw $wv(w,top).value    \
         -titel "Values <$gd(targetProgramm)>" \
         -buttonbox false      \
         -multi    false       \
         -geometry 800x1000    \
         -parent   $wv(w,top)  \
         ]
      set wv(w,tl,value) $tl
      
      set fr [$tl winfo frame]
      pack $fr -padx 0 -pady 0 -expand true -fill both
      
      # Notebook
      set nb [::utils::gui::mkNoteBook wv $fr "" -homogeneous 0]
      pack $nb -padx 3 -pady 3 -fill both -expand 1
      
      set wv(w,nb,$gd(targetProgramm)) $nb
      $nb bindtabs <ButtonRelease-3> [list ValueTLClose $nb ]
   }
   
   # Toplevel schon vorhanden, nur raise
   #
   set tl $wv(w,top).value
   set nb $wv(w,nb,$gd(targetProgramm))
   wm deiconify $tl
   raise $tl
   
   # neues Register
   #
   set title   "$liste: $item"
   set tabName "${liste} $item"
   
   # bei Quellen nur Tail anzeigen
   #
   if {$liste eq "Quelle"} {
      set tabName "$liste [file tail $item]"
   }
   
   # tab schon da, dann raise
   #
   set tabNrn [$nb pages]
   foreach nr $tabNrn {
      set name [$nb itemcget $nr -text]
      if {$tabName eq $name} {
         $nb raise $nr
         return
      }
   }
   
   # neuer Tab einfügen
   #
   incr gd(dynTabNr)
   set tabNr $gd(dynTabNr)
   $nb insert end $tabNr -text $tabName
   
   set fr [$nb getframe $tabNr]
   
   # Tasten
   set fb [frame $fr.bb -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $fb -padx 3 -pady 3 -fill x -expand 0 -side bottom
   
   set lb [::utils::gui::mkLabel wv $fr "" -relief sunken\
      -font TkHeadingFont]
   pack $lb -padx 3 -pady 3 -fill x -expand 0
   
   set txt [text $fr.txt -wrap none -background white]
   set wv(w,txt,$tabNr) $txt
   
   pack $txt -padx 3 -pady 3 -fill both -expand 1
   bind $txt <ButtonPress-3> [list PopupValue $nb %W %x %y]
   
   set bt1 [::utils::gui::mkButton wv $fb "" \
      -image [::utils::gui::ic 22 go-next] \
      -borderwidth 1 -relief groove \
      -command [list ValueTLEval $tabName $txt] \
      -helptext "Registerlasche zum Ziel senden" \
      -background skyBlue1]
   set bt2 [::utils::gui::mkButton wv $fb "" \
      -image [::utils::gui::ic 22 edit-redo] \
      -borderwidth 1 -relief groove \
      -helptext "Registerlasche restaurieren" \
      -command [list ValueTLReset $orgStr $txt] \
      -background skyBlue1]
   set bt3 [::utils::gui::mkButton wv $fb "" \
      -image [::utils::gui::ic 22 system-switch-user] \
      -borderwidth 1 -relief groove \
      -helptext "vergleicht geänderten Text" \
      -command [list ValueTLDiff $orgStr $txt] \
      -background skyBlue1]
   
   set bt5 [::utils::gui::mkButton wv $fb "" \
      -image [::utils::gui::ic 22 view-refresh] \
      -borderwidth 1 -relief groove \
      -helptext "Element neu laden nach reconnect" \
      -command [list ValueTLReload $nb $tabNr $txt] \
      -background skyBlue1]
   
   set bt6 [::utils::gui::mkButton wv $fb "" \
      -image [::utils::gui::ic 22 process-stop] \
      -borderwidth 1 -relief groove \
      -helptext "Fenster löschen" \
      -command [list destroy $tl] \
      -background skyBlue1]
   
   pack $bt1 -padx 3 -pady 3 -side right
   pack $bt6 $bt5 $bt2 $bt3 -padx 3 -pady 3 -side left
   
   # text (Value) einfügen
   #
   $txt insert end $orgStr
   ::syntaxhighlight::highlight $txt
   
   $txt edit modified 0
   bind $txt <<Modified>> [list ValueTLModified $nb %W]
   
   # Zeile markieren ?
   #
   if {$zeile >0} {
      incr zeile
      $txt tag add zeilex $zeile.0 $zeile.end
      $txt tag configure zeilex -background red -foreground yellow
      $txt see $zeile.0
   }
   $nb raise $tabNr
   
   # Label setzen
   #
   if {$liste eq "Proc"} {
      set text $source
   } else {
      set text "$liste - $item"
   }
   
   $lb configure -textvariable {}
   $lb configure -text $text
   return
}
#-----------------------------------------------------------------------
proc ValueTLUpdate {  } {
   # akt. in ToplevelValue alle Register nach reconnect
   #-----------------------------------------------------------------------
   global wv gd
   
   # Ziel verloren
   if {$gd(target) eq ""} {return}
   
   if {[info exists wv(w,nb,$gd(target))]} {
      set nb $wv(w,nb,$gd(target))
   } else {
      return
   }
   
   if {![winfo exists $nb]} {
      return
   }
   
   # alle Tabnamen sichern, Inhalt Register löschen
   #
   set list_items ""
   foreach tab [$nb pages] {
      set list_item [$nb itemcget $tab -text]
      lappend list_items $list_item
      $nb delete $tab
   }
   
   # alle Tabnamen neu laden
   #
   foreach list_item $list_items {
      lassign [split $list_item] liste item
      if {$liste eq "Proc"} {
         # item gegen Listeninhalt prüfen
         # ansonst Datei ermitteln und sourcen
         if {$item ni $gd(Proc,inhalt)} {
            if {[catch {Bwsend $gd(target) set ::auto_index($item)} source]} {
               # :: weglassen
               set itemK [string range $item 2 end]
               if {[catch {Bwsend $gd(target) set ::auto_index($itemK)} source]} {
                  set source ""
               }
            }
            if {$source ne ""} {
               if {[catch {Bwsend $gd(target)  $source} msg]} {
                  ::utils::gui::msg error Source $msg
               } else {
                  UpdateListe Proc
               }
            }
            #return
         }
      }
      SelectListe -liste $liste -item $item -top 1
   }
}
#--------------------------------------------------------------------
proc ValueTLReload {nb tabnr txt} {
   # lädt in ToplevelValue die Prozedur der aktuelle
   # Registerlasche neu, zB nach reconnect
   #--------------------------------------------------------------------
   global wv gd
   
   # Ziel verloren
   if {$gd(target) eq ""} {return}
   
   # Abfrage überschreiben ja/neim
   if {[$txt edit modified]} {
      set msg "Text wurde geändert\n"
      append msg "Überschreiben ?"
      set ans [tk_messageBox  \
         -message  $msg       \
         -parent $txt         \
         -type yesno]
      if {$ans eq "yes"} {
         # weiter anzeigen
      } else {
         return
      }
   }
   
   set tabText [$nb itemcget $tabnr -text]
   lassign [split $tabText] liste item
   $nb delete $tabnr
   SelectListe -liste $liste -item $item -top 1
   
}
#--------------------------------------------------------------------
proc ValueTLReset {orgStr txt} {
   # restauriert in ToplevelValue die aktuelle Registerlasche
   # auf den Stand der Anzeige zB nach interaktiven Änderungen.
   # d.h. Änderungen werden ignoriert.
   # orgStr : Inhalt zum Stand beim ersten Anzeigen
   #--------------------------------------------------------------------
   global gd
   
   # Abfrage überschreiben ja/neim
   if {[$txt edit modified]} {
      set msg "Text wurde geändert\n"
      append msg "Überschreiben ?"
      set ans [tk_messageBox  \
         -message  $msg       \
         -parent $txt         \
         -type yesno]
      if {$ans eq "yes"} {
         # weiter anzeigen
      } else {
         return
      }
   }
   
   $txt delete 0.0 end
   $txt insert end $orgStr
   ::syntaxhighlight::highlight $txt
   
   # Modified-Markierung reset
   $txt edit modified 0
   
}
#--------------------------------------------------------------------
proc ValueTLDiff {orgStr txt} {
   # vergleicht orig. und akt. Inhalt der aktuellen Registerlasche
   # in ToplevelValue
   #--------------------------------------------------------------------
   global gd
   
   DirDiffText $orgStr $txt
}
#--------------------------------------------------------------------
proc ValueTLClose {nb tabNr} {
   # löscht ToplevelValue die aktuelle Registerlasche
   #--------------------------------------------------------------------
   global gd wv
   
   # Ziel verloren
   if {$gd(target) eq ""} {return}
   
   # Abfrage überschreiben ja/neim
   set txt $wv(w,txt,$tabNr)
   if {[$txt edit modified]} {
      set msg "Text wurde geändert\n"
      append msg "Löschen ?"
      set ans [tk_messageBox  \
         -message  $msg       \
         -parent $nb          \
         -type yesno]
      if {$ans eq "yes"} {
         #weiter
      } else {
         return
      }
   }
   $nb delete $tabNr
   $nb raise [lindex [$nb pages] 0]
   
}
#--------------------------------------------------------------------
proc ValueTLEval {tabName txt} {
   # sendet in ToplevelValue die aktuelle Registerlasche zum Ziel
   # txt: Textwidget
   #--------------------------------------------------------------------
   global gd
   
   if {$gd(target) eq ""} {return}
   set gd(status) {}
   
   # Register Quelle nicht senden
   #
   if {[lindex $tabName 0] eq "Quelle"} {
      return
   }
   
   set value [$txt get 0.0 end ]
   _leer $value {return}
   ::utils::gui::setClock on $txt
   SendSyn --  $value
   set gd(status) "send $tabName fertig"
   ::utils::gui::setClock off $txt
   
   # Modified-Markierung reset
   $txt edit modified 0
   
}

#--------------------------------------------------------------------
proc ValueTLKorr {procname txtW} {
   # übergibt die geänderte Proc an ased5
   # procname : Name Procedur
   # txtW     : Textwidget mit geänderte Procedur (Inhalt von Tab)
   #--------------------------------------------------------------------
   global gd
   
   # Ziel verloren
   if {$gd(target) eq ""} {return}
   
   # KorrDatei erstellen
   set txtKorr [$txtW get 1.0 end]
   set tmp [::utils::file::writetmp $txtKorr inspector]
   
   # ased5 aufrufen mit send
   #
   set cmd "send ased5 ::ED::replaceProc $procname $tmp"
   if {[catch {eval $cmd} msg]} {
      set msg1 "F-$cmd:$msg"
      ::utils::gui::msg error "Fehler" $msg1
      file delete $tmp
      return
   }
   
   file delete $tmp
   set gd(status) "$procname korrigiert"
   
   
}

#-------------------------------------------------------------------
proc ValueUpdate {liste} {
   # aktualisiert Valuetext
   # Aufruf nach Select CB oder durch reconnect
   #--------------------------------------------------------------------
   global wv gd
   
   set w $wv(w,cb,val,$liste)
   set liste_item [$w get]
   _leer $liste_item  {return}
   
   lassign $liste_item listeI item
   if {$liste == {Widget} } {
      if { $::inspector::winOpts == {Configuration}} {
         # Widget vorhanden
         if {![info exists ::inspector::widgetTree($item)]} {
            return
         }
         # dadurch wird 2x geflasht, n-1 und n
         SelectWidget -widget $item
         return
      }
   } else {
      if {$liste eq "Proc"} {
         # item gegen Listeninhalt prüfen
         # ansonst Datei ermitteln und sourcen
         if {$item ni $gd(Proc,inhalt)} {
            if {[catch {Bwsend $gd(target) set ::auto_index($item)} source]} {
               # :: weglassen
               set itemK [string range $item 2 end]
               if {[catch {Bwsend $gd(target) set ::auto_index($itemK)} source]} {
                  set source ""
               }
            }
            if {$source ne ""} {
               if {[catch {Bwsend $gd(target) $source} msg]} {
                  ::utils::gui::msg error Source $msg
                  return
               }
               UpdateListe Proc
            }
            return
         }
      }
      set wLb $wv(w,lb,$liste)
      $wLb selection clear
      
      catch {SelectListe -liste $liste -item $item}
   }
}
#-----------------------------------------------------------------------
proc ValueTLModified {nb textW} {
   #bei Textänderung wird rote Kugel gesetzt bzw zurück gesetzt
   #-----------------------------------------------------------------------
   set tab [$nb raise]
   if {[$textW edit modified]} {
      $nb itemconfigure $tab \
         -image [::utils::gui::ic 12 redball]
   } else  {
      catch {$nb itemconfigure $tab -image ""}
   }
   return
}