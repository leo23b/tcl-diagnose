# testling1.tcl
#
# auto_load einrichten
#
set scriptDir [pwd]
set libDir    [file normalize [file join $scriptDir .. ..]]

::tcl::tm::path add $libDir           ;# für Module
lappend ::auto_path $libDir

package require BWidget

# port für Kommunikation mit inspector
#
#-----------------------------------------------------------------------
proc getPort {} {
   #
   #-----------------------------------------------------------------------

   package require comm
   set adrInspector [::comm::comm self]
   comm::comm config -local 1 -port $adrInspector
   puts "comm Testling1 $adrInspector"
   return 
}
   # Port einrichten und anzeigen
   getPort

set win .testling1
toplevel $win
wm withdraw .
wm geometry $win 300x300
wm protocol   $win WM_DELETE_WINDOW exit

set fr [frame $win.fr]
pack $fr -side top -expand yes -fill both

set titel [label $fr.titel -font TkHeadingFont -text testling1 \
   -relief sunken -borderwidth 2]
pack $titel -side top -fill x -expand 0

set lab [label $fr.lab -font TkHeadingFont -text "Hello World" \
   -relief sunken -borderwidth 2]
pack $lab -side top -fill both -expand 1


