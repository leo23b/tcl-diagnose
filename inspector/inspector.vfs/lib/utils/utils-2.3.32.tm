# -*-Tcl-*-
# ###################################################################
#
#  FILE: "utils.tcl"
#                                    created: 16.03.2009 18:00:09
#                                last update: 16.03.2009 18:00:09
#
#  History
#
package provide utils 2.3.32
#  modified   by   rev    reason
#  ---------- ---- ------ -------------------------
#  17.07.2023 mlrd 2.3.32  Log read/save/CfgU
#  28.03.2023 mlrd 2.3.31  matDelRow neu
#  14.11.2021 mlrd 2.3.30  zeilenumbruch
#  07.10.2021 mlrd 2.3.29  topwidget entfernt
#  06.09.2021 mlrd 2.3.28  widget::tw
#  19.08.2021 mlrd 2.3.27  sendmail: Name zipdatei,Fehlerabh.
#  28.08.2020 mlrd 2.3.26  dictgetkeys
#  13.08.2020 mlrd 2.3.25  sendmail: tmp delete
#  11.07.2020 mlrd 2.3.24  dictget default vorbelegt mit ""
#  08.02.2020 mlrd 2.3.23  dolog/dostat: name-datum.log
#  27.10.2019 mlrd 2.3.22  dolog/dostat: nl->°
#  29.06.2019 mlrd 2.3.21  Doku
#  12.06.2019 mlrd 2.3.20  specExec
#  24.10.2018 mlrd 2.3.19  readCfgU/saveCfgU ohne puts wg xtools
#                          sendmail: ohne tmpDEl nach 3 min,
#                          zipfile umbenannt
#  25.08.2018 mlrd 2.3.18  utils-Packages neu sortiert, tabfs
#  27.07.2018 mlrd 2.3.17  sendmail mit host, dolog ohne display
#                          savecfg ohne sync, init mit args
#  31.01.2018 mlrd 2.3.16  p requ Thread muss ins Hauptprogramm
#  18.01.2018 mlrd 2.3.15  utils::thread
#  13.12.2017 mlrd 2.3.14  printarray
#  26.09.2017 mlrd 2.3.13  Test bei Userdir
#  25.09.2017 mlrd 2.3.12  ~ -> home/spsy in _userCfgU
#                          _userCfgDir ohne user
#  01.09.2017 mlrd 2.3.11  xCfgDir wieder aktiviert
#  20.08.2017 mlrd 2.3.10 _userCfgDir
#  18.08.2017 mlrd 2.3.9  _userCfgDirU
#  05.07.2017 mlrd 2.3.8  ping saveCfgu
#  19.02.2017 mlrd 2.3.7  sendmail mit sndml bei rem Host, init
#  22.11.2016 mlrd 2.3.6  excelColInt
#  05.09.2016 mlrd 2.3.5  saveCfgU: Anpassung 4.7 mir spec::release
#  29.08.2016 mlrd 2.3.4  saveCfgU: Anpassung 4.7
#  13.06.2016 mlrd 2.3.3  saveCfg: Test Tk
#  16.02.2016 mlrd 2.3.2  nochmals dostat
#  16.02.2016 mlrd 2.3.1  dostat mit nl, printhex
#  17.10.2015 mlrd 2.3.0  Doku ND, incrChar
#  07.03.2015 mlrd 2.2.0  sendmail
#  21.01.2015 mlrd 2.1.1  dolog |
#  15.01.2015 mlrd 2.1.0  saveCfgU nosync
#  10.01.2015 mlrd 2.0.2  neu Interface dolog dostat
#  12.09.2014 mlrd 2.0.1  Clientversion cfg-Datei, ohne synchr bei save
#  31.08.2014 mlrd 1.5.3  dolog arvLog loe
#  15.07.2014 mlrd 1.5.2  oneblank ergänzt
#  05.07.2014 mlrd 1.5.1  savecfg:bei Xtools nicht syncr
#  28.06.2014 mlrd 01.05  savecfg etc
#  24.04.2014 mlrd 01.04  Proc mit NS
#  10.02.2014 mlrd 01.03  kein puts bei dolog
#  28.11.2013 mlrd 01.02  jmatrixtostring mit csv::join
#  22.22.2013 mlrd 01.01  jetzt
#  28.08.2013 mlrd 01.00  Original
# ###################################################################
#-----------------------------------------------------------------------
#      utils-package
#-----------------------------------------------------------------------

namespace eval utils  {
   # alle utils-Pakete laden
   #
   package require utils::dz
   package require utils::file
   package require utils::suchen
   package require utils::gui
   package require utils::thread
   
   package require Opts
   package require widgets::tw
   
   #---------- Variable ------------------------------------------------
   variable test           0
   variable packagename    {utils}
   variable rundir
   
   #--------- interne Funktionen ------------------------------------------
   
   # -------------------------------------------------------------------
   ###-----------------------------------------------------------------------------
   #    proc debuginfo {} {
   #       set str {
   #          # ---------------Debug -----------------
   #          # 1 : Trace proc
   #          # 2 :
   #          # 3 :
   #          # 4 : Trace Result
   #          # 5 : interner Ablauf
   #          # 100 : remSendmail-Kdo
   #          # 101 : Sendmail-Args
   #          
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
   #    
   #    #--------------------------------------------------------------------
   #    proc _proctrace {} {
   #       #--------------------------------------------------------------------
   #       set infoLev [info level -1]
   #       _dbg 1 Proctrace {set infoLev}
   #    }
   #    
   #    #--------------------------------------------------------------------
   #    proc _resulttrace {msg} {
   #       #--------------------------------------------------------------------
   #       variable packagename
   #       set infolevel [info level -1]
   #       ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
   #    }
   #    #-----------------------------------------------------------------------
   ###-----------------------------------------------------------------------------
   proc init {args} {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      variable test
      variable rundir
      
      ##nagelfar variable opts varName
      ::Opt::opts opts $args {
         {-test   {0}  "Simulation Betrieb"}
         {-rundir {}   "Pfad"}
      }
      set test   $opts(-test)
      set rundir $opts(-rundir)
      
      return
   }
   
}
#--------------------------------------------------------------------
#--------------    Hauptfunktionen         --------------------------
#--------------------------------------------------------------------


###-----------------------------------------------------------------------------
#
# Proc: printliste
#
# *::utils::printliste liste name offset*
#
#   druckt eine Liste nach STDOUT.
#
# Parameter:
#     liste: Name oder Variablenname der Liste
#     name: optionale Bezeichnung der Liste (default:'')
#     offset: Ein String mit n Blanks. Die Elemente der
#     Liste werden mit dem Versatz *offset* gelistet.  (default:'')
#
#
# Beispiel:
# (start code)
# set liste { a qs d}
# printliste $liste LISTE {  }
#  Liste LISTE
#  0: a
#  1: qs
#  2: d
#  Ende LISTE
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::printliste {liste {name {}} {offset {}} } {
   upvar $liste varListe
   
   if {[info exists varListe]} {
      if {$name == {}} {set name $liste}
      set liste $varListe
   }
   
   set nr 0
   puts "Liste $name"
   foreach element $liste {
      puts "$offset $nr: <$element>"
      incr nr
   }
   puts "Ende $name"
}

