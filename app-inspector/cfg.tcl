## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "cfg.tcl"
 #  Description:
 #  enthält Proz. zur Konfiguration
 #
 # ###################################################################

namespace eval Cfg {
   variable opts
   variable defOpts
   variable dialogWin
   
   
   #-----------------------------------------------------------------------
   proc dialog {  } {
      #   Dialog für die Einstellungen anzeigen
      #-----------------------------------------------------------------------
      #_proctrace
      global wv
      variable dialogWin
      
      set p $wv(w,top)
      set dialogWin $p.cfg
      catch {destroy $dialogWin}
      set tl [toplevel $dialogWin]
      wm title $tl Einstellungen
      set xp [winfo pointerx .]
      set yp [winfo pointery .]
      wm geometry $tl 756x504-$xp-$yp
      ::utils::gui::centerWindow $wv(w,top) $tl
      set f1 [frame $tl.f1 \
         -relief flat \
         -borderwidth 0]
      pack $f1 -padx 3 -pady 3 -fill both -expand 1
      
      #---- Notebook  ----------------
      #
      set nb [::utils::gui::mkNoteBook wv $f1 nbcfg]
      pack $nb -padx 3 -pady 3 -fill both -expand 1
      $nb insert end systemfonts \
         -text SystemFonts \
         -createcmd [list Cfg::mkSystemFonts $nb systemfonts]
      $nb raise systemfonts
      
   }
   
   #-----------------------------------------------------------------------
   proc buttonBox {p name} {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      
      # Funktionstasten
      #
      set fbb [frame $p.fbb \
         -borderwidth 1 \
         -relief sunken \
         -bg skyblue]
      pack $fbb -padx 3 -pady 3 -fill x -expand 0 -side bottom
      
      Button $fbb.ende \
         -text Ende \
         -helptext "Dialog beenden" \
         -command ::Cfg::invokeEnde
      Button $fbb.def \
         -text Vorbelegung \
         -helptext "Vorbelegung eintragen" \
         -command [list ::Cfg::applyGr $name def]
      pack $fbb.ende -padx 3 -pady 3 -side right
      pack $fbb.def  -padx 3 -pady 3 -side left
      
      return
      #Resulttrace
   }
   
   #---------------------------------------------------------------------
   proc invokeEnde {  } {
      #   im angewählten Register Defaultwerte eintragen
      #------------------------------------------------------------------
      #_proctrace
      variable dialogWin
      
      destroy $dialogWin
   }
   
   #---------------------------------------------------------------------
   proc saveOptions {  } {
      #---------------------------------------------------------------------
      global gd
      variable opts
      #_proctrace
      
      set cfgFile [file join $gd(rundir) einstellungen.cfg]
      
      set str ""
      # auch Cfg::option
      foreach option [lsort [array names ::Cfg::opts]] {
         if {![info exists ::Cfg::opts($option)]} {continue}
         set wert $::Cfg::opts($option)
         append str "[list ::Cfg:: $option $wert]\n"
         
      }
      ::utils::file::writefile $cfgFile $str
   }
   
   
   #---------------------------------------------------------------------
   proc applyGr { grp {default {}} } {
      # im angewählten Register grp Änderungen aktivieren
      # oder auf Default zurücksetzten
      #------------------------------------------------------------------
      #_proctrace
      global wv
      variable opts
      variable defOpts
      variable syntaxEle
      variable dialogWin
      
      if {$default ne ""} {
         set keys [array names defOpts "$grp,*"]
         foreach k $keys {set opts($k) $defOpts($k)}
      }
      
      if {$grp eq "systemfonts"} {
         # Systemfonts
         foreach fo {TkDefaultFont TkHeadingFont TkFixedFont TkIconFont \
               TkMenuFont TkTextFont TkTooltipFont} {
            set familie $opts(systemfonts,$fo,familie)
            set size    $opts(systemfonts,$fo,size)
            set weight  $opts(systemfonts,$fo,weight)
            set slant   $opts(systemfonts,$fo,slant)
            font configure $fo -family $familie -size $size \
               -weight $weight -slant $slant
            
         }
      }
      
      # Dialog neu anzeigen, damit Labels aktuell
      destroy $dialogWin
      dialog
   }
   
   #-----------------------------------------------------------------------
   proc loadCfgFile {  } {
      # liest die Konfig-Datei, prüft die Eintragen gegen Defaultwerte
      # überschreibt Default
      #-----------------------------------------------------------------------
      #_proctrace
      variable opts
      global gd
      
      set cfgFile [file join $gd(rundir) einstellungen.cfg]
      set zeilen [::utils::file::readliste $cfgFile \
         -noerror 1]
      if {$zeilen eq ""} {
         puts "F-Open <$cfgFile> fehlt oder leer"
         return
      }
      foreach zeile $zeilen {
         lassign $zeile name key wert
         if {$name eq "::Cfg::"} {
            if {![info exists ::Cfg::defOpts($key)]} {
               puts "Key:  <$key> unbekannt"
               continue
            }
            set ::Cfg::opts($key) $wert
         } else {
            puts "Key:  <$key> unbekannt"
         }
      }
      #Resulttrace
   }
   
   
   #---------------------------------------------------------------------
   proc loadDefault {  } {
      #   belegt alle Optionen mit den Defaultwerten
      #------------------------------------------------------------------
      #_proctrace
      variable opts
      variable defOpts
      
      set keys [array names defOpts]
      foreach k $keys {
         set opts($k) [::utils::oneblank $defOpts($k)]
      }
      
   }
   
