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
namespace eval history_fsm {

variable m_rx_list
variable m_data

proc init {} {
    variable m_rx_list
    variable m_data

	set m_rx_list {"header" "history"}
    if {[info exists m_data]} {
        unset m_data
    }
    array set m_data {}

    return
}

proc process_generic {p_data} {
    upvar $p_data argarray
    variable m_rx_list
    variable m_data

    set data $argarray(data)
	set tmplist [split $data "\n"]
	
	set idx [lindex $m_rx_list 0]
	set m_data($idx) [lindex $data 0]
	set tmplist [lrange $tmplist 1 end]
	set historylist ""
	foreach day $tmplist {
	    if {$day != ""} {
		    lappend historylist $day
		}
	}
	set idx [lindex $m_rx_list 1]
	set m_data($idx) $historylist
    return
}
	    
proc Dump_history {p_data} {
    upvar $p_data data
    variable m_data

    array set data [array get m_data]
    return
}

}

