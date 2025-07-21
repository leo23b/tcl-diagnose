## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "connect.tcl"
 #  Description:
 #  enthält Funktionen zum Verbindungsauf- und abbau mit dem Testling
 #
 # ###################################################################
   
namespace eval Connect {
   variable modeZiel       ;# {entry|comm ziel}
   variable alteAdr {}     ;# für reconnect 
   
   #-----------------------------------------------------------------------
   proc dialog {} {
      # alle dem Inspector bekannten CommIds zur Auswahl anbieten
      # oder Eingabe einer ID
      #-----------------------------------------------------------------------
      #_proctrace
      global wv
      
      # Dialog kreiern
      #
      set p $wv(w,top)
      catch {destroy $p.targetDlg}
      set dlg [Dialog $p.targetDlg \
         -image     [::utils::gui::ic 32 view-refresh-2]  \
         -title "Auswahl Testlinge" \
         -modal     none \
         -parent    $p   \
         -separator true \
         -cancel    0    \
         -default   2    \
         -anchor    w    ]
      
      set f  [$dlg getframe]
      
      # Comm-Verbindungen
      #
      set tf [TitleFrame $f.tf2 -text Comm-Verbindungen]
      pack $tf -padx 3 -pady 3 -fill both -expand 1
      set frComm [$tf getframe]
      
      set adrInspector [::comm::comm self]
      comm::comm config -local 1 -port $adrInspector
      
      # alle Comm-Ziele, die der Inspector kennt
      #
      set commTargets [comm::comm interps]
      set nr 0
      set links {}
      
      foreach port $commTargets {
         # inspector auslassen
         if {$port == $adrInspector } continue
         
         # nicht doppelt !
         if {$port in $links } continue
         
         # # Applic Name
         set name {}
         if {[catch {comm::comm send $port winfo "name" .} name]} {
            set name [comm::comm send $port set ::gd(programm)]
         }
         
         set ziel "$port ($name)"
         radiobutton $frComm.$nr \
            -text $ziel          \
            -anchor w            \
            -variable ::Connect::modeZiel \
            -value [list comm $port] \
            -relief flat
         bind $frComm.$nr <Double-ButtonRelease-1> \
            [list Connect::connectCB $dlg connect]
         pack $frComm.$nr -side top -pady 2 -anchor w -fill x
         incr nr
         lappend links $port
      }
      
      # Comm-Entry
      #
      set tf [TitleFrame $f.tf3 -text "Comm Id eingeben"]
      pack $tf -padx 3 -pady 3 -fill both -expand 1
      set frEntry [$tf getframe]
      
      set en [::utils::gui::mkEntry wv $frEntry en,comm ]
      
      radiobutton $frEntry.rb \
         -variable ::Connect::modeZiel \
         -anchor w \
         -value [list entry $en] \
         -relief flat
      pack $frEntry.rb -side left -pady 2 -anchor w -fill x
      pack $en -padx 3 -pady 3 -fill x -expand 1 -side left
      bind $frEntry.rb <Double-ButtonRelease-1> \
         [list Connect::connectCB $dlg connect]
      
      # Radiobutton selektieren
      if {[llength $links] == 0} {
         $frEntry.rb select
      }
      
      # Tasten
      $dlg add -image [::utils::gui::ic 22 process-stop] \
         -helptext {Dialog abbrechen} \
         -command [list $dlg withdraw]
      $dlg add -text "Info" -helptext {Info zur Verbindung} \
         -command [list Connect::connectCB $dlg info]
      $dlg add -text "Connect" -helptext {Verbindung herstellen} \
         -command [list Connect::connectCB $dlg connect]
      $dlg draw
      
      return
   }
   
