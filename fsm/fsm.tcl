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
# DYNAMIC SOURCE BEGIN
foreach filename [glob $env(FSM_HOME)/gencode/simple/*.tcl] {
    source $filename
}   
# DYNAMIC SOURCE END 
# DYNAMIC SOURCE BEGIN
foreach filename [glob $env(FSM_HOME)/gencode/complex/*.tcl] {
    source $filename
}
# DYNAMIC SOURCE END
# DYNAMIC SOURCE BEGIN
foreach filename [glob $env(FSM_HOME)/gencode/dynamic_type/*.tcl] {
    source $filename
}
# DYNAMIC SOURCE END

namespace eval Fsm {

    variable m_fsm
    variable m_debug

proc strip_root_name {name} {
    # If the name is x.y.z, return y.z.
    # If the name is x.y, return y
    # If the name is x, return x.
    set idx [string first "." $name]
    if {$idx == -1} {
	return $name
    }
    incr idx
    return [string range $name $idx end]
}

proc Init {{debug 0}} {

    variable m_fsm
    variable m_debug
    #Call malloc::init in the caller code.
    #malloc::init

    # Initiailize the main object first.
    set m_fsm [malloc::getmem]
    set m_debug $debug
    init_FsmMgr $m_fsm
    return
}

proc create_fsm {name} {
    variable m_fsm
    set p_thing [malloc::getmem]
    init_Fsm $p_thing
    byFSMs::set_key $p_thing $name
    byFSMs::add_part $m_fsm $p_thing
    return
}

proc set_init_proc {fsm_name init_proc} {
    variable m_fsm

    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    byFsm::set_init_proc $p_fsm_root $init_proc
    return
}

proc create_node {fsm_name name process_proc} {
    variable m_fsm

    # Check if node is not a duplicate!
    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    if {[byState::get_part $p_fsm_root $name] != "NULL"} {
	return -2
    }
    # Get fsm root name, and prefix this name to the state's name.
    set rootname [byFSMs::get_key $p_fsm_root]
    set p_thing [malloc::getmem]
    init_Node $p_thing
    byState::set_key $p_thing $rootname.$name
    byNode::set_process_proc $p_thing $process_proc
    byState::add_part $p_fsm_root $p_thing
    return 0
}

proc Create_Link {fsm_name fromnode tonode eval_proc action_proc} {
    variable m_fsm

    # Locate fsm root first. 
    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    # Get fsm root name, and prefix this name to the state's name.
    set rootname [byFSMs::get_key $p_fsm_root]
    set p_from_node [byState::get_part $p_fsm_root $rootname.$fromnode]
    set p_to_node [byState::get_part $p_fsm_root $rootname.$tonode]
    if {$p_from_node == "NULL" || $p_to_node == "NULL"} {
	return
    }

    set p_link [malloc::getmem]
    init_Link $p_link
    byLink::set_eval_proc $p_link $eval_proc
    byLink::set_action_proc $p_link $action_proc
    byTransition::graph_add_edge $p_from_node $p_to_node $p_link

    return 1
}

proc Load_Fsm {filename {fsm_name ""}} {
    variable m_fsm

    # Extract fsm name from file name.
    if {$fsm_name == ""} {
    	set fsm_name [lindex [split $filename "/"] end]
    	set fsm_name [lindex [split $fsm_name "."] 0]
    }
    create_fsm $fsm_name

    set state "FIND_BEGIN_STATE" 
    set fd [open $filename r]
    while {[gets $fd line] > -1} {
	if {$line == ""} {
	    continue
	}
	set line [string trim $line]
	if {[string first "#" $line] == 0} {
	    continue
	}
	switch -- $state \
	  FIND_BEGIN_STATE {
	    if {[string first "BEGIN_STATE" $line] > -1} {
		set state FIND_END_STATE
	    }
	} FIND_END_STATE {
	    if {[string first "END_STATE" $line] > -1} {
		set state FIND_BEGIN_LINK
		continue
	    }
	    set name [lindex $line 0]
	    set process_proc [lindex $line 1]
	    create_node $fsm_name $name $process_proc

	} FIND_BEGIN_LINK {
	    if {[string first "BEGIN_LINK" $line] > -1} {
		set state FIND_END_LINK
	    }
	} FIND_END_LINK {
	    if {[string first "END_LINK" $line] > -1} {
		set state FIND_BEGIN_INIT 
		continue
	    }
	    set from_node [lindex $line 0]
	    set to_node [lindex $line 1]
	    set eval_proc [lindex $line 2]
	    set action_proc [lindex $line 3]
	    Create_Link $fsm_name $from_node $to_node $eval_proc $action_proc
	} FIND_BEGIN_INIT {

	    if {[string first "proc = " $line] > -1} {
		set procname [lindex $line 2]
		set_init_proc $fsm_name $procname		
		set state FIND_END_INIT
	    }
	} FIND_END_INIT {
	    if {[string first "END_INIT" $line] > -1} {
		set state FIND_BEGIN_DEFAULT
	    }
 
	} FIND_BEGIN_DEFAULT {

	    if {[string first "BEGIN_DEFAULT_STATE" $line] > -1} {
		set state FIND_END_DEFAULT
	    }
	} FIND_END_DEFAULT {

	    if {[string first "state = " $line] > -1} {
		set state [lindex $line 2]
		Set_State $fsm_name $state
		set state TERMINATE 
	    }
	} TERMINATE {
	    # Do nothing.
	}
    }
    close $fd
}

proc Init_Fsm {fsm_name} {
    variable m_fsm

    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    byFsm::set_in_service $p_fsm_root 1
    byFsm::set_last_error $p_fsm_root ""
    set init_proc [byFsm::get_init_proc $p_fsm_root]
    set rc [$init_proc]
    return
}

proc Set_State {fsm_name initial_state} {
    variable m_fsm

    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    # Set the initial state of FSM.
    set rootname [byFSMs::get_key $p_fsm_root]
    set p_tmp_node [byState::get_part $p_fsm_root $rootname.$initial_state]
    if {$p_tmp_node == "NULL"} {
	return -2
    }
    byCurNode::add_rel $p_fsm_root $p_tmp_node
    return
}

proc Get_State {fsm_name} {
    variable m_fsm

    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return "" 
    }
    # Get current state.
    set p_cur_node [byCurNode::get_rel $p_fsm_root]
    set rc [byState::get_key $p_cur_node]
    set idx [string last "." $rc]
    incr idx
    return [string range $rc $idx end]
}

proc Is_In_Service {fsm_name} {
    variable m_fsm

    # Locate fsm root first. 
    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    return [byFsm::get_in_service $p_fsm_root]
}

proc Get_Error {fsm_name} {
    variable m_fsm

    # Locate fsm root first. 
    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }
    return [byFsm::get_last_error $p_fsm_root]
}

proc Run {fsm_name p_arg_array} {
    variable m_fsm
    variable m_debug
    upvar $p_arg_array arg_array

    # Locate fsm root first. 
    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }

    # Don't run if an error is already logged.
    if {![byFsm::get_in_service $p_fsm_root]} {
	return -2
    }

    # Get current state.
    set p_cur_node [byCurNode::get_rel $p_fsm_root]
    set process_proc [byNode::get_process_proc $p_cur_node]
    if {$process_proc == "null"} {
	return 1	
    }

    if {[catch {$process_proc arg_array} rc]} {
	byFsm::set_in_service $p_fsm_root 0
	byFsm::set_last_error $p_fsm_root $rc
	return -2
    }
    if {$rc == 0} {
    	# Do not evaluate the individual links.
	return 1
    }
   
    # Get all transitions.
    set default_action_proc "null"
    foreach p_link [byTransition::graph_get_from_iterator $p_cur_node] {
	set eval_proc [byLink::get_eval_proc $p_link]
	# To support calling default action proc if there is
	# no state transition.
	if {$eval_proc == "null"} {
	    set p_tmp_node [byTransition::graph_get_vertex_to $p_link]
	    if {$p_tmp_node == $p_cur_node} {
		set default_action_proc [byLink::get_action_proc $p_link]
	    }
	    continue
	}
	#
    	if {[catch {$eval_proc} rc]} {
	    byFsm::set_in_service $p_fsm_root 0
	    byFsm::set_last_error $p_fsm_root $rc
	    return -2
	}
	if {$rc == 0} {
	    continue	
	}

        set action_proc [byLink::get_action_proc $p_link]
	if {$action_proc != "null"} {
    	    if {[catch {$action_proc} rc]} {
	    	byFsm::set_in_service $p_fsm_root 0
	    	byFsm::set_last_error $p_fsm_root $rc	
	    	return -2
	    }
	}

	set p_tmp_node [byTransition::graph_get_vertex_to $p_link]
	if {$m_debug} {
	    puts "From: [byState::get_key $p_cur_node] To: [byState::get_key $p_tmp_node]"
	    foreach idx [array names arg_array] {
		puts "<$idx> $arg_array($idx)"
	    }
	}
	byCurNode::remove_rel $p_fsm_root
	byCurNode::add_rel $p_fsm_root $p_tmp_node

    	return 1
    }

    # Not one state has handled the data!
    # Invoke the default action proc if is is specified 
    # in the fsm definition.
    if {$default_action_proc != "null"} {
        if {[catch {$default_action_proc} rc]} {
    	    byFsm::set_in_service $p_fsm_root 0
    	    byFsm::set_last_error $p_fsm_root $rc	
    	    return -2
    	}
    }

    return 0
}

proc Dump {} {
    variable m_fsm

    return
}

proc Dot_Output {fsm_name} {
    variable m_fsm

    # Locate fsm root first. 
    set p_fsm_root [byFSMs::get_part $m_fsm $fsm_name]
    if {$p_fsm_root == "NULL"} {
	return -1
    }

    # Output state transition diagram data.
    set fsm_name [byFSMs::get_key $p_fsm_root]
    set fd [open $fsm_name.graph.dot w]
    puts $fd "digraph G \{"
    puts $fd "rankdir = LR\;"
    foreach p_node [byState::get_iterator $p_fsm_root] {
	set nodename [strip_root_name [byState::get_key $p_node]]
	set linklist [byTransition::graph_get_from_iterator $p_node]
	foreach p_link $linklist {
	    set p_to_node [byTransition::graph_get_vertex_to $p_link]
	    set to_nodename [strip_root_name [byState::get_key $p_to_node]]
	    puts $fd "$nodename -> $to_nodename\;"
	}
    }
    puts $fd "\}"
    close $fd
}

proc Save {filename} {
    variable m_fsm
    variable m_debug
    malloc::set_var fsm_var $m_fsm
    malloc::set_var fsm_debug $m_debug
    #malloc::save $filename
}

proc Load {filename} {
    variable m_fsm
    variable m_debug
    #malloc::restore $filename
    set m_fsm [malloc::get_var fsm_var]
    set m_debug [malloc::get_var fsm_debug]
}

}

