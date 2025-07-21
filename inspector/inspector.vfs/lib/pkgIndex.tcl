#
# dieser eine lappend muss bleiben
# sonst findet der thread lokale Prozeduren  nicht
# das Directory ist egal
# ?????
#puts "dir <$dir>"
lappend auto_path [file join $dir comm]
