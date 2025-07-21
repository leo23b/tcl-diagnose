## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "send.tcl"
 #  Description:
 #  enthält Proz. zum senden an/vom Ziel
 #
 # ###################################################################

#---------------------------------------------------------------
proc Bwsend {zieladr args} {
   # sendet synchron
   # zieladr : commID des Ziels
   # args    : Kommando
   # Result  : erg vom Kommando oder ""
   #--------------------------------------------------------------------
   global gd
   
   if {$zieladr eq ""} {return ""}
   
   if {[catch {eval comm::comm send $zieladr {*}$args } erg]} {
      ::utils::gui::msg error "Fehler Bwsend" $erg
      return ""
   }
   return $erg
}
#---------------------------------------------------------------
proc SendSyn {args} {
   # sendet asynchron  mit Zeitüberwachung ein Kommando an den Testling.
   # Der antwortet mit ReplySyn
   #---------------------------------------------------------------
   global gd wv
   
   if {$gd(target) eq {}} {
      ::utils::gui::msg error SendFehler "kein Testziel vorhanden"
      return {}
   }
   ::Opt::opts {params} $args {
      {-to    {}  "Timeout in sec"}
      {-msg   {0} "Popup-Meldung anzeigen"}
      {-noerr {0} "kein error-return bei Fehler"}
      {--      ""  "Kommando mit Arg. für den Testling"}
   }
   
   if {$gd(defaultTO) >=1 || $gd(defaultTO) ne ""} {
      if {$params(-to) eq ""} {
         set timeout [expr {$gd(defaultTO) * 1000}]
      } else {
         set timeout [expr {$params(-to) * 1000}]
      }
   } else {
      set timeout -1
   }
   
   set showMsg $params(-msg)
   set noErr   $params(-noerr)
   set cmd     $params(--)
   
   set sendKdo "comm::comm send -async $gd(target) \
      ::inspector_testling::ReplySyn $cmd "
   #_dbg 15 SendKdo {set sendKdo}
   
   set mitError 0
   unset -nocomplain ::testling_result
   if {[catch {eval $sendKdo} msg]} {
      ::utils::gui::msg error "SendSyn" $msg
      ::utils::gui::setClock off $wv(w,top)
      return {}
   }
   
   # Timer aufziehen und warten
   if {$timeout >1} {
      set afterId [after $timeout {set ::testling_result {{} timeOut {} }}]
   }
   
   tkwait variable ::testling_result
   if {[info exists afterId]} {
     after cancel $afterId
   }
   set erg "$::testling_result"
   
   lassign $erg errCode errInfo result
   if {$errInfo ne ""} {
      set mitError 1
      set result $errInfo
   }
   #_dbg 15 SendErg {::utils::printlistestring erg}
   
   # PopUp bei Fehler ?
   if {$showMsg && $mitError} {
      ::utils::gui::msg error SendFehler "Target:$gd(target)\n:<$cmd<\n$result"
   }
   
   # result abgeschnitten ?
   #if {$errCode == 5} {
   #   set msg1 "<$cmd<\nDaten abgeschnitten "
   #   ::utils::gui::msgow $wv(w,top) $msg1
   #}
   
   # return Error bei Fehler ?
   if {!$noErr && $mitError} {
      ::utils::gui::setClock off $wv(w,top)
      
      # SnitFehler ignorieren
      if {[string match {*Snit_*Cache*} $result]} {
         #puts "snitfehler"
         return {}
      }
      
      return -code error $result
   }
   #puts "I:$result"
   return $result
}


