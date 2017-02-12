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
    global g_repeat
    global g_next_crawler

    set rc "" 
    set url [byList::get_list $p_ip]
    set crawler [byList::get_crawler $p_ip]
    set repeat $g_repeat
    while {$repeat} {
    	array set data {}
    	process_$crawler $url data
	set urlerror $data(urlerror) 
        if {$urlerror == ""} {
            break
        }
        if {$urlerror == "N/A"} {
            set repeat 0
	    break
        }
        if {[string first "FAILfsm" $urlerror] > -1} {
            set repeat 0 
        } else {
	    incr repeat -1
	    unset data
	}
    }
    if {$repeat == 0} {
        server_log "ERROR" "rc = $urlerror url = $url"
    	set p_out [ip::clone $p_ip]
    	byList::remove $p_out
    	byList::init $p_out
    	byList::set_list $p_out $url
    	byList::set_crawler $p_out $crawler
    	byList::set_urlerror $p_out $urlerror
    	server_send $p_out OUT-2
    	ip::sink $p_out
        return $rc
    }

    set p_out [ip::clone $p_ip]
    byList::remove $p_out
    byList::init $p_out
    byList::set_list $p_out [array get data]
    if {$g_next_crawler($crawler) != ""} {
	byList::set_crawler $p_out $g_next_crawler($crawler)
    }
    server_send $p_out OUT-1
    ip::sink $p_out
    return $rc
}

proc init {datalist} {
    global g_repeat
    global g_next_crawler
    global env

    set url_param [lindex $datalist 2]
    set url_mode [lindex $url_param 0]
    set url_cache [lindex $url_param 1]
    Url::init $url_mode
    Url::init_cachedir $url_cache
    PhantomjsUrl::init $url_mode
    PhantomjsUrl::init_cachedir $url_cache
    Fsm::Init
    foreach tuple [lrange $datalist 3 end] { 
    	set crawler [lindex $tuple 0]
	set arglist [lindex $tuple 1]
    	set to_crawler [lindex $tuple 2]
	if {[UtilSys::Is_Runtime] == 0} {
    	    loadeach $env(WEB_DRIVER) $crawler
	} else {
	    loadeach [UtilSys::Get_Path]/web_driver $crawler
	}
	# Kludge
# DYNAMIC SOURCE BEGIN
	if {$crawler == "financials"} {
	    source $env(WEB_DRIVER)/financials/symbol_filter.tcl
	}
	source $env(COMP_HOME)/stock/$crawler/$crawler.tcl
# DYNAMIC SOURCE END 
	init_$crawler $arglist
    	set g_next_crawler($crawler) $to_crawler
    }
    set g_repeat [lindex $datalist 0]
    return
}

proc shutdown {} {
}

package require htmlparse
source $env(COMP_HOME)/ip2/byList.tcl
source $env(WEB_DRIVER)/loadall/loaddir.tcl
source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(PATTERN_HOME)/getphantomjsurl.tcl
source $env(PATTERN_HOME)/sys_util.tcl
source $env(PATTERN_HOME)/stock_util.tcl
