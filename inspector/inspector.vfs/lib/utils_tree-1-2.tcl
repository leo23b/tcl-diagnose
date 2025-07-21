## -*-Tcl-*-
   # ###################################################################
   #
   #  FILE: "utils_tree.tcl"
   #                                    created: 2009-12-20 21:57:51
   #  Description:
   #    Allgemeine Tree-spezifische Module
   #
   #
   #  History
   #
   #  modified   by   rev      reason
   #  ---------- ---- -----    -----------
   #  2013-03-08 mlrd 1.2      dbg ->LOG l_assign, spez Fkt entfernt
   #  2010-02-06 mlrd 1.0      Erstfassung
   # ###################################################################
   ##
#----------------------------------------------------------

 ##
  # -------------------------------------------------------------------------
  #
  # ToStack --
  #
  #   legt ein Element auf den Stack
  #
  # Argument     Default In/Out Description
  # ------------ ------- ------ ---------------------------------------------
  # stackVar        obl    in   Variable Stack
  # elem            obl    in   Element für den Stack
  #
  # Results:
  #  -
  #
  # Side effects:
  #  im Stack wird das Element am Ende angefügt
  # -------------------------------------------------------------------------
  ##
proc ToStack {stackVar elem} {
   
   upvar $stackVar stack
   
   if {![info exists stack]} {
      return -code error "Variable $stackVar exist. nicht"
   }
   
   lappend stack $elem
}

 ##
  # -------------------------------------------------------------------------
  #
  # FromStack --
  #
  #   holt ein Element vom Stack
  #
  # Argument     Default In/Out Description
  # ------------ ------- ------ ---------------------------------------------
  # stackVar        obl    in   Variable Stack
  #
  # Results:
  #  element
  #
  # Side effects:
  #  Stack wird das Element am Ende gekürzt
  # -------------------------------------------------------------------------
  ##
proc FromStack {stackVar } {
   
   upvar $stackVar stack
   
   if {![info exists stack]} {
      return -code error "Variable $stackVar exist. nicht"
   }
   set elem [lindex $stack end]
   set stack [lrange $stack 0 end-1]
   return $elem
}

## 
 # -------------------------------------------------------------------------
 # 
 # "TreePopup" --
 # 
 #  Kreiert beim ersten Aufruf das Menü und legt die 
 #  Aufrufparameter (TreeWidget und Knoten) global ab.
 #  Zeigt popup_Fenster mit Menü an und ruft Funktion auf.
 # 
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # wTree        --      in     Widget Tree
 # node         --      in     Name selektierter Knoten
 #  
 # Results:
 #  keine
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc TreePopup {wTree node } {
   global gd 
   #_proctrace
   
   set gd(popupTree) $wTree
   set gd(popupNode) $node
      
   set x [winfo pointerx .]
   set y [winfo pointery .]
   catch {destroy .menubar}
   set menubar [menu .menubar -tearoff 0]
	#set nodeTxt [$wTree itemcget $node -text]
   set pfD  {}
   set pfLZ {}
	lassign [split [$wTree itemcget $node -data] {|}] datum zeit art pfI
   if {$art == {A}} {
      if {$pfI != {FPM-Datei splitten}} {
         ##nagelfar ignore
      	lassign [ParseFilename $pfI] dtI it ft ext bkv j m t  
         if {$bkv != {alle_bkv}} {
        #    set pfD [GetArvPf $dtI $ft $bkv $t.$m.$j]
        #    if {![file readable $pfD]} {set pfD {}}
        #    set pfLZ [GetLZPf $dtI $it $ft $bkv $t.$m.$j]
        #    if {![file readable $pfLZ]} {set pfLZ {}}
         }
      }
   }
   if {$pfD != {}} {
		$menubar add command -label {Daten anzeigen} \
		  -command [list CBTreeMenuAnz $pfD daten]
      $menubar add separator
   }
   if {$pfLZ != {}} {
      $menubar add command -label {LZ anzeigen} \
		 -command [list CBTreeMenuAnz $pfLZ lz]
      $menubar add separator
   }
   $menubar add command -label Aufklappen -command {nodeFkts opentree}
   $menubar add command -label Zuklappen  -command {nodeFkts closetree}
   $menubar add separator
   $menubar add command -label Suchen \
      -command [list suchAlle $wTree $node]
   $menubar add command -label {Fehler suchen}    \
      -command [list suchAlle $wTree $node {|F|}]
   $menubar add command -label {Warnung suchen}   \
      -command [list suchAlle $wTree $node {|W|}]
   $menubar add command -label {Ums unv suchen}   \
      -command [list suchAlle $wTree $node {|U|}]
   $menubar add separator
   $menubar add command -label KnotenInfo -command {getNodeOpts}
   
   tk_popup .menubar  $x $y
}


