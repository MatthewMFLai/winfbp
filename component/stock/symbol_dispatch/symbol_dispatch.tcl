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
proc map_exchange {exchange} {
    if {$exchange == "T"} {
	return "T"
    } else {
	return "X"
    }
}

proc dispatch {symbol exchange crawler port} {

    set p_ip [ip::source]
    byRetry::init $p_ip
    byRetry::set_retry $p_ip 0
    byList::init $p_ip
    byList::set_list $p_ip "$symbol [map_exchange $exchange]"
    byList::set_crawler $p_ip $crawler 
    server_send $p_ip OUT-$port
    ip::sink $p_ip
    return
}

proc process {inport p_ip} {
    global g_tsx_exchange
    global g_grouplist
    global .msg
    global g_cur_group
    global g_cur_page

    set rc ""
    array set data [byList::get_list $p_ip] 
    set urlerror $data(urlerror)
    if {$urlerror != ""} {
	server_log "ERROR" "rc = $urlerror"
	return $rc
    }

    	set symbollist $data(symbollist)

    	set maxtoken [llength $symbollist]
    	for {set i 0} {$i < $maxtoken} {incr i} {
    	    set symbollist_data [lindex $symbollist $i]
	    dispatch $symbollist_data $g_tsx_exchange "financials" 0 
	    dispatch $symbollist_data $g_tsx_exchange "fundamental" 1 
	    dispatch $symbollist_data $g_tsx_exchange "company" 2 
    	}

    return $rc
}

proc init {datalist} {
    global g_tsx_exchange

    set g_tsx_exchange [lindex $datalist 0]
    return
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(COMP_HOME)/ip2/byRetry.tcl

