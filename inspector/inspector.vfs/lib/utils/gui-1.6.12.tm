# -*-Tcl-*-
# ###################################################################
#
#  FILE: "utils_gui.tcl"
#                                    created: 22.01.2012 14:00:00
#                                last update: 22.01.2012 14:00:00
#
#  Description:
#  utils::gui-Package enthält
#  gui-spezifische Helferlein
#
#  History
#
package provide utils::gui 1.6.12
#  modified   by   rev     reason
#  ---------- ---- ------- -------------------------
#  29.04.2024 mlrd 01.6.12 scrollxy und bei mktable und mxtext,Doku
#  17.04.2024 mlrd 01.6.10 tblpat neu
#  05.03.2024 mlrd 01.6.9  popupTblMuster: suchen mit tbl
#  01.02.2024 mlrd 01.6.8  tw -title -> tw -titel
#  17.01.2024 mlrd 01.6.7  tw::tw -> ::tw
#  22.08.2023 mlrd 01.6.6  Default von msgow1
#  30.04.2023 mlrd 01.6.5  msgow entfernt
#  03.12.2022 mlrd 01.6.4  Tabular entfernt
#  15.12.2021 mlrd 01.6.2  msgow1 doku
#  15.12.2021 mlrd 01.6.2  msgow1
#  20.11.2021 mlrd 01.6.1  topwidget entfernt
#  10.09.2021 mlrd 01.6.0  drucken entfernt
#  25.08.2020 mlrd 01.5.29 geoObenRechts: winfo toplevel
#  31.05.2020 mlrd 01.5.28 setClock: Ausnahme topwidget
#  08.05.2020 mlrd 01.5.27 gui::msg mit timeout
#  04.04.2020 mlrd 01.5.26 Doku htmlLinks neu
#  31.03.2020 mlrd 01.5.24 geoObenRechts
#  07.03.2020 mlrd 01.5.23 topwidget, pad 0 bei Frames
#  10.09.2019 mlrd 01.5.18 Tooltipadd: -~- -> nl
#  13.11.2019 mlrd 01.5.21 bittewarten2
#  26.09.2019 mlrd 01.5.19 msgow,bittew mit nr
#  10.09.2019 mlrd 01.5.18 ° -> nl
#  09.07.2019 mlrd 01.5.17 dpi
#  28.06.2019 mlrd 01.5.16 Doku
#  13.01.2019 mlrd 01.5.15 Spaltenanzeige mit titel
#  25.09.2018 mlrd 01.5.14 bittewarten mit geo
#  25.08.2018 mlrd 01.5.13 utils-Packages neu sortiert, tabfs
#  11.05.2018 mlrd 01.5.12 Diskrete Werte einer Spalte
#  14.03.2018 mlrd 01.5.11 F-msg kein gui noch einmal
#  22.01.2018 mlrd 01.5.10 F-msg kein gui
#  18.10.2017 mlrd 01.5.9  Spaltenanzeige mit topwidget
#  25.09.2017 mlrd 01.5.8  ::msg Abfrage wv(w,top)
#  24.07.2017 mlrd 01.5.6  gui::ic fehlertolerant
#  21.06.2017 mlrd 01.5.5  html-Adressen angepasst
#  13.06.2017 mlrd 01.5.4  parent bei msg vorbelegt
#  29.04.2017 mlrd 01.5.3  msg TL
#  15.04.2017 mlrd 01.5.2  checkName: Test info exists
#  09.04.2017 mlrd 01.5.1  mkTable: -namen : Spaltenname belegt
#  07.02.2017 mlrd 01.5.0  widgets::nbvert,mkNBVertikal entfernt,TblColInit
#                          mkEntryLB, mkLra entfernt
#  30.01.2017 mlrd 01.4.2  nbvert
#  14.12.2016 mlrd 01.4.1  TblColInit: Vorbelegung von td, mkTable mit -matrix
#  06.09.2016 mlrd 01.4.0  tdx statt td
#  10.06.2016 mlrd 01.3.9  cursor statt setclock
#  19.04.2016 mlrd 01.3.8  td mit name und title
#  18.03.2016 mlrd 01.3.7  topNix ohne exit
#  20.01.2016 mlrd 01.3.6  snit entfernt
#  09.01.2016 mlrd 01.3.5  mytablelist
#  31.12.2015 mlrd 01.3.4  iconsDirList
#  05.12.2015 mlrd 01.3.3  F- mklbentry
#  23.10.2015 mlrd 01.3.2  ND kurze Namen
#  11.10.2015 mlrd 01.3.2  popup hübsch
#  06.10.2015 mlrd 01.3.1  Top Bt
#  24.09.2015 mlrd 01.3.0  NaturalsDok Doku eingebaut
#  16.09.2015 mlrd 01.2.10 mkEntryLB , topNix neu
#  15.09.2015 mlrd 01.2.9  selectcolor, -selectproc bei NBVert
#  07.08.2015 mlrd 01.2.8  LB mit ScrolledFrame NB nicht homog.
#  23.07.2015 mlrd 01.2.7  -richt | bei mkNBVerti
#  16.07.2015 mlrd 01.2.6  srciptdirH, synchsrcoll
#  07.07.2015 mlrd 01.2.5  -richt | und - bei panedWindow
#  07.04.2015 mlrd 01.2.4  utils::gui::ic neu
#  23.02.2015 mlrd 01.2.2  setclock integriert
#  31.01.2015 mlrd 01.21  bittewarten mit titel,ohne geo, nbvert lb
#  06.12.2014 mlrd 01.20  bittewarten breiter
#  03.11.2014 mlrd 01.19  Args popuptblmuster
#  16.10.2014 mlrd 01.18  msg, centerwindow
#  27.08.2014 mlrd 01.17  bittewarten liefert Labelwidget
#  21.07.2014 mlrd 01.16  topTable mit Titel
#  24.04.2014 mlrd 01.15  Proc mit NS
#  27.03.2014 mlrd 01.14  topTable kann . als tl
#  18.02.2014 mlrd 01.13  topText mit Icons
#  22.11.2013 mlrd 01.12  ReadFile
#  11.06.2013 mlrd 01.11  loginfo
#  16.05.2013 mlrd 01.10  tblpopup mit export
#  17.01.2013 mlrd 01.09  checkName : Name doppelt, Widget nicht mehr da
#  23.12.2012 mlrd 01.08  Spaltenanzeige auch für Tabular, etc
#  04.11.2012 mlrd 01.06  mkNBVert mit titel
#  27.10.2012 mlrd 01.05  tbl mit scrbar und autoscroll
#  21.09.2012 mlrd 01.04  popupTblMuster mit drucken, bittewarten
#  28.07.2012 mlrd 01.03  mkListBox, mkPagesManager, mkNBvertikal
#                         mkText, topText
#  28.07.2012 mlrd 01.02  Optionen tbl
#  13.06.2012 mlrd 01.00  Original
# ###################################################################