## 
 # -------------------------------------------------------------------------
 # 
 # "nodeFkts" --
 # 
 #  Verteiler für Knotenfunktionen. Wird von callPopup
 #  aufgerufen.
 # 
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # fkt          --      in     Hauptfunktion
 # args         --      in     variable Anzahl Argumente
 # Results:
 #  keine
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc nodeFkts {fkt args} {
   global gd

   set tree $gd(wTree)
   set node $gd(popupNode)

   switch -- $fkt {
		opentree -
      closetree -
      delete   {$tree $fkt $node}
   
      selection {
                  set subfkt [lindex $args 0]
                  switch --  $subfkt {
                     add -
                     remove {$tree selection $subfkt $node}
                     clear  {$tree selection $subfkt}
                     default {puts "F-Switch subfkt $subfkt"}              
                  }
      }
      default {puts "F-Switch fkt:$fkt"}
            
   }
}
## 
 # -------------------------------------------------------------------------
 # 
 # "getKinder" --
 # 
 #  liefert die Kinder zu einem Knoten
 # -------------------------------------------------------------------------
 ##
proc getKinder {tree node} {
   if {[$tree exists $node]} {
      return [$tree nodes $node 0 end]
   } else {
      return {}
   }
}

## 
 # -------------------------------------------------------------------------
 # 
 # "getNodeFromData" --
 # 
 #  sucht node nach gegebenem data-Wert.
 #  Das Suchmuster kann exakt oder mit Wildcards angegeben
 #  werden. Dann wird ein oder mehrere Knoten geliefert.
 #  Bsp: suchtext: 'emil'  oder 'emil*text'
 # 
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # tree         --      in     Widget
 # anker        root    in     Suchanker 
 # suchtext     --      in     Suchmuster für -data
 # reset        --      in     Ergebnis normieren 1|0  (def 1)
 #
 # Results:
 #  Knotenliste
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc getNodeFromData {tree anker suchtext {reset {1}} } {
   variable erg
   if {$reset} {
      set erg {}
      #puts "erg norm."
   }
#puts "getNode kin: $anker erg: $erg"   
   if {$anker == {}} {
     set anker {root1}
   }

   # zuerst den anker  prüfen
   set data [$tree itemcget $anker -data]
   if {[string match -nocase $suchtext $data]} {
      lappend erg $anker
   } 

   # nun die Kinder und Enkel
   set kinder [getKinder $tree $anker]
   foreach kind $kinder {
#puts "   kind:$kind"
      set enkels [getKinder $tree $kind]
      if {$enkels!={}} {
         foreach enkel $enkels {
            getNodeFromData $tree $enkel $suchtext 0
         }
      } else {            
         if {[$tree exists $kind]} {
           set data [$tree itemcget $kind -data]
   #puts "    $kind $data $suchtext"
              if {[string match -nocase $suchtext $data]} {
                  lappend erg $kind
              } 
         }
      }
   }
#puts "ende :$erg"
   return $erg
}

## 
 # -------------------------------------------------------------------------
 # 
 # "getNodeFromText" --
 # 
 #  sucht node nach gegebenem text-Wert.
 #  Das Suchmuster kann exakt oder mit Wildcards angegeben
 #  werden. Dann wird ein oder mehrere Knoten geliefert.
 #  Bsp: suchtext: 'emil'  oder 'emil*text'
 # 
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # tree         --      in     Widget
 # anker        root    in     Suchanker 
 # suchtext     --      in     Suchmuster für -data
 # reset        --      in     Ergebnis normieren 1|0  (def 1)
 #
 # Results:
 #  Knotenliste
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc getNodeFromText {tree anker suchtext {reset {1}} } {
   variable erg
   if {$reset } {
      set erg {}
      #puts "erg norm."
   }
   #puts "getNode kin: $anker erg: $erg"   
   if {$anker == {}} {
     set anker {root1}
   }

   # zuerst den anker  prüfen
   set data [$tree itemcget $anker -text]
   if {[string match -nocase $suchtext $data]} {
      lappend erg $anker
   } 

   # nun die Kinder und Enkel
   set kinder [getKinder $tree $anker]
   foreach kind $kinder {
      #puts "   kind:$kind"
      set enkels [getKinder $tree $kind]
      if {$enkels!={}} {
         foreach enkel $enkels {
            getNodeFromText $tree $enkel $suchtext 0
         }
      } else {            
         if {[$tree exists $kind]} {
           set data [$tree itemcget $kind -text]
            #puts "    $kind $data $suchtext"
              if {[string match -nocase $suchtext $data]} {
                  lappend erg $kind
              } 
         }
      }
   }
   #puts "ende :$erg"
   return $erg
}