###-----------------------------------------------------------------------------
#
# Proc: printlistestring
#
# *::utils::printlistestring liste name offset*
#
#  druckt eine Liste in einen String
#
# Parameter:
#     liste: Name oder Variablenname der Liste
#     name: optionale Bezeichnung der Liste (default:'')
#     offset: Ein String mit n Blanks. Die Elemente der
#              Liste werden mit dem Versatz *offset* gelistet.
#             (default:'')
#
#
###-----------------------------------------------------------------------------
proc ::utils::printlistestring {liste {name {}} {offset {}} } {
   upvar $liste varListe
   
   if {[info exists varListe]} {
      if {$name == {}} {set name $liste}
      set liste $varListe
   }
   
   set str "Liste $name\n"
   set nr 0
   foreach element $liste {
      append str "$offset $nr: $element\n"
      incr nr
   }
   append str "Ende $name"
   return $str
}

###-----------------------------------------------------------------------------
#
# Proc: printarraystring
#
# *::utils::printarraystring array pattern*
#
#  druckt ein Array in einen String
#
# Parameter:
#     array: Name des Array
#     pattern: Muster für die Schlüssel
#
#
###-----------------------------------------------------------------------------
proc ::utils::printarraystring {arrayV {pattern *}} {
   upvar $arrayV a
   
   if { ![array exists a] } { error "\"$arrayV\" isn't an array" }
   
   set lines [list]
   set max 0
   foreach name [array names a $pattern] {
      set len [string length $name]
      if { $len > $max } { set max $len }
   }
   set max [expr {$max + [string length $arrayV] + 2}]
   foreach name [array names a $pattern] {
      set line [format %s(%s) $arrayV $name]
      lappend lines [format "%-*s = %s" $max $line $a($name)]
   }
   return [join [lsort $lines] \n]
   
}

# -------------------------------------------------------------------------
#
# Proc: range
#
# *::utils::range from to step*
#
# liefert eine Integer-Liste von .. bis inclusive
#
#  Der letzte Listenwert ist der Endewert (inclusive).
#  Die Parameter können negativ sein
#
# Parameter:
#
#  from:       Startwert
#  to:         Endewert
#  step:       Increment (default:1)
#
# Ergebnis:
#  Liste mit Integern
#
# Beispiel:
# (start code)
# range 5 1 -1  --> 5 4 3 2 1
#
# range 1 5 2  -->  1 3 5
#
# range 5 --> 0 1 2 3 4 5
#
# range 1 4 -1  --> 1
# (end)
#
# -------------------------------------------------------------------
proc ::utils::range {from to {step 1}} {
   set res $from
   while {$step>0?$to>$from:$to<$from} {lappend res [incr from $step]}
   return $res
}


###-----------------------------------------------------------------------------
#
# Proc: lremove
#
# *::utils::lremove liste wert1*
#
# löscht in einer Liste alle *gleichen* Elemente
#
# Parameter:
#     liste: Name der Liste.
#     wert: Alle Elemente mit exakt *wert* werden gelöscht.
#
# Hinweis:
# wert darf keine Liste und nicht {} sein
#
# Ergebnis:
# veränderte Liste
#
#
# Beispiel:
# (start code)
# set liste {a b c a d e}
# lremove $liste {a}  --> b c d e
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::lremove  {liste wert } {
   if {$wert == {}} {
      puts "l_remove : wert={} nicht erlaubt"
      return $liste
   }
   #puts "vorher"
   #printListe  $liste l_remove
   set liste [lsearch -all -inline -not -exact $liste $wert]
   #puts "nachher"
   #printListe  $liste l_remove
   return $liste
}

###-----------------------------------------------------------------------------
#
# Proc: ldelete
#
# *::utils::ldelete liste idxliste*
#
#  löscht in einer Liste alle Werte, deren Indices in der
# Liste *idxliste* enthalten sind.
#
# Parameter:
#     liste: Name der Liste.
#     idxliste: Liste aller Indizes zum Löschen. In der Liste sind nur Integer zulässig, end ist nicht erlaubt.
#
# Ergebnis:
# veränderte Listenwert
#
#
# Beispiel:
# (start code)
# set liste {a b c d e}
# ldelete $liste {0 1}  --> c d e
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::ldelete  {liste idxliste } {
   
   if {$idxliste == {}} {return $liste}
   if {$liste    == {}} {return {}}
   
   set nr -1
   set erg {}
   foreach el $liste {
      incr nr
      if {[lsearch -integer -exact $idxliste $nr] >= 0} {continue}
      lappend erg $el
   }
   return $erg
}

###-----------------------------------------------------------------------------
#
# Proc: matrixtostring
#
# *::utils::matrixtostring matrix sepc dos*
#
#
# _matrixtostring_ macht aus einer Matrix (Liste in Liste)
# einen String mit mehreren Zeilen.
# Die Werte der Liste sind mit einem wählbaren
# Zeichen getrennt.
#
# Parameter:
#     matrix: Matrixname (Liste in einer Liste)
#     sepc: Trennzeichen zwischen den Listenelementen (default: ;)
#     dos: wird am Zeilenende angehängt, .z.B \r bei DOS.
#             (default:'')
#
# Ergebnis:
# mehrzeiliger Text
#
#
###-----------------------------------------------------------------------------
proc ::utils::matrixtostring {matrix {sepc {;}} {dos {}} } {
   if {$matrix == {}} {return {}}
   package require csv
   
   set ergStr {}
   foreach z $matrix {
      append ergStr "[::csv::join $z $sepc]$dos\n"
   }
   # letztes nl entfernen
   set ergStr [string range $ergStr 0 end-1]
   return $ergStr
}

###-----------------------------------------------------------------------------
#
# Proc: splitstring
#
# *::utils::splitstring str*
#
#  spaltet einen String in eine Wortliste. Trennzeichen sind
# ein oder mehrere Leerzeichen.
#
# Parameter:
#     str: Textstring
#
# Ergebnis:
#
# Liste
#
# Beispiel:
# (start code)
# splitstring {123    456 789 1}
#   --> 123 456 789 1
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::splitstring {str} {
   set str [string trim $str]
   regsub -all -- { +} $str { } str
   return [split $str]
}

###-----------------------------------------------------------------------------
#
# Proc: splitfix
#
# *::utils::splitfix str len*
#
#   spaltet einen String in eine Liste mit Elementen fester
#   Länge . Das letzte Element ist der verbleibende Rest.
#
# Parameter:
#     str: Textstring
#     len: Länge der Listenelemete
#
# Ergebnis:
# Liste  mit Elementen gleicher Länge, ggf ist das letze
# Element kürzer aber nicht leer.
#
# Beispiel:
# (start code)
# splitfix {1234567891} 3
#   -->  123 456 789 1
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::splitfix {str len} {
   
   if {![string is integer $len] } {
      return -code error "len <$len> muss Integer sein"
   }
   if {$len <= 0 } {
      return -code error "len <$len> muss > 0 sein"
   }
   
   incr len -1
   set lenStr [string length $str]
   set von 0
   set bis 0
   incr bis $len
   set liste {}
   while {$bis < $lenStr} {
      set ele [string range $str $von $bis ]
      incr von $len
      incr bis $len
      incr von
      incr bis
      lappend liste $ele
   }
   
   # gibt es Rest
   incr bis -$len
   set rest [string range $str $bis end]
   if {$rest != {} } {
      lappend liste $rest
   }
   return $liste
}

