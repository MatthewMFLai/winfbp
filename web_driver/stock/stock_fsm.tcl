# Copyright (C) 2017 by Matthew Lai, email : mmlai@sympatico.ca
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
variable m_key
variable m_data

proc init {} {
    variable m_keys
    variable m_data
    
    # raw data looks like this
	# 2.28,88.71M,270.27M,118540000,N/A,300724,255287,0.04,2.00,1.13,57.00,1.94
	# 2.28 = last trade (price only) : LastTradePriceOnly
	#88.71M = revenue : Revenue
	#270.27M = market capitalization : MarketCapitalization
	#118540000 = shares outstanding : SharesOutstanding
	#N/A = shares owned : SharesOwned
	#300724 = volume : Volume
	#255287 = avg daily volume : AverageDailyVolume
	#0.04 = earnings per share : EarningsShare
	#2.00 = book value : BookValue
	#1.13 = price / book : PriceBook
	#57.00 = P/E ratio : PERatio
	#1.94 = short ratio : ShortRatio
	
    set m_keys {LastTradePriceOnly Revenue MarketCapitalization SharesOutstanding SharesOwned \
                Volume AverageDailyVolume EarningsShare BookValue PriceBook PERatio ShortRatio}
    if {[info exists m_data]} {
		unset m_data
    }
    array set m_data {}

    return
}

proc process_generic {p_data} {
    upvar $p_data argarray
    variable m_keys
    variable m_data

    set data $argarray(data)
    set tokens [split $data ","]
    foreach key $m_keys token $tokens {
		regsub -all {\+} $token "" value
		regsub -all "," $value "" value
		if {[string index $value end] == "M"} {
			regsub "M" $value "" value
			set value [expr round($value * 1000000)]
		} elseif {[string index $value end] == "B"} {
			regsub "B" $value "" value
			set value [expr round($value * 1000000000)]
		}
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
