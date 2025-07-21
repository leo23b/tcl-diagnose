
package require platform
set platform [::platform::generic]

set lib [file join $platform libtkdnd2.9.so]


package ifneeded tkdnd 2.9 \
  "source \{$dir/tkdnd.tcl\} ; \
   tkdnd::initialise \{$dir\} $lib tkdnd"
   
# -*- coding: ISO8859-15 -*-