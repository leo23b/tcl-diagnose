# -*-Tcl-*-
# ###################################################################
#
#  FILE: "tree-x.y.tm"
#                                    created: 05.11.2017
#  Description:
#  tree-Package enthält
#  tree-spezifische Helferlein
#
#  History
package provide utils::tree 1.0.2
#
#  modified   by   rev     reason
#  ---------- ---- ------- -------------------------
#  17.01.2024 mlrd 01.0.2  ::tw::tw -> ::tw
#  29.06.2019 mlrd 01.0.1  Doku 
#  05.11.2017 mlrd 01.00  Original
# ###################################################################

package require Opts

namespace eval utils::tree {
   #---------- Variable ------------------------------------------------
   variable test           0
   variable wNr            0
   variable nodeNr         0
   variable topNum         0    ;# eindeut. Toplevelnummer
   variable packagename    {utils::tree}
   
   #--------- interne Funktionen ------------------------------------------
   ###-----------------------------------------------------------------------------
   #    proc debuginfo {} {
   #       set str {
   #          # ---------------Debug -----------------
   #          # 1 : Trace proc
   #          # 2 :
   #          # 3 :
   #          # 4 : Trace Result
   #          # 5 : interner Ablauf
   #          
   #          # 10:
   #          # 15:
   #          #-------------------------------------
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
   #    #--------------------------------------------------------------------
   #    proc _proctrace {} {
   #       #--------------------------------------------------------------------
   #       set infoLev [info level -1]
   #       #_dbg 1 Proctrace {set infoLev}
   #    }
   #    #--------------------------------------------------------------------
   #    proc _resulttrace {msg} {
   #       #--------------------------------------------------------------------
   #       variable packagename
   #       set infolevel [info level -1]
   #       ::utils::dbg::debugstring 4 $packagename Resulttrace "$infolevel ->\n\t -> $msg"
   #    }
   #    
   #    #---------------------------------------------------------------
   ###-----------------------------------------------------------------------------
   proc checkName {W name} {
      # W      : Array Widgetverzeichnis
      # name   : eindeutiger Name
      # prüft ob Widgetname schon da oder leer, dann liefert Nr
      upvar $W wv
      variable wNr
      
      if {$name != {}} {
         if {[info exists wv(w,$name)]} {
            # exist Widget ?
            if {[winfo exists $wv(w,$name)]} {
               return -code error "Name <$name> schon vorhanden "
            } else {
               return $name
            }
         } else {
            return $name
         }
      } else {
         incr wNr
         set name $wNr
         #_dbg 5 Widgetnr {set wNr}
         return $name
      }
   }
   #-----------------------------------------------------------------------
   proc _getTL {p} {
      # sucht toplevel p
      #-----------------------------------------------------------------------
      global wv
      if {$p ne ""} {
         return [winfo toplevel $p]
      } elseif {[info exists wv(w,top)]} {
         if {[winfo exists $wv(w,top)]} {return $wv(w,top)}
      } else {
         return .
      }
   }
   
}
#--------------------------------------------------------------------
#        Hauptprozeduren
#--------------------------------------------------------------------

#--------------------------------------------------------------------
#
# Proc: mkTree
#
# *::utils::tree::mkTree W p name args*
# 
# erzeugt ein Treewidget mit vertikalen Scrollbars
# unter dem Widget-Vater _p_ mit dem Namen _name_ im
# Widgetverzeichnis _W_.
#
# Parameter:
#     W: Globales Widgetverzeichnis i.a. wv (ohne $)
#     p: Parentwidget
#     name:  eindeutiger Name im Widgetverzeichnis. Per Default wird der Name
#        automatisch vergeben.
#     args:  Optionen
#
# Optionen:
#  -titel str:   Titel für Titleframe um tree und view
#
#  -dragEnd script:   Abschluss dragNdrop
#                Parameter: (source target op datatype data args)
#
#  -dropOver script: Callback wird vor dem Drop gerufen.
#     Prüft ob Drop zulässig, steuert das DragIcon.
#     Parameter: target source ev x y op datatype data.
#       ** 1 : drop zulässig
#       ** 0 : drop unzulässig
#
#  -openCmd script: klappt Knoten auf. Parameter: (tree node)
#
#  -closeCmd script: klappt Knoten zu. Parameter: (tree node)
#
#  -popup script: Popup-Script auf dem Tree.widget Parameter: (tree node)
#
#  Nach der Kennung *--* können weitere Optionenpaare
#       von *tree* angefügt werden.
#
# Funktionen:
#   insertNode : Vater oder Kind einfügen (siehe Beispiel:)
#                
#
#
#
# 
# Ergebnis:
#    Treewidget
#
#  siehe auch:
# - <bwidget/Tree.html>
#
# Beispiel:
# (start code)
#
#   package require utils::tree
#   
#   set tw [::widgets::topwidget $wv(w,top) ]
#   set fr [$tw winfo frame]
#   
#   set tree [::utils::tree::mkTree "wv" $fr tree \
#      -titel meinTree]
#   
#   # Knoten einfügen
#   set n1 [::utils::tree::insertNode $tree {} \
#      -text Knoten1 \
#      -data knoten1 \
#      -symbol folder]
#   # und Kinder
#   set n11 [::utils::tree::insertNode $tree $n1 \
#      -text Knoten11 \
#      -data knoten11 \
#      -symbol leaf]
# (end)
#
#
#