namespace eval utils::gui {
   #---------- Variable ------------------------------------------------
   variable test           0
   variable wNr            10   ;# Widgetnummer wenn Name {}
   variable topNum         0    ;# eindeut. Toplevelnummer
   #variable iconsDir       $::utils_dir_icons
   variable packagename    {utils::gui}
   variable iconsDirList   {iconsDirListFehlt}
   
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
  #    proc _proctrace {} {
  #       #--------------------------------------------------------------------
  #       set infoLev [info level -1]
  #       #_dbg 1 Proctrace {set infoLev}
  #    }
  #    #--------------------------------------------------------------------
  #    proc _resulttrace {msg} {
  #       #--------------------------------------------------------------------
  #       variable packagename
  #       set infolevel [info level -1]
  #       ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
  #    }
  #    
  ###-----------------------------------------------------------------------------
   #---------------------------------------------------------------
   proc checkName {W name} {
      # W      : Array Widgetverzeichnis
      # name   : eindeutiger Name
      # prüft ob Widgetname schon da oder leer, dann liefert Nr
      upvar $W wv
      variable wNr
      
      if {$name != {}} {
         if {[info exists wv(w,$name)]} {
            # exist Widget ?
            if {[winfo exists $wv(w,$name)]} {
               return -code error "Name <$name> schon vorhanden "
            } else {
               return $name
            }
         } else {
            return $name
         }
      } else {
         incr wNr
         set name $wNr
         #_dbg 5 Widgetnr {set wNr}
         return $name
      }
   }
   #-----------------------------------------------------------------------
   proc _getTL {p} {
      # sucht toplevel p
      #-----------------------------------------------------------------------
      global wv
      if {$p ne ""} {
         return [winfo toplevel $p]
      } elseif {[info exists wv(w,top)]} {
         if {[winfo exists $wv(w,top)]} {return $wv(w,top)}
      } else {
         return .
      }
   }
}
#--------------------------------------------------------------------
#        Hauptprozeduren
#--------------------------------------------------------------------
#-----------------------------------------------------------------------
proc ::utils::gui::init  {dirlistP} {
   #
   #-----------------------------------------------------------------------
   #_proctrace
   variable iconsDirList
   
   set iconsDirList $dirlistP
   return
   #Resulttrace
}
#package require snit
###-----------------------------------------------------------------------------
# snit::widgetadaptor mytablelist {
#    option -tdx -default {}
#    option -namen -default {}
#
#    constructor { args } {
#
#       ##nagelfar variable self
#       installhull [::tablelist::tablelist $self]
#
#       $self configurelist $args
#       $self configure \
#          -stretch             all            \
#          -font                TkTextFont     \
#          -labelfont           TkHeadingFont  \
#          -activestyle         frame          \
#          -background          #e082f810ffff  \
#          -foreground          black          \
#          -labelforeground     black          \
#          -labelbackground     SlateGray2     \
#          -stripebackground    #e0e8f0        \
#          -showseparators      yes            \
#          -selectmode          single         \
#          -selecttype          row            \
#          -labelcommand        tablelist::sortByColumn    \
#          -movablecolumns      1                          \
#          -tooltipaddcommand ::utils::gui::TooltipAddCmd  \
#          -tooltipdelcommand DynamicHelp::delete
#
#       set td [$self cget -td]
#       set namen [$self cget -namen]
#       ::utils::gui::TblColInit $self $td
#       $self configure -namen ""
#       # Spalten inittialis.
#       if {$td != {}} {
#          ::utils::gui::TblColInit $self $td
#       } elseif {$namen != {}} {
#          $self configure -columns {}
#          $self configure -columntitles $namen
#       }
#
#       bind  [$self bodypath] <Button-3> \
#          [list ::utils::gui::popupTblMuster %W %x %y ]
#
#    }
#    # this delegates some methods to be able to manipulate
#    # the tablelist Widget
#    delegate method * to hull
#    delegate option * to hull
# }
#
###-----------------------------------------------------------------------------
#------------------------------------------------------------------
proc ::utils::gui::TblColInit {tbl tdx} {
   # Spalten der Tabelle einrichten
   #
   #  tdx :  name title breite ident sortTyp dbname dbtyp hierarchie ttip
   #  dbname dbtyp hierarchie ttip wird nur von tabfs verwendet
   # ---------------------------------
   
   if {$tdx == {}} {return}
   
   # Spaltenbreite, Ident und Titel
   set col {}
   foreach sp $tdx {
      lassign $sp name title breite ident
      if {$name eq ""} {
         #return -code error "name in tdx fehlt"
         # continue
      }
      if {$title eq ""}  {set title $name}
      if {$breite eq ""}  {set breite 0}
      if {$ident eq ""}  {set ident left}
      append col "$breite \"$title\" $ident\n"
   }
   $tbl configure -columns $col
   # Spaltennamen und Sortiermode
   set nr 0
   foreach sp $tdx {
      lassign $sp name title breite ident sortMode
      if {$name eq ""} {
         #return -code error "name in tdx fehlt"
         #continue
      }
      
      if {$sortMode eq ""}  {set sortMode dictionary}
      
      $tbl columnconfigure $nr -name $name -sortmode $sortMode
      incr nr
   }
}

#     ------------------------------------------------------------------
proc ::utils::gui::TooltipAddCmd {tbl row col} {
   ##nagelfar variable fullText
   if {($row >= 0 && [$tbl iselemsnipped $row,$col "fullText"]) ||
      ($row <  0 && [$tbl istitlesnipped $col "fullText"])} {
      regsub -all -- {\\nl} $fullText "\n" fullText
      regsub -all -- {-~-}  $fullText "\n" fullText
      DynamicHelp::add $tbl -text $fullText
   }
}

#     ------------------------------------------------------------------
proc ::utils::gui::TblGetZS {tbl x y} {
   # liefert Zeile,Spalte bei gegeb. x y
   set w [$tbl bodypath]
   foreach {::tablelist::W ::tablelist::x ::tablelist::y} \
      [::tablelist::convEventFields $w $x $y] {}
   
   set cell [$tbl containingcell $::tablelist::x $::tablelist::y]
   lassign [split $cell {,}] zeile spalte
   return [list $zeile $spalte]
}

#     ------------------------------------------------------------------
proc ::utils::gui::popupTblMuster {tbl_body x y} {
   
   set tbl [winfo parent $tbl_body]
   lassign [TblGetZS $tbl $x $y] zeile spalte
   if {$zeile == -1} {return}
   
   set xp [winfo pointerx .]
   set yp [winfo pointery .]
   
   set inh [$tbl cellcget $zeile,$spalte -text]
   
   # Menu
   set menuName .tblMenu
   catch {destroy $menuName}
   set menubar [menu $menuName -tearoff 0 \
      -borderwidth 3 -relief groove]
   
   #$menubar add separator
   $menubar add command -label {Spaltenanzeige... } \
      -command [list ::utils::gui::Spaltenanzeige $tbl $zeile]
   $menubar add command -label {Diskrete Spaltenwerte... } \
      -command [list ::utils::gui::DiskreteSpaltenWerte $tbl $spalte]
   $menubar add command -label { suchen... } \
      -command [list ::utils::suchen::findDialog $tbl $tbl]
   $menubar add command -label { export... } \
      -command [list ::utils::export::dialog $tbl $tbl]
   
   tk_popup $menubar  $xp $yp
}