#----------------------------------------------------------
#  callPopup:
#  zeigt Popup-Fenster an
#  wTree :  Widget Tree
#  node  :  Node unter Cursor
#-----------------------------------------------------------
## 
 # -------------------------------------------------------------------------
 # 
 # "callPopup" --
 # 
 #  Kreiert beim ersten Aufruf das Menü und legt die 
 #  Aufrufparameter (TreeWidget und Knoten) global ab.
 #  Zeigt popup_Fenster mit Menü an und ruft Funktion auf.
 # 
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # wTree        --      in     Widget Tree
 # wEntry       --      in     Widget Eingabe Suchtext
 # node         --      in     Name selektierter Knoten
 #  
 # Results:
 #  keine
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc callPopup {wTree wEntry node } {
   global gd 
   set gd(wTree) $wTree
   set gd(popupNode) $node
   #_proctrace
      
   set x [winfo pointerx .]
   set y [winfo pointery .]
   
   if {![winfo exists .menubar]} {
      set menubar [menu .menubar -tearoff 0]
      $menubar add command -label Aufklappen -command [list nodeFkts opentree]
      $menubar add command -label Zuklappen  -command [list nodeFkts closetree]
      $menubar add separator
      $menubar add command -label Suchen -command [list suchAlle $wEntry ]
      $menubar add command -label Sortieren -command [list sortKinder ]
      $menubar add separator
      $menubar add command -label {Update this list} -command \
         [list updateListe widgets  ]
      $menubar add command -label Manual -command [list ShowManual]
      $menubar add separator
      $menubar add command -label NodeInfo -command [list getNodeOpts ]
   }
   tk_popup .menubar  $x $y
}

## 
 # -------------------------------------------------------------------------
 # 
 # "getNodeOpts" --
 # 
 #  protokolliert die Konfigurationsparameter
 #  des selektierten Knotens (Testfunktion)
 # -------------------------------------------------------------------------
 ##
proc getNodeOpts {} {
   global gd
   
   set tree $gd(wTree)
   set node $gd(popupNode)
   
   set info {}
   append info "Node: $node\nOptionen:\n"
   set opts [$tree itemconfigure $node]
   foreach opt $opts {
      set qual  [lindex $opt 0]
      set value [lindex $opt 4]
      append info "\t$qual $value\n"
   }
  ## TopText $gd(wTop) $info KnotenInfo
}


## 
 # -------------------------------------------------------------------------
 # 
 # "sortKinder" --
 # 
 #  sortiert die Kinder eines Knotens nach Knoten und Blätter und darin
 #  wieder alphabetisch.
 #  Es werden nur Kinder sortiert die angezeigt sind, d.h. vorher ggf
 #  aufklappen.
 # -------------------------------------------------------------------------
 ##
proc sortKinder {} {
    global gd
 
    set tree  $gd(wTree) 
    set vater $gd(popupNode) 
    #puts "sort $vater"
    set kinder [$tree nodes $vater 0 end]
    
    # Knoten und Blätter trennen
    set knoten   {}
    set blaetter {}
    foreach kind $kinder {
        if {[llength [$tree nodes $kind 0 end]]!=0} {
            lappend knoten $kind
        } else {
            lappend blaetter $kind
        }         
    }
    #puts "knoten:$knoten\nblätter:$blaetter"
    
    # Knoten und Blätter in Hash speichern
    foreach blatt $blaetter {
        set hBlaetter([$tree itemcget $blatt -data]$blatt) $blatt
    }
    foreach knot $knoten {
        set hKnoten([$tree itemcget $knot -data]$knot) $knot
    }
    
    #
    # Knoten und Blätter sortieren
    set newOrder {}
    foreach key_kn [lsort [array names hKnoten]] {
        lappend newOrder $hKnoten($key_kn)
    }
    foreach key_bl [lsort [array names hBlaetter]] {
        lappend newOrder $hBlaetter($key_bl)
    }
    $tree reorder $vater $newOrder
}


