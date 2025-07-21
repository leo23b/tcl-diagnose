
package ifneeded callib 1.0 \
   [list source [file join $dir callib-0.7.tcl]]

set ::utils_dir_icons [file join $dir icons]

package ifneeded utils 2.3.32  \
   [list source [file join $dir utils-2.3.32.tm]]

package ifneeded fsdialog 1.17.4  \
   [list source [file join $dir fsdialog-1.17.4 fsdialog.tcl]]
