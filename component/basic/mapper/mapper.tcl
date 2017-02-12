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
proc send_request {datalist outport} {
    global g_crawler

    set p_ip [ip::source]
    byList::init $p_ip
    byList::set_list $p_ip $datalist
    server_send $p_ip $outport 
    ip::sink $p_ip
    return
}

proc process {inport p_ip} {
    global g_mapper
    global g_keylist

    set rc ""
    set keylist ""
    if {$inport == "IN-1"} {
	array set newkeyval {}
    	array set curkeyval [byList::get_list $p_ip]
	foreach idx [array names curkeyval] {
	    if {[info exists g_mapper($idx)]} {
		set val $curkeyval($idx)
		set key $g_mapper($idx)
		set newkeyval($key) $val
		lappend keylist $key
	    }
	}
	foreach key [UtilSet::ldifference $g_keylist $keylist] {
	    set newkeyval($key) ""
	}
	send_request [array get newkeyval] OUT-1

    } else {

    }
    return $rc
}

proc init {datalist} {
    global g_mapper
    global g_keylist

    set g_keylist ""
    set filename [lindex $datalist 0]
    if {[file exists $filename] } {
	set fd [open $filename "r"]
	while {[gets $fd line] > -1} {
	    array set g_mapper $line
	    lappend g_keylist [lindex $line 1]
	}
	close $fd
    } else {
	puts "mapper: $filename does not exist."
    }
    return
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(PATTERN_HOME)/set.tcl

