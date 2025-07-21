## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "canvas.tcl"
 #  Description:
 #  enthält Proz. zum Thema canvas
 #
 # ###################################################################

namespace eval Canvas {
   variable canvasArr ;# keys:idORtag,typ|tagsORids
   variable allIDs  {}
   variable allTags {}
   
   #-----------------------------------------------------------------------
   proc displayTree {{canvas {}}} {
      # zeigt doppelten Baum mit ID und Tags
      #-----------------------------------------------------------------------
      #_proctrace
      global wv
      variable canvasArr
      variable allIDs
      variable allTags
      
      set lb $wv(w,lb,Canvas)
      set sel [$lb selection get]
      if {$sel=={}} {
         ::utils::gui::msg info Hinweis "Canvas in Liste selektieren!" $lb
         return
      }
      set canvas [$lb itemcget $sel -text]
      _leer $canvas return
      ::utils::gui::setClock on $wv(w,top)
      
      fillCanvasArr $canvas
      
      # Gui 2 Tree
      #
      set top [::widgets::tw $wv(w,top).cantree \
         -titel "IDTree $canvas" \
         -buttonbox 0]
      set p [$top winfo frame]
      
      set erg [::utils::gui::mkPanedWindow "wv" $p "" \
         -wts {1,1}\
         -richt |]
      lassign $erg pw flinks frechts
      pack $pw -padx 0 -pady 0 -fill both -expand yes -side "top"
      
      # Baum links tag -> id
      #
      set labID [label $flinks.labID -text "Tags -> IDs" -bd 2 \
         -relief ridge]
      pack $labID -padx 3 -pady 3 -fill x -side "top"

      set labTags [label $frechts.labTags -text "IDs -> Tags" -bd 2 \
         -relief ridge]
      pack $labTags -padx 3 -pady 3 -fill x -side "top"

      set idTree  [createTree $frechts]
      set allIDs [lsort -index 0 -dictionary $allIDs]
      foreach id $allIDs {
         #set tags $canvasArr($id,tagsORids)
         set typ  $canvasArr($id,typ)
         set parent [insertNode $idTree $canvas $id $typ]
      }
      
      set tagTree [createTree $flinks]
      set allTags [lsort -index 0 -dictionary $allTags]
      foreach tag $allTags {
         #set ids $canvasArr($tag,tagsORids)
         set typ $canvasArr($tag,typ)
         set parent [insertNode $tagTree $canvas $tag $typ]
      }
      ::utils::gui::setClock off $wv(w,top)
      return
      #Resulttrace
   }
   #-----------------------------------------------------------------------
   proc insertChildren {tree parent} {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      global wv gd
      variable canvasArr
      
      set data [$tree itemcget $parent -data]
      lassign $data canvas idORtag typ
      set idsTags $canvasArr($idORtag,tagsORids)
      foreach tag $idsTags {
         $tree insert end $parent n:$gd(nodeCount) \
            -text  "$tag ($typ)"   \
            -image [::utils::gui::ic 16 unchecked] \
            -data  [list $canvas $tag $typ]
         incr gd(nodeCount)
      }
      return
      #Resulttrace
   }
   
