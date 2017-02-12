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
namespace eval FbpMgr {

variable m_port
variable m_ip_prefix
variable m_ip_array

proc Init {ip_prefix port} {
    variable m_port
    variable m_ip_prefix

    set m_port $port
    set m_ip_prefix $ip_prefix
    return
}

proc getip {} {
    variable m_ip_array
    
    return [array names m_ip_array]
}

proc get_graph_ids {p_data} {
    variable m_ip_array
    upvar $p_data data

    foreach ipaddr [array names m_ip_array] {
	foreach graph_id $m_ip_array($ipaddr) {
	    if {![info exists data($graph_id)]} {
		set data($graph_id) ""
	    }	
	    lappend data($graph_id) $ipaddr
	}
    }
    return
}

proc checkip {ipaddr port} {
    variable m_ip_array

    set dot "."
    puts "scanning $ipaddr..."
    if {[catch {socket $ipaddr $port} fd]} {
    	return 
    }
    puts $fd "IDENT $ipaddr"
    flush $fd
    gets $fd resp
    if {[lindex $resp 0] != "DONE"} {
     # if {$resp != "DONE"} 
    	close $fd
    	return 
    }
    set m_ip_array($ipaddr) [lindex $resp 1]
    puts "$ipaddr service available"
    close $fd
    return
}

proc Sweep {start stop} {
    variable m_port
    variable m_ip_prefix
    variable m_ip_array

    # Clean the ip array first.
    foreach idx [array names m_ip_array] {
	unset m_ip_array($idx)
    }

    set dot "."
    for {set i $start} {$i < $stop} {incr i} {
	set ipaddr $m_ip_prefix$dot$i
	checkip $ipaddr $m_port
    }

    # Check localhost if ip array is empty.
    if {[array names m_ip_array] == ""} {
	checkip "localhost" $m_port
    }	
    return
}

proc send_one_file {name host port} {
    set size [file size $name]
    set fp [open $name r]
    fconfigure $fp -translation binary

    set channel [socket $host $port]
    fconfigure $channel -translation binary
    # Strip the directory prefix from file name.
    set idx [string last "/" $name]
    incr idx
    set filename [string range $name $idx end]
    puts $channel [list $filename $size]

    fcopy $fp $channel -size $size

    close $fp
    close $channel
}

proc bcast_send_file {filename ipaddrlist port} {
    variable m_ip_array

    foreach ipaddr $ipaddrlist {
	if {![info exists m_ip_array($ipaddr)]} {
	    return "$ipaddr not in sweep set \([array names m_ip_array]\)"
	}
	puts "sending $filename $ipaddr $port"
	send_one_file $filename $ipaddr $port
    }
    return "" 
}
	
}

