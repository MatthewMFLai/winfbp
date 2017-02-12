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
proc filter {p_ip} {
    puts "default filter"
    return ""
}

proc process {inport p_ip} {
    global g_fd

    foreach data [filter $p_ip] {
	puts $g_fd $data
    }
    return 
}

proc init {datalist} {
    global g_fd
    global g_filter

    # Check for %Y%m%d format in file name. If found, replace
    # it with the actual YYYYMMDD string.
    set datepattern "%Y%m%d"
    set filename [lindex $datalist 0]
    set datestr [clock format [clock seconds] -format $datepattern] 
    regsub $datepattern $filename $datestr filename
    set g_fd [open $filename w]
    set g_filter [lindex $datalist 1]
    if {$g_filter != ""} {
	if {[catch {source $g_filter} rc]} {
	    puts $rc
	    exit -1
	}
    }
    # Optional data for filter.
    set filterdata [lindex $datalist 2]
    if {$filterdata != ""} {
	puts $g_fd [filter_pre $filterdata]
    }
    return
}

proc shutdown {} {
    global g_fd

    close $g_fd
    return
}

global g_fd
global g_filter
set g_fd ""
set g_filter ""

