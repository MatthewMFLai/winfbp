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

set crawler "dividend"
loadeach $env(WEB_DRIVER) $crawler

# Extract url template.
set fd [open [lindex $argv 2] r]
gets $fd url_template
close $fd

# Set up symbol suffix mapper.
set fd [open [lindex $argv 3] r]
while {[gets $fd line] > -1} {
    set mapper([lindex $line 0]) [lrange $line 1 end]
}
close $fd

${crawler}::init $url_template mapper

set infile [lindex $argv 0]
set outfile [lindex $argv 1]
set fd [open $infile r]
set fd2 [open $outfile w]
while {[gets $fd line] > -1} {
    if {[lindex $line 2] == "N/A"} {
	continue	
    }

    set cur_symbol [lindex $line 0]
    set rc [${crawler}::extract_data $cur_symbol]
    set urlerror [lindex $rc end]
    if {$urlerror == ""} {
	set symbol [lindex $rc 0]
    	set yield [lindex $rc 1] 
    	set yield5yr [lindex $rc 2] 
    	set paidsince [lindex $rc 3] 
	puts "$symbol $yield $yield5yr $paidsince"
	puts $fd2 "$symbol $yield $yield5yr $paidsince"
	flush $fd2
    } else {
   	puts $urlerror 
    }
}
close $fd
close $fd2
exit 0