#--------------------------------------------------------------------
#
# Proc: mkTable
#
# *::utils::gui::mkTable W p name args*
#
# erzeugt eine Tablelist-Tabelle mit automatischen Scrollbars
# unter dem Widget-Vater *p* mit dem Namen *name* im
# Widgetverzeichnis *W*.
#
#
# Parameter:
#     W: Globales Widgetverzeichnis i.a. wv (ohne $)
#     p: Parentwidget
#     name:  eindeutiger Name im Widgetverzeichnis. Per Default wird der Name
#        automatisch vergeben.
#     args:  Optionen
#
# Optionen:
#  -tdx TD:   TD ist eine Matrix, die für jede Spalte
#       ** Name
#       ** Titel
#       ** Breite
#       ** Ausrichtung (left, center,right)
#       ** Sortiermode (integer, ascii, dictionary) enthält.
#
# -namen liste:      Liste mit den Spaltennamen. Diese Option kann
#       vereinfacht anstatt der Option -tdx verwendet werden.
#
# -matrix daten:  Die Matrix daten (Liste in Liste) wird in der
#    Tabelle angezeigt.
#
#       Nach der Kennung *--* können weitere Optionenpaare
#       für *tablelist* angefügt werden.
#
# Ergebnis:
#    Tablelistwidget
#
#  siehe auch:
# <tablelistWidget.html>
#
# Beispiel:
# (start code)
#
#
#   #--------------- Tabellenbeschreibung
#   #
#   set gd(tdlog) {
#      {Datum Zeile1\nZeile2 12 left  dictionary }
#      {Zeit   Zeit          10 left  dictionary }
#      {Host   Host          16 left  dictionary }
#      {Display Display      0  left  dictionary }
#      {Art    Art           3  center ascii     }
#      {Meldung m            0  left dictionary  }
#   }
#
#   global wv
#   set tab [::utils::gui::mkTable wv $ftbl logtab \
#     -tdx $gd(tdlog)    \
#     --                 \
#     -selecttype row    \
#   ]
# (end)
#
#
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkTable {W p name args} {
   upvar $W wv
   #_proctrace
   
   set name [checkName wv $name]
   
   package require tablelist
   ##nagelfar variable params
   ::Opt::opts {params} $args {
      {-tdx    {}    "erweiterte Tabledescription"}
      {-namen  {}    "Name der Spalten, fakultativ zu td"}
      {-matrix     {} "Matrix zum Einfügen"}
      {--      ""    "Options für Tablelist folgen"}
   }
   #
   # Tabledescription:
   #  name titel breite ident sortmode dbname dbtyp hierarchie
   #
   set tdx      $params(-tdx)
   set namen   $params(-namen)
   set matrix  $params(-matrix)
   #--------------------------------------------------------
   # Tablelist mit Scrollbar kreiern
   #
   set fr [frame $p.$name]
   pack $fr -padx 0 -pady 0 -expand yes -fill both
   set tbl $fr.tbl
   tablelist::tablelist $tbl \
      -stretch             all            \
      -font                TkTextFont     \
      -labelfont           TkHeadingFont  \
      -activestyle         frame          \
      -background          #e082f810ffff  \
      -foreground          black          \
      -labelforeground     black          \
      -labelbackground     SlateGray2     \
      -stripebackground    #e0e8f0        \
      -showseparators      yes            \
      -selectmode          single         \
      -selecttype          row            \
      -labelcommand        tablelist::sortByColumn    \
      -movablecolumns      1                          \
      -tooltipaddcommand ::utils::gui::TooltipAddCmd  \
      -tooltipdelcommand DynamicHelp::delete          \
      -yscroll "$fr.yscroll set" \
      -xscroll "$fr.xscroll set" \
      {*}$params(--)
   option add *tbl*Entry.background white
   
   scrollbar $fr.xscroll -relief sunken \
      -orient horizontal  -command "$tbl xview"
   scrollbar $fr.yscroll -relief sunken \
      -orient vertical -command "$tbl yview"
   pack $fr.yscroll -side right  -fill y
   pack $fr.xscroll -side bottom -fill x
   pack $tbl -padx 0 -pady 0 -fill both -expand yes
   
   #::autoscroll::autoscroll $fr.xscroll
   #::autoscroll::autoscroll $fr.yscroll
   
   # Spalten inittialis.
   if {$tdx != {}} {
      TblColInit $tbl $tdx
   } elseif {$namen != {}} {
      $tbl configure -columns {}
      $tbl configure -columntitles $namen
      set num 0
      foreach na $namen {
         $tbl columnconfigure $num -name $na
         incr num
      }
   }
   
   # scroll xy
   scrollxy $tbl
   
   #$tbl configure -labelborderwidth  1
   #$tbl configure -setgrid            yes
   #$tbl columnconfigure 1 -sortmode command -sortcommand vglDatum
   #bind [$tbl bodypath] <ButtonRelease-1> cbSelectZeile
#   bind  [$tbl bodypath] <Button-3> \
#      [list ::utils::gui::popupTblMuster %W %x %y ]
   set wv(w,$name) $tbl
   if {$matrix != {}} {$tbl insertlist end $matrix}
   return $tbl
}

###-----------------------------------------------------------------------------
#
# Proc: scrollxy
#
# *::utils::gui::scrollxy w*
#
# ermöglicht bei einem Tablelist- oder Textwidget scrollen in x und y
# durch Ziehen mit der Maus bei gedrückter Shift-Taste
# 
# Parameter:
#
#   w:      Tablelist- oder Textwidget
#
#
###-----------------------------------------------------------------------------
#-----------------------------------------------------------------------
proc ::utils::gui::scrollxy {w} {
   # verschiebt txt und tbl in xy durch Ziehen mit der Maus
   # ruft _scrView
   #-------------------------------------------------------------------
   set wbind $w
   
   # nur bei tablelist oder text
   if {[winfo class $w] eq "Tablelist"} {
      set wbind [$w bodypath]
   } elseif {[winfo class $w] eq "Text"} {
   } else {
      return -code error "falsche class "
   }
      
   bind $wbind  <Shift-B1-Motion> \
      [list ::utils::gui::_scrView $w motion %x %y]
   bind $wbind  <Shift-ButtonPress-1> \
      [list ::utils::gui::_scrView $w set %x %y]
   
   return
}

