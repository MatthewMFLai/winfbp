# Copyright (C) 2017 by Matthew Lai, email : mmlai@sympatico.ca
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
proc process {inport p_ip} {
    global g_view

    array set tmpdata [byList::get_list $p_ip]
	regsub "IN-" $inport "" inport
    set view $g_view($inport)
    set row [mk::row append $view]
    eval mk::set $row [array get tmpdata]
	unset tmpdata
    mk::file commit $view

    return
}

proc init {datalist} {
    global g_db
    global g_view

    # Check for %Y%m%d format in file name. If found, replace
    # it with the actual YYYYMMDD string.
    set datepattern "%Y%m%d"
    set filename [lindex $datalist 0]
    set datestr [clock format [clock seconds] -format $datepattern] 
    regsub $datepattern $filename $datestr filename
	
    mk::file open g_db $filename
    array set g_view {}
	
	# Set the layout for the tables.
	set datalist [lrange $datalist 1 end]
	foreach tokens $datalist {
		set view [lindex $tokens 0]
		set propertyfile [lindex $tokens 1]
		set map_inport [lindex $tokens 2]
		set propertylist ""
		set fd [open $propertyfile r]
		while {[gets $fd line] > -1} {
			lappend propertylist $line
		}
		close $fd
		
		set g_view($map_inport) [mk::view layout g_db.$view $propertylist]
	}
    return
}

proc shutdown {} {
    global g_db

    mk::file close g_db
    return
}

global env
source $env(COMP_HOME)/ip2/byList.tcl
global tcl_platform
if {[string first "Windows" $tcl_platform(os)] > -1} {
    package require Mk4tcl
} else {
    load Mk4tcl.so
}
global g_db
set g_db ""