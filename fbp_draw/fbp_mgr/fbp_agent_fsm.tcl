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
namespace eval fbp_agent_fsm {


variable m_ipaddrlist
variable m_currlist
# 2 filenames: first is the taskfile, second is the graphfile.
variable m_filename
variable m_cmd
variable m_action
variable m_reconnect
variable m_portmap

proc init {} {
    
    variable m_ipaddrlist
    variable m_currlist
    variable m_filename
    variable m_cmd
    variable m_action
    variable m_reconnect
    variable m_portmap
	
    set m_ipaddrlist ""
    set m_currlist ""
    set m_filename ""
    set m_cmd ""
    set m_action ""
    set m_reconnect 0
	array set m_portmap {}

    return
}

proc get_clr_cmd {} {
    variable m_cmd

    set rc $m_cmd
    set m_cmd ""
    return $rc
}

proc process_ready {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_ipaddrlist
    variable m_filename
    variable m_reconnect

    set m_ipaddrlist $arg_array(ipaddrlist)
    lappend m_filename $arg_array(filename)
    lappend m_filename $arg_array(graphname)
    set m_reconnect $arg_array(reconnect)
    return
}

proc process_allocport {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_currlist
    variable m_portmap

    set ipaddr $arg_array(ipaddr)
    set idx [lsearch $m_currlist $ipaddr]
    if {$idx != -1} {
	    set m_currlist [lreplace $m_currlist $idx $idx]
    }

    array set m_portmap [lrange $arg_array(request) 1 end]
    return
}

proc process_running {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_action

    set m_action $arg_array(action)
    return
}

proc process_generic {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_currlist

    set ipaddr $arg_array(ipaddr)
    set idx [lsearch $m_currlist $ipaddr]
    if {$idx != -1} {
	set m_currlist [lreplace $m_currlist $idx $idx]
    }
    return
}

proc eval_ready_to_create {} {
    variable m_reconnect

    if {$m_reconnect == 0} {
	return 1
    }
    return 0
}

proc eval_ready_to_running {} {
    variable m_reconnect

    if {$m_reconnect} {
	return 1
    }
    return 0
}

proc eval_running_to_drain {} {
    variable m_action

    if {$m_action == "stop"} {
	return 1
    }
    return 0
}

proc eval_running_to_ready {} {
    variable m_action

    if {$m_action == "disconnect"} {
	return 1
    }
    return 0
}

proc eval_all_ipaddr_rx {} {
    variable m_currlist

    if {$m_currlist == ""} {
	return 1
    }
    return 0
}

proc act_default {} {
    variable m_ipaddrlist
    variable m_currlist

    set m_currlist $m_ipaddrlist
    return
}

proc act_ready_to_create {} {
    variable m_cmd
    variable m_filename

    act_default 
    set m_cmd "CREATE [lindex $m_filename 0] [lindex $m_filename 1]"
    return
}

proc act_create_to_allocport {} {
    variable m_cmd

    act_default 
    set m_cmd "ALLOCPORT"
    return
}

proc act_allocport_to_update_portmap {} {
    variable m_cmd
	variable m_portmap

    act_default 
    set m_cmd "UPDATE_PORTMAP [array get m_portmap]"
    return
}

proc act_update_portmap_to_enable {} {
    variable m_cmd

    act_default 
    set m_cmd "ENABLE"
    return
}

proc act_enable_to_pid {} {
    variable m_cmd

    act_default 
    set m_cmd "PID"
    return
}

proc act_pid_to_kick {} {
    variable m_cmd

    act_default 
    set m_cmd "KICK"
    return
}

proc act_running_to_drain {} {
    variable m_cmd

    act_default 
    set m_cmd "DRAIN"
    return
}

proc act_drain_to_disable {} {
    variable m_cmd

    act_default 
    set m_cmd "DISABLE"
    return
}

proc act_disable_to_close {} {
    variable m_cmd

    act_default 
    set m_cmd "CLOSE"
    return
}

proc act_to_ready {} {
    init
    return
}

proc Dump {} {
    variable m_ipaddrlist
    variable m_currlist
    variable m_cmd

    puts "ipaddrlist = $m_ipaddrlist"
    puts "currlist = $m_currlist"
    puts "current cmd = $m_cmd"
    return
}

}
