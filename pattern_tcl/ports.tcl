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
proc set_ports {p_ports portlist} {
    upvar #0 $p_ports ports 

    # portlist must have one of the following formats
    # {IN/OUT/INIT-<port #> <socket port #> IN/OUT/INIT-<port #> <socket port #> ...}
    foreach {portname portvalue} $portlist {
	if {[string first "IN-" $portname] == -1 &&
	    [string first "OUT-" $portname] == -1 &&
	    [string first "INIT-" $portname] == -1} {
	    puts "Port name $portname is not supported."
	    continue
	}
	set idx [string first "-" $portname]
	incr idx -1
	set key [string range $portname 0 $idx]
	switch -- $key {
	    IN {
		set portidx [lsearch $ports(&IN) $portname]
		if {$portidx == -1} { 
    		    lappend ports(&IN) $portname
		    lappend ports(&IN) $portvalue
		} else {
		    incr portidx
		    set ports(&IN) [lreplace $ports(&IN) $portidx $portidx $portvalue]
		}
	    } 
	    OUT {
		set portidx [lsearch $ports(&OUT) $portname]
		if {$portidx == -1} { 
    		    lappend ports(&OUT) $portname
		    lappend ports(&OUT) $portvalue
		} else {
		    incr portidx
		    set ports(&OUT) [lreplace $ports(&OUT) $portidx $portidx $portvalue]
		}
	    } 
	    INIT {
		set portidx [lsearch $ports(&INIT) $portname]
		if {$portidx == -1} { 
    		    lappend ports(&INIT) $portname
		    lappend ports(&INIT) $portvalue
		} else {
		    incr portidx
		    set ports(&INIT) [lreplace $ports(&INIT) $portidx $portidx $portvalue]
		}
	    }
	}
    }
}

proc get_port {p_ports portname} {
    upvar #0 $p_ports ports 
    set portvalue ""

    # portname must have one of the following formats
    # IN/OUT/INIT-<port #>
    if {[string first "IN-" $portname] == -1 &&
    	[string first "OUT-" $portname] == -1 &&
    	[string first "INIT-" $portname] == -1} {
    	puts "Port name $portname is not supported."
	return $portvalue 
    }
    set idx [string first "-" $portname]
    incr idx -1
    set key [string range $portname 0 $idx]
    switch -- $key {
   	IN {
	    set portidx [lsearch $ports(&IN) $portname]
	    if {$portidx > -1} { 
		incr portidx
	    	set portvalue [lindex $ports(&IN) $portidx]
	    }
    	} 
	OUT {
	    set portidx [lsearch $ports(&OUT) $portname]
	    if {$portidx > -1} { 
		incr portidx
		set portvalue [lindex $ports(&OUT) $portidx]
	    }
	} 
	INIT {
	    set portidx [lsearch $ports(&INIT) $portname]
	    if {$portidx > -1} { 
	    	incr portidx
	    	set portvalue [lindex $ports(&INIT) $portidx]
	    }
    	}
    }
    return $portvalue
}

proc init_ports {p_ports} {
    upvar #0 $p_ports ports 
    set ports(&IN) ""
    set ports(&OUT) ""
    set ports(&INIT) ""
}