###-----------------------------------------------------------------------------
#
# Proc: printdict
#
# *::utils::printdict d i p s fout*
#
#  druckt ein Dictionary.
#
# Parameter:
#     d: Name des Dictionaries
#     i: indent level (default: 0)
#     p: prefix string for one level of indent (default:"  ")
#     s: separator string between key and value (default:"  -> ")
#     fout: Ausgabekanal  (default: stdout)
#
###-----------------------------------------------------------------------------
proc ::utils::printdict { d {i 0} {p "  "} {s " -> "} {fout {stdout}} } {
   set errorInfo $::errorInfo
   set errorCode $::errorCode
   set fRepExist [expr {0 < [llength\
         [info commands tcl::unsupported::representation]]}]
   while 1 {
      if { [catch {dict keys $d}] } {
         if {! [info exists dName] && [uplevel 1 [list info exists $d]]} {
            set dName $d
            unset d
            upvar 1 $dName d
            continue
         }
         return -code error  "error: PrintDict - argument is not a dict"
      }
      break
   }
   if {[info exists dName]} {
      puts $fout "dict $dName"
   }
   set prefix [string repeat $p $i]
   set max 0
   foreach key [dict keys $d] {
      if { [string length $key] > $max } {
         set max [string length $key]
      }
   }
   dict for {key val} ${d} {
      puts -nonewline $fout "${prefix}[format "%-${max}s" [list $key]]$s"
      if {    $fRepExist && ! [string match "value is a dict*"\
            [tcl::unsupported::representation $val]]
         || ! $fRepExist && [catch {dict keys $val}] } {
         puts $fout "'${val}'"
      } else {
         puts $fout ""
         printdict $val [expr {$i+1}] $p $s $fout
      }
   }
   set ::errorInfo $errorInfo
   set ::errorCode $errorCode
   return ""
}

###-----------------------------------------------------------------------------
#
# Proc: printdictstring
#
# *::utils::printdictstring d i p s*
#
#   Dictionary drucken und als String liefern
#
# Parameter:
#     d: Name des Dictionaries
#     i: indent level (default: 0)
#     p: prefix string for one level of indent (default:"  ")
#     s: separator string between key and value (default:"  -> ")
#
# Ergebnis:
#
# String
#
###-----------------------------------------------------------------------------
proc ::utils::printdictstring { d {i 0} {p "  "} {s " -> "} } {
   while 1 {
      if { [catch {dict keys $d}] } {
         if {! [info exists dName] && [uplevel 1 [list info exists $d]]} {
            set dName $d
            unset d
            upvar 1 $dName d
            continue
         }
         return -code error  "error: PrintDict - argument is not a dict"
      }
      break
   }
   set tmpFile [::utils::file::tmpname {tmp_printdict}]
   set fout [open $tmpFile w]
   
   printdict $d $i $p $s $fout
   close $fout
   
   set str [::utils::file::readfile $tmpFile]
   file delete $tmpFile
   return $str
}

###-----------------------------------------------------------------------------
#
# Proc: printdictkeys
#
# *::utils::printdictkeys d i p s*
#
# druckt die Schlüsselstruktur eines Dictionaries nach STDOUT.
#
# Parameter:
#     d: Name des Dictionaries
#     i: indent level (default: 0)
#     p: prefix string for one level of indent (default:"  ")
#     s: separator string between key and value (default:" -> ")
#
#
# Beispiel:
# (start code)
#  set d [dict create a {1 i 2 j 3 k} b {x y z} \
#      c {i m j {q w e r} k o}]
#   --> a {1 i 2 j 3 k} b {x y z} c {i m j {q w e r} k o}
#  printdictkeys $d
#  a ->
#      1 ->
#      2 ->
#      3 ->
#  b ->
#  c ->
#      i ->
#      j ->
#         q ->
#         e ->
#      k ->
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::printdictkeys { d {i 0} {p {  }} {s " -> "} } {
   set errorInfo $::errorInfo
   set errorCode $::errorCode
   set fRepExist [expr {0 < [llength\
         [info commands tcl::unsupported::representation]]}]
   while 1 {
      if { [catch {dict keys $d}] } {
         if {! [info exists dName] && [uplevel 1 [list info exists $d]]} {
            set dName $d
            unset d
            upvar 1 $dName d
            continue
         }
         return -code error  "error: PrintDict - argument is not a dict"
      }
      break
   }
   if {[info exists dName]} {
      puts "dict $dName"
   }
   set prefix [string repeat $p $i]
   set max 0
   foreach key [dict keys $d] {
      if { [string length $key] > $max } {
         set max [string length $key]
      }
   }
   dict for {key val} ${d} {
      puts  "${prefix}[format "%-${max}s" $key]$s"
      if {    $fRepExist && ! [string match "value is a dict*"\
            [tcl::unsupported::representation $val]]
         || ! $fRepExist && [catch {dict keys $val}] } {
         #puts "'${val}'"
      } else {
         puts ""
         printdictkeys $val [expr {$i+1}] $p $s
      }
   }
   set ::errorInfo $errorInfo
   set ::errorCode $errorCode
   return ""
}

###-----------------------------------------------------------------------------
#
# Proc: dictget
#
# *::utils::dictget dict args*
#
# Liefert einen Wert passend zu einer Schlüsselliste keys
# aus einem Dictionary. Mit _-default wert_ kann ein
# fehlender Wert vorbelegt werden und
# damit ein Fehler abgefangen werden.
#
# Parameter:
#     dict: Name des Dictionaries.
#     args: key1 key2 .. -default xx,
#           Default ist mit Blank vorbelegt
#
# Ergebnis:
#  Wert passend zu den Schlüsseln
#
#
# Beispiel:
# (start code)
# set wert [dictget $dict key1 key2 -default abc]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::dictget {dict args} {
   
   set default {}
   if {[lindex $args end-1] == {-default}} {
      set default [lindex $args end]
      set args [lrange $args 0 end-2 ]
   }
   if {$dict == {}} {
      if {[info exists default] } {
         return $default
      } else {
         return -code error "dict ist {}"
      }
   }
   if {[dict exists $dict {*}$args] } {
      return [dict get $dict {*}$args]
   } else {
      return $default
   }
}

###-----------------------------------------------------------------------------
#
# Proc: sliceliste
#
# *::utils::sliceliste liste anz*
#
#  wandelt eine Liste in eine Matrix.
#
# _sliceliste_ macht aus einer 1-dimensionalen Liste
# eine Matrix mit anz Spalten. Die letzte Zeile
# enthält den Rest und ist ggf kürzer.
#
# Parameter:
#     liste: Name der Liste
#     anz: Die Matrix hat anz Spalten.
#
# Ergebnis:
# - Matrix
# - leere Liste, wenn anz = 0
#
# Beispiel:
# (start code)
# sliceliste {12 34 56 78 91} 3
#   12 34 56
#   78 91
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::sliceliste {liste anz} {
   if {![string is integer $anz] } {
      return -code error "anz <$anz> muss Integer sein"
   }
   
   if {$anz < 0} {
      return -code error "anz <$anz> muss > 0 sein"
   }
   if {$anz == 0} {return {}}
   
   set lenListe [llength $liste]
   if {$lenListe == 0} {return {}}
   
   # Länge der Liste minus 1
   incr lenListe -1
   set nr -1
   set ergL {}
   set anz_1 [incr anz -1]
   #puts "len:$lenListe"
   
   foreach w $liste {
      set von [incr nr]
      set bis [incr nr $anz_1]
      if {$von > $lenListe} {break}
      #set slice [lrange $liste $von $bis]
      lappend ergL [lrange $liste $von $bis]
      #puts "$von $bis: <$slice<"
      set nr $bis
   }
   #puts $ergL
   return $ergL
   
}

