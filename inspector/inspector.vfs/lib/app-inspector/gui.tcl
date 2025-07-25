## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "gui.tcl"
 #  Description:
 #  enthält gui-Funktionen 
 #
 # ###################################################################

#-----------------------------------------------------------------------
# x11Staff
#-----------------------------------------------------------------------
proc x11Staff {} {
   global gd opt wv
   
   puts "x11 einrichten ..."
   
   # Icon-Verzeichnisse initialisieren
   #
   ::utils::gui::init [list [file join $::scriptDirMain .. icons] ]
   
   #--------------- einige Optionen
   #
   option add *selectForeground black
   option add *selectBackground yellow
   option add *Entry*background white
   option add *LabelEntry*background white
   option add *Scrollbar*width 10
   option add *background slategray1
   option add *font TkDefaultFont
   tk_focusFollowsMouse
   
   bind all <Control-plus>  {BumpFonts %W +1}
   bind all <Control-minus> {BumpFonts %W -1}
   
   #--------------- Palette übernehmen
   #
   tk_setPalette SlateGray1
   option add *background slategray1 widgetDefault
   
   #--------------- WheelScrolling im Canvas
   #
   ##nagelfar ignore
  # bind Canvas <Button-4> {%W yview scroll -5 units}
   ##nagelfar ignore
  # bind Canvas <Button-5> {%W yview scroll 5 units}
   
   ##nagelfar ignore
  # bind Canvas <Shift-Button-4> {%W xview scroll -5 units}
   ##nagelfar ignore
  # bind Canvas <Shift-Button-5> {%W xview scroll  5 units}
   
   ##nagelfar ignore
   bind Text <Shift-Button-4> {%W xview scroll -5 units}
   ##nagelfar ignore
   bind Text <Shift-Button-5> {%W xview scroll  5 units}
   
   #--------------- Select Entry bei FocusIn
   #
   bind Entry   <FocusIn> {Traverse_in %W}
   
   #--------------- Tooltip Alias
   #
   interp alias {} tooltip {} DynamicHelp::register
   DynamicHelp::configure \
      -delay 200 -padx 3 -pady 3 -background yellow
   
   #set gd(colErr)  {red1}
   #set gd(colWar)  {yellow}
   #set gd(colUnv)  {MediumPurple4}
   
   
   #---------------  Window manager stuff
   #
   wm withdraw .
   set w ".$gd(programm)"
   set wv(w,top) $w
   
   toplevel $w    \
      -class $gd(programm) -padx 0 -pady 0 -bd 0 -relief ridge
   
   set geo [::utils::getCfgKey "geo"  $gd(programm)]
   _leer $geo {set geo {1200x800+400+50}}
   wm geometry $w $geo
   
   wm title $w "$gd(programm) <$gd(host)>"
   wm iconphoto  $w -default [::utils::gui::ic 48 doctors-bag-48]
   wm protocol   $w WM_DELETE_WINDOW CleanExit
   
   #  bind all <Control-c>  [list ConnectDialog ]
   bind all <Control-u>  [list UpdateListe alle]
   return $w
}