   #-------------------------------------------------------------------
   proc connectCB {dlg fkt} {
      # Callback gerufen vom Dialog
      # dlg:      Dialogwindow
      # fkt:      connect|info
      #----------------------------------------------------------------
      #_proctrace
      variable modeZiel
      
      lassign $modeZiel mode ziel
      
      # mode : comm|entry
      # ziel : commId|entryWidget
      if {$mode eq "entry"} {
         set ziel [$ziel get]
         set mode comm
      }
      
      if {$ziel eq ""} {
         ::utils::gui::msgow1 "bitte Ziel wählen" 1000 Hinweis $dlg 
         return
      }
      
      # Dialog entfernen
      $dlg withdraw
      
      switch -exact -- $fkt  {
         info    {connectInfo $mode $ziel}
         connect {connect $mode $ziel}
         default {return -code error "fkt falsch"}
      } ; # end switch
      
      return
   }
   
   #-------------------------------------------------------------------
   proc connect {mode ziel} {
      # verbindet den inspector mit dem Testling und aktualisiert
      # die Listen im Notebook
      # mode : entry |comm
      # ziel : commID 
      #----------------------------------------------------------------
      #_proctrace
      global gd wv
      variable alteAdr
       
      set adrInspector [::comm::comm self]
      set gd(sendAnInspector) \
         "::comm::comm send -async $adrInspector "
      comm::comm config -local 1 -port $adrInspector
      
      # ----------------------- Verbindung async testen
      #
      ::utils::gui::setClock on $wv(w,top)
      
      set targetNew  $ziel
      set altProgramm $gd(targetProgramm)
      
      if {![testTarget $targetNew]} {
         ::utils::gui::setClock off $wv(w,top)
         return
      }
      
      setTarget $ziel
      initTestling
      
      # TPTl und ValueTL ggf löschen
      DeleteTL $altProgramm
      
      # commAdresse speichern für reconnect Aufruf
      set alteAdr [list $ziel]
      
      # callback für Verbindungsabbruch
      ::comm::comm hook lost {
         ::utils::gui::msgow1 "Verbindung verloren" 2000 Hinweis $::wv(w,top)
         set ::wv(v,targetName) {Drop here}
         set ::gd(target) {}
         return
      }
      
      # reset modified-Taste im Valuefeld
      foreach liste $gd(listen) {
         if {[info exists wv(w,txt,val,$liste)]} {
            if {[winfo exists $wv(w,txt,val,$liste)]} {
               $wv(w,txt,val,$liste) edit modified 0
            }
         }
      }
      
      # alle Listen aktulisieren
      UpdateListe alle
      ::utils::gui::setClock off $wv(w,top)
      return
   }
   
   #-------------------------------------------------------------------
   proc connectInfo {mode ziel} {
      # liefert Infos zum selektiertem Ziel, gerufen aus ConnectDialog
      # mode : comm
      # ziel : commId
      #--------------------------------------------------------------------
      global gd wv
      #_proctrace
      
      set targetNew    [list $ziel]
      set gd(sendAnInspector) "::comm::comm send [::comm::comm self] "
      
      #Verbindung async testen
      ::utils::gui::setClock on $wv(w,top)
      update idletasks
      if {![testTarget $targetNew]} {
         ::utils::gui::setClock off $wv(w,top)
         return
      }
      
      set msg {}
      append msg "Zieladresse:\t$targetNew\n"
      append msg "Applic-Name:\t[comm::comm send $ziel winfo name .]\n\n"
      append msg "Host\t:\t[Bwsend $targetNew info hostname]\n"
      append msg "Interp\t:\t[Bwsend $targetNew info nameofexecutable]\n"
      append msg "argv0\t:\t[Bwsend $targetNew set ::argv0]\n"
      append msg "ArgV\t:\t[Bwsend $targetNew set ::argv]\n"
      append msg "PWD\t:\t[Bwsend $targetNew pwd]\n"
      set pid [Bwsend $targetNew pid]
      append msg "PID\t:\t$pid\n"
      append msg "ps\t:\t[Bwsend $targetNew exec ps --no-headers -p $pid f]\n"
      
      ::widgets::tw $wv(w,top).conninfo \
         -widget text \
         -buttonbox 0 \
         -titel Verbindungsinfo \
         -text  $msg
      ::utils::gui::setClock off $wv(w,top)
      
      return
   }
   
