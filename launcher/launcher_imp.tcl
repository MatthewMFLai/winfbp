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
namespace eval %%% {

variable m_initportmap
variable m_blockmap
variable m_connector_port

proc sanity {} {
    return "alive"
}

proc get_port {token} {
    return [lindex [split $token ":"] 1]
}

proc get_ipaddr {token} {
    return [lindex [split $token ":"] 0]
}

proc set_block_port {taskfile ipaddr} {
    variable m_blockmap

    # Clean the block name to mtc socket port map.
    unset m_blockmap
    array set m_blockmap {}
    # Parse the split file to generate the block name to 
    # maintenance socket port mapping array.
    set fd [open $taskfile r]
    while {[gets $fd line] > -1} {
    	array set tmparray $line 
	if {$ipaddr != [get_ipaddr $tmparray(INIT)]} {
	    unset tmparray 
	    continue
	}
	set mtcport [get_port $tmparray(INIT)]
	set block $tmparray(BLOCK)
	# For now just remove the circuit name prefix.
	if {$block != "CONNECT"} {
	    set block [lindex [split $block ":"] 1]
	}
	set m_blockmap($block\-$mtcport) 1
	unset tmparray
    }
    close $fd
    return
}

proc get_block_port {block} {
    variable m_blockmap

    set idx [array names m_blockmap $block\-*]
    return [lindex [split $idx "-"] 1] 
}

proc get_block {blockport} {
    variable m_blockmap

    set idx [array names m_blockmap *-$blockport]
    return [lindex [split $idx "-"] 0] 
}

proc Set_Block_Pid {} {
    variable m_initportmap
    variable m_blockmap

    foreach idx [array names m_blockmap] {
	set token [split $idx "-"]
	set port [lindex $token 1]

	set fd $m_initportmap($port)
	puts $fd "PID"
	flush $fd
	gets $fd pidstr
	set m_blockmap($idx) $pidstr
    }
    return
}

proc get_block_pid {processid} {
    variable m_blockmap

    foreach idx [array names m_blockmap] {
	if {$m_blockmap($idx) == $processid} {
	    set token [split $idx "-"]
	    set block [lindex $token 0]
	    return $block
	}
    }
    return ""
}

proc getCPUutil {idlist} {
    set tmppids [join $idlist ","]
    set rc [exec top -b -n 1 -p $tmppids]
    return $rc
}

proc Queue_data_set {block port length} {
    return "$block:$port:$length"
}

proc Queue_data_get {data p_block p_port p_length} {
    upvar $p_block block
    upvar $p_port port
    upvar $p_length length 

    set tmplist [split $data ":"]
    set block [lindex $tmplist 0]
    set port [lindex $tmplist 1]
    set length [lindex $tmplist 2]
    return 
}

proc Init {graphname} {
    variable m_initportmap
    variable m_blockmap
    variable m_connector_port
    # Content of the current graph file.
    variable m_graph

    if {[info exists m_initportmap]} {
	unset m_initportmap
    }
    array set m_initportmap {}

    if {[info exists m_blockmap]} {
	unset m_blockmap 
    }
    array set m_blockmap {}

    set m_connector_port 0

    set fd [open $graphname r]
    set m_graph [read $fd]
    close $fd
    file delete -force $graphname

    return
}

proc exec_imp {program task} {
    global env
    global tcl_platform
    # Need to check for windows or Unix.
    # tcl_platform(os)
    if {[string first "Windows" $tcl_platform(os)] > -1} {
    	#set line "exec tclsh $env(LAUNCHER_HOME)/$program $task &"
    	set line "exec ZZZ $env(LAUNCHER_HOME)/$program "

	# Kludge for the stand-alone single windows folder install.
	# Check for "package require Tk" line in the program.
	# If present, use exec wish, otherwise use exec tclsh.
	set useTk 0
	foreach {name value} $task {
	    append line "$name "
	    if {[llength $value] == 1} {
	    	append line "$value "
    	    } else {
	    	append line "\{$value\} "
    	    }
	    if {$name == "PROGRAM"} {
		set fd [open $value r]
		while {[gets $fd tmpline] > -1} {
		    set idx [string first "package require Tk" $tmpline]
		    if {$idx == -1} {
			continue
		    }
		    if {$idx != -1} {
		    	set idx2 [string first "#" $tmpline]
		    	if {$idx2 == -1} {
			    # The line "package require Tk" is present.
		    	    set useTk 1
			    break
			} else {
			    if {$idx < $idx2} {
			    	# The line "package require Tk...# " is present.
				set useTk 1
				break
			    } else {
			    	# The line "# package require Tk..." is present.
			    }
			}
		    }
		}
		close $fd
	    }
	}
	append line "&"
	if {$useTk} {
	    regsub "ZZZ" $line "wish" line
	} else { 
	    regsub "ZZZ" $line "tclsh" line
	}
	#puts "line = $line"
    	set rc [eval $line]
    } else {
    	set rc [exec $env(LAUNCHER_HOME)/$program $task &]
    }
    return $rc
}

proc Runit_Create {taskfile ipaddr p_program_data p_program_testdata} {
    variable m_connector_port
    global env
    upvar $p_program_data program_data
    upvar $p_program_testdata program_testdata

    set_block_port $taskfile $ipaddr
	array set portmap {}
    array set program_data {}
    array set program_testdata {}
    set initportlist ""
    set fd [open $taskfile r]
    while {[gets $fd task] > -1} {
	# Replace all env(..) in line with the corresponding env var value.
	set task [subst $task]
	array set temptable $task
	if {$ipaddr != [get_ipaddr $temptable(INIT)]} {
	    unset temptable
	    continue
	}
	puts "process $task"
	set mtcport [get_port $temptable(INIT)]
	if {[info exists temptable(DATA)]} {
	    set program_data($mtcport) $temptable(DATA)
	} else {
	    set program_data($mtcport) "" 
	}

	if {[info exists temptable(TESTDATA)]} {
	    set program_testdata($mtcport) $temptable(TESTDATA)
	} else {
	    set program_testdata($mtcport) ""
	}

	# Spawn each task as subprocess. The IN-ports for
	# the task will be set up when the subprocess is
	# launched.
	if {[info exists temptable(TYPE)] == 0} {
	    set rc [exec_imp rqstmgr $task]
	} else {
	    if {$temptable(TYPE) == "TX"} {
		set rc [exec_imp txmgr $task]
	    } elseif {$temptable(TYPE) == "TX_OUTONLY"} {
		set rc [exec_imp txmgr_outonly $task]
	    } elseif {$temptable(TYPE) == "RX"} {
		set rc [exec_imp rxmgr $task]
	    } elseif {$temptable(TYPE) == "LDMGR"} {
		set rc [exec_imp loadmgr $task]
	    } else {
		set rc [exec_imp rqstmgr $task]
	    }
	}
	foreach {port alloc_port} [check_ready_file $mtcport] {
	    set portmap($port) $alloc_port
	}
	# Return the allocated INIT port i.e.
	# the original init port may be localhost:9034, and the launcher
	# maps it to localhost:20100, and thus 20100 is the real INIT port.
	set mtcport [get_port $portmap($temptable(INIT))]
	
	lappend initportlist "[get_port $temptable(INIT)] $mtcport"
	# Mark the init port for the connector component.
	if {$temptable(BLOCK) == "CONNECT"} {
	    set m_connector_port $mtcport
	}
	unset temptable
    }
    close $fd
    return [list $initportlist [array get portmap]]
}

proc Runit_Update_Portmap {initportlist portmaplist} {
    variable m_initportmap

    # Now initialize each task to open the socket connection for the
    # OUT-* ports.
    foreach token $initportlist {
	    set initport [lindex $token 0]
		set allocport [lindex $token 1]
	    set fd [socket localhost $allocport]
	    fconfigure $fd -buffering line
		set m_initportmap($initport) $fd
	    puts $fd "UPDATE_PORTMAP $portmaplist"
		check_ready_file $initport
    }
    return
}

proc Runit_Enable {initportlist p_program_data} {
    variable m_initportmap
    upvar $p_program_data program_data

    # Now initialize each task to open the socket connection for the
    # OUT-* ports.
    foreach token $initportlist {
	    set initport [lindex $token 0]
		set fd $m_initportmap($initport)
		if {$program_data($initport) == ""} {
			puts $fd "ENABLE"
		} else {
			puts $fd "ENABLE $program_data($initport)"
		}
		check_ready_file $initport
    }
    return
}

proc Runit_Kick {p_program_testdata} { 
    variable m_initportmap
    upvar $p_program_testdata program_testdata

    foreach initport [array names m_initportmap] {
	if {$program_testdata($initport) == ""} {
	    continue
	}
	set fd $m_initportmap($initport)
	puts $fd "TEST $program_testdata($initport)"
    }
}

proc Runit {taskfile} {
    array set program_data {}
    array set program_testdata {}
    set initportlist [Runit_Create $taskfile abc program_data program_testdata]

    Runit_Enable $initportlist program_data

    # Query the process id for each spawned process.
    Set_Block_Pid

    Runit_Kick program_testdata
    return 
}

proc Drainit {} {
    variable m_connector_port
    variable m_initportmap

    set portlist [array names m_initportmap]
    # Arrange to have the connector port at the head of the list.
    # By doing so we guarantee all the TX components will 
    # always get an ACK when sending out IPs.
    set idx [lsearch $portlist $m_connector_port]
    set portlist [lreplace $portlist $idx $idx]
    set portlist [concat $m_connector_port $portlist]
    foreach initport $portlist {
	set fd $m_initportmap($initport)
	puts $fd "DRAIN"
	check_ready_file $initport
    }
    return
}

proc Stopit_outport {} {
    variable m_initportmap

    # close the OUT-* port for each task.
    foreach initport [array names m_initportmap] {
	set fd $m_initportmap($initport)
	puts $fd "DISABLE"
	check_ready_file $initport
    }
    return
}

proc Stopit_initport {} {
    variable m_initportmap

    # close the init port to each task. This will translate to
    # task terminte later on.
    foreach initport [array names m_initportmap] {
	set fd $m_initportmap($initport)
	close $fd
    }
    return
}

proc Stopit {} {
    Stopit_outport
    Stopit_initport
}

proc QueryQueue {} {
    variable m_initportmap
    variable m_blockmap

    set fd $m_initportmap([get_block_port CONNECT])
    puts $fd "QUEUEQUERY"
    flush $fd
    gets $fd line
    array set tmpdata $line
    set rc ""
    foreach idx [array names tmpdata] {
	# idx looks like INPORT-1-8013
	if {$tmpdata($idx) == 0} {
	    continue
	}
	set token [split $idx "-"]
	set portname [lindex $token 1]
	set blockport [lindex $token 2]
	set block [get_block $blockport]
	lappend rc "$block $portname $tmpdata($idx)"
    }
    return $rc
}

proc QueryCpu {} {
    variable m_blockmap
    global tcl_platform

    # Per process cpu utilization.
    set idlist "" 
    foreach idx [array names m_blockmap] {
	lappend idlist $m_blockmap($idx)
    }
    if {[string first "Windows" $tcl_platform(os)] > -1} {
	set rc ""
	foreach idx [array names m_blockmap] {
	    set token [split $idx "-"]
	    set block [lindex $token 0]
	    append rc "$block N/A "
	}
    } else {
    	set data [split  [getCPUutil $idlist] "\n"]
	foreach line $data {
	    if {$line == ""} {
		continue
	    }
	    set block [get_block_pid [string trim [lindex $line 0]]]
	    if {$block != ""} {
		append rc "$block [string trim [lindex $line 8]] "
	    }
	}
    }
    return [string range $rc 0 end-1] 
}

proc QueryGraph {} {
    variable m_graph

    return [list $m_graph]
}

proc check_ready_file {initport} {
    # Check for the presence of marker file before 
    # launching another task.
    set toloop 1
	set rc ""
    while {$toloop} {
		while {[SocketLock::acquire_lock "FBP_PROCESS_SYNC"] != "SOCKETLOCK_OK"} {
			after 10
		}
    	if {[file exists data_$initport.ready]} {
		    # Read the first line of the file and return the data.
			set fd [open $initport.ready r]
			gets $fd rc
			close $fd
			set toloop 0
			file delete data_$initport.ready
		}
		SocketLock::release_lock "FBP_PROCESS_SYNC"
    }
	return $rc
}

}

