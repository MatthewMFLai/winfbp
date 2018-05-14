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
source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(DISK2)/fbp_draw/fbp_mgr/fbp_agent_fsm.tcl
source $env(DISK2)/fbp_draw/fbp_mgr/fbp_mgr.tcl

namespace eval FbpDraw {

variable m_fd

proc fd_to_ipaddr {cid} {
    variable m_fd

    foreach ipaddr [array names m_fd] {
	if {$m_fd($ipaddr) == $cid} {
	    return $ipaddr
	}
    }
    return ""	
}

proc fbpmgr_handle {cid} {
    variable m_fd
    variable m_graph

    if {[gets $cid request] < 0} {
        close $cid
    } else {
	puts "Rx: $request"
	if {[lindex $request 0] != "DONE"} {
	    return
	}
	set tmpdata(ipaddr) [fd_to_ipaddr $cid]
	if {$tmpdata(ipaddr) == ""} {
	    return
	}
	set tmpdata(request) $request
	Fsm::Run fbp_agent_fsm tmpdata
	set cmd [fbp_agent_fsm::get_clr_cmd]
	if {$cmd != ""} {
	    set cmd [lappend cmd $m_graph(graph_id)]
    	    foreach ipaddr [array names m_fd] {
		puts $m_fd($ipaddr) $cmd
		flush $m_fd($ipaddr)
	        puts "Tx: $ipaddr $cmd"
    	    }
	}
    }
}

proc Mgr_Init {ip_prefix port} {
    variable m_fd

    array set m_fd {}
    FbpMgr::Init $ip_prefix $port
    return
}

proc Mgr_Sweep {start stop} {
    variable m_fd

    # Close preivous file descriptors first.
    foreach ipaddr [array names m_fd] {
	catch {close $m_fd($ipaddr)}
	unset m_fd($ipaddr)
    }	
    FbpMgr::Sweep $start $stop 
    return
}

proc Mgr_Run {taskfile graphfile ipaddrlist} {
    variable m_fd
    variable m_network
    variable m_graph

    # Close preivous file descriptors first.
    foreach ipaddr [array names m_fd] {
	catch {close $m_fd($ipaddr)}
	unset m_fd($ipaddr)
    }
	
    # FbpMgr already has list of ip addresses from previous sweep.
    set rc [FbpMgr::bcast_send_file $taskfile $ipaddrlist $m_network(fcopy_port)]
    if {$rc != ""} {
	return -code error $rc
    }
    # Download the current graph file to fbp agent.
    # This is needed for the network recovery feature.
    set rc [FbpMgr::bcast_send_file $graphfile $ipaddrlist $m_network(fcopy_port)]
    if {$rc != ""} {
	return -code error $rc
    }

    foreach ipaddr $ipaddrlist { 
    	set m_fd($ipaddr) [socket $ipaddr $m_network(service_port)]
    	fileevent $m_fd($ipaddr) readable "FbpDraw::fbpmgr_handle $m_fd($ipaddr)"
    	fconfigure $m_fd($ipaddr) -buffering line -blocking 0 
    }

    set idx [string last "/" $taskfile]
    incr idx
    set filename [string range $taskfile $idx end]
    set idx [string last "/" $graphfile]
    incr idx
    set graphname [string range $graphfile $idx end]

    set tmpdata(ipaddrlist) $ipaddrlist 
    set tmpdata(filename) $filename
    set tmpdata(graphname) $graphname
    set tmpdata(reconnect) 0
    Fsm::Run fbp_agent_fsm tmpdata
    set cmd [fbp_agent_fsm::get_clr_cmd]
    if {$cmd != ""} {
	set cmd [lappend cmd $m_graph(graph_id)]
    	foreach ipaddr $ipaddrlist {
	    puts $m_fd($ipaddr) $cmd
	    flush $m_fd($ipaddr)
            puts "send $ipaddr $cmd"
    	}
    }
    unset tmpdata
}

proc mgr_terminate {action} {
    variable m_fd
    variable m_graph

    set tmpdata(action) $action 
    Fsm::Run fbp_agent_fsm tmpdata
    set cmd [fbp_agent_fsm::get_clr_cmd]
    if {$cmd != ""} {
	set cmd [lappend cmd $m_graph(graph_id)]
    	foreach ipaddr [array names m_fd] {
	    puts $m_fd($ipaddr) $cmd
	    flush $m_fd($ipaddr)
            puts "send $ipaddr $cmd"
    	}
    }
    unset tmpdata
}

proc Mgr_Disconnect {} {
    mgr_terminate "disconnect"
    return
}

proc Mgr_Reconnect {ipaddrlist} {
    variable m_fd
    variable m_network
    variable m_graph

    # Close preivous file descriptors first.
    foreach ipaddr [array names m_fd] {
	catch {close $m_fd($ipaddr)}
	unset m_fd($ipaddr)
    }
	
    foreach ipaddr $ipaddrlist { 
    	set m_fd($ipaddr) [socket $ipaddr $m_network(service_port)]
    	fileevent $m_fd($ipaddr) readable "FbpDraw::fbpmgr_handle $m_fd($ipaddr)"
    	fconfigure $m_fd($ipaddr) -buffering line -blocking 0 
    }

    set tmpdata(ipaddrlist) $ipaddrlist 
    set tmpdata(filename) "-----" 
    set tmpdata(graphname) $m_graph(graph_id)
    set tmpdata(reconnect) 1
    Fsm::Run fbp_agent_fsm tmpdata
    set cmd [fbp_agent_fsm::get_clr_cmd]
    if {$cmd != ""} {
	set cmd [lappend cmd $m_graph(graph_id)]
    	foreach ipaddr $ipaddrlist {
	    puts $m_fd($ipaddr) $cmd
	    flush $m_fd($ipaddr)
            puts "send $ipaddr $cmd"
    	}
    }
    unset tmpdata
}

proc Mgr_Stop {} {
    mgr_terminate "stop"
    return
}

proc Mgr_Query {query} {
    variable m_fd
    variable m_network
    variable m_graph

    set rc ""
    set query [lappend query $m_graph(graph_id)]
    foreach ipaddr [array names m_fd] { 
    	set fd [socket $ipaddr $m_network(info_port)]
	puts $fd $query
	flush $fd
	gets $fd response
	close $fd
	set rc [concat $rc $response]
    }
    return $rc
}

proc Mgr_Query_Graph {query ipaddr graph_id} {
    variable m_network

    lappend query $graph_id
    set fd [socket $ipaddr $m_network(info_port)]
    puts $fd $query
    flush $fd
    gets $fd response
    # Kludge: I have problem retrieving the newline 
    # characters since the get command already removes them!
    # I tried the read command but it does not return.
    # So I have to manually insert the newline character back
    # into the discovered graph file data.
    set data $response
    while {![info complete $data]} {
        append data "\n"
    	gets $fd response
    	append data $response
    }
    set response $data
    close $fd
    return $response
}

}

malloc::init
Fsm::Init
Fsm::Load_Fsm $env(DISK2)/fbp_draw/fbp_mgr/fbp_agent_fsm.dat
Fsm::Init_Fsm fbp_agent_fsm

if {0} {
set w .fr1
frame $w -borderwidth 1 -relief raised
pack $w -fill x
text $w.text -relief sunken -bd 2
pack $w.text -expand yes -fill both
frame $w.buttons
pack $w.buttons -side bottom -fill x -pady 2m
button $w.buttons.sweep -text Sweep -command {
    FbpMgr::Init 192.168.0 14000
    FbpMgr::Sweep 113 117
    $w.text delete 0.0 end
    $w.text insert end "[FbpMgr::getip]\n" 
}
}


