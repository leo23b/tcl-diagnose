## -*-Tcl-*-
# ###################################################################
#
#  FILE: "utils_thread.tcl"
#                                    created: 2004-03-12 05:21:04
#                                last update: 2005-05-11 07:39:09
#  History
#
package provide utils::thread 1.2
#  modified   by   rev reason
#  ---------- ---  --- -----------
#  26.04.22   mlrd 1.2 create ersetzt
#  29.06.19   mlrd 1.1 Doku
#  11.09.13   mlrd 1.0   neu
# ###################################################################


namespace eval utils::thread {
   #---------- Variable ------------------------------------------------
   variable test           0
   variable varnr          0 ;# Index für Callback Varname
   
   #---------- interne Funktionen --------------------------------------
   
   #--------------------------------------------------------------------
   #        Hauptprozeduren
   #--------------------------------------------------------------------
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: ::utils::thread::xcreate
   #
   # *::utils::thread::xcreate args*
   # 
   # Richtet einen Thread ein und belegt den auto_path. Es wird unterschieden
   # Start mit Starkit oder mit einer tcl-Datei. Man kann beim
   # Anlegen des Thread ein Script mitgeben. Nach Beenden des
   # Scripts wird der Thread beendet. Ohne Script geht der
   # Thread in die Warteschleife und wartet auf utils::thread::sendasy.
   # Dieser Thread muss mit ::thread::resume beendet werden.
   # 
   #
   # Parameter:
   #     args: Optionenpaare
   #
   # Optionen:
   #    -starkit string: Name starkit (default argv0)
   #    -scriptdir string: Verzeichnis des Tcl-Scripts,
   #                   zum Anlegen LibDir (Angabe ist fakutativ zu starkit)
   #    -script  Script: zum Ausführen im Thread . Thread wird danach beendet.
   # 
   # Ergebnis:
   # Thread-ID
   #
   # siehe auch:
   # <cacheTable.html>
   #
   ###-----------------------------------------------------------------------------
   proc xcreate {args} {
      package require Thread
      
      ##nagelfar variable opts varName
      ::Opt::opts "opts" $args {
         {-starkit   {}  "Name starkit default:argv0"}
         {-scriptdir {}  ""}
         {-script    {}  ""}
      }
      set starkit   $opts(-starkit)
      set scriptdir $opts(-scriptdir)
      set script    $opts(-script)
      set mainth [thread::id] ;# Mainthread für Ergebnis zurück geben
      
      if {$scriptdir eq ""} {
         set scriptdir [file normalize [file dirname [info script]]]
      }
      
      # Starkit oder nicht
      #
      set isKit [info exists ::starkit::mode]
      
      if {$isKit} {
         if {$starkit eq ""} {
            set starkit $::argv0
         }
      }
      
      set initScript {
         set libDir [file normalize [file join %scriptdir% ..]]
         if {%isKit%} {
            # Starkit mounten
            #
            package require starkit
            package require vfs::mk4    ;# für Mount
            vfs::mk4::Mount %starkit% %starkit% -readonly
            set ::starkit::topdir [file normalize %starkit%]
            set libDir [file join $::starkit::topdir lib]
         }
         ::tcl::tm::path add $libDir     ;# für Module
         lappend ::auto_path %scriptdir% ;# für tclIndex
         lappend ::auto_path $libDir
         if {{%script%} ne ""} {
            eval %script%
         } else {
            ::thread::wait
         }
      }
  
      set initScript [string map \
         "%isKit% $isKit %mainth% $mainth \
         %starkit% \"$starkit\" \
         %script% [list $script] \
         %scriptdir% \"$scriptdir\" " $initScript]
      
      # Thread einrichten
      package require Thread
      if {[catch {::thread::create $initScript} thId]} {
         return -code error $thId
      }
      return $thId
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: ::utils::thread::sendasy
   #
   # *::utils::thread::sendasy thid args*
   # 
   # Sendet an einen Thread ein Script, das asynchron ausgeführt
   # wird. Ein optionale Callbackprozedur kann aufgerufen werden.
   # 
   # Parameter:
   #     thid: Threadidentifier
   #     args: Optionenpaare
   #
   # Optionen:
   #    -script Script: zum Ausführen im Thread .
   #    -callback proc: optionale Callbackprozedur mit Parametern
   # 
   # Ergebnis:
   # -
   #
   # siehe auch:
   # <cacheTable.html>
   #
   ###-----------------------------------------------------------------------------
   proc sendasy {thid args} {
      variable varnr
      incr varnr
      
      ##nagelfar variable opts varName
      ::Opt::opts "opts" $args {
         {-callback     {}  ""}
         {-script       {}  ""}
      }
      set callback  $opts(-callback)
      set script    $opts(-script)
      
      ::thread::send -async $thid  $script var$varnr
      
      # callback
      if {$callback ne ""} {
         ##nagelfar ignore
         vwait var$varnr
         eval $callback
      }
      
   }
   
   #-----------------------------------------------------------------------
   proc musterCB {args} {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      
     # puts "Thread fertig: $args"
      
   }
   
   proc create {args} {
      
      global gd argv0
      
      set ::mainth [::thread::id]
      set libDir   [file normalize [file join $::scriptDirMain ..]]
      
      set mountKdo {}
      if {[info exists ::starkit::topdir]} {
         # mount je nach tclkit verzweigen
         if {[info commands vfs::mkcl::Mount] ne "" } {
            set mountKdo  {vfs::mkcl::Mount $argv0 $argv0 -readonly}
         } else {
            set mountKdo {vfs::mk4::Mount $argv0 $argv0 -readonly}
         }
      }
      
      set initCmd1 "
      set ::mainth $::mainth
      set ::argv0 $::argv0
      set ::auto_path [list $::auto_path]
      ::tcl::tm::path add $libDir
      
      # nur bei tclkit
      if {[info exists ::starkit::topdir]} {
         package require starkit
         package require vfs
         
         eval $mountKdo
         set ::starkit::topdir $argv0
      }
      
      package require spec
      package require utils
      package require sqlite3
      package require Iddug
      package require tpclient
      
      # dyn Variable setzen
      #
      set  gd(programm)    $gd(programm) 
      set  gd(test)        $gd(test) 
      set  gd(binDirProd)  $gd(binDirProd) 
      set  gd(xtsPort)     $gd(xtsPort) 
      set  gd(rundir)      $gd(rundir) 
      set  gd(admhost)     $gd(admhost) 
      set  gd(oraclehost)  $gd(oraclehost) 
    # set gd(remiddugdir) $gd(remiddugdir) 
   
   
      #--------------- Utils init
      #
      ::spec::init  \
         -test      $gd(test)       \
         -xtoolsbin $gd(binDirProd) \
         -xtsport   $gd(xtsPort)    \
         -programm  $gd(programm)
      
      ::utils::init \
         -test   $gd(test)    \
         -rundir $gd(rundir)
      
      ::tpclient::init  \
         -test      $gd(test)  \
         -xtoolsbin $gd(binDirProd)
      
      # zuerst oraclehost = admhost
      set gd(oraclehost) $gd(admhost)
      ::utils::sql::init              \
         -test       $gd(test)        \
         -xtsport    $gd(xtsPort)     \
         -programm   $gd(programm)    \
         -admhost    $gd(admhost)     \
         -oraclehost $gd(oraclehost)  \
         -xtoolsbin  $gd(binDirProd)
      
      #::Iddug::init  \
      #   -test          $gd(test)         \
      #   -admhost       $gd(admhost)      \
      #   -remiddugdir   $gd(remiddugdir)
      
      ::thread::wait
      "
      
      set tid [::thread::create $initCmd1]
      return $tid
      
      
   }

}