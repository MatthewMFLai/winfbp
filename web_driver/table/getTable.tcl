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
source $env(PATTERN_HOME)/geturl.tcl
source [pwd]/table_fsm.tcl
source [pwd]/custom/table_fsm_dividend.tcl
package require htmlparse

proc fsm_if {tag slash param text} {
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    #regsub -all "\n" $text "" text
    set tmpdata(tag) $tag
    set tmpdata(slash) $slash
    set tmpdata(param) $param
    set tmpdata(text) $text
    set rc [Fsm::Run table_fsm tmpdata]
    if {$rc < 0} {
	puts "rc = $rc"
	puts [Fsm::Get_Error table_fsm]
	exit -1
    }
}

proc fsm {tag slash param text} {
    global g_fd
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    regsub -all "\n" $text "" text
    puts $g_fd "tag = $tag"
    puts $g_fd "slash = $slash"
    puts $g_fd "param = $param"
    puts $g_fd "text = $text"
    puts $g_fd ""
}

# sanity mode 0: get real url data, parse with default fsm.
# sanity mode 1: get real url data, parse with custom fsm.
# sanity mode 2: get  url data from file, parse with custom fsm.
set sanity_mode 1
Url::init
 
if {$sanity_mode} {
    malloc::init
    Fsm::Init

    Fsm::Load_Fsm table_fsm.dat
    Fsm::Init_Fsm table_fsm
}


set infile [lindex $argv 0]
set sanity [lindex $argv 1]

if {$sanity_mode != 2} { 
    set in_fd [open $infile r]
    gets $in_fd url
    close $in_fd
    set data [Url::get_no_retry $url]

    # Custom code...

} else {
    set fd [open raw.dat r]
    set data [read $fd]
    close $fd
    # Custom code...
}

if {$sanity_mode == 0} {
    set fd [open raw.dat w]
    puts $fd $data
    close $fd
}

if {$sanity_mode} {
    htmlparse::parse -cmd fsm_if $data
    set tmpdata "" 
    table_fsm::Dump_Tables tmpdata
    if {$sanity != "test"} {
    	foreach table $tmpdata {
	    table_fsm::Format_Table table
    	}
    } else {
	if {[llength $tmpdata] == 0} {
	    exit -1	
	}
    }
	 
	
} else {
    set g_fd [open out.dat w]
    htmlparse::parse -cmd fsm $data
    close $g_fd
}
exit 0