   # -------------------------------------------------------------------------
   #  klappt den Knoten auf und zu. Beim Aufklappen
   #  wird das Symbol auf- und zugeklappt (bei Knoten)
   # ------------ ------- ------ ---------------------------------------------
   # fkt          --      in     open|close
   # tree         --      in     Widget Tree
   # node         --      in     Kontenname
   # -------------------------------------------------------------------------
   proc modTree { fkt tree node} {
      global gd wv
      
      update idletasks
      if { $fkt eq "open" } {
         insertChildren $tree $node
         $tree itemconfigure $node -drawcross auto
         if { [llength [$tree nodes $node]] } {
            $tree itemconfigure $node -image [::utils::gui::ic 16 openFolder]
         } else {
            $tree itemconfigure $node -image [Bitmap::get file]
         }
      } else {
         if { [llength [$tree nodes $node]] } {
            if {$fkt=={1}} {
               set image [::utils::gui::ic 16 openFolder]
            } else {
               set image [::utils::gui::ic 16 clsdFolder]
            }
            $tree itemconfigure $node -image $image
         }
      }
      update idletasks
   }
   #------------------------------------------------------------------------------
   proc createTree {p} {
      #  erzeugt ID- und TagBaum
      #------------------------------------------------------------------------------
      global gd wv
      
      set sw [ScrolledWindow $p.sw  -relief ridge -borderwidth 2]
      set wTree [Tree $sw.tree \
         -deltay 20     \
         -relief flat   \
         -borderwidth 0 \
         -width 15      \
         -highlightthickness 0 \
         -redraw 1      \
         -opencmd   "::Canvas::modTree open $sw.tree"  \
         -closecmd  "::Canvas::modTree close $sw.tree" \
         ]
      $sw setwidget  $wTree
      
      $wTree bindImage  <Button-1> "::Canvas::flashID -tree $wTree -node "
      $wTree bindText   <Button-1> "::Canvas::flashID -tree $wTree -node "
      $wTree bindImage  <Button-3> "::Canvas::popup $wTree"
      $wTree bindText   <Button-3> "::Canvas::popup $wTree"
      
      pack $sw -fill both -padx 3 -pady 3 -expand yes
      return $wTree
   }
   # -------------------------------------------------------------------------
   #  trägt einen Knoten (ohne Kinder) ein.
   #  Der Knotenname wird synth. gebildet, n:lfdNr .
   #  Das Kreuz wird auf 'immer' gesetzt,
   #  damit es aufgeklappt werden kann.
   # ------------ ------- ------ ---------------------------------------------
   # tree         --      in     Widget Tree
   # text         --      in     Text für Node
   # data         --      in     Data für Node
   #
   # Results:Nodename
   # -------------------------------------------------------------------------
   proc insertNode {tree canvas id typ} {
      global gd
      set image [::utils::gui::ic 16 clsdFolder]
      
      # ggf obersten Knoten eintragen
      if {![$tree exists root1]} {
         $tree insert end root root1 \
            -text      Wurzel \
            -image     $image \
            -drawcross always \
            -data      Wurzel \
            -open      1
      }
      
      if {![info exists gd(nodeCount)]} {
         set gd(nodeCount) 0
      }
      set cross {allways}
      $tree insert end root1 n:$gd(nodeCount) \
         -text      "$id ($typ)" \
         -image     $image \
         -drawcross always \
         -data      [list $canvas $id $typ]  \
         -open 0
      set pa n:$gd(nodeCount)
      incr gd(nodeCount)
      
      return $pa
   }
   #-----------------------------------------------------------------------
   proc flashID {args} {
      # ID im Canvas flashen
      # Aufruf: B1- im Tree und B1 in TBL
      # args: -tree tree -node node
      # args: -canvas canvas -id id
      #-----------------------------------------------------------------------
      #_proctrace
      variable canvasArr
      set flashdelay {200}
      set bgFlash #ff69b4
      ::Opt::opts "par" $args {
         { -tree     {}    "Treewidget" }
         { -node     {}    "Treenode" }
         { -canvas   {}    "Canvaswidget" }
         { -id       {}    "CanvasID" }
      }
      set tree  $par(-tree)
      set node  $par(-node)
      set canvas  $par(-canvas)
      set id      $par(-id)
      
      if {$tree ne ""} {
         set data [$tree itemcget $node -data]
         lassign $data canvas id typ
      }
      
      set typ $canvasArr($id,typ)
      switch -- $typ {
         window - image {}
         arc     {set oldPar [SendSyn -- $canvas itemcget $id -outline]}
         bitmap  {set oldPar [SendSyn -- $canvas itemcget $id -background]}
         default {set oldPar [SendSyn -- $canvas itemcget $id -fill]}
      }
      
      switch -- $typ {
         window - image {}
         arc     {SendSyn -- $canvas itemconfigure $id -outline $bgFlash}
         bitmap  {SendSyn -- $canvas itemconfigure $id -background $bgFlash}
         default {SendSyn -- $canvas itemconfigure $id -fill $bgFlash}
      }
      
      switch -- $typ {
         window - image {}
         arc     {SendSyn -- after $flashdelay [list $canvas itemconfigure $id -outline [list $oldPar]]}
         bitmap  {SendSyn -- after $flashdelay [list $canvas itemconfigure $id -background [list $oldPar]]}
         default {SendSyn -- after $flashdelay [list $canvas itemconfigure $id -fill [list $oldPar]]}
      }
      
      return
   }
   
   #-----------------------------------------------------------------------
   proc canvasIDInRect {startstop} {
      # zeigt IDs innerhalb eines Rechtecks
      # Start : zum Einrichten
      # Stop  : zum Aufräumen
      #-----------------------------------------------------------------------
      global wv
      set lb $wv(w,lb,Canvas)
      set sel [$lb selection get]
      if {$sel=={}} {
         ::utils::gui::msg info Hinweis "Canvas in Liste selektieren!" $lb
         return
      }
      set canvas [$lb itemcget $sel -text]
      _leer $canvas return

      SendSyn -- ::inspector_testling::canvasRect$startstop $canvas
   }

