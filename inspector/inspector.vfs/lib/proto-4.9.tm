# -*-Tcl-*-
# ###################################################################
#
#  FILE: "proto.tm"
#                                    created: 22.01.2012 14:00:00
#
#  Description:
#  proto-Package
#
#
#  History
#
#  modified   by   rev     reason
#  ---------- ---- ------  -------------------------
#  22.08.2024 mlrd 04.9    source2 protoDir
#  22.08.2024 mlrd 04.8    source2
#  01.10.2022 mlrd 04.7    Dok verbessert
#  26.06.2022 mlrd 04.6    _protofile: geschacht. Includes
#  03.06.2022 mlrd 04.5    -tlmode neu
#  21.05.2022 mlrd 04.4    Doku
#  18.07.2020 mlrd 04.3    _protofile rekursiv incl
#  16.07.2020 mlrd 04.1    _insertBase
#  15.07.2020 mlrd 04.0    proto::info,proto::source
#  16.05.2020 mlrd 03.3    name mit Fehler
#  04.02.2020 mlrd 03.2    topwidget
#  04.02.2020 mlrd 03.1    name(base name id)
#  28.01.2020 mlrd 03.0    V4
#  30.06.2019 mlrd 02.0.2  Doku
#  04.06.2018 mlrd 02.0.1  checkname nur beim 1.Aufruf
#  21.05.2018 mlrd 02.00   Anpassung an proto V3
#  08.02.2018 mlrd 01.00   Original
# ###################################################################


package provide proto 4.9

namespace eval proto {
   #---------- Variable ------------------------------------------------
   variable test             0
   set scriptDir             [file dirname [info script]]
   variable packagename      {proto}
   variable checkKollisionNr 1
   variable baseD            {}  ;# dict: modul -> base
   variable windowListe      {}
   
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
   #    #-----------------------------------------------------------------------
   ###-----------------------------------------------------------------------------
   proc init  {testp} {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      variable test
      
      set test $testp
      return
      #Resulttrace
   }
   
   #--------------------------------------------------------------------
   #
   # Proc: proto::source2
   #
   # *::proto::source2 args*
   #
   # liest die Proto(typ)Datei ein, sucht und expandiert die
   # Includedateien.
   # Die protoDatei wird über modul und protodir bestimmt. 
   #
   # Parameter:
   #     -modul    : Name des Moduls
   #     -protodir : Verzeichnis Protodatei (Default: proto unter Src-Dir)
   #     -base     : Anker des Prototyps im Zielprogramm (i.a. ein Frame)
   #     -incldirlist: Liste der Include-Verzeichnisse (Default: protodir)
   #     -tlmode   : Toplevelmode single|multi (Default : Blank)
   #
   # Ergebnis:
   #    Erfolg : 0
   #
   # Beispiel:
   # (start code)
   #
   #   # Prototyp einlesen
   #   #
   #
   #   if {[::proto::source2 -modul $modul -base $p ]} { exit}
   #   
   # (end)
   #    *Prototyp mit multi Toplevel*
   #
   #   oberstes Widget *tw* oder *toplevel* in der Proto-Datei.
   # 
   #   *Achtung*: die Option -multi in tw muss *false* sein
   #
   # (start code)
   #   set ::base $wv(w,top) ;# !!
   #   set modul toplevel
   #
   #   if {[::proto::source2 -modul toplevel -base $::base $path -tlmode multi] } {exit}
   # (end)
   #
   #
   #   *Prototyp mit single Toplevel*
   # 
   #    wie bei Multi nur -tlmode single.
   #    Achtung bei mehreren Single-Toplevel im Programm
   #
   #   *Dialog*
   # 
   # (start code)
   #   global dialogWin
   #   set ::base $wv(w,top)
   #   set modul dialog
   #   catch {destroy $dialogWin}  ;# !!!
   #   if {[::proto::source2 -modul dialog -base $::base  ]} {exit}
   # 
   #   set dialogWin [::proto::window dialog dialog]
   #   return 
   # (end)
   ###--------------------------------------------------------------------------
   
