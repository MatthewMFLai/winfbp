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
source cc.tcl
source pvc.tcl

array set node {}
set node(portlist) ""
set node(cclist) ""

proc create_cc {numofports} {
	global node

	set region1 [list "0 0" "19 19"]
	set region2 [list "30 30" "49 49"]
	set region3 [list "60 60" "99 99"]
	set region4 [list "100 100" "499 499"]

	# Create trunk port first. 
	global port$numofports
	array set port$numofports {}
	pvc::idpool_init_member port$numofports
	pvc::idpool_add_region port$numofports $region1
	pvc::idpool_add_region port$numofports $region2
	pvc::idpool_add_region port$numofports $region3
	pvc::idpool_add_region port$numofports $region4
	cc::graph_init_vertex port$numofports

	# Add port variable name to node.
	lappend node(portlist) port$numofports

	# Create each edge port and each cross connect.
	for {set i 0} {$i < $numofports} {incr i} {
		set portname port$i
		set ccname cc$i

		global $portname
		global $ccname
 
		array set $portname {}
		pvc::idpool_init_member $portname
		pvc::idpool_add_region $portname $region1
		cc::graph_init_vertex $portname

		array set $ccname {}
		cc::graph_init_vertex $ccname
		
		# Get the next available end point from edge port
		# and from trunk port.

		set endpt [pvc::idpool_alloc_next_id $portname]
		set ${ccname}(a_endpt) $endpt
		set endpt [pvc::idpool_alloc_next_id port$numofports]	
		set ${ccname}(z_endpt) $endpt

		# Add the cross connect between two ports.
		cc::graph_add_edge $portname port$numofports $ccname

		# Add variable names to node.
		lappend node(portlist) $portname
		lappend node(cclist) $ccname
	}
}

proc save_cc {numofports filename} {
	global node

	set fd [open $filename w]
	foreach portname $node(portlist) { 
		upvar #0 $portname portalias

		puts $fd [list global $portname]
		puts $fd [list array set $portname [array get portalias]]
	}

	foreach ccname $node(cclist) { 
		upvar #0 $ccname ccalias

		puts $fd [list global $ccname]
		puts $fd [list array set $ccname [array get ccalias]]
	}

	# Save node
	puts $fd [list global node]
	puts $fd [list array set node [array get node]]

	close $fd
}

proc save_cc_old {numofports filename} {
	set fd [open $filename w]
	for {set i 0} {$i < $numofports} {incr i} {
		set portname port$i
		set ccname cc$i

		upvar #0 $portname portalias
		upvar #0 $ccname ccalias

		puts $fd [list global $portname]
		puts $fd [list array set $portname [array get portalias]]
		puts $fd [list global $ccname]
		puts $fd [list array set $ccname [array get ccalias]]
	}
	set portname port$numofports
	upvar #0 $portname portalias

	puts $fd [list global $portname]
	puts $fd [list array set $portname [array get portalias]]
	close $fd
}

proc load_cc {filename} {
	source $filename
}

