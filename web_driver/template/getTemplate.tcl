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

lappend auto_path $env(DISK2)/tclkit/modules

source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(WEB_DRIVER_HOME)/template/template_fsm.tcl

set sanity_mode 1
Url::init

if {$sanity_mode} {
    malloc::init
    Fsm::Init

    Fsm::Load_Fsm template_fsm.dat
    Fsm::Init_Fsm template_fsm
}

set infile [lindex $argv 0]
set sanity [lindex $argv 1]

set in_fd [open $infile r]
gets $in_fd url
close $in_fd

if {$sanity_mode != 2} {
    set data [Url::get_no_retry $url]
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
    Fsm::Run template_fsm argdata
    array set tmpdata {}
    template_fsm::Dump_template tmpdata
    if {$sanity != "test"} {
    	foreach idx [lsort [array names tmpdata]] {
	        puts "$idx $tmpdata($idx)"
    	}
    } else {
		if {[llength [array names tmpdata]] == 0} {
			exit -1
		}
    }
}
#Fsm::Dump
exit 0
