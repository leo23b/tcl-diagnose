   # calendar.tcl
   #
   #    Implementation of calendar calculations for Tcl.
   #
   # by Torsten Reincke (reincke@marilim.de)
   #

   # some important notes:
   #
   #### all dates are given in the format day.month.year
   #### example: 1.12.2001 (1st December 2001)
   #### the only exeptions are: today, yesterday, and tomorrow
   #
   # julain dates are those upto 4.10.1582 (a Thursday)
   # then ten days are missing
   # gregorian dates start from 15.10.1582 (a Friday)
   #
   # A julian day is something completetly different, namely the days
   # that have passed by since 1st January 4713 B.C.
   #
   # You can safely use the command for all dates in the gregorian calendar.
   #
   # The julian day 2299160.5 corresponds to the gregorian date 15.10.1582 at 0 GMT
   # So saying "cal gregorian 2299161" will return 15.10.1582 (which is 12 GMT)
   # while "cal gregorian 2299160.4" returns 14.10.1582
   #  (which is shortly before midnight, in the proleptic gregorian calendar)

   # uses lindex $list end-1
   #
   package require Tcl 8.2
   package provide calendar 1.0

   # create a new namespace and put life to it:
   namespace eval ::calendar {
      # some definitions used throughout the code:
      # the '0' in front of each list is just a dummy in order to access
      # names and numbers by their monthly or weekly index
      set week(long,english) {0 Monday Tuesday Wednesday Thursday Friday Saturday Sunday}
      set week(short,english) {0 Mo Tu We Th Fr Sa Su}
      set week(long,german) {0 Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag}
      set week(short,german) {0 Mo Di Mi Do Fr Sa So}
      set month(german) {0 Januar Februar März April Mai Juni Juli August September Oktober November Dezember}
      set month(english) {0 January February March April May June July August September Oktober November December}
      set days(1) {0 31 29 31 30 31 30 31 31 30 31 30 31}
      set days(0) {0 31 28 31 30 31 30 31 31 30 31 30 31}

      # initial language used is German:
      variable language german
      # initial format for month names is a number:
      variable dateformat numeric

      # 'subcommands' is the list of subcommands
      # recognized by the cal command
      variable subcommands [list  \
               "daysbetween"    \
               "fromnumber"     \
               "gregorian"      \
               "isleapyear"     \
               "julian"         \
               "month"          \
               "today"          \
               "tonumber"       \
               "weekday"        \
               "year"           ]

      ## unimplemented subcommands:
      #
      # cal easter      [returns the date for easter (sunday) in the specified year]
      #
      ##

      # we export the procedure 'cal'
      namespace export cal
   }

   # ::calendar::cal
   #
   #    Command that feeds all subcommands
   #
   # Arguments:
   #    cmd     subcommand to invoke
   #    args    arguments for subcommand
   #
   # Results:
   #    Varies based on subcommand to be invoked

   proc ::calendar::cal {{cmd ""} {args ""}} {
       variable subcommands
       # do minimal args checks here:
       if { $cmd==""} {
           error "wrong # args: should be \"cal option ?arg arg ...?\""
       }
       # was the subcommand ok?
       if {[lsearch -exact $subcommands $cmd] == -1} {
          error "bad option \"$cmd\": must be [join $subcommands {, }]"
       }

       # invoke the specified subcommand:
       eval ::calendar::_$cmd $args
   }

   # ::calendar::_daysbetween
   #
   #    Return the number of days between to given dates
   #
   # Arguments:
   #    firstDate       Date denoting the beginning of the peroid
   #    lastDate        Date denoting the end of the period
   #
   # Results:
   #                    Number giving the number of days between the two given dates
   #
   proc ::calendar::_daysbetween {{firstDate ""} {lastDate ""}} {
       if {$firstDate=="" || $lastDate==""} {
           error "wrong # args: should be \"cal daysbetween firstDate lastDate\""
       }
       #### calculate difference in julian dates:
       return [expr int([_julian $lastDate] - [_julian $firstDate])]
   }

   # ::calendar::_gregorian
   #
   #    Calculates the gregorian date for a given julian date
   #    adapted from JulianDatesG.html (Bill Jefferys, bill@clyde.as.utexas.edu)
   #
   # Arguments:
   #    j_date          A julian date
   #
   # Results:
   #                    A gregorian date in format 'dd.mm.yyyy'
   #
   proc ::calendar::_gregorian {{j_date ""}} {
      if {$j_date==""} {
         error "wrong # args: should be \"cal gregorian date\""
      }
      set JD [expr $j_date+0.5]
      set W  [expr int(($JD-1867216.25)/36524.25)]
      set B  [expr $JD+1+$W-$W/4+1524]
      set C  [expr int(($B-122.1)/365.25)]
      set D  [expr int(365.25*$C)]
      set E  [expr int(($B-$D)/30.6001)]
      set F  [expr int(30.6001*$E)]
      set d  [expr int($B-$D-$F)]
      if $E<=13 {set m [expr $E-1]} else {set m [expr $E-13]}
      if $m>2 {set y [expr $C-4716]} else {set y [expr $C-4715]}
      return "$d.$m.$y"
   }

   # ::calendar::_julian
   #
   #    Return the julian date of a given gregorian date
   #    (i.e. days since 1st January 4713 B.C.)
   #    adapted from JulianDatesG.html (Bill Jefferys, bill@clyde.as.utexas.edu)
   #
   # Arguments:
   #    g_date          A gregorian date as 'dd.mm.yyyy'
   #
   # Results:
   #                    The corresponding julian date
   #
   #
   proc ::calendar::_julian {{g_date ""}} {
      if {$g_date==""} {
         error "wrong # args: should be \"cal julian date\""
      }
      foreach {d m y} [split $g_date .] {}
      # take care of leading zeroes:
      set d [string trimleft $d 0]
      set m [string trimleft $m 0]
      if {$y<0} {incr y 1}
      if {$m<3} {incr y -1; incr m 12}
      return [expr 2-$y/100+$y/400+$d+int(365.25*($y+4716))+int(30.6001*($m+1))-1524.5]
   }

   # ::calendar::_isleapyear
   #
   #    Calculates if the gives year is a leapyear
   #    (from http://www.mitre.org/tech/cots/LEAPCALC.html)
   #
   # Arguments:
   #    year            A year
   #
   # Results:           1 if the year is a leapyear
   #                    0 if the year is no leapyear
   #
   proc ::calendar::_isleapyear {{year ""}} {
      if {$year==""} {
         error "wrong # args: should be \"cal isleapyear year\""
      }
      if {[expr $year%4  ]!=0} {
         return 0
      } elseif  {[expr $year%400]==0} {
         return 1
      } elseif  {[expr $year%100]==0} {
         return 0
      } else {
         return 1
      }
   }

   # ::calendar::today
   #
   #    Returns the date of today
   #
   # Arguments:           None
   #
   # Results:           A string giving today's date
   #
   proc ::calendar::_today {args} {
      if {$args!=""} {
         error "wrong # args: should be \"cal today\""
      }
      return [clock format [clock seconds] -format "%d.%m.%Y"]
   }
