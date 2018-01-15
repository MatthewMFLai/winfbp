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
namespace eval history {

variable g_url_history

proc init {url_history} {
    variable g_url_history

    set g_url_history $url_history
    return 
}

proc doit {exchange symbol startdate enddate url_history p_outdata} {
    upvar $p_outdata outdata

	# qm = quotemedia.
	set qm_symbol [UtilStock::convert_symbol_GM_YAHOO $symbol]
	set qm_exchange "ca"
    regsub -all "XXXXX" $url_history $qm_symbol tmpurl
    regsub -all "YYYYY" $tmpurl $qm_exchange url
	
	set startdate [split $startdate "-"]
	set startyear [lindex $startdate 0]
	set startmonth [lindex $startdate 1]
	set startday [lindex $startdate 2]
	regsub "STARTDAY" $url $startday url
	regsub "STARTMONTH" $url $startmonth url
	regsub "STARTYEAR" $url $startyear url
	
	set enddate [split $enddate "-"]
	set endyear [lindex $enddate 0]
	set endmonth [lindex $enddate 1]
	set endday [lindex $enddate 2]
	regsub "ENDDAY" $url $endday url
	regsub "ENDMONTH" $url $endmonth url
	regsub "ENDYEAR" $url $endyear url
	
    if {[catch {Url::get $url} data]} {
    	set outdata(ERROR) $data 
	return 
    }

    set argdata(data) $data
    Fsm::Run history_fsm argdata
    if {[Fsm::Is_In_Service history_fsm] == 1} {
    	array set tmpdata {}
    	history_fsm::Dump_history tmpdata
		
		# The history list may contain data outside the start/end period.
		# Exclude those price points outside of the requested period.
		set historylist ""
		set startstamp [clock scan $startyear-$startmonth-$startday]
		foreach day $tmpdata(history) {
		    # 2018-01-12,18.22,18.22,18.22,18.22,100,0.02,0.11%,18.22,1822.00,1
			set daystamp [clock scan [lindex [split $day ","] 0]]
			if {$daystamp < $startstamp} {
			    break
			}
			lappend historylist $day
		}
		set tmpdata(history) $historylist
		
    	array set outdata [array get tmpdata]
    } else {
    	 set outdata(ERROR) "$symbol FAIL [Fsm::Get_Error history_fsm]"
    }

	
    Fsm::Init_Fsm history_fsm
    Fsm::Set_State history_fsm ONE

    return
}

# startdate and enddate must have this format YYYY-MM-DD
proc extract_data {exchange symbol startdate enddate p_data} {
    variable g_url_history
    upvar $p_data data

    array set tmpdata {}
    doit $exchange $symbol $startdate $enddate $g_url_history tmpdata
    if {[info exists tmpdata(ERROR)] == 0} {
		array set data [array get tmpdata]
		set data(urlerror) ""
		set data(symbol) $symbol
		set data(startdate) $startdate
		set data(enddate) $enddate
    } else {
	    set data(urlerror) $tmpdata(ERROR)
    }
    return
}

}

