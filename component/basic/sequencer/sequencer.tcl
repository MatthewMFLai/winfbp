# Copyright (C) 2016 by Matthew Lai, email : mmlai@sympatico.ca
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
proc process {inport p_ip} {
    global g_count
    global g_limit
    global g_data
 
    set rc "" 
    set data [byRetry::get_retry $p_ip]

    puts $data
    lappend g_data($inport) $data
    incr g_count($inport)
    after [expr int(floor(rand() * 100))]
    if {$g_count($inport) >=  $g_limit} {
	if {$inport == "IN-1"} {
	    set rc [list IN-2 IN-3] 
	} elseif {$inport == "IN-2"} {
	    if {$g_count(IN-3) != $g_limit} {
	        set rc [list "IN-3"]
	    } else {
	        set rc [list "IN-1"]
    		array set g_count {IN-1 0 IN-2 0 IN-3 0} 
	    }
	} elseif {$inport == "IN-3"} {
	    if {$g_count(IN-2) != $g_limit} {
	        set rc [list "IN-2"]
	    } else {
	        set rc [list "IN-1"]
    		array set g_count {IN-1 0 IN-2 0 IN-3 0} 
	    }
	} else {
	}
    }
    return $rc
}

proc init {datalist} {
    global g_count
    global g_limit
    global g_data

    array set g_count {IN-1 0 IN-2 0 IN-3 0} 
    array set g_data {IN-1 {} IN-2 {} IN-3 {}}
    if {$datalist == "" || [lindex $datalist 0] == ""} {
    	set g_limit 10
    } else {
	set g_limit [lindex $datalist 0]
    }
}

proc shutdown {} {
    global g_data

    foreach port [array names g_data] {
        set datalist $g_data($port)
	set base [lindex $datalist 0]
	set len [llength $datalist]
	for {set i 1} {$i < $len} {incr i} {
	    set data [expr $base + $i]
	    if {$data != [lindex $datalist $i]} {
		puts "$port data corrupted."
		break
	    }
	}
	puts "$port data is clean."
    }
    return
}

source $env(COMP_HOME)/ip2/byRetry.tcl

variable g_count
variable g_limit
variable g_data

