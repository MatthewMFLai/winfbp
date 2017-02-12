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

proc gen_block_file {filename p_blockname_map} {
    variable m_block
    variable m_portqueue
    upvar $p_blockname_map blockname_map

    set fd [open $filename w]
    foreach systemid [array names blockname_map] {
	set displayname $blockname_map($systemid)
	block_get $systemid filename filepath init kicker inports outports \
            ipaddr timeout portset
	set line "Block "
	append line "$displayname "
	append line $filepath/$filename\.tcl
	if {$init != "" || $kicker != ""} {
	    append line " "
	    append line "\{$init\} $kicker"
	}
	puts $fd $line
	if {$inports != ""} {
	    set line "InPort "
	    append line $inports
	    puts $fd $line
	} 
	if {$outports != ""} {
	    set line "OutPort "
	    append line $outports
	    puts $fd $line
	}
	foreach port $inports {
	    set portname [gen_portname $systemid INPORT $port]
	    if {[info exists m_portqueue($portname)]} {
		puts $fd "QueueLen $port $m_portqueue($portname)"	
	    }
	}
	puts $fd "IPAddr $ipaddr"
	puts $fd "Timeout $timeout"
	if {$portset != ""} {
	    set line "Portset "
	    append line $portset
	    puts $fd $line
	}
    }
    close $fd
    return
}

proc gen_link_file {filename p_blockname_map} {
    variable m_a
    upvar $p_blockname_map blockname_map

    set fd [open $filename w]
    foreach link $m_a(edges) {
	set from_id [lindex $link 1]
	set to_id [lindex $link 2]
	
	set fromportname [get_portname $from_id]
	inv_gen_portname $fromportname fromsystemid fromporttype fromport

	set toportname [get_portname $to_id]
	inv_gen_portname $toportname tosystemid toporttype toport

	puts $fd "$blockname_map($fromsystemid) $fromport $blockname_map($tosystemid) $toport"
    }
    close $fd
    return
}

proc gen_file {win isblock} {
    global env

    set file [tk_getSaveFile]
    if {$file != ""} {
    	array set blockname_map {}
    	get_blockname_map $win "BLOCK" blockname_map
	if {$isblock} {
	    gen_block_file $file blockname_map
	} else {
	    gen_link_file $file blockname_map
	}
    }
    return
}

}

