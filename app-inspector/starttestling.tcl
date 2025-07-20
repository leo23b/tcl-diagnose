#
# starttestling
#

global argv
set testling [lindex  $argv 0 ]
if {$testling eq ""} {
   puts "\nso gehts: \$ wish starttestling.tcl <pfadTestling>\n"
   puts "pfadtestling kann auf kit oder den Hauptmodul zeigen\n"
   puts "starttestling richtet mit ::comm einen Port ein und sourced"
   puts "den Testling"
   exit
}

puts "testling: $testling"

source [file join .. snit2.3.2 snit2.tcl]

source [file join  ..  comm-4.6.3.1.tm]

set port [::comm::comm self]
puts "Port:$port"

source $testling