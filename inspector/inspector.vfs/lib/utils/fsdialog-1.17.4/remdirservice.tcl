
#-----------------------------------------------------------------------
   proc dirService {dir dirpat filepat} {
      # liefert ls -al und ls -l vom Verzeichnis mit Details
      # size mtime etc
      # dir : Pfad Verzeichnis
      # dirpat : Pattern fuer Verzeichnisse
      # filepat:   "      "  Dateien
      # Return : {status ergebnis|fehlertext}
      # ergebnis: Matrix {{dir1 dir size ..} {dir2 dir} .. {file1 file} ..}
      #-----------------------------------------------------------------------
   
      # Trennen zwischen files und dir
      set files [glob \
         -directory $dir \
         -nocomplain     \
         -types f {*}$filepat]
      
      set dirs [glob \
         -directory $dir \
         -nocomplain     \
         -types d {*}$dirpat]
 
      set mat [list]
      # bei Verzeichnissen . und .. unterdruecken
      foreach name $dirs  {
         if {[string range $name end end] eq "."} {
            continue
         }
         
         set size [file size $name]
         set mtime [file mtime $name]
         set attr [file attributes $name]
         lassign [split $attr] g group o owner p permission
         lappend mat [list [file tail $name] \
            "dir" $size $mtime $permission $owner $group ]
      }
      
      foreach name $files {
         set size [file size $name]
         set mtime [file mtime $name]
         set attr [file attributes $name]
         lassign [split $attr] g group o owner p permission
         lappend mat [list [file tail $name] \
            file $size $mtime $permission $owner $group ]
      }
      return $mat
   }
   
   # Aufruf
   # argv : 'dir~dirpat~filepat'
   
   set argv [lindex $argv 0]
   set ele  [split $argv ~]
   lassign $ele dir dirpat filepat
   if {[catch {dirService $dir $dirpat $filepat} erg]} {
      return -code error "DirService <$dir> <$dirpat> <$filepat> \n$erg"
      #puts "DirService <$dir> <$dirpat> <$filepat> \n$erg"
   }
   puts $erg
   #puts [list 0 $erg]

# -*- coding: ISO8859-15 -*-