#------------------------------------------------------------------
proc ::utils::gui::_scrView { w cmd x y } {
   # verschiebt txt und tbl in xy durch Ziehen mit der Maus
   #  w : Widget tbl|txt
   # cmd : set|move
   # geklaut bei BWidget/scrollView
   #------------------------------------------------------------------
   variable _widget_dx
   variable _widget_dy
   variable width
   variable height
   
   # wg. dragnDrop
   if {[winfo class $w] eq "Tablelist"} {
      $w selection clear 0 end
   }
   
   #    set w [Widget::getoption $path -window]
   if {[winfo exists $w]} {
      if {[string equal $cmd "set"]} {
         set x0 [winfo x $w]
         set y0 [winfo y $w]
         set width [winfo width $w]
         set height [winfo height $w]
         set x1 [expr {$x0 + $width}]
         set y1 [expr {$y0 + $height}]
         if {$x >= $x0 && $x <= $x1 &&
            $y >= $y0 && $y <= $y1} {
            set _widget_dx [expr {$x-$x0}]
            set _widget_dy [expr {$y-$y0}]
            return
         } else {
            set x0 [expr {$x-($x1-$x0)/2}]
            set y0 [expr {$y-($y1-$y0)/2}]
            set _widget_dx [expr {$x-$x0}]
            set _widget_dy [expr {$y-$y0}]
            set vh [expr {double($x0-5)/$width}]
            set vv [expr {double($y0-5)/$height}]
         }
      } elseif {[string equal $cmd "motion"]} {
         set vh [expr {double($x-$_widget_dx-5)/$width}]
         set vv [expr {double($y-$_widget_dy-5)/$height}]
      }
      $w xview moveto $vh
      $w yview moveto $vv
   }
}


#------------------------------------------------------------------
proc ::utils::gui::Spaltenanzeige {tbl z {titel {} } } {
   # zeigt alle Spalten einer Tabellenzeile
   
   set colTitles [$tbl cget -columntitles]
   set zeile [$tbl get $z]
   
   if {$zeile== {}} {return}
   if {$titel eq ""} {
      set titel "Spaltenanzeige Zeile:$z"
   } else {
      set titel "Spalte $z <$titel>"
   }
   
   set tl [winfo toplevel $tbl]
   set tw [::widgets::tw $tl.spa \
      -widget tablelist  \
      -titel  $titel     \
      -namen  {Spalte   Wert}]
   set tbl [$tw winfo tablelist]
   foreach tit $colTitles z $zeile {
      $tbl insert end [list $tit $z]
   }
}

###-----------------------------------------------------------------------------
#
# Proc: DiskreteSpaltenWerte
#
# *::utils::gui::DiskreteSpaltenWerte tbl spalte*
#
# zeigt alle diskreten Werte einer Spalte der *angezeigten* Tabelle.
# 
# Der WerteVorrat zeigt alle verschiedenen Werte einer Spalte der
# *gesamten* Tabelle.
#
# 
# Parameter:
#
#   tbl:     Tablelistwidget
#   spalte:  Spaltennummer 
#
# Ergebnis:
#    Toplevel
#
###-----------------------------------------------------------------------------
proc ::utils::gui::DiskreteSpaltenWerte {tbl spalte } {
   # zeigt alle diskreten Werte einer Spalte
   
   if {$spalte == {}} {return}
   
   # alle Werte einer Spalte
   set werte [$tbl columncget $spalte -text]
   # Werte sortieren
   set werte [lsort -unique $werte]
   
   set tl [winfo toplevel $tbl]
   set tw [::widgets::tw $tl.dissp \
      -widget tablelist \
      -titel "Diskrete Werte der Spalte: [$tbl columncget $spalte -title]" \
      -namen {Nr Werte}]
   set tbl [$tw winfo tablelist]
   set nr 1
   foreach w $werte {
      $tbl insert end [list $nr $w]
      incr nr
   }
}

###-----------------------------------------------------------------------------
#
# Proc: mkTabular
#
# *::utils::gui::mkTabular W p name args*
#
# erzeugt ein Tabularwidget
# mit automatischen Scrollbars
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  eindeutiger Name im Widgetverzeichnis. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das Buttonwidget
#
#
# Ergebnis:
#    Tabular-Widget
#
#
# Beispiel:
# (start code)
# global wv
# set tab [::utils::gui::mkTabular wv $f logTabular \
#    -bg white \
# ]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::xmkTabular {W p name args} {
   upvar $W wv
   #_proctrace
   
   set name [checkName wv $name]
   
   package require Tabular
   #--------------------------------------------------------
   # Tabular mit Scrollbar kreiern
   #
   set sw [ScrolledWindow $p.$name -auto both]
   pack $sw -fill both -expand yes
   #set tab [tabular $sw.tab {*}$args]
   set tab xxx
   $sw setwidget $tab
   
   set txt $tab.body
   set title $tab.title
   $title configure -background SkyBlue1
   $title configure -font TkHeadingFont
   $txt   configure -background SlateGray1
   $txt   configure -background  #e082f810ffff
   #$txt tag configure #evenrow -background #e082f810ffff
   $txt tag configure #oddrow -background #e0e8f0
   $txt configure -font TkTextFont
   
   #bind $txt <ButtonRelease-1> [list cbSelect1 $table $tab]
   #bind $txt <Button-3> [list popupTab $tab $table %W %x %y ]
   set wv(w,$name) $tab
   return $tab
}

###-----------------------------------------------------------------------------
#
# Proc: mkComboBox
#
# *::utils::gui::mkComboBox W p name args*
#
# erzeugt ein ComboBoxWidget.
# unter dem
# Widget-Vater _p_ mit dem Namen _name_ im
# Widgetverzeichnis _W_. Die _Textvariable_ ist mit
# wv(v, _$name_ ) vorbelegt.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das ComboBoxwidget
#
#
# Ergebnis:
# Widget ComboBox
#
# siehe auch:
#
# - <bwidget/ComboBox.html>
#
# Beispiel:
# (start code)
# set w [mkComboBox wv $p farben \
#   -values {blau rot gruen}     \
# ]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkComboBox {W p name args} {
   # W      : Array Widgetverzeichnis
   # p      : parent
   # name   : eindeutiger Name
   # args   : Widget-Optionen
   upvar $W wv
   #_proctrace
   
   set noName 0
   if {$name == {}}  {set noName 1}
   
   set name [checkName wv $name]
   if {$noName} {
      set cb [ComboBox $p.$name {*}$args]
   } else {
      set wv(v,$name) $name
      set cb [ComboBox $p.$name -textvariable "wv(v,$name)" {*}$args]
   }
   
   set wv(w,$name) $cb
   return $cb
}

###-----------------------------------------------------------------------------
#
# Proc: mkButton
#
# *::utils::gui::mkButton W p name args*
#
# erzeugt ein ButtonWidget
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  eindeutiger Name im Widgetverzeichnis. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das Buttonwidget
#
#
# Ergebnis:
#  Widget Button
#
# siehe auch:
# - </bwidget/Button.html>
#
# Beispiel:
# (start code)
# set w [mkButton wv $p exit  \
#    -helptext {Programmende} \
# ]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkButton {W p name args} {
   upvar $W wv
   #_proctrace
   
   set name [checkName wv $name]
   set w [Button $p.$name  {*}$args]
   set wv(w,$name) $w
   return $w
}

###-----------------------------------------------------------------------------
#
# Proc: mkTButton
#
# *::utils::gui::mkTButton W p name args*
#
# erzeugt ein Tool-ButtonWidget
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  eindeutiger Name im Widgetverzeichnis. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das Buttonwidget
#
#
# Ergebnis:
#  Widget Button
#
#
# siehe auch:
# - <bwidget/Button.html>
#
# Beispiel:
# (start code)
# set w [mkTButton wv $p exit  \
#    -icon [::utils::gui::ic 16 exit_process] \
#    -helptext {Programmende}  \
#]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkTButton {W p name args} {
   upvar $W wv
   variable wNr
   #_proctrace
   set name [checkName wv $name]
   set w [Button $p.$name  \
      -borderwidth 0             \
      -background skyBlue1       \
      -highlightthickness 0      \
      -takefocus 0               \
      -relief link               \
      -padx 1 -pady 1            \
      {*}$args]
   set wv(w,$name) $w
   return $w
}

