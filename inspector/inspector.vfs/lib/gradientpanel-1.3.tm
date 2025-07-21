 #
 # Gradient Panel
 # 
 # a clone of Karsten Lentzsch GradientPanel in Tcl
 # using the canvas and the gradient code found in 
 # tclers wiki. It is implemented using Snit as pure tcl  
 # megawidget.
 #
 #
 # Links: 
 # Karsten Lentzsch www.jgoodies.com
 # Snit: http://www.wjduquette.com/snit/
 # Gradient: http://wiki.tcl.tk/6100
 #
 # Author: Carsten Zerbst carsten.zerbst@groy-groy.de
 #

# 21.06.2020 1.2   - drag Quelle inspector
# 17.02.2016 1.1   - nagelfar ignore
      
 package require snit
 package require Tk
# package require Img

 package provide gradientpanel 1.3

 snit::widgetadaptor gradientpanel {
    option -font 
    option -text 
    option -title 
    option -bg0 -default white
    option -bg1 
    option -fg -default black
    option -icon

      constructor { args } {
        # Create a canvas widget
         ##nagelfar variable self
         ##nagelfar variable win
        installhull [ canvas $self]
        
        $self configure -height 50
        $self configurelist $args
        
        # if nothing set, determine gradient color
        if {[string length [$self cget -bg1]] == 0} {
            # try to determine new end color
            frame $self.dummyframe 
            $self configure -bg1 [ $self.dummyframe cget -bg]
            destroy $self.dummyframe                                         
        }        
        # same for font
        if {[string length [$self cget -font]] == 0} {
            label $self.dummylabel
            $self configure -font [ $self.dummylabel cget -font]
            destroy $self.dummylabel
        }        
        
        $self _drawText
       # $self _drawGradient
        bind $win <Configure> [list $self _drawGradient ]
    }

    # this delegates some methods to be able to manipulate 
    # the canvas context
    delegate method * to hull 
    delegate option * to hull
    
    # use to draw the text
    method _drawText { } {
         ##nagelfar variable self

        set font [$self cget -font ]
        $self delete text
        $self create text 10 10 -text [$self cget -title]  -anchor w \
            -font $font -fill [$self cget -fg] -tag [list text title] 
        set y 24
        if {[llength $font] > 2} {
            set messagefont [lreplace $font 2 2 normal]
        } else {
            set messagefont $font
        }
        foreach tok [split [$self cget -text] \n] {
            $self create text 40 $y -text $tok -anchor w \
                -font $messagefont -fill [$self cget -fg] \
                -tag [list text message]
            incr y 18
         }
         
         if {![catch {package require tkdnd} msg]} {
            # Drag-Quelle : comm/self kopieren
            # Quelle : Label text  DND_TYP: DND_Text
            ::tkdnd::addType DND_COMMID text/plain
            ::tkdnd::drag_source register $self  DND_COMMID
            bind $self <<DragInitCmd>> [list ::dragInitInsp %W %x %y]
         }
    }
    
    # used to redraw the gradient and icon after resize
    method _drawGradient { } {
         ##nagelfar variable self
         ##nagelfar variable win
     
        $self delete gradient
        
        set width  [winfo width $win]
        set height [winfo height $win]
        set max $width; 
        
        if {[catch {winfo rgb $self [ $self cget -bg0 ]} color1]} {
            puts stderr $color1
            return -code error "Invalid color [ $self cget -bg0 ]"
        }
        
        if {[catch {winfo rgb $self [ $self cget -bg1 ]} color2]} {
            return -code error "Invalid color [ $self cget -bg1 ]"
        }
        
        # Check color resolution. Low color resolution results in stripes
        # instead of a smooth gradient. In this case we better use only
        # bg0 as background
        if {[lindex [ winfo rgb $self #010000 ] 0] != 257 } {

            $win create rectangle  0 0 $width $height -tags gradient -fill [ $self cget -bg0 ]

        } else {

            foreach {r1 g1 b1} $color1 break
            foreach {r2 g2 b2} $color2 break
            set rRange [expr $r2.0 - $r1]
            set gRange [expr $g2.0 - $g1]
            set bRange [expr $b2.0 - $b1]
            
            set rRatio [expr $rRange / $max]
            set gRatio [expr $gRange / $max]
            set bRatio [expr $bRange / $max]
            
            
            for {set i 0} {$i < $max} {incr i  } {
                set nR [expr int( $r1 + ($rRatio * $i) )]
                set nG [expr int( $g1 + ($gRatio * $i) )]
                set nB [expr int( $b1 + ($bRatio * $i) )]
                
                set col [format {%4.4x} $nR]
                append col [format {%4.4x} $nG]
                append col [format {%4.4x} $nB]
                
                $win create line $i 0 $i $height -tags gradient -fill #${col} 
                
            }
        }
        $self lower gradient

        # draw icon
        $self delete icon
        set icon [$self cget -icon] 
        if {[string length $icon ] > 0} {
            set distance 10    
            set xmin [expr [lindex [$win bbox text] 2] + $distance]                         
            set width [ winfo width $self]
            set x [expr $width - [image width $icon ]]                         
            if { $xmin  > $x } {
                set x $xmin
            }
            incr x -100
            set y [ winfo height $self]
            
            $self create image $x $y -image $icon -anchor sw -tag icon
            
        }
    }
 }

 #
 # Example code
 #
 # proc example { } {
    # #set m1 [ image create photo -file möwe.png]
    # set m1 [ image create photo -data $::bild]
    # set text [join [list "Lorem ipsum dolor sit amet, consectetuer adipiscing elit." \
                        # "Pellentesque at tortor. Morbi ac wisi imperdiet enim" \
                        # "mattis egestas. Sed ac"] \n]
    # 
    # set title "Lorem Ipsum"
    # set gp [ gradientpanel create .test -text $text -title $title -icon $m1 ]
    # 
    # label .rest -text "The Rest of Your Panel"
    # 
    # grid $gp -sticky ew
    # grid .rest -sticky nesw
    # 
    # grid columnconfigure . 0 -weight 1
    # grid rowconfigure . 1 -weight 1
    # 
    # wm geometry . 600x300
 # } 
# 
 # example