# Copyright (C) 2018 by Matthew Lai, email : mmlai@sympatico.ca
#
# The author  hereby grants permission to use,  copy, modify, distribute,
# and  license this  software  and its  documentation  for any  purpose,
# provided that  existing copyright notices  are retained in  all copies
# and that  this notice  is included verbatim  in any  distributions. No
# written agreement, license, or royalty  fee is required for any of the
# authorized uses.  Modifications to this software may be copyrighted by
# their authors and need not  follow the licensing terms described here,
# provided that the new terms are clearly indicated on the first page of
# each file where they apply.
#
# IN NO  EVENT SHALL THE AUTHOR  OR DISTRIBUTORS BE LIABLE  TO ANY PARTY
# FOR  DIRECT, INDIRECT, SPECIAL,  INCIDENTAL, OR  CONSEQUENTIAL DAMAGES
# ARISING OUT  OF THE  USE OF THIS  SOFTWARE, ITS DOCUMENTATION,  OR ANY
# DERIVATIVES  THEREOF, EVEN  IF THE  AUTHOR  HAVE BEEN  ADVISED OF  THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE  AUTHOR  AND DISTRIBUTORS  SPECIFICALLY  DISCLAIM ANY  WARRANTIES,
# INCLUDING,   BUT   NOT  LIMITED   TO,   THE   IMPLIED  WARRANTIES   OF
# MERCHANTABILITY,  FITNESS   FOR  A  PARTICULAR   PURPOSE,  AND
# NON-INFRINGEMENT.  THIS  SOFTWARE IS PROVIDED  ON AN "AS  IS" BASIS,
# AND  THE  AUTHOR  AND  DISTRIBUTORS  HAVE  NO  OBLIGATION  TO  PROVIDE
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#!/bin/sh
# \
exec tclsh $0 "$@"

# date should be YYYY-MM-DD
proc gen_date_ranges {date_begin date_end} {
    set rc ""
	set month_begin "-01-01"
	set month_end "-12-31"
	set year_begin [lindex [split $date_begin "-"] 0]
	set year_end [lindex [split $date_end "-"] 0]
	
	set year_cur $year_begin
	lappend rc $date_begin
	while {$year_cur < $year_end} {
	    lappend rc "$year_cur$month_end"
        incr year_cur
        lappend rc "$year_cur$month_begin"	
	}
	lappend rc $date_end
	return $rc
}

#-------------------------------------------------------
lappend auto_path $env(DISK2)/tclkit/modules
package require Mk4tcl
source db_if.tcl

set dbpath $env(DISK2_DATA)/scratchpad/db/db
db_if::Init $dbpath
#-------------------------------------------------------

source $env(WEB_DRIVER_HOME)/common/history_range.tcl
array set g_histrange {}

# cd C:/winfbp/web_driver/common
# tclsh get_history_range2.tcl close 1.00 1.00 history_range.cfg date 2017-01-01 2018-02-09 stock_history.dat

set column [lindex $argv 0]
set ref_value_limit [lindex $argv 1]
set value_limit [lindex $argv 2]
set cfgfile [lindex $argv 3]
set column_date [lindex $argv 4]
set min_date [lindex $argv 5]
set max_date [lindex $argv 6]
set outfile [lindex $argv 7]

set fd2 [open $outfile w]

histrange::init $cfgfile
set idxlist [histrange::get_idx_all]

set daterangelist [gen_date_ranges $min_date $max_date] 
puts "date ranges are $daterangelist"

foreach filename [db_if::Get_Symbollist] {	
	puts "processing $filename"
	
    foreach idx $idxlist {
	    set g_histrange($idx) 0
	}

	set buffer ""
	foreach {date1 date2} $daterangelist {
		set rc ""
		set year [lindex [split $date1 "-"] 0]
		db_if::get_recordlist $filename $year $column date $date1 $date2 rc
		if {$rc != ""} {
            set buffer [concat $buffer $rc]
        }		
    }
	
	# Use the first line as reference line
	set ref_value [lindex $buffer 0]
	set buffer [lreplace $buffer 0 0]
	foreach value $buffer {
		if {$value == "0.00"} {
		    continue
	    }
        set change [expr ($value - $ref_value) * 100.0 / $ref_value]
		set idx [histrange::get_range_idx $change]
		incr g_histrange($idx)	    
	}
	
	set result ""
    foreach idx $idxlist {
	    if {!$g_histrange($idx)} {
		    continue
		}
		set result [linsert $result 0 "$idx $g_histrange($idx)"]
	}
	
	if {[string last "/" $filename] > -1} {
	    set symbol [lindex [split $filename "/"] end]
	} else {
	    set symbol $filename
	}
	
	if {$ref_value < $ref_value_limit || $value < $value_limit} {
	    continue
	}
	
	puts $fd2 "$symbol $ref_value $value $result"
	unset g_histrange
}
close $fd2
exit 0

