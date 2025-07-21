   # -*-Tcl-*-
   # ###################################################################
   #
   #  FILE: "utils_file-x.y.tcl"
   #                                    created: 22.01.2012 14:00:00
   #
   #  Description:
   #  enthält file -Package
   #
   #  History
   #
   package provide utils::file 2.5.9
   #  modified   by   rev    reason
   #  ---------- ---- ------ -------------------------
   #  28.06.2019 mlrd 02.5.9 Doku
   #  12.06.2019 mlrd 02.5.8 specExec
   #  07.06.2019 mlrd 02.5.7 cleanremdir tclkit
   #  22.02.2018 mlrd 02.5.6 cleanremdir tclkit
   #  23.11.2018 mlrd 02.5.5 cleanremdir
   #  21.07.2018 mlrd 02.5.4 Doku fsdialog
   #                file tmp : atexit : file delete -FORCE
   #  24.12.2017 mlrd 02.5.3 zlib
   #  21.06.2017 mlrd 02.5.2 html-Adressen angepasst
   #  02.12.2015 mlrd 02.5.1 append vereinfacht
   #  21.10.2015 mlrd 02.5.0 Doku mit ND, sftp,ssh_expect
   #  07.03.2015 mlrd 02.4.4 zipfile ctfile
   #  14.09.2014 mlrd 02.4.3 atexit -> ::pool::atexit
   #  04.07.2014 mlrd 02.4.1 dml/bq .... kann nicht in /tmp schreiben
   #  26.06.2014 mlrd 02.4   tmpdir -> /tmp
   #  10.10.2013 mlrd 02.4   readfile mit -nonewline
   #  28.07.2013 mlrd 02.3   von utils_file.tcl übernommen
   # ###################################################################
   
   #-----------------------------------------------------------------------
   
   
   package require Opts
   
   namespace eval utils::file {
      #---------- Variable ------------------------------------------------
      variable test           0
      variable packagename    {utils::file}
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
     #       proc _proctrace {} {
     #          #--------------------------------------------------------------------
     #          set infoLev [info level -1]
     #          #_dbg 1 Proctrace {set infoLev}
     #       }
     #       
     #       #--------------------------------------------------------------------
     #       proc _resulttrace {msg} {
     #          #--------------------------------------------------------------------
     #          variable packagename
     #          set infolevel [info level -1]
     #          ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
     #       }
     #       
     #       
     ###-----------------------------------------------------------------------------
   }
   #--------------------------------------------------------------------
   #--------------    Hauptfunktionen         --------------------------
   #--------------------------------------------------------------------
   
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: readfile
   #
   # *::utils::file::readfile pfad args*
   # 
   # liest eine Datei und liefert den Inhalt als String zurück
   #
   # Parameter:
   #     pfad: Pfadname der Datei.
   #     args: Optionenpaare 
   #
   # Optionen:
   #
   # -noerror bool: Im Fehlerfall wird ein leerer String als
   #     Ergebnis geliefert, ansonsten wird abgebrochen. (Default: 0)
   #
   # -unzip bool: Die Datei wird vor dem Lesen dekomprimiert.
   #     Die Datei kann mit zip, bzip2 oder gzip komprimiert sein.
   #    (Default:0)
   # -optopen -liste :  In einer Liste können Optionen
   #       für *fconfigure* übergeben werden.
   #
   # Ergebnis:
   #
   # Inhalt der Datei als String
   #
   # Beispiel:
   # (start code)
   # set inhalt [::utils::file::readfile abc.txt.gz -unzip True \
   #    -optopen {-blocking 1 -buffering line}]
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::readfile {pfad args} {
      #_proctrace hier nicht möglich
      package require Opts
      
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-noerror   {0}   "kein Abbruch bei Fehler"    -type boolean}
         {-unzip     {0}   "0|1 Datei zuerst entzippen" -type bool}
         {-optopen   {}    "Optionen für fconfigure"  }
      }
      
      set noError  $params(-noerror)
      set unzip    $params(-unzip)
      set optOpen  $params(-optopen)
      
      if {$pfad=={}} {
         if {$noError} {return {}}
         return -code error "wrong # args: should be \"readfile pfad\""
      }
      
      if {![file readable $pfad]} {
         if {$noError} {return {}}
         return -code error "Datei <$pfad> existiert nicht"
      }
      
      # vorher entzippen
      #
      if {$unzip} {
         # Zipped Pfad_zip
         package require fileutil
         set type [::fileutil::fileType $pfad]
         set kdo  {}
         switch -- $type {
            {binary compressed zip}  {set kdo "unzip   -p $pfad"}
            {binary compressed bzip} {set kdo "bunzip2 -c $pfad"}
            {binary compressed gzip} {set kdo "gunzip  -c $pfad"}
         }
         if {$kdo != {}} {
            set CH [open "| $kdo"]
            set inh [read -nonewline $CH]
            close $CH
            return $inh
         }
      }
      # File oeffnen
      if { [catch {open  $pfad r} fid ] } {
         if {$noError} {return {}}
         return -code error  $fid
      }
      
      if {$optOpen != {}} {
         if {[catch {fconfigure $fid {*}$optOpen} msg]} {
            if {$noError} {return {}}
            close $fid
            return -code error $msg
         }
      }
      # File lesen
      if { [catch {read -nonewline $fid } inh ] } {
         if {$noError} {return {}}
         close $fid
         return -code error $inh
      }
      close $fid
      return $inh
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: appendfile
   #
   # *::utils::file::appendfile pfad str*
   # 
   # fügt an eine Datei einen Text an.
   #
   # Parameter:
   #     pfad: Pfadname der Datei.
   #     str: Text zum Anfügen.
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::appendfile {pfad str} {
      # _proctrace hier nicht möglich
      
      if {$pfad=={}} {return -code error {Pfad ist leer} }
      
      # File oeffnen
      if { [catch {open $pfad a} fid ] } {
         return -code error  $fid
      }
      
      # String schreiben
      puts -nonewline $fid $str 
      close $fid
      
      #set inh [readfile $pfad -noerror 1]
      #append inh "\n$str"
      #writefile $pfad $inh
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: readliste
   #
   # *::utils::file::readliste pfad args*
   # 
   # liest eine Datei und liefert den Inhalt als Liste zurück
   #
   # Parameter:
   #     pfad: Pfadname der Datei.
   #     args: Optionenpaare
   #
   # Optionen:
   #
   # -noerror bool:  Im Fehlerfall wird ein leerer String als
   #     Ergebnis geliefert, ansonsten wird abgebrochen. (Default: 0)
   #
   # -unzip bool: Die Datei wird vor dem Lesen dekomprimiert.
   #     Die Datei kann mit zip, bzip2 oder gzip komprimiert sein.
   #    (Default:0)
   # -optopen -liste: In einer Liste können Optionen
   #     für *fconfigure* übergeben werden.
   #
   # Ergebnis:
   #
   # Inhalt der Datei als Liste aller Zeilen
   #
   # Beispiel:
   # (start code)
   # set zeilen [::utils::file::readliste abc.txt.gz -unzip True \
   #    -optopen {-blocking 1 -buffering line}]
   # (end)
   #
   ###-----------------------------------------------------------------------------
   
   proc ::utils::file::readliste {pfad args} {
      #_proctrace
      
      ##nagelfar variable params
      ::Opt::opts {params} $args {
         {-noerror   {0}   "kein Abbruch bei Fehler"    -type boolean}
         {-unzip     {0}   "0|1 Datei zuerst entzippen" -type bool}
         {-optopen   {}    "Optionen für fconfigure"  }
      }
      
      set noError  $params(-noerror)
      set unzip    $params(-unzip)
      set optOpen  $params(-optopen)
      set inh [readfile $pfad -noerror $noError -unzip $unzip -optopen $optOpen]
      return [split $inh "\n"]
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: remcopy 
   #
   # *::utils::file::remcopy quelle remhost ziel*
   # 
   #
   # _remcopy_ kopiert quelle nach ziel auf den
   # entfernten Rechner remhost. Das Zielverzeichnis wird zuvor
   # angelegt. Lokal wird mit cp kopiert.
   # 
   # Parameter:
   #     quelle: Absoluter oder lokaler Pfadname der Quell-Datei. 
   #     remhost: Name des Zielknotens. 
   #     ziel: Absoluter Pfadname der Ziel-Datei. 
   # 
   # Ergebnis: 
   # - Erfolg 1
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::remcopy {quelle remhost ziel } {
      #_proctrace
      
      set ssh [auto_exec ssh]
      set scp [auto_exec scp]
      
      if {![file readable $quelle]} {
         return -code error "F-remcopy:$quelle nicht lesbar"
      }
      
      set mode {remote}
      if {[info hostname] == $remhost} {set mode {local}}
      
      set zdir [file dirname $ziel]
      
      if {$mode == {remote}} {
         if {[catch {exec $ssh $remhost mkdir -p $zdir} msg] } {
            return -code error "F-remcopy:mkdir $zdir\n$msg"
         }
         
         if {[catch {exec  $scp -p $quelle $remhost:$ziel} msg] } {
            return -code error "F-remcopy:rcp $quelle $remhost:$ziel\n$msg"
         }
      } else {
         if {[catch {exec  mkdir -p $zdir} msg] } {
            return -code error "F-remcopy:mkdir $zdir\n$msg"
         }
         
         if {[catch {exec  cp -p $quelle $ziel} msg] } {
            return -code error "F-remcopy:cp $quelle $ziel\n$msg"
         }
      }
      return 1
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: tmpexe 
   #
   # *::utils::file::tmpexe fos*
   # 
   #
   # _tmpexe_ kopiert eine Datei oder einen Text in eine ausführbare
   # temporäre Datei. Der Name der temp. Datei wird als
   # Ergebnis zurück geliefert, so dass die Datei mit exec
   # ausgeführt werden kann.
   #
   # Bei tclkit ist der Umweg über
   # eine temp. Datei notwendig, da VFS-Dateien nicht
   # mit exec aufgerufen werden können.
   # Die temp. Datei wird am Programmende automatisch gelöscht.
   # 
   # Parameter:
   #     fos: file oder string zum Ausführen. 
   # 
   # Ergebnis: 
   # Name der temporären Datei
   # 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::tmpexe { fos } {
      #_proctrace
      
      set istFile [file isfile $fos]
      if {$istFile && ![file readable $fos]} {
         return -code error "F-tmpexe: $fos nicht vorhanden/lesbar"
      }
      set target [tmpname]
      if {$istFile} {
         if {[catch {
               file copy -force $fos $target;
               exec chmod +x $target
            } erg ]} {
            return -code error "F-tmpexe :Copy von $fos\n$erg"
         }
      } else {
         if { [catch {
               writefile $target $fos
               exec chmod +x $target
            } erg ]} {
            return -code error "F-tmpexe: writefile fos\n$erg"
         }
      }
      return $target
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: tmpname 
   #
   # *::utils::file::tmpname name*
   # 
   #  _tmpname_ bestimmt einen temporären Dateinamen. Das Verzeichnis
   # wird aus
   # 
   # - TMPDIR
   # - TEMPDIR
   # -   HOME
   # -   /tmp
   # 
   # in absteigender Reihenfolge ausgewählt. Die Datei wird zum
   # Löschen zum Programmende vorgemerkt.
   # 
   # Parameter:
   #     name: Stammname der Datei. Der Dateiname <name>nnnnn.tmp  (Default tmp)
   # 
   # Ergebnis:
   # 
   # Name der temporären Datei
   ###-----------------------------------------------------------------------------
   proc ::utils::file::tmpname {{name {tmp}}} {
      #_proctrace
      global env
      if {[info exists env(TMPDIR)]} {
         set tmpDir $env(TMPDIR)
      } elseif {[info exists env(TEMPDIR)]} {
         set tmpDir $env(TEMPDIR)
      } elseif {[info exists env(HOME)]} {
         set tmpDir $env(HOME)
      } elseif {[file writable /tmp]} {
         set tmpDir "/tmp"
      } elseif {[info exists env(USERPROFILE)]} {
         set tmpDir $env(USERPROFILE)
      } else {
         return -error "kein tmpdir gefunden"
      }
      
      set tmpDir [file normalize $tmpDir]
      set erg [file join $tmpDir $name[pid][clock clicks].tmp]
      
      # Datei gibt es schon ?
      if {[file exists $erg]} {
         return -code error "F-tmpname: <$erg> schon da"
      }
      ::pool::atexit::add [list file delete -force $erg]
      return $erg
   }

   ###-----------------------------------------------------------------------------
   # 
   # Proc: writefile 
   #
   # *::utils::file::writefile pfad str*
   # 
   #   erstellt eine Datei mit den übergebenen Pfad und Text.
   # 
   # Parameter:
   #     pfad: Pfadname der zu erstellenden Datei. Der Pfadname kann absolut oder relativ sein. 
   #     str: Der Text wird in die Datei geschrieben. 
   # 
   # Ergebnis: 
   # - Erfolg 1
   # 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::writefile {pfad str} {
      # -------------------------------------------------------------------
      #_proctrace hier nicht möglich
      package require Opts
      
      if {$pfad=={}} {
         return -code error "wrong # args: should be \"WriteFile pfad string\""
      }
      
      # File oeffnen
      if { [catch {open  $pfad w} fid ] } {
         return -code error  $fid
      }
      
      # String schreiben
      puts -nonewline $fid $str
      close $fid
      return 0
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: writeliste
   #
   # *::utils::file::writeliste pfad liste*
   # 
   #
   # _writeliste_ erstellt eine Datei _pfad_.
   # Die Elemente der Liste werden mit Newline zu einem String
   # zusammengefasst.
   # 
   # Parameter:
   #     pfad: Pfadname der zu erstellenden Datei. Der Pfadname kann absolut oder relativ sein. 
   #     liste: Aus liste wird ein Text erstellt, der in die Datei geschrieben wird. 
   # 
   # Ergebnis: 
   #  Erfolg: 1
   # 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::writeliste {pfad liste} {
      #_proctrace
      
      set str [join $liste "\n"]
      return [writefile $pfad $str]
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: writetmp
   #
   # *::utils::file::writetmp str name*
   # 
   #
   # _writetmp_ schreibt einen Text in eine temporäre Datei.
   # Der Dateiname wird mit TmpName gebildet.
   # Die Datei wird am Programmende gelöscht.
   # 
   # Parameter:
   #     str:  Der Text wird in die Datei geschrieben.
   #     name: Stammname der temp. Datei. (Default:tmp)
   # 
   # Ergebnis: 
   # Name der temporären Datei
   # 
   # siehe auch:
   # ::utils::file::tmpname
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::writetmp {str {name {tmp}} } {
      #_proctrace
      
      set tmp [tmpname $name]
      writefile $tmp $str
      return $tmp
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: cleandir
   #
   # *::utils::file::cleandir dir wc tage*
   # 
   #
   # _cleandir_ löscht im Verzeichnis _dir_
   # alle Dateien gemäss Wildcard _wc_ 
   #  deren Änderungsdatum länger als _tage_ Tage zurückliegt
   #
   # Parameter:
   #     dir:  Verzeichnis mit den Dateien.
   #     wc:   Wildcard zur Auswahl der Dateien, zur Verwendung im glob-Kommando.
   #     tage:  Anzahl der Tage nach der letzten Änderung der Datei.
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::cleandir {dir wc tage} {
      #_proctrace
     
      set files [glob -nocomplain -directory $dir $wc]
      foreach file $files {
         file stat $file stat
         set mtime $stat(mtime)
         # tage * 24 *60 *60 addieren
         set new [expr {$mtime + $tage * 86400}]
         if {$new < [clock seconds]} {
            file delete $file
         }
      }
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: cleanremdir
   #
   # *::utils::file::cleanremdir host dir wc tage xtoolsBin*
   # 
   #
   # _cleanremdir_ löscht im _host_ und Verzeichnis _dir_
   # alle Dateien gemäss Wildcard _wc_ 
   #  deren Änderungsdatum länger als _tage_ Tage zurückliegt
   #
   # Parameter:
   #     host:  remote Host
   #     dir:   Verzeichnis mit den Dateien.
   #     wc:    Wildcard zur Auswahl der Dateien, zur Verwendung im glob-Kommando.
   #     tage:  Anzahl der Tage nach der letzten Änderung der Datei.
   #     xtoolsBin:  Verzeichnis der xtools-Binaries
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::cleanremdir {host dir wc tage xtoolsBin} {
      #_proctrace
      global gd
      
      # für alle Dateien in dir die mtime holen
      set remdir $dir
      set pat $wc
      set filter *
      set pars  "$remdir~$pat~$filter"
      
     # if {[::spec::release] eq "460"} {
     #    set tclkit [file join $gd(xtoolsBin) tclkit_sparc]
     # } else {
     #    set tclkit [file join $gd(xtoolsBin) tclkit_x86]
     # }
      
      # die beiden ' ' verhindern dass bash * expandiert
      if {[catch {::spec::specExec ssh $host \
               $xtoolsBin/tclkit  $xtoolsBin/remdirservice.tcl \
               '$pars'} erg]} {
         return -code error  $erg
      }
      foreach li $erg {
         lassign $li name typ size mtime
         set filename [file join $dir $name]
         # tage * 24 *60 *60 addieren
         set new [expr {$mtime + $tage * 86400}]
         if {$new < [clock seconds]} {
            # Datei löschen
            try {
               set result [exec ssh $host /bin/rm $filename]
            } on error result {
               puts "F-cleanremdir:$result"
            }
            
         }
      }
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: zip
   #
   # *::utils::file::zip pfad zipargs*
   # 
   # Die Datei _pfad_ wird gezippt.
   #
   # Die _zipargs_ werden an zip durchgereicht.
   #  Der Pfadname der gezippten Datei wird mit .zip ergänzt
   #  Der Pfadname der gezippten Datei wird zurück geliefert.
   #  
   # 
   # Parameter:
   #     pf: Pfad der ungezippten Datei
   #     zipargs: Parameter für das zip-Kommando
   # 
   # Beispiel:
   #  *zipargs*
   # 
   #  - V : save VMS !! nicht verwenden
   #  - m : Eingangsdatei löschen
   #  - j : Directory nicht speichern
   #
   # Ergebnis:
   # Pfad der gezippten Datei
   # 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::zip {pf zipargs} {
      set zipFile "$pf.zip"
      set inPf $pf
      set zipKdo "zip $zipargs $zipFile $inPf"
      catch {file delete -force $zipFile}
      if {[catch {eval exec $zipKdo } msg]} {
         catch {file delete $zipFile }
         return -code error "Fehler beim Zippen\n$msg"
      }
      if {![string match {*deflated*} $msg]} {
         catch {file delete $zipFile }
         return -error  "Datenfehler" "Fehler beim Zippen\n$msg"
      }
      return $zipFile
   }
   
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: crlf 
   #
   # *::utils::file::crlf pfStr*
   # 
   # An alle Zeilenende wird crlf angehängt 
   # 
   # Parameter:
   #     pfStr: Pfad oder String.
   #
   # Wenn pfStr eine Datei ist, wird
   #      die geänderte Datei gespeichert.
   # 
   # Ergebnis: 
   # String 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::crlf {pfStr} {
      
      # Text oder Datei
      if {[file readable $pfStr]} {
         set txt [::utils::file::readfile $pfStr]
         set isFile 1
      } else {
         set txt $pfStr
         set isFile 0
      }
      
      # crlf anhängen
      set txt1 ""
      foreach z [split $txt "\n"] {
         append z "\r\n"
         append txt1 $z
      }
      set txt $txt1
      if {$isFile} {::utils::file::writefile $pfStr $txt}
      return $txt
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: setprotVMS 
   #
   # *::utils::file::setprotvms pfad prot*
   # 
   # _set prot_ auf die Datei(en) anwenden
   # 
   # Parameter:
   #     pfad: Dateipfad, ggf mit WC \[.dir...\]*.*\;* 
   #     prot: VMS-Prtection, zB W:RWE 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::setprotVMS {pfad prot} {
      #   führt das VMS-Kdo set prot aus
      # pfad  N
      # prot  
      # -------------------------------------------------------------------
      #_proctrace
      global tcl_platform
      
      if {$tcl_platform(os) != {OpenVMS}} {return}
      
      if {[catch {exec set prot=$prot $pfad} msg]} {
         return -code error $msg
      }
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: deleteallvers 
   #
   # *::utils::file::deleteallvers pfad*
   # 
   # löscht alle Versionen eine VMS-Datei 
   # 
   # Parameter:
   #     pfad: Dateipfad
   # 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::deleteallvers {pfad} {
      # -------------------------------------------------------------------
      global tcl_platform
      #_proctrace
      
      if {![file exists $pfad]} {
         return
      }
      if {$tcl_platform(os) == {OpenVMS}} {
         set pfadN [file nativename $pfad]
         if {[catch {exec delete $pfadN\;*} msg]} {
            return -code error $msg
         }
      } else {
         file delete $pfad
      }
   }

   ###-----------------------------------------------------------------------------
   # 
   # Proc: rglob 
   #
   # *::utils::file::rglob dirlist globlist*
   # 
   #
   # Alle Dateien in den Verzeichnissen _dirliste_ werden nach
   # allen Mustern _globliste_ rekursiv durchsucht.
   # 
   # Parameter:
   #     dirlist: Liste aller Verzeichnisse. 
   #     globlist: Liste aller Muster. 
   # 
   # Ergebnis: 
   # 
   # Dateiliste
   # 
   # Beispiel:
   # (start code)
   # set files [rglob {/home /usr} {*.txt *.html}]
   # (end)
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::rglob {dirlist globlist} {
      #_proctrace
      set result {}
      set recurse {}
      foreach dir $dirlist {
         if {![file isdirectory $dir]} {
            return -code error "'$dir' is not a directory"
         }
         foreach pattern $globlist {
            lappend result {*}[glob -nocomplain -directory $dir -- $pattern]
         }
         foreach file [glob -nocomplain -directory $dir -- *] {
            set file [file join $dir $file]
            if {[file isdirectory $file]} {
               set fileTail [file tail $file]
               if {!($fileTail eq "." || $fileTail eq "..")} {
                  lappend recurse $file
               }
            }
         }
      }
      if {[llength $recurse] > 0} {
         lappend result {*}[rglob $recurse $globlist]
      }
      return $result
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: getopenfile
   #
   # *::utils::file::getopenfile args*
   # 
   # liefert einen Dateipfad zum Öffnen einer neuen oder vorhandenen
   # Datei. Arbeitet netztransparent über den vorgegebenen host.
   #
   # Parameter:
   #     args: Optionen
   #
   # Optionen:
   #
   # -defaultextension ext: zur Vorbelegung im Dialog
   # -filetypes liste: zur Vorbelegung im Dialog (Default:none)
   # -initialdir dir: zur Vorbelegung im Dialog
   # -intialfile file: zur Vorbelegung im Dialog
   # -parent p: Parentwidget vom Dialog
   # -title string: Dialogtitel
   # -typevariable string: Auswahl in der Filterliste
   # -multiple bool: Mehrfachauswahl
   # -sepfolders bool: im Dialog werden die Verzeichnisse links angezeigt (Default:1)
   # -sort str: Sortiervorgabe für die angezeigten Dateien (Name Date Size) Default:Name
   # -foldersfirst bool: Verzeichnisse am Anfang listen (Default:1)
   # -reverse bool: umgekehrte Reihenfolge (Default:0)
   # -details bool: Details der Dateien anzeigen (Default:0)
   # -hidden bool: - versteckte Dateien anzeigen (Default:1)
   # -host h: Daten vom Host (Default:{})
   # -hosts liste: Liste von Hosts zur Auswahl in der Combobox (Default:{})
   # -mithost bool:  die gewählte Datei host:datei (Default: 0)
   # 
   # Ergebnis:
   # Dateipfad oder {}
   #
   # siehe auch:
   # - <TkCmd/getOpenFile.htm>
   #
   # Beispiel:
   # (start code)
   # set filePatternListe [list \
   #     "Tcl-Files {*.tcl *.tk *.itcl *.itk *.tm}" "All {*}"]
   # ::utils::file::getopenfile \
   #     -filetypes $filePatternListe \
   #     -initialdir $ad(workingDir) \
   #     -hidden 0 \
   #     -multiple 1 \
   #     -title "Datei öffnen"
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::getopenfile {args} {
      #--------------------------------------------------------------------
      package require fsdialog
      set os $::tcl_platform(os)
      switch -- $os {
         "Linux" - "SunOS" - "freebsd" {
            return [ttk::getOpenFile {*}$args]
         }
         "macosx" {
            return [tk_getOpenFile {*}$args]
         }
         "Win32" {
            return [tk_getOpenFile {*}$args]
         }
         default {
            return [tk_getOpenFile {*}$args]
         }
      }
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: getsavefile
   #
   # *::utils::file::getsavefile args*
   # 
   # liefert einen Dateipfad zum Öffnen einer neuen oder vorhandenen
   # Datei zum *Schreiben*. Arbeitet nur lokal.
   #
   # Parameter:
   #     args - Optionen
   #
   # Optionen:
   #
   # -defaultextension ext: zur Vorbelegung im Dialog
   # -filetypes liste: zur Vorbelegung im Dialog (Default:none)
   # -initialdir dir: zur Vorbelegung im Dialog
   # -intialfile file: zur Vorbelegung im Dialog
   # -parent p: Parentwidget vom Dialog
   # -title string: Dialogtitel
   # -sepfolders bool: im Dialog werden die Verzeichnisse links angezeigt (Default:1)
   # -sort str: Sortiervorgabe für die angezeigten Dateien (Name Date Size) Default:Name
   # -foldersfirst bool: Verzeichnisse am Anfang listen (Default:1)
   # -reverse bool: umgekehrte Reihenfolge (Default:0)
   # -details bool: Details der Dateien anzeigen (Default:0)
   # -hidden bool: - versteckte Dateien anzeigen (Default:1)
   #
   # Ergebnis:
   # Dateipfad oder {}
   #
   # siehe auch:
   # - <TkCmd/getOpenFile.htm>
   #
   # Beispiel:
   # (start code)
   # set filePatternListe [list \
   #     "Tcl-Files {*.tcl *.tk *.itcl *.itk *.tm}" "All {*}"]
   # ::utils::file::getsavefile \
   #     -filetypes $filePatternListe \
   #     -initialdir $ad(workingDir) \
   #     -hidden 0 \
   #     -title "Datei öffnen"
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::getsavefile {args} {
      #--------------------------------------------------------------------
      package require fsdialog
      set os $::tcl_platform(os)
      switch -- $os {
         "Linux" - "SunOS" - "freebsd" {
            return [ttk::getSaveFile {*}$args]
         }
         "macosx" {
            return [tk_getSaveFile {*}$args]
         }
         "Win32" {
            return [tk_getSaveFile {*}$args]
         }
         default {
            return [tk_getSaveFile {*}$args]
         }
      }
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: getdirectory
   #
   # *::utils::file::getDirectory args*
   # 
   #    pops up a dialog box for the user to select a directory.
   #    Arbeitet nur lokal.
   #
   # Parameter:
   #     args: Optionen
   #
   # Optionen:
   #
   # -initialdir dir: Specifies that the directories in directory
   #    should be displayed when the dialog pops up. If this
   #    parameter is not specified, the initial directory defaults
   #    to the current working directory
   #    If the parameter specifies a relative path, the return value will convert the relative path to an absolute path.
   # -mustexist bool:  Specifies whether the user may specify
   #     non-existent directories. If this parameter is true, then the user may only select directories that already exist. The default value is false.
   # -parent p: Parentwidget
   # -title string: Dialogtitel
   #
   # Ergebnis:
   # Pfad Verzeichnis
   #
   # siehe auch:
   # - <TkCmd/chooseDirectory.htm>
   #
   # Beispiel:
   # (start code)
   # set dir [::utils::file::getdirectory \
   #     -initialdir ~ -title "Choose a directory"]
   # if {$dir eq ""} {
   #   label .l -text "No directory selected"
   # } else {
   #   label .l -text "Selected $dir"
   # }
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::getdirectory {args} {
      package require fsdialog
      set os $::tcl_platform(os)
      switch -- $os {
         "Linux" - "SunOS" - "freebsd" {
            return [ttk::chooseDirectory {*}$args]
         }
         "macosx" {
            return [tk_chooseDirectory {*}$args]
         }
         "Win32" {
            return [tk_chooseDirectory {*}$args]
         }
         default {
            return [tk_chooseDirectory {*}$args]
         }
      }
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: getappendfile
   #
   # *::utils::file::getappendfile args*
   # 
   # liefert Dateipfad zum Öffnen einer vorhandenen
   # Datei (nur lokal)
   #
   # Parameter:
   #     args: Optionen
   #
   # Optionen:
   #
   # -defaultextension: zur Vorbelegung im Dialog
   # -filetypes: zur Vorbelegung im Dialog (Default:none)
   # -initialdir: zur Vorbelegung im Dialog
   # -intialfile: zur Vorbelegung im Dialog
   # -parent: Parentwidget vom Dialog
   # -title: Dialogtitel
   # -typevariable: Auswahl in der Filterliste
   # -multiple: Mehrfachauswahl
   # -sepfolders: im Dialog werden die Verzeichnisse links angezeigt (Default:1)
   # -sort: Sortiervorgabe für die angezeigten Dateien (Name Date Size) Default:Name
   # -foldersfirst: Verzeichnisse am Anfang listen (Default:1)
   # -reverse: umgekehrte Reihenfolge (Default:0)
   # -details: Details der Dateien anzeigen (Default:0)
   # -hidden: versteckte Dateien anzeigen (Default:1)
   #
   # Ergebnis:
   # Dateipfad oder {}
   #
   # siehe auch:
   # - <TkCmd/getOpenFile.htm>
   #
   # Beispiel:
   # (start code)
   # set filePatternListe [list \
   #     "Tcl-Files {*.tcl *.tk *.itcl *.itk *.tm}" "All {*}"]
   # ::utils::file::getappendfile \
   #     -filetypes $filePatternListe \
   #     -initialdir $ad(workingDir) \
   #     -hidden 0 \
   #     -multiple 1 \
   #     -title "Datei öffnen"
   # (end)
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::getappendfile {args} {
      #--------------------------------------------------------------------
      package require fsdialog
      set os $::tcl_platform(os)
      switch -- $os {
         "Linux" - "SunOS" - "freebsd" {
            return [ttk::getAppendFile {*}$args]
         }
         "Win32" {
            return [tk_getSaveFile -confirmoverwrite 0 {*}$args]
         }
         default {
            return [ttk::getAppendFile {*}$args]
         }
      }
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: ssh_expect 
   #
   # *::utils::file::ssh_expect pw kdo args*
   # 
   #
   # ssh_expect ruft ssh, scp oder sshfs auf. Wenn bei pw ein
   # leerer String übergeben wird, wird direkt exec kdo ..
   # gestartet, ansonst wird expect verwendet. Dabei ist
   # wichtig, dass der Zielknoten interaktiv nach dem Passwort
   # frägt, d.h. die Authorisierung mit öffentlichen und
   # privaten Schlüsseln funktioniert bei ssh_expect nicht.
   # 
   # Hinweis:
   # Host muss nach Passwort fragen !!
   # Wenn pw = {} wird das Kommando direkt mit exec aufgerufen
   #
   # Parameter:
   #     pw:   Passwort des Benutzers auf dem Zielhost oder leerer String 
   #     kdo:  ssh|scp|sshfs  ssh-Funktion
   #     args: Argumente zum Kommando 
   # 
   # 
   # Ergebnis: 
   # Text von ssh|scp
   # 
   # siehe auch:
   # - sftp
   # 
   # Beispiel:
   # (start code)
   # ssh_expect geheim  ssh -v mlrd@amilo ls -l bin
   # ssh_expect geheim  scp -p mlrd@amilo:quelle ziel
   # ssh_expect geheim  scp -p quelle mlrd@amilo:ziel
   # ssh_expect geheim  sshfs mlrd@amilo:/remdir locdir -opts
   # 
   # (end)
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::ssh_expect {pw kdo args} {
      package require Expect
      set timeout 5
      set msg {}
      set prompt {$ }
   
      # ohne Pw direkt aufrufen
      #
      if {$pw == {}} {
         if {[catch {exec $kdo {*}$args} fm ]} {
            return -code error $fm
         } else {
            return $fm
         }
      }
   
      log_user 0
      if {[regexp -- {ssh|scp|sftp} $kdo]} {
         spawn $kdo {*}$args
   
         expect  {
             -re {Password: }       {exp_send $pw\r}
             {No route to host}     {return -code error "No route to host"}
             eof                    {return -code error "eof: $expect_out(buffer)"}
            timeout                 {return -code error "ssh timeout"}
         }
   
         expect -re (.*)\r\n$prompt\r\n
         if {[info exists expect_out(buffer)]} {
            set msg $expect_out(buffer)
         }
      } else {
         return -code error "kdo <$kdo> muss ssh|scp|sshfs sein"
      }
   
      # Fehler bei scp beginnen mit 'scp:'
      if {$kdo == {scp} && [string match "*\nscp:*" $msg]} {
         return -code error $msg
      }
      return [string trim $msg]
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: sftp 
   #
   # *::utils::file::sftp user pw host qu z*
   # 
   #
   # _sftp_ kopiert die Quelle _qu_ nach _z_ auf dem Knoten _host_.
   # Wenn bei pw ein leerer String übergeben wird, wird direkt
   # exec sftp .. gestartet, ansonst wird ssh_expect verwendet.
   # Dabei ist wichtig, dass der Zielknoten interaktiv nach dem
   # Passwort frägt, d.h. die Authorisierung mit öffentlichen
   # und privaten Schlüsseln funktioniert bei ssh_expect nicht.
   # 
   # Parameter:
   #     user: Benutzername auf dem Zielhost 
   #     pw:   Passwort des Benutzers auf dem Zielhost oder leerer String 
   #     host: Zielhost 
   #     qu:   Pfadname der Quelle 
   #     z:    Pfadname der Zieldatei 
   # 
   # 
   # siehe auch:
   # - ssh_expect 
   # 
   # Beispiel:
   # (start code)
   # sftp mlrd geheim amilo /home/mlrd/q z
   # 
   # (end)
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::sftp {user pw host qu z} {
   
      set putStr "put $qu $z\nquit"
      set tmpFile [::utils::file::writetmp $putStr]
   
      if {$pw == {}} {
         if {[catch {exec sftp -q -b $tmpFile $user@$host} fm]} {
            return -code error $fm
         } else {
            return $fm
         }
      } else {
         return [ssh_expect $pw sftp -q -b $tmpFile $user@$host]
      }
      file delete $tmpFile
   }
   
   ###-----------------------------------------------------------------------------
   # 
   # Proc: zlibb
   #
   # *::utils::file::zlibb fkt pf str*
   # 
   # zlib-Funktionen ausführen
   #
   # zlib gzip datei.gz str
   # 
   # zlib gunzip datei.gz 
   #  
   #  
   # 
   # Parameter:
   #     fkt: gzip|gunzip
   #     str: Textstring
   #     pf:  Pfad der Datei.gz
   # 
   #
   # Ergebnis:
   # 
   # gzip: 0|1
   # 
   # gunzip : String
   # 
   # 
   ###-----------------------------------------------------------------------------
   proc ::utils::file::zlibb {fkt pf {str {}}} {
      
      switch -exact -- $fkt  {
         gzip {
            #if {![file writable $pf]} {
            #   return -code error "F-zlib gzip : $pf \nnicht schreibfähig"
            #}
            
            if {$str eq ""} {
               return -code error "F-zlib gzip : str ist leer"
            }
            
            #  if {[file extension $pf] ne ".gz"} {
            #    return -code error "F-zlib gzip : Dateityp muss .gz sein"
            #}
            
            set hdr [list filename [file rootname $pf]]
            set strZ [encoding convertto utf-8 $str]
            if {[catch {::zlib gzip $strZ -header $hdr} inhZ]} {
               return -code error "zlib gzip:$inhZ"
            }
            
            set FOUT [open $pf w]
            fconfigure $FOUT -translation binary -encoding binary
            puts -nonewline $FOUT $inhZ
            close $FOUT
            return 0
         }
         gunzip {
            if {![file readable $pf]} {
               return -code error "F-zlib gunzip : $pf \nnicht lesefähig"
            }
            # zlib bricht oft ab bei crc mismatch
            # deshalb gunnzip
            return [gunzipp $pf STRINGAUSGABE]
            #set FIN [open $pf r]
            #fconfigure $FIN -translation binary -encoding binary
            #set inhZ  [read -nonewline $FIN]
            #close $FIN
            #if {[catch {::zlib gunzip $inhZ} inh]} {
            #   return -code error "zlib gunzip $pf :$inh"
            #}
            #return $inh
         }
         default {
            return -code error "F-zlib: fkt <$fkt> falsch"
         }
      } ; # end switch
   }
   
   ###-----------------------------------------------------------------------------
   #
   # Proc: gunzipp
   #
   # *::utils::file::gunzipp file outfile*
   # 
   # entzippt eine Datei, liefert Datei oder String 
   #
   # gunzipp file ?outfile?
   # 
   # gunzipp file ?STRINGAUSGABE?
   # 
   #
   # Parameter:
   #     file: Pfad der Datei.gz
   #     outfile: Pfad der entzippten Datei oder {}
   #     outfile: STRINGAUSGABE
   #
   # Ergebnis:
   # pfad oder String 
   #
   ###-----------------------------------------------------------------------------
   proc ::utils::file::gunzipp { file {outfile ""} } {
      # outfile == STRINGAUSGABE -> String ausgeben
      
      #package require zlib
      # Gunzip the file
      # See http://www.gzip.org/zlib/rfc-gzip.html for gzip file description
      
      set in [open $file r]
      fconfigure $in -translation binary -buffering none
      
      set id [read $in 2]
      if { ![string equal $id \x1f\x8b] } {
         error "$file is not a gzip file."
      }
      set cm [read $in 1]
      if { ![string equal $cm \x8] } {
         error "$file: unknown compression method"
      }
      binary scan [read $in 1] b5 FLAGS
      #puts $FLAGS
      foreach {FTEXT FHCRC FEXTRA FNAME FCOMMENT} [split $FLAGS ""] {}
      binary scan [read $in 4] i MTIME
      set XFL [read $in 1]
      set OS [read $in 1]
      
      if { $FEXTRA } {
         binary scan [read $in 2] S XLEN
         set ExtraData [read $in $XLEN]
      }
      set name ""
      if { $FNAME } {
         set XLEN 1
         set name [read $in $XLEN]
         set c [read $in 1]
         while { $c != "\x0" } {
            append name $c
            set c [read $in 1]
         }
      }
      set comment ""
      if { $FCOMMENT } {
         set c [read $in 1]
         while { $c != "\x0" } {
            append comment $c
            set c [read $in 1]
         }
      }
      set CRC16 ""
      if { $FHCRC } {
         set CRC16 [read $in 2]
      }
      
      set cdata [read $in]
      close $in
      
      binary scan [string range $cdata end-7 end] ii CRC32 ISIZE
      
      set data [::zlib inflate [string range $cdata 0 end-8]]
      
      if { $CRC32 != [zlib crc32 $data] } {
        ## puts "gunzip Checksum mismatch."
      }
      
      # String ausgeben ?
      #
      if {$outfile eq "STRINGAUSGABE"} {
         return $data
      }
      
      # File ausgeben
      #
      if { $outfile == "" } {
         set outfile $file
         if { [string equal -nocase [file extension $file] ".gz"] } {
            set outfile [file rootname $file]
         }
      }
      if { [string equal $outfile $file] } {
         error "Will not overwrite input file. sorry."
      }
      set out [open $outfile w]
      fconfigure $out -translation binary -buffering none
      puts -nonewline $out $data
      close $out
      file mtime $outfile $MTIME
      return $outfile
   }

       