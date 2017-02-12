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
proc display {msg} {
    global g_display
    if {$g_display == "ON"} {
	global .msg
    	.msg configure -text $msg 
    }
    return
}

proc process {inport p_ip} {
    global g_server_id

    set server_id $g_server_id 
    # Search for the out port in the request data
    # and forward the data to out port. Remove out port
    # data from the request.
    set outport [byMux::get_key $p_ip $server_id]
    if {$outport != ""} {    
    	regsub "IN" $outport "OUT" outport
    	byMux::remove_key $p_ip $server_id 
    	server_send $p_ip $outport	
    	display "Demux data to out port $outport"
    } else {
    	display "Demux data information missing"
    }
}

proc init {datalist} {
    global g_display
    global g_server_id
    set g_display [lindex $datalist 0]
    set g_server_id [lindex $datalist 1]
    if {$g_display == ""} {
	set g_display "ON"
	package require Tk
	global .msg
	button .msg -text OK
	pack .msg
    }
    return
}

proc shutdown {} {
}

# Need to source in other tcl scripts in the same directory.
# The following trick to retrieve the current subdirectory
# should work.
#set scriptname [info script]
#regsub "mux.tcl" $scriptname "ZZZ" scriptname
#regsub "ZZZ" $scriptname "byMux.tcl" script2 
#source $script2 
source $env(COMP_HOME)/ip/byMux.tcl
set g_display "ON" 
if {0} {
package require Tk
button .msg -text OK
pack .msg
}