#-----------------------------------------------------------------------
proc ::utils::tree::mkTree {W p name args} {
   # erzeugt Baum mit Titel und ScrolledView
   #-----------------------------------------------------------------------
   upvar $W wv
   #_proctrace
   
   
   set noName 0
   if {$name == {}}  {set noName 1}
   set name [checkName wv $name]
   
   ##nagelfar variable params
   ::Opt::opts {params} $args {
      {-titel    {titel}  "Titel für Baum und View"}
      {-noview   {0}      "ohne View"}
      {-dragEnd  {}       "Callback"}
      {-dropOver {}       "Callback"}
      {-openCmd  {::utils::tree::openCmd}  "Callback"}
      {-closeCmd {::utils::tree::closeCmd} "Callback"}
      {-popup    {::utils::tree::popup}    "Callback"}
      {--        ""       "Options für Tree folgen"}
   }
   set titel    $params(-titel)
   set dragEnd  $params(-dragEnd)
   set dropOver $params(-dropOver)
   set openCmd  $params(-openCmd)
   set closeCmd $params(-closeCmd)
   set popup    $params(-popup)
   
   set tfr [TitleFrame $p.$name -text $titel]
   pack $tfr -padx 3 -pady 3 -expand yes -fill both
   set fr [$tfr getframe]
   
   # Panedwindow : oben Tree unten View
   #
   set erg [::utils::gui::mkPanedWindow wv $fr "" \
      -wts {6,1} \
      -richt - ]
   lassign $erg pw ftree fview
   pack $pw -padx 3 -pady 3 -fill both -expand 1 -side top
   
   set sw [ScrolledWindow $ftree.sw_$name \
      -relief sunken \
      -borderwidth 4 \
      -scrollbar vertical]
   pack $sw -padx 3 -pady 3 -expand yes -fill both
   
   # und jetzt der Tree
   #
   set wTree         \
      [Tree $sw.tree \
      -deltay 20     \
      -relief flat   \
      -borderwidth 0 \
      -width 15      \
      -highlightthickness 0 \
      -redraw 0      \
      -dropenabled 1 \
      -dragenabled 1 \
      -dragevent 1   \
      -draginitcmd ::utils::tree::draginit   \
      -dragendcmd  $dragEnd      \
      -dropovercmd $dropOver \
      -opencmd     [list $openCmd $sw.tree] \
      -closecmd    [list $closeCmd $sw.tree] \
      -droptypes   {TREE_NODE {copy {} move {} link {}}} \
      {*}$params(--)
   ]
   $sw setwidget $wTree
   if {!$noName} {set wv(w,tree,$name) $wTree}
   
   # --------------------- Scrolled View
   #
   set sv [ScrollView $fview.scrv -window $sw.tree -fill white]
   pack $sv -fill both -expand yes
   
   $wTree bindText  <Button-3> "$popup $wTree"
   $wTree bindImage <Button-3> "$popup $wTree"
   
   # Wurzel eintragen
   #
   $wTree insert end root wurzel \
      -text      Wurzel \
      -image     [Bitmap::get folder] \
      -drawcross allways   \
      -data      "Wurzel"  \
      -open      1
   
   
   return $wTree
}

