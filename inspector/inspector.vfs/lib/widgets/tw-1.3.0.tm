# -*-Tcl-*-
# ###################################################################
#
#  FILE: "tw.tm"
#                                    created: 12.10.2014 14:00:00
#                                last update: 12.10.2014 14:00:00
#
#  Description:
#  widgets::tw-Package enthält
#  Megawidget tw (links-rechts-Auswahl)
#
#  Syntax:
#    $tw win args
# 
package provide widgets::tw 1.3.0

#  History
##  17.02.2025 mlrd 1.3.0   -bd -bg -relief
##  29.04.2024 mlrd 1.2.0   mit scroll xy
##  20.12.2021 mlrd 1.1.0   _cget,conf
##  16.12.2021 mlrd 1.0.3   bh 500x500
##  23.11.2021 mlrd 1.0.2   win ..abc -> .abc
##  30.09.2021 mlrd 1.0.1   tw geo 750x700
##  06.09.2021 mlrd 1.0.0   topwidget -> tw, w = neue Widget
##  22.08.2020 mlrd 2.0.1   2.0.0 zurück
##  06.03.2020 mlrd 2.0.0   ::widgets::tw::tw
#                           tl und multi=1 leicht versetzen
#                           frames pad 0,
##  12.01.2020 mlrd 1.0.8   tw frame padxy 0
##  30.06.2019 mlrd 1.0.7   Doku
##  20.05.2019 mlrd 1.0.6   Toplevel zentr bei -parent 
##  07.04.2018 mlrd 1.0.5   Farbe exitbutton
##  10.02.2018 mlrd 1.0.4   lindex str 0 -> str
##  21.10.2017 mlrd 1.0.3   -nobbox -nobtexit
##  18.10.2017 mlrd 1.0.2   centerwindow
##  02.06.2017 mlrd 00.00   Original
# ###################################################################
package require Opts


namespace eval ::widgets::tw {
   #---------- Variable ------------------------------------------------
   variable test           0
   variable packagename    {widgets::tw}
   variable topNum         0
   variable oldWin         {} ;# Win n-1
   
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
  #          # 100: Argumente tw-Aufruf
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
  #       
  #       ::utils::dbg::debug $num $packagename $titel $script
  #    }
  #    #--------------------------------------------------------------------
  #    proc _proctrace {} {
  #       #--------------------------------------------------------------------
  #     #  set infoLev [info level -1]
  #     #  _dbg 1 Proctrace {set infoLev}
  #    }
  #    #--------------------------------------------------------------------
  #    proc _resulttrace {msg} {
  #       #--------------------------------------------------------------------
  #       variable packagename
  #       set infolevel [info level -1]
  #       ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
  #    }
  #    
  #    
  ###-----------------------------------------------------------------------------
   #--------------------------------------------------------------------
   #        Hauptprozeduren
   #--------------------------------------------------------------------
   