###-----------------------------------------------------------------------------
#
# Proc: matrixtranspose
#
# *::utils::matrixtranspose mvar*
#
# transponiert eine Matrix (Liste in Liste).
# Die Matrix hat zwei Dimensionen und wird per Variable übergeben
#
# Parameter:
#     mvar: Variablenname der Matrix
#
# Ergebnis:
# Matrix
#
#
###-----------------------------------------------------------------------------
proc ::utils::matrixtranspose {_M} {
   upvar $_M M
   foreach row $M {
      set c 0
      ##nagelfar variable c varName
      foreach element $row {lappend $c $element; incr c}
   }
   set res [list]
   ##nagelfar variable c varName
   for {set c 0} {$c<[llength $row]} {incr c} {
      ##nagelfar variable c varName
      lappend res [set $c]
   }
   set res
}


###-----------------------------------------------------------------------------
#
# Proc: matDelRow
#
# *::utils::matDelRow mat row*
#
# löscht in einer Matrix 'mat' (Liste in Liste) die Spalte Nummer 'row'.
#
# Parameter:
#     mat: Name der Matrix
#     row: Spaltennummer
#
# Ergebnis:
# neue Matrix
#
# Fehler:
# mat oder row {} oder row zu gross. Ergebnis ist dann {}
#
###-----------------------------------------------------------------------------

#-----------------------------------------------------------------------
proc ::utils::matDelRow {mat row} {
   # löscht in der Matrix mat die Spalte Nummer row
   # Liefert {} bei Fehler sonst matNeu
   #-----------------------------------------------------------------------
   
   if {$row eq ""} {return {}}
   if {$mat eq ""} {return {}}
   
   # Anzahl Spalten
   set len [llength [lindex $mat 0]]
   if {$row > $len} {return {}}
   
   set matNeu [list]
   foreach li $mat {
      set li1 [lreplace $li $row $row ]
      lappend matNeu $li1
   }
   
   return $matNeu
}


###-----------------------------------------------------------------------------
#
# Proc: dicttomat
#
# *::utils::dicttomat d matVar keys*
#
#   liefert eine Matrix aus einem Dictionary
#
# Parameter:
#     d: Name des Dictionaries.
#     matVar: Variable Matrix
#     keys: Liste aller Schlüssel
#
# Ergebnis:
# Matrix (Liste in Liste)
#
#
# Beispiel:
# (start code)
#   set mat {}
#   dicttomat $d mat {}
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::dicttomat {d matVar keys} {
   upvar $matVar mat
   if {[catch {dict keys $d} subkeys] || $d == {}} {
      set wert $d
      lappend keys $wert
      set mat [concat $mat [list $keys]]
      return
   } else {
      foreach k $subkeys {
         set d1 [dict get $d $k]
         set keys1 [concat $keys [list $k]]
         ##nagelfar variable matVar varName
         dicttomat $d1 $matVar $keys1
      }
   }
}

###-----------------------------------------------------------------------------
#
# Proc: dictgetkeys
#
# *::utils::dictgetkeys d keys*
#
#   liefert die Schlüssel der Ebene i eines Dictionaries.
#
# Parameter:
#     d: Name des Dictionaries.
#     keys : Schlüssel Ebene1 Ebene2 ... Ebene i
#
# Ergebnis:
# Liste der Subkeys
#
#
# Beispiel:
# (start code)
#   set keys [dictgetkeys $d [list $k1 $k2]]
# (end)
#
###-----------------------------------------------------------------------------
proc ::utils::dictgetkeys {d {keys {}} } {
   
   # keine Schlüssel -> Ebenen 0
   if {$keys eq {}} {
      return [dict keys $d]
   }
   
   set k0 [lindex $keys 0]
   set d1 [dict get $d $k0]
   
   if {[catch {dict keys $d1} k1]} {
      return {}
   }
   
   set k2 [lrange $keys 1 end]
   # Ende erreicht ?
   if {$k2 eq ""} {return $k1}
   
   dictgetkeys $d1 [lrange $keys 1 end]
   
}

###-----------------------------------------------------------------------------
#
# Proc: dostat
#
# *::utils::dostat datei spusName args*
#
# erzeugt einen Statistikeintrag.
# Der Eintrag wird mit Datum, Zeit, Host und SpusName ergänzt.
# Zeilenwechsel in der Meldung werden mit -~- maskiert. Ebenso kann
# ein Zeilenwechsel in der Meldung vom Benutzer vorgegeben
# werden.
# Die Spalten werden ° getrennt.
#
# Wenn die Statistikdatei > 1 MB ist, wird eine neue Datei angelegt.
# Es wird maximal eine archivierte Statistikatei behalten.
#
# Parameter:
#     datei: Statistikdatei (XTOOLSHOME/progr/stat.log)
#     spusName: Name Spectrum-User
#     args: Statistikparameter (proc p1 p2 p3...)
#
###-----------------------------------------------------------------------------
proc ::utils::dostat {datei spusName args} {
   
   set sf $datei
   file mkdir [file dirname $sf]
   set heute [::utils::dz::heute]
   set jetzt [::utils::dz::jetzt]
   set msg "${heute}°${jetzt}°[info hostname]°$spusName"
   foreach ar $args {
      regsub -all -- "\n" $ar {-~-} ar
      append msg "°$ar"
   }
   ::utils::file::appendfile $sf "$msg\n"
   
   # --------------------- Statfile umbenennen wenn > 1MB
   #
   file stat $sf size
   if {$size(size) > 1000000 } {
      set altStat "[file rootname $datei]_${heute}_${jetzt}.log"
      set info "${heute}°${jetzt}°[info hostname]°${spusName}°altes Statfile umbenannt in $altStat"
      ::utils::file::appendfile $sf $info
      file rename -force $sf $altStat
      
      # nur 2 arch Statdateien übrig lassen
      set statLogs [glob -nocomplain  [file rootname $datei]*]
      set li ""
      foreach logf $statLogs {
         lappend li [list $logf [file mtime $logf]]
      }
      set li [lsort -index 1 $li]
      while {[llength $li] >1} {
         set info "${heute}°${jetzt}°[info hostname]°${spusName}°file delete [lindex $li 0 0]"
         ::utils::file::appendfile $sf "$info\n"
         file delete -force [lindex $li 0 0]
         set li [lrange $li 1 end]
      }
   }
}

###-----------------------------------------------------------------------------
#
# Proc: nooctal
#
# *::utils::nooctal zi*
#
# entfernt bei einer Ziffer mit oder ohne Vorzeichen die
# führenden Nullen.
#
# Parameter:
#     zi: Ziffer mit oder ohne Vorzeichen
#
# Ergebnis:
# Ziffer mit oder ohne Vorzeichen ohne führende Nullen
#
#
###-----------------------------------------------------------------------------
proc ::utils::nooctal {zi} {
   if {$zi == {} } {return {}}
   if {![regexp  -expanded -- {
         ^\s*
         ([+-]*)     # Vorzeichen
         ([0])*      # führende Nullen
         (\d+)       # Ziffern
         \s* $
      } $zi dum vz null  z ]} {
      return -code error "nooctal: <$zi> muss  \[+-\] \[0*\] \[d\]+ sein"
   }
   return "$vz$z"
}

