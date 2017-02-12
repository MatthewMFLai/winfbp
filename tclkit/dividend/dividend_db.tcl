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
namespace eval Dividend {

    variable m_filename

proc init {filename} {
    variable m_filename
    variable m_db

    if {[info exists m_db]} {
	unset m_db
    }
    array set m_db {}
    set m_filename $filename

    populate_db
}

#symbol,52WkLowHi,CashFlow,ConsDivIncr,DebtEquiteRatio,DebtEquitytoIndusty,AllStarRank,DivCur,DivPrev,DivDeclDate,DivExDate,DivGrow3yrAvg,DivGrow5yrAvg,DivPayDate,DivPayType,DivPay,DivPayRatio5yrAvg,DivPayRatio,DivRate,DivRecordDate,DivYield5yrAvg,DivYield,DivSince,EPS,LastClosePrice,LastTradeDate,MarketCap,NetIncome,PEtoIndustry,PE,DivYield10yrProj,Revenue,TotalReturn12mon,TotalReturn3yr,TotalReturn5yr
#AW__U,$ 23.38 - $ 30.00,$ 20151000,1 years,N/A %,1853 %,,$ 0.1250,$ 0.1250,Dec-16-2015,Dec-29-2015,0.85 %,-0.41 %,Jan-29-2016,None,Last 12 months payments: 12,0.00 %,0.00 %,$ 1.50 %,Dec-31-2015,5.90 %,5.40 %,2002,$ 1.19,$ 27.90,Jan-22-2016,$ 230286600,$ 14388000,21 %,N/A,5.40 %,$ 28716000,6.96 %,46.46 %,47.00 %
proc populate_db {} {
    variable m_filename
    variable m_db

    if {![file exist $m_filename]} {
	puts "$m_filename does not exist"
	return
    }

    array set tmptable {}
    set fd [open $m_filename "r"]
    # First line is the header line.
    gets $fd line
    set keylist [split $line ","]
    set maxidx [llength $keylist]
    incr maxidx -1
    while {[gets $fd line] > -1} {
	if {$line == ""} {
	    continue
	}
	set valuelist [split $line ","]
	set symbol [lindex $valuelist 0]

	set idx 1
	while {$idx <= $maxidx} {
	    set key [lindex $keylist $idx]
	    set value [lindex $valuelist $idx]
	    regsub -all {\$} $value "" value        
	    regsub -all "%" $value "" value        
	    regsub -all "," $value "" value
	    if {[string first "Rank" $key] > -1} {
	    	regsub -all " " $value "" value
	    	set value [string length $value]
	    }
	    set m_db($key,$symbol) [string trim $value]
	    incr idx
    	}
    }
    close $fd
    return
}

proc populate_db_old {} {
    variable m_filename
    variable m_db

    if {![file exist $m_filename]} {
	puts "$m_filename does not exist"
	return
    }

    array set tmptable {}
    set fd [open $m_filename "r"]
    while {[gets $fd line] > -1} {
	if {$line == ""  || [string first "urlerror" $line] > -1} {
	    continue
	}
	if {[string first "symbol" $line] > -1} {
	    set symbol [lindex $line 1]
	    foreach idx [array names tmptable] {
		set m_db($idx,$symbol) $tmptable($idx)
	    }
	    unset tmptable
    	    array set tmptable {}
	    continue
	}
		
	set tokens [split $line ":"]
	set key [lindex $tokens 0]
	set value [lindex $tokens 1]
	regsub -all {\$} $value "" value        
	regsub -all "%" $value "" value        
	regsub -all "," $value "" value
	if {[string first "Rank" $key] > -1} {
	    regsub -all " " $value "" value
	    set value [string length $value]
	}
	set tmptable($key) [string trim $value]
    }
    close $fd
    return
}

proc search_db {key lower_val upper_val} {
    variable m_db

    set rc ""
    foreach idx [array names m_db "$key,*"] {
	set value $m_db($idx)
	if {$lower_val <= $value && $value <= $upper_val} {
	    lappend rc [lindex [split $idx ","] 1]
	}
    }
    return $rc
}

proc get_symbol {symbol p_rc} {
    variable m_db
    upvar $p_rc rc

    foreach idx [array names m_db "*,$symbol"] {
	set key [lindex [split $idx ","] 0]
	set rc($key) $m_db($idx)
    }
    return
}

}
