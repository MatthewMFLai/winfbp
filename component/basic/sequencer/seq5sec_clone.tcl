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
proc statechange {} {
    global g_state

    if {$g_state == "STATE_1"} {
	set g_state STATE_2
    } elseif {$g_state == "STATE_2"} {
	set g_state STATE_3
    } else {
	set g_state STATE_1
    }
    return
}

proc process {inport p_ip} {
    global g_state
    global g_timestamp
 
    set rc "" 

    set p_cloned [ip::clone $p_ip]
    regsub "IN" $inport "OUT" outport
    server_send $p_cloned $outport 
    ip::sink $p_cloned

    set timestamp_cur [clock seconds]
    if {[expr $timestamp_cur - $g_timestamp] > 10} {
	set g_timestamp $timestamp_cur
	statechange
    	if {$g_state == "STATE_1"} {
	    set rc [list "IN-1"] 
    	} elseif {$g_state == "STATE_2"} {
	    set rc [list "IN-2"]
    	} elseif {$g_state == "STATE_3"} {
	    set rc [list "IN-3"]
    	}
    }
    return $rc
}

proc init {datalist} {
    global g_state
    global g_timestamp

    set g_timestamp [clock seconds]
    set g_state STATE_1
    return
}

proc shutdown {} {
    return 
}

source $env(COMP_HOME)/ip2/byRetry.tcl

variable g_state
variable g_timestamp

