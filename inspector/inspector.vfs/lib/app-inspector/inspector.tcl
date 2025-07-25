## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  FILE: "inspector.tcl"
 #
 # ###################################################################

global gd env

package provide app-inspector 1.0

# #----------------------------------------------------------------
###-----------------------------------------------------------------------------
# InitVars
# initialisiert Anfangswerte
#---------------------------------------------------------------
proc InitVars {} {
   global argv tcl_platform env
   global gd
   set gd(programm) {inspector}
   
   # Systemdaten
   set gd(os)       $tcl_platform(os)
   set gd(platform) $tcl_platform(platform)
   set gd(home)     $env(HOME)
   set gd(host)     [info hostname]
   
   # Widgets
   set wv(w,top)        {} ; # Toplevel
      
   set gd(rundir)        [file join $gd(home) .$gd(programm)]
   
   # mainframe
   set gd(w,prg)        {}      ;# Widget Progressbar
   set gd(status)      {status} ;# Programmstatus
   set gd(clockset)    0        ;# ClockCursor ist angezeigt
   
   # Zustandsdaten
   #set gd(target)     {}       ;# aktuelles Ziel
   set gd(dynTabNr)    0        ;# TabNummer dyn ValueTab
   set gd(traceNr)     0        ;# Nummer Tracedisplay
   set gd(traces)      ""       ;# Traceverwaltung zum aufräumen
   set gd(traceRead)   ""       ;# Default für Dialog
   set gd(traceWrite)  write
   set gd(traceUnset)  unset
   
   set gd(target)         {}    ;# Port und Name Testling
   set gd(targetProgramm) {}    
   
   #--------------- Tabellenbeschreibung
   #
   #--------------- Tabelle Konfig
   set gd(tdOptKonf) {
      {Option  }
      {Wert    }
      {Default }
      {DBClass }
      {Typ     }
      {Args    }
   }
   set gd(tdStack) {  \
         {Level         Level         0  right  integer   }    \
         {{Aufruf von}  {Aufruf von}  20 left  dictionary }    \
         {NS }                                                 \
         {{in Prozedur} {in Prozedur} 10 left  dictionary }    \
         {Zeile         Zeile         0  right  integer   }    \
         {Name          Name          10 left  dictionary }    \
         {Typ           Typ           0  left ascii       }    \
      }
   set gd(tdP) {
      {0 Parents right   {}  }}
   set gd(tdC) {
      {0 Children right  {} }}
   
   set gd(listen) {Widget Proc Global Namespace Image Menu Canvas \
         After Font Quelle}
   set gd(tileClasses) {
      TButton TCheckbutton TCombobox TEntry TFrame TImage      \
         TLabel TLabelframe TMenubutton TNotebook TPanedwindow    \
         TProgressbar TRadiobutton TScale TScrollbar TSeparator   \
         TSizegrip   \
         TSpinbox Treeview }
   
   set ::inspector::Filter_Empty_Window_Options 1
   set ::inspector::Filter_Window_Class_Options 1
   set ::inspector::Filter_Pack_Options  0
   set ::inspector::winOpts {Configuration}
   
   set gd(sendAnInspector) "??"
   set gd(ziel) ""         ;# im Connectdialog
   set gd(defaultTO) 3     ;# Default Timeout in sec
   
   set gd(imageNr) 0
   set gd(fontNr)  0
   
   # Testpunkte siehe ResetData
   
   # Listeninhalt und Filter
   #foreach liste $gd(listen) {
   #   set gd($liste,inhalt)   {}       ;# Listeninhalt
   #  set gd($liste,filter)   {}       ;# Filter
   #   set gd($liste,inclExcl) {excl}   ;# Checkbutton Include Pattern
   #}
   
   # set gd(Global,filter) {^::.*}
   # set gd(Proc,filter)   {^tk[A-Z].*  ^auto_.*  ^::.* }
   
   # alles mit suchen
   foreach liste $gd(listen) {
      set ::inspector::lastSee($liste) -1  ;# letzte Anzeige
      set ::inspector::pattOld($liste) {}  ;# letztes Suchmuster
   }
   
   # alles mit Debug
   set gd(dbgPrgK)    "-1"
   set gd(dbgLevelsK) "-1"
   set gd(dbgLenK)    "-1"
   set gd(dbgPkgK)    "-1"
   
   # Widgetanzeige-Optionen
   set gd(winOpts) Configuration
   set gd(winOptsHlp) {
      Configuration Packing Slave_Packing Bindings Bindtags \
         Bindtags\Bind Class_Bind Style Layout Map Element_Opts
   }
   set gd(winOptsListe) {
      Cfg Pck SlvPck Bnd BndTgs BndTgs-Bnd ClsBnd Sty Lay Map ElmOpts}
   
   # Packman
   set gd(pmFill)    "none"
   set gd(pmExp)     0
   set gd(pmSide)    "top"
   set gd(pmAnchor)  "ne"
   
   set  gd(cursors) {
      X_cursor arrow based_arrow_down based_arrow_up boat bogosity
      bottom_left_corner bottom_right_corner bottom_side bottom_tee box_spiral
      center_ptr circle clock coffee_mug cross cross_reverse crosshair
      diamond_cross dot dotbox double_arrow draft_large draft_small draped_box
      exchange fleur gobbler gumby hand1 hand2 heart icon iron_cross left_ptr
      left_side left_tee leftbutton ll_angle lr_angle man middlebutton mouse pencil
      pirate plus question_arrow right_ptr right_side right_tee rightbutton
      rtl_logo sailboat sb_down_arrow sb_h_double_arrow sb_left_arrow
      sb_right_arrow sb_up_arrow sb_v_double_arrow shuttle sizing spider spraycan
      star target tcross top_left_arrow top_left_corner top_right_corner top_side
      top_tee trek ul_angle umbrella ur_angle watch xterm
   }
   
   #  Pseudooptionen von xtoolsWidget definieren
   #  name dbName class default inputType inputValue hilfe
   #  !! wird in tcldoc gepfegt !!!
   if {0} {
      set gd(pseudoOpts,PanedWindow|) [list \
         {-activator  {} {} {} Entrytype {} {}} \
         {-background {} {} {} Entrytype {} {}} \
         {-pad        {} {} {} Entrytype {} {}} \
         {-side       {} {} {} Listtype {top left} {}} \
         {-weights    {} {} {} Entrytype {} {}} \
         {-width      {} {} {} Entrytype {} {}} \
         ]
      set gd(pseudoOpts,PanedWindow-) [list \
         {-activator  {} {} {} Entrytype {} {}} \
         {-background {} {} {} Entrytype {} {}} \
         {-pad        {} {} {} Entrytype {} {}} \
         {-side       {} {} {} Listtype {top left} {}} \
         {-weights    {} {} {} Entrytype {} {}} \
         {-width      {} {} {} Entrytype {} {}} \
         ]
      set gd(pseudoOpts,NBTab) [list \
         {-createcmd {} {} {} Entrytype {} {Specifies a command to be called the first time the page is raised}}\
         {-image     {} {} {} Entrytype {} {Specifies an image to display for the page at the left of the label}}\
         {-leavecmd  {} {} {} Entrytype {} "Specifies a command to be called when a page is about to be leaved.\nThe command must return 0 if the page can not be leaved, or 1 if it can"}\
         {-raisecmd  {} {} {} Entrytype {} {Specifies a command to be called each time the page is raised}}\
         {-state     {} {} {} Entrytype {} {Specifies the state of the page. Must be normal or disabled}}\
         {-text      {} {} {} Entrytype {} {Specifies a label to display for the page}}\
         ]
      set gd(pseudoOpts,PWPane) [list \
         {-minsize {} {} {} Entrytype {} {Specifies the minimum size requested for the pane} {}}\
         {-weight  {} {} {} Entrytype {} {Specifies the relative weight for apportioning any extra spaces among panes} {}}\
         ]
      set gd(pseudoOpts,widgets::tw) [list \
         {-titel      {} {} {}        Entrytype {} {Fenstrtitel des Toplevel} {}}\
         {-geometry   {} {} {500x350} Entrytype {} {Größe und Postion des Toplevel} {}}\
         {-multi      {} {} {false}   Listtype  {true false} {parallele Toplevel} {}}\
         {-widget     {} {} {}        Listtype  {text tablelist {}} {Widgetklasse } {}}\
         {-pfad       {} {} {}        Entrytype {} {Dateipfad für Textwidget} {}}\
         {-text       {} {} {}        Entrytype {} {Text für Textwidget} {}}\
         {-tdx        {} {} {}        Entrytype {} {Spaltenbeschreibung für tablelist} {}}\
         {-namen      {} {} {}        Entrytype {} {Spaltennamen für tablelist} {}}\
         {-matrix     {} {} {}        Entrytype {} {Daten für tablelist} {}}\
         {-buttonbox  {} {} {true}    Listtype  {true false} {Rahmen für Tasten} {}}\
         {-exitbutton {} {} {true}    Listtype  {true false} {Exit für Toplevel} {}}\
         {-parent     {} {} {}        Entrytype {} {Text für Textwidget} {}}\
         ]
      set gd(pseudoOpts,widgets::lra) [list \
         {-tdxl   {} {} {} Entrytype {} {Tabledescription links} {}}\
         {-tdxr   {} {} {} Entrytype {} {Tabledescription rechts} {}}\
         {-namenl {} {} {} Entrytype {} {Namen der Spalten links, alternativ zu -tdxl} {}}\
         {-namenr {} {} {} Entrytype {} {Namen der Spalten rechts, alternativ zu -tdxr} {}}\
         {-datenl {} {} {} Entrytype {} {Datenmatrix linke Tabelle} {}}\
         {-datenr {} {} {} Entrytype {} {Datenmatrix recte Tabelle} {}}\
         {-titell {} {} {} Entrytype {} {Überschrift linke Tabelle} {}}\
         {-titell {} {} {} Entrytype {} {Überschrift linke Tabelle} {}}\
         {-updown {} {} {true} Listtype {true false} {Pfeile auf/ab} {}}\
         ]
      set gd(pseudoOpts,widgets::entrylb) [list \
         {-titel    {} {} {} Entrytype {} {Titel oberhalb der Listbox} {}}\
         {-texte    {} {} {} Entrytype {} {Listboxeinträge (data=texte)} {}}\
         ]
      set gd(pseudoOpts,widgets::nbvert) [list \
         {-titel {} {} {} Entrytype {} {Titel oberhalb der Listbox} {}}\
         {-texte {} {} {} Entrytype {} {Liste Namen in der Listbox} {}}\
         {-data {} {} {} Entrytype {} {Liste Pagetags (Default:Texte)} {}}\
         ]
      set gd(pseudoOpts,widgets::tabfs) [list \
         {-tdx   {} {} {dummytdx} Entrytype {} "erweiterte Tabellenbeschreibung." {}}\
         {-tabelle {} {} {dummytabelle} Entrytype {} {Name Tabelle oder Report} {}}\
         {-titel {} {} {} Entrytype {} {Überschrift Tabelle} {}}\
         {-filterspalten {} {} {4} Entrytype {} {Anzahl Filterspalten} {}}\
         {-popuptbl     {} {} {}    Entrytype {} {}    {}} \
         {-api          {} {} {tcl} Entrytype {} {tcl} {}} \
         {-dbpf         {} {} {}    Pathtype  {} {}    {}} \
         {-dbtoken      {} {} {}    Entrytype {} {}    {}} \
         {-postproc     {} {} {}    Entrytype {} {}    {}} \
         {-reportselect {} {} {}    Entrytype {} {}    {}} \
         {-cbquerystart {} {} {}    Entrytype {} {}    {}} \
         {-cbqueryend   {} {} {}    Entrytype {} {}    {}} \
         {-tooltip      {} {} {}    Entrytype {} {}    {}} \
         ]
   }
   
   # Init. Utils
   package require utils
   ::utils::init -rundir $gd(rundir)
   
}
#----------------------------------------------------------------
# shoCmd
# zeigt Kommando Parameter
#---------------------------------------------------------------
proc ShoCmd {optStr} {
   global gd
   
   set bedStr "\
Bedienung inspector

Syntax: \$inspector <optionen> 

Optionen : -port nummer

Diese Kurzanleitung ausgeben:
   \$inspector ?
   
   Ausführliche Beschreibung gibt es zusätzliche Informationen
   in der Online-Hilfe

Mögliche Optionen:\n$optStr"

   puts $bedStr
   exit
}
##
# -------------------------------------------------------------------
#
# Get_options --
#
#  verarbeitet Optionen von der Kommandozeile
#
# Argument	:	 Description
# ------------------------------------------------------------------
# -		:	-
#
# Results:
#  keine
#
# Side effects:
#  Optionen und Funktion wird glabal abgelegt
# ------------------------------------------------------------------
##
proc GetOptions {} {
   global gd argv env opt
   global tcl_platform
   
   #--------------- Kommandoparameter prüfen
   #
   set fkt {}
   set kommando {inspector}
   set vars {?fkt?}
   set optString {
      -hilfe     {switch "Kurzbeschreibung der Startqualifier"}
      -port      {string "Portnummer vom Testling"}
   }
   
   if {[catch {cmd_args $kommando $optString $vars $argv} msg]} {
      puts $msg
      exit
   }
   
   #---------------------------------------------------------
   set gd(fkt)     $fkt
   set gd(params)  {}
   if {[info exists args]} {
      set gd(fkt)    [lindex $args 0]
      set gd(params) [lrange $args 1 end]
   }
   
   #--------------- Hilfe ausgeben
   #
   if {[info exists opt(-hilfe)]} {
      ShoCmd $optString
   }
   if {$gd(fkt) == {?}} {
      ShoCmd $optString
   }
   
   # debug
  ###-----------------------------------------------------------------------------
  #    set ::utils::dbg::prg inspector
  #    set ::utils::dbg::levels {0}
  #    set ::utils::dbg::packages {}
  #    if {[info exists opt(-dbgpck)]} {
  #       set ::utils::dbg::packages $opt(-dbgpck)
  #    }
  #    if {[info exists opt(-dbg)]} {
  #       set ::utils::dbg::levels $opt(-dbg)
  #       if {$opt(-dbg) == {?}} {debuginfo}
  #    }
  #    
  ###-----------------------------------------------------------------------------
   # Target belegen
   if {![info exists opt(-port)]} {
      set opt(-port) ""
   }
return
   #--------------- tcp Socket  aufmachen
   #
   package require comm
   set adrInspector [::comm::comm self]
   comm::comm config -local 1 -port $adrInspector
   puts "comm inspector $adrInspector"
}