#--------------------------------------------------------------------
proc PrepareInspection {} {
   # die nachfolgenden Prozeduren werden auf den
   # Testling zur remote Ausführung übertragen
   #
   # Show_Widget_remote <--ctrl-shift-alt-1
   #--------------------------------------------------------------------
   global gd
   
   #_proctrace
   set procTxt {
      namespace eval inspector_testling {
         variable tpVW [list]  ;# Verwaltung Tracepunkte
         
         # --------------------------------------------------
         proc ::inspector_testling::ReplySyn {args} {
            # ist die synchrone Antwortproc für SendSyn
            
            set msg ??
            set ::errorCode {}
            set ::errorInfo {}
            
            # Kommando lokal ausführen
            #
            catch {set msg [eval $args ]}
            
            # Ergebnis an inspector zurück senden
            #
            set ret [list $::errorCode $::errorInfo $msg]
            %sendAnInspector [list set ::testling_result $ret]
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::Show_Widget_Remote {w x y} {
            # das im Testling selektierte Widget mit ctr-shift-alt-b1
            # wird im inspector WidgetRegister angezeigt
            
            set win [winfo containing $x $y]
            %sendAnInspector TriggerSelectWidget $w $x $y
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::GetWidgetInfo {} {
            # liefert Widgettree und  Widgetclassen
            
            # key:Widget Inhalt: Class
            array unset ::inspector_testling::widgetClasses
            
            # Liste aller Widgets und deren Kinder
            array unset ::inspector_testling::widgetTree
            
            ::inspector_testling::GetWidgetTree .
            
            set msg ""
            set liste [array get ::inspector_testling::widgetTree]
            set len   [string length $liste]
            return $msg
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::GetWidgetTree {p} {
            # ermittelt rekursiv alle Widget und Kinder
            set children [ ::winfo children $p]
            set ::inspector_testling::widgetTree($p) $children
            set ::inspector_testling::widgetClasses($p) [ ::winfo class $p]
            foreach w $children {
               ::inspector_testling::GetWidgetTree $w
            }
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::GetNamespaces { parent } {
            # ermittelt für alle NS rekursiv die NS
            if {$parent == {::}} {
               set ::inspector_testling::alleNamespaces {}
            }
            set erg [::namespace children $parent]
            lappend ::inspector_testling::alleNamespaces $parent
            
            foreach namespace $erg {
               ::inspector_testling::GetNamespaces $namespace
            }
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::GetGlobals {} {
            # ermittelt für alle NS rekursiv die glob Daten
            set ::inspector_testling::alleGlobals {}
            ::inspector_testling::GetNamespaces {::}
            foreach ns $::inspector_testling::alleNamespaces {
               set erg [::info vars ${ns}::* ]
               set ::inspector_testling::alleGlobals \
                  [concat $::inspector_testling::alleGlobals $erg]
            }
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::GetProcs {} {
            # ermittelt für alle NS rekursiv alle Prozeduren
            set ::inspector_testling::alleProcs {}
            ::inspector_testling::GetNamespaces {::}
            
            foreach ns $::inspector_testling::alleNamespaces {
               set erg [::info procs ${ns}::* ]
               set ::inspector_testling::alleProcs \
                  [concat $::inspector_testling::alleProcs $erg]
            }
            
            # WidgetProcs weglassen
            # body fängt mit 'return \[eval \[linsert' an
            # und die Parameter sind 'cmd args'
            #set procLi {}
            #foreach pr $::inspector_testling::alleProcs {
            #   set _args [info args $pr]
            #   set _body [string range [info body $pr] 0 6]
            #   if {$_args eq {cmd args} && \
            #      $_body eq {return }} {
            #      continue
            #   }
            #   lappend procLi $pr
            #}
            #set ::inspector_testling::alleProcs $procLi
            
            # besser in ProcListe filtern
         }
         
         # --------------------------------------------------
         proc  ::inspector_testling::GetGlobalVar {var} {
            # liefert Inhalt einer globalen Variable
            
            # :: davorhängen , wenn fehlt
            #
            set var ::$var
            #if {[string first  {::} $var ] == -1} {
            #   set var ::$var
            #}
            if {[array exists $var ]} {
               #puts "$var ist array"
               ##nagelfar ignore
               set names [lsort [array names $var]]
               set erg {}
               foreach name $names {
                  ##nagelfar ignore
                  set wert  [set ${var}(${name})]
                  append erg [list set ${var}(${name}) $wert]
                  append erg "\n"
               }
               return $erg
            } else {
               if {[info exists $var]} {
                  set erg [set $var]
               } else {
                  return {}
               }
               return "set $var $erg "
            }
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::TagShow {txtw von bis} {
            # Tags eines Textwidgets im Testling markieren
            #
            $txtw tag add inspector_testling_tag $von $bis
            $txtw tag configure inspector_testling_tag \
               -background pink -foreground black -borderwidth 1 \
               -relief solid
            $txtw see $von
            after 3000 "$txtw tag remove inspector_testling_tag 1.0 end"
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::GetCanvasProperties {canvas} {
            # liefert Id- und Tagliste eines Canvas
            #
            if {![winfo exists $canvas]} {return {}}
            set idListe  ""
            set tagListe ""
            array unset tagArray
            set ids [$canvas find all]
            foreach id $ids {
               set typ [$canvas type $id]
               set tags [$canvas gettags $id]
               lappend idListe [list $id $typ $tags]
               foreach tag $tags {set tagArray($tag) $tag}
            }
            foreach tag [array names tagArray] {
               set ids [$canvas find withtag $tag]
               set typ [$canvas type $tag]
               lappend tagListe [list $tag $typ $ids]
            }
            return [list $idListe $tagListe]
         }
         
         # --------------------------------------------------
         proc ::inspector_testling::ProcInfo {name} {
            # liefert eine selektierte Proc
            #
            if {[catch {info body $name} body ]} {
               return {}
            }
            
            set argsString "\{ "
            set args [info args $name]
            foreach argu $args {
               set hatDef [info default $name $argu __default_arg]
               if {$hatDef} {
                  set vorbel $__default_arg
                  append argsString " \{$argu "
                  if {$vorbel=={} } {
                     append argsString "\{\}\} "
                  } else {
                     append argsString " \{ $vorbel \} \} "
                  }
               } else {
                  append argsString "$argu "
               }
            }
            set procInfo "proc $name $argsString \} \{$body\n\}"
            
            # Quelle in auto_index suchen
            set nameK [string range $name 2 end] ;# Procname ohne ::
            set source "Proc $name"
            
            foreach na [list $name $nameK] {
               if {[info exists ::auto_index($na)]} {
                  set source $::auto_index($na)
                  break
               }
            }
            set erg [list $source $procInfo]
            return $erg
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::canvasRectStart {canvas} {
            # liefert IDs innerhalb eines Rechtecks
            #-----------------------------------------------------------------------
            bind $canvas <ButtonPress-1>   "::::inspector_testling::createRect %W %x %y"
            bind $canvas <B1-Motion>       "::inspector_testling::dragRect %W %x %y"
            bind $canvas <ButtonRelease-1> "::inspector_testling::endRect %W %x %y"
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::canvasRectStop {canvas} {
            # zum Aufräumen
            #-----------------------------------------------------------------------
            bind $canvas <ButtonPress-1>   ""
            bind $canvas <B1-Motion>       ""
            bind $canvas <ButtonRelease-1> ""
            catch {$canvas delete rectShape}
            catch {$canvas dtag rectShape}
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::createRect {win x y} {
            # Anfang Rechteck aufziehen
            #-----------------------------------------------------------------------
            catch {$win delete rectShape}
            $win create rect $x $y $x $y -outline black -width 2 \
               -tags rectShape
            return
         }
         #-----------------------------------------------------------------------
         proc ::inspector_testling::dragRect {win x y} {
            # Rechteck wird aufgezogen
            #-----------------------------------------------------------------------
            set coords [$win coords rectShape]
            set coords [lreplace $coords 2 3 $x $y]
            eval $win coords rectShape $coords
            return
         }
         #-----------------------------------------------------------------------
         proc ::inspector_testling::endRect {win x y} {
            # Rechteck ist fertig
            #-----------------------------------------------------------------------
            #puts [info level 0]
            
            dragRect $win $x $y
            set coords [$win bbox rectShape]
            set ids [$win find enclosed {*}$coords]
            set str ""
            foreach id $ids {
               set typ [$win type $id]
               set tags [$win gettags $id]
               if {"rectShape" in $tags } {continue}
               append str "ID:$id  Typ:$typ  Tags:$tags\n"
            }
            if {$str eq ""} {set str "---"}
            
            tk_messageBox          \
               -message $str       \
               -title Canvas-Items \
               -icon info          \
               -parent [winfo toplevel $win]
            return
         }
         #-----------------------------------------------------------------------
         proc ::inspector_testling::enterIDCanvas {canvas x y} {
            # im Baum selektieren und im Canvas flashen
            #-----------------------------------------------------------------------
            variable oldPar
            variable wTooltip
            #variable idxy
            
            set bgFlash #ff69b4
            #set idxy [$canvas find closest $x $y]
            set curr [$canvas find withtag current]
            #set idxy $curr
            set typ [$canvas type current]
            switch -- $typ {
               window - image {}
               arc     {set oldPar [$canvas itemcget current -outline]}
               bitmap  {set oldPar [$canvas itemcget current -background]}
               default {set oldPar [$canvas itemcget current -fill]}
            }
            
            switch -- $typ {
               window - image {}
               arc     {$canvas itemconfigure current -outline $bgFlash}
               bitmap  {$canvas itemconfigure current -background $bgFlash}
               default {$canvas itemconfigure current -fill $bgFlash}
            }
            # Tooltip anzeigen
            set tags [$canvas gettags current]
            set text "ID:$curr Typ:$typ  Tags:$tags"
            ::inspector_testling::toolTip $canvas on $text
            return
         }
         #-----------------------------------------------------------------------
         proc ::inspector_testling::leaveIDCanvas {canvas} {
            # im Baum selektieren und im Canvas flashen
            #-----------------------------------------------------------------------
            variable oldPar
            variable wTooltip
            #variable idxy
            
            set typ [$canvas type current]
            
            switch -- $typ {
               window - image {}
               arc     {$canvas itemconfigure current -outline $oldPar}
               bitmap  {$canvas itemconfigure current -background $oldPar}
               default {$canvas itemconfigure current -fill $oldPar}
            }
            
            # Tooltip löschen
            ::inspector_testling::toolTip $canvas off ""
            return
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::toolTip {canvas onoff text} {
            # Tooltip anzeigen oder löschen
            #-----------------------------------------------------------------------
            variable wTooltip
            # Tooltip löschen
            if {$onoff eq "off"} {
               if {[winfo exists $wTooltip]} {destroy $wTooltip}
               return
            } else {
               # Tooltip anzeigen
               catch {destroy .inspector_testling_tt}
               set tl [toplevel .inspector_testling_tt]
               wm overrideredirect $tl 1
               set xp [winfo x [winfo toplevel $canvas]]
               set yp [winfo y [winfo toplevel $canvas]]
               set xp [expr {$xp +20}]
               set yp [expr {$yp -20}]
               wm geometry $tl +$xp+$yp
               set wTooltip $tl
               
               set fr [frame $tl.fr]
               pack $fr
               set lb [label $fr.lb \
                  -foreground black \
                  -background yellow \
                  -text $text \
                  -justify left \
                  -padx 5 \
                  -relief ridge \
                  -borderwidth 2]
               pack $lb -padx 0 -pady 0 -fill "x"
            }
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::QuelleSort {} {
            # entnimmt ::auto_index die Quellen und liefert eine
            # sortierte Liste
            #-----------------------------------------------------------------------
            
            set quListe [list]
         
            foreach key [array names ::auto_index] {
               
               set qu  [lindex $::auto_index($key) 1]
              
               if {![file readable $qu]} {continue}
               
               # nicht doppelt
               if {$qu in $quListe} {continue}
               
               lappend quListe $qu
            }
            set qus [lsort $quListe]
            return $qus
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::GetQuelle {qu} {
            # liefert die Quelle
            #--------------------------------------------------------------------
            
            # Quelle lesbar ?
            if {![file readable $qu]} {
               return {Quelle nicht lesbar}
            }
            
            set FQU [open $qu]
            set inh [read $FQU]
            close $FQU
            return $inh
         }
         
         # ------------------------------------------------------------
         # ctr-shift-b2 zeigt Callback-Funktion vom sel. Widget
         # 
         proc ::inspector_testling::CBInfoCallback {} {
            set erg ""
            
            # das selektierte Widget im Testling suchen
            lassign [winfo pointerxy .] xp yp
            set win [winfo containing $xp $yp]
            if {$win eq ""} {return ""}
            
            # Widget ein Menu ?
            if {[winfo class $win] eq "Menu"} {
               # im aktiven Menubutton nach -command ?
               if {[catch {$win entrycget active -command} msg]} {
                  return ""
               }
               set erg [list [list -command $msg]]
            } else {
               # Button ComboBox CheckButton Radiobutton liefern
               # -command Option ?
               foreach opt {-command -modifycmd -postcommand -closecmd \
                     -opencmd -selectcmd -validatecommand } {
                  if {[catch {$win cget $opt} call]} {continue}
                  if {$call eq ""} {continue}
                  lappend erg [list $opt $call]
               }
               # hat das Widget bind-Kommando
               # i.a. bei Entry
               if {![catch {bind $win} events]} {
                  foreach ev $events {
                     if {[catch {bind $win $ev} call]} {continue}
                     if {$call eq ""} {continue}
                     lappend erg [list $ev $call]
                  }
               }
            }
            # Ergebnis an ased5 zurück senden
            %sendAnInspector [list CBInfoShow $erg]
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::flashWidget {class window} {
            # Widget im Testling blinkt
            # wenn kein bg oder bg leer wird state geflasht
            #--------------------------------------------------------------------
            set cfgStr  [join [$window configure] " "]
            
            # gibt es -background ?
            # Widget hat -bg -> bg flashen
            if {[string match *-background* $cfgStr] \
                  && [$window cget -background] ne ""} {
               set bg [$window cget -background]
               # manchmal 2x Aufruf
               ##   if {$bg eq "#ff69b4"} {return}
               set flashdelay 800
               $window configure -background #ff69b4
               after $flashdelay \
                  [list $window configure -background $bg]
               
               # borderwidth ändern
               if {[string match *-borderwidth* $cfgStr] \
                     && [$window cget -borderwidth] ne ""} {
                  set bd [$window cget -borderwidth]
                  set flashdelay 800
                  $window configure -borderwidth 2
                  after $flashdelay \
                     [list $window configure -borderwidth $bd]
               }
            } elseif {[string match *-style* $cfgStr]} {
               # Sonderbehandlung ttk
               set wstyle [$window cget -style]
               set kstyle ""
               #%sendAnInspector [list puts "wstyle:$wstyle"]
               if {$wstyle eq ""} {
                  # Style von der Klasse
                  set kstyle $class
               }
               if {$kstyle eq "" && $wstyle eq ""} {
                  return
               }
               #%sendAnInspector [list puts "kstyle:$kstyle"]
               # Style mit bg ergänzen
               if {$wstyle ne ""} {
                  set style $wstyle
               } else {
                  set style $kstyle
               }
               
               # bei TSrcollbar -orient beachten
               if {$class eq "TScrollbar"} {
                  set orient [$window cget -orient]
                  if {$orient eq "vertical"} {
                     set style Vertical.TScrollbar
                  } else {
                     set style Horizontal.TScrollbar
                  }
               }
               # bei TScale -orient beachten
               if {$class eq "TScale"} {
                  set orient [$window cget -orient]
                  if {$orient eq "vertical"} {
                     set style Vertical.TScale
                  } else {
                     set style Horizontal.TScale
                  }
               }
               
               #%sendAnInspector [list puts "style:$style"]
               
               ttk::style configure Flash.$style \
                  -background red \
                  -borderwidth 2
               $window configure -style Flash.$style
               set flashdelay 800
               after $flashdelay \
                  [list $window configure -style $wstyle]
            }
         }
         
         #-----------------------------------------------------------------------
         proc ::inspector_testling::traceCB {fkt wText namespace args} {
            # schreibt die Trace-Ausgaben in das Trace-Fenster
            # fkt  : cmd|var
            # wText: Tracefenster des Inspectors
            # namespace : Namespace der Variablen
            # args jeweils :
            #    var: varname item ops 
            #    var: varname {} ops
            #    cmd enter: procaufruf
            #    cmd leave: procaufruf exitStatus result
            #
            # Machmal wird die Variable mit oder ohne NS geliefert
            #----------------------------------------------------------
            set resStr "\n[clock format [clock seconds] -format {%X}] "
            if {$fkt eq "var"} {
               lassign $args varname item ops
               #%sendAnInspector \
               #   [list puts "\narg: <$args< ns :<$namespace< "]
                  
               # Varname ggf mit NS ergänzen
               set nsItem [namespace qualifiers $varname]
               if {$nsItem eq ""} {
                  set varname ${namespace}::$varname
               } else {
                  set varname $varname
               }
               
               #%sendAnInspector [list puts  "varname:<$varname>"]
               
               append resStr " <$ops> "
               append resStr "$varname"
               set vari $varname
               # Array(item)
               if {$item ne ""} {
                  append resStr "($item)"
                  set vari ${varname}($item)
               }
               
               #%sendAnInspector [list puts  "vari:$vari " ]
               # Wert vorhanden ? dann holen
               if {![info exists $vari]} {
                  append resStr " Var <$vari> not exists"
               } else {
                  append resStr " = [set $vari]"
               }
               #%sendAnInspector [list puts " res:$resStr"  ]
               
               # Caller-Proc und Parameter
               set caller   [info level 1]
               set callProc [lindex $caller 0]
               set par      [lrange $caller 1 end]
               append resStr "   in <$callProc>  "
               if {$par ne ""} {
                  append resStr "Parameter: $par\n"
               } else {
                  append resStr "\n"
               }
               
            } elseif {$fkt eq "cmd" } {
               # args Länge 2 ->enter, 4 -> leave
               if {[llength $args] == 2} {
                  #enter
                  lassign $args procname
                  append resStr "enter $procname \n"
               } elseif {[llength $args] == 4 } {
                  #leave
                  lassign $args procname status result
                  append resStr "leave $procname Status:<$status> Result: <$result> \n"
                  
               } ; # end elseif
            } else {
               set resStr "fkt <$fkt> falsch, nur var|cmd\n"
            } ; # end elseif
            
            # Ergebnis in das Trace-Fenster
            %sendAnInspector [list $wText insert end-1c $resStr]
            %sendAnInspector [list $wText see end]
         } ;# Ende traceCB
         
         # nur bei gui-Ziel
         if {[info commands winfo] ne ""} {
            bind all <Control-Shift-Button-2> \
               [list ::inspector_testling::CBInfoCallback]
            bind all <Control-Shift-Alt-Button-1> \
               [list ::inspector_testling::Show_Widget_Remote %W %X %Y ]
         }
         
      } ;# ns ::inspector_testling
      
      #-----------------------------------------------------------------------
      proc ::inspector_testling::tp {nr typ rProc args} {
         # schreibt einen Tracepunkt in das TP-Fenster
         # nr    : TP-Nr
         # typ   : var|liste|level0
         # rProc : rufende Proc
         # args  : variable (bei Typ var )
         #----------------------------------------------------------
         global gd
         
         # Tracepunkt aktiv ?
         set gefunden false
         foreach tp $::inspector_testling::tpVW {
            lassign $tp tpNr p m aktiv
            if {$tpNr == $nr && $aktiv ==1} {
               set gefunden true
               break
            }
         }
         # nicht aktiv
         if {!$gefunden} {
            return
         }
         
         set resStr "\n[clock format [clock seconds] -format {%X}] "
         append resStr "TP: $nr "
         if {$typ eq "var"} {
            lassign $args var
            upvar $var variable
            append resStr "  $rProc / $var =\n\t $variable \n"
            
         } elseif {$typ eq "level0"} {
            set lev0 [info level 1]
            append resStr "  ProcInf:\n\t$lev0 \n"
            
         }  elseif {$typ eq "liste"} {
            lassign $args var
            upvar $var variable
            append resStr "  $rProc / Liste = $var \n"
            set lp [::utils::printlistestring variable]
            append resStr "$lp\n"
         }
         
         # Ergebnis in das TP-Fenster
         catch {%sendAnInspector [list ::Tp::tpDisplay $resStr]}
      }
      
   } ;# End procTxt
   
   # Variable ersetzen
   #
   set translateStr [list \
      %sendAnInspector $gd(sendAnInspector) \
      ]
   set procTxt [string map $translateStr $procTxt]
   
   # Prozeduren zum Testling schicken
   #
   Bwsend $gd(target) [list $procTxt]
   set gd(status) "Prepare_Inspection ready"
}


#--------------------------------------------------------------------
proc ResetData {} {
   # setzt alle Daten des Ziels nach connect zurück
   # nicht bei Reconnect
   #--------------------------------------------------------------------
   global gd wv
   #_proctrace
   
   # Listen Inhalt und Filter Liste
   foreach liste $gd(listen) {
      set gd($liste,inhalt)   {}       ;# Listeninhalt
      set gd($liste,filter)   {}       ;# Filter
      set gd($liste,inclExcl) {excl}   ;# Checkbutton Include Pattern
   }
   # set gd(Global,filter) {^::.*}
   # set gd(Proc,filter)   {^tk[A-Z].*  ^auto_.*  ^::.* }
   set gd(Proc,filter)   {^::[^.] }
   set gd(Proc,inclExcl)  incl
   
   # alles mit suchen
   foreach liste {Widget Proc Global Namespace} {
      set ::inspector::lastSee($liste) -1  ;# letzte Anzeige
      set ::inspector::pattOld($liste) {}  ;# letztes Suchmuster
   }
   
   # Value Label und CBox leeren
   foreach liste {Proc Global Namespace Image Menu Canvas After Font} {
      catch {
         $wv(w,txt,val,$liste) delete 1.0 end
         $wv(w,cb,val,$liste) configure -values {}
         set wv(v,cb,val,$liste) {}
         $wv(w,lab,val,$liste) configure -text {}
      }
   }
   catch {
      $wv(w,tbl,val,Widget) delete 0 end
      $wv(w,cb,val,Widget) configure -values {}
      set wv(v,cb,val,Widget) {}
      $wv(w,lab,val,Widget) configure -text {}
      
      $wv(w,cb,val,Canvas) configure -values {}
      set wv(v,cb,val,Canvas) {}
      $wv(w,lab,val,Canvas) configure -text {}
      $wv(w,tbl,tags) delete 0 end
      $wv(w,tbl,ids)  delete 0 end
   }
   
   $wv(w,nb) raise Global
   $wv(w,nb) raise Widget
   
   # Tracepunkte
   #
   set ::Tp::tpNr -1
   set ::Tp::tpVW [list]
   
   SendSyn -- set ::inspector_testling::tpVW [list $::Tp::tpVW]
   
   
}
