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
namespace eval Company {

    variable m_filename
    variable m_db
    variable m_symbols
    variable m_keylist

proc init {filename} {
    variable m_filename
    variable m_db
    variable m_symbols
    variable m_keylist

    if {[info exists m_db]} {
	unset m_db
    }
    array set m_db {}
    set m_filename $filename
    set m_symbols ""
    set m_keylist ""

    populate_db
}

#symbol	description	name	sector	industry	employees	incorporated
#AW.UN	A&W Revenue Royalties Income Fund (the Fund) is a Canada-based limited purpose trust. The Fund invests in A&W Trade Marks Inc. (Trade Marks), which through its ownership interest in A&W Trade Marks Limited Partnership (the Partnership) owns the A&W trade-marks used in the A&W quick service restaurant business in Canada. The Fund's capital management objectives are to have sufficient cash and cash equivalents to pay unit holders, after satisfaction of its debt service and income tax obligations, provisions for general and administrative expenses, and retention of reasonable working capital reserves. The Partnership has granted A&W Food Services of Canada Inc. (Food Services) a license to use the A&W trade-marks in Canada for which Food Services pays a royalty of 3% of sales reported to Food Services by specific A&W restaurants. Food Services is a franchisor of hamburger quick service restaurants in Canada. 	A&W Revenue Royalties Income Fund	Cyclical Consumer Goods & Services	Restaurants	0	December 18, 2001
proc populate_db {} {
    variable m_filename
    variable m_db
    variable m_symbols
    variable m_keylist

    if {![file exist $m_filename]} {
	puts "$m_filename does not exist"
	return
    }

    array set tmptable {}
    set fd [open $m_filename "r"]
    # First line is the header line.
    gets $fd line
    set m_keylist [split $line "\t"]
    set maxidx [llength $m_keylist]
    incr maxidx -1
    while {[gets $fd line] > -1} {
	if {$line == ""} {
	    continue
	}
	set valuelist [split $line "\t"]
	set symbol [lindex $valuelist 0]
	lappend m_symbols $symbol

	set idx 1
	while {$idx <= $maxidx} {
	    set key [lindex $m_keylist $idx]
	    set value [lindex $valuelist $idx]
	    set m_db($key,$symbol) [string trim $value]
	    incr idx
    	}
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

proc get_all_symbols {} {
    variable m_symbols

    return $m_symbols
}

proc get_keylist {} {
    variable m_keylist

    return $m_keylist
}

}
