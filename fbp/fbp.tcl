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
foreach filename [glob $env(FBP_HOME)/gencode/simple/*.tcl] {
    source $filename
}   
foreach filename [glob $env(FBP_HOME)/gencode/complex/*.tcl] {
    source $filename
}
foreach filename [glob $env(FBP_HOME)/gencode/dynamic_type/*.tcl] {
    source $filename
}

namespace eval FlowGraph {

    variable g_graph

proc Init_Graph {} {

    variable g_graph

    # Initiailize the graph object first.
    set g_graph [malloc::getmem]
    init_Main $g_graph
}

proc init_block {p_node name issubcircuit data} {

    variable g_graph
    set program_name [lindex $data 0]
    set program_data [lindex $data 1]
    set program_testdata [lindex $data 2]

    # Initiailize the block first.
    init_Block $p_node
    byBlock::set_name $p_node $name
    byBlock::set_is_subcircuit $p_node $issubcircuit 
    byBlock::set_program_name $p_node $program_name
    byBlock::set_program_data $p_node $program_data
    byBlock::set_program_testdata $p_node $program_testdata
    byMain_Block::set_key $p_node $name
    byMain_Block::add_part $g_graph $p_node
}

proc init_port {p_port name isvport in_out hostipaddr} {

    variable g_graph

    # Initiailize the port first.
    init_Port $p_port
    byPort::set_id $p_port $name
    byPort::set_is_vport $p_port $isvport 
    byPort::set_hostipaddr $p_port $hostipaddr
    byBlock_$in_out\Port::set_key $p_port $name
}

proc init_portgrp {p_group name} {

    variable g_graph

    # Initiailize the port first.
    init_Portgrp $p_group
    byPortgrp::set_name $p_group $name
}

proc Create_Object {type name data} {
    variable g_graph

    switch -- $type \
	Block {
	    set p_node [malloc::getmem]
	    init_block $p_node $name 0 $data 
	    return $p_node

    }   Subcircuit { 
	    set p_node [malloc::getmem]
	    init_block $p_node $name 1 $data 
	    return $p_node

    }   InPort {
	    set p_port [malloc::getmem]
	    init_port $p_port $name 0 "In" $data
	    return $p_port

    }   InVport {
	    set p_port [malloc::getmem]
	    init_port $p_port $name 1 "In" $data
	    return $p_port

    }   OutPort {
	    set p_port [malloc::getmem]
	    init_port $p_port $name 0 "Out" $data
	    return $p_port

    }   OutVport {
	    set p_port [malloc::getmem]
	    init_port $p_port $name 1 "Out" $data
	    return $p_port

    }   Portgrp {
	    set p_group [malloc::getmem]
	    init_portgrp $p_group $name
	    return $p_group

    }   default {
	    puts "Unknow object type $type" 
	    return "" 
    }
}

proc Get_Socketport {to_block_name in_port_id} {
    variable g_graph

    set p_to_block [byMain_Block::get_part $g_graph $to_block_name]
    Assert::Assert $p_to_block
    set p_in_port [byBlock_InPort::get_part $p_to_block $in_port_id]
    Assert::Assert $p_in_port
    return [byPort::get_socketport $p_in_port]

}

proc Get_Group_Port {p_block in_port_id status} {

    set p_in_port [byBlock_InPort::get_part $p_block $in_port_id]
    Assert::Assert $p_in_port
    byPort::set_def_grp_status $p_in_port $status 
    return $p_in_port

}
proc Set_Timeout {p_block timeout} {
    byBlock::set_timeout $p_block $timeout
}

proc Set_Portgrp {p_block p_group} {
    byBlock_Portgrp::add_part $p_block $p_group
}

proc Add_To_Portgrp {p_group p_port} {
    byPortgrp_Port::add_part $p_group $p_port
}

proc Set_IPAddr {p_block ipaddr} {
    byBlock::set_ip_addr $p_block $ipaddr 
}

proc Set_InPort {p_block p_port} {
    byBlock_InPort::add_part $p_block $p_port
}

proc Set_OutPort {p_block p_port} {
    byBlock_OutPort::add_part $p_block $p_port
}

proc Set_Subcircuit {p_subcircuit p_block} {
    byBlock_Subcircuit::add_part $p_subcircuit $p_block
}

proc Set_Vport_Port_Link {p_vport p_port} {
    byVport_Port::add_rel $p_vport $p_port
}

proc Set_Linkage {from_block_name out_port_id to_block_name in_port_id socketport} {
    variable g_graph

    set p_from_block [byMain_Block::get_part $g_graph $from_block_name]
    Assert::Assert $p_from_block
    set p_out_port [byBlock_OutPort::get_part $p_from_block $out_port_id]
    Assert::Assert $p_out_port

    set p_to_block [byMain_Block::get_part $g_graph $to_block_name] 
    Assert::Assert $p_to_block
    set p_in_port [byBlock_InPort::get_part $p_to_block $in_port_id]
    Assert::Assert $p_in_port

    byInPort_OutPort::add_rel $p_out_port $p_in_port

    byPort::set_socketport $p_out_port $socketport
    while {[byPort::get_is_vport $p_out_port]} {
	set p_out_port [byVport_Port::get_rel $p_out_port]
    	Assert::Assert $p_out_port
    	byPort::set_socketport $p_out_port $socketport
    }

    byPort::set_socketport $p_in_port $socketport
    while {[byPort::get_is_vport $p_in_port]} {
	set p_in_port [byVport_Port::get_rel $p_in_port]
    	Assert::Assert $p_in_port
    	byPort::set_socketport $p_in_port $socketport
    }
}

proc Set_Mtc_Port {socketport} {
    variable g_graph

    foreach p_block [byMain_Block::get_iterator $g_graph] {
	Assert::Assert $p_block
	if {[byBlock::get_is_subcircuit $p_block]} {
	    byBlock::set_mtc_port $p_block 0
	} else {
	    byBlock::set_mtc_port $p_block $socketport
	    incr socketport
	    foreach p_port [byBlock_InPort::get_iterator $p_block] {
		Assert::Assert $p_port
		if {[byPort::get_socketport $p_port] == ""} {
		    byPort::set_socketport $p_port $socketport
	    	    incr socketport
		}
	    }
	}
    }
}
 
proc Set_Port_Queuelen {block_name in_port_id queuelen} {
    variable g_graph

    set p_block [byMain_Block::get_part $g_graph $block_name] 
    Assert::Assert $p_block
    set p_in_port [byBlock_InPort::get_part $p_block $in_port_id]
    Assert::Assert $p_in_port

    byPort::set_queuelen $p_in_port $queuelen
    return
}

proc Get_Block_Ports {} {
    variable g_graph

    set blocklist ""
    foreach p_block [byMain_Block::get_iterator $g_graph] {
	Assert::Assert $p_block
	if {[byBlock::get_is_subcircuit $p_block]} {
	    continue 
	}
	set ipaddr [byBlock::get_ip_addr $p_block]
	set blockdata ""
	append blockdata "BLOCK [byBlock::get_name $p_block] "
	append blockdata "INIT $ipaddr:[byBlock::get_mtc_port $p_block] "
	foreach p_port [byBlock_InPort::get_iterator $p_block] {
	    Assert::Assert $p_port
	    if {[byPort::get_socketport $p_port] == ""} {
		continue
	    }
	    set port [byPort::get_socketport $p_port]
	    set id [byPort::get_id $p_port]
	    append blockdata "IN-$id $ipaddr:$port "

	    # Handle per port queue length.
	    set queuelen [byPort::get_queuelen $p_port]
	    if {$queuelen != ""} {
		append blockdata "QUEUE-$id $queuelen "
	    }
	}
	foreach p_port [byBlock_OutPort::get_iterator $p_block] {
	    Assert::Assert $p_port
	    if {[byPort::get_socketport $p_port] == ""} {
		continue
	    }

	    # Find out the ipaddr of the to-block.
	    set p_to_port [byInPort_OutPort::get_rel $p_port]
	    Assert::Assert $p_to_port
	    set p_to_block [byBlock_InPort::get_whole $p_to_port]
	    Assert::Assert $p_to_block
	    set to_ipaddr [byBlock::get_ip_addr $p_to_block]

	    set port [byPort::get_socketport $p_port]
	    set id [byPort::get_id $p_port]
	    append blockdata "OUT-$id $to_ipaddr:$port "
	}

        set tmpidx 1
	foreach p_group [byBlock_Portgrp::get_iterator $p_block] {
	    Assert::Assert $p_group
	    set name [byPortgrp::get_name $p_group]
	    foreach p_port [byPortgrp_Port::get_iterator $p_group] {
	        Assert::Assert $p_port
    		set status [byPort::get_def_grp_status $p_port]

	    	set id [byPort::get_id $p_port]
	    	append blockdata "PORTSET-$tmpidx \{IN-$id $name $status\} "
		incr tmpidx
            }
	}

	append blockdata "PROGRAM [byBlock::get_program_name $p_block]"
	if {[byBlock::get_program_data $p_block] != ""} {
	    append blockdata " DATA [list [byBlock::get_program_data $p_block]]"
	}
	if {[byBlock::get_program_testdata $p_block] != ""} {
	    append blockdata " TESTDATA [list [byBlock::get_program_testdata $p_block]]"
	}
	append blockdata " TIMEOUT [byBlock::get_timeout $p_block]"
	lappend blocklist $blockdata 
    }
    return $blocklist
} 

proc Dump {} {
    variable g_graph

    foreach p_block [byMain_Block::get_iterator $g_graph] {
	Assert::Assert $p_block
	puts "Block [byBlock::get_name $p_block] mtc-port [byBlock::get_mtc_port $p_block]"
	foreach p_port [byBlock_InPort::get_iterator $p_block] {
	    Assert::Assert $p_port
	    puts "Input port [byPort::get_id $p_port] socketport [byPort::get_socketport $p_port]"
	    set fromportlist [byInPort_OutPort::get_rel $p_port]
	    foreach p_from_port $fromportlist {
		Assert::Assert $p_from_port
		set p_from_block [byBlock_OutPort::get_whole $p_from_port]
		Assert::Assert $p_from_block
		puts "  Block [byBlock::get_name $p_from_block] Outport [byPort::get_id $p_from_port] socketport [byPort::get_socketport $p_from_port]"
	    }
	}
	foreach p_port [byBlock_OutPort::get_iterator $p_block] {
	    Assert::Assert $p_port
	    puts "Output port [byPort::get_id $p_port] socketport [byPort::get_socketport $p_port]"
	    set toportlist [byInPort_OutPort::get_rel $p_port]
	    foreach p_to_port $toportlist {
		Assert::Assert $p_to_port
		set p_to_block [byBlock_InPort::get_whole $p_to_port]
		Assert::Assert $p_to_block
		puts "  Block [byBlock::get_name $p_to_block] Inport [byPort::get_id $p_to_port] socketport [byPort::get_socketport $p_to_port]"
	    }
	}
    }
}

proc Save_Graph {filename} {
    variable g_graph
    malloc::set_var flow_graph $g_graph
    malloc::save $filename
}

proc Load_Graph {filename} {
    variable g_graph
    malloc::restore $filename
    set g_graph [malloc::get_var flow_graph]
}

}