   #--------------------------------------------------------------------
   proc checkAsync {ziel} {
      # asynchron Verbindung testen
      # liefert ok|nok
      #--------------------------------------------------------------------
      global gd
      
      if {$ziel eq {} } {
         set ::connOK nok
         return nok
      }
      
      # Verbindung testen
      unset -nocomplain ::connOK
      set remCmd " $gd(sendAnInspector) set ::connOK ok"
      catch { comm::comm send -async $ziel $remCmd}
      
      # Timeout 1 sec
      #
      set afterId [after 1000 {set ::connOK nok}]
      tkwait variable ::connOK
      if {[info exists afterId]} {
         after cancel $afterId
      }
      return $::connOK
   }
   
   #--------------------------------------------------------------------
   proc testTarget {target} {
      # prüft ob Ziel erreichbar ist
      # 1: ok
      # 0: nok
      #--------------------------------------------------------------------
      #_proctrace
      global gd
     
      if {$target eq {} } {
         setTarget {}
         return 0
      }
      
      set asyncErg [::Connect::checkAsync $target]
      if {$asyncErg == "nok"} {
         ::utils::gui::msg warning Kommunikation "Ziel <$target> nicht erreichbar"
        return 0
      } else {
         #setTarget $target
         return 1
      }
   }
   
   
   #----------------------------------------------------------------------
   proc setTarget {target} {
      # Ziel anzeigen, Fenstertitel, Statuszeile
      #--------------------------------------------------------------------
      global gd wv
      #_proctrace
      
      set gd(target) $target
      if {$target == {}} {
         set wv(v,targetName) {Drop here}
         set gd(targetProgramm) "kein_ziel"
      } else {
         # gui-Ziele
         if {[Bwsend $target info commands winfo] ne ""} {
            set gd(targetProgramm) [Bwsend $target ::winfo name .]
         } else {
            set gd(targetProgramm) [Bwsend $target set ::gd(programm)]
         }
         
         set wv(v,targetName)  $gd(targetProgramm)
         append wv(v,targetName) " <$gd(target)>"
      }
      
      wm title $wv(w,top) "inspector -> $wv(v,targetName)"
   }
   
   #-----------------------------------------------------------------------
   proc initTestling {} {
      #
      #-----------------------------------------------------------------------
      
      PrepareInspection
      ResetData
  ##    DebugInit
      return
   }
   
   #--------------------------------------------------------------------
   proc reconnect {} {
      # mit bisherigen Ziel wieder verbinden
      # aber ohne ResetData, 
      #--------------------------------------------------------------------
      #_proctrace
      global gd wv
      variable alteAdr    ;# für reconnect
   
      # ----------------------- Verbindung async testen
      #
      ::utils::gui::setClock on $wv(w,top)
      update idletasks
      
      # beim Neustart vom Testling hat sich ggf die Id
      # geändert
      if {$alteAdr ne ""} {
         set gd(target)   $alteAdr
      }
      
      if {![testTarget $gd(target)]} {
         ::utils::gui::setClock off $wv(w,top)
         return
      }
      
      PrepareInspection
      ##DebugReInit
      
      set gd(status) "Prepare_Inspection ready"
      ::utils::gui::setClock off $wv(w,top)
      
      
      # alle Listen aktualisieren
      #
      UpdateListe alle
      
      # auch die abgesetzte ValueTabelle
      ValueTLUpdate
      
      # reset Suchmuster
      set ::inspector::pattOld(Global) {}
      set ::inspector::pattOld(Namespace) {}
      set ::inspector::pattOld(Proc) {}
      set ::inspector::pattOld(Widget) {}
      
      ::utils::gui::setClock off $wv(w,top)
      return
   }
   
   
   
   
   
} ; # end namespace