## 
 # -------------------------------------------------------------------------
 # 
 # "insertNode" --
 # 
 #  trägt einen Knoten (ohne Kinder) ein. Wird von dispTree und moddir
 #  (zum Knoten aufklappen) gerufen.
 #  Der Knotenname wird synth. gebildet, n:lfdNr .
 #  Das Kreuz wird auf 'immer' gesetzt, 
 #  damit es aufgeklappt werden kann.
 #  
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # tree         --      in     Widget Tree
 # textRoot     --      in     Text für Rootnode
 # dataRoot     --      in     Data für Rootnode
 # text         --      in     Text für Node
 # data         --      in     Data für Node
 # 
 # Results:
 #  Nodename
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc insertNode {tree textRoot dataRoot text data} {
   global gd

   # ggf obersten Knoten eintragen
   if {![$tree exists root1]} {
       $tree insert end root root1 \
           -text      $textRoot \
           -image     $gd(folder) \
           -drawcross allways   \
           -data      $dataRoot  \
           -open      0         
   } 

   if {![info exists gd(nodeCount)]} {
      set gd(nodeCount) 0
   }
   set image $gd(folder)
   set cross {allways}
   $tree insert end root1 n:$gd(nodeCount) \
       -text      $text \
       -image     $image \
       -drawcross allways \
       -data      $data  
   incr gd(anzNodes)
   return n:$gd(nodeCount)
}
## 
 # -------------------------------------------------------------------------
 # 
 # "getNodeText" --
 # 
 #  liefert den Text zu einem Knoten
 # -------------------------------------------------------------------------
 ##
proc getNodeText {tree node} {
      return [$tree itemcget $node -text]
}
## 
 # -------------------------------------------------------------------------
 # 
 # "getNodeData" --
 # 
 #  liefert Data zu einem Knoten
 # -------------------------------------------------------------------------
 ##
proc getNodeData {tree node} {
      return [$tree itemcget $node -data]
}
## 
 # -------------------------------------------------------------------------
 # 
 # "moddir" --
 # 
 #  klappt den Knoten auf und zu. Beim ersten Aufklappen
 #  (Kreuz=='allways') werden die Kinder eingetragen, sonst
 #  wird nur das Symbol auf- und zugeklappt (bei Knoten)
 # 
 # Argument     Default In/Out Description
 # ------------ ------- ------ ---------------------------------------------
 # fkt          --      in     Funktion 1:öffnen 0:schliessen
 # tree         --      in     Widget Tree
 # node         --      in     Kontenname
 # 
 # Results:
 #  keine
 # 
 # Side effects:
 #  keine
 # -------------------------------------------------------------------------
 ##
proc moddir { fkt tree node } {
   global gd wv

   SetClock on $wv(w,top)
   update idletasks
   if { $fkt  } {
        insertChildren $tree $node 
        $tree itemconfigure $node -drawcross auto
        if { [llength [$tree nodes $node]] } {
           $tree itemconfigure $node -image $gd(openfolder)
        } else {
           $tree itemconfigure $node -image $gd(leaf)
        }
   } else {
      if { [llength [$tree nodes $node]] } {
         if {$fkt=={1}} {
            set image $gd(openfolder)
         } else {
            set image $gd(folder)
         }
         $tree itemconfigure $node -image $image                  
      }         
   }
   SetClock off $wv(w,top)
   update idletasks
}
#------------------------------------------------------------------------------
proc make_tree {p} {
#  erzeugt Baum 
#------------------------------------------------------------------------------
   global gd wv

   #..................................................
   # ScrolledWindow für den Tree
   #
   set sw [ScrolledWindow $p.sw  -relief ridge -borderwidth 2]
          
   set wTree            \
      [Tree $sw.tree    \
         -deltay 20     \
         -relief flat   \
         -borderwidth 0 \
         -width 15      \
         -highlightthickness 0 \
         -redraw 1      \
         -dropenabled 1 \
         -dragenabled 1 \
         -dragevent 2   \
         -draginitcmd draginitCmd   \
         -dragendcmd  dragendCmd   \
         -dropovercmd dropOverCmd \
         -opencmd   "moddir  1  $sw.tree" \
         -closecmd  "moddir  0  $sw.tree" \
         -droptypes {TREE_NODE {copy {} move {} link {}}} \
       ]
   $sw setwidget  $wTree
   set wv(w,tree) $wTree

   # Muster
   #$wTree bindText  <Button-1> "SelectTabelle $wTree"
   #$wTree bindImage <Button-1> "SelectTabelle $wTree"

   pack $sw -fill both -padx 3 -pady 3 -expand yes
   return $wTree
}