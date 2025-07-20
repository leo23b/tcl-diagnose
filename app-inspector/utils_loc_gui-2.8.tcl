## -*-Tcl-*-
 # ###################################################################
 #  Copyright (c) 2025  Leo Bauer (E-mail: leo.bauer1@gmx.de)
 #  lib - Library-Funktionen für TCL/TK
 #
 #  FILE: "utils_loc_gui.tcl"
 #  Description:
 #  enthaelt allg. GUI-Routinen
 #
 # ###################################################################
    
#------------------------------------------------------------
# AddTab fuegt ein Register ins Notebook
#
# Parameter:
#
# nb        : Notebook
# name      : Name Register
# text      : Text in der Registerlasche
# createCmd :
# raiseCmd  :
#
# Ergebnis:
# Frame der Tabelle
#------------------------------------------------------------
proc AddTab {nb name text createCmd raiseCmd}  {
   set pages [$nb pages 0 end]
   if {$name in $pages} {return {} }
   
   $nb insert end $name       \
      -text $text             \
      -createcmd $createCmd   \
      -raisecmd  $raiseCmd
   return [$nb getframe $name]
}
#-----------------------------------------------------------
# SetDisable
# setzt -state von w auf disabled/normal
#
# Parameter:
# w      : Widget
# onoff  : on|off
#-----------------------------------------------------------
proc SetDisable {onoff w } {

   if {[KeinTk]} {return}
   if {![winfo exists $w]} {return}

   if {$onoff== {on}} {
      $w  configure -state disabled
   } else {
      $w  configure -state  normal
   }
   update idletasks
   return
}
#----------------------------------------------------------------------
proc BumpFonts {w incr} {
# vergrössert oder verkleinert dden Font des sel. Wigets
# cget -font liefert
#       - einen Fontnamen zB TkDefaultFont oder
#       - einen Font (Liste mit Name Größe bold)
#         zB {fixed 12} oder {Courier -18 bold}
#----------------------------------------------------------------------
   #puts "\nw:$w"
   if {![winfo exists $w]} {return}
      
   # Widget hat -font ?
   if {[catch {$w cget -font} fontdescr]} {
      return
   }
   #puts [$w cget -font]

   # {fixed 14 bold} oder nur benannter Font
   lassign $fontdescr font size bold
   if {$size == {} } {
      set size [font configure $font -size]
   }
   #puts "s:$size"

   # size ist negativ ?
   if {[string range $size 0 0] == {-}} {
      set size [string range $size 1 end]
   }
   incr size $incr

   # keep font sizes sane...
   set abssize [::tcl::mathfunc::abs $size]
   if {$abssize >= 8 && $abssize <= 32} {
      #puts "font configure $font -size -$size"
      $w configure -font [list $font $size $bold]
   }
}

#-----------------------------------------------------------
# KeinTk
# prüft ob X11 (oder Tk) geladen ist
#
# Parameter:
# Ergebnis : 1/0
# Hinweis:
# Existenz eines Widgets muss zusätzlich geprüft werden
#-----------------------------------------------------------
proc KeinTk {} {

   if {[info commands winfo] != {}} {
      return false
   } else {
      return true
   }
}
#------------------------------------------------------------
# DirDiffText
# vergleicht t1 und t2 mit Dirdiff
# t1 und t2 ist ein Textwidget, eine Datei oder ein String
#
# t1     : Text 1
# t2     : Text 2
#
# Ergebnis: -
#
#------------------------------------------------------------
proc DirDiffText {t1 t2}  {

   set cmd [auto_execok dirdiff]
   if {$cmd == {}} {return}

   set cl1 {}
   catch {
      set cl1 [winfo class $t1]
   }
   set cl2 {}
   catch {
      set cl2 [winfo class $t2]
   }
   if {[file readable $t1]} {
      set file1 $t1
   } elseif {$cl1 == {Text}} {
      set file1 [::utils::file::writetmp [$t1 get 0.0 end]]
   } else {
      set file1 [::utils::file::writetmp $t1]
   }
   if {[file readable $t2]} {
      set file2 $t2
   } elseif {$cl2 == {Text} } {
      set file2 [::utils::file::writetmp [$t2 get 0.0 end]]
   } else {
      set file2 [::utils::file::writetmp $t2]
   }

   if {[catch {exec $cmd $file1 $file2 &} msg]} {
      puts "F-dirdiff:$msg"
   }
}

#-----------------------------------------------------------------------
proc Paste {W} {
   # löscht im Entry Text (selektiert oder nicht) unf fügt
   # Clipboard (Ctrl-c) ein
   # bei Taste Ctrl-v oder B-2
   #-----------------------------------------------------------------------
   
   if {[catch {::tk::GetSelection  $W CLIPBOARD} sel]} {
      # nix im Clipboard , vorhrt Ctrl-c
      return
   }
   #puts "sel:$sel"
   $W delete 0 end
   $W insert insert $sel
   return
}

#-----------------------------------------------------------------------
proc Traverse_in {path} {
#       selektiert das ganze Eingabefeld bei dem Ereignis
#       <<TraverseIn>> (dh beim springen über die Eingabefelder
#       mit der TabTaste)
#-----------------------------------------------------------------------

   #--------------------- Autohighlight the selection,
   #--------------------- but not if one existed
   #
   if {[$path selection present] != 1} {
      $path selection range 0 end
   }
}
# Variante für Spinbox
proc Traverse_inSP {path} {

   if {[$path.e selection present] != 1} {
      $path.e selection range 0 end
   }
}
