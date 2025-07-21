   # -*-Tcl-*-
   # ###################################################################
   #
   #  FILE: "utils_dz-x.y.tcl"
   #                                    created: 22.01.2012 14:00:00
   #
   #  Description:
   #  enthält datum-zeit -Package dz
   #
   #  History
   package provide utils::dz 1.3.6
   #
   #  modified   by   rev    reason
   #  ---------- ---- ------ -------------------------
   #  18.11.2023 mlrd 01.3.6 sommerzeit: Tageswechsel fehlt
   #  07.10.2023 mlrd 01.3.5 neu sommerzeit
   #  28.06.2019 mlrd 01.3.4 Doku
   #  12.03.2017 mlrd 01.3.3 splitZeit erkennt Trennzeichen autom.
   #  16.10.2016 mlrd 01.3.2 neu: datumDE, datumENG
   #  27.12.2015 mlrd 01.3.1 rangele -> range
   #  21.10.2015 mlrd 01.3.0 NaturalsDok Doku eingebaut
   #  24.04.2014 mlrd 01.03  Proc mit NS
   #  28.07.2013 mlrd 01.02  Korrekturen, splitzeit auch ohne sek
   #                         ok 0 f:1
   #  28.07.2013 mlrd 01.01  Original
   # ###################################################################
   
   #-----------------------------------------------------------------------
   #  Doku Schnittstelle
   #  ::aru::archivinfo name           --> {vd vz bd bz cycE cycW endlos}
   
   #-----------------------------------------------------------------------
   
   
   #package require Opts
   package require Pool_Base
   package require callib
   
   namespace eval utils::dz {
      #---------- Variable ------------------------------------------------
      variable test           0
      variable packagename    {utils::dz}
      #--------- interne Funktionen ------------------------------------------
   ###-----------------------------------------------------------------------------
   #       proc debuginfo {} {
   #          set str {
   #             # ---------------Debug -----------------
   #             # 1 : Trace proc
   #             # 2 :
   #             # 3 :
   #             # 4 : Trace Result
   #             # 5 : interner Ablauf
   #             
   #             # 10:
   #             # 15:
   #             #-------------------------------------
   #          }
   #          puts $str
   #          exit
   #       }
   #       #--------------------------------------------------------------------
   #       proc _dbg {num titel {script {}} } {
   #          # erzeugt eine Debug-Ausgabe
   #          #--------------------------------------------------------------------
   #          variable packagename
   #          ::utils::dbg::debug $num $packagename $titel $script
   #       }
   #       #--------------------------------------------------------------------
   #       proc #_proctrace {} {
   #          #--------------------------------------------------------------------
   #          set infoLev [info level -1]
   #          _dbg 1 Proctrace {set infoLev}
   #       }
   #       #--------------------------------------------------------------------
   #       proc _resulttrace {msg} {
   #          #--------------------------------------------------------------------
   #          variable packagename
   #          set infolevel [info level -1]
   #          ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
   #       }
   #    }
   #    #--------------------------------------------------------------------
   ###-----------------------------------------------------------------------------
   #--------------    Hauptfunktionen         --------------------------
   #--------------------------------------------------------------------
   
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: minRunden
   #
   # *::utils::dz::minRunden hhmmss*
   #
   #  rundet die angegebene Zeit auf Minuten genau auf oder ab.
   #
   # Parameter:
   #     hhmmss: Zeit in der Form hh:mm:ss
   #
   # Ergebnis:
   # gerundete Zeit hh:mm
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::minRunden {hhmmss} {
      set secs  [clock scan $hhmmss]
      set zeith [clock format $secs -format {%X}]
      if {$hhmmss != $zeith} {
         return -code error "F-MinRunden: Zeit <$hhmmss> falsch oder nicht hh:mm:ss"
      }
      
      incr secs 30
      set zeith [clock format $secs -format {%H:%M}]
      return $zeith
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: splitDatum
   #
   # *::utils::dz::splitDatum tmj vt vm vj args*
   #
   # splittet Datum tmj in die Variable vt vm vj.
   #
   # Optional werden fehlende Teile ersetzt und Fehlermeldung
   # oder noOctal unterdrückt
   # Die Trennzeichen im Datum sind obligat.
   #
   # Parameter:
   #
   #     tmj:    Datumstring TMJ, mit Trennzeichen [/.- ]
   #     vt:     Variable Tag
   #     vm:     Variable Monat
   #     vj:     Variable Jahr  (4-stellig)
   #
   # Optionen:
   #
   #     -nooctal bool:  führende Nullen entfernen
   #     -noerror bool:  kein Abbruch, es wird o oder {} geliefert
   #     -default  str:  fehlende Teile t m j werden vorbelegt
   #
   # Ergebnis:
   #
   # - 0 Erfolg
   # - 1 Fehler
   #
   # Beispiel:
   #
   # splitDatum 1// -default [heute]
   ###-----------------------------------------------------------------------------
   proc utils::dz::splitDatum {tmj vt vm vj args} {
      upvar $vt t $vm m $vj j
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-nooctal     {0}    "liefert keine führende Null"}
         {-noerror     {0}    "liefert 0 und {} bei Fehler"}
         {-default     {}     "Vorbelegung für fehlende Teile"}
      }
      set nooctal $params(-nooctal)
      set noError $params(-noerror)
      set default $params(-default)
      
      set t {}
      set m {}
      set j {}
      set tD {}
      set mD {}
      set jD {}
      
      # Datum relativ ?
      if {[regexp -- {[gestern|heute|morgen]} $tmj]} {
         set tmj     [relDat $tmj]
      }
      
      if {![regexp -- {^\s*(\d*)\s*[/.-]*\s*(\d*)\s*[/.-]*\s*(\d*)\s*$} \
            $tmj dum t m j]} {
         if {$noError } {return 0}
         set msg "F-splitDatum:Format <$tmj> falsch -> tt/mm/jjjj "
         return -code error $msg
      }
      
      # Vorbelegung splitten und belegen
      if {$default != {} } {
         splitDatum $default {tD} {mD} {jD} -noerror $noError -nooctal $nooctal
      }
      
      if {$t == {} } {set t $tD}
      if {$m == {} } {set m $mD}
      if {$j == {} } {set j $jD}
      
      
      # führende Nullen entfernen
      set t [::utils::nooctal $t]
      set m [::utils::nooctal $m]
      set j [::utils::nooctal $j]
      if {!$nooctal } {
         set t [format {%02d} $t]
         set m [format {%02d} $m]
         set j [format {%02d} $j]
      }
      # Jahr 4-stellig
      if {[catch {clock format [clock scan 1/1/$j] \
               -format {%Y} } yearStr ]} {
         if {$noError } {return 0}
         return -code error \
            "F-splitDatum:Jahr <$j> falsch\n$yearStr"
      } else {
         set j $yearStr
      }
      
      return 0
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: splitZeit
   #
   # *::utils::dz::splitZeit zeit vh vm vs args*
   #
   # splittet die Zeit in die Variable vh vm vs.
   #
   # Optional werden fehlende Teile ersetzt und eine Fehlermeldung
   # unterdrückt
   #
   # Parameter:
   #
   #     zeit:    Zeit hh:mm:ss. Ziffern sind optional, Trennzeichen obligat.
   #     vh:     Variable Stunde
   #     vm:     Variable Minute
   #     vs:     Variable Sekunde
   #
   # Optionen:
   #
   #     -nooctal bool:  führende Nullen entfernen
   #     -noerror bool:  bei True wird im Fehlerfall 0 geliefert und nicht abgebrochen. Die Variablen sind leer.
   #     -default  str:  fehlende in der Zeit werden vorbelegt
   #
   # Ergebnis:
   #
   #  - 0 Erfolg
   #  - 1 Fehler
   #
   # Beispiel:
   # (start code)
   # splitZeit 02:10 h m s -default 10:11:12
   # set h
   # 02
   # set m
   # 10
   # set s
   # 12
   # (end)
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::splitZeit {zeit vh vm vs args} {
      upvar $vh h $vm m $vs s
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-nooctal     {0}    "liefert keine führende Nullen"}
         {-noerror     {0}    "liefert 0 und {} bei Fehler"}
         {-default     {}     "Default für fehlende Teile"}
      }
      set nooctal $params(-nooctal)
      set noError $params(-noerror)
      set default $params(-default)
      
      set hD {}
      set mD {}
      set sD {}
      set h  {}
      set m  {}
      set s  {}
      
      if {![regexp -- {^\s*(\d*)\s*[:/.-]*\s*(\d*)\s*[:/.-]*\s*(\d*)\s*$} \
            $zeit dum h m s]} {
         if {$noError } {return 0}
         set msg "F-splitZeit:Format <$zeit> falsch -> hh:mm:ss "
         return -code error $msg
      }
      
      # Vorbelegung
      if {$default != {} } {
         splitZeit $default {hD} {mD} {sD} -noerror $noError -nooctal $nooctal
      }
      if {$h == {} } {set h $hD}
      if {$m == {} } {set m $mD}
      if {$s == {} } {set s $sD}
      
      if {$nooctal } {
         # führende Nullen entfernen
         set h [::utils::nooctal $h]
         set m [::utils::nooctal $m]
         set s [::utils::nooctal $s]
      } else {
         set h [::utils::nooctal $h]
         set m [::utils::nooctal $m]
         set s [::utils::nooctal $s]
         set h [format {%02d} $h]
         set m [format {%02d} $m]
         set s [format {%02d} $s]
      }
      return 0
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: jetzt
   #
   # *::utils::dz::heute sepC*
   #
   # liefert die aktuelle Uhrzeit in der Form hh:mm:ss.
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::jetzt {  } {
      return [clock format [clock seconds] -format {%X}]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: heute
   #
   # *::utils::dz::heute sepC*
   #
   #  liefert das Datum von heute tt.mm.jjjj
   #
   # Das Trennzeichen ist wählbar, vorbelegt ist der Punkt.
   #
   # Parameter:
   #     sepC: Trennzeichen (default: .)
   ###-----------------------------------------------------------------------------
   proc utils::dz::heute {{sepC {.}}} {
      return [clock format [clock seconds] -format "%d$sepC%m$sepC%Y"]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: gestern
   #
   # *::utils::dz::gestern sepC*
   #
   #  liefert das Datum vom Vortag tt.mm.jjjj
   #
   # Das Trennzeichen ist wählbar, vorbelegt ist der Punkt.
   #
   # Parameter:
   #     sepC: Trennzeichen (default: .)
   ###-----------------------------------------------------------------------------
   proc utils::dz::gestern {{sepC {.}}} {
      set gestern [::pool::date::prev [::pool::date::now]]
      set gestern [nachTMJ $gestern $sepC]
      return $gestern
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: morgen
   #
   # *::utils::dz::morgen sepC*
   #
   #  liefert das Datum von morgen tt.mm.jjjj
   #
   # Das Trennzeichen ist wählbar, vorbelegt ist der Punkt.
   #
   # Parameter:
   #     sepC: Trennzeichen (default: .)
   ###-----------------------------------------------------------------------------
   proc utils::dz::morgen {{sepC {.}}} {
      set morgen [::pool::date::next [::pool::date::now]]
      set morgen [nachTMJ $morgen $sepC]
      return $morgen
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: nachTMJ
   #
   #  wandelt Datum von *mm/tt/jjjj* nach *tt/mm/jjjj*.
   #
   # Parameter:
   #     mtj - Datum mm/tt/jjjj
   #     sepC - Trennzeichen (default: .)
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::nachTMJ {mtj {sepC {.}}} {
      ##nagelfar variable j
      ##nagelfar variable m
      ##nagelfar variable t
      ::pool::date::split $mtj "j" "m" "t"
      set t [::utils::nooctal $t]
      set m [::utils::nooctal $m]
      set j [::utils::nooctal $j]
      return [format "%02d$sepC%02d$sepC%04d" $t $m $j]
   }
   ###-----------------------------------------------------------------------------
   #
   # Proc: nachMTJ
   #
   #   *::utils::dz::nachMTJ tmj sepC*
   #
   #  wandelt Datum von *tt/mm/jjjj* nach *mm/tt/jjjj*.
   #
   # Parameter:
   #     tmj: Datum tt/mm/jjjj
   #     sepC: Trennzeichen (default: /)
   #
   #
   ###-----------------------------------------------------------------------------
   
   proc utils::dz::nachMTJ {tmj {sepC {/}}} {
      if {[splitDatum $tmj t m j]} {
         return -code error "F-splitDatum $tmj t m j"
      }
      set t [::utils::nooctal $t]
      set m [::utils::nooctal $m]
      set j [::utils::nooctal $j]
      return [format "%02s$sepC%02s$sepC%04s" $m $t $j]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: nachJMT
   #
   # *::utils::dz::nachJMT tmj sepC*
   #
   #  wandelt Datum von *tt/mm/jjjj* nach *jjjj/mm/tt*
   #
   # Parameter:
   #     tmj: Datum tt/mm/jjjj
   #     sepC: Trennzeichen (default: .)
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::nachJMT {tmj {sepC {.}} } {
      if {[splitDatum $tmj t m j]} {
         return -code error "F-splitDatum $tmj t m j"
      }
      set t [::utils::nooctal $t]
      set m [::utils::nooctal $m]
      set j [::utils::nooctal $j]
      return [format "%04s$sepC%02s$sepC%02s" $j $m $t]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: checkDatum
   #
   # *::utils::dz::checkDatum datS args*
   #
   #  prüft das Datum und liefert tt.mm.jjjj.
   #
   #  Die _Trennzeichen_ im datum sind obligat. Optional können
   # fehlende Teile im Datum vorbelegt werden. Bei Fehlern im
   # Datum kann der Abbruch unterdrückt und {} geliefert werden.
   # Im Erfolgsfall wird das Datum in Form tt.mm.jjjj ausgegeben,
   # das Trennzeichen ist wählbar.
   #
   # Parameter:
   #
   #     datS: Datumstring  (siehe Beispiele)
   #     args: Optionen
   #
   # Optionen:
   #
   #     -noerror bool: kein Abbruch, es wird {} geliefert
   #     -default  str: fehlende Teile t m j werden vorbelegt
   #     -sepc char: Trennzeichen Ausgabe [/.-] , (Default:'.')
   #
   # Ergebnis:
   #
   #     Datum formatiert tt.mm.jjjj oder {}
   #
   #
   # Beispiel:
   #
   # (start code)
   # checkDatum 1/02/12 -default heute
   # checkDatum 01-1-
   # checkDatum ..2012 -noeeror 1
   # checkDatum heute
   # checkDatum gestern-2
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::checkDatum {datS args} {
      #_proctrace
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-noerror     {0}    "liefert im Fehlerfall {}"}
         {-default     {}     "Vorbelegung falls {}"}
         {-sepc        {.}    "Trennzeichen im Ausgabe-Datum"}
      }
      set noError $params(-noerror)
      set default $params(-default)
      set sepC    $params(-sepc)
      
      # Datum relativ ?
      if {[regexp -- {[gestern|heute|morgen]} $datS]} {
         set dat     [relDat $datS]
         if {$dat == {}} {
            if {$noError } {return {}}
            return -code error \
               "Datum <$datS> falsch --> tt/mm/jj oder gestern-x<"
         } else {
            set datS $dat
         }
      }
      
      splitDatum $datS t m j \
         -nooctal False -noerror $noError -default $default
      
      if {$j > 2030 } {
         if {$noError } {return {}}
         return -code error \
            "Datum $t/$m/$j > 2030"
      }
      
      if { [catch {clock scan $m/$t/$j} secs]} {
         if {$noError } {return {}}
         return -code error \
            "scan-Datum $datS nicht korrekt\n$secs\n Format:tt/mm/jjjj"
      }
      # Gegenprobe
      if { [catch {clock format $secs -format {%d/%m/%Y} } datH]} {
         if {$noError } {return {}}
         return -code error \
            "format-Datum $datS nicht korrekt\n$datH\n Format:tt/mm/jjjj"
      }
      
      if {$datH != "$t/$m/$j"} {
         if {$noError } {return {}}
         return -code error \
            "Datum $t/$m/$j nicht korrekt\n$datH\n Format:tt/mm/jjjj"
      }
      
      return [clock format $secs -format "%d$sepC%m$sepC%Y"]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: checkZeit
   #
   # *::utils::dz::checkZeit zeit args*
   #
   #  prüft die Zeit und liefert hh:mm:ss.
   #
   #  Die _Trennzeichen_ in zeit sind obligat. Optional können
   # fehlende Teile vorbelegt werden. Bei Fehlern in der zeit
   # kann der Abbruch unterdrückt und {} geliefert werden.
   #
   # Parameter:
   #
   #     zeit: Zeitstring  (siehe Beispiel)
   #     args: optionale Optionspaare
   #
   # Optionen:
   #
   #     -noerror bool: kein Abbruch, es wird {} geliefert
   #     -default  str: fehlende Teile h,m und s werden vorbelegt
   #
   # Ergebnis:
   #
   #    Zeit formatiert hh:mm:ss oder {}
   #
   #
   # Beispiel:
   # (start code)
   # checkZeit 02:10: -default 10:11:12
   #   -> 02:10:12
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::checkZeit {zeit args} {
      #     prüft und formatiert Zeit-String.
      #     Optional kann der Fehlerabbruch unterdrückt
      #     werden oder fehlende Teile in der Zeit vorbelegt
      #     werden. Die Trennzeichen in der Zeit sind obligat.
      #     Fehlende Teile ohne -default ist ein Fehler.
      #
      # Parameter:
      #     zeit    : Zeitstring  1:2:3
      #               oder 1:2: ::30
      #     -noerror bool : kein Abbruch,  {} geliefert
      #     -default  str : fehlende Teile h m s werden vorbelegt
      #
      # Ergebnis:
      #     Datum formatiert hh:mm:ss oder {}
      #--------------------------------------------------------------------
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-noerror     {0}    "liefert im Fehlerfall {}"}
         {-default     {}     "Vorbelegung fehlender Teile"}
      }
      set noError $params(-noerror)
      set default $params(-default)
      
      splitZeit $zeit std min sec \
         -nooctal True -noerror $noError -default $default
      
      if { ($std < 0) || ($std > 23)} {
         if {$noError } {return {}}
         return -code error \
            "Fehler|Zeit <$zeit>, Stunde falsch: <std:$std>"
      }
      if { ($min < 0) || ($min > 59)} {
         if {$noError } {return {}}
         return -code error \
            "Fehler|Zeit <$zeit>, Minute falsch: <min:$min>"
      }
      if { (($sec < 0) || ($sec > 59)) } {
         if {$noError } {return {}}
         return -code error \
            "Fehler|Zeit <$zeit>, Sekunde falsch: <sec:$sec>"
      }
      
      return [format "%02d:%02d:%02d" $std $min $sec]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: tagAbstand
   #
   # *::utils::dz::tagAbstand von bis*
   #
   #  Abstand zweier Daten in Tagen.
   #
   # Das Ergebnis kann positiv oder negativ sein. Die
   # Zeitumstellung wird nicht beachtet.
   #
   # Parameter:
   #     von:  Datum tt.mm.jjjj
   #     bis:  Datum tt.mm.jjjj
   #
   # Ergebnis:
   # - Erfolg : Integer
   # - Fehler : {}
   #
   ###-----------------------------------------------------------------------------
   
   proc utils::dz::tagAbstand {von bis} {
      if {$von == $bis } {return -0}
      
      set vonCh [checkDatum $von -noerror True]
      if {$vonCh == {}} {return {}}
      
      splitDatum $vonCh vonT vonM vonJ
      set v [clock scan "$vonM/$vonT/$vonJ"]
      
      set bisCh [checkDatum $bis -noerror True]
      if {$bisCh == {}} {return {}}
      
      splitDatum $bisCh bisT bisM bisJ
      set b [clock scan "$bisM/$bisT/$bisJ"]
      
      set diff [expr {($v -$b)/86400}]
      if {$diff >= 0} {set diff "+$diff"}
      #puts "von:$von bis:$bis $diff"
      return $diff
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: relDat
   #
   # *::utils::dz::relDat reldatum*
   #
   #  formatiert ein relatives Datum in tt.mm.jjjj um.
   #
   # Parameter:
   #     relDatum: <datum> [+-]<Anzahl>
   #
   # Ergebnis:
   #
   #  Erfolg: tt.mm.jjjj
   #
   #  Fehler: {}
   #
   # Beispiel:
   # (start code)
   # heute -3
   # 1.2.2008 +3
   # gestern +5
   # morgen + 2
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::relDat {relDatum} {
      if {![regexp -- {^\s*([.-/\d\w]+)\s*([-+]*)\s*(\d*)\s*$} $relDatum dum dat vz tage]} {
         puts "F-relDat: <$relDatum> falsch, richtig : Datum +- Tage"
         return {}
      }
      
      if {![regexp -- {^\s*(heute|morgen|gestern)\s*$} $dat ]} {
         puts  "F-relDat: <$dat> falsch, nur heute|morgen|gestern"
         return {}
      }
      
      #puts "sd $relDatum <$dat< <$vz< <$tage<"
      if {$vz   == {}} {set vz {-}}
      if {$tage == {}} {set tage 0}
      
      set dat [string trim $dat]
      if {$dat == {heute}}   {set dat [heute]}
      if {$dat == {gestern}} {set dat [gestern]}
      if {$dat == {morgen}}  {set dat [morgen]}
      
      set d [checkDatum $dat -noerror True]
      if {$d == {}} {return {}}
      
      if {$tage == 0} {return $d}
      
      splitDatum $d vonT vonM vonJ
      set v [clock scan "$vonM/$vonT/$vonJ"]
      if {$vz == {-}} {
         set d [expr {$v - $tage * 84600}]
      } else {
         incr tage
         set d [expr {$v + $tage * 84600}]
      }
      #puts "erg:[clock format $d -format {%d.%m.%Y}]"
      return [clock format $d -format {%d.%m.%Y}]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: scan_zp
   #
   # *::utils::dz::scan_zp datum zeit*
   #
   # wandelt einen Zeitpunkt in das interne Zeitformat.
   #
   # Parameter:
   #     datum: Datum tt/mm/jjjj
   #     zeit: Zeit hh:mm:ss
   #
   # Ergebnis:
   # Integer
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::scan_zp {datum zeit} {
      splitDatum $datum vt vm vj
      if {[catch {clock scan "$vm/$vt/$vj $zeit"} zpi]} {
         return -code error $zpi
      }
      #puts "$datum $zeit $zpi [clock format $zpi]"
      return $zpi
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: puts_dauer
   #
   # *::utils::dz::puts_dauer zanf txt*
   #
   # Gibt die Zeitdauer von _tanf_ in msec bis jetzt in msec mit
   # einem Text aus. Die Prozedur wird i.a. für Laufzeitmessungen verwendet.
   #
   # Parameter:
   #     zanf:  Startzeitpunkt in msec mit clock erfasst.
   #     txt: Kommentar zur Beschreibung der Zeitdifferenz.
   #     (default:'')
   #
   # Beispiel:
   # (start code)
   # set anf_msec [clock clicks -milliseconds]
   # after 1000
   #
   # parse_daten
   # puts_dauer $anf_msec "-Parse Daten-"
   #
   # liefert diese Ausgabe auf STDOUT:
   #    Dauer -Parse Daten- 1001 msecs
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::puts_dauer {zanf {txt {}}  }  {
      set zend [clock clicks -milliseconds]
      puts "Dauer $txt:[expr {$zend -$zanf}] msecs"
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: datum+
   #
   # *::utils::dz::datum+ datum tage sepC*
   #
   #  verlängert ein gegebenes Datum um eine Anzahl Tage.
   #
   # Das Trennzeichen im neuen Datum ist wählbar, vorbelegt
   # ist ein Punkt.
   #
   # Parameter:
   #     datum: Startdatum tt.mm.jjjj
   #     tage: Anzahl Tage zur Verlängerung, muss >0 sein.
   #     sepC: Trennzeichen im neuen Datum (default: .)
   #
   # Ergebnis:
   #  Erfolg: tt.mm.jjjj
   #
   #  Fehler: {}
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::datum+ {datum tage {sepC {.}}} {
      if {$tage <0} {
         return -code error -errorinfo "tage <$tage> muss >0 sein" {}
      }
      
      set MTJ [nachMTJ $datum]
      if {$tage} {
         foreach tag [::utils::range 1 $tage 1] {
            set MTJ [::pool::date::next $MTJ]
         }
      }
      return [nachTMJ $MTJ $sepC]
   }
   
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: datum-
   #
   # *::utils::dz::datum- datum tage sepC*
   #
   #   verkürzt ein Datum um Anzahl Tage.
   #
   # Das Trennzeichen im neuen Datum ist wählbar,
   # vorbelegt ist ein Punkt.
   #
   # Parameter:
   #     datum: Startdatum tt.mm.jjjj.
   #     tage: Anzahl Tage zur Kürzung, muss >0 sein.
   #     sepC: Trennzeichen im neuen Datum (Default:'.')
   #
   # Ergebnis:
   #  Erfolg: tt.mm.jjjj
   #
   #  Fehler: {}
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::datum- {datum tage {sepC {.}}} {
      if {$tage <0} {
         return -code error -errorinfo "tage <$tage> muss >0 sein"
      }
      
      set MTJ [nachMTJ $datum]
      if {$tage} {
         foreach tag [::utils::range 1 $tage 1] {
            set MTJ [::pool::date::prev $MTJ]
         }
      }
      return [nachTMJ $MTJ $sepC]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: dsp_calender
   #
   # zeigt einen Kalender an.
   #
   # Das Datum aus dem zugeordneten Eingabefeld *e* wird vorbelegt.
   # Wenn das Datum im Eingabefeld leer oder fehlerhaft ist,
   # wird heute vorbelegt. Das selektierte Datum im Kalender
   # wird ins Eingabefeld übernommen und der Kalender gelöscht.
   #
   # Parameter:
   #     p - Parentwidget
   #     e - Entrywidget zur Vorbelegung und Übernahme des gewählten Datums.
   #
   # Ergebnis:
   #  Datum im Entrywidget
   #
   #
   # Beispiel:
   # (start code)
   # set gd(datum) 1/2/2011
   # set w .test
   # set p [toplevel $w]
   # set e [Entry $p.e -textvariable gd(datum)]
   # Button $p.cal -text Cal \
   #    -command [list dsp_calender $p $e]
   # pack $e $p.cal
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::dsp_calender {p e} {
      package require callib
      _show_calender $p $e
   }
   
   #--------------------------------------------------------------------
   # Kalender Anzeige
   #--------------------------------------------------------------------
   
   proc utils::dz::_show_calender {w entry_w} {
      
      # Kalender-Callback
      proc _cal_cb {caltop entry_w args} {
         lassign $args jhr mon tag wota row col
         # tt.mm.jjjj
         set dat [checkDatum "$tag/$mon/$jhr" -noerror True]
         if {$dat == {}} {return {}}
         
         $entry_w configure -text $dat
         catch {$entry_w invoke}
         destroy $caltop
      }
      
      
      proc _setMonthYear { cal } {
         global monthYear
         set p [ $cal configure -month ]
         set y [ $cal configure -year ]
         set scanStr [format "%s/1/%s 12:00:00"  $p $y ]
         set timestamp [ clock scan $scanStr ]
         set monthYear [clock format $timestamp -format "%b -%Y" ]
      }
      
      proc _incrementMonth { cal   } {
         $cal nextmonth
         _setMonthYear  $cal
      }
      proc _decrementMonth { cal   } {
         $cal prevmonth
         _setMonthYear  $cal
      }
      proc _incrementYear { cal   } {
         $cal nextyear
         _setMonthYear  $cal
      }
      proc _decrementYear { cal   } {
         $cal prevyear
         _setMonthYear $cal
      }
      
      # Datum aus entrywidget
      set datdefault [$entry_w cget -text]
      if {$datdefault == 0} {
         set datdefault [heute]
      }
      
      # Datum pruefen, ggf vorbelegen
      if {[catch {checkDatum $datdefault -default [heute]} datdefault]} {
         set datdefault [heute]
      }
      
      splitDatum $datdefault tag mon jhr
      set monthDay $tag
      if {[winfo exists $w.caltop]} {
         destroy $w.caltop
      }
      set p [toplevel $w.caltop]
      ::utils::gui::centerWindow . $p
      wm transient $p $w
      wm title $p {Kalender}
      frame $p.frame  -relief flat
      set topframe [ frame $p.frame.topframe  ]
      set calendar [ calwid $p.frame.calendar   \
         -font { helvetica 8 bold }             \
         -dayfont {Arial 9 bold }               \
         -foreground black                      \
         -background slategray1                 \
         -activebackground cyan                 \
         -clickedcolor    red                   \
         -startsunday     0                     \
         -callback [list ::utils::dz::_cal_cb $p $entry_w]    \
         -daynames {So Mo Di Mi Do Fr Sa}       \
         -day   $tag \
         -month $mon \
         -year  $jhr \
         -relief groove ]
      Button $topframe.decyear   -text "<<" \
         -padx 1m -pady 0m \
         -font {TkHeadingFont {10} bold} \
         -command " ::utils::dz::_decrementYear $calendar "
      Button $topframe.decmonth   -text "<" \
         -padx 1m -pady 0m \
         -font {TkHeadingFont {10} bold} \
         -command " ::utils::dz::_decrementMonth $calendar "
      label  $topframe.monthyrlbl -textvariable monthYear \
         -font {Helvetica 10 bold } -width 10 \
         -background blue \
         -foreground white
      Button $topframe.incrmonth -text ">" \
         -padx 1m -pady 0m \
         -font {TkHeadingFont {10} bold} \
         -command " ::utils::dz::_incrementMonth $calendar "
      Button $topframe.incryear  -text ">>"  \
         -padx 1m -pady 0m \
         -font {TkHeadingFont {10} bold} \
         -command " ::utils::dz::_incrementYear $calendar "
      pack $p.frame  -side top -expand 1 -fill both
      pack $topframe -side top -expand 1 -fill x -pady 3
      pack $topframe.decyear    -side left -expand 1 -fill none -padx 3 -pady 3
      pack $topframe.decmonth   -side left -expand 1 -padx 3 -pady 3
      pack $topframe.monthyrlbl -side left -expand 1 -padx 3 -pady 3
      pack $topframe.incrmonth  -side left -expand 1 -padx 3 -pady 3
      pack $topframe.incryear   -side left -expand 1 -padx 3 -pady 3
      pack $calendar   -side top -anchor c  -expand 1
      _setMonthYear $calendar
   }
   
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: tagStunden
   #
   # *::utils::dz::tagStunden datum*
   #
   #
   # _tagStunden_ prüft, ob am vorgegebenen Datum eine
   # Zeitumschaltung vorliegt und liefert die Anzahl
   # der Tagesstunden zurück, 23, 24 oder 25 .
   #
   # Parameter:
   #     datum: Tagesdatum tt.mm.jjjj
   #
   # Ergebnis:
   #  23|24|25
   #
   #  0 im Fehlerfall
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::tagStunden {datum} {
      set dat [checkDatum $datum -noerror True]
      if {$dat == {}} {return 0}
      splitDatum $dat tag mon jahr
      
      set z1 [clock scan "$mon/$tag/$jahr 00:00"]
      set z2 [clock scan "$mon/$tag/$jahr 23:00"]
      set anz [expr {($z2 -$z1)/3600 +1}]
      return $anz
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: incrDatum
   #
   # *::utils::dz::incrDatum datum_var einh anz richtung*
   #
   # Erhöht oder vermindert das per Variable übergebene Datum tt.mm.jjjj
   #  um +- n Tage oder Monate.
   #
   # Parameter:
   #
   #     datum_var: Datum tt.mm.jjjj wird per Variable  übergeben.
   #     einh: Datum wird um Tag|Monat verändert
   #     anz: spezifiert die Anzahl.
   #     richtung: +|- spezifiert, ob inkrementiert oder dekrementiert wird.
   #
   # Ergebnis:
   # neues Datum tt.mm.jjjj
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::incrDatum {datum_var einh anz richtung} {
      upvar $datum_var datum
      
      # Parameter prüfen
      if {![regexp -- {^(Tag|Monat)$} $einh]} {
         return -code error "Einheit <$einh> muss Tag oder Monat sein"
      }
      if {![regexp -- {^[+-]$} $richtung]} {
         return -code error "Richtung  <$richtung> muss + oder - sein"
      }
      
      splitDatum $datum t m j
      if {$einh == {Tag}} {
         if {$richtung == {+}} {
            set datum [datum+ $datum $anz]
         } else {
            set datum [datum- $datum $anz]
         }
      } else {
         if {$richtung == {+}} {
            set nm [::pool::date::nextMonth $m/$j]
            lassign [split $nm {/}] mn jn
            set datum $t.$mn.$jn
         } else {
            set pm [::pool::date::prevMonth $m/$j]
            lassign [split $pm {/}] mn jn
            set datum $t.$mn.$jn
         }
      }
      return $datum
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: vergTage
   #
   # *::utils::dz::vergTage mon jhr*
   #
   #
   # _vergTage_ liefert wieviele Tage sind im angegebenen
   # Monat vergangen sind. Im aktuellen Monat wird der
   # aktuelle Tag geliefert.
   #
   # Parameter:
   #     mon: Monat mm
   #     jhr: Jahr jj oder jjjj
   #
   # Ergebnis:
   # Integer
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::vergTage {mon jhr} {
      set ml [::pool::date::monthLength $mon/$jhr]
      
      splitDatum [heute] t m j
      if {$m == $mon && $j == $jhr} {
         return $t
      } else {
         return $ml
      }
   }
   
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: woTag
   #
   # *::utils::dz::woTag datum*
   #
   #  liefert den Wochentag zu einem gegebenen Datum tt.mm.jjjj in
   # englisch.
   #
   # Parameter:
   #     datum: Datum tt/mm/jjjj. Ziffern sind optional, Trennzeichen obligat.
   #
   # Ergebnis:
   # Wochentag in englisch: Monday Tuesday ...
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::woTag {datum} {
      splitDatum $datum t m j
      return [clock format [clock scan "$m/$t/$j"] -format %A]
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: tageListe
   #
   # *::utils::dz::tageListe von bis args*
   #
   #  liefert Liste der Daten von -> bis.
   # Die Tagliste ist inclusiv von und bis.
   #
   # Parameter:
   #     von: Datum tt.mm.jjjj
   #     bis: Datum tt.mm.jjjj
   #     args: Optionen
   #
   # Optionen:
   #
   # -noerror bool: im Fehlerfall wird {} geliefert und nicht abgebrochen.
   # -sepc char: Trennzeichen im Ausgabedatum, vorbelegt ist der Punkt.
   #
   # Ergebnis:
   # - Erfolg : Liste mit tt.mm.jjjj
   # - Fehler : {}
   #
   #
   ###-----------------------------------------------------------------------------
   proc utils::dz::tageListe {von bis args} {
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-noerror     {0}    "liefert im Fehlerfall {}"}
         {-sepc        {.}     "Trennzeichen im Ausgabe-Datum"}
      }
      set noError $params(-noerror)
      set sepC    $params(-sepc)
      
      set tagLi {}
      
      # von/bis-Datum checken
      set erg [checkDatum $von -noerror $noError -sepc $sepC]
      if {$erg == {} }  {return {}}
      set von $erg
      
      set erg [checkDatum $bis -noerror $noError -sepc $sepC]
      if {$erg == {} }  {return {}}
      set bis $erg
      
      # wieviele Tage ?
      set anzTage [tagAbstand $bis $von]
      if {$anzTage == {} } {return {}}
      
      # vz - , wenn bis < von
      set vz   [string range $anzTage 0 0]
      set tage [string range $anzTage 1 end]
      
      if {$vz == {-}} {
         set anf $bis
      } else {
         set anf $von
      }
      
      lappend tagLi $anf
      for {set i 1} {$i <= $tage} {incr i} {
         lappend tagLi [datum+ $anf $i $sepC]
      }
      return $tagLi
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: datumDE
   #
   # *::utils::dz::datumDE datEng*
   #
   # wandelt das englische Datum in dt um,
   # Oct -> Okt
   #
   # Parameter:
   #     datEng:  englisches Datum : 12-oct-16
   #
   # Ergebnis:
   #    Datum in dt : 12-okt-16
   #
   #
   ###-----------------------------------------------------------------------------
   
   proc utils::dz::datumDE {datEng} {
      #-----------------------------------------------------------------------
      #_proctrace
      
      set mons {
         Mar Mär
         May Mai
         Oct Okt
         Dec Dez
      }
      foreach {eng dt} $mons {
         regsub -nocase -all -- $eng $datEng $dt datEng
      }
      set datDE $datEng
      return $datDE
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: datumENG
   #
   # *::utils::dz::datumENG datDE*
   #
   # wandelt das deutsche Datum in englisch um,
   # Okt -> Oct
   #
   # Parameter:
   #     datDE:  dt. Datum : 12-Okt-16
   #
   # Ergebnis:
   #    Datum in engl. : 12-Oct-16
   #
   #
   ###-----------------------------------------------------------------------------
   
   proc utils::dz::datumENG {datDE} {
      #-----------------------------------------------------------------------
      #_proctrace
      
      set mons {
         Mär Mar
         Mai May
         Okt Oct
         Dez Dec
      }
      foreach {dt eng} $mons {
         regsub -nocase -all -- $dt $datDE $eng datDE
      }
      set datEng $datDE
      return $datEng
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: sommerzeit
   #
   # *::utils::dz::sommerzeit seconds*
   #
   # liefert 1/0 wenn Sommerzeit gilt.
   #
   # Parameter:
   #     seconds:  geliefert von [clock seconds]
   #
   # Ergebnis:
   #    1 : es ist Sommerzeit
   #    0 : es ist Winterzeit
   #
   ###------------------------------------------------------------------
   
   proc utils::dz::sommerzeit {seconds} {
      # In der Winterzeit liefert GMT 1 h weniger, bei Sommerzeit
      # ist GMT 2h zuück.
      #-----------------------------------------------------------------
      #
      
      set gmtH [clock format $seconds -format %k -gmt 1]
      set h    [clock format $seconds -format %k -gmt 0]
      
      # Tagewechsel
      if {$h < $gmtH} {incr h 24}
         
      set diff [expr {$h -$gmtH}]
      #puts "h:$h gmtH:$gmtH dif:$diff"
      switch -exact -- $diff  {
         1 {return 0}
         2 {return 1}
         default {
            return -code error "sommerzeit: diff:<$diff>"
         }
      } ; # end switch
      
      
      return
   }
   
   