   #---------------------------------------------------------------------
   proc setupDefault {  } {
      #   Optionen auf Default setzen
      #------------------------------------------------------------------
      #_proctrace
      variable defOpts
      
      # Register Systemfonts
      #
      set defOpts(systemfonts,TkDefaultFont,familie) {sans-serif}
      set defOpts(systemfonts,TkDefaultFont,size) 13
      set defOpts(systemfonts,TkDefaultFont,weight) normal
      set defOpts(systemfonts,TkDefaultFont,slant) roman
      
      set defOpts(systemfonts,TkFixedFont,familie) {Noto Mono}
      set defOpts(systemfonts,TkFixedFont,size) 13
      set defOpts(systemfonts,TkFixedFont,weight) normal
      set defOpts(systemfonts,TkFixedFont,slant) roman
      
      set defOpts(systemfonts,TkHeadingFont,familie) {sans-serif}
      set defOpts(systemfonts,TkHeadingFont,size) 13
      set defOpts(systemfonts,TkHeadingFont,weight) bold
      set defOpts(systemfonts,TkHeadingFont,slant) roman
      
      set defOpts(systemfonts,TkIconFont,familie) {sans-serif}
      set defOpts(systemfonts,TkIconFont,size) 13
      set defOpts(systemfonts,TkIconFont,weight) normal
      set defOpts(systemfonts,TkIconFont,slant) roman
      
      set defOpts(systemfonts,TkMenuFont,familie) {sans-serif}
      set defOpts(systemfonts,TkMenuFont,size) 13
      set defOpts(systemfonts,TkMenuFont,weight) normal
      set defOpts(systemfonts,TkMenuFont,slant) roman
      
      set defOpts(systemfonts,TkTextFont,familie) {sans-serif}
      set defOpts(systemfonts,TkTextFont,size) 13
      set defOpts(systemfonts,TkTextFont,weight) normal
      set defOpts(systemfonts,TkTextFont,slant) roman
      
      set defOpts(systemfonts,TkTooltipFont,familie) {sans-serif}
      set defOpts(systemfonts,TkTooltipFont,size) 11
      set defOpts(systemfonts,TkTooltipFont,weight) normal
      set defOpts(systemfonts,TkTooltipFont,slant) roman
      
      
   }
   
   #-----------------------------------------------------------------------
   proc updateFonts {  } {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      variable opts
      
      # Systemfonts
      foreach fo {TkDefaultFont TkHeadingFont TkFixedFont TkIconFont \
            TkMenuFont TkTextFont TkTooltipFont} {
         set familie $opts(systemfonts,$fo,familie)
         set size    $opts(systemfonts,$fo,size)
         set weight  $opts(systemfonts,$fo,weight)
         set slant   $opts(systemfonts,$fo,slant)
         font configure $fo -family $familie -size $size \
            -weight $weight -slant $slant
      }
   }
   