###-----------------------------------------------------------------------------
#
# Proc: mkLabel
#
# *::utils::gui::mkLabel W p name args*
#
# erzeugt ein Label-Widget
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Die _Textvariable_ wird mit wv(v, _$name_ ) vorbelegt.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das Label-Widget
#
#
# Ergebnis:
#  Widget Label
#
#
# siehe auch:
# - <bwidget/Label.html>
#
# Beispiel:
# (start code)
# set wv(v,datum) {01.12.12} ;# textvariable belegen
# set w [mkLabel wv $p datum -relief raised]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkLabel {W p name args} {
   upvar $W wv
   variable wNr
   
   set noName 0
   if {$name == {}}  {set noName 1}
   #_proctrace
   
   set name [checkName wv $name]
   if {$noName} {
      set w [Label $p.$name  {*}$args]
   } else {
      set w [Label $p.$name -textvariable "wv(v,$name)" {*}$args]
      set wv(w,$name) $w
   }
   return $w
}

###-----------------------------------------------------------------------------
#
# Proc: mkText
#
# *utils::gui::mkText W p name args*
#
# erzeugt ein Text-Widget mit Scrollbars
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  eindeutiger Name im Widgetverzeichnis. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das Buttonwidget
#
#
# Ergebnis:
#  Widget Text
#
#
# siehe auch:
# - <TkCmd/text.htm>
#
# Beispiel:
# (start code)
# global wv
# set tab [::utils::gui::mkText wv $f logtext \
#    -wrap none \
# ]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkText {W p name args} {
   upvar $W wv
   
   set noName 0
   if {$name == {}}  {set noName 1}
   #_proctrace
   
   set name [checkName wv $name]
   set sw [ScrolledWindow $p.sw_$name -auto both]
   pack $sw -padx 3 -pady 3 -expand yes -fill both
   
   set t [text $p.$name {*}$args]
   $sw setwidget $t
   
   if {!$noName} {set wv(w,$name) $t}
   
   # scroll in xy
   scrollxy $t
   
   return $t
}

###-----------------------------------------------------------------------------
#
# Proc: mkListBox
#
# *::utils::gui::mkListBox W p name args*
#
# erzeugt ein ListBox-Widget mit Scrollbars
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# *Das Widget darf nicht gepackt werden.*
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das ListBox-Widget
#
# Ergebnis:
#  Widget ListBox
#
#
# siehe auch:
# - <bwidget/ListBox.html>
#
# Beispiel:
# (start code)
# global wv
# set w [mkListBox wv $p farben -selectmode single]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkListBox {W p name args} {
   upvar $W wv
   variable wNr
   
   set noName 0
   if {$name == {}}  {set noName 1}
   #_proctrace
   
   set name [checkName wv $name]
   set sw [ScrolledWindow $p.sw_$name ]
   pack $sw -padx 0 -pady 0 -expand yes -fill both
   
   
   set w [ListBox $p.$name  {*}$args ]
   $sw setwidget $w
   
   if {!$noName} {set wv(w,$name) $w}
   return $w
}

###-----------------------------------------------------------------------------
#
# Proc: mkPagesManager
#
# *::utils::gui::mkPagesManager W p name args*
#
# erzeugt ein PagesManager-Widget
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# *Das Widget darf nicht gepackt werden.*
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das PagesManager-Widget
#
# Ergebnis:
#  Widget PagesManager
#
# siehe auch:
# - <bwidget/PagesManager.html>
#
# Beispiel:
# (start code)
# global wv
# set w [mkPagesManager wv $p pm -width 100]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkPagesManager {W p name args} {
   upvar $W wv
   variable wNr
   
   set noName 0
   if {$name == {}}  {set noName 1}
   #_proctrace
   
   set name [checkName wv $name]
   set w [PagesManager $p.$name  {*}$args]
   if {!$noName} {set wv(w,$name) $w}
   return $w
}

###-----------------------------------------------------------------------------
#
# Proc: mkEntry
#
# *::utils::gui::mkEntry W p name args*
#
# erzeugt ein EntryBox-Widget
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Die _Textvariable_ wird mit wv(v, _$name_ ) vorbelegt.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das Entry-Widget
#
# Ergebnis:
#  Widget Entry
#
# siehe auch:
# - <bwidget/Entry.html>
#
# Beispiel:
# (start code)
# set wv(v,datum) {01.12.12} ;# Textvariable belegen
# set w [mkEntry wv $p datum  -bg red]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkEntry {W p name args} {
   upvar $W wv
   variable wNr
   
   set noName 0
   if {$name == {}}  {set noName 1}
   #_proctrace
   
   set name [checkName wv $name]
   if {$noName} {
      set e [Entry $p.$name -background white {*}$args ]
   } else {
      set e [Entry $p.$name -textvariable "wv(v,$name)" \
         -background white \
         {*}$args ]
      set wv(w,$name) $e
   }
   return $e
}

###-----------------------------------------------------------------------------
#
# Proc: mkLabelEntry
#
# *::utils::gui::mkLabelEntry W p name args*
#
# erzeugt ein LabelEntry-Widget.
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Die _Textvariable_ wird mit wv(v, _$name_ ) vorbelegt.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das LabelEntry-Widget
#
# Ergebnis:
#  Widget LabelEntry
#
# siehe auch:
# - <LabelEntry.html>
#
# - <bwidget/Entry.html>
#
# Beispiel:
# (start code)
# set wv(v,datum) {01.12.12} ;# Textvariable belegen
# set w [mkLabelEntry wv $p datum -label Datum]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkLabelEntry {W p name args} {
   upvar $W wv
   variable wNr
   
   set noName 0
   if {$name == {}}  {set noName 1}
   #_proctrace
   
   set name [checkName wv $name]
   if {$noName} {
      set e [LabelEntry $p.$name {*}$args]
   } else {
      set e [LabelEntry $p.$name -textvariable "wv(v,$name)" {*}$args]
      set wv(w,$name) $e
   }
   return $e
}

###-----------------------------------------------------------------------------
#
# Proc: mkNoteBook
#
# # *::utils::gui::mkNoteBook W p name args*
#
# erzeugt ein NoteBook-Widget
# unter dem
# Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  originale Optionenpaare für das NoteBook-Widget
#
# Ergebnis:
#  Widget NoteBook
#
# siehe auch:
# - <bwidget/NoteBook.html>
#
# Beispiel:
# (start code)
# set w [mkNoteBook wv $p nb -side top]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkNoteBook {W p name args} {
   upvar $W wv
   variable wNr
   #_proctrace
   
   set name [checkName wv $name]
   NoteBook $p.$name    \
      -arcradius 3   -internalborderwidth 5    \
      -borderwidth 2     \
      -tabbevelsize 0    \
      -homogeneous 0     \
      -tabpady     {8 8} \
      {*}$args
   set wv(w,$name) $p.$name
   return $p.$name
}

