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
# Substitue <assoc> with the name of the
# pattern instance.
# Substitue <whole> and <part> with the
# names of the application structures.
proc add_node {p_parent p_node} {
    upvar #0 $p_parent parent
    upvar #0 $p_node node 

    set node(&parent_ref) $p_parent
    lappend parent(&child_list) $p_node
}

proc remove_node {p_parent p_node} {
    upvar #0 $p_parent parent 
    upvar #0 $p_node node
    set idx 0

    foreach p_tmpnode $parent(&child_list) {
	if {$p_node == $p_tmpnode} {
	    set parent(&child_list) [lreplace $parent(&child_list) $idx $idx]
	    set node(&parent_ref) ""
	    # Recursively remove the parent/child relationship data.
	    if {$node(&child_list) == ""} {
	    	return 1
	    }
	    foreach p_child $node(&child_list) {
		remove_node $p_node $p_child
	    }
	    return 1 
	}
	incr idx
    }
    return 0
}

# Return 1 if common parent is found for the two nodes,
#        0 otherwise.
# Return the up path and down path found.
# If the from node is a, and to node is z, and
# the complete up path is a -> b -> c -> d -> e
# and the complete down path is e -> d -> c -> y -> z
# then the returned up path is {a b}
# and the returned down path is {y z}
proc diff_nodes {p_from_node p_to_node p_up_path p_down_path} {
    upvar #0 $p_from_node from_node
    upvar #0 $p_to_node to_node
    upvar $p_up_path up_path
    upvar $p_down_path dn_path

    set rc 0
    set up_path ""
    set dn_path ""

    # Construct complete up path first.
    set up_path $p_from_node
    set p_cur_node $p_from_node
    while {1} {
	upvar #0 $p_cur_node cur_node
	if {$cur_node(&parent_ref) == ""} {
	    break
	}
	set p_cur_node $cur_node(&parent_ref)
	lappend up_path $p_cur_node
    }

    # Construct complete down path first.
    set dn_path $p_to_node
    set p_cur_node $p_to_node
    while {1} {
	upvar #0 $p_cur_node cur_node
	if {$cur_node(&parent_ref) == ""} {
	    break
	}
	set p_cur_node $cur_node(&parent_ref)
	lappend dn_path $p_cur_node
    }

    #puts "complete up path: $up_path"
    #puts "complete dn path: $dn_path"

    set up_idx 0
    set dn_idx -1
    set up_path_len [llength $up_path]
    for {set up_idx 0} {$up_idx < $up_path_len} {incr up_idx} {
	set p_node [lindex $up_path $up_idx]
	set dn_idx [lsearch $dn_path $p_node]
	if {$dn_idx != -1} {
	    break 
	}
    }
    if {$dn_idx == -1} {
	# Common parent not found!
	return $rc
    }
    # Trim the up path.
    incr up_idx -1
    set up_path [lrange $up_path 0 $up_idx]
    # Trim the down path.
    incr dn_idx -1
    set dn_path [lrange $dn_path 0 $dn_idx]
    # Invert the down path.
    set tmp_path ""
    foreach p_node $dn_path {
	set tmp_path [linsert $tmp_path 0 $p_node]
    }
    set dn_path $tmp_path

    return 1    
}

proc depth_first {p_node} {
    upvar #0 $p_node node 

    set child_rc_list ""
    foreach p_child $node(&child_list) {
	lappend child_rc_list [depth_first $p_child]
    }
    catch {$node(&callback) $p_node $child_rc_list} rc
    return $rc  
}

proc get_parent {p_node} {
    upvar #0 $p_node node

    return $node(&parent_ref)
}

proc get_iterator {p_node} {
    upvar #0 $p_node node 

    return $node(&child_list)
}

proc set_callback {p_node procname} {
    upvar #0 $p_node node

    set node(&callback) $procname
}

proc init_node {p_node} {
    upvar #0 $p_node node 
    set node(&child_list) ""
    set node(&parent_ref) ""
    set node(&callback) ""
}

