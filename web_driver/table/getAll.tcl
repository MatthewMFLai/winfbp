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
exec tclsh $0 "$@"
package require htmlparse
source $env(PATTERN_HOME)/malloc.tcl
malloc::init
source $env(WEB_DRIVER)/loadall/loaddir.tcl
source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/geturl.tcl
Url::init
Fsm::Init
set crawler "table"
loadeach $env(WEB_DRIVER)  $crawler

set infile [lindex $argv 0]
set outfile [lindex $argv 1]
set filterfile [lindex $argv 2]

set linelist ""
if {$filterfile != ""} {
    set fd [open $filterfile r]
    while {[gets $fd line] > -1} {
	lappend linelist $line
    }
    close $fd
}
 
set fd [open $infile r]
set fd2 [open $outfile w]
gets $fd url
array set web_data {}
${crawler}::doit $url web_data
if {[info exists web_data(ERROR)]} {
    puts $web_data(ERROR)
    exit -1 
}
foreach idx [lsort -integer [array names web_data]] {
    set toskip 0
    foreach line $linelist {
	if {[string first $line $web_data($idx)] > -1} {
	    set toskip 1 
	}
    }
    if {$toskip} {
	continue	
    }
    puts $web_data($idx) 
    puts $fd2 $web_data($idx)
}

close $fd
close $fd2

exit 0