###-----------------------------------------------------------------------------
#
# Proc: mkPanedWindow
#
# *::utils::gui::mkPanedWindow W p name args*
#
# erzeugt ein PanedWindow-Widget mit mehreren Teilfenstern
#  unter dem  Widget-Vater _p_ mit dem Namen _name_  im
# Widgetverzeichnis _W_.
#
# Parameter:
#
#   W:      Globales Widgetverzeichnis i.a. wv (ohne $)
#   p:      Parentwidget
#   name:  Name im Widgetverzeichnis muss in gesamten
#            Programm eindeutig sein. Per Default wird der Name
#            automatisch vergeben.
#   args:  Optionen
#
# Optionen:
# -wts str: String mit den Gewichtungen der Teilfenster,
#              jeweils mit _Komma_ getrennt. Damit wird implizit die
#              Anzahl der Teilfenster bestimmt.
#
# -richt ri:  Je nach Richtung *|* oder *-*  werden
#             die Teilfenster *waagrecht* oder
#             *senkrecht* angeordnet. (Default: waagrecht)
#
#       Nach der Kennung *--* können weitere Optionenpaare
#       für _PanedWindow_ angefügt werden.

#
# Ergebnis:
#  Liste {panedwindow teilfenster1 teilfenster2 ..}
#
# siehe auch:
# - <bwidget/PanedWindow.html>
#
# Beispiel:
# (start code)
# global wv
# set erg [::utils::gui::mkPanedWindow wv $p pw \
#   -wts {1,2}     \
#   -richt -       \
#   -- -width 100  \
# ]
# lassign $erg wpw foben funten
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::mkPanedWindow {W p name args} {
   # W      : Array Widgetverzeichnis
   # p      : parent
   # name   : eindeutiger Name
   # args   : Widget-Optionen
   # liefert {w f1 f2 ..}
   upvar $W wv
   variable wNr
   #_proctrace
   
   ##nagelfar variable params
   ::Opt::opts {params} $args {
      {-wts    {1,1}  "Liste Gewichtung Teilfenster, mit ',' getrennt"}
      {-richt  {|}    "Richtung | oder -"}
      {--      ""     "Options für PanedWindow folgen"}
   }
   
   set name [checkName wv $name]
   set wts [split $params(-wts) {,}]
   if {$params(-richt) eq "-"} {
      set side left
   } elseif {$params(-richt) eq "|"} {
      set side top
   } else {
      return -code error "richt:<$params(-richt)> muss | oder - sein"
   }
   set pw [PanedWindow $p.$name -side $side \
      -weights available  \
      -pad 0              \
      {*}$params(--)]
   
   set erg $pw
   set anz [llength $wts]
   for {set i 1} {$i <= $anz} {incr i} {
      set idx [expr {$i -1}]
      lappend erg [$pw add -weight [lindex $wts $idx]]
   }
   
   # Trennlinie blau faerben
   for {set i 1} {$i < $anz} {incr i} {
      $pw.sash${i}.sep configure -background blue
      $pw.sash${i}.but configure -background blue
   }
   set wv(w,$name) $pw
   return $erg
}

###-----------------------------------------------------------------------------
#
# Proc: ic
#
# *::utils::gui::ic size name*
#
# erzeugt ein Icon-Image.
# mit der Grösse *size* das unter
# dem Pfad *name.png*  oder *name.gif* in den Icon-Verzeichnissen
# abgelegt ist.
#
# Das Verzeichnis _lib/icons_
# ist mit 'size'-Unterverzeichnissen eingerichtet.
#
# Parameter:
#     size: Icongrösse 16,22,... (entspricht dem Unterverzeichnis)
#     name: Dateiname des Icons ohne Dateierweiterung (png|gif)
#
# Ergebnis:
#    Das Image wird im Cache _wv(ic,size,name)_ abgelegt.
#
# Beispiel:
# (start code)
# set hlp [::utils::gui::mkButton wv $fo bt,bthlp \
#           -image   [::utils::gui::ic 16 help-hint]      \
#           -command [list DebugHelp]]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::ic {size name}  {
   global wv
   variable iconsDirList
   
   if {[info exists wv(ic,$size,$name)]} {
      return $wv(ic,$size,$name)
   }
   # image erstellen
   set path ""
   foreach dir $iconsDirList {
      #puts [file normalize $dir]
      set path [glob -nocomplain \
         -directory [file join $dir $size] $name.png]
      if {$path ne ""} {break}
      set path [glob -nocomplain \
         -directory [file join $dir $size] $name.gif]
      if {$path ne ""} {break}
   }
   if {$path ne ""} {
      set wv(ic,$size,$name) [image create photo -file $path]
      return $wv(ic,$size,$name)
   }
   puts "Icon $size $name nicht gefunden"
   if {$name eq "script-error"} {
      return ""
   }
   
   ::utils::gui::ic 22 script-error
   #return $wv(ic,22,bug-buddy)
}

###-----------------------------------------------------------------------------
#
# Proc: bittewarten2
#
# *::utils::gui::bittewarten2 txt p title geometry*
#
# zeigt ein Popup-Fenster mit der Sanduhr.
#
# Das Fenster muss mit destroy .. gelöscht werden
#
# Der Text kann mit _<topwidget>.frame.lb configure -text .._
# geändert werden.
#
# Parameter:
#     txt:    Text zum Anzeigen (Default: bitte warten)
#     p:      Parentwidget (Default: wv(w,top))
#     title:  Fenstertitel (Default: bitte warten)
#     geometry:  Höhe und Breite des Fensters (Default: 300x60)
#
# Ergebnis:
#  Topwidget
#
# Beispiel:
# (start code)
# set bw [::utils::gui::bittewarten2 "es dauert leider "]
# ....
# # Text ändern
# $bw.frame.lb configure -text " immer noch"
# ...
# destroy $bw
# (end)

###-----------------------------------------------------------------------------
proc ::utils::gui::bittewarten2  {{txt {bitte warten}} {p {}}\
      {title {bitte warten}} {geometry {300x60}}} {
   
   variable nr
   global wv
   if {$p eq ""} {set p $wv(w,top)}
   if {![winfo exists $p]} {return}
   if {![info exists nr]} {set nr 0}
   
   incr nr
   if {$p == "."} {
      set w ".bittewarten_$nr"
   } else {
      set w "$p.bittewarten_$nr"
   }
   
   catch   {destroy $w}
   set dlg [Dialog $w  \
      -image [Bitmap::get hourglass] \
      -modal none            \
      -parent $p             \
      -title $title          \
      -place center          \
      -geometry 300x60       \
      ]
   set lab [Label [$dlg getframe].lb -text $txt]
   pack $lab -padx 1 -pady 1 -fill both -expand yes
   
   $dlg draw
   update idletasks
   return $dlg
}

