## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "dnd.tcl"
 #  Description:
 #  enthält allgemeine DnD-Utilities:
 #
 # ###################################################################


namespace eval Dnd {
   
   #-----------------------------------------------------------------------
   proc dragQuelle {w dndtyp draginit} {
      # Widget DragQuelle konfigurieren
      #-----------------------------------------------------------------------
      ::tkdnd::addType $dndtyp text/plain
      ::tkdnd::drag_source register $w $dndtyp
      bind $w <<DragInitCmd>> [list $draginit %W %x %y]
      
      return
   }
  
   #-----------------------------------------------------------------------
   proc dropZiel {w dndtyp drop dropenter dropleave} {
      # DropWidget für dnd konfigurieren
      # 
      # w         : Widget DropZiel
      # dndtyp    : DND_Typ
      # drop      : cb für drop-Event
      # dropenter : analog
      # dropleave : analog
      #-----------------------------------------------------------------------
      ::tkdnd::addType $dndtyp text/plain
      ::tkdnd::drop_target register $w $dndtyp
      bind $w <<Drop>>       [list $drop      %W %X %Y %A %D]
      bind $w <<DropEnter>>  [list $dropenter %W %X %Y %TT]
      bind $w <<DropLeave>>  [list $dropleave %W %X %Y]
      
      return
   }
   
   
   #
   # Verbindung entgegennehmen ----------------------
   #
   
   #-----------------------------------------------------------------------
   proc dropTestlingSelf {args} {
      # Drag ist über Targetlabel und liefert self vom Testling
      #--------------------------------------------------------------------
      global gd
      
      lassign $args w x y A data
      set classZiel [winfo class $w]
      if {$classZiel ne "Label"} {
         return refuse_drop
      }
      
      lassign $data typ selfTestling
      
      $w configure \
         -background cornFlowerBlue \
         -borderwidth 2 \
         -relief sunken
      
  
      # Connect zum Testling
      ::Connect::connect comm $selfTestling
      return
   }
   
   #-----------------------------------------------------------------------
   proc dropEnterTestlingSelf {args} {
      # Drag ist über Targetlabel und liefert self vom Testling
      #-------------------------------------------------------------------
      
      lassign $args w x y typ
      set classZiel [winfo class $w]
      if {$classZiel ne "Label"} {
         return refuse_drop
      }
      
      $w configure -background lawngreen -relief groove -borderwidth 2
   }
   
   #-----------------------------------------------------------------------
   proc dropLeaveTestlingSelf {args} {
      # Drag ist über Targetlabel und liefert self vom Testling
      #------------------------------------------------------------------
      
      lassign $args w x y
      $w configure                   \
         -background  cornFlowerBlue \
         -borderwidth 2              \
         -relief      sunken
   }
   
   #-----------------------------------------------------------------------
   proc dropEnterProc {args} {
      return
   }
   
   #-----------------------------------------------------------------------
   proc dropLeaveProc {args} {
      # Drag ist über Targetlabel und liefert self vom Testling
      #------------------------------------------------------------------
      return
   }
   
   
} ;# ende namespace