###-----------------------------------------------------------------------------
#
# Proc: dolog
#
# *::utils::doLog logfile spusName typ msgP*
#
# schreibt eine Meldung in eine Logdatei.
# Die Meldung wird mit Datum, Zeit, Host und SpusName ergänzt.
# Zeilenwechsel in der Meldung werden mit -~- maskiert. Ebenso kann
# ein Zeilenwechsel in der Meldung vom Benutzer vorgegeben
# werden.
# Die Spalten werden ° getrennt.
#
# Wenn die Logdatei > 1 MB ist, wird eine neue Datei angelegt.
# Es wird maximal eine archivierte LogDatei behalten.
#
# Je nach Meldungstyp wird
#
# - ::utils::logfehler
# - ::utils::logwarnung
#
# gesetzt.
#
# Parameter:
#     logFile: Pfad zur Logdatei.
#     spusName: Name Spectrum-User
#     typ: Meldungstyp F|W|I
#     msgP: Logmeldung
#
#
###-----------------------------------------------------------------------------
proc ::utils::dolog {logFile spusName typ msgP} {
   
   switch -exact -- $typ  {
      F  {set ::utils::logfehler 1}
      W  {set ::utils::logwarnung 1}
      I  {}
      default {return -code error "dolog Typ :<$typ> muss F W oder I"}
   } ; # end switch
   
   if {![file exists $logFile]} {
      file mkdir [file dirname $logFile]
   }
   
   regsub -all -- "\n" $msgP {-~-} msgP
   #regsub -all -- {\|} $msgP {_} msgP
   set heute [::utils::dz::heute]
   set jetzt [::utils::dz::jetzt]
   set msg "${heute}°${jetzt}°[info hostname]°${spusName}°"
   append msg "${typ}°$msgP"
   
   ::utils::file::appendfile $logFile "$msg\n"
   
   # Logfile umbenennen wenn > 1MB
   file stat $logFile size
   if {$size(size) > {1000000}} {
      set altLog "[file rootname $logFile]_${heute}_${jetzt}.log"
      set info "${heute}°${jetzt}°[info hostname]°${spusName}°I°altes Logfile umbenannt in $altLog"
      puts $info
      ::utils::file::appendfile $logFile "$info\n"
      file rename -force $logFile $altLog
      
      # nur eine arch Logdatei übrig lassen
      set arvLogs [glob -nocomplain  [file rootname $logFile]*]
      set li ""
      foreach logf $arvLogs {
         lappend li [list $logf [file mtime $logf]]
      }
      set li [lsort -index 1 $li]
      while {[llength $li] >1} {
         set info "${heute}°${jetzt}°[info hostname]°${spusName}°I°file delete [lindex $li 0 0]"
         ::utils::file::appendfile $logFile "$info\n"
         file delete -force [lindex $li 0 0]
         set li [lrange $li 1 end]
      }
   }
}

###-----------------------------------------------------------------------------
#
# Proc: readCfgU
#
# *::utils::readCfgU user prg*
#
#
#  liest die userspez. Konfiguration.
# Die Konfiguration wird von _saveCfgU_ in der Datei
# XTOOLSHOME/programm/usercfg/user/programm.cfg abgelegt.
#
# Parameter:
#     user: Name (spusname)
#     prg: Programmname
#
# Ergebnis:
# Dictionary wird von getCfgKeyU gelesen
#
# siehe auch:
# - saveCfgU
# - getCfgKeyU
#
###-----------------------------------------------------------------------------
proc ::utils::readCfgU {user prg} {
   variable cfg
   
   set userCfgDir [::utils::_userCfgDir]
   if {$userCfgDir eq ""} {return ""}
   
   set cfgDatei [file join $userCfgDir "${user}_${prg}.cfg"]
   
   if {[file readable $cfgDatei] } {
      set cfg [::utils::file::readfile $cfgDatei]
      DoLog I "$cfgDatei gelesen"
   } else {
      ::utils::gui::msgow1 "$cfgDatei nicht gefunden"
      return
   }
   
   foreach k [dict keys $cfg ] {
      set wert [dict get $cfg $k]
      #_dbg 4 ReadCfg {format "$k = $wert"}
      switch -- $k {
         geo {
            # wird in xstaff verarbeitet
         }
         default {
            # hier kommen die Variablen
            ##nagelfar variable k varName
            catch {set $k $wert}
            #puts "$k = $wert"
         }
      }
   }
   # savedFilterListe {2 {f1} 4 {f3} ...  }
   if {[info exists ::widgets::tabfs::savedFilterListe]} {
      set ele [llength $::widgets::tabfs::savedFilterListe]
      set anz [expr {$ele / 2}]
      DoLog I "Anz Filter gelesen: $anz"
      #puts "Anz Filter gelesen: $anz"
   }
   
}

###-----------------------------------------------------------------------------
#
# Proc: getCfgKeyU
#
# *::utils::getCfgKeyU key user prg*
#
# liest aus der Konfig-Datei einen Wert zu einem Schlüssel
#
# Parameter:
#     key: Schlüssel
#     user: Name (spusname)
#     prg: Programm
#
# Ergebnis:
# String oder {}
#
# siehe auch:
# - readCfgU
#
###-----------------------------------------------------------------------------
proc ::utils::getCfgKeyU {key user prg} {
   variable cfg
   
   set userCfgDir [::utils::_userCfgDir]
   if {$userCfgDir eq ""} {return ""}
   
   set cfgDatei [file join $userCfgDir "${user}_${prg}.cfg"]
   
   if {[file readable $cfgDatei] } {
      set cfg [::utils::file::readfile $cfgDatei]
      #puts "$cfgDatei gelesen"
   } else {
      return
   }
   
   if {[dict exists $cfg $key] } {
      return [dict get $cfg $key]
   } else {
      return {}
   }
}
#-----------------------------------------------------------------------
proc ::utils::_userCfgDir {} {
   # legt das Verzeichnis für userspez. Historie
   # test: ~/devroot/spsy/<prg>/usercfg/
   #     : ~/xtools/<prg>/usercfg/
   # SpusHome ist nicht writable
   #-----------------------------------------------------------------------
   #_proctrace
   variable rundir
   
   set base $rundir
   set userCfgDir [file join $base usercfg]
   if {[catch {file mkdir $userCfgDir} msg]} {
      return ""
   }
   
   return $userCfgDir
}

