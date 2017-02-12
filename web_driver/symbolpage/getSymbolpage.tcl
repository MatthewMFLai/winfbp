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
source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/getphantomjsurl.tcl
source $env(WEB_DRIVER_HOME)/symbolpage/symbolpage_fsm.tcl

set sanity_mode 1 
PhantomjsUrl::init

if {$sanity_mode} {
	malloc::init
	Fsm::Init

	Fsm::Load_Fsm symbolpage_fsm.dat
	Fsm::Init_Fsm symbolpage_fsm
	Fsm::Set_State symbolpage_fsm FIND_PAGE
}

proc fsm_if {tag slash param text} {
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    #regsub -all "\n" $text "" text
    set tmpdata(tag) $tag
    set tmpdata(slash) $slash
    set tmpdata(param) $param
    set tmpdata(text) $text
    Fsm::Run symbolpage_fsm tmpdata
}

set infile [lindex $argv 0]
set sanity [lindex $argv 1]

set in_fd [open $infile r]
set url [read $in_fd]
close $in_fd

if {$sanity_mode != 2} { 
	set data [PhantomjsUrl::get_no_retry $url]
}
if {$sanity_mode == 0} {
    set fd [open raw.dat w]
    puts $fd $data
    close $fd
} elseif {$sanity_mode == 2} {
    set fd [open raw.dat r]
    set data [read $fd]
    close $fd
} else {

}

if {$sanity_mode} {
    set argdata(data) $data
    Fsm::Run symbolpage_fsm argdata
    set linklist [symbolpage_fsm::Dump_Link]
    set symbollist [symbolpage_fsm::Dump_Symbols]
    set symbollink [symbolpage_fsm::Dump_Symbollink]
    if {$sanity != "test"} {
		puts $symbollist 
    } else {
    	if {[llength $symbollist] == 0} {
			exit -1 
		}
    }
}
exit 0