#----------------------------------------------------------------
# cleanExit: bei Programmende aufraeumen
# wird von destroy aufgerufen
#
#---------------------------------------------------------------
proc CleanExit {} {
   global gd wv
   #_proctrace
   
   # Traces und TP aufräumen
   TraceClean
   ::Tp::tpClean
   
   catch {::utils::saveCfg $gd(programm) $wv(w,top) \
         [file join $::scriptDirMain cfg_vars.txt]}
   
   #_dbg 10 GD-Array {catch {parray gd}}
   
   # Einstellungen speichern
   ::Cfg::saveOptions
   
   # eigene commIds schliessen
   catch {
      ::comm::comm hook lost {}
      foreach id [::comm::comm ids] {
        ::comm::comm shutdown $id
      }
   }
   exit
}
#------------------------------------------------------------
# Hauptprogramm
#------------------------------------------------------------
proc Main {} {
   global gd
   
   namespace eval inspector {}
   namespace eval Tp {}
   
   #--------------- Kommandoparameter prüfen
   #
   GetOptions
   
   
   #--------------- globale Daten initialisieren
   #
   InitVars
   
   # Cfg-Optionen mit Default vorbelegen und mit der Werten
   # der Konfigdatei überschreiben
   #
   ::Cfg::setupDefault
   ::Cfg::loadDefault
   ::Cfg::loadCfgFile
   
   # Systemfonts konfigurieren
   #
   ::Cfg::updateFonts

   #--------------- Sprungverteiler Funktion
   #
   switch -- $gd(fkt) {
      gui -
      default {MainGui}
   }
   
}
#----------------------------------------------------------------------
encoding system utf-8

#
#--------------- auto_path einstellen
#

# start mit tclkit ?
if {[info exists ::starkit::topdir]} {
   set scriptDir [file join $::starkit::topdir lib app-inspector]
} else {
   set scriptDir [file normalize [file dirname [info script]]]
}
      
set libDir [file normalize [file join $scriptDir ..]]
set ::scriptDirMain $scriptDir

::tcl::tm::path add $libDir           ;# für Module
lappend ::auto_path $::scriptDirMain  ;# für tclIndex
lappend ::auto_path $libDir

source [file join $::scriptDirMain chronik.tcl]

puts $gd(version)
#cd $scriptDir
cd ~
source [file join $::scriptDirMain inspectormenu.tcl]

#
#--------------- Packages
#
package require BWidget
package require tablelist
package require scrollutil
package require utils
package require fsdialog
package require comm
package require syntaxhighlight
package require cursor
#package require tkdnd
package require canvas_gradient

set gd(argvOrg) $argv
Main