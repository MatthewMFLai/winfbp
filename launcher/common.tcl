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

proc build_port {ipaddr num} {
    return "$ipaddr:$num"
}

proc get_port {token} {
    return [lindex [split $token ":"] 1]
}

proc get_ipaddr {token} {
    return [lindex [split $token ":"] 0]
}

proc alive_alert {} {
    global g_logfile

    set idx [string first ":" $g_logfile]
    incr idx
    set idx2 [string first "." $g_logfile]
    incr idx2 -1
    puts "[string range $g_logfile $idx $idx2] is alive..."
    after 30000 alive_alert
}

proc server_send {p_ip portid} {
    global g_async_send

    if {$portid != ""} {
	lappend g_async_send [list $portid [ip::serialize $p_ip]]
    }
    return
}

proc server_log {mode data} {
    global g_logfile
    set fd [open $g_logfile a]
    puts $fd "[clock format [clock seconds]] $mode $data"
    flush $fd
    close $fd
}

proc get_server_id {} {
    global g_ports
    return [get_port $g_ports(INIT)]
}

proc get_inports {} {
    global g_ports
    return [array names g_ports "IN-*"]
}

proc get_outports {} {
    global g_ports
    return [array names g_ports "OUT-*"]
}

proc ready_file {initport {zero_port_map ""}} {	
    # Put a marker file to let the launcher know that
    # the sockets have been set up.
	while {[SocketLock::acquire_lock "FBP_PROCESS_SYNC"] != "SOCKETLOCK_OK"} {
	    after 10
	}
    set fd [open data_$initport.ready w]
    puts $fd $zero_port_map
    close $fd
	SocketLock::release_lock "FBP_PROCESS_SYNC"
}

proc port_0_get {inportname inport} {
    set portnum [get_port $inport]
	set ipaddr [get_ipaddr $inport]
	if {$inportname == "INIT"} {
        set tmp_fd [socket -server server_init 0]
	} else {
        set tmp_fd [socket -server server_accept_$inportname 0]	
	}
	set alloc_portnum [lindex [fconfigure $tmp_fd -sockname] 2]
	return [build_port $ipaddr $alloc_portnum]
}

proc port_0_get_localhost {inportname ipaddr} {
    set tmp_fd [socket -server server_accept_$inportname 0]
	set alloc_portnum [lindex [fconfigure $tmp_fd -sockname] 2]
	return [build_port $ipaddr $alloc_portnum]
}