#-----------------------------------------------------------------------
proc MakeMf {w} {
   #  w Parent
   #  erzeugt Toplevel Mainframe
   #-----------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   #--------------------- Mainframe mit Menu
   #
   set mainframe [MainFrame::create $w.mf  \
      -menu $gd(mainMenu)        \
      -textvariable ::gd(status) \
      ]
   
   set gd(status) $gd(version)
   
   pack $mainframe -fill both -expand yes -padx 0 -pady 0
   set p [$mainframe getframe]
   
   $mainframe.status configure -background skyBlue1 \
      -relief sunken -borderwidth 1
   $mainframe.status.label configure -background skyBlue1 \
      -relief sunken -borderwidth 1 -padx 5
   
   $mainframe.status.prg.bar configure -background skyBlue1 \
      -relief sunken -borderwidth 1
   $mainframe.status.prg configure -background skyBlue1
   
   set wv(w,progress) $mainframe.status.prg
   
   DynamicHelp::add $mainframe.status.indf -text {ind}
   
   #--------------------- Rahmen fuer Toolbox
   #
   set fbo [frame $p.fbo -borderwidth 1 -relief ridge \
      -background #c082f061ffff]
   pack  $fbo -padx 3 -pady 3 -fill x -side top
   
   ::utils::gui::mkTButton wv $fbo exit   \
      -image [::utils::gui::ic 22 system-shutdown] \
      -helptext {Programm beenden}        \
      -background #c082f061ffff           \
      -command CleanExit
   ::utils::gui::mkTButton wv $fbo help   \
      -image [::utils::gui::ic 22 help-browser] \
      -helptext {Online Hilfe anzeigen}   \
      -background #c082f061ffff           \
      -command OnlineDoku
   
   ::utils::gui::mkTButton wv $fbo target     \
      -image  [::utils::gui::ic 22 view-refresh-2] \
      -helptext {mit dem Testling verbinden} \
      -background #c082f061ffff              \
      -command [list Connect::dialog ]
   
   ::utils::gui::mkTButton wv $fbo reconnect \
      -image [::utils::gui::ic 22 view-refresh] \
      -helptext {Reconnect akt. Ziel} \
      -background #c082f061ffff       \
      -command ::Connect::reconnect
   
   ::utils::gui::mkTButton wv $fbo config \
      -image [::utils::gui::ic 22 configure-2] \
      -helptext "Einstellungen ändern" \
      -background #c082f061ffff        \
      -command ::Cfg::dialog
   
   # Entr timeout
   set enTO [Entry $fbo.ento -width 3 \
      -justify      right            \
      -textvariable "gd(defaultTO)"  \
      -background   #c082f061ffff    \
      -borderwidth  1                \
      -relief       solid            \
      -justify      center           \
      -helptext "Default Timeout in sec"]
   
   pack $fbo.exit $fbo.help -padx 3 -pady 3 -side left
   pack $fbo.target $fbo.reconnect $fbo.config \
      $fbo.ento -padx 3 -pady 3 -side left
   
   
   #pack $fbo.ento -padx 3 -pady 3 -side left -fill y
   
   
   set titel [::utils::gui::mkLabel wv $fbo targetName \
      -bd 2                     \
      -relief sunken            \
      -font TkHeadingFont       \
      -background #c082f061ffff \
      -padx 8]
   set wv(v,targetName) "Drop here"
   set wv(w,targetName) $titel
   pack $titel -side left -fill both -padx 5 -pady 3
   
   if {![catch {package require tkdnd} msg]} {
      # Dropziel für Testling
      # liefert comm::comm self  Typ DND_COMMID
      ::Dnd::dropZiel $titel DND_COMMID \
         ::Dnd::dropTestlingSelf        \
         ::Dnd::dropEnterTestlingSelf   \
         ::Dnd::dropLeaveTestlingSelf
   }
   Separator $fbo.sep1 -orient vertical
   pack $fbo.sep1 -side left -fill y -padx 1
   
   package require gradientpanel
   ##nagelfar ignore
   set gp [ gradientpanel create $fbo.lb \
      -text {         inspector} \
      -title ""          \
      -bg0 #c082f061ffff \
      -bg1 skyblue4      \
      -fg blue           \
      -font {TKHeadingFont } \
      -icon [::utils::gui::ic 48 gwenview-2]]
   pack $fbo.lb -side left -fill both -expand 1
   
   
   return $p
}
#-----------------------------------------------------------------------
proc MainGui {} {
   #  erzeugt graphische Oberflaeche
   #-----------------------------------------------------------------------
   global gd wv opt
   #_proctrace
   
   puts " Gui anlegen ..."
   set w [x11Staff]
   set p [MakeMf $w]
   
   # unten Sendebereich, oben Auswahl und Inhalt
   # 
   set erg [::utils::gui::mkPanedWindow wv $p pw \
      -wts {6,1} -richt -]
   lassign $erg pw fo fu
   pack $pw -padx 0 -pady 0 -fill both -expand yes
   
   # -------------------------- Send-Bereich
   #
   set fsend [frame $fu.send -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $fsend -padx 3 -pady 3 -fill x -expand 0 -side top -anchor n
   
   # Sendebereich
   # 
   set bt [::utils::gui::mkButton wv $fsend bt,send \
      -image [::utils::gui::ic 16 mail-forward] \
      -command SendCommand \
      -helptext "Kommando zum Ziel schicken" \
      -borderwidth 2 -relief raised \
      -background skyBlue1]
   pack $bt -padx 3 -pady 3 -side left
   
   set cb [::utils::gui::mkComboBox wv $fsend cb,send \
      -command   SendCommand \
      -modifycmd SendCommand \
      -exportselection 0     \
      -background skyBlue1]
   pack $cb -padx 3 -pady 3 -side right -fill x -expand 1
   set wv(v,cb,send) ""
   
   # Ergebnis senden
   set txt [::utils::gui::mkText wv $fu txt,send \
      -wrap none \
      -exportselection 1]
   bind $txt <Control-f> [list ::utils::suchen::findDialog %W %W]
   
   # --------------------------  Klassen-Notebook-Listen-Bereich
   #
   set fnb [frame $fo.nb -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $fnb -padx 3 -pady 3 -fill both -expand 1 -side top -anchor n
   
   set nb [::utils::gui::mkNoteBook wv $fnb nb -homogeneous 0]
   pack $nb  -padx 3 -pady 3 -fill both -expand 1 -side top -anchor n
   
   # Hintergrund Gradient
   ::canvas::gradient $nb.c -direction x \
      -color2  skyblue4 \
      -color1  cornFlowerBlue
   
   # Klassen-Tabs 
   foreach na $gd(listen) {
      set text $na
      AddTab $nb $na $text {} [list RaiseTab $na]
   }
   
   # Verbindung zum angegebenem Port
   ::Connect::connect comm $opt(-port)
   
   return
}
#-----------------------------------------------------------------------
proc RaiseTab {liste} {
   #
   #-----------------------------------------------------------------------
 
   return
}



#-----------------------------------------------------------------------
proc CreateListe {nb liste} {
   # erzeugt LB, Find und Valuebereich aller Register außer Widget
   # liste : Register Proc ....
   #-----------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   if {$liste eq "Widget"} {
      CreateWidgetListe $nb $liste
      return
   }
   set fr [$nb getframe $liste]
   
   # -------------------- PanedWindow: o: Listbox u:Valuebereich
   #
   set erg [::utils::gui::mkPanedWindow wv $fr "" \
      -wts {1,1} -richt -]
   lassign $erg pw fo fu
   pack $pw -padx 0 -pady 0 -fill both -expand yes
   
   # -------------------- ListBox-Bereich
   #
   set sw [ScrolledWindow $fo.sw -auto both]
   
   set lb [ListBox $fo.lb \
      -deltay 20 \
      -selectforeground red \
      -selectmode single ]
   $sw setwidget $lb
   set wv(w,lb,$liste) $lb
      
   # Hintergrund ListBox
   ::canvas::gradient $lb.c -direction x \
      -color1  lavender   \
      -color2  cornflowerblue
   
   # -------------------- Findbereich
   #
   set ff [frame $fo.find -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $ff -padx 0 -pady 0 -fill x -expand 0 -side bottom
   
   # FindButton
   set bt [::utils::gui::mkButton wv $ff bt,find,$liste \
      -image [::utils::gui::ic 16 edit-find] \
      -borderwidth 2 -relief raised \
      -command [list ListboxSuche $lb %N %K $liste] \
      -background skyBlue1]
   pack $bt -padx 3 -pady 3 -side left
   
   # ClearButton
   set bt [::utils::gui::mkButton wv $ff bt,clear,$liste \
      -image [::utils::gui::ic 16 edit-clear-locationbar-ltr] \
      -borderwidth 2 -relief raised \
      -command ClearPat   \
      -background skyBlue1]
   pack $bt -padx 3 -pady 3 -side left
   
   # PatternEntry
   set en [::utils::gui::mkEntry wv $ff en,find,$liste ]
   
   # IntensivSuche bei Proc
   # suche in auto_index und source vom Modul
   if {$liste eq "Proc"} {
      set bt [::utils::gui::mkButton wv $ff bt,intensiv,$liste \
         -helptext {intensiv nach Proc suchen} \
         -image [::utils::gui::ic 16 zoom-3]   \
         -borderwidth 2 -relief raised         \
         -command [list IntensivProc $lb $en $liste]   \
         -background skyBlue1]
      pack $bt -padx 3 -pady 3 -side right
   }
   
   pack $en -padx 3 -pady 3 -side left -fill x -expand 1
   bind $en <KeyRelease>  [list ListboxSuche $lb %N %K $liste]
   
   # Listboxbereich
   pack $sw -padx 3 -pady 3 -expand yes -fill both -side top
   
   # -------------------- Value-Bereich
   #
   
   # Label
   set lab [::utils::gui::mkLabel wv $fu "lab,val,$liste" \
      -relief sunken -background skyblue1 -font TkHeadingFont]
   pack $lab -padx 3 -pady 1 -fill x -expand 0
   
   set fval [frame $fu.val -relief ridge -borderwidth 1 \
      -background skyBlue1]
   pack $fval -padx 3 -pady 2 -fill x -expand 0 -side top -anchor n
   
   # ValButton
   set bt [::utils::gui::mkButton wv $fval bt,val,$liste \
      -image [::utils::gui::ic 16 mail-forward] \
      -command SendValue             \
      -borderwidth 2 -relief raised \
      -helptext "Text zum Ziel schicken" \
      -background skyBlue1]
   pack $bt -padx 3 -pady 3 -side left
   
   # ComboBox für Historie
   set cb [::utils::gui::mkComboBox wv $fval cb,val,$liste \
      -modifycmd [list ValueUpdate $liste]  \
      -background skyBlue1]
   pack $cb -padx 3 -pady 3 -side right -fill x -expand 1
   set wv(v,cb,val,$liste) ""
   
   if {$liste ne "Canvas"} {
      # ValueText
      set txt [::utils::gui::mkText wv $fu txt,val,$liste \
         -background white       \
         -selectforeground black \
         -wrap none              \
         -exportselection 1]
   } else {
      set wv(fr,fu,Canvas) $fu
      # Valuebutton entfernen
      pack forget $wv(w,bt,val,Canvas)
   }
   
   $lb bindText <ButtonRelease-1> [list SelectListe -index ]
   $lb bindText <Control-ButtonRelease-1> [list SelectListe -top 1 -index ]
   bind $lb <ButtonPress-3> [list PopupListe $lb %x %y]
   if {$liste ne "Canvas"} {
      bind $txt <ButtonPress-3> [list PopupValue $nb %W %x %y]
      bind $txt <Control-s> [list SendValue]
      bind $txt <Control-f> [list ::utils::suchen::findDialog %W %W]
   }
}
#-----------------------------------------------------------------------
proc IntensivProc {lb en liste} {
   # Suche nach einer Proc, deren Modul noch nicht gesourced ist.
   # Suche in ::auto_index liefert alle passenden Module,
   # die anschliessend gesourced werden
   #
   # lb: Listbox
   # en: Eingabewidget Suchmuster
   # liste : Listenname (muss Proc sein)
   #-----------------------------------------------------------------------
   #_proctrace
   global gd
   
   # nur bei ProcListe
   if {$liste ne "Proc"} {return}
   
   # Suchmuster aus entry
   #
   set pat [$en get]
   
   # schon in der Procliste vorhanden ?
   #
   foreach pr $gd(Proc,inhalt) {
      if {[string match -nocase "*$pat*" $pr]} {
         # gefunden, jetzt nochmal nach Muster suchen
         ListboxSuche $lb {} {} Proc
         #_dbg 20 Procliste {format "$pat schon in ProcListe"}
         return
      }
   }
   
   # in auto_index suchen
   #
   set keys [SendSyn -- array names ::auto_index *$pat*]
   if {$keys eq ""} {
      set gd(status) "Intensiv nach <$pat> ohne Erfolg gesucht"
      return
   }
   #_dbg 20 Modulliste {::utils::printlistestring keys}
   
   # alle gefundenen Module sourcen
   set module [list]
   foreach key $keys {
      set sourcePath [SendSyn -- set ::auto_index($key)]
      lassign [split $sourcePath] dum path
      if {$path in $module} {continue}
      
      SendSyn -- source $path
      lappend module $path
   }
   
   # Proc Liste aktualisieren
   UpdateListe Proc
   
   # jetzt nochmal nach Muster suchen
   ListboxSuche $lb {} {} Proc
   
   return
}

#--------------------------------------------------------------------
proc FillListe {liste data} {
   # die Liste liste wird mit den Daten neu befüllt
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   # Register vorhanden ?
   set nb $wv(w,nb)
   if {![info exists wv(w,bt,find,$liste)]} {
      CreateListe $nb $liste
   }
   
   if {$liste eq "Widget"} {return}
   
   set wListbox $wv(w,lb,$liste)
   $wListbox delete [$wListbox items]
   
   set nr 0
   foreach item $data {
      $wListbox insert end $nr -text $item -data $item
      incr nr
   }
   set gd(status) "[llength $data] Elemente in $liste"
}

#--------------------------------------------------------------------
proc SelectListe {args} {
   # zeigt Item aus der Liste im Valuefenster
   # oder als TL
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   if {$gd(target) eq ""} {return}
   ::Opt::opts "par" $args {
      { -liste    {}    "Listenname" }
      { -top      {}    "Anzeige als Tl" }
      { -item     {}    "Item im Infofeld anzeigen" }
      { -zeile    {}    "Zeile # zeile im TL markieren" }
      { -index    {}    "ListBox Index" }
   }
   set item  $par(-item)
   set index $par(-index)
   set top   $par(-top)
   set zeile $par(-zeile)
   set liste $par(-liste)
   
   _leer $liste  {set liste [$wv(w,nb) raise]}
   set wLb $wv(w,lb,$liste)
   set gd(status) ""
   
   if {$item eq ""} {
      set item [$wLb itemcget $index -text ]
   }
   _leer $item {return}
   
   if {$liste eq "Canvas"} {
      ::Canvas::tblCanvas $item
      return
   }
   
   ::utils::gui::setClock on $wLb
   set result {}
   
   # Switch über Liste
   #
   switch -- $liste {
      Namespace {
         set namespace $item
         set result "namespace eval $namespace \{\n"
         
         set exports [names::exports $namespace]
         if {$exports ne ""} {
            append result "\n   namespace export $exports\n"
         }
         
         set vars [names::vars $namespace]
         if {$vars ne ""} {
            append result "\n"
         }
         foreach var [lsort $vars] {
            append result "   [names::value $var]"
         }
         
         set procs [lsort [names::procs $namespace]]
         append result "\n# export:\n"
         foreach proc $procs {
            if {[lsearch -exact $exports [namespace tail $proc]]!=-1} {
               append result "   [names::prototype  $proc]\n"
            }
         }
         
         append result "\n# internal:\n"
         foreach proc $procs {
            if {[lsearch -exact $exports [namespace tail $proc]]==-1} {
               append result "   [names::prototype $proc]\n"
            }
         }
         #nagelfar ignore
         append result "\}\n\n"
         
         set children [names::names   $namespace]
         foreach child [lsort $children] {
            if {$child!=$namespace} {
               append result "namespace eval $child {}\n"
            }
         }
         
      }  
      Global {
         # info item exists ?
         if {[SendSyn -- info exists $item]} {
            set wert [SendSyn -- ::inspector_testling::GetGlobalVar $item]
            append result $wert
         } else {
            set gd(status) "$item existiert nicht mehr"
         }
      }
      Proc {
         set result [SendSyn -- ::inspector_testling::ProcInfo $item]
      }
      
      Menu {
         set anz [SendSyn -- $item "index" end]
         # anz ist none
         if {![string is integer $anz]} {set anz -1}
         
         incr anz
         set result {;# }
         append result " menu $item has $anz entries"
         for {set nr 0} { $nr < $anz} {incr nr} {
            set entrConfig [SendSyn --    $item entryconfig $nr]
            append result "\n$item entryconfigure $nr"
            foreach option $entrConfig {
               set opt  [lindex $option 0]
               set wert [lindex $option 4]
               append result " \\\n\t$opt [list $wert]"
            }
         }
      }
      
      Image {
         set image $item
         set result {;# }
         append result "image configuration for [list $image]\n"
         set class ""
         append class [SendSyn -- "image" width $image] "x"   \
            [SendSyn -- "image" height $image] " "  \
            [SendSyn -- "image" type $image]
         append result "# ($class image)\n"
         append result "$image config"
         foreach spec [SendSyn --   $image config] {
            if {[llength $spec] == 2} {continue}
            append result " \\\n\t[lindex $spec 0] [list [lindex $spec 4]]"
         }
         append result "\n"
      }
      
      Font {
         set font $item
         set result {;# }
         append result "font configuration for [list $item]\n"
         append result "font configure $font"
         foreach {spec val} [SendSyn -- "font" configure $item ] {
            if {$spec == "-family"} {set val [list $val]}
            append result " \\\n\t$spec $val "
         }
         append result "\n"
      }
      
      After {
         set sendK [list after info $item]
         if {[catch {eval $sendK} afterInfo]} {
         }
         
        # set afterInfo [SendSyn -- after info $item]
         set result {;# }
         append result "   -- after Info $item  --\n"
         if {[llength $afterInfo]==2} {
            set script [lindex $afterInfo 0]
            set type   [lindex $afterInfo 1]
            switch $type {
               idle    {append result "#\tafter idle $script\n"}
               timer   {append result "#\tafter ms $script\n"}
               default {append result "#\tafter $type $script\n"}
            }
         } else {
            append result "# $afterInfo"
         }
      }
      Quelle {
         set result [SendSyn -- \
            ::inspector_testling::GetQuelle $item]
      }
   } ;# switch
   
   # Result in textWidget oder Toptext schreiben
   #
   
   # Proc liefert {source result}
   if {$liste eq "Proc"} {
      lassign $result source erg
      set result $erg
      set text $source
   } else {
      # Label setzen
      set text "$liste - $item"
      set source ""
   }
   if {$top ne ""} {
      ValueTL $result -liste $liste -item $item -zeile $zeile \
         -source $source
   } else {
      
      # Abfrage überschreiben ja/neim
      set textWidget $wv(w,txt,val,$liste)
      
      if {[$textWidget edit modified] } {
         set msg "ValueFeld wurde geändert\n"
         append msg "siehe rote Kennung \n"
         append msg "Valuefeld überschreiben ?"
         set ans [tk_messageBox  \
            -message  $msg       \
            -parent $wv(w,top)   \
            -type yesno]
         if {$ans eq "yes"} {
            # weiter anzeigen
         } else {
            ::utils::gui::setClock off $wLb
            return
         }
      }
      
      # Textinhalt und Überschrift normieren
      #
      
      set lab $wv(w,lab,val,$liste)
      $lab configure -text ""
      
      $textWidget delete 0.0 end
      $textWidget insert end $result
      
      $textWidget edit modified 0
      bind $textWidget <<Modified>> [list ListModified %W $liste]
      
      # kein highlight bei langen Proc
      if {$liste eq "Proc"        \
            || $liste eq "Quelle" \
         } {
         if {[string length $result] < 600000} {
            ::syntaxhighlight::highlight $textWidget
         }
      }
      
      # in ComboBox Item eintragen
      set wCbValue $wv(w,cb,val,$liste)
      set vals [$wCbValue cget -values]
      if {"$liste $item" ni $vals} {
         $wCbValue configure -values [lappend vals "$liste $item"]
      }
      set wv(v,cb,val,$liste) "$liste $item"
      
      $lab configure -textvariable {}
      $lab configure -text $text
   }
   ::utils::gui::setClock off $wLb
}

#-----------------------------------------------------------------------
proc ListModified {textW liste} {
   #bei Textänderung wird rote Kugel gesetzt bzw zurück gesetzt
   #-----------------------------------------------------------------------
   global wv
   set bt $wv(w,bt,val,$liste)   
   if {[$textW edit modified]} {
      $bt configure -background red
   } else  {
      $bt configure -background skyBlue1
   }
   return
}


#--------------------------------------------------------------------
proc ListboxSuche {w char key liste} {
   # sucht in der Listbox oder im Widgettree nach Muster
   # w: lb |tbl
   # char : eingegebenes Zeichen
   # key  : Tastencode
   #--------------------------------------------------------------------
   global gd wv
   
   # Steuertasten Shift,Control, Alt  ...ausblenden
   # aber Return durchlassen
   if {$char > 60000 &&
      ($key ne "Return" || $key eq "??" || $key eq "")} {
      return
   }
   
   set wEntry $wv(w,en,find,$liste)
   set vEntry $wv(v,en,find,$liste)
   
   set len [llength $gd($liste,inhalt)]
   set gd(status) {}
   set pattern $vEntry
   if {$pattern eq ""} {
      set gd(status) {bitte Suchtext eingeben}
      return
   }
   
   # blättern ?
   if {$pattern == $::inspector::pattOld($liste) &&
         $::inspector::ids($liste) ne {} } {
      set idx $::inspector::lastSee($liste)
      incr idx
      if {$idx >= [llength $::inspector::ids($liste)]} {
         set idx 0
      }
      $w selection clear 0 end
      
      set gef [lindex $::inspector::ids($liste) $idx]
 
      $w selection set $gef
      set seeI [expr {$gef + 3}]
     # set seeI [expr {$gef }]
      if {$seeI >= $len} {set seeI $gef}
      $w see $seeI
      set ::inspector::lastSee($liste) $idx
      if {$liste eq "Widget"} {
         SelectWidget
      } else {
         SelectListe -liste $liste -index $gef
      }
      return
   } else {
      set ::inspector::lastSee($liste) 0
      set ::inspector::pattOld($liste) $pattern
   }
   
   # nicht blättern
   # 
   if {$liste eq "Widget"} {
      set items [$w get 0 end]
   } else {
      set items $gd($liste,inhalt)
   }
   
   $w selection clear 0 end
   
   set ::inspector::ids($liste) \
      [lsearch -all -nocase -glob $items "*$pattern*"]
 
   if {$::inspector::ids($liste) < 0 } {
      set gd(status) "<$pattern> nicht gefunden"
      $wEntry configure -background red
      set ::inspector::pattOld($liste) {}
      set ::inspector::lastSee($liste) 0
      return
   }
   
   $wEntry configure -background white
   set gd(status) "<$pattern> [llength $::inspector::ids($liste)]x gefunden"
   set gef [lindex $::inspector::ids($liste) 0]
 
   $w selection set $gef
   set seeI [expr {$gef + 3}]
   #set seeI [expr {$gef }]
 
   if {$seeI >= $len} {set seeI $gef}
   $w see $seeI
 
   if {$liste eq "Widget"} {
      SelectWidget
   } else {
      SelectListe -liste $liste -index $gef
   }
}


#--------------------------------------------------------------------
proc ClearPat {} {
   # löscht die Eingabe im Suchfeld, setzt den Focus
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set liste  [$wv(w,nb) raise]
   
   set gd(status) {}
   set wv(v,en,find,$liste) {}
   $wv(w,en,find,$liste) configure -background white
   focus $wv(w,en,find,$liste)
}

#----------------------------------------------------------------------
proc PopupListe {lb x y} {
   # Pupup-Menu für alle Listen
   # ------------------------------------------------------------------
   global wv
   set xp [winfo pointerx .]
   set yp [winfo pointery .]
   
   set liste [$wv(w,nb) raise]
   set item ""
   set sel [$lb selection get]
   if {$sel ne ""} {
      set item [$lb itemcget $sel -text]
   }
   
   # Menu
   set menuName .valueMenu
   catch {destroy $menuName}
   set menubar [menu $menuName -tearoff 0 -borderwidth 2 -relief ridge]
   
   $menubar add command -label {Anzeigefilter ändern} \
      -command [list FilterDialog]
   $menubar add separator
   $menubar add command -label {Update Liste} \
      -command [list UpdateListe $liste]
   
   if {$liste eq "Proc"} {
      $menubar add separator
      $menubar add command -label {Trace Proc ENTER} \
         -command [list TraceStart $item execution enter]
      $menubar add command -label {Trace Proc LEAVE} \
         -command [list TraceStart $item execution leave]
   }
   if {$liste eq "Global"} {
      $menubar add separator
      $menubar add command -label {Trace Variable} \
         -command [list TraceDialog]
   }
   if {$liste eq "Image"} {
      $menubar add separator
      $menubar add command -label {Show Image} \
         -command [list ShowImage $item]
   }
   if {$liste eq "Font"} {
      $menubar add separator
      $menubar add command -label {Show Font} \
         -command [list ShowFont $item]
   }
   if {$liste eq "Canvas"} {
      $menubar add separator
      $menubar add command -label {ID/Tag Tree} \
         -command [list ::Canvas::displayTree]
      $menubar add separator
      $menubar add command -label {IDs im Rechteck Start} \
         -command [list ::Canvas::canvasIDInRect Start]
      $menubar add command -label {IDs im Rechteck Stop} \
         -command [list ::Canvas::canvasIDInRect Stop]
      $menubar add separator
      $menubar add command -label {Enter ID mit Maus Start} \
         -command [list ::Canvas::enterID Start]
      $menubar add command -label {Enter ID mit Maus Stop} \
         -command [list ::Canvas::enterID Stop]
   }
   if {$liste eq "Quelle"} {
      $menubar add separator
      $menubar add command -label {Source} \
         -command [list SourceQuelle]
   }
   tk_popup $menubar $xp $yp
}
#-------------------------------------------------------------------
proc ListPackages { {pattern *}} {
   # listet  die erreichbaren Packages
   # Force the package loader to do its thing:
   # NOTE: this depends on a side effect of the
   # built-in [package unknown].  Other [package unknown]
   # handlers might not meet our expectations.
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   
   set outListe {}
   foreach package [lsort [SendSyn -- package names]] {
      if {![string match $pattern $package]} { continue }
      foreach version [SendSyn -- "package" versions $package] {
         set present [expr {
            [string compare $version [SendSyn -- "package" provide $package]]
            ? " " : "+" }]
         set ifneeded \
            [string replace \
            [string trim \
            [string map {"\n" " " "\t" " "} \
            [SendSyn -- "package" ifneeded $package $version]]] \
            200 end "..."]
         lappend outListe \
            [list $present $package $version $ifneeded]
      }
   }
   
   # noch sortieren
   set outListe [lsort -index 1 $outListe]
   
   ::widgets::tw $wv(w,top).pl           \
      -titel "Packages von <$gd(target)>"    \
      -namen {Used Package Version ifneeded} \
      -widget    tablelist  \
      -buttonbox 0          \
      -geometry  780x440    \
      -matrix    $outListe
}

#--------------------------------------------------------------------
proc ListAutoPath {} {
   # listet 'auto_path im TopText
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set autopath [SendSyn -- set ::auto_path]
   # sortieren
   set autopath [lsort $autopath]
   
   set out [::utils::printlistestring autopath]
   ::widgets::tw $wv(w,top).lap  \
      -titel "Auto_path von $gd(target)" \
      -widget    text     \
      -buttonbox 0        \
      -geometry  780x440  \
      -text      $out
}
#--------------------------------------------------------------------
proc ListTMPath {} {
   # listet 'tcl::tm::path im TopText
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set tmpath [SendSyn -- ::tcl::tm::path list]
   # sortieren
   set tmpath [lsort $tmpath]
   
   set out [::utils::printlistestring tmpath]
   ::widgets::tw $wv(w,top).ltmp  \
      -titel "tm::path von $gd(target)" \
      -widget    text     \
      -buttonbox 0        \
      -geometry  780x440  \
      -text      $out
}
#--------------------------------------------------------------------
proc ListLoaded {} {
   # zeigt 'info loaded' im TopText
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   
   set pliste [SendSyn -- info loaded]
   
   set out {}
   foreach p $pliste {
      lassign $p path modul
      append out "\n$path ->$modul"
   }
   ::widgets::tw $wv(w,top).lload  \
      -widget text \
      -buttonbox 0                        \
      -titel "info loaded von $gd(target)" \
      -text $out
}

#--------------------------------------------------------------------
proc FilterDialog {} {
   # Dialog zum Filtern der gezeigten Listenelemente
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   
   # Dialog kreiern
   set p $wv(w,top)
   catch {destroy $p.filterDlg}
   set dlg [Dialog $p.filterDlg  \
      -modal none             \
      -parent $p              \
      -title "Liste filtern"  \
      -separator true         \
      -anchor w               \
      ]
   set f [$dlg getframe]
   set tf [TitleFrame $f.tf1 -text Pattern]
   pack $tf -fill x -expand 1
   set fr [$tf getframe ]
   set en [::utils::gui::mkEntry wv $fr en,filter]
   pack $en -padx 3 -pady 3 -fill x -expand 1
   
   set fr2 [frame $fr.fr2 -relief flat -borderwidth 0]
   pack $fr2 -padx 0 -pady 0 -fill both -expand 1
   
   set frl [frame $fr.l -relief flat -borderwidth 0]
   pack $frl -padx 0 -pady 0 -fill both -expand 1 -side left
   set frr [frame $fr.r -relief flat -borderwidth 0]
   pack $frl -padx 0 -pady 0 -fill both -expand 1 -side left
   
   # Pattern LB
   set liste [$wv(w,nb) raise]
   set lb [listbox $fr.lb]
   $lb delete 0 end
   foreach li $gd($liste,filter) {
      $lb insert end $li
   }
   pack $lb -padx 3 -pady 3 -fill both -expand 1
   # Knöpfe
   set incl [radiobutton $frl.incl -text "Include Pattern" \
      -value incl -variable gd($liste,inclExcl)]
   set excl [radiobutton $frl.excl -text "Exclude Pattern" \
      -value excl -variable gd($liste,inclExcl)]
   set add [::utils::gui::mkButton wv $frl bt,addfilter  \
      -text "Add Pattern" \
      -command [list FilterAddPat $lb $en $liste]]
   set del [::utils::gui::mkButton wv $frl bt,delfilter \
      -text "Delete Pattern" \
      -command [list FilterDelPat $lb $liste]]
   set apl [::utils::gui::mkButton wv $frl bt,aplfilter \
      -text "Apply" -command [list UpdateListe $liste]]
   pack $incl $excl $add $del $apl -padx 3 -pady 3 -fill x
   
   bind $en <Return> [list FilterAddPat $lb $en $liste]
   $dlg draw
}
#--------------------------------------------------------------------
proc FilterAddPat {lb en liste} {
   # Dialog zum Filtern der gezeigten Listenelemente
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   set gd(status) ""
   set pat [$en get]
   lappend gd($liste,filter) $pat
   $lb insert end $pat
   set gd(status) "Filter <$pat> hinzu gefügt"
}
#--------------------------------------------------------------------
proc FilterDelPat {lb liste} {
   # Dialog zum Filtern der gezeigten Listenelemente
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   set gd(status) ""
   set idx [$lb curselection]
   if {$idx eq ""} {
      set gd(status) "bitte Filter zum Löschen selektieren"
      return
   }
   set pat [$lb get $idx]
   $lb delete $idx
   set gd($liste,filter) [$lb get 0 end]
   set gd(status) "Filter <$pat> gelöscht"
   
}
#--------------------------------------------------------------------
proc FilterListe {liste} {
   # Dialog zum Filtern der gezeigten Listenelemente
   #--------------------------------------------------------------------
   global wv gd
   #_proctrace
   set pats $gd($liste,filter)
   set inclexcl $gd($liste,inclExcl)
   #puts "liste $liste pats:$pats\n$inclexcl"
   set neueListe {}
   if {$inclexcl=={incl}} {
      foreach pat $pats {
         foreach item $gd($liste,inhalt) {
            if {[regexp -- $pat $item ]} {
               lappend neueListe $item
            }
         }
      }
      return $neueListe
   }
   if {$inclexcl=={excl}} {
      foreach item $gd($liste,inhalt) {
         set include 1
         foreach pat $pats {
            if {[regexp -- $pat $item ]} {
               set include 0
            }
         }
         if {$include} { lappend neueListe $item }
      }
      return $neueListe
   }
}
#-----------------------------------------------------------------------
proc ShowDict {txtwidget x y} {
   # zeigt ein dict im TL an
   #-----------------------------------------------------------------------
   #_proctrace
   global gd wv
   set txt [$txtwidget get 1.0 end]
   
   # akt. Zeile
   set pos   [$txtwidget index @$x,$y]
   set zeile [$txtwidget get "$pos linestart" "$pos lineend"]
   
   # Zeile splitten : set var wert
   lassign [split $zeile] kom var wert
   #puts "dict:w:$wert v:$var \nz:$zeile"
   set dict ::[SendSyn --  set $var]
   
   # Anzeige mit printdictstring
   set str [::utils::printdictstring $dict]
   ::widgets::tw $wv(w,top).dict \
      -text     $str         \
      -widget   text         \
      -geometry 850x800      \
      -titel    "Dictionary $var" 
   return
   
}


#-----------------------------------------------------------------------
proc ShowList {txtwidget x y} {
   # zeigt ein Liste im TL an
   #-----------------------------------------------------------------------
   #_proctrace
   global gd wv
   
   # akt. Zeile
   set txt [$txtwidget get 1.0 end]
   set pos [$txtwidget index @$x,$y]
   set zeile [$txtwidget get "$pos linestart" "$pos lineend"]
   
   set wert [lassign [split $zeile] dum var]
   set str [::utils::printlistestring wert]
   
   set tl [::widgets::tw $wv(w,top).shlist \
      -widget    text     \
      -text      $str     \
      -titel     "Liste  < $var >"  \
      -buttonbox 0        \
      -geometry  800x600  \
      -multi     0        \
      ]
}


#--------------------------------------------------------------------
proc ShowImage {image} {
   # Image selektieren und anzeigen
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set lb $wv(w,lb,Image)
   if {$image eq ""} {
      ::utils::gui::msgow1 "Bitte Zeile auswählen"
      return
   }
   
   set imageName $image
   set nr [incr gd(imageNr)]
   
   lassign [winfo pointerxy $wv(w,top)] newX newY
   set w .tkinspect_image$nr
   
   set imgScript "
   toplevel $w
   wm geometry $w +$newX+$newY
   label $w.img -image $imageName -relief groove -padx 4 -pady 4
   frame $w.bf -relief raised
   button $w.bf.close -text \"$imageName\" -command \"destroy $w\"
   pack $w.img  -padx 3 -pady 3
   pack $w.bf -fill x -expand yes -padx 0 -pady 0
   pack $w.bf.close -fill x  -padx 3 -pady 3
   wm title $w \"inspector $imageName\"
   "
   Bwsend $gd(target) [list $imgScript]
}
#--------------------------------------------------------------------
proc ShowFont { font } {
   # Font selektieren und anzeigen
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set lb $wv(w,lb,Font)
   if {$font eq ""} {
      ::utils::gui::msgow1 "Bitte Zeile auswählen"
      return
   }
   set fontName $font
   set nr [incr gd(fontNr)]
   
   lassign [winfo pointerxy $wv(w,top)] newX newY
   
   set w .tkinspect_font$nr
   set fontScript "
   toplevel $w
   wm geometry $w +$newX+$newY
   frame $w.bf -relief raised
   button $w.bf.close \
      -text \"so sieht Font <$fontName> aus\" \
      -font $fontName \
      -command \"destroy $w\"
   pack $w.bf -fill x -expand yes -padx 0 -pady 0
   pack $w.bf.close -fill x  -padx 3 -pady 3
   wm title $w \"inspector $fontName\"
   "
   Bwsend $gd(target) [list $fontScript]
}

#--------------------------------------------------------------------
proc SourceQuelle {} {
   # Quelle selektieren und sourceb
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   set lb $wv(w,lb,Quelle)
   set sel [$lb selection get]
   if {$sel=={}} {
      ::utils::gui::msg info Hinweis "Quelle in Liste selektieren!" $lb
      return
   }
   set quelle [$lb itemcget $sel -text]
   _leer $quelle return
   
   # Dir ergänzen
   SendSyn --  source [file join $::scriptDirMain $quelle]
   set gd(status) "source $quelle"
   
   # ProcListe aktualisieren
   UpdateListe Proc
}
#-----------------------------------------------------------------------
proc CBInfoShow {liste} {
   # nimmt Daten vom Testling entgegen, Anzeige in einem Textpopup
   # und sucht Proc in den quellen (FIF)
   # liste : {{typ callback} ... }
   # typ  ist option oder event
   #-----------------------------------------------------------------------
   #_proctrace
   global wv gd
   
   if {[llength $liste] == 0} {return}
   
   set topw [::widgets::tw $wv(w,top).cbinfosh \
      -widget text \
      -- -wrap none ]
   set txt [$topw winfo text]
   
   # Tags
   $txt tag configure titel -font TkHeadingFont
   $txt tag configure cmd -background white -foreground blue
   
   set proc ""
   # bind liefern u.U. mehrere Callbacks
   foreach li $liste {
      lassign $li typ callback
      set ele [split $callback]
      set proc [lindex $ele 0]
      set args [lrange $ele 1 end]
      $txt insert end $typ titel \n\n
      $txt insert end "Proc: "
      $txt insert end $proc {titel cmd} \n
      $txt insert end "Args: $args\n\n"
   }
   
   # in der ProcListe suchen
   #
   $wv(w,nb) raise Proc
   set wv(v,en,find,Proc) $proc
   $wv(w,bt,find,Proc) invoke
   
   return
}
#-----------------------------------------------------------------------
proc PSInfo {} {
   # zeigt ps-Informationen vom Testling
   #-----------------------------------------------------------------------
   #_proctrace
   global gd wv
   
   if {$gd(target)=={}} {
      ::utils::gui::msg error SendFehler "kein Testziel vorhanden"
      return {}
   }
   
   set psListe [list \
      pid 	PID 	"a number representing the process ID " \
      user 	USER 	"effective user name.\nThis will be the textual user ID, if it can be obtained and the field width permits,\nor a decimal representation otherwise.."\
      pcpu 	CPU 	"cpu utilization of the process .\nCurrently, it is the CPU time used divided by the time the process has been running\n(cputime/realtime ratio), expressed as a percentage." \
      time 	TIME 	"cumulative CPU time, DD-HH:MM:SS format."\
      s 	S 	"minimal state display (one character).\nD uninteruptible sleep (usually IO)\nR running or runable\nS interruptible sleep\nT stopped by job control\nt stopped by debugger\nW paging\nX dead\nZ zombie"\
      etime 	ELAPSED 	"elapsed time since the process was started, in the form DD-hh:mm:ss."\
      rss 	RSS 	"resident set size, the non-swapped physical memory\nthat a task has used (in MegaBytes).."\
      vsz  VSZ  " The total size of the process in virtual memory, in Megabytes."\
      pmem 	%MEM 	"ratio of the process's resident set size to the physical memory on the machine,\nexpressed as a percentage. "\
      args COMMAND "command with all its arguments as a string. "\
      ]
   
   # ps-Optionen aufbereiten
   set opts ""
   set headers ""
   set tooltips ""
   foreach {opt header tooltip} $psListe {
      lappend opts     $opt
      lappend headers  $header
      lappend tooltips $tooltip
   }
   
   #ps-Kommando
   set optsStr [join $opts ,]
   set pid [SendSyn -- pid] ;# pis vom Testling
   set psKdo "exec ps -o $optsStr -p $pid"
   
   puts $psKdo
   
   set psInfo [SendSyn -- $psKdo]
   #puts $psInfo
   
   # Textzeile ausblenden
   set psStr [lindex [split $psInfo "\n"] end]
   
   # mehrere Blanks zusammenfassen
   set psStr [::utils::oneblank [join $psStr]]
   set werte [split $psStr]
   
   # der letzte Wert (args hat Blanks)
   set anz [llength $opts]
   incr anz -1
   
   set erg [list]
   for {set i 0} {$i < $anz} {incr i} {
      set o [lindex $opts $i]
      set w [lindex $werte $i]
      
      # rss in MByte
      if {$o eq "rss" || $o eq "vsz"} {
         set w [format %.2f [expr {$w / 1024.0}]]
      }
      set t [lindex $tooltips $i]
      lappend erg [list $o $w $t]
   }
   
   
   # args hat Blanks
   set comm [lrange $werte $anz end]
   lappend erg [list args {} $comm ]
   
   #::utils::printliste erg
   
   # TL-Tabelle mit ps-Protokoll
   set top [::widgets::tw $wv(w,top).lps \
      -titel    "ps-Info  $gd(target)"  \
      -multi    true       \
      -geometry 800x500    \
      -widget   tablelist  \
      -namen {Parameter Wert Erklärung} \
      -matrix $erg]
   
   return
}
#-----------------------------------------------------------------------
proc ShowProcs {textW} {
   # zeigt alle Procs
   # Gerufen im Valuefeld der Liste Quelle
   #-----------------------------------------------------------------------
   #_proctrace
   global gd wv
   
   # Label zeigt 'Quelle - Name'
   set lab $wv(w,lab,val,Quelle)
   if {![winfo exists $lab]} {return}
   
   set titel [$lab cget -text]
   lassign [split $titel] dum dum1 pfad
   set pfad [file tail $pfad]
   
   # im Textwidget nach proc-Zeilen suchen
   set all [$textW search -all \
      -regexp {(proc|method)\s+([^ ]+)\s+.*\{.*$}  1.0 end ]
   if {$all eq ""} {return}
   
   # Proczeile detailliert prüfen und ProcNamen entnehmen
   set procs {}
   foreach pos $all {
      set procZeile [$textW get "$pos linestart" "$pos lineend"]
      if {[regexp -expanded -- {^\s*
            (proc|method)\s+
            ([^ ]+)\s+		      # ProcName
            .*\s+		           # Parameter
            \{.*$		           # öffnede Klammer Body, ggf Folgezeile
         } $procZeile dum pm pn]} {
         lappend procs [list $pn $pos]
      } else {
         continue
      }
   }
   
   # procs sortieren
   set procs [lsort -index 0 $procs]
   
   # Toplevel Listbox anzeigen
   #
   set tl [::widgets::tw $wv(w,top).proc \
      -titel     "Procs $pfad"  \
      -multi     false  \
      -buttonbox 0      \
      ]
   wm geometry $tl [::utils::gui::geoObenRechts $wv(w,top)]
   
   set fr [$tl winfo frame]
   set lbox [ListBox $fr.lb -deltay 25 -relief ridge -selectmode single]
   pack $lbox -padx 3 -pady 3 -fill both -expand 1 -anchor n
   
   $lbox bindText <ButtonRelease-1> [list SelectProcInLB $lbox $textW]
   
   # Listbox füllen mit Name und pos
   foreach el $procs {
      lassign $el na pos
      $lbox insert end #auto -text $na -data $pos
   }
   return
}
#-----------------------------------------------------------------------
proc SelectProcInLB  {lbox textW args} {
   # positioniert die angewählte Proc im Textfeld Value
   # lbox  : Listbox mit Prozeduren
   # textW : Textwidget im Valuefeld Liste Quelle
   # args  : sel. Index in der Listbox
   #-----------------------------------------------------------------------
   #_proctrace
   
   set index $args
   set pos [$lbox itemcget $index -data]
   $textW see $pos
   return
}