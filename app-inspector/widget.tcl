## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "widget.tcl"
 #  Description:
 #  enthält Proz. des Widgetregisters
 #
 # ###################################################################

#-----------------------------------------------------------------------
proc CreateWidgetListe {nb liste} {
   # erzeugt die obere Hälfte vom Widgetregister
   # liste : Register {Widget Proc ....}
   #-----------------------------------------------------------------------
   global gd wv
   
   set wv(ic,16,leaf) [image create bitmap \
      -file [file join $::scriptDirMain .. icons leaf.xbm] \
      -background coral -foreground gray50]
   set wv(ic,16,comp) [image create bitmap \
      -file [file join $::scriptDirMain .. icons comp.xbm] \
      -background yellow -foreground gray50]
   
   # ----------------- PanedWindow: o: WidgetTree u: Konfig.
   #
   set fr [$nb getframe $liste]
   set erg [::utils::gui::mkPanedWindow wv $fr "" \
      -wts {7,5} -richt -]
   lassign $erg pw fo fu
   $fo configure -borderwidth 4 -relief ridge
   $fu configure -borderwidth 4 -relief ridge
   pack $pw -padx 0 -pady 0 -fill both -expand yes
   set wv(w,fr,fu,Widget) $fu
   
   # ------------------ Findbereich Tree
   #
   set ff [frame $fo.find -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $ff -padx 0 -pady 0 -fill x -expand 0 -side bottom
   
   # FindButton
   set btfind [::utils::gui::mkButton wv $ff bt,find,$liste \
      -image [::utils::gui::ic 16 edit-find] \
      -borderwidth 2 -relief raised \
      -background skyBlue1]
   pack $btfind -padx 3 -pady 3 -side left
   
   # ClearButton
   set bt [::utils::gui::mkButton wv $ff bt,clear,$liste \
      -image [::utils::gui::ic 16 edit-clear-locationbar-ltr] \
      -borderwidth 2 -relief raised \
      -command ClearPat   \
      -background skyBlue1]
   pack $bt -padx 3 -pady 3 -side left
   
   # Patternentry
   set en [::utils::gui::mkEntry wv $ff en,find,$liste ]
   pack $en -padx 3 -pady 3 -side left -fill x -expand 1
   
   # -------------------- Window Anzeigeoptionen
   #
   set fopt [frame $fo.fopt -relief sunken -borderwidth 1 \
      -background skyblue1]
   pack $fopt -padx 3 -pady 3 -fill x -expand 0 -side top
   
   set nr 1
   foreach wo $gd(winOptsListe) hlp $gd(winOptsHlp) {
      radiobutton $fopt.rb$nr -value $hlp -text $wo \
         -command SelectWidget \
         -variable gd(winOpts) -background skyblue1
      DynamicHelp::add $fopt.rb$nr -text $hlp
      pack $fopt.rb$nr -side left
      incr nr
   }
   
   # -------------------- Widget Baum
   #
   set frtbl [frame $fo.tbl -relief ridge -borderwidth 2]
   pack $frtbl -padx 3 -pady 3 -fill both -expand 1
   set tbl [::utils::gui::mkTable wv $frtbl tbl,tree,$liste \
      -namen {Name Class Window} \
      -- -exportselection 0      \
      -font TkDefaultFont]
   $tbl configure -expandcommand ExpandWidget
   pack $tbl -padx 0 -pady 3 -fill both -expand 1
   
   $btfind configure -command [list ListboxSuche $tbl %N %K $liste]
   
   # Label
   set lab [::utils::gui::mkLabel wv $fu "lab,val,$liste" \
      -relief sunken -background skyblue1 -font TkHeadingFont]
   pack $lab -padx 5 -pady 1 -fill x -expand 0
   
   
   # -------------------- Widget Value Bereich
   #
   set fval [frame $fu.val -relief ridge -borderwidth 1 \
      -background skyBlue1]
   pack $fval -padx 5 -pady 1 -fill x -expand 0 -side top -anchor n
   
   # ValButton
   set bt [::utils::gui::mkButton wv $fval bt,val,$liste \
      -image [::utils::gui::ic 16 mail-forward] \
      -borderwidth 2 -relief raised  \
      -helptext "WindowKonfiguration zum Ziel schicken" \
      -background skyBlue1]
   pack $bt -padx 3 -pady 3 -side left
   
   # ComboBox
   set cb [::utils::gui::mkComboBox wv $fval cb,val,$liste \
      -background skyBlue1 \
      -modifycmd [list ValueUpdate $liste]]
   pack $cb -padx 3 -pady 3 -side right -fill x -expand 1
   set wv(v,cb,val,$liste) ""
   
   # Frame für ValueText/tbl
   set wv(w,fr,fu,Widget) $fu
   
   bind [$tbl bodypath] <ButtonPress-3> [list PopupWidget %W %x %y]
   bind $en <KeyRelease> [list ListboxSuche $tbl %N %K $liste ]
   bind [$tbl bodypath] <ButtonRelease-1> [list SelectWidget -x %x -y %y]
   bind [$tbl bodypath] <Control-ButtonRelease-1> [list SelectWidget -x %x -y %y -top 1]
   
   #bind $txt <Control-s> [list SendValue]
   
   
   #------------------------------------------------------------------------------
   proc ExpandWidget {tbl row} {
      # Outputs the data of the children of the widget whose leaf name is displayed
      # in the first cell of the specified row of the tablelist widget tbl, as child
      # items of the one identified by row.
      #------------------------------------------------------------------------------
      if {[$tbl childcount $row] == 0} {
         set w [$tbl rowattrib $row pathName]
         PutChildren $w $tbl $row
      }
   }
   
   #------------------------------------------------------------------------------
   proc PutChildren {w tbl nodeIdx} {
      # Outputs the data of the children of the widget w into the tablelist widget
      # tbl, as child items of the one identified by nodeIdx.
      #------------------------------------------------------------------------------
      #
      #puts "PutCildren $nodeIdx $w"
      global wv
      if {[string compare $nodeIdx "root"] == 0} {
         $tbl delete 0 end
         set row 0
      } else {
         set row [expr {$nodeIdx + 1}]
      }
      
      # Display the data of the children of the
      # widget w in the tablelist widget tbl
      #
      foreach c $::inspector::widgetTree($w) {
         #
         # Insert the data of the current child into the tablelist widget
         #
         set item {}
         set name [lindex [split $c "."] end]
         # #Name auslassen
         if {[string match {#*} $name]} {continue}
         lappend item $name $::inspector::widgetClasses($c) $c
         $tbl insertchild $nodeIdx end $item
         
         #
         # Insert an image into the first cell of the row; mark the
         # row as collapsed if the child widget has children itself
         #
         if {[llength $::inspector::widgetTree($c)] == 0} {
            $tbl cellconfigure $row,0 -image [::utils::gui::ic 16 leaf]
         } else {
            $tbl cellconfigure $row,0 -image [::utils::gui::ic 16 comp]
            $tbl collapse $row
         }
         
         $tbl rowattrib $row pathName $c
         incr row
      }
   }
   
}

#--------------------------------------------------------------------
proc SelectWidget {args} {
   # wird gerufen, wenn
   # - in den Widgettree geklickt wird
   # - Triggerselect  vom Testling
   # - Aufruf aus ValueCBox
   # - Suchen im Widgettree
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   if {$gd(target) eq ""} {return}
   ::Opt::opts par $args {
      { -x        {}    "x-Kooordinate" }
      { -y        {}    "y-Kooordinate" }
      { -top      {0}   "Anzeige als Tl" }
      { -widget   {}    "Widgetname von Triggerselect" }
   }
   set window $par(-widget)
   set x      $par(-x)
   set y      $par(-y)
   set top    $par(-top)
   
   set Filter_Empty_Window_Options $::inspector::Filter_Empty_Window_Options
   set Filter_Window_Class_Options $::inspector::Filter_Window_Class_Options
   set Filter_Pack_Options         $::inspector::Filter_Pack_Options
   set winOpts $gd(winOpts)
   
   set tbl $wv(w,tbl,tree,Widget)
   
   # Widget aus Selektion oder x,y nehmen
   if {$window eq ""} {
      if {$x != {}} {
         lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
         set inh [$tbl get $zeile]
         lassign $inh name class window
      } else {
         set sel [$tbl curselection]
         if {$sel !={}} {
            set inh [$tbl get $sel]
            lassign $inh name class window
         }
      }
   } else {
      # Window im Tree suchen
      $tbl selection clear 0 end
      set row [lsearch -exact -index 2 [$tbl get 0 end] $window]
      #_leer $row return
      if {$row == -1} {
         ::utils::gui::msg info Update \
            "Widget nicht vorhanden\nggf Liste aktualisieren"
         return
      }
      
      $tbl selection set $row
      $tbl see $row
      lassign [$tbl get $row] name class windowI
      $wv(w,nb) raise Widget
   }
   
      # selektiertes Widget blinkt
   #
   SendSyn -- ::inspector_testling::flashWidget $class $window

   
   if {$window eq ""} {
      ::utils::gui::msg info Update \
         "Widget nicht vorhanden\nggf Liste aktualisieren"
      return
   }
   set ret [SendSyn -- winfo exists $window]
   if {!$ret} {
      ::utils::gui::msg info Update \
         "Widget nicht vorhanden\nggf Liste aktualisieren"
      return
   }
   set result {}
   ::utils::gui::setClock on $tbl
   
   # Switch mit Anzeige Optionen
   #
   switch -- $winOpts {
      Configuration  {
         # siehe WidgetOptionen
      }
      
      Packing  {
         set result ";# packing info for [list $window]\n"
         set info [SendSyn -noerr 1  -- pack info $window]
         if {[string match {*isn't packed*} $info]} {set info ""}
         if {$info ne ""} {
            append result "pack configure [list $window]"
            set len [llength $info]
            for {set i 0} {$i < $len} {incr i 2} {
               append result " \\\n\t[lindex $info $i] [lindex $info [expr {$i+1}]]"
            }
            append result "\n"
         } else {
            append result ";# window \"$window\" isn't packed"
         }
         # -in ausblenden
         if {$Filter_Pack_Options} {
            regsub -all "(\n)\[ \t\]*-in\[ \t\]+\[^ \\\n\]*\n?" $result \
               "\\1" result
         }
      }
      
      Slave_Packing  {
         set result ";# packing info for slaves of [list $window]\n"
         set slaves [SendSyn -- pack slaves $window]
         foreach slave $slaves {
            set info [SendSyn -noerr 1 -- pack "info" $slave]
            if {[string match {*isn't packed*} $info]} {set info ""}
            if {$info ne ""} {
               append result "pack configure [list $slave]"
               set len [llength $info]
               for {set i 0} {$i < $len} {incr i 2} {
                  append result " \\\n\t[lindex $info $i] [lindex $info [expr {$i+1}]]"
               }
               append result "\n"
            } else {
               append result ";# slave \"$slave\" isn't packed"
            }
         }
         # -in ausblenden
         if {${Filter_Pack_Options}} {
            regsub -all "(\n)\[ \t\]*-in\[ \t\]+\[^ \\\n\]*\n?" $result \
               "\\1" result
         }
      }
      
      Style  {
         set result ";# Style of [list $window]\n"
         if {$class ni $gd(tileClasses) } {
            append result "#[list $window] ist kein TileWidget\n"
         } else {
            set tags [SendSyn -- ttk::style configure $window]
            _leer $tags {
               append result "# [list $window] = {}\n"
               append result "# class $class\n"
            }
            set confgs [SendSyn -- ttk::style configure $class]
            append result "ttk::style configure $class"
            set nr 0
            foreach k $confgs {
               set key [lindex $confgs $nr]
               _leer $key {continue}
               incr nr
               set val [lindex $confgs $nr]
               incr nr
               append result " \\\n\t$key [list $val]"
            }
            _leer $confgs {append result "  {}"}
         }
      }
      
      Layout  {
         set result ";# Layout of [list $window]\n"
         if {$class ni $gd(tileClasses) } {
            append result "#[list $window] ist kein TileWidget\n"
         } else {
            append result "# class $class\n"
            set lay [SendSyn -- ttk::style layout $class]
            append result  "ttk::style layout $class {\n\t "
               regsub -all -- {-children} $lay "-children\n\t" lay
               if {$lay != {}} {append result $lay}
               append result "\n}"
         }
      }
      
      Map  {
         set result ";# Style Map of [list $window]\n"
         if {$class ni $gd(tileClasses) } {
            append result "#[list $window] ist kein TileWidget\n"
         } else {
            append result "# class $class\n"
            set lay [SendSyn -- ttk::style map $class]
            append result  "ttk::style map $class {\n\t "
               if {$lay != {}} {append result $lay}
               append result "\n}"
         }
      }
      
      {Element_Opts}  {
         set result ";# Element Options of [list $window]\n"
         if {$class ni $gd(tileClasses) } {
            append result "#[list $window] ist kein TileWidget\n"
         } else {
            append result "# class $class\n"
            set elemente [GetClassElemente $class]
            foreach ele $elemente {
               append result "# Element: $ele \n"
               set options [SendSyn -- ttk::style element option $ele]
               foreach opt $options {
                  set val [SendSyn -- ttk::style lookup $class $opt]
                  _leer $val {continue}
                  append result "\tttk::style configure $class  $opt [list $val]\n"
               }
            }
         }
      }
      
      BindtagsBind  {
         set result ";# bindtags of [list $window]\n"
         set tags [SendSyn -- bindtags $window]
         append result [list bindtags $window $tags]
         append result "\n# bindings (in bindtag order)..."
         foreach tag $tags {
            append result "\n#<$tag> "
            foreach sequence [SendSyn -- bind $tag] {
               append result "\n   #sequence"
               append result "\n    bind $tag $sequence "
               append result [SendSyn -- bind $tag $sequence]
            }
         }
         append result "\n"
      }
      
      Bindings  {
         set result ";# bindings of [list $window]\n"
         foreach sequence [SendSyn -- bind $window] {
            append result "\nbind $window $sequence \\"
            append result "\n\t"
            append result [list [SendSyn -- bind $window $sequence]]
         }
         append result "\n"
      }
      
      {Bindtags}  {
         set result ";# bindtags of [list $window]\n"
         set tags [SendSyn -- bindtags $window]
         append result [list bindtags $window $tags]
         append result "\n"
      }
      
      {Class_Bind}  {
         set result ";# class bindings for $window"
         append result "\n# class: $class\n"
         foreach sequence [SendSyn -- bind $class] {
            append result "\nbind $class $sequence  \{"
            append result [SendSyn -- bind $class $sequence]
            append result "\}"
         }
         append result "\n"
      }
   }
   
   #
   # Result in textWidget oder Toptext schreiben
   #
   if {$top && $winOpts ne {Configuration}} {
      ValueTL $result -liste Widget -item $window
   } else {
      # Value Label
      set wv(v,lab,val,Widget) "$name ($class) $window"
      
      set fu $wv(w,fr,fu,Widget)
      catch {destroy $fu.fr}
      set fr [frame $fu.fr -relief flat -borderwidth 0]
      pack $fr -padx 0 -pady 0 -fill both -expand 1
      
      set wv(w,txt,val,Widget) ""
      set wv(w,tbl,val,Widget) ""
      if {$winOpts == {Configuration}} {
         WidgetOptionen $fr $window
         $wv(w,bt,val,Widget) configure \
            -command [list EvalOptionen $window ]
      } else {
         set txtWidget [::utils::gui::mkText wv $fr txt -wrap none]
         set wv(w,txt,val,Widget) $txtWidget
         $txtWidget delete 0.0 end
         $txtWidget insert end $result
         ::syntaxhighlight::highlight $txtWidget
         $wv(w,bt,val,Widget) configure \
            -command [list SendValue ]
         set mainNB $wv(w,nb)
         bind $txtWidget  <ButtonPress-3> [list PopupValue $mainNB %W %x %y]
      }
   }
   
   # in 'send Value' ComboBox Value eintragen
   #
   if {$winOpts == {Configuration}} {
      set liste {Widget}
      set item $window
      set wCbValue $wv(w,cb,val,$liste)
      set vals [$wCbValue cget -values]
      if {"$liste $item" ni $vals} {
         $wCbValue configure       \
            -values [lappend vals "$liste $item"]
      }
      set wv(v,cb,val,$liste) "$liste $item"
   }
   
   # selektiertes Widget blinkt
   #
#   SendSyn -- ::inspector_testling::flashWidget $class $window
   ::utils::gui::setClock off $tbl
   
}
#--------------------------------------------------------------------
proc WidgetOptionen {p window} {
   # zeigt WindowOptionen in einer Tabelle
   #--------------------------------------------------------------------
   global wv gd
   ##_proctrace
   
   #--------------------------------
   proc FormatCmd {args} {return ""}
   
   #--------------------------------
   proc TooltipAddCmdOpt {tbl row col} {
      ##nagelfar variable fullText
      if {$col == 2 && $row >= 0} {
         set tt [$tbl cellattrib $row,$col tt]
         if {$tt ne ""} {
            DynamicHelp::add $tbl -text $tt
         }
         return
      }
      if {$col == 2 && $row >= 0} {
         set tt [$tbl cellcget $row,$col -text]
         if {$tt ne ""} {
            DynamicHelp::add $tbl -text $tt
         }
         return
      }
      if {($row >= 0 && [$tbl iselemsnipped $row,$col "fullText"]) ||
         ($row <  0 && [$tbl istitlesnipped $col "fullText"])} {
         regsub -all -- {\\nl} $fullText "\n" fullText
         DynamicHelp::add $tbl -text $fullText
      }
   }
   
   #--------------------------------
   proc CreateButton {tbl row col w } {
      global wv
      lassign [$tbl get $row] option wert default class entryTyp args
      switch -exact -- $entryTyp  {
         Fonttype  {
            button $w -image [::utils::gui::ic 16 preferences-desktop-font16] \
               -command [list ChooseFont $tbl $row ?] \
               -text {} -compound left  \
               -padx 2m -pady 0 -font $wert
            ChooseFont $tbl $row $wert
         }
         Colortype  {
            button $w -image [::utils::gui::ic 16 fill-color16]  \
               -command [list ChooseColor $tbl $row ?] \
               -text {} -compound left  \
               -padx 2m -pady 0 -font TkFixedFont
            # Zelle einfärben
            ChooseColor $tbl $row $wert
         }
         default {}
      } ; # end switch
   }
   
   #--------------------------------
   proc CreateComboBox {tbl row col w } {
      global wv gd
      lassign [$tbl get $row] option wert default class entryTyp args
      if {$entryTyp eq "Cursortype"} {set args $gd(cursors)}
      set value $wert
      ComboBox $w -values $args  -text $value \
         -modifycmd [list CSBoxEdit $w $tbl $row $col]
   }
   
   #--------------------------------
   proc CreateSpinBox {tbl row col w } {
      global wv gd
      lassign [$tbl get $row] option wert default class entryTyp args
      SpinBox $w \
         -range {-1000000 100000000 1} \
         -text $wert \
         -modifycmd [list CSBoxEdit $w.e $tbl $row $col]
   }
   
   #--------------------------------
   proc CreateEntry {tbl row col w } {
      global wv gd
      lassign [$tbl get $row] option wert default class entryTyp args
      Entry $w \
         -text $wert \
         -command [list CSBoxEdit $w $tbl $row $col]
   }
   
   #--------------------------------
   proc CSBoxEdit {wEntry tbl row col} {
      set text [$wEntry get]
      $tbl cellconfigure $row,$col -text $text
   }
   
   tablelist::addBWidgetComboBox
   tablelist::addBWidgetEntry
   tablelist::addBWidgetSpinBox
   
   set readOnlies {-container -orientation -sizebox}
   set Filter_Empty_Window_Options $::inspector::Filter_Empty_Window_Options
   set Filter_Window_Class_Options $::inspector::Filter_Window_Class_Options
   set Filter_Pack_Options         $::inspector::Filter_Pack_Options
   set winOpts $gd(winOpts)
   
   # Widget Class und Optionen abfragen
   #
   set widgetClass [SendSyn -- winfo class $window]
   set confgs [SendSyn -- $window configure]
   _leer $confgs return
   set readonly {}
   
   # Tabelle anlegen
   #
   set tbl [::utils::gui::mkTable wv $p "" \
      -tdx $gd(tdOptKonf)       \
      -- -exportselection 0]
   set wv(w,tbl,val,Widget) $tbl
  
   $tbl configure \
      -labelcommand      ""                \
      -movablecolumns    0                 \
      -font              TkDefaultFont     \
      -showeditcursor    0                 \
      -tooltipaddcommand TooltipAddCmdOpt  \
      -exportselection   0                 \
      -labelbackground   SlateGray2        \
      -stripebackground  #e0e8f0           \
      -showseparators    yes               \
      -titlecolumns 1

   $tbl columnconfigure Wert -formatcommand FormatCmd -editable 1
   $tbl columnconfigure Wert -width 22
   
   # Schleife alle Optionen
   #
   foreach opt $confgs {
      if {[llength $opt] <= 2} continue
      lassign $opt option dbname dbclass default wert
      if {$option == {-class}} {continue}
      if {$Filter_Empty_Window_Options && $wert=={}} continue
      if {$option in $readOnlies } {continue}
      
      # inputType inputArgs und tooltip erfragen
      set ele [GetOptsDetails *,*,$widgetClass,$option]
      lassign $ele name dbname cl def inputType inputArgs tooltip
      #set inputType [lindex $ele 3]
      #set inputArgs [lindex $ele 4]
      #set tooltip   [lindex $ele end]
      regsub -all -- {~~} $tooltip "\n" tooltip
   
      # Tabellenzeile bauen und anzeigen
      #
      set zeile [list $option $wert $default $dbclass $inputType \
         $inputArgs]
      $tbl insert end $zeile
      $tbl cellattrib end,2 tt $tooltip
      
      # Eingabemethode nach Inputtyp
      #
      switch -exact -- $inputType  {
         Cursortype -
         Listtype    {
            $tbl cellconfigure end,Wert -window CreateComboBox
            pack [$tbl windowpath end,Wert]
         }
         Integertype {
            $tbl cellconfigure end,Wert -window CreateSpinBox
            pack [$tbl windowpath end,Wert]
         }
         Fonttype    {$tbl cellconfigure end,Wert -window CreateButton}
         Colortype   {$tbl cellconfigure end,Wert -window CreateButton}
         default     {$tbl cellconfigure end,Wert -window CreateEntry}
         
      } ; # end switch
   } ; # Optionen
}


#--------------------------------------------------------------------
proc GetLocWidgetInfo {} {
   # ermittelt alle Widgets incl Kinder und ihre Klasse
   #--------------------------------------------------------------------
   global gd
   #_proctrace
   
   # key:Widget Inhalt: Class
   array unset ::inspector::widgetClasses
   
   # key:Widget Inhalt: Children
   array unset ::inspector::widgetTree
   
   # WidgetInfo remote auf dem Testling ausführen
   # liefert Class und widgetTree
   # mit PrepareInspection im Testling vorbereitet
   
   set erg [SendSyn -- ::inspector_testling::GetWidgetInfo]
   
   # und nun das Array über den Listen Umweg holen
   #  
   set widgetsClassesList \
      [SendSyn --  array get ::inspector_testling::widgetClasses]
   array set ::inspector::widgetClasses $widgetsClassesList
   set widgetsList \
      [SendSyn --  array get ::inspector_testling::widgetTree]
   array set ::inspector::widgetTree $widgetsList
   set gd(Widget,inhalt) 1
   return 0
}

#--------------------------------------------------------------------
proc GetOptsDetails {pat} {
   # liefert det. Infos von allen Optionen eines Widgets
   # Infos werden im Cache gehalten
   # key : toolkit,widget,class,option zB Tk,button,Button-background
   # # wert : {optionName dbname class default inputType inputValue tooltip}
   # inputType:  Entrytype|Cursortype|Floattype|Colortype|Listtype|
   #    Fonttype|Integertype|Floattype
   #--------------------------------------------------------------------
   global gd
   #_proctrace
   
   set keys [array names ::optsArr $pat]
   set key [lindex $keys 0]
   if {[info exists ::optsArr(gelesen)]} {
      if {[info exists ::optsArr($key)]} {
         return $::optsArr($key)
      } else {
         return ""
      }
   }
   # Datei opts.array einlesen
   # Hinweis: die Datei wird mit tcldoc aktualisiert
   #   tcldoc alleoptionen --->tcltkdoc/opts.array
   array unset ::optsArr
   array set ::optsArr [::utils::file::readfile \
      [file join $::scriptDirMain opts.array]]
   
   if {0} {
      # Pseudowidgets ergänzen
      #
      foreach cl {PanedWindow| PanedWindow- NBTab \
            PWPane widgets::tw widgets::lra \
            widgets::entrylb widgets::nbvert widgets::tabfs} {
         foreach option $gd(pseudoOpts,$cl) {
            set optName [lindex $option 0]
            #puts "na:$optName"
            #puts "opts:$option"
            set ::optsArr(pseudo,$cl,$cl,$optName) $option
         }
      }
   }
   
   set ::optsArr(gelesen) 1
   if {[info exists ::optsArr($pat)]} {
      return $::optsArr($pat)
   } else {
      return ""
   }
}
#--------------------------------------------------------------------
proc GetWidgetbyClass {class} {
   # liefert Widgetname passend zur Klasse
   # nicht eindeutig
   #--------------------------------------------------------------------
   
   # Array einlesen
   if {![info exists ::optsArr(gelesen)]} {
      GetOptsDetails *,*,$class,*
   }
   
   set keys [array names ::optsArr *,*,$class,*]
   if {$keys eq ""} {
      return ??
   }
   
   set key [lindex $keys 0]
   lassign [split $key ","] toolkit widget
   return $widget
}

#--------------------------------------------------------------------
proc GetClassElemente {class} {
   # liefert Elemente von TileWidget-Class
   #--------------------------------------------------------------------
   global gd
   #_proctrace
   
   if {$class ni $gd(tileClasses)} {
      return {}
   }
   set layout [SendSyn -- ttk::style layout $class]
   _leer $layout {return {}}
   
   # Hauptname zB Button von TButton
   set hana [string range $class 1 end]
   if {$class eq {Treeview}} {set hana $class}
   set idx 0
   set ele {}
   while {$idx >= 0} {
      set idx [string first $hana $layout $idx]
      #puts $idx
      if {$idx >=0} {
         set blank [string first { } $layout $idx]
         incr blank -1
         lappend ele [string range $layout $idx $blank]
         incr idx
      }
   }
   #puts $ele
   return $ele
}
#--------------------------------------------------------------------
proc InsertWidgetTree {w} {
   # WidgetTree anzeigen
   #--------------------------------------------------------------------
   global wv
   #_proctrace
   
   # nicht bei nogui-Zielen
   if {[SendSyn -- info commands winfo] eq ""} {
      return
   }
   
   # Register vorhanden ?
   set nb $wv(w,nb)
   if {![info exists wv(w,tbl,tree,Widget)]} {CreateWidgetListe $nb Widget}
   
   # holt Class und Kinder von allen Kindern
   #
   if {[GetLocWidgetInfo]} {return}
   PutChildren $w $wv(w,tbl,tree,Widget) root
   $wv(w,tbl,tree,Widget) expandall
   return
}
#------------------------------------------------------------------
proc PopupWidget {tbl_body x y} {
   # PopupMenu für Widget-Register
   #
   set tbl [winfo parent $tbl_body]
   lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
   if {$zeile == -1} {return}
   
   set xp [winfo pointerx .]
   set yp [winfo pointery .]
   
   
   # kein Text ?
   set inh [$tbl get $zeile]
   _leer $inh {return}
   lassign $inh name class window
   
   # Menu
   set menuName .valueMenu
   catch {destroy $menuName}
   set menubar [menu $menuName -tearoff 0 -borderwidth 2 -relief ridge]
   
   $menubar add command -label {aufklappen} \
      -command [list WidgetAufZu $tbl $zeile auf]
   $menubar add command -label {zuklappen} \
      -command [list WidgetAufZu $tbl $zeile zu]
   $menubar add separator
   $menubar add command -label {Lupe} \
      -command [list InsertWidgetTree $window]
   $menubar add separator
   $menubar add command -label {Set Widget} \
      -command [list WidgetSet $window]
   $menubar add separator
   $menubar add command -label {PackManager} \
      -command [list PackmanDialog $window]
   if {$class eq "Text"} {
      $menubar add separator
      $menubar add command -label {TagInfo} \
         -command [list TagInfo $window]
      $menubar add command -label {MarkInfo} \
         -command [list MarkInfo $window]
   }
   
   $menubar add separator
   $menubar add command -label {Update Liste} \
      -command [list UpdateListe Widget]
  # $menubar add command -label {Doku Widget} \
  #    -command [list exec tcldoc -key [GetWidgetbyClass $class] anz &]
   
   tk_popup $menubar $xp $yp
}

proc WidgetAufZu {tbl zeile aufzu} {
   switch -exact -- $aufzu  {
      auf {$tbl expand   $zeile -fully}
      zu  {$tbl collapse $zeile -partly}
      default {  }
   } ; # end switch
   
}

proc WidgetSet {window} {
   # Windget den Alias xyz zuordnen
   #
   global gd
   SendSyn --   set ::xyz $window
   set gd(status) "$window  --> ::xyz"
}

#--------------------------------------------------------------------
proc TriggerSelectWidget {widget x y} {
   # inspector selektiert das widget
   #--------------------------------------------------------------------
   global gd
   #_proctrace
  
   _leer $widget   return
   _leer $gd(target) return
   
   UpdateListe   Widget
   
   # Analyze Stack
   AnalyzeTrace $widget
   SelectWidget   -widget $widget
   
}

#--------------------------------------------------------------------
proc EvalOptionen {win} {
   # Änderungen im Widget-Value ausführen
   #--------------------------------------------------------------------
   global wv gd
   
   set tbl $wv(w,tbl,val,Widget)
   set matrix [$tbl get 0 end]
   
   # Optionen-String bauen
   #
   set confKdo "$win configure \\\n"
   foreach z $matrix {
      lassign $z option wert
      append confKdo "  $option  [list $wert] \\\n"
   }
   
   # Zeilenwechsel am Ende entfernen
   #
   set confKdo [string range $confKdo 0 end-3]
   
   # configure ausführen
   #
   ::utils::gui::setClock on $tbl
   SendSyn -- $confKdo
   set gd(status) "Optionen $win gesendet"
   ::utils::gui::setClock off $tbl
}

#---------------------------------------------------------------
proc PackmanDialog {window} {
   #  PackmanDialog  anzeigen
   #---------------------------------------------------------------
   global wv gd
   #_proctrace
   
   set p $wv(w,top)
   
   catch {destroy $p.pmDlg}
   set topPM [toplevel $p.pmDlg]
   wm title $topPM PackManager
   
   set fr1 [frame $topPM.fr1 -relief flat -borderwidth 0]
   pack $fr1 -padx 3 -pady 3 -fill both -expand 1 -side top
   
   set fr2 [frame $topPM.fr2 -relief flat -borderwidth 0]
   pack $fr2 -padx 3 -pady 3 -fill both -expand 1 -side top
   
   set fr3 [frame $topPM.fr3 -relief flat -borderwidth 0]
   pack $fr3 -padx 3 -pady 3 -fill both -expand 1 -side top
   
   set fb [frame $topPM.fb -relief ridge -borderwidth 2 \
      -background skyBlue1]
   pack $fb -padx 3 -pady 3 -fill x -expand 0
   
   # Fill
   set lf [TitleFrame $fr1.lf -text Fill]
   pack $lf -side left -anchor n -padx 3 -pady 3 -expand yes -fill both -padx 3
   
   set frFill [$lf getframe]
   foreach it {x y both none} {
      radiobutton $frFill.$it -text $it -variable gd(pmFill) \
         -value $it -width 11 -anchor w
      pack $frFill.$it -anchor w
   }
   
   checkbutton $frFill.exp -text Expand -variable gd(pmFillExp)
   pack $frFill.exp -anchor w
   
   # Padding
   set lf [TitleFrame $fr1.lfp -text Padding]
   pack $lf -side right -anchor n -expand yes -fill both -padx 3 -pady 3
   
   set frPad [$lf getframe]
   set f1 [frame $frPad.1 -relief flat -borderwidth 0]
   pack $f1 -padx 3 -pady 3 -fill both -expand 1 -side top -anchor n
   set f2 [frame $frPad.2 -relief flat -borderwidth 0]
   pack $f2 -padx 3 -pady 3 -fill both -expand 1 -side top -anchor n
   
   set le [LabelEntry $f1.x -label "Internal: X " -width 4 \
      -textvariable "gd(pmIpadx)"]
   set wv(w,en,pmpadintx) $le.e
   pack $le -side left
   
   set le [LabelEntry $f1.y -label " y " -width 4 \
      -textvariable "gd(pmIpady)"]
   set wv(w,en,pmpadinty) $le.e
   pack $le -side left
   
   set le [LabelEntry $f2.x -label "External: X " -width 4 \
      -textvariable "gd(pmEpadx)"]
   set wv(w,en,pmpadextx) $le.e
   pack $le -side left
   
   set le [LabelEntry $f2.y -label " y "  -width 4 \
      -textvariable "gd(pmEpady)"]
   set wv(w,en,pmpadexty) $le.e
   pack $le -side left
   
   set le [LabelEntry $frPad.in -label "in: " \
      -textvariable "gd(pmIn)"]
   set wv(w,en,pmpadin) $le.e
   pack $le -side bottom -anchor nw
   
   # Side
   set lf [TitleFrame $fr2.lf -text Side]
   pack $lf -side left -anchor n -padx 3
   
   set frSide [$lf getframe]
   foreach it {top bottom left right} {
      radiobutton $frSide.$it -text $it -variable gd(pmSide) \
         -value $it -width 11 -anchor w
      pack $frSide.$it -anchor w
   }
   
   # Anchor
   set lf [TitleFrame $fr2.lfa -text Anchor]
   pack $lf -side right  -padx 3 -anchor n -expand yes -fill both
   set frAnchor [$lf getframe]
   
   set fr21 [frame $frAnchor.1 -relief flat -borderwidth 0]
   pack $fr21 -padx 3 -pady 3 -fill both -expand 1 -side left
   set fr22 [frame $frAnchor.2 -relief flat -borderwidth 0]
   pack $fr22 -padx 3 -pady 3 -fill both -expand 1 -side right
   set fr23 [frame $frAnchor.3 -relief flat -borderwidth 0]
   pack $fr23 -padx 3 -pady 3 -fill both -expand 1 -side right
   
   foreach it {nw n ne } {
      radiobutton $fr21.$it -text $it -variable gd(pmAnchor) \
         -value $it
      pack $fr21.$it -anchor w
   }
   foreach it {w center e } {
      radiobutton $fr22.$it -text $it -variable gd(pmAnchor) \
         -value $it
      pack $fr22.$it -anchor w
   }
   foreach it {sw s se} {
      radiobutton $fr23.$it -text $it -variable gd(pmAnchor) \
         -value $it
      pack $fr23.$it -anchor w
   }
   
   # Widgets
   set frP [frame $fr3.lf -borderwidth 1 -relief ridge]
   pack $frP -side left -anchor n -padx 0 -expand yes -fill both
   
   set sw [ScrolledWindow $frP.sw -auto both]
   pack $sw -padx 3 -pady 3 -expand yes -fill both
   
   set lbP [listbox $fr3.lbP]
   $sw setwidget $lbP
      
   # Kinder
   set frC [frame $fr3.lfk -borderwidth 1 -relief ridge]
   pack $frC -side left -anchor n -padx 0 -expand yes -fill both
   
   set sw [ScrolledWindow $frC.sw -auto both]
   pack $sw -padx 3 -pady 3 -expand yes -fill both
   
   set lbC [listbox $fr3.lbC]
   $sw setwidget $lbC
    
   set parents $window
   set p $window
   while {$p != {}} {
      set p [SendSyn -- winfo parent $window]
      _leer $p break
      lappend parents $p
      set window $p
   }
   
   #::utils::printliste parents
   $lbC delete 0 end
   $lbP delete 0 end
   $lbP insert end {*}$parents
   bind $lbP  <ButtonRelease-1> \
      [list PackSelectParent $lbP $lbC]
   bind $lbC <ButtonRelease-1> \
      [list PackSelectChild $lbP $lbC]
   
   set btpack [::utils::gui::mkButton wv $fb "" \
      -text Pack \
      -command [list PackPack $lbC] \
      -helptext "sel. Kind der Kinder packen"]
   
   set btunpack [::utils::gui::mkButton wv $fb "" \
      -text Unpack \
      -command [list PackUnpack $lbC] \
      -helptext "sel. Kind der Kinder entpacken"]
   
   pack $btpack $btunpack -padx 3 -pady 3 -side left
}

#--------------------------------------------------------------------
proc PackSelectParent {lbP lbC}  {
   # Kinder vom sel. Parents in tbl Children füllen
   #--------------------------------------------------------------------
   #_proctrace
   
   set selIdx [$lbP curselection]
   if {$selIdx eq ""} {
      set selIdx [$lbP index active]
      _leer $selIdx {return}
   }
   
   set parent [$lbP get $selIdx]
   _leer $parent return
   set ret [SendSyn -- winfo exists $parent]
   if {!$ret} {return}
   if {$ret eq ""} {return}
   set children [SendSyn -- winfo children $parent]
   
   $lbC delete 0 end
   $lbC insert end {*}$children
   SelectWidget -widget $parent
}

#--------------------------------------------------------------------
proc PackSelectChild {lbP lbC} {
   #
   #--------------------------------------------------------------------
   #_proctrace
   global gd
   
   set selIdx [$lbC curselection]
   if {$selIdx eq ""} {
      set selIdx [$lbC index active]
      _leer $selIdx {return}
   }
   
   set child [$lbC get $selIdx]
   _leer $child return
   set ret [SendSyn -- winfo exists $child]
   if {!$ret} {return}
   if {$ret == {}} {return}
   SelectWidget -widget $child
   
   if {[catch {SendSyn -- pack info $child} packInfo]} {
      #::utils::gui::msg info PackInfo $packInfo
      set gd(status) "$child ist nicht gepackt "
      return
   }
   if {$packInfo == {}} {
      set gd(status) "$child ist nicht gepackt "
      return
   }
   array set packAr $packInfo
   #parray packAr
   set gd(pmFill)   $packAr(-fill)
   set gd(pmSide)   $packAr(-side)
   set gd(pmAnchor) $packAr(-anchor)
   set gd(pmIn)     $packAr(-in)
   set gd(pmIpadx)  $packAr(-ipadx)
   set gd(pmIpady)  $packAr(-ipady)
   set gd(pmEpadx)  $packAr(-padx)
   set gd(pmEpady)  $packAr(-pady)
   set gd(pmExp)    $packAr(-expand)
   
}

#--------------------------------------------------------------------
proc PackUnpack {lbC} {
   # sel. Child aus Lb Children entpacken
   #--------------------------------------------------------------------
   #_proctrace
   set selIdx [$lbC curselection]
   if {$selIdx eq ""} {
      set selIdx [$lbC index active]
      _leer $selIdx {return}
   }
   
   set child [$lbC get $selIdx]
   _leer $child return
   set ret [SendSyn -- winfo exists $child]
   if {!$ret} {return}
   if {$ret == {}} {return}
   
   if {[catch {SendSyn -- pack info $child} packInfo]} {
      ::utils::gui::msg info PackInfo $packInfo
      return
   }
   _leer $packInfo {
      set gd(status) "$child ist nicht gepackt"
      return
   }
   
   SendSyn -- pack forget $child
}

#--------------------------------------------------------------------
proc PackPack {lbC} {
   # sel. Child aus tbl Children neu packen
   #--------------------------------------------------------------------
   #_proctrace
   global gd
   
   set selIdx [$lbC curselection]
   if {$selIdx eq ""} {
      set selIdx [$lbC index active]
      _leer $selIdx {return}
   }
   set child [$lbC get $selIdx]
   _leer $child return
   set ret [SendSyn -- winfo exists $child]
   if {!$ret} {return}
   if {$ret == {}} {return}
   
   set packCmd "pack $child "
   append packCmd "-padx $gd(pmEpadx) "
   append packCmd "-pady $gd(pmEpady) "
   append packCmd "-ipadx $gd(pmIpadx)  "
   append packCmd "-ipady $gd(pmIpady)  "
   append packCmd "-in $gd(pmIn)  "
   append packCmd "-fill $gd(pmFill) "
   append packCmd "-side $gd(pmSide) "
   append packCmd "-anchor $gd(pmAnchor) "
   append packCmd "-expand  $gd(pmExp) "
   puts $packCmd
   SendSyn -- {*}$packCmd
}

#-----------------------------------------------------------------------
proc TagInfo {w {tbl {}}} {
   # zeigt Tabelle aller Tags vom Textwidget w
   #-----------------------------------------------------------------------
   #_proctrace
   global wv gd
   
   ::utils::gui::setClock on $wv(w,top)
   update idletasks
   
   # alle Tagnamen holen
   #
   if {[catch {SendSyn -- $w tag names} namen]} {
      ::utils::gui::msg error TagInfo $namen
      ::utils::gui::setClock off $wv(w,top)
      return
   }
   
   # Bereich von/bis von allen Tags holen und Ergebnistabelle bauen
   #
   set erg ""
   foreach name $namen {
      if {[catch {SendSyn -- $w tag ranges $name} ranges]} {
         ::utils::gui::msg error TagRanges $ranges
         ::utils::gui::setClock off $wv(w,top)
         return
      }
      # Tags ohne ranges
      if {$ranges eq ""} {
         lappend erg [list $name - -]
      }
      
      foreach {von bis} $ranges {
         lassign [split $von "."] vonZ vonSp
         lappend erg [list $name $vonZ $vonSp $bis]
      }
   }
   #::utils::printliste erg
   
   # Tagtabelle sortiren und anzeigen
   #
   set erg [lsort -index 1 -dictionary $erg]
   set gd(status) "[llength $erg] Tags gefunden"
   
   if {$tbl ne ""} {
      $tbl delete 0 end
      $tbl insertlist end $erg
      ::utils::gui::setClock off $wv(w,top)
      return
   }
   
   set tdx {
      {Name}
      {vonZeile  vonZeile  0  right dictionary}
      {vonSpalte vonSpalte 0 right dictionary}
      {bis       bis       0  right dictionary}
   }
   set tl [::widgets::tw  $wv(w,top).taginfo  \
      -widget tablelist    \
      -titel "Tags von $w" \
      -tdx $tdx \
      -geometry 650x550 \
      -matrix $erg]
   set tbl [$tl winfo tablelist]
   set fbb [$tl winfo buttonbox]
   bind [$tbl bodypath] <Button-1> [list TagSelect $w $tbl %x %y]
   bind [$tbl bodypath] <Control-Button-1> [list TagShowConfig $w $tbl %x %y]
   
   # Funktionstasten
   set btupd [::utils::gui::mkButton "wv" $fbb "" \
      -image [::utils::gui::ic 22 view-refresh] \
      -helptext "Anzeige aktualisieren" \
      -command [list TagInfo $w $tbl]]
   set btcfg [::utils::gui::mkButton "wv" $fbb "" \
      -image [::utils::gui::ic 22 applications-development] \
      -helptext "Tag Konfiguration ansehen/ändern" \
      -command [list TagShowConfig $w $tbl {} {}]]
   pack $btupd $btcfg -padx 3 -pady 3 -side left
   ::utils::gui::setClock off $wv(w,top)
   #Resulttrace
}

#-----------------------------------------------------------------------
proc TagSelect {text tbl x y  } {
   # ein Tag in der Tagtabelle selektieren
   # wird im Testling markiert
   #-----------------------------------------------------------------------
   #_proctrace
   
   lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
   if {$zeile == -1} {return}
   
   set inh [$tbl get $zeile]
   lassign $inh name vonZ vonSp bis
   
   # Tag ohne Range
   if {$vonZ eq "-"} {
      return
   }
   
   if {[catch {SendSyn -- \
            ::inspector_testling::TagShow $text $vonZ.$vonSp $bis} msg]} {
      ::utils::gui::msg error TagShow $msg
      return
   }
   
   #Resulttrace
}
#-----------------------------------------------------------------------
proc TagShowConfig {text tbl x y} {
   # Auswahl eines Tag in der Tagtabelle, Optionen anzeigen und ändern
   # Aufruf durch Control-1 oder Taste
   #-----------------------------------------------------------------------
   #_proctrace
   global wv
   
   # selekt. Tag identifizieren
   #
   if {$x ne "" && $y ne ""} {
      lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
   } else {
      # Zeile selektiert
      set zeile [$tbl curselection]
      if {$zeile eq ""} {
         ::utils::gui::msg info Bedienugshinweis "bitte Zeile selektieren"
         return
      }
   }
   if {$zeile == -1} {return}
   
   set inh [$tbl get $zeile]
   lassign $inh name vonZ vonSp bis
   
   # Tag-Optionen vom Testling holen
   #
   if {[catch {SendSyn -- \
            $text tag configure $name} ret]} {
      ::utils::gui::msg error TagShow $ret
      return
   }
   
   # Optionen-String bauen
   #
   set str "$text \\\n   tag configure $name \\\n"
   foreach opt $ret {
      lassign $opt option p1 p2 p3 wert
      append str "\t$option [list $wert] \\\n"
   }
   set str [string range $str 0 end-3]
   
   # TagBindings
   if {[catch {SendSyn -- \
            $text tag bind $name} binds]} {
      ::utils::gui::msg error TagShowBind $binds
      return
   }
   if {$binds ne ""} {
      foreach event $binds {
         append str "\n\n# ---------- Tag Binding $event ------- \n"
         if {[catch {SendSyn -- \
                  $text tag bind $name $event} script]} {
            ::utils::gui::msg error TagShowBindScript $script
            return
         }
         append str "$text \\\n   tag bind $name $event \\\n"
         append str "    [list $script]"
      }
   }
   
   # TagOptionen als Toplevel anzeigen
   #
   set topcfg [::widgets::tw  $wv(w,top).tagopt  \
      -titel "Configuration Tag $name in $text"\
      -widget "text"          \
      -- \
      -font {TkFontFixed 9}   ]
   set toptxt [$topcfg winfo "text"]
   set frbbox [$topcfg winfo buttonbox]
   
   $toptxt insert 1.0 $str
   
   set sendbt [::utils::gui::mkButton "wv" $frbbox "" \
      -helptext "an Ziel senden" \
      -command [list TagSendConfig $toptxt ] \
      -text Senden]
   pack $sendbt -padx 3 -pady 3 -side left
}

#-----------------------------------------------------------------------
proc TagSendConfig {toptxt} {
   # angezeigte Tagoptionen nach Änderung zum Testling senden
   #-----------------------------------------------------------------------
   #_proctrace
   global gd
   
   if {[catch {SendSyn -- \
            [$toptxt get 1.0 end]} msg]} {
      ::utils::gui::msg error TagShow $msg
      return
   }
   set gd(status) "Tag geändert"
   
   #Resulttrace
}
#-----------------------------------------------------------------------
proc MarkInfo {w {tbl {}}} {
   # zeigt Tabelle mit marks vom Textwidget w
   #-----------------------------------------------------------------------
   #_proctrace
   global wv gd
   
   ::utils::gui::setClock on $wv(w,top)
   if {[catch {SendSyn -- $w mark names} namen]} {
      ::utils::gui::msg error MarkInfo $namen
      ::utils::gui::setClock off $wv(w,top)
      return
   }
   set erg ""
   foreach name $namen {
      if {[catch {SendSyn -- $w index $name} idx]} {
         ::utils::gui::msg error MarkIndex $idx
         ::utils::gui::setClock off $wv(w,top)
         return
      }
      lappend erg [list $name $idx]
   }
   set erg [lsort -index 1 -dictionary $erg]
   set gd(status) "[llength $erg] Marken gefunden"
   #::utils::printliste erg
   
   if {$tbl ne ""} {
      $tbl delete 0 end
      $tbl insertlist end $erg
      ::utils::gui::setClock off $wv(w,top)
      return
   }
   set tdx {
      {Name}
      {Index Index 0 right dictionary}
   }
   set tl [::widgets::tw $wv(w,top).markinfo  \
      -widget tablelist      \
      -titel "Marken von $w" \
      -tdx $tdx \
      -geometry 650x550 \
      -matrix $erg ]
   set tbl [$tl winfo tablelist]
   set fbb [$tl winfo buttonbox]
   bind [$tbl bodypath] <Button-1> [list MarkSelect $w $tbl %x %y]
   
   set btupd [::utils::gui::mkButton "wv" $fbb "" \
      -image [::utils::gui::ic 22 view-refresh] \
      -helptext "Anzeige aktualisieren" \
      -command [list MarkInfo $w $tbl]]
   pack $btupd -padx 3 -pady 3 -side left
   ::utils::gui::setClock off $wv(w,top)
   #Resulttrace
}
#-----------------------------------------------------------------------
proc MarkSelect {text tbl x y  } {
   #
   #-----------------------------------------------------------------------
   #_proctrace
   
   lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
   if {$zeile == -1} {return}
   
   
   set inh [$tbl get $zeile]
   lassign $inh name index
   set bis "$index +3c"
   
   if {[catch {SendSyn -- \
            ::inspector_testling::TagShow $text $index \"$bis\"} msg]} {
      ::utils::gui::msg error TagShow $msg
      return
   }
   
   #Resulttrace
}

#--------------------------------------------------------------------
proc ChooseFont {tbl row erg} {
   # wählt Font im Dialog
   # erg : ? -> Fonttype im Dialog erfragen
   # erg : != {} -> Font erg übernehmen und in der Zelle anzeigen
   #--------------------------------------------------------------------
   if {$erg eq "?"} {
      set fontAlt [$tbl cellcget $row,Wert -text]
      set erg [exec choosefont]
      if {$erg eq ""} {
         $tbl cancelediting
         return
      }
   }
   if {$erg eq ""} {return}
   
   lassign $erg name size durch under
   if {$size eq ""} {
      set wert [list $name]
   } else {
      set wert [list $name $size]
   }
   
   set blanks "                    "
   set len [string length $wert]
   set diff [expr {21 - $len}]
   set pad [string range $blanks 0 $diff]
   set wertF " $wert $pad"
   set wertF " $wert $blanks"
   
   $tbl cellconfig $row,Wert -text $wert
   [$tbl windowpath $row,Wert] configure -text $wertF \
      -font $wert
   return
}

#--------------------------------------------------------------------
proc ChooseColor {tbl row ret } {
   # wählt Farbe im Dialog
   # ret : ? -> Farbe im Dialog erfragen
   # ret : != {} -> Farbe ret übernehmen und in der Zelle anzeigen
   #--------------------------------------------------------------------
   if {$ret eq "?"} {
      set fAlt [$tbl cellcget $row,Wert -text]
      set erg [exec tcolor]
      if {$erg eq ""} {
         $tbl cancelediting
         return
      }
      
      lassign $erg farbName farbRaum farbCode
      set ret $farbName
      if {$farbName eq ""} {
         set ret $farbCode
      }
   }
   
   if {$ret eq ""} {return}
   
   $tbl cellconfig $row,Wert -text $ret
   if {$ret eq "black"} {
      set fg "white"
   } else {
      set fg "black"
   }
   set blanks "                    "
   set len [string length $ret]
   set diff [expr {15 - $len}]
   set pad [string range $blanks 0 $diff]
   set wertF " $ret $pad"
   
   [$tbl windowpath $row,Wert] configure -text $wertF -background $ret \
      -foreground $fg
   return
}