###-----------------------------------------------------------------------------
#
# Proc: saveCfgU
#
# *::utils::saveCfgU user prg top cfgVars*
#
#  speichert die userspez. Konfiguration
#
# Die Konfiguration wird in der Datei
# XTOOLSHOME/programm/usercfg/user/programm.cfg abgelegt.
#
# Parameter:
#     user: Name (spusname)
#     prg: Programmname
#     top: Toplevelwindow
#     cfgvarsPf: Pfad zur Datei mit Variablen zur
#       Konfiguration, ia. <scriptDir/cfg_vars.txt
#
# siehe auch:
# - readCfgU
# - getCfgKeyU
#
###-----------------------------------------------------------------------------
proc ::utils::saveCfgU {user prg top cfgvarsPf  } {
   variable cfg
   
   set cfg {}
   set userCfgDir [::utils::_userCfgDir]
   if {$userCfgDir eq ""} {return ""}
   
   set cfgDatei [file join $userCfgDir "${user}_${prg}.cfg"]
   
   # geo
   if {[catch {winfo geometry $top} geoxy]} {
      return
   }
   
   catch {dict set cfg geo $geoxy}
   
   # vars
   set vars {}
   catch {set vars [::utils::file::readliste $cfgvarsPf]}
   foreach v $vars {
      set v [string trim $v]
      if {$v == ""} {continue }
      if {[string match {#*} $v]} {continue}
      ##nagelfar variable v varName
      if {[info exists $v] } {
         dict set cfg  "$v" [set $v]
      }
   }
   if {$cfg == ""} {return}
   
   ::utils::file::writefile $cfgDatei $cfg
   #_dbg 4 SaveCfgDict {::utils::printdictstring $cfg}
   # puts "$cfgDatei erstellt"
   DoLog I "$cfgDatei erstellt"
   catch {
      set fl [::utils::dictget $cfg ::widgets::tabfs::savedFilterListe ]
      # savedFilterListe {2 {f1} 4 {f3} ...  }
      set ele [llength $fl]
      set anz [expr {$ele / 2}]
      DoLog I "$anz Filter gespeichert"
      #puts "$anz Filter gespeichert"
   }
   return
}

###-----------------------------------------------------------------------------
#
# Proc: readCfg
#
# *::utils::readCfg prg*
#
#  liest die userspez. Programmkonfiguration
#
# Die Konfiguration wird von saveCfg in der Datei
# XTOOLSHOME/programm/usercfg/programm.cfg abgelegt.
#
# Hinweis:
# Da spsy nicht in das User-Verzeichnis schreiben darf,
# kann zZ nur readCfgU verwendet werden.
#
# Parameter:
#     prg: Programmname
#
# Ergebnis:
# Dictionary wird von getCfgKey gelesen
#
# siehe auch:
# - saveCfg
# - getCfgKey
#
###-----------------------------------------------------------------------------
proc ::utils::readCfg {prg} {
   variable cfg
   
   set userCfgDir [::utils::_userCfgDir]
   if {$userCfgDir eq ""} {return ""}
   
   set cfgDatei [file join $userCfgDir "${prg}.cfg"]
   
   if {[file readable $cfgDatei] } {
      set cfg [::utils::file::readfile $cfgDatei]
      puts "$cfgDatei gelesen"
   } else {
      return
   }
   
   foreach k [dict keys $cfg ] {
      set wert [dict get $cfg $k]
      #_dbg 4 ReadCfg {format "$k = $wert"}
      switch -- $k {
         geo {
            # wird in xstaff verarbeitet
         }
         default {
            # hier kommen die Variablen
            ##nagelfar variable k varName
            catch {set $k $wert}
         }
      }
   }
}

###-----------------------------------------------------------------------------
#
# Proc: getCfgKey
#
# *::utils::getCfgKey key prg*
#
# liest aus der Konfig-Datei einen Schlüssel
# XTOOLSHOME/programm/usercfg/programm.cfg abgelegt.
#
# Hinweis:
# Da spsy nicht in das User-Verzeichnis schreiben darf,
# kann zZ nur getCfgU verwendet werden.
#
#
# Parameter:
#     key: Scklüssel
#     prg: Programm
#
# Ergebnis:
# String oder {}
#
# siehe auch:
# - readCfg
#
###-----------------------------------------------------------------------------
proc ::utils::getCfgKey {key prg} {
   variable cfg
   
   set userCfgDir [::utils::_userCfgDir]
   if {$userCfgDir eq ""} {return ""}
   
   set cfgDatei [file join $userCfgDir "${prg}.cfg"]
   
   if {[file readable $cfgDatei] } {
      set cfg [::utils::file::readfile $cfgDatei]
      #puts "$cfgDatei gelesen"
   } else {
      return {}
   }
   
   if {[dict exists $cfg $key] } {
      return [dict get $cfg $key]
   } else {
      return {}
   }
}
###-----------------------------------------------------------------------------
#
# Proc: saveCfg
#
# *::utils::saveCfg prg top cfgVarsPf*
#
#  speichert die userspez. Programmkonfiguration.
#
# Die Konfiguration wird in der Datei
# XTOOLSHOME/programm/usercfg/user_programm.cfg abgelegt.
#
# Hinweis:
# Da spsy nicht in das User-Verzeichnis schreiben darf,
# kann zZ nur saveCfgU verwendet werden.
#
# Parameter:
#     prg: Programmname
#     top: Toplevelwindow
#     cfgvarsPf: Pfad mit Datei mit Variablen zur
#       Konfiguration, ia. <scriptDir/cfg_vars.txt
#
# siehe auch:
# - readCfg
# - getCfgKey
#
###-----------------------------------------------------------------------------
proc ::utils::saveCfg {prg top cfgvarsPf} {
   variable cfg
   set cfg {}
   
   set userCfgDir [::utils::_userCfgDir]
   if {$userCfgDir eq ""} {return ""}
   
   set cfgDatei [file join $userCfgDir "${prg}.cfg"]
   
   # geo
   if {[catch {winfo geometry $top} geoxy]} {
      return
   }
   
   catch {dict set cfg geo $geoxy}
   
   # vars
   set vars {}
   #set cfgvarsPf [file join $gd(scriptDir) cfg_vars.txt]
   catch {set vars [::utils::file::readliste $cfgvarsPf]}
   foreach v $vars {
      set v [string trim $v]
      if {$v == ""} {continue }
      if {[string match {#*} $v]} {continue}
      ##nagelfar variable v varName
      if {[info exists $v] } {
         dict set cfg  "$v" [set $v]
      }
   }
   if {$cfg == ""} {return}
   
   ::utils::file::writefile $cfgDatei $cfg
   #_dbg 4 SaveCfgDict {::utils::printdictstring $cfg}
   puts "$cfgDatei erstellt"
   
}

###-----------------------------------------------------------------------------
#
# Proc: oneblank
#
# *::utils::oneblank str*
#
# fasst in einem String mehrere Blanks zu einem Blank zusammen.
#
# Parameter:
#     str: String
#
# Ergebnis:
# String
#
#
###-----------------------------------------------------------------------------
proc ::utils::oneblank {str} {
   
   regsub -all "\[ \t\]+" $str " " str
   return $str
}



###-----------------------------------------------------------------------------
#
# Proc: sendmail
#
# *::utils::sendmail args*
#
# Erstellt eine Mail und leitet sie an smtp weiter.
# Wenn eine Anhangdatei nicht lokal liegt, wird sie
# zuerst mit scp geholt. Jede Anhangdatei wird mit fünf
# Parametern beschrieben:
#
# ** Pfad : host:pfad
# ** Name : Name im Anhang
# ** zip  : wird gezippt
# ** crlf : Zeilenende für MS
# ** tmp  : ist tmp. Datei wird gelöscht (z.B. Bildausschnitt)
#
# Parameter:
#     args: Optionenpaare
#
# Optionen:
#
# -to  liste: Empfänger
# -cc  liste: CCs
# -bcc liste: BCCs
# -servers  liste: der möglichen Mailserver (Default:localhost)
# -ports  liste: der möglichen Ports (Default:25)
# -subject string: Betreff
# -headers liste: Header
# -mailtext  string: Mailtext
# -from  liste: Absender (optional)
# -atts  matrix: Anhangliste mit Parametern (pf name zip crlf tmp ....)
# -cs  Charset: des Mailtextes (Default: systemencoding)
# -debug bool: Debugflag für smtp
#
# Ergebnis:
# 0 : bei Erfolg
#
###-----------------------------------------------------------------------------
proc ::utils::sendmail {args} {
   #_proctrace
   
   package require mime
   package require smtp
   package require fileutil::magic::mimetype
   ##nagelfar variable params
   ::Opt::opts {params} $args {
      {-to         {}  "To-Liste"}
      {-cc         {}  "CC-Liste"}
      {-bcc        {}  "BCC-Liste"}
      {-servers    {localhost}  "Liste Mailserver"}
      {-ports      {25}  "Liste Mailserverports"}
      {-subject    {}  "Betreff obligat"}
      {-headers    {}  "Header-Liste"}
      {-mailtext   {}  "Anschreiben String|Datei"}
      {-from       {}  "Absender opt."}
      {-atts       {}  "Anhangliste mit Parametern (Matrix)"}
      {-cs         {}  "Charset Default:systemencoding"}
      {-debug      {0} "Smtp-Debug"}
   }
   
   set toList   $params(-to)
   set ccList   $params(-cc)
   set bccList  $params(-bcc)
   set servers  $params(-servers)
   set ports    $params(-ports)
   set subject  $params(-subject)
   set headers  $params(-headers)
   set mailtext $params(-mailtext)
   set from     $params(-from)
   set atts     $params(-atts) ;# Attname mit Ext
   set cs       $params(-cs)
   set debug    $params(-debug)
   
   set todelete ""
   
   # Plausis
   if {$subject eq ""} {set subject "kein Betreff"}
   if {$cs eq ""} {set cs [encoding system]}
   
   # Attachments bearbeiten
   # Attachmentparameter: {pfad anhangname  zip crlf tmp}
   # Pf:ad: host:pfad,
   set attsLi ""
   if {[llength $atts] != 0} {
      foreach att $atts {
         lassign $att hostpf attName zip crlf tmp
         
         set hostpf [string trim $hostpf]
         set ele [split $hostpf ":"]
         lassign $ele host pf
         # remote Datei holen
         if {[llength $ele] == 2} {
            set host [string trim [lindex $ele 0]]
            if {$host ne "localhost" && $host ne [info hostname]} {
               # remote Datei mit scp kopieren
               set tmpDatei [::utils::file::tmpname tmpsm]
               set scpcmd "scp -p $hostpf $tmpDatei"
               if {[catch {eval exec $scpcmd} msg]} {
                  file delete $tmpDatei
                  return -code error "F-scp $pf :$msg"
               }
               set pf $tmpDatei
               # zum Löschen vormerken
               lappend todelete $pf
            }
         } else {
            # Pfad ohne Host
            set pf $hostpf
         }
         
         # im Attachment-Name nur zulässige Zeichen
         set attName [string map \
            {/ _ ? _ \" _ ! _ $ _ [ _ ] _ \{ _ \} _ = _ * _ ; _ \\ _ % _ & __|_} $attName]
         
         # Zeilenende für Microsoft
         if {$crlf} {::utils::file::crlf $pf}
         
         # Datei zippen ?
         if {$zip} {
            # pf nach ~ kopieren wg Schreibrechte vom zipfile
            set tmpSrc [::utils::file::tmpname $attName.]
            #set tmpSrc $attName
            file copy $pf $tmpSrc
            
            set zipFile [::utils::file::zip  $tmpSrc -j]
            set mimeType "application/x-zip"
            set attName "$attName.zip"
            set pfad $zipFile
            lappend todelete $pfad
            lappend todelete $tmpSrc
            ::pool::atexit::add [list file delete -force $zipFile]
            #puts "pf:$pf \ntmp:$tmpSrc\nzip:$zipFile"
         } else {
            set pfad $pf
            set mimeType [_chooseMime $pf]
         }
         
         # tmp Datei löschen
         if {$tmp} {
            lappend todelete $pf
         }
         
         # neue Attachmentmatrix
         lappend attsLi [list $pfad $attName $mimeType $tmp]
      }
   }
   
   # Inhalt in mime verpacken
   #
   if {$attsLi == {}} {
      #--------------MimeToken für Body und kein Anhang
      set mimeT [::utils::_textToMime $mailtext $cs]
   } else {
      #--------------MimeToken für Body und Anhang
      set args [::utils::_textToMime $mailtext $cs]
      foreach att $attsLi {
         lassign $att pf name mimeType tmp
         lappend args [::utils::_fileToMime $pf $name $mimeType]
      }
      set mimeT [::utils::_multiPartMime {*}$args]
   }
   
   # mit charset kodieren
   set subject [::mime::word_encode $cs {quoted-printable} $subject]
   
   set mailargs [list     \
      -debug     $debug   \
      -servers   $servers \
      -ports     $ports   \
      -header    [list Subject $subject] \
      ]
   
   if {$from ne ""} {
      set mailargs [lappend mailargs -header [list From "$from"]]
   }
   foreach item $toList {
      set mailargs [lappend mailargs \
         -header [list To "$item"]]
   }
   foreach item $ccList {
      set mailargs [lappend mailargs \
         -header [list Cc "$item"]]
   }
   foreach item $bccList {
      set mailargs [lappend mailargs \
         -header [list Bcc "$item"]]
   }
   foreach {na wert} $headers {
      set mailargs [lappend mailargs \
         -header [list $na "$wert"]]
   }
   #_dbg 101 MailArgs {set mailargs}
   
   # -----------------------------------------------------------
   # set ret [eval [linsert $mailargs 0 smtp::sendmessage $mimeT]]
   if {[catch {eval [linsert $mailargs 0 smtp::sendmessage $mimeT]} ret]} {
      ::utils::gui::msg error "Fehler" $ret
      DoLog F $ret
   }
   
   # -----------------------------------------------------------
   mime::finalize $mimeT
   
   # nach 3 min aufräumen
   #    after 180000 list
   after 18 [list \
      foreach f $todelete {
         catch {file delete -force $f}
      } ]
   
   # an empty list indicates everything's went well with the mail server
   #if {[llength $ret] == 0}
   if {$ret eq ""} {
      return 0
   }
   
   return -code error $ret
}

#---------------------------------------------------------------------
proc ::utils::_multiPartMime {args} {
   #---------------------------------------------------------------------
   #_proctrace
   set multiT [mime::initialize -canonical multipart/mixed \
      -parts $args]
   return $multiT
}
#---------------------------------------------------------------------
proc ::utils::_fileToMime {pf name mimeType}  {
   #---------------------------------------------------------------------
   #_proctrace
   
   set tok [mime::initialize \
      -canonical "$mimeType; name=\"$name\"" \
      -header [list Content-Disposition "attachment; filename=\"$name\""] \
      -file $pf]
   return $tok
}

#---------------------------------------------------------------------
proc ::utils::_textToMime {text cs} {
   # cs: charset
   #---------------------------------------------------------------------
   
   #------------- Text Datei oder String
   #
   if {[file readable $text]} {
      set mimeT [mime::initialize -canonical text/plain -string $text]
   } else {
      set mimeT [mime::initialize -canonical text/plain \
         -param [list charset $cs] \
         -string $text]
   }
   return $mimeT
}
#---------------------------------------------------------------------
proc ::utils::_chooseMime {pf} {
   #---------------------------------------------------------------------
   #_proctrace
   
   set erg {}
   if {![file readable $pf]} {return {}}
   package require fileutil
   set type [::fileutil::fileType $pf]
   switch -glob -- $type {
      {binary graphic gif} {
         return {image/gif}
      }
      {binary graphic png} {
         return {image/png}
      }
      {binary graphic jpeg} {
         return {image/jpeg}
      }
      {binary graphic jpeg jfif} {
         return {image/jpeg}
      }
      {text} {
         return {text/plain}
      }
      {text * html} {
         return {text/html}
      }
      {binary executable*} {
         return {application/octet-stream}
      }
      {binary script*} {
         return {application/x-sh}
      }
      {binary pdf} {
         return {application/pdf}
      }
      {binary compressed*} {
         return {application/x-gzip}
      }
      default {
         set msg "$pf\nDateityp:<$type> unbekannt.\n<Text> wird verwendet"
         puts $msg
         return {text/plain}
      }
   }
}

###-----------------------------------------------------------------------------
#
# Proc: remsendmail
#
# *::utils::remsendmail admhost args*
#
# Erstellt eine Mail und leitet sie an smtp des ADMHost weiter.
# Ruft dazu über ssh das Programm sndml auf (weil nur ADM mailen darf).
# Wenn eine Anhangdatei nicht lokal liegt, wird sie
# zuerst mit scp geholt. Jede Anhangdatei wird mit fünf
# Parametern beschrieben:
#
# ** Pfad : host:pfad
# ** Name : Name im Anhang
# ** zip  : wird gezippt
# ** crlf : Zeilenende für MS
# ** tmp  : ist tmp. Datei wird gelöscht (z.B. Bildausschnitt)
#
# Parameter:
#     admhost: Host
#     args: Optionenpaare
#
# Optionen:
#
# -to  liste: Empfänger
# -cc  liste: CCs
# -bcc liste: BCCs
# -servers  liste: der möglichen Mailserver (Default:localhost)
# -ports  liste: der möglichen Ports (Default:25)
# -subject string: Betreff
# -headers liste: Header
# -mailtext  string: Mailtext
# -from  liste: Absender (optional)
# -atts  matrix: Anhangliste mit Parametern (pf name zip crlf tmp ....)
# -cs  Charset: des Mailtextes (Default: systemencoding)
# -debug bool: Debugflag für smtp
#
# Ergebnis:
# 0 : bei Erfolg
#
###-----------------------------------------------------------------------------

#-----------------------------------------------------------------------
proc ::utils::remSendmail {admHost args} {
   # ruft über ssh das Programm sndml auf (weil nur ADM mailen darf)
   #-----------------------------------------------------------------------
   #_proctrace
   variable test
   
   ##nagelfar variable params
   ::Opt::opts {params} $args {
      {-to         {}  "To-Liste"}
      {-cc         {}  "CC-Liste"}
      {-bcc        {}  "BCC-Liste"}
      {-servers    {localhost}  "Liste Mailserver"}
      {-ports      {25}  "Liste Mailserverports"}
      {-subject    {}  "Betreff obligat"}
      {-headers    {}  "Header-Liste"}
      {-mailtext   {}  "Anschreiben String|Datei"}
      {-from       {}  "Absender opt."}
      {-atts       {}  "Anhangliste mit Parametern"}
      {-cs         {}  "Charset Default:systemencoding"}
      {-debug      {0} "Smtp-Debug"}
   }
   
   # Attachmentparameter
   # {pfad anhangname  zip crlf}
   set toList   $params(-to)
   set ccList   $params(-cc)
   set bccList  $params(-bcc)
   set servers  $params(-servers)
   set ports    $params(-ports)
   set subject  $params(-subject)
   set headers  $params(-headers)
   set mailtext $params(-mailtext)
   set from     $params(-from)
   set atts     $params(-atts)
   set cs       $params(-cs)
   set debug    $params(-debug)
   
   # Headerliste in Headerstring
   # str: na1,wert1^na2,wert2
   set headerLi [list]
   set headerStr ""
   foreach {na wert} $headers {
      lappend headerLi "$na,$wert"
   }
   set headerStr ""
   if {$headerLi ne ""} {
      set headerStr [join $headerLi "^"]
   }
   
   # Attachmentmatrix in Attstring
   #
   set attListe [list]
   foreach att $atts {
      lappend attListe [join $att ","]
   }
   set attStr ""
   if {$attListe ne ""} {
      set attStr [join $attListe "^"]
   }
   # alle Blanks ' und []auf ein _ im Betreff reduzieren
   set subject [string map  {\  _  \[ _ \] _ ' _ \" _} $subject]
   #
   if {$test} {
      set sndmlExe /usr/local/bin/sndml
   } else {
      set sndmlExe "/home/s/bin/enbw/xtools/tclkit /home/s/bin/enbw/xtools/sndml"
   }
   set tmp [::utils::file::writetmp $mailtext sndml]
   set cmd    "$sndmlExe "
   append cmd "-sender [info hostname] "
   if {$toList ne ""}  {append cmd "-to $toList "}
   if {$ccList ne ""}  {append cmd "-cc $ccList "}
   if {$bccList ne ""} {append cmd "-bcc $bccList "}
   if {$servers ne ""} {append cmd "-mailservers $servers "}
   if {$ports ne ""}   {append cmd "-mailports $ports "}
   if {$headerStr ne ""} {append cmd "-headerStr $headerStr "}
   if {$attStr ne ""} {append cmd "-attstr $attStr "}
   if {$subject ne ""} {append cmd "-subject $subject "}
   if {$from ne ""} {append cmd "-from $from "}
   if {$cs ne ""} {append cmd "-cs $cs "}
   if {$debug ne ""} {append cmd "-debug $debug "}
   if {$test} {append cmd "-test $test "}
   append cmd "-mailpfad $tmp "
   
   set kdo "ssh spsy@$admHost \"ksh -c 'export SPECPATH=/home/s ; . /home/spsy/.profile ; $cmd'\""
   #puts $kdo
   #_dbg 100 remSendmailKdo {set kdo}
   if {[catch {::spec::specExec $kdo} msg]} {
      return -code error $msg
   }
   return 0
}


###-----------------------------------------------------------------------------
#
# Proc: incrChar
#
# *::utils::incrChar c*
#
#   inkrementiert einen Character a -> b
#
# Parameter:
#     c: Zeichen
#
# Ergebnis:
# Zeichen
#
#
###-----------------------------------------------------------------------------
proc ::utils::incrChar {c} {
   
   if {![string is ascii $c] } {
      return -code error "c <$c> muss ein Zeichen sein"
   }
   if {[string length $c] >1 } {
      return -code error "c <$c> muss ein EIN Zeichen sein"
   }
   
   # char to int
   scan $c %c i
   #puts "int: <$i<"
   
   incr i
   # int to char
   set c1 [format %c [scan $i %s]]
   return $c1
}

#-----------------------------------------------------------------------
proc ::utils::printhex {str} {
   # gibt str normal und in der nächsten Zeil hex aus
   #-----------------------------------------------------------------------
   
   set lenByte [string bytelength $str]
   set len [string length $str]
   puts "\n<$str> len:$len lenByte :$lenByte"
   for {set i 0} {$i < $len} {incr i} {
      set c [string index $str $i ]
      # char to int
      scan $c %c zei
      #puts "int: <$i<"
      puts -nonewline "[format %0x $zei] "
   }
   puts "\n------"
   return
   #Resulttrace
}

###-----------------------------------------------------------------------------
#
# Proc: excelColInt
#
# *::utils::excelColInt col*
#
#   wandelt ExcelSpalte in Nummer, zB A -> 0
#
# Parameter:
#     col: Bezeichnung der Excelspalte, z.B. AB
#
# Ergebnis:
# Int
#
#
###-----------------------------------------------------------------------------
proc ::utils::excelColInt col {
   set abc {- A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
   set int 0
   foreach char [split $col ""] {
      set int [expr {$int*26 + [lsearch $abc $char]}]
   }
   incr int -1 ;# one-letter columns start from A
   #puts "$col -> $int"
   return $int
}
###-----------------------------------------------------------------------------
#
# Proc: zeilenumbruch
#
# *::utils::zeilenumbruch str lng*
#
#   bricht eine String in Zeilen mit der Länge <lng> um
#
# Parameter:
#     str: String
#     lng: Zeilenlänge
#
# Ergebnis:
# String
#
#
###-----------------------------------------------------------------------------
proc ::utils::zeilenumbruch {str lng} {
   
   set text ""
   
   if {[string length $str] <= $lng} {
      return $str
   }
   
   set worte [splitstring $str]
   
   set zeile ""
   foreach wort $worte {
      append zeile "$wort "
      if {[string length $zeile] > $lng} {
         append text "$zeile\n"
         set zeile ""
      }
   }
   # letzte angefangene Zeile
   append text $zeile
   return $text
}