###-----------------------------------------------------------------------------
#
# Proc: tblpat
#
# *::utils::gui::tblpat tbl pat fkt par*
#
# prüft, ob in der Tabelle tbl ein Muster <pat> vorkommt. Oder liefert
# alle Fundstellen des Musters
#
#  tblpat tbl pat exists -glob 0/1 -nocase 0/1
#
#  tblpat tbl pat suchen -glob 0/1 -nocase 0/1
#
#  tblpat tbl zeigen -pos liste -msec num
#
# Ergebnis:
#  - exists : 0/1
#  - suchen : Liste {z,s z,s ..}
#  - zeigen : -
#
###-----------------------------------------------------------------------------
proc ::utils::gui::tblpat  {tbl pat fkt args} {
   
   # Argumente belegen
   # args: -gefunden bool -pos liste -msec num
   set argsArr(-glob)   1
   set argsArr(-nocase) 1
   set argsArr(-msec)   3000
   set argsArr(-pos)    {}
   
   array set argsArr $args
   set glob ""
   if {$argsArr(-glob)} {
      set glob -glob
   }
   set nocase ""
   if {$argsArr(-nocase)} {
      set nocase -nocase
   }
   
   
   if {$fkt eq "exists"} {
      set liste [$tbl get 0 end]
      
      # in allen Zeilen suchen
      ##nagelfar ignore
      set result [lsearch $nocase $glob -all $liste $pat]
      if {[llength $result] == 0} {
         return {}
      } else {
         return 1
      }
   }
   
   if {$fkt eq "suchen"} {
      # in Zeilen suchen
      ##nagelfar ignore
      set result [lsearch $nocase $glob -all $liste $pat]
      
      # jetzt auch in den Spalten suchen
      set resListe [list]
      
      foreach z $result {
         set zeile [lindex $liste $z]
         ##nagelfar ignore
         set spalten [lsearch $glob $nocase -all $zeile $pat]
         #puts "sp:$spalten"
         # Position z,sp speichern
         foreach sp $spalten {
            lappend resListe $z,$sp
         }
      }
      puts "pos:$resListe"
      return $resListe
   }
   
}



###-----------------------------------------------------------------------------
#
# Proc: msgow1
#
# *::utils::gui::msgow1 txt msec title  p *
#
# _message ohne warten_ zeigt ein Popup-Fenster mit der Sanduhr. Nach
# msec Millisekunden wird das Fenster gelöscht
#
#
# Parameter:
#     txt:   Text zum Anzeigen
#     msec:   Anzeigedauer (Default: 3000)
#     title:  Fenstertitel (Default: Hinweis)
#     p:      Parentwidget (Default: wv(w,top) oder .)
#
# Ergebnis:
#  keines
#
###-----------------------------------------------------------------------------
###-----------------------------------------------------------------------------
proc ::utils::gui::msgow1  {txt {msec {}} {title {}} {p {}} } {
   #_proctrace
   variable nr
   global wv
   
   # Defaults
   if {$msec eq ""}  {set msec 3000}
   if {$title eq ""} {set title "Hinweis"}
   
   # Parent vorhanden ?
   if {$p ne ""} {
      if {![winfo exists $p]} {
         puts $txt
         return
      }
   } else {
      #Parent vorbelegen
      if {[info exists wv(w,top)]} {
         if {[winfo exists $wv(w,top)]} {
            set p $wv(w,top)
         }
      } else {
         set p .
      }
   }
   
   if {![info exists nr]} {set nr 0}
   incr nr
   if {$p == "."} {
      set w ".msgow_$nr"
   } else {
      set w "$p.msgow_$nr"
   }
   catch {destroy $w}
   set dlg [Dialog $w \
      -image [Bitmap::get hourglass] \
      -modal none            \
      -parent $p             \
      -title $title          \
      -place center          \
      ]
   set lab [Label [$dlg getframe].lb -text $txt]
   pack $lab -padx 1 -pady 1 -fill both -expand yes
   $dlg draw
   update idletasks
   
   after $msec destroy $dlg
   return
}

###-----------------------------------------------------------------------------
#
# Proc: msg
#
# *::utils::gui::msg icon title msg parent clock timeout*
#
# popt eine Meldung mit ClockCursor.
#
# Wird bei _parent_ das zugeordnete Fenster angegeben ,
# ist das Popup immer transparent sichtbar.
# Falls kein GUI vorhanden ist, wird die Meldung mit
# _puts_  ausgegeben. Bei gesetztem _timeout_-Parameter
# wird das Meldungspopup automatisch entfernt.
#
# Parameter:
#     icon:    error|info|warning
#     title:   Specifies a string to display as the title of
#                the message box. The default value is an empty string.
#     msg:     Specifies the message to display in this message box.
#     parent:  Makes window the logical *parent* of the message box.
#               The message box is displayed on top of its parent window.
#               (default: wv(w,top))
#     clock:   Auf dem Widget *clock* wird die Sanduhr angezeigt.
#             (Default: keine Uhr)
#
#     to:    Timeout in sec (Default : kein Timeout)
#
# siehe auch:
# - <TkCmd/messageBox.htm>
#
###-----------------------------------------------------------------------------

proc ::utils::gui::msg {icon title msg {parent {}} {clock {}} {to {0}} } {
   # bringt Meldungspopup ggf mit ClockCursor
   # bei parent sollte das zugeordnete Fenster stehen
   # damit Popup immer transparent sichtbar ist
   # Falls kein GUI vorhanden, puts ...
   #
   # Parameter:
   #   icon     : angezeigtes Icon error|info|warning
   #   title    : Titel des PopupFenster
   #   message  : Meldungstext
   #   parent   : Popu transparent auf parent dargestellt
   #   clock    : Widget zur Anzeige clockCursor
   #              Default {} : kein ClockCursor
   #   to       : Timeout in sec, Default 0
   #-----------------------------------------------------------
   global wv
   
   # kein Tk ?
   if {[info commands winfo] == {} } {
      puts $msg
      return
   }
   
   # Parent vorhanden ?
   if {$parent ne ""} {
      if {![winfo exists $parent]} {
         puts $msg
         return
      }
   } else {
      #Parent vorbelegen
      if {[info exists wv(w,top)]} {
         if {[winfo exists $wv(w,top)]} {
            set parent $wv(w,top)
         }
      } else {
         set parent .
      }
   }
   
   # Toplevel von parent
   set parent [::utils::gui::_getTL $parent]
   
   if {$clock != {}} {
      if {![winfo exists $clock]} {
         puts $msg
         return
      }
      set ctl [winfo toplevel $clock]
   }
   
   if {$clock != {}} {::utils::gui::setClock on $ctl}
   
   # Timeout zur Vermeidung von globalen Grab bei tkdnd
   #
   if {$to} {
      set to [expr {$to *1000}]
      set afterId [after $to {set ::tk::Priv(button) ok}]
   }
   
   tk_messageBox         \
      -message "$msg"    \
      -title   "$title"  \
      -icon    $icon     \
      -parent  $parent
   
   catch {after cancel $afterId}
   if {$clock != {}} {::utils::gui::setClock off $ctl}
}

