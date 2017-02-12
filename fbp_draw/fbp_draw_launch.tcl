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
source $env(DISK2)/fbp_draw/fbp_mgr/fbp_mgr_gui.tcl

namespace eval FbpDraw {
    variable m_tmpdir
    variable m_querytime
    variable m_runstate
    variable m_queryid
    variable m_portqueuelist
    variable m_cpus

proc launch_init {} {
    variable m_tmpdir
    variable m_querytime
    variable m_queryid
    variable m_runstate
    variable m_portqueuelist
    variable m_cpus
    global env

    set m_tmpdir $env(DISK2)/scratchpad
    array set m_querytime {QUEUE 0 CPU 0} 
    array set m_queryid {QUEUE 0 CPU 0} 
    set m_runstate "LAUNCH_IDLE"
    set m_portqueuelist ""
    set m_cpus ""
    return
}

proc launch_clear_cpu {win} {
    variable m_cpus

    array set tmparray $m_cpus
    foreach idx [array names tmparray] {
        set tmparray($idx) "CLEAR"
    }
    update_cpu $win tmparray
    set m_cpus ""	
    return
}

proc launch_setdir {} {
    variable m_tmpdir
    variable m_runstate

    if {$m_runstate != "LAUNCH_IDLE"} {
	error_dialog "Network is running!"
	return
    }

    set m_tmpdir [tk_chooseDirectory \
        -initialdir ~ -title "Choose a working directory"]
    if {$m_tmpdir == ""} {
	error_dialog "Working directory is not set!"
	return
    }
    set m_tmpdir "$m_tmpdir/FBPDRAW"
    if {[file exists $m_tmpdir]} {
    	file delete -force $m_tmpdir
    }
    file mkdir $m_tmpdir
    return
}

proc launch_run {p_blockname_map} {
    variable m_tmpdir
    variable m_runstate
    variable m_network
    variable m_graph
    global env
    global tcl_platform

    if {$m_graph(graph_id) == ""} {
	error_dialog "Graph name cannot be empty!"
	return
    }
    if {$m_runstate != "LAUNCH_IDLE"} {
	error_dialog "Network is already running!"
	return
    }
	
    if {$m_tmpdir == ""} {
	error_dialog "Select scratchpad to set working directory!"
	return
    }

    # Call the routines to generate block and link files.
    set name "$m_tmpdir/task"
    upvar $p_blockname_map blockname_map
    gen_block_file $name.block  blockname_map
    gen_link_file $name.link blockname_map
    # Call the fbp routines to generate the out and split files.
    if {[string first "Windows" $tcl_platform(os)] > -1} {
    	set line "exec tclsh $env(FBP_HOME)/fbp_test.tcl "
        append line "$name.block $name.link $m_network(circuitname) $m_network(first_port) $name.out"
	eval $line
    	set line "exec tclsh $env(FBP_HOME)/fbp_postproc.tcl "
	append line "$name.out $name.split"
	eval $line
    } else {
    	exec $env(FBP_HOME)/fbp_test.tcl \
            $name.block $name.link $m_network(circuitname) $m_network(first_port) $name.out
    	exec $env(FBP_HOME)/fbp_postproc.tcl $name.out $name.split 
    }
    # Call FBP mgr to spawn the processes.
    set ipaddrlist [block_get_all_ipaddr]
    set graphfile [Gen_Graphfile_Name] 
    if {[catch {Mgr_Run $name.split $graphfile $ipaddrlist} rc]} {
	puts $rc
	return
    }
    set m_runstate "LAUNCH_RUNNING"
    file delete -force $name.block
    file delete -force $name.link
    file delete -force $name.out
    file delete -force $name.split
    file delete -force $graphfile
    return
}

proc launch_stop_trace {win} {
    variable m_querytime
    variable m_queryid
    variable m_portqueuelist

    if {$m_querytime(QUEUE) != 0} {
	set m_querytime(QUEUE) 0
	after cancel $m_queryid(QUEUE)
	set m_queryid(QUEUE) 0
	update_port_queue $win $m_portqueuelist
	set m_portqueuelist ""
    }
    if {$m_querytime(CPU) != 0} {
	set m_querytime(CPU) 0
	after cancel $m_queryid(CPU)
	set m_queryid(CPU) 0
	launch_clear_cpu $win
    }
    return
}

proc launch_disconnect {win} {
    variable m_runstate

    if {$m_runstate != "LAUNCH_RUNNING"} {
	error_dialog "Network is not running!"
	return
    }
    launch_stop_trace $win
    if {[catch {Mgr_Disconnect} rc]} {
	
    }
    set m_runstate "LAUNCH_IDLE"
    return
}

proc launch_stop {win} {
    variable m_runstate

    if {$m_runstate != "LAUNCH_RUNNING"} {
	error_dialog "Network is not running!"
	return
    }
    launch_stop_trace $win
    if {[catch {Mgr_Stop} rc]} {
	
    }
    set m_runstate "LAUNCH_IDLE"
    return
}

proc launch_monitor {win} {
    variable m_runstate
    variable m_querytime
    variable m_queryid
    variable m_portqueuelist

    if {$m_runstate != "LAUNCH_RUNNING"} {
	error_dialog "Network is not running!"
	return
    }

    if {$m_querytime(QUEUE) == 0} {
	set m_querytime(QUEUE) 100
	set m_queryid(QUEUE) [after $m_querytime(QUEUE) FbpDraw::query_queue $win]
    } else {
	set m_querytime(QUEUE) 0
	after cancel $m_queryid(QUEUE)
	set m_queryid(QUEUE) 0
	update_port_queue $win $m_portqueuelist
	set m_portqueuelist ""
    }
    return 
}

proc launch_monitor_cpu {win} {
    variable m_runstate
    variable m_querytime
    variable m_queryid

    if {$m_runstate != "LAUNCH_RUNNING"} {
	error_dialog "Network is not running!"
	return
    }

    if {$m_querytime(CPU) == 0} {
	set m_querytime(CPU) 1500
	set m_queryid(CPU) [after $m_querytime(CPU) FbpDraw::query_cpu $win]
    } else {
	set m_querytime(CPU) 0
	after cancel $m_queryid(CPU)
	set m_queryid(CPU) 0
	launch_clear_cpu $win
    }
    return 
}
proc query_queue {win} {
    variable m_querytime
    variable m_queryid
    variable m_portqueuelist

    set rc [Mgr_Query QUERY_QUEUE]
    if {$rc != ""} {
	update_port_queue $win $m_portqueuelist
	set m_portqueuelist ""
	update_port_queue $win $rc
	foreach token $rc {
	    queue_data_get $token block port length
	    set length 0
	    lappend m_portqueuelist \
                [queue_data_set $block $port $length]
	}
    } else {
	if {$m_portqueuelist != ""} {
	    update_port_queue $win $m_portqueuelist
	    set m_portqueuelist ""
	}
    }

    if {$m_querytime(QUEUE) != 0} {
    	set m_queryid(QUEUE) [after $m_querytime(QUEUE) FbpDraw::query_queue $win]
    }
    return
}

proc query_cpu {win} {
    variable m_querytime
    variable m_queryid
    variable m_cpus

    set rc [Mgr_Query QUERY_CPU]
    if {$rc != ""} {
	# Clear old data first.
	launch_clear_cpu $win

	set m_cpus $rc
	array set tmparray $rc
	update_cpu $win tmparray 
    }

    if {$m_querytime(CPU) != 0} {
    	set m_queryid(CPU) [after $m_querytime(CPU) FbpDraw::query_cpu $win]
    }
    return
}

proc launch_reconnect {win} {
    variable m_tmpdir
    variable m_runstate
    variable m_network
    variable m_graph

    if {$m_graph(graph_id) == ""} {
	error_dialog "Graph name cannot be empty!"
	return
    }
    if {$m_runstate != "LAUNCH_IDLE"} {
	error_dialog "Network is already running!"
	return
    }
	
    if {$m_tmpdir == ""} {
	error_dialog "Select scratchpad to set working directory!"
	return
    }

    # Call FBP mgr to spawn the processes.
    set ipaddrlist [block_get_all_ipaddr]
    if {[catch {Mgr_Reconnect $ipaddrlist} rc]} {
	puts $rc
	return
    }
    set m_runstate "LAUNCH_RUNNING"
    return
}

}

