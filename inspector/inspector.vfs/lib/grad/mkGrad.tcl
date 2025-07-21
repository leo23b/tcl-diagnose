# /usr/bin/env tclsh
# mkGrad.tcl --
#     Show a gradient 
#
# p1 : col1 p2: col2 p3 :x|y

source canvas_gradient.tcl

global argv
if {[llength $argv] == 0} {
   puts {Doku mkGrad.tcl
      mit mkGrad einen Gradienten anzeigen:
       $> wish mkGrad.tcl color1 color2 x|y
      Beispiel:
      tclkit mkGrad.tcl cornflowerblue aliceblue  x

      Das anstehende Fenster in eine Datei schreiben:
      $> import datei.png
      und Gradientfläche mit der Maus aufziehen
   }
   exit
      
   
}


if {[llength $argv] != 3} {
   puts "usage: wish mkGrad.tcl color1 color2 x|y"
   
   exit
}
lassign $argv col1 col2 xy

package require canvas::gradient
canvas .c
canvas::gradient .c -direction $xy -color1 $col1 -color2 $col2
pack .c -fill both -expand 1

# -*- coding: ISO8859-15 -*-