   #-----------------------------------------------------------------------
   proc ::proto::source2 {args} {
      # liest die Protodatei und expandiert die Includedateien
      #-----------------------------------------------------------------
      variable baseD
      variable scriptNeu
      variable windowListe
      variable baseProto
      variable tlNr  ;# Nr für MultiToplevel
      
      set windowListe [list]
      set scriptNeu ""
      
      if {![info exists tlNr]} { set tlNr -1}
      
      ::Opt::opts opts $args {
         {-modul    {}  "Modulname (obligat)"}
         {-base     {}  "Einhängepunkt im gui (obligat)"}
         {-protodir {}  "Verzeichnis Prototypen "}
         {-incldirlist {}  "Verzeichnis Incl-Prototypen  (Default: protodir)"}
         {-tlmode   {{oneof multi single {}}}  "Prototyp ist Multilevel multi|single"}
      }
      
      set tlMode      $opts(-tlmode)
      set base        $opts(-base)
      set modul       $opts(-modul)
      set protoDir    $opts(-protodir)
      set incldirlist $opts(-incldirlist)
      
      # baseProto : basis vom Hauptprotofile
      set baseProto $base
      
      # protodir vorbelegen: proto unterhalb sourcedir
      if {$protoDir eq ""} {
         set protoDir  [file join $::scriptDirMain proto]
      }
      set path [file join $protoDir ${modul}.tcl]
      
      # base anpassen bei MultiToplevel
      #
      if {$tlMode eq "multi"} {
         # multi TL
         incr tlNr
         set base ${base}._tw_$tlNr
      } elseif {$tlMode eq "single"} {
         # single TL
         catch {destroy ${base}._tw_$tlNr}
         incr tlNr
         set base ${base}._tw_$tlNr
      }
      #puts "base:$base tlMode:$tlMode"
      
      # incldirlist vorbelegen
      if {$incldirlist eq ""} {
         set incldirlist $protoDir
      }
      
      # protofile und inclDateinen rekursiv aufrufen
      _protofile $base $path false $incldirlist
      
      # WidgetlisteArray anlegen
      ::proto::_setWidArr $windowListe $base
      
      #::utils::printdict $baseD
      # scriptNeu : protodatei.tcl und incl aneinander
      # puts sriptNeu\n$scriptNeu
      #::utils::file::writefile ~/test.tcl $scriptNeu
      set ::base $base
      if {[catch {eval $scriptNeu} msg]} {
         ::utils::gui::msg error \
            "Fehler proto::source2" "eval script:$msg\n$::errorInfo"
         return 1
      }
      
      return 0
   }
   
   
   #-----------------------------------------------------------------------
   proc ::proto::_protofile {base path isIncl incldirlist } {
      # verarbeitet eine prototyp-Datei und rekursiv die Includes
      # hängt bearbeitete Dateizeilen an scriptNeu
      # basis  : basis vom Hauptproto bzw Includebasis
      # isIncl : es idt eine IncludeDatei
      # incldirlist : wo liegen die Includedateien
      #
      # protofile liest die prototyp.tcl Datei ein und speichert sie
      # zeilenweise in ein script scriptNeu.
      # Entdeckte Include-Protodateien werden ebenfalls rekursiv
      # im ScriptNeu eingefügt. Die einzelnen Zeilen werden
      # verändert:
      # Hinweis 1
      # #include $base.0.nb.ftab,mess.fr,mess.22.15 zeitbereich_mess.tcl
      # Aus der include-Zeile wird inclBasis und includeDatei entnommen.
      # In allen IncludeZeilen werden Adressen um die IncludeBasis
      # ergänzt: frame $base.0  -> frame $base.0.nb.ftab,mess.fr,mess.22.15
      # Wegen geschachtelten Includes werden die InclBasen in einem
      # Stack gepflegt und zur Anpassung der inclZeilen entnommen.
      # Hinweis 2:
      # In jeder Zeile wird nach einem Widget mit Namen gesucht
      # und in der windowListe abgelegt.
      # Hinweis 3:
      # In der Protodatei und allen IncludeDateien wird nach
      # dem Modul gesucht und die Beziehung modul -> base
      # im Dictionary baseD gespeichert.
      #-----------------------------------------------------------------------
      #_proctrace
      variable scriptNeu
      variable windowListe
      variable baseD
      
      # verwaltet die geschachtelten InclBasen
      variable inclBaseStack
      if {![info exists inclBaseStack]} {
         set inclBaseStack [list]
      }
      #puts "\nprotofile $base [file tail $path] isincl:$isIncl"
      #::utils::printliste inclBaseStack
      
      set modul xxx
      
      if {$isIncl} {
         set scriptLines [::proto::_readIncl $path $incldirlist]
         if {$scriptLines eq ""} {return}
         # Endekennung
         lappend scriptLines {# incl ende}
      } else {
         if {[catch {::utils::file::readliste $path} scriptLines]} {
            ::utils::gui::msg error "Fehler proto::source2" $scriptLines
            return 1
         }
      }
      
      #
      # proto-tclDatei zeilenweise lesen, nach Include und
      # modulname suchen
      #
      foreach zeile $scriptLines {
         #
         # nach incl suchen, liefert inclBasis, inclDatei
         #
         if {[regexp -- {^\s*#include \$([^ ]+) ([^ ]+)\s*} \
               $zeile dum basis inclDatei]} {
            set ele [split $basis "."]
            set basis  [join   [lrange $ele 1 end-1]  "."]
            # puts "inclBasis :$basis"
            
            set inclBasis $basis
            if {$inclBasis ne ""} {
               lappend inclBaseStack $inclBasis
            }
            
            #::utils::printliste inclBaseStack
            _protofile $basis $inclDatei true $incldirlist
         }
         
         if {$isIncl} {
            # basis in allen inclZeilen anpassen (siehe Hinweis 1)
            set inclBaseNeu "base.[join $inclBaseStack {.}]"
            #puts "qneu: $inclBaseNeu"
            #puts $zeile
            regsub -all -- {base} $zeile $inclBaseNeu zeile
            #puts $zeile
                       # doppelte . entfernen
            regsub -all {\.\.} $zeile {\.} zeile

         }
         
         # Ende incl ?
         if {[string match {# incl ende} $zeile]} {
            # Stack verkleinern
            set inclBaseStack [lrange $inclBaseStack 0 end-1]
         }
         
         
         # nach modulzeile 'variable modul name' suchen
         #
         if {[regexp -- {^\s*variable\s+modul\s+([_\w]+)} \
               $zeile dum modul]} {
            # Dict: modul -> base ergänzen /Hinweis 3
            _insertBase $modul $base
         }
         
         # nach Widgets suchen (Hinweis 2)
         #
         set erg [_suchWidget $zeile]
         if {$erg ne ""} {
            lassign $erg window id
            # windowListe ergänzen
            lappend windowListe [list $base $modul $window $id]
         }
         
         append scriptNeu $zeile\n
         
      } ;# proto-tclDatei
      
      return
   }
   
   
   #-----------------------------------------------------------------------
   proc ::proto::_setWidArr {windowListe baseProto} {
      # legt das widArr an
      # windowListe : widgetListe {base modul win ..}
      # widArr key:base°modul°name wert:win
      # baseProto : Basis vom Haupt-Protofile (nicht inclDatei)
      #-----------------------------------------------------------------------
      variable widArr
      
      array set widArr [list]
      foreach el $windowListe {
         lassign $el base modul win id
         # Basis anpassen (siehe insertBase)
         regsub -all -- "base.0" $base $baseProto base
         regsub -all -- "base" $win $baseProto win
         
         # nur benannte id
         if {![string is integer $id]} {
            set widArr(${base}°${modul}°$id) $win
         }
      }
      #parray widArr
      return
   }
   
   
   #-----------------------------------------------------------------------
   proc ::proto::_readIncl {name incldirlist} {
      # sucht die inclDatei in incldirlist
      # inclName    : Name der inclDatei
      # incldirlist : Liste Verzeichnisse
      #-----------------------------------------------------------------------
      #_proctrace
     
      # Extension mit .tcl ergänzen
      #
      if {[file extension $name] eq ""} {
         set name "$name.tcl"
      }
      
      # Protodatei mit Verzeichnis ?
      #
      if {[file dirname $name] eq "."} {
         # Verzeichnisse testen
         foreach dir $incldirlist {
            set f [file join $dir $name]
            if {[file readable $f]} {
               return [::utils::file::readliste $f]
            }
         }
         # nicht gefunden
         set msg "Include <$name> in <$incldirlist> nicht gefunden"
         ::utils::gui::msg error Fehler $msg
         return ""
      } else {
         # inclname mit Verzeichnis
         if {![file readable $name]} {
            ::utils::gui::msg error Fehler "Include <$name> nicht vorhanden"
            return ""
         }
         return [::utils::file::readliste $name]
      }
   }
   
   #--------------------------------------------------------------------
   #
   # Proc: proto::window
   #
   # *::proto::window modul id*
   #
   # liefert die Window-Id des Widgets mit der Id <id> im
   # Modul <modul>. Die Funktion
   # ersetzt die bisherige wv(w,id)-Konstruktion.
   #
   # *Achtung*: wenn das Modul mehrfach verwendet wird, zB bei tlmode=multi
   # wird nur die ID gefunden, das zuletzt gesourced wurde.
   #
   # Parameter:
   #     modul: Name des Protomoduls
   #     id: Widget-ID
   #
   # Ergebnis:
   #    Erfolg : id sonst Error
   #
   #
   # Beispiel:
   # (start code)
   #
   #   # Prototyp einlesen
   #   #
   #   set frtl [$tl winfo frame]
   #   set ::base $frtl ;# !! :: ist wichtig
   #
   #   if {[::proto::source -base $::base -modul <modul>]} {exit}
   #
   #   #Prototyp ergänzen
   #
   #   FillProto $tl $nr $typ $owner $::base
   #
   #   proc FillProto ...
   #
   #   set btExit [::proto::window $modul close]
   #   set enBetr [::proto::window $modul betr]
   #   ...
   # (end)
   ###----------------------------------------------------------------------
   
   #-----------------------------------------------------------------------
   proc ::proto::window {modul id} {
      # liefert window-Adresse eines widgets mit der id im Modul
      # modul : Modul der protodatei
      # id    : eindeutige ID eines Widgets im Modul
      #-----------------------------------------------------------------------
      variable baseD
      variable widArr
      variable baseProto
      
      # base vom Modul suchen
      set base [::utils::dictget $baseD $modul -default ""]
      if {$base eq ""} {
         return -code error "Modul <$modul> fehlt"
      }
      
      # im WidgetArray suchen
      if {[info exists widArr(${base}°${modul}°$id) ]} {
         return $widArr(${base}°${modul}°$id)
      }
      return -code error "Window für <$modul> und <$id> nicht vorhanden"
   }
   
   #-----------------------------------------------------------------------
   proc ::proto::_suchWidget {zeile} {
      # sucht in der proto.tcl-Zeile nach einem Widget
      # zeile : Zeile aus der tcl-Datei
      # Resultat : {window id} oder {}
      #-----------------------------------------------------------------------
      # Leerzeile
      if {$zeile eq ""} {return {}}
      
      # Kommentar
      if {[regexp -- {^\s*#.*} $zeile]} {return {}}
      
      # pack-Zeile
      if {[regexp -- {^\s*pack .*} $zeile]} {return {}}
      
      # namespace-Zeile
      if {[regexp -- {^\s*namespace .*} $zeile]} {return {}}
      
      # ende namespace-Zeile
      if {[regexp -- {^\s*\}.*} $zeile]} {return {}}
      
      # bind-Zeile
      if {[regexp -- {^\s*bind .*} $zeile]} {return {}}
      
      # lappend-Zeile
      if {[regexp -- {^\s*lappend.*} $zeile]} {return {}}
      
      # variable widliste
      if {[regexp -- {^\s*variable widliste.*} $zeile]} {return {}}
      
      # PWPane ->  $base.0.1.id add -minsize 100
      if {[regexp -- {^\s*\$([^ ]+) add\s*} $zeile dum win   ]} {
         set id [lindex [split $win "."] end]
         return [list $win $id]
      }
      
      # NBTab -> $base.0.nb insert end tab,mess -text Messung
      if {[regexp -- {^\s*\$([^ ]+) insert end ([^ ]+)\s*} \
            $zeile dum win tabID ]} {
         return [list $win $tabID]
      }
      
      #
      # $base.0.1 draw
      #
      # Label $base.0.1.fmel -text Meld -> Standardwidget
      if {[regexp -- {^\s*([^ ]+) \$([^ ]+).*} \
            $zeile dum class win ]} {
         # $base.0.1 draw
         if {$win eq "draw"} {return {}}
         set id [lindex [split $win "."] end]
         # nur benannte id
         if {[string is integer $id]} {
            return {}
         }
         
         return [list $win $id]
      }
   }
   
   #-----------------------------------------------------------------------
   proc ::proto::_insertBase {modul base} {
      # fügt base in das Dictionary baseD
      # Wenn von proto der prototyp angezeigt wird, wird
      # .tlproto nicht eingefügt
      # Wegen dyn Toplevel werden vorhandende base überschrieben
      #
      #
      #-----------------------------------------------------------------------
      variable baseD
      variable baseProto
      if {$base ne ".tlproto"} {
         # $base.0.nb.ftab,mess.fr,mess.22.15
         #      -> .am.mf.frame.nb.ftab,mess.fr,mess.22.15 (Hinweis 4)
         regsub -all -- {base.0} $base $baseProto base
         dict set baseD $modul $base
      }
      return
   }
   
   
   #--------------------------------------------------------------------
   #
   # Proc: proto::source
   #
   # *::proto::source base path incldirlist args*
   #
   # liest die Proto(typ)Datei ein, sucht und expandiert die
   # Includedateien. Namenskollisionen (set wv() ..) werden geprüft.
   # 
   # !! source2 benutzen !!
   #
   # Parameter:
   #     base: Anker des Prototyps im Zielprogramm (i.a. ein Frame)
   #     path: Pfad der Prototypdatei. Suche in incldirlist, wenn ohne Verzeichnis
   #     incldirlist: Liste der Include-Verzeichnisse (Default: Verzeichnis Protodatei)
   #        relativ zum Quellverzeichnis app-x
   #     args: -tlmode <Toplevelmode> 
   #     Toplevelmode : 1 (multi Toplevel)  0 (single Toplevel)
   #     nur bei toplevel oder tw
   #
   # Ergebnis:
   #    Erfolg : 0
   #
   #
   # Beispiel:
   # (start code)
   #
   #   # Prototyp einlesen
   #   # oberstes Widget *Frame* in proto.proto
   #   #
   #   # !!! .tcl
   #   set path [file join $::scriptDirMain proto proto.tcl]
   #   set ::base $p      ;# :: ist wichtig !!
   #
   #   if {[::proto::source $::base $path ]} {exit}
   # (end)
   #    *Prototyp mit multi Toplevel*
   #
   #   oberstes Widget *tw* oder *toplevel* in der Proto-Datei.
   # 
   #   Option -multi = false !! nur bei bei tw
   #
   # (start code)
   #   set path [file join $::scriptDirMain proto toplev.tcl]
   #   set ::base $wv(w,top) ;# !!
   #   set modul toplevel
   #
   #   if {[::proto::source $::base $path {} -tlmode 1] } {exit}
   # (end)
   #
   #
   #   *Prototyp mit single Toplevel*
   # 
   #    wie bei Multi nur -tlmode 0.
   #    Achtung bei mehreren Single-Toplevel im Programm
   #
   #   *Dialog*
   # 
   #   bringt keinen Vorteil gegenüber tw oder toplevel,
   #   eher Nachteile, da die besonderen Features mit proto
   #   nicht nutzbar sind.
   #
   # (start code)
   #   global dialogWin
   #   set path [file join $::scriptDirMain proto dialog.tcl]
   #   set ::base $wv(w,top)
   #   set modul dialog
   #   catch {destroy $dialogWin}  ;# !!!
   #   if {[::proto::source $::base $path  ]} {exit}
   # 
   #   set dialogWin [::proto::window dialog dialog]
   #   return 
   # (end)
   ###--------------------------------------------------------------------------
   
   #-----------------------------------------------------------------------
   proc ::proto::xsource {base path {incldirlist {}} args } {
      # liest die Protodatei und expandiert die Includedateien
      # base  : Widgetparent im Zielprogramm
      # path  : Pfad Proto-tcl-datei
      # incldirlist : Liste möglicher Verzeichnisse der Includedateien
      #              relativ zum Quellverzeichnis, zB proto
      # args : -tlmode 1|0 Toplevelmode
      #-----------------------------------------------------------------
      variable baseD
      variable scriptNeu
      variable windowListe
      variable baseProto
      variable tlNr  ;# Nr für MultiToplevel
      
      if {![info exists tlNr]} { set tlNr -1}
      
      ::Opt::opts opts $args {
         {-tlmode {}  "Prototyp ist Multilevel:1|0||"}
      }
      
      set tlMode $opts(-tlmode)
      
      set windowListe [list]
      set scriptNeu ""
      # baseProto : basis vom Hauptprotofile
      set baseProto $base
      
      # base anpassen bei MultiToplevel
      #
      if {$tlMode == 1} {
         # multi TL
         incr tlNr
         set base ${base}._tw_$tlNr
      } elseif {$tlMode == 0} {
         # single TL
         catch {destroy ${base}._tw_$tlNr}
         incr tlNr
         set base ${base}._tw_$tlNr
      }
      #puts "base:$base tlMode:$tlMode"
      
      # incldirlist vorbelegen
      if {$incldirlist eq ""} {
         set incldirlist [file dirname $path]
      }
      
      # protofile und inclDateinen rekursiv aufrufen
      _protofile $base $path false $incldirlist
      
      # WidgetlisteArray anlegen
      ::proto::_setWidArr $windowListe $base
      
      #::utils::printdict $baseD
      # scriptNeu : protodatei.tcl und incl aneinander
      # puts sriptNeu\n$scriptNeu
      #::utils::file::writefile ~/test.tcl $scriptNeu
      set ::base $base
      if {[catch {eval $scriptNeu} msg]} {
         ::utils::gui::msg error \
            "Fehler proto::source" "eval script:$msg\n$::errorInfo"
         return 1
      }
      
      return 0
   }
   
   
}  ;# Ende ns