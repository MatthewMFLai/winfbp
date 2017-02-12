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
namespace eval FbpDraw {

proc block_clear {} {
    variable m_block

    unset m_block
    array set m_block {}
    return
}

proc block_check {systemid} {
    variable m_block

    if {[info exists m_block($systemid,filename)]} {
	return 1
    } else {
    	return 0
    }
}

proc block_get_all_ipaddr {} {
    variable m_block

    set rc ""
    foreach idx [array names m_block "*,ipaddr"] {
	lappend rc $m_block($idx)
    }
    return [lsort -unique $rc]
}

proc block_set_all_ipaddr {ipaddr} {
    variable m_block

    foreach idx [array names m_block "*,ipaddr"] {
	set m_block($idx) $ipaddr
    }
}

proc block_add {systemid filename filepath init kicker inports outports ipaddr timeout portset} {
    variable m_block

    if {[block_check $systemid]} {
	return
    }
    if {$ipaddr == ""} {
	set ipaddr "localhost"
    }
    set m_block($systemid,filename) $filename
    set m_block($systemid,filepath) $filepath
    set m_block($systemid,init) $init
    set m_block($systemid,kicker) $kicker
    set m_block($systemid,inports) $inports
    set m_block($systemid,outports) $outports
    set m_block($systemid,ipaddr) $ipaddr
    set m_block($systemid,timeout) $timeout

    # Passed in portset looks like {PG1 1 ON} {PG1 2 OFF} {PG2 3 OFF} {PG2 4 ON}
    # Store the port groups as a list of:
    # {<port group name> {port status} {port status} ...}
    # {PG1 {1 ON} {2 OFF}} {PG2 {3 OFF} {4 ON}}
    set m_block($systemid,portset) "" 
    if {$portset != ""} {
	array set portgrptable {}
	foreach token $portset {
	    set portgrp [lindex $token 0] 	
	    set port [lindex $token 1] 	
	    set status [lindex $token 2]
	    if {[info exists portgrptable($portgrp)]  == 0} {
		set portgrptable($portgrp) ""
	    }
	    lappend portgrptable($portgrp) [list $port $status]
	}
	foreach portgrp [array names portgrptable] {
	    set tmplist ""
	    lappend tmplist $portgrp
	    foreach port_status $portgrptable($portgrp) {
		lappend tmplist $port_status
	    }
    	    lappend m_block($systemid,portset) $tmplist
	}
    }
    return
}

proc block_get {systemid p_filename p_filepath p_init p_kicker p_inports p_outports p_ipaddr p_timeout p_portset} {
    variable m_block

    upvar $p_filename filename
    upvar $p_filepath filepath
    upvar $p_init init 
    upvar $p_kicker kicker 
    upvar $p_inports inports 
    upvar $p_outports outports
    upvar $p_ipaddr ipaddr
    upvar $p_timeout timeout
    upvar $p_portset portset 
    if {![block_check $systemid]} {
    	set filename ""
	set filepath ""
    	set init ""
    	set kicker ""
    	set inports "" 
    	set outports ""
	set ipaddr ""
	set timeout 0 
	set portset ""
	return
    }
    set filename $m_block($systemid,filename)
    set filepath $m_block($systemid,filepath)
    set init $m_block($systemid,init)
    set kicker $m_block($systemid,kicker)
    set inports $m_block($systemid,inports)
    set outports $m_block($systemid,outports)
    set ipaddr $m_block($systemid,ipaddr)
    set timeout $m_block($systemid,timeout)
    set portset $m_block($systemid,portset)
    return
}

proc block_set {systemid init kicker ipaddr timeout} {
    variable m_block

    if {![block_check $systemid]} {
	return
    }
    set m_block($systemid,init) $init
    set m_block($systemid,kicker) $kicker
    set m_block($systemid,ipaddr) $ipaddr
    set m_block($systemid,timeout) $timeout
    return
}

proc block_clone {systemid cur_systemid} {
    variable m_block
    variable m_portqueue

    if {[block_check $systemid]} {
	return
    }
    foreach idx [array names m_block "$cur_systemid,*"] {
	regsub $cur_systemid $idx $systemid newidx
	set m_block($newidx) $m_block($idx)
    }
    foreach idx [array names m_portqueue] {
	inv_gen_portname $idx blockname porttype portname
	if {$cur_systemid == $blockname} {
	    set idxnew [gen_portname $systemid $porttype $portname]
	    set m_portqueue($idxnew) $m_portqueue($idx)
	}
    }
    return
}

proc block_dump {} {
    variable m_block
	
    foreach idx [lsort [array names m_block]] {
	puts "$idx $m_block($idx)"
    }
    return
}

proc delete_block {systemid} {
    variable m_a
    variable m_block
    variable m_portmap
    variable m_portqueue

    # Need to update the edges data first since
    # get_portname() depends on m_portmap and
    # if we modify m_portmap first we get incorrect
    # results with the edge data removal!
    if {[array names m_a -exact edges] != ""} {
        set linklist "" 
        foreach i $m_a(edges) {
	    set from_id [lindex $i 1]
	    set to_id [lindex $i 2]
	    if {[string first $systemid [get_portname $from_id]] == -1 && 
	        [string first $systemid [get_portname $to_id]] == -1} {
	        lappend linklist $i
	    }
        }
	set m_a(edges) $linklist
    }

    foreach idx [array names m_block] {
	if {[string first $systemid $idx] > -1} {
	    unset m_block($idx)
	}
    }

    foreach idx [array names m_portmap] {
	inv_gen_portname $idx blockname porttype portname
	if {$systemid == $blockname} {
	    unset m_portmap($idx)
	}
    }

    foreach idx [array names m_portqueue] {
	inv_gen_portname $idx blockname porttype portname
	if {$systemid == $blockname} {
	    unset m_portqueue($idx)
	}
    }

    return
}

}