   # win is used as a unique token to create arrays for each widget instance
   #--------------------------------------------------------------------
   proc _getAr {win suffix name} {
      #--------------------------------------------------------------------
      set arName __tw[set win][set suffix]
      uplevel [list upvar \#0 $arName $name]
      return $arName
   }
   
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: tw
   #
   # *::widgets::tw win args*
   # 
   # erzeugt ein Toplevel-Fenster eventuell mit einem Text- oder
   # Tablelistwidget. Das tw kann singulär oder mehrfach
   # angelegt werden. Der Rahmen für die Tasten und der Exitbutton
   # kann unterdrückt werden.
   #
   #
   # Parameter:
   #     win: Parentwidget -> neuer Widgetname
   #     args: Optionen
   #
   # Optionen:
   #
   #  -titel str:      Fenstertitel des Toplevelwidget
   #  -geometry geo: legt Größe und Position des Toplevel-Fenster
   #        fest. (Default: 500x350)
   #  -multi bool: es können mehrere tw parallel angelegt
   #                   werden (Default: 1)
   #  -widget widget: text , tablelist oder keine Angabe
   #  -pfad datei: Im Textwidget wird die Datei angezeigt.
   #  -text Txt:       Im Textwidget wird der Text angezeigt. Es kann
   #           entweder -pfad oder -text angegeben werden. 
   #
   #  -tdx TDX:        TDX ist eine Matrix, die für jede Spalte
   #        eine Liste {name titel breite sorttyp} enthält.
   #        (siehe Beispiel ::utils::gui::mkTable)
   #
   # -namen liste:  Liste mit den Spaltennamen. Diese Option kann
   #          vereinfacht anstatt der Option -tdx verwendet werden.
   #
   # -matrix dat:      Die Matrixdaten (Liste in Liste) werden in der
   #    Tabelle angezeigt.
   #
   # -buttonbox bool:   Rahmen für Tasten (Default:1)
   #
   # -exitbutton bool: Exitbutton  (Default: 1)                              
   #
   # -parent p: Toplevel wird p zentriert (Default : keine)
   #
   # Optionenliste für das Text- oder TablelistWidget
   # müssen am *Schluss der Argumente* stehen
   # und werden mit _--_ eingeleitet.
   #
   # Ergebnis:
   #
   #  Widget tw  (Klasse tw) eventuell mit einem scrollbaren
   #  Text- oder Tablelistwidget.
   #
   # Funktionen:
   #
   # *$tw p ?Optionen?*:
   # 
   #      erzeugt ein toplevel-Widget. *p* ist der Parent oder Pfadname
   #      des zu erzeugenden Widgets. Wird ebenfalls als Ergebnis
   #      zurückgegeben.
   # 
   #      ** -multi :1 -> p ist Parent i.a. wv(w,top)
   #      ** -multi :0 -> p ist Name des neuen Widgets
   #
   # *$tw winfo ?subwidget?*:
   # 
   #        liefert Subwidgetpfade von 
   #         toplevel frame tablelist text buttonbox exitbutton
   #
   #  Wenn ?subwidget? fehlt, wird die Liste der Subwidgets geliefert
   #
   #
   # *$tw configure ?opt val? ?opt val?*:
   # 
   #   liefert/setzt die spez. Optionen von tw
   #
   # *$tw cget opt*:
   # 
   #   liefert die spez. Optionen von tw
   #
   #
   # siehe auch:
   # - <TkCmd/text.htm>
   # 
   # - <tablelistWidget.html>
   # 
   # - <mkTable.html>
   #
   # Beispiel:
   # (start code)
   # global wv
   # set tw [::widgets::tw $gd(w,top).neu  \
   #    -widget tablelist   \
   #    -titel TEST-Tabelle \
   #    -geometry 200x200   \
   #    -namen {SP1 Sp1}    \
   #    -matrix {{1 2 } {3 4 }} \
   #    -- \
   #    -background white \
   # ]
   # (end)
   
   ###-----------------------------------------------------------------------------
   
   proc ::widgets::tw {win args} {
      #--------------------------------------------------------------------
      #_proctrace
      variable topNum
      variable oldWin

      #_dbg 100 Win {set win}
      #_dbg 100 Args {::utils::printlistestring args}
      
      ::Opt::opts {params} $args {
         {-titel      {}  "Fenstertitel"}
         {-geometry   {500x500} "Geometry füt Toplevel"}
         {-widget     {}  "text oder tablelist "}
         {-multi      {1} "mehrere Toplevelwidgets "}
         {-tdx        {}  "Tabledescription"}
         {-namen      {}  "Spaltennamen"}
         {-matrix     {}  "Matrix zum Einfügen"}
         {-text       {}  "Textstring zum Einfügen"}
         {-pfad       {}  "Datei zum Einfügen"}
         {-buttonbox  {1} "mit Buttonbox"}
         {-exitbutton {1} "mit Button exit"}
         {-parent     {}  "Parent zur zentrierten Anzeige"}
         {--          {} "Options für Tablelist folgen"}
      }

      if {$params(-multi)} {
         incr topNum
         set topview "${win}_$topNum"
      } else {
         catch {destroy $win}
         set topview $win
      }
      set win $topview
      #_dbg 100 TopView {set topview}
      

      # win darf nicht ..abc sein
      # -> .abc
      if {[string range $win 0 1] eq ".."} {
         set win [string range $win 1 end]
      }
    
      # params -> ar
      #
      set arV [widgets::tw::_getAr $win config "ar"]
      foreach k [array names params] {
         set ar($k) $params($k)
      }
      
      #  option  optName optDB  default wert
      set ar(optNamen) {-titel -geometry -multi -widget -pfad -text \
            -tdx -namen -matrix -buttonbox -exitbutton -parent}
      set ar(opts) {
         {-titel      {titel}      {Titel}      {}        {}}
         {-geometry   {geometry}   {Geometry}   {500x350} {}}
         {-multi      {multi}      {Multi}      {false}   {}}
         {-widget     {widget}     {Widget}     {}        {}}
         {-pfad       {pfad}       {Pfad}       {}        {}}
         {-text       {text}       {Text}       {}        {}}
         {-tdx        {tdx}        {Tdx}        {}        {}}
         {-namen      {namen}      {Namen}      {}        {}}
         {-matrix     {matrix}     {Matrix}     {}        {}}
         {-buttonbox  {buttonbox}  {Buttonbox}  {true}    {}}
         {-exitbutton {exitbutton} {Exitbutton} {true}    {}}
         {-parent     {parent}     {Parent}     {}        {}}
      }

      # aktuelle Optionen belegen
      foreach opt $ar(optNamen) {
         if {![info exists ar($opt)]} {continue}
         set idx [lsearch $ar(optNamen) $opt]
         lset ar(opts) $idx 4 $ar($opt)
      }

      
      # Megawidget zeichnen --------------------------------------
      #
      widgets::tw::_create $win
      # Abschluss
      #
      rename $win _junk$win
      bind $win <Destroy> [list ::widgets::tw::_destroy $win %W]
      interp alias {} $win {} ::widgets::tw::_instanceCmd $win
      set oldWin $win
      return $win
   }
   
   #-----------------------------------------------------------------------
   proc _create {win} {
      # zeichnet das Megawidget
      #-----------------------------------------------------------------------
      #_proctrace
      variable topNum
      variable oldWin
      
      set arV [widgets::tw::_getAr $win config "ar"]
      ##nagelfar variable ar varName
      
      # Args
      #
      set titel  $ar(-titel)
      set geo    $ar(-geometry)
      set widget $ar(-widget)
      set options $ar(--)
      # tablelist
      set tdx    $ar(-tdx)
      set namen  $ar(-namen)
      set matrix $ar(-matrix)
      # text
      set pfad   $ar(-pfad)
      set str    $ar(-text)
      
      # Toplevel anlegen
      #
      
      toplevel $win  -class tw
      if {$titel == {}} {set $titel $win}
      set ar(w,toplevel) $win
      
      set parent $ar(-parent)
      if {$parent ne ""} {
         ::utils::gui::centerWindow $parent $win
      }
      wm title $win $titel
      wm geometry $win $geo
      set fr [frame $win.fr -relief flat -borderwidth 0]
      pack $fr -padx 0 -pady 0 -fill both -expand 1 -side top
      set ar(w,frame) $fr
      
      if {$ar(-buttonbox)} {
         # Rahmen für Tasten
         set fbb [frame $fr.fbb -borderwidth 1 \
            -relief sunken -bg skyblue1]
         pack $fbb -padx 1 -pady 1 -fill x -side bottom
         set ar(w,buttonbox) $fbb
         
         if {$ar(-exitbutton)} {
            Button $fbb.end \
               -background  skyBlue1           \
               -borderwidth 0                  \
               -image       [::utils::gui::ic 22 edit-delete]  \
               -helptext    {Fenster schliessen}  \
               -highlightthickness 0 \
               -command  [list destroy $win]
            pack $fbb.end -padx 3 -pady 3 -side left
            set ar(w,exitbutton) $fbb.end
         }
      }
      # Toplevel mit Text oder TablelistWidget oder nichts
      # füllen
      
      if {$widget eq "text"} {
         # Textwidget mit Scrollbars anlegen
         set sw [ScrolledWindow $fr.sw -auto both]
         pack $sw -padx 0 -pady 0 -expand yes -fill both -side top
         
         set t [text $fr.text -padx 3 -pady 3 -wrap none {*}$options]
         $sw setwidget $t
         set ar(w,text) $t
         
         if {$str  != {}} {$t insert end $str}
         if {$pfad != {}} {$t insert end [::utils::file::readfile $pfad]}
         
         # scroll xy
         ::utils::gui::scrollxy $t
         
         
      } elseif {$widget eq "tablelist"} {
         # Tablelistwidget mit Scrollbars anlegen
         set sw [ScrolledWindow $fr.sw -auto both]
         pack $sw -padx 0 -pady 0 -expand yes -fill both -side top
         
         set tbl [tablelist::tablelist $fr.tbl \
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
            {*}$options  \
            ]
         option add *tbl*Entry.background white
         $sw setwidget $tbl
         set ar(w,tablelist) $tbl
         
         # Spalten inittialis.
         if {$tdx != {}} {
            ::utils::gui::TblColInit $tbl $tdx
         } elseif {$namen != {}} {
            $tbl configure -columns {}
            $tbl configure -columntitles $namen
            set num 0
            foreach na $namen {
               $tbl columnconfigure $num -name $na
               incr num
            }
         }
         
         # Tabelle füllen
         if {$matrix != {}} {$tbl insertlist end $matrix}
         
         # scroll xy
         ::utils::gui::scrollxy $tbl
         
         
      }
      
      return $win
   }
   
   
   #--------------------------------------------------------------------
   proc _destroy  {win dWin} {
      #--------------------------------------------------------------------
      #_proctrace
      
      if {![string equal $win $dWin]} {return}
      _getAr $win config ar
      
      catch {rename $win {}}
      array unset ar
   }
   
   #--------------------------------------------------------------------
   proc _instanceCmd {self cmd args} {
      #--------------------------------------------------------------------
      #_proctrace
      _getAr $self config "ar"
      ##nagelfar variable ar varName
      #_dbg 100 "InstanceCmd"  {format "$self $cmd $args" }
      
      # SubWidgetnamen aus ar(w,name)
      set widgetListe [list]
      foreach key [array names ar "w,*"] {
         if {![info exists ar($key)]} {continue}
         set ele [split $key ","]
         lassign $ele dum name
         lappend widgetListe $name
      }
      switch -glob -- $cmd {
         winfo {
            # winfo subwidget
            set swid [lindex $args 0]
            if {$swid eq ""} {
               return $widgetListe
            } else {
               if {[lsearch $widgetListe $swid] >=0} {
                  return $ar(w,$swid)
               } else {
                  return -code error \
                     "$self winfo <$swid> ->Subwidget falsch. Muss in <$widgetListe> enthalten sein"
               }
            }
         }
         cget {
            return [_cget $self $args]
         }
         conf* {
            return [_conf $self $args]
         }
         default {
            set cmds "winfo|conf|cget"
            return -code error \
               "invalid cmd to $self $cmd $args\n-> tw $cmds ?args?"
         }
      }
   }
   
   #--------------------------------------------------------------------
   proc _conf {win args} {
      # liefert alle Optionen oder setzt manche Optionen
      # {  opt    optName OptClass Default Wert}
      #--------------------------------------------------------------------
      
      ##nagelfar variable ar varName
      set arV  [_getAr $win config "ar"]
      set args {*}$args
      
      # konfigurierbare Optionen
      set confOpts {-titel -geometry -pfad -text -tdx -namen }
      
      #
      # wenn opts leer, alle Optionen als Liste liefern
      #
      if {$args eq ""} {
         return $ar(opts)
      }
      
      if {[llength $args] & 1} {
         return -code error \
            "die Optionen und Werte müssen paarweise eingegeben werden:\n$args"
      }
      
      #
      # mehrere  Optionen setzen
      #
      foreach {opt wert} $args {
         switch -exact -- $opt  {
            -pfad -
            -text {
               if {$ar(-widget) eq "text"} {
                  set txt [$win winfo text]
                  if {[winfo exists $txt]} {
                     $txt delete 1.0 end
                     if {$opt eq "-text"} {
                        $txt insert end $wert
                     } else {
                        if {![file readable $wert]} {
                           return -code error "<$wert> nicht lesbar"
                        }
                        set text [::utils::file::readfile $wert]
                        $txt insert end $text
                     }
                  }
               } else {
                  return -code error "<-text> oder <-pfad> nur möglich bei -widget text"
               }
            }
            -tdx -
            -namen {
               if {$ar(-widget) eq "tablelist"} {
                  set tbl [$win winfo tablelist]
                  if {[winfo exists $tbl]} {
                     if {$opt eq "-namen"} {
                        $tbl configure -columntitles $wert
                     } else {
                        ::utils::gui::TblColInit $tbl $wert
                     }
                  }
               } else {
                  return -code error "<-namen> oder <-tdx>  nur möglich bei -widget tablelist"
               }
            }
            -geometry {
               wm geometry $win $wert
            }
            -titel    {
               wm title $win $wert
            }
            -borderwidth -
            -bd {
               $win.fr configure -borderwidth $wert
            }
            -background -
            -bg {
               $win.fr configure -background $wert
            }
            -relief  {
               $win.fr configure -relief $wert
            }
            default {
               return -code error \
                  "Option <$opt> unbekannt. Optionen :$confOpts"
            }
         } ; # end switch
         
         # Optionen neu belegen
         set ar($opt) $wert
      }
      
      # aktuelle Optionen belegen
      foreach opt $ar(optNamen) {
         if {![info exists ar($opt)]} {continue}
         
         set idx [lsearch $ar(optNamen) $opt]
         lset ar(opts) $idx 4 $ar($opt)
      }
      
   }
   
   #--------------------------------------------------------------------
   proc _cget {win args} {
      # liefert Wert von einer Option
      #--------------------------------------------------------------------
      _getAr $win config "ar"
      
      if {[llength $args] != 1} {
         return -code error \
            "so ist richtig: tw cget <opt>"
      }
      
      if {![info exists ar($args)]} {
         return -code error \
            "falsche Option <$args>. Optionen :$ar(optNamen)"
      }
      return $ar($args)
   }
   
}