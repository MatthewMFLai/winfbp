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
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS
namespace eval stock_fsm {

variable m_trim_begin
variable m_trim_end
variable m_data

proc init {} {
    variable m_trim_begin
    variable m_trim_end
    variable m_data
    
    # raw data looks like this
    #{"query":{"count":1,"created":"2016-04-03T14:52:10Z","lang":"en-US","results":{"quote":{"symbol":"fts.to","Ask":"40.79","AverageDailyVolume":"1320660",...,"LastTradeTime":"4:00pm","TickerTrend":null,"OneyrTargetPrice":null,"Volume":"929570","HoldingsValue":null,"HoldingsValueRealtime":null,"YearRange":"34.16 - 41.58","DaysValueChange":null,"DaysValueChangeRealtime":null,"StockExchange":"TOR","DividendYield":"3.72","PercentChange":"+0.15%"}}}}
    #
    # We want to trim everything before the first "quote" and remove the last 4 braces
    #
    set m_trim_begin -1
    set m_trim_end -4 
    if {[info exists m_data]} {
	unset m_data
    }
    array set m_data {}

    return
}

proc process_generic {p_data} {
    upvar $p_data argarray
    variable m_trim_begin
    variable m_trim_end
    variable m_data

    set data $argarray(data)

    set idx [string first "symbol" $data]
    incr idx $m_trim_begin
    set idx2 [string last "\}" $data]
    incr idx2 $m_trim_end
    set dataline [string range $data $idx $idx2]
    set tokens [split $dataline ","]
    foreach token $tokens {
	# token looks like
	# "name":"value"
	set idx [string first ":" $token]
	incr idx -2
	set key [string range $token 1 $idx]
	incr idx 3
	if {[string index $token $idx] == "\""} {
	    incr idx 1
	    set value [string range $token $idx end-1]
	} else {
	    set value [string range $token $idx end]
	}
	regsub -all {\+} $value "" value	
	set m_data($key) $value
    }

    return
}
	    
proc Dump_Stock {p_data} {
    upvar $p_data data
    variable m_data

    array set data [array get m_data]
    return
}

proc Dump {} {
    variable m_data

    foreach idx [lsort [array names m_data]] {
	puts "$idx $m_data($idx)"
    }
    return
}

}