#-----------------------------------------------------------------------
proc ::utils::tree::draginit {tree node args} {
   # Callback gerufen zur Initialisierung des dragNDrop
   #-----------------------------------------------------------------------
   return [list TREE_NODE [list copy move] $node]
}
#-----------------------------------------------------------------------
proc ::utils::tree::popup {args} {
   # Musterpopup
   #-----------------------------------------------------------------------
   lassign $args  tree node
puts [info level 0]
  
   set xp [winfo pointerx .]
   set yp [winfo pointery .]

   catch {destroy .menubar}
   set menubar [menu .menubar -tearoff 0]
   $menubar add command -label Aufklappen -command "::utils::tree::nodeFkts $tree $node opentree"
   $menubar add command -label Zuklappen  -command "::utils::tree::nodeFkts $tree $node closetree"
   $menubar add separator
   $menubar add command -label KnotenInfo -command "::utils::tree::knotenInfo $tree $node "

   tk_popup .menubar  $xp $yp

   return 
}
#-----------------------------------------------------------------------
proc ::utils::tree::nodeFkts {args} {
   #  Verteiler für Knotenfunktionen. Wird von callPopup
   #  aufgerufen.
   #--------------------------------------------------------------------
   puts [info level 0]
     
   lassign $args tree node fkt subfkt
   
   switch -- $fkt {
      opentree -
      closetree -
      delete   {$tree $fkt $node}      
      selection {
         switch --  $subfkt {
            add -
            remove {$tree selection $subfkt $node}
            clear  {$tree selection $subfkt}
            default {puts "F-Switch subfkt $subfkt"}
         }
      }
      default {puts "F-Switch fkt:$fkt"}
   }
   return
}
#-----------------------------------------------------------------------
proc ::utils::tree::knotenInfo {args} {
   #
   #-----------------------------------------------------------------------
   global wv
   lassign $args tree node
   puts [info level 0]
   
   set info {}
   append info "Node: $node\nOptionen:\n"
   set opts [$tree itemconfigure $node]
   foreach opt $opts {
      set qual  [lindex $opt 0]
      set value [lindex $opt 4]
      append info "\t$qual $value\n"
   }
   ::widgets::tw $wv(w,top).ki \
      -widget text          \
      -titel {KnotenInfo}   \
      -text [list $info]    \
      -- \
      -bg white
   return
}
#-----------------------------------------------------------------------
proc ::utils::tree::insertNode {tree vater args} {
   # einen Knoten am Ende eintragen
   # Knoten kann Vater oder Kind sein
   # Vater: symbol:folder
   # Kind : Symbol:leaf
   # vater : Default : Wurzel -> am Ende anfügen
   #-----------------------------------------------------------------------
   variable nodeNr
   
   ##nagelfar variable params
   ::Opt::opts {params} $args {
      {-text    {text}  "Textinfo Knoten"}
      {-data    {data}  "Dateninfo Knoten"}
      {-symbol  {leaf}  "folder|leaf"}
      {-font    {TkDefaultFont} "Font"}
   }
   set text    $params(-text)
   set data    $params(-data)
   set font    $params(-font)
   set text    $params(-text)
   set symbol  $params(-symbol)
   
   if {$vater eq ""} {
      set vater wurzel
   }
   if {$symbol eq "leaf"} {
      set image [Bitmap::get file]
      set cross auto
   } elseif {$symbol eq "folder" } {
      set image [Bitmap::get folder]
      set cross always
   } else {
      return -code error "F-insertNode : leaf|folder"
   }
   set node n$nodeNr
   $tree insert end $vater $node \
      -text      $text \
      -image     $image \
      -drawcross $cross \
      -data      $data   \
      -font      $font
   
   incr nodeNr
   $tree configure -redraw 1
   return $node
}
#-----------------------------------------------------------------------
proc ::utils::tree::openCmd {args} {
   #
   #-----------------------------------------------------------------------
   puts [info level 0]
   
   lassign $args tree node
   
   if { [llength [$tree nodes $node]] } {
      $tree itemconfigure $node -image [Bitmap::get openfold]
   }
   return
}
#-----------------------------------------------------------------------
proc ::utils::tree::closeCmd {args} {
   #
   #-----------------------------------------------------------------------
   puts [info level 0]
   
   lassign $args tree node
   
   if { [llength [$tree nodes $node]] } {
      $tree itemconfigure $node -image [Bitmap::get folder]
   }
   return
}