   #-----------------------------------------------------------------------
   proc enterID {StartStop} {
      # mit b1 Canvas markieren
      # StartStop : Start|Stop 
      #-----------------------------------------------------------------------
      #_proctrace
      global wv
      # 
      set lb $wv(w,lb,Canvas)
      set sel [$lb selection get]
      if {$sel=={}} {
         ::utils::gui::msg info Hinweis "Canvas in Liste selektieren!" $lb
         return
      }
      set canvas [$lb itemcget $sel -text]
      _leer $canvas return

      if {$StartStop eq "Start"} {
         SendSyn -- $canvas addtag inspector_testling all
         SendSyn -- $canvas bind inspector_testling <Enter> \
            \"::inspector_testling::enterIDCanvas %W %x %y\"
         SendSyn -- $canvas bind inspector_testling <Leave> \
            \"::inspector_testling::leaveIDCanvas %W \"
      } else {
         SendSyn -- $canvas dtag inspector_testling 
         SendSyn -- $canvas bind inspector_testling <Enter> ""
         SendSyn -- $canvas bind inspector_testling <Leave> ""
      }
      return 
   }
   
   #-----------------------------------------------------------------------
   proc popup {tree node} {
      #
      #-----------------------------------------------------------------------
      #_proctrace
      global
      variable
      
      set x [winfo pointerx .]
      set y [winfo pointery .]
      
      catch {destroy .menubar}
      set menubar [menu .menubar -tearoff 0]
      $menubar add command -label "Konfiguration einer ID" \
         -command [list ::Canvas::showConfig -tree $tree -node $node]
         
      #$menubar add command -label Aufklappen -command [list $tree opentree $node 0]
      #$menubar add command -label Zuklappen  -command [list $tree closetree $node 0]
      #$menubar add separator
      
      tk_popup .menubar  $x $y
      return
   }
      #-----------------------------------------------------------------------
      proc showConfig {args} {
         # ConfigItems einer ID anzeigen, mit dyn Notebook, sendefähig
         # wird vom Tree- oder tbl-Popup gerufen
         # args: -tree tree -node node
         # args: -canvas canvas -id id
         #-----------------------------------------------------------------------
         #_proctrace
         global wv gd
         variable canvasArr
         
         ::Opt::opts "par" $args {
            { -tree     {}    "Treewidget" }
            { -node     {}    "Treenode" }
            { -canvas   {}    "Canvaswidget" }
            { -id       {}    "CanvasID" }
         }
         set tree  $par(-tree)
         set node  $par(-node)
         set canvas  $par(-canvas)
         set id      $par(-id)
         
         if {$tree ne ""} {
            set data [$tree itemcget $node -data]
            lassign $data canvas id typ
         }
         
         set tags $canvasArr($id,tagsORids)
         set typ $canvasArr($id,typ)
         set result {; # }
         append result " Tag/ID:\t$id Object:\t$typ Tag/IDs:\t$tags\n"
         append result "$canvas itemconfigure $id"
         foreach spec [SendSyn -- $canvas itemconfigure $id] {
            append result " \\\n\t[lindex $spec 0] [list [lindex $spec 4]]"
         }
         append result "\n"
         
         # Notebook mit dyn. Register
         #
         set p $wv(w,top)
         set zielOP [string tolower $gd(target)]
         regsub -all {\.} $zielOP {_} zielOP
         regsub -all { }  $zielOP {_} zielOP
         set top "$p.${zielOP}_canvas"
         
         if {![winfo exists $top]} {
            toplevel $top
            wm title $top "Canvas-Items <$gd(target)>"
            wm geometry $top 500x500
            
            set nb [::utils::gui::mkNoteBook wv $top "" -homogeneous 0]
            pack $nb -padx 3 -pady 3 -fill both -expand 1
            set wv(w,nb,canvas,$gd(target)) $nb
            $nb bindtabs <ButtonRelease-3> [list ValueTLClose $nb ]
            
         } else {
            set nb $wv(w,nb,canvas,$gd(target))
            wm deiconify $top
            raise $top
         }
         set tabName $id
         set tabNrn [$nb pages]
         
         # tab schon da ?
         foreach nr $tabNrn {
            set name [$nb itemcget $nr -text]
            if {$tabName eq $name} {
               $nb raise $nr
               return
            }
         }
         
         # neuer Tab einfügen
         incr gd(dynTabNr)
         set tabNr $gd(dynTabNr)
         $nb insert end $tabNr -text $tabName
         
         set fr [$nb getframe $tabNr]
         
         # Tasten
         set fb [frame $fr.bb -relief ridge -borderwidth 2 \
            -background skyBlue1]
         pack $fb -padx 3 -pady 3 -fill x -expand 0 -side bottom
         
         set lb [::utils::gui::mkLabel wv $fr "" -relief sunken]
         pack $lb -padx 3 -pady 3 -fill x -expand 0
         
         set txt [::utils::gui::mkText wv $fr "" -wrap none -background white]
         # bind $txt <ButtonPress-3> [list PopupValue %W %x %y]
         
         set bt1 [::utils::gui::mkButton wv $fb "" \
            -image [::utils::gui::ic 22 go-next] \
            -borderwidth 0 -relief groove \
            -command [list ValueTLEval $tabName $txt] \
            -helptext "Registerlasche zum Ziel senden" \
            -background skyBlue1]
         pack $bt1 -padx 3 -pady 3 -side right
         
         set btexit [::utils::gui::mkButton wv $fb "" \
            -image [::utils::gui::ic 22 edit-delete] \
            -borderwidth 0 -relief groove \
            -command [list destroy $top] \
            -background skyBlue1]
         pack $btexit -padx 3 -pady 3 -side left
         
         # Value einfügen
         $txt insert end $result
         $nb raise $tabNr
         
         # Label setzen
         set text "Canvas $canvas"
         $lb configure -textvariable {}
         $lb configure -text $text
         return
      }
  
   
 
   #-----------------------------------------------------------------------
   proc tblCanvas {canvas} {
      # listet alle ID und Tags des sel. Canvas als doppelte Tabelle
      #-----------------------------------------------------------------------
      global wv
      variable canvasArr
      variable allIDs
      variable allTags
      
      set lab $wv(w,lab,val,Canvas)
      $lab configure -text ""
      
      # Canvasproperties von Target
      #
      fillCanvasArr $canvas
      
      set item $canvas
      set p $wv(fr,fu,Canvas)
      catch {destroy $p.fr}
      set p [frame $p.fr -relief flat -borderwidth 0]
      pack $p -padx 3 -pady 3 -fill both -expand 1 -side top
      
      set erg [::utils::gui::mkPanedWindow "wv" $p "" \
         -wts {1,1} \
         -richt |]
      lassign $erg pw flinks frechts
      pack $pw -padx 0 -pady 0 -fill both -expand yes
      $flinks configure -relief ridge -bd 2
      $frechts configure -relief ridge -bd 2
      
      # links TagTbl, rechts IDTbl
      set labL [Label $flinks.lab \
         -text   "Alle Tags"      \
         -font   TkHeadingFont    \
         -relief ridge ]
      pack $labL -padx 3 -pady 3 -fill x
      
      set tagTbl [::utils::gui::mkTable "wv" $flinks "tbl,tags" \
         -namen {Tag Object IDs}]
      
      set labR [Label $frechts.lab \
         -text   "Alle IDS "       \
         -font   TkHeadingFont     \
         -relief ridge ]
      pack $labR -padx 3 -pady 3 -fill x
      
      set idsTbl [::utils::gui::mkTable "wv" $frechts "tbl,ids" \
         -namen {ID Object Tags}]
      bind  [$tagTbl bodypath] <Button-3> \
         [list ::Canvas::popupTbl %W %x %y $canvas]
      bind  [$idsTbl bodypath] <Button-3> \
         [list ::Canvas::popupTbl %W %x %y $canvas]
         
      bind [$tagTbl bodypath] <ButtonRelease-1> \
         [list ::Canvas::b1Tbl %W %x %y $canvas]
         
      bind [$idsTbl bodypath] <ButtonRelease-1> \
         [list ::Canvas::b1Tbl %W %x %y $canvas]
         
      bind [$tagTbl bodypath] <Double-ButtonRelease-1> \
         [list ::Canvas::doubleB1Tbl %W %x %y $canvas]
      bind [$idsTbl bodypath] <Double-ButtonRelease-1> \
         [list ::Canvas::doubleB1Tbl %W %x %y $canvas]
      
      set liste [list]
      foreach tag $allTags {
         set object $canvasArr($tag,typ)
         set ids $canvasArr($tag,tagsORids)
         
         # zuviele Ids in Spalte > BadAlloc
         set lenIds [llength $ids]
         if {$lenIds >10} {
            set ids "[lrange $ids 0 10] ..."
         }
         lappend liste [list $tag $object $ids]
      }
      # nach Tag sortieren
      set liste [lsort -index 0 -dictionary $liste]
      $tagTbl delete 0 end
      $tagTbl insertlist end $liste
      
      set liste [list]
      foreach id $allIDs {
         set object $canvasArr($id,typ)
         set tags $canvasArr($id,tagsORids)
         lappend liste [list $id $object $tags]
      }
      
      # nach ID sortieren
      set liste [lsort -index 0 -dictionary $liste]
      $idsTbl delete 0 end
      $idsTbl insertlist end $liste
      
      # in ComboBox Value eintragen
      #
      set wCbValue $wv(w,cb,val,Canvas)
      set vals [$wCbValue cget -values]
      if {"Canvas $item" ni $vals} {
         $wCbValue configure -values [lappend vals "Canvas $item"]
      }
      set wv(v,cb,val,Canvas) "Canvas $item"
      
      # Label setzen
      set text "Canvas - $item"
      $lab configure -textvariable {}
      $lab configure -text $text
      
      return
   }
   
  #------------------------------------------------------------------
   proc popupTbl {tbl_body x y canvas} {
      # Popup anzeigen über Tabelle Tags oder IDs
      #-----------------------------------------------------------------------
      
      set tbl [winfo parent $tbl_body]
      lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
      if {$zeile == -1} {return}
      
      set xp [winfo pointerx .]
      set yp [winfo pointery .]
      
      set id [$tbl cellcget $zeile,0 -text]
      
      # Menu
      set menuName .tblMenu
      catch {destroy $menuName}
      set menubar [menu $menuName -tearoff 0 \
         -borderwidth 3 -relief groove]
      
      
      $menubar add command -label "Konfiguration ID/Tag" \
         -command [list ::Canvas::showConfig -canvas $canvas -id $id]
      $menubar add separator
      $menubar add command -label {Spaltenanzeige... } \
         -command [list ::utils::gui::Spaltenanzeige $tbl $zeile]
      $menubar add command -label { suchen... } \
         -command [list ::utils::suchen::findDialog $tbl [$tbl bodypath]]
      $menubar add command -label { drucken... } \
         -command [list ::utils::drucken::druckDialog $tbl $tbl]
      $menubar add command -label { export... } \
         -command [list ::utils::drucken::exportDialog $tbl $tbl]
      
      tk_popup $menubar  $xp $yp
   }
     
   #-----------------------------------------------------------------------
   proc b1Tbl {tblbody x y canvas} {
      # B1-Release in TBL -> flashID
      #-----------------------------------------------------------------------
      #_proctrace
      set tbl [winfo parent $tblbody]
      lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
      if {$zeile == -1} {return}
      
      set id [$tbl cellcget $zeile,0 -text]
      ::Canvas::flashID -canvas $canvas -id $id
      return
   }
   
   #-----------------------------------------------------------------------
   proc doubleB1Tbl {tblbody x y canvas} {
      # Double-B1-Release in TBL -> showConfig
      #-----------------------------------------------------------------------
      #_proctrace
      set tbl [winfo parent $tblbody]
      lassign [::utils::gui::TblGetZS $tbl $x $y] zeile spalte
      if {$zeile == -1} {return}
      
      set id [$tbl cellcget $zeile,0 -text]
      ::Canvas::showConfig -canvas $canvas -id $id
      
      return
   }
   
   
   #-----------------------------------------------------------------------
   proc fillCanvasArr {canvas} {
      # belegt canvasArr
      #-----------------------------------------------------------------------
      #_proctrace
      global
      variable canvasArr
      variable allIDs
      variable allTags
      
      if {[catch {SendSyn -- ::inspector_testling::GetCanvasProperties \
               $canvas} canvasProps]} {
         return -code error $canvasProps
      }
      
      lassign $canvasProps idListe tagListe
      array unset canvasArr
      set allIDs  ""
      set allTags ""
      foreach el $idListe {
         lassign $el id typ tags
         lappend allIDs $id
         set canvasArr($id,typ)  $typ
         set canvasArr($id,tagsORids) $tags
      }
      foreach el $tagListe {
         lassign $el tag typ ids
         lappend allTags $tag
         set canvasArr($tag,typ) $typ
         set canvasArr($tag,tagsORids) $ids
      }
      return
   }
   
}