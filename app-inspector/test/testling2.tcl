# testling2.tcl
#
# auto_load einrichten
#
set scriptDir [pwd]
set libDir    [file normalize [file join $scriptDir .. ..]]

::tcl::tm::path add $libDir           ;# für Module
lappend ::auto_path $libDir

package require BWidget


#-----------------------------------------------------------------------
proc getPort2 {args} {
   # richtet im Testling einen tcp-port 
   #--------------------------------------------------------------------
   
   if {[catch {::comm::comm "self"} msg]} {
      # ggf comm laden und self bestimmen
      package require comm
      set port [::comm::comm "self"]
      comm::comm config -local 0 -port $port
   } else {
      set port [::comm::comm "self"]
   }
   
   set data [list typ_commid $port]
   return [list copy DND_COMMID $data]
}

#-----------------------------------------------------------------------
proc dragLabel {w} {
   # legt Label an, ist DragQuelle. Wird in das Dropziel -Drop here-
   # im inspector gezogen.
   # -------------------------------------------------------------------
   
   set titel [label $w.titel -font TkHeadingFont -text testling2 \
      -background gainsboro -foreground blue \
      -relief raised -borderwidth 2]
   
   # Drag-Quelle : comm/self kopieren
   # Quelle : Label text  DND_TYP: DND_Text
   package require tkdnd
   ::tkdnd::addType DND_COMMID text/plain
   ::tkdnd::drag_source register $titel  DND_COMMID
   bind $titel <<DragInitCmd>> [list ::getPort2 %W %x %y]
   
   return $titel
}

set win .testling2
toplevel $win
wm withdraw .
wm geometry $win 300x300
wm protocol   $win WM_DELETE_WINDOW exit

set fr [frame $win.fr]
pack $fr -side top -expand yes -fill both

set titel [dragLabel $fr]
pack $titel -side top -fill x -expand 0


set lab [label $fr.lab -font TkHeadingFont -text "Hello World" ]
pack $lab -side top -fill both -expand 1