   #-----------------------------------------------------------------------
   proc getFontFamilies {  } {
      # Fonts sortiert und distinct
      #-----------------------------------------------------------------------
      #_proctrace
      
      set values ""
      lappend values Monospace TkDefaultFont TkFixedFont TkHeadingFont
      array unset fArr
      foreach font [font families] {
         set fArr($font) 1
      }
      lappend values {*}[lsort [array names fArr]]
      return $values
      #Resulttrace
   }
   #-----------------------------------------------------------------------
   proc mkSystemFonts { nb name } {
      #   Register Systemfonts
      # name: systemfonts
      #-----------------------------------------------------------------------
      #_proctrace
      global wv
      variable opts
      
      set fr [$nb getframe $name]
      buttonBox $fr $name
      
      Label $fr.lab \
         -text Systemfonts   \
         -font TkHeadingFont \
         -relief sunken \
         -pady 5 \
         -bg skyblue1 \
         -borderwidth 1
      pack $fr.lab -padx 3 -pady 3 -fill x
      
      #------------------------------------------------------
      #set sw [ScrolledWindow $fr.sw \
      #   -auto both]
      #pack $sw -fill both -expand yes -side top
      #set sf [ScrollableFrame $fr.f \
      #  -constrainedwidth yes \
      #   -constrainedheight no \
      #   -yscrollincrement 5]
      #$sw setwidget $sf
      #set fr [$sf getframe]
      #------------------------------------------------------
      #
      # Create a scrollableframe within a scrollarea
      #
      set f  [frame $fr.fr]
      set sa [scrollutil::scrollarea $f.sa]
      set sf [scrollutil::scrollableframe $sa.sf]
      $sa setwidget $sf
      
      pack $sa -side top -expand yes -fill both -padx 7p -pady 7p
      pack $f  -expand yes -fill both
      
      #
      # Create mouse wheel event bindings for the binding tag "all"
      #
      scrollutil::createWheelEventBindings all
      
      #
      # Get the content frame and populate it
      #
      
      set fr [$sf contentframe]
      
      #------------------------------------------------------
      set tf1 [TitleFrame $fr.tf2 -ipad 1 \
         -text Fontelemente \
         -font {TkHeadingFont 10 bold}]
      pack $tf1 -padx 3 -pady 3 -fill x
      set tfele [$tf1 getframe]
      
      set frt [frame $tfele.frt \
         -relief ridge \
         -borderwidth 2]
      pack $frt -padx 3 -pady 3 -fill x -side top
      
      label $fr.l1 -text Font    -width 14
      label $fr.l2 -text Familie -width 16
      label $fr.l3 -text Grösse  -width 8
      label $fr.l4 -text Style   -width 12
      label $fr.l5 -text Muster  -width 14
      pack $fr.l1 $fr.l2 $fr.l3 $fr.l4 $fr.l5 \
         -padx 3 -pady 3 -fill x -in $frt -side left
      
      # alle Fonts
      #     set scrollWins [list $fr $sw $sf]
      foreach font {TkDefaultFont TkHeadingFont TkFixedFont \
            TkIconFont TkMenuFont TkTextFont TkTooltipFont} {
         set fontK [string tolower $font]
         set frs  [frame $fr.$fontK \
            -relief ridge \
            -borderwidth 1]
         pack $frs -padx 3 -pady 3 -fill x -side top
         #       lappend scrollWins $fr.$fontK
         
         Label $frs.name \
            -text $font \
            -width 14 \
            -font TkDefaultFont
         #set wv(w,hl,$ele,name) $frs.name
         pack $frs.name -padx 3 -pady 3 -side left -anchor w
         #      lappend scrollWins $frs.name
         
         # Fontfamilie
         set cb [ComboBox $frs.cb -width 16]
         pack $cb -padx 3 -pady 3 -fill x -side left
         set values [getFontFamilies]
         $cb configure -values $values -text TkDefaultFont
         $cb configure \
            -textvariable ::Cfg::opts(systemfonts,$font,familie)
         $cb configure \
            -modifycmd [list ::Cfg::updateFonts]
         
         SpinBox $frs.size \
            -textvariable ::Cfg::opts(systemfonts,$font,size) \
            -text $::Cfg::opts(systemfonts,$font,size) \
            -width 8 \
            -range {5 20 1}
         $frs.size configure \
            -modifycmd [list ::Cfg::updateFonts]
         pack $frs.size -padx 3 -pady 3 -side left -anchor w
         #       lappend scrollWins $frs.size.e
         
         ComboBox $frs.weight \
            -textvariable ::Cfg::opts(systemfonts,$font,weight) \
            -text $::Cfg::opts(systemfonts,$font,weight) \
            -width 8 \
            -values {normal bold}
         $frs.weight configure \
            -modifycmd [list ::Cfg::updateFonts]
         pack $frs.weight -padx 3 -pady 3 -side left -anchor w
         #     lappend scrollWins $frs.weight.e
         
         Label $frs.muster \
            -text "the quick brown fox" \
            -anchor w  \
            -font $font
         #set wv(w,hl,$ele,muster) $frs.muster
         pack $frs.muster -padx 3 -pady 3 -side left -anchor w
         #     lappend scrollWins $frs.muster
      }
      
      # zum Scrollen
      #    foreach w $scrollWins {
      #      bind $w <Button-5> [list $sf yview scroll  5 units]
      #     bind $w <Button-4> [list $sf yview scroll -5 units]
      #    bind $w <Shift-Button-5> [list $sf xview scroll  2 units]
      #   bind $w <Shift-Button-4> [list $sf xview scroll -2 units]
      #}
      
   }
   
   #--------------------------------------------------------------------
   proc chooseFont {p systemfont label} {
      # wählt Font im Dialog, speichert opt und konfig
      #--------------------------------------------------------------------
      global wv
      variable opts
      
      set newfont [SelectFont .fontdlg \
         -parent $p       \
         -title "Font   $systemfont" \
         -type dialog]
      if { $newfont == "" } {return}
      
      # Configure Kommando bauen
      set newfont [::utils::oneblank $newfont]
      lassign $newfont family size args
      set cfg "font configure $systemfont \
         -family [list $family] -size $size "
      
      foreach arg $args {
         switch -exact -- $arg  {
            bold -
            Fett            {append cfg "-weight $arg "}
            italic -
            Kursiv          {append cfg "-slant $arg "}
            underline -
            Unterstrichen   {append cfg "-underline 1 "}
            overstrike -
            Durchgestrichen {append cfg "-overstrike 1 "}
            default {return -code error "chooseFont:<$arg> falsch"}
         } ; # end switch
      }
      # Konfig-Kommando ausführen
      try $cfg
      set opts(systemfonts,$systemfont) $cfg
      
      # Label im Dialog anpassen
      $label configure \
         -text [string range $opts(systemfonts,$systemfont) 15 end]
   }
   
} ;# Namespace