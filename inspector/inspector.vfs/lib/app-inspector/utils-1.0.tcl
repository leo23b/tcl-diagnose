## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "utils.tcl"
 #  Description:
 #  enthält allgemeine Utilities:
 #
 # ###################################################################

#----------------------------------------------------------------
#  DESCRIPTION
#      This file contains a procedure written in Tcl that supports static
#      variables.
#
#+ static - static variables support
#
#    This procedure supports static variables for a procedure whole through
#    Tcl code.  This procedure is based on code from the authors of the
#    tclX extension.
#
# REQUIREMENTS
#    None.
#
# RETURNS
#    Nothing.
#
# EXAMPLE
#    static {foo 10} bar
#
# CAVEATES
#    None.
#
proc static {args} {
   global staticvars
   set procName [lindex [info level -1] 0]
   foreach varPair $args {
      set varName [lindex $varPair 0]
      if {[llength $varPair] != 1} {
         set varValue [lrange $varPair 1 end]
      } else {
         set varValue {}
      }
      if {! [info exists staticvars($procName:$varName)]} {
         set staticvars($procName:$varName) $varValue
      }
      uplevel 1 "upvar #0 staticvars($procName:$varName) $varName"
   }
}
#-----------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc _dbg {num titel {script {}}    } {
#    # erzeugt eine Debug-Ausgabe
#    #-----------------------------------------------------------------------
#    global gd
#    ::utils::dbg::debug $num $gd(programm) $titel $script
# }
# 
###-----------------------------------------------------------------------------
#-----------------------------------------------------------------------
###-----------------------------------------------------------------------------
# proc #_proctrace {} {
#    #-----------------------------------------------------------------------
#    #set infoLev [info level -1]
#    #_dbg 1 Proctrace {set infoLev}
# }
# 
# #-----------------------------------------------------------------------
# proc _resulttrace {msg} {
#    #-----------------------------------------------------------------------
#    #set infolevel [info level -2]
#    #global gd
#    #::utils::dbg::debugstring 4 $gd(programm) Resulttrace "$infolevel ->\n\t -> $msg"
# }
# 
###-----------------------------------------------------------------------------
#-----------------------------------------------------------
# incrChar : inkrem Character
#            macht aus a b
# c   : Zeichen
# Ergebnis : Inkr
#-----------------------------------------------------------
proc incrChar {c} {
   
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

#----------------------------------------------------------------
# InfoExists
# liefert Wert wenn Variable existiert, sonst einen Defaultwert
# Parameter:
# v      : Variable
# def    : Defaultwert
#---------------------------------------------------------------
proc infoexists {v {def {}} } {
   
   upvar 1 $v var
   if {[info exists var]} {
      return $var
   } else {
      return $def
   }
}
#-----------------------------------------------------------------------
proc _leer {var script} {
   #  prüft ob var leer ist und führt dann script aus
   #-----------------------------------------------------------------------
   set var     [string trim $var]
   set script  [string trim $script]
   if {$var == {}} {
      if {[string match {return {}} $script]} {
         return -code return {}
      }
      if {[string match {return} $script]} {
         return -code return
      }
      if {[string match {continue} $script]} {
         return -code continue
      }
      if {[string match {break} $script]} {
         return -code break
      }
      
      # return mit -code oder mit Ergebnis ?
      # zB return {}
      # hier funktioniert *leer nicht
      if {[string match {return*} $script]} {
         if {$script != {return}} {
            return -code error "das kann _leer nicht"
         }
      }
      
      #
      # am Ende vom Script ein RETURN ?
      set nzeilen {}
      set n 0
      foreach z [split $script "\n"] {
         if {[string trim $z] == {}} {continue}
         lappend nzeilen $z
         #puts "$n $z"
         incr n
      }
      if {[string match {*return*} [lindex $nzeilen end]]} {
         set nscript [join [lrange $nzeilen 0 end-1] "\n"]
         # puts "ns:<$nscript<"
         uplevel 1 eval [list $nscript]
         return -code return
      } else {
         uplevel 1 eval [list $script]
      }
   }
}


#-----------------------------------------------------------------------
proc dragInitInsp {args} {
   # zieht Label insp in den Inspector (Label target)
   # Bestimmt comm::comm self zur Übergabe
   # dndtyp: DND_COMMID
   # Ziele : Label taerget im inspector
   #--------------------------------------------------------------------
   
   if {[catch {::comm::comm "self"} msg]} {
      # ggf comm laden und self bestimmen
      package require comm
      set self [::comm::comm "self"]
      comm::comm config -local 0 -port $self
   } else {
      set self [::comm::comm "self"]
   }
   
   set data [list typ_commid $self]
   return [list copy DND_COMMID $data]
}
#------------------------------------------------------------------------------
#  OnlineDoku  :
#  htmlfile : Name der html-Datei  (Default: <programm>.html)
#------------------------------------------------------------------------------
proc OnlineDoku {{htmlfile {}}} {
   global gd wv myStatus result
   variable topNum
   
   if {$htmlfile eq {}} {
      set htmlfile $gd(programm).html
   }
   
   set path [file join $::scriptDirMain hilfe $htmlfile]
   set tmphtml [::utils::file::tmpexe $path]
   exec -ignorestderr firefox $tmphtml 2> /dev/null &
   
   return
}
#-----------------------------------------------------------------------
proc check {cmd ctx ergV {clock {1}} {err {1}} } {
   # führt cmd aus und belegt Ergebnisvariable ergV. Im Fehlerfall
   # wird 'throw' gerufen
   # Wenn cmd kein Ergebnis liefert, muss ergV "" sein !!!
   #
   # ctx : beschreibt den Kontext zum Kommando
   # ergV: Variable für das Ergebnis
   # clock : clock-Symbol ausschalten
   # err   : error aufrufen
   #--------------------------------------------------------------------
   global wv
   upvar $ergV ergebnis
   if {[catch {uplevel $cmd} ergebnis]} {
      set msg "F-$ctx:\n  $ergebnis"
      if {$clock} {::utils::gui::setClock off $wv(w,top)}
      if {$err} {error $msg}
   }
   return
}

#-----------------------------------------------------------------------
# ShowChronik
# zeigt Inhalt von chronik.tcl
#
#-----------------------------------------------------------------------
proc ShowChronik {} {
   global  wv gd
   
   set tw [::widgets::tw $wv(w,top).chronik \
      -widget   text                 \
      -titel    Änderungschronik     \
      -text     $::aenderungschronik \
      -geometry 700x600              \
      -- \
      -bg white ]
   
   # xtoolslibs
   package require xtoolslibs_chronik
   
   set tw [::widgets::tw $wv(w,top).chroniklibs \
      -widget   text                 \
      -titel    {Chronik xtoolslibs} \
      -text     $::xtoolslibs_chronik::chronik\
      -geometry 700x600              \
      -- \
      -bg white ]
   
}
#---------------------------------------------------------------
#  ShowVersion
#  Version im  ausgeben
#---------------------------------------------------------------
proc ShowVersion {} {
   global gd wv
   
   set vers $gd(version)
   
   # xtoolslibs
   package require xtoolslibs_chronik
   append vers "\nxtoolslibs $::xtoolslibs_chronik::version"
   ::utils::gui::msgow1 "$vers" 5000 Version
}