###-----------------------------------------------------------------------------
#
# Proc: centerWindow
#
# *::utils::gui::centerWindow parent me*
#
# plaziert ein Fenster mitten auf dem Parent-Fenster
#
# Parameter:
#     parent:  Parentwidget
#     me:      neues Widget
#
###-----------------------------------------------------------------------------###-----------------------------------------------------------------------------###-----------------------------------------------------------------------------###-----------------------------------------------------------------------------
proc ::utils::gui::centerWindow {parent me  } {
   
   set oldsx [winfo width  $parent]
   set oldsy [winfo height $parent]
   set oldpx [winfo rootx  $parent]
   set oldpy [winfo rooty  $parent]
   set centerx [expr {$oldpx + ($oldsx / 2)}]
   set centery [expr {$oldpy + ($oldsy / 2)}]
   set xtop [expr {$centerx - [winfo reqwidth $me]/2}]
   set ytop [expr {$centery - [winfo reqheight $me]/2}]
   if { $xtop < 0 || $ytop < 0 } {
      set xtop 400
      set ytop 300
   }
   wm geometry $me +$xtop+$ytop
}

###-----------------------------------------------------------------------------
#
# Proc: geoObenRechts
#
# *::utils::gui::geoObenRechts win h w dx dy*
#
# liefert geometry für Postion rechts oben
#
# Parameter:
#     win : Window
#     h   : Höhe Zielfenster   (default: 0)
#     w   : Breite Zielfenster (default: 0)
#     dx  : Versatz (default: 0)
#     dy  : Versatz (default: 0)
#
# Ergebnis:
#     String für -geometry
#     wxh+x+y oder +x+y wenn h oder w = 0
#
###-----------------------------------------------------------------------------###-----------------------------------------------------------------------------###-----------------------------------------------------------------------------###-----------------------------------------------------------------------------
proc ::utils::gui::geoObenRechts {win {h 0} {w 0} {dx 0} {dy 0} } {
   
   set win [winfo toplevel $win]
   # Höhe und Breite eig Fenster
   set winH [winfo height $win]
   set winW [winfo width $win]
   
   # xy eig. Fenster
   set x [winfo x $win]
   set y [winfo y $win]
   
   # xy rects oben
   set xro [expr {$x + $winW + $dx}]
   set yro [expr {$y + $dy}]
   
   # Ziel Höhe und Breite angegeben
   if {$w != 0 && $h != 0} {
      return ${w}x${h}+${xro}+${yro}
   } else {
      return +${xro}+${yro}
   }
}


###-----------------------------------------------------------------------------
#
# Proc: setClock
#
# *::utils::gui::setClock onoff w1*
#
# setzt/löscht die Anzeige der Sanduhr.
#
# Parameter:
#     onoff:  steuert anzeigen/löschen der Sanduhr
#     w1:     auf dem Toplevel-Widget des Widgets _w1_ wird die Sanduhr
#          gesetzt/gelöscht.
#
###-----------------------------------------------------------------------------
proc ::utils::gui::setClock { onoff w1 } {
   
   if {[info commands winfo] != {}} {
      set keinTk false
   } else {
      set keinTk true
   }
   # Windowoberflaeche ?
   if {$keinTk || ![winfo exists $w1]} {return}
   
   # F : topwidget fehlt -cursor
   if {[winfo class $w1] eq "topwidget"} {
      set w1 [winfo parent $w1]
   }
   # Cursor setzen
   if {$onoff=={on}} {
      ::cursor::propagate $w1 watch
   } else {
      ::cursor::restore $w1
   }
   update idletasks
}

###-----------------------------------------------------------------------------
#
# Proc: synchScroll
#
# *::utils::gui::synchScroll wid1 wd2 sbar1 sbar2 richtung*
#
# zwei parallele Widgets werden synchron gescrollt.
#
# Die zwei vorhandenen Scrollbars und zwei parallele
# Widgets werden so umkonfiguriert, dass die beiden Widgets
# synchron scrollen.
# Das funktioniert waagrecht und senkrecht.
#
# Parameter:
#     wid1:  ein paralles Widgetpaar (Listbox, Text etc)
#     wid2:  Widget 2
#     sbar1:   ein paralles Scrollbarpaar
#     sbar2:   Scrollbar 2
#     richtung:  Ausrichtung der Scrollbars v|h
#
# Beispiel:
# (start code)
#   # synchr Scroll
#   set sbyL  [winfo parent $tblCSV].yscroll
#   set sbyR  [winfo parent $tblSDB].yscroll
#   set sbyWL [winfo parent $tblCSV].xscroll
#   set sbyWR [winfo parent $tblSDB].xscroll
#
#   ::utils::gui::synchScroll $tblCSV $tblSDB $sbyL $sbyR v
#   ::utils::gui::synchScroll $tblCSV $tblSDB $sbyWL $sbyWR h
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::gui::synchScroll {wid1 wid2 sbar1 sbar2 richtung} {
   #-----------------------------------------------------------------------
   proc ::utils::gui::_setScroll {sbar args} {
      $sbar set {*}$args
      {*}[$sbar cget -command] moveto [lindex [$sbar get] 0]
   }
   
   #-----------------------------------------------------------------------
   proc ::utils::gui::_synchScroll {widgets args} {
      #  scrollt mehrere Widgets synchron
      #-----------------------------------------------------------------------
      foreach w $widgets {$w {*}$args}
   }
   
   if {$richtung eq "v"} {
      set opt -yscrollcommand
      set fkt yview
   } elseif {$richtung eq "h" } {
      set opt -xscrollcommand
      set fkt xview
   } else {
      return -code error "richtung <$richtung> muss v|h sein"
   }
   
   $wid1 configure $opt [list ::utils::gui::_setScroll $sbar1]
   $wid2 configure $opt [list ::utils::gui::_setScroll $sbar2]
   
   foreach sbar [list $sbar1 $sbar2] {
      $sbar configure -command \
         [list ::utils::gui::_synchScroll [list $wid1 $wid2] $fkt]
   }
}

###-----------------------------------------------------------------------------
#
# Proc: selectColor
#
# *::utils::gui::selectColor p col title*
#
# zeigt den _ColorDialog_ zur Auswahl einer Farbe.
#
# Die bisherige (alte) Farbe wird angezeigt.
#
# Parameter:
#     p:      Parentwidget
#     col:     bisheriger Farbname oder -code
#     title:  Fenstertitel des Dialogs (Default: Farbauswahl)
#
# Ergebnis:
#    Farbcode z.B. #ffff00
#
#
###-----------------------------------------------------------------------------
proc ::utils::gui::selectColor {p col {title {} } } {
   
   if {$title eq ""} {
      set title Farbauswahl
   }
   
   set result [tk_chooseColor \
      -parent $p     \
      -initialcolor $col    \
      ]
   return $result
}
###-----------------------------------------------------------------------------
#
# Proc: dpi
#
# *::utils::gui::dpi*
#
# liefert 'uhd' oder 'hd' je nach Bildschirmauflösung
#
# Ergebnis:
#    uhd|hd
#
#
###-----------------------------------------------------------------------------
proc ::utils::gui::dpi {} {
   
   set dpi [winfo pixels . 1i]
   
   if {$dpi >= 96} {return uhd}
   if {$dpi <= 90} {return hd}
   
}