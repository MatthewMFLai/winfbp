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
proc process {p_data} {
    upvar $p_data data
    global g_view

    set symbol $data(SYMBOL)
    unset data(SYMBOL)

    regsub -all {\.} $symbol "_" symbol_nodot
    if {![info exists g_view($symbol)]} {
    	set g_view($symbol) [mk::view layout g_db.$symbol_nodot "date close volume"]
    }
    set view $g_view($symbol)

    foreach idx [array names data] {
		array set tmpdata {}
		set tmpdata(date) $idx
		set tmpdata(close) [lindex $data($idx) 0]
		set tmpdata(volume) [lindex $data($idx) 1]
    	set row [mk::row append $view]
    	eval mk::set $row [array get tmpdata]
	    unset tmpdata
    }
    mk::file commit $view

    return
}

proc init {filename} {
    global g_db
    global g_view

    mk::file open g_db $filename
    array set g_view {}
    return
}

proc shutdown {} {
    global g_db

    mk::file close g_db
    return
}

global env
global tcl_platform
if {[string first "Windows" $tcl_platform(os)] > -1} {
    package require Mk4tcl
} else {
    load Mk4tcl.so
}
global g_db
set g_db ""

set count 0
set db_num 1
set year [lindex $argv 1]
set db_filename $env(DISK2_DATA)/scratchpad/db/db/$year/[lindex $argv 0]-$db_num
init $db_filename
set historydir $env(DISK2_DATA)/scratchpad/history
foreach filename [glob $historydir/*] {
    set idx [string last "/" $filename]
	incr idx
	set symbol [string range $filename $idx end]
	puts "Processing $symbol in $db_filename ..."
	array set data {}
	set data(SYMBOL) $symbol
	set fd [open $filename r]
	while {[gets $fd line] > -1} {
	    set line [split $line ","]
	    set date [lindex $line 0]
		if {[string first $year $date] == -1} {
		    continue
		}
		set close [lindex $line 4]
		set volume [lindex $line 5]
		set data($date) "$close $volume"	
	}
	close $fd
	process data
	unset data
	
	incr count
	if {$count == 200} {
	    shutdown
	    
		set count 0
		incr db_num
        set db_filename $env(DISK2_DATA)/scratchpad/db/db/$year/[lindex $argv 0]-$db_num
        init $db_filename		
	}
}
shutdown

