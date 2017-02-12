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
#!/bin/sh
# \
exec tclsh $0 $@

# Test driver for testing the graph pattern class.
source graph.tcl

set max_nodes 50000
for {set i 0} {$i < $max_nodes} {incr i} {
	array set node$i {}
	graph_init_vertex node$i
	array set link$i {}
	graph_init_edge link$i
}

# Just one target node.
array set target {}
graph_init_vertex target

for {set i 0} {$i < $max_nodes} {incr i} {
	graph_add_edge node$i target link$i
}

# Test retrieve each link in turn.
for {set i 0} {$i < $max_nodes} {incr i} {
	puts [graph_get_edge node$i target]
}

# Test removing each link in turn.
for {set i [expr $max_nodes - 1]} {$i >= 0} {incr i -1} {
	if {[graph_remove_edge node$i target link$i] == 0} {
		puts "link$i removed"
	}
}

# Test unsetting each node and link in turn.
for {set i 0} {$i < $max_nodes} {incr i} {
	unset node$i
	unset link$i
}

unset target

exit 0				



