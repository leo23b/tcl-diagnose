## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "utils_inspector.tcl"
 #  Description:
 #  enthält allgemeine Utilities
 #
 # ###################################################################

#--------------------------------------------------------------------
proc UpdateListe {liste} {
   # Alle oder eine Liste wird aktualisiert und das
   # Ergebnis in die Listbox geschrieben
   # Wird bei Programmstart, bei Änderung einer Verbindung
   # oder durch Menu aufgerufen
   # liste   :   Name|{}|alle
   #--------------------------------------------------------------------
   global gd wv
   
   # Ziel vorhanden ? Liste leeren
   #
   if {$gd(target) eq ""} return
   
   # alle Listen ?
   if {$liste eq "alle"} {
      set gd(clockset) 1
      foreach li $gd(listen) {UpdateListe $li}
      set gd(clockset) 0
      return
   }
   
   if {!$gd(clockset)} {
      ::utils::gui::setClock on $wv(w,top)
   }
   
   set gd($liste,inhalt) {}
   switch -- $liste  {
      Widget {
         InsertWidgetTree .
      }
      
      Quelle {
         # auf dem Testling die sortierte QuellListe erzeugen und holen
         set gd(Quelle,inhalt) \
            [SendSyn -- ::inspector_testling::QuelleSort]
      }
      
      Namespace {
         # auf dem Testling die rekursive Liste erzeugen
         SendSyn -- ::inspector_testling::GetNamespaces ::
         
         # Liste von Testling holen
         set gd(Namespace,inhalt) \
            [SendSyn --  set ::inspector_testling::alleNamespaces]
      }
      
      Global {
         # auf dem Testling die rekursive Liste erzeugen
         SendSyn -- ::inspector_testling::GetGlobals
         
         # Liste von Testling holen
         set gd(Global,inhalt) \
            [SendSyn -- set ::inspector_testling::alleGlobals]
         
         # :: nochmals hinten anhängen
         set erg [SendSyn --  ::info vars *]
         set gd(Global,inhalt) [concat $gd(Global,inhalt) $erg]
         
      }
      
      Proc {
         # auf dem Testling die rekursive Liste erzeugen
         SendSyn -- ::inspector_testling::GetProcs
         
         # Liste von Testling holen
         set gd(Proc,inhalt) \
            [SendSyn -- set ::inspector_testling::alleProcs]
         
         if {0}   {
            # :: nochmals hinten anhängen
            set erg [SendSyn -- ::info procs *]
            #lappend gd(Proc,inhalt) {*}$erg
            set gd(Proc,inhalt) [concat $gd(Proc,inhalt) $erg]
            
            # Proz . ausschliessen
            set erg ""
            foreach li $gd(Proc,inhalt) {
               if {[string match {.*} $li]} {continue}
               lappend erg $li
            }
            set gd(Proc,inhalt) $erg
         }
      }
      classes {
         
      }
      objects {
         
      }
      Image {
         # nicht bei nogui-Zielen
         if {[SendSyn -- info commands winfo] eq ""} {return}
         set gd(Image,inhalt) [SendSyn -- image names]
      }
      Font {
         # nicht bei nogui-Zielen
         if {[SendSyn -- info commands winfo] eq ""} {return}
         set gd(Font,inhalt) [SendSyn -- font names]
      }
      Menu {
         # nicht bei nogui-Zielen
         if {[SendSyn -- info commands winfo] eq ""} {return}
         # alle Wigets müssen aktuell sein
         GetLocWidgetInfo
         
         foreach widget [array names ::inspector::widgetClasses] {
            set class $::inspector::widgetClasses($widget)
            if {$class=={Menu}} {
               lappend gd(Menu,inhalt) $widget
            }
         }
      }
      After {
         set gd(After,inhalt) [SendSyn -- after info]
         # after exists ?
         set ergAfter [list]
         foreach id $gd(After,inhalt) {
            set sendK [list after info $id]
            if {[catch {eval $sendK} afterInfo]} {continue}
            lappend ergAfter $id
         }
         set gd(After,inhalt) $ergAfter
      }
      
      Canvas {
         # nicht bei nogui-Zielen
         if {[SendSyn -- info commands winfo] eq ""} {return}
         # alle Wigets müssen aktuell sein
         GetLocWidgetInfo
         foreach widget [array names ::inspector::widgetClasses] {
            set class $::inspector::widgetClasses($widget)
            if {$class=={Canvas}} {
               lappend gd($liste,inhalt) $widget
            }
         }
      }
   }
   
   # Liste sortieren, filtern und anzeigen
   #
   set gd($liste,inhalt) [lsort $gd($liste,inhalt)]
   set gd($liste,inhalt) [FilterListe $liste]
   FillListe  $liste $gd($liste,inhalt)
   
   # Valuefeld im Register aktual.
   ValueUpdate $liste
   if {!$gd(clockset)} {
      ::utils::gui::setClock off $wv(w,top)
   }
   
   # Suchenergebnis reset
   set ::inspector::ids($liste) {}
}

#-------------------------------------------------------------------
proc SendValue {} {
   # Inhalt vom Infofenster an Ziel senden
   # gerufen von Taste Send Value und
   # Taste Eval aus TopTextValue
   #--------------------------------------------------------------------
   global wv gd
   
   if {$gd(target) eq ""} {return}
   set gd(status) {}
   
   set liste [$wv(w,nb) raise]
   set txt $wv(w,txt,val,$liste)
   set value [$txt get 0.0 end ]
   _leer $value {return}
   SendSyn -- $value
   set gd(status) {send value fertig}
   $txt edit modified 0
}

#--------------------------------------------------------------------
proc SendCommand {} {
   # Kommando an Ziel senden, Ergebnis wird im Consolenfenster angezeigt
   #--------------------------------------------------------------------
   global gd wv
   
   if {$gd(target) eq ""} {return}
   
   set txt $wv(w,txt,send)
   set cb  $wv(w,cb,send)
   set cmd [$cb get]
   
   if {$cmd eq ""} {return}
   
   #$txt delete 1.0 end
   $txt insert end "\n-------------------------------\n"
   $txt insert end "$cmd ...\n"
   set result [SendSyn -- $cmd]
   
   $txt insert end $result
   $txt insert end "\n-- Ende --"
   $txt see end
   
   # in Historie eintragen
   set items [$cb cget -values]
   if {$cmd ni $items} {
      $cb configure -values [lappend items $cmd]
   }
}

#--------------------------------------------------------------------
proc NewInspector {} {
   # erzeugt neue inspector-Instanz
   #--------------------------------------------------------------------
   set cmd [auto_execok inspector]
   exec $cmd &
}
#-----------------------------------------------------------------------
proc DeleteTL {altProgramm} {
   # bei connect wird tpToplevel gelöscht. ValueTL wird gelöscht
   # bei neuem Zielname
   # altProgramm : n-1 Programmname
   #-----------------------------------------------------------------------
   global wv gd
   
   # TracepunktToplevel
   if {[info exists wv(w,tl,tp)]} {
      catch {destroy $wv(w,tl,tp)}
   }
   
   # ValueTL da ?
   if {![info exists wv(w,tl,value)]} {
      return
   }
   
   # neues Programm ?
   if {$altProgramm eq $gd(targetProgramm)} {return}
   
   catch {destroy $wv(w,tl,value)}
   return
}