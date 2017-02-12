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
proc get_word {} {
    global g_wordlist
    global g_count
    global .msg

    if {$g_wordlist == ""} {
    	.msg configure -text "Finish"
	return
    }
    set word [lindex $g_wordlist 0]
    set g_wordlist [lreplace $g_wordlist 0 0]
    set remain [llength $g_wordlist]
    .msg configure -text "Word: $word Remain: $remain"
    set p_ip [ip::source]
    byRetry::init $p_ip
    byRetry::set_retry $p_ip 0
    byList::init $p_ip
    byList::set_list $p_ip [list $word] 
    byList::set_crawler $p_ip "freedict" 
    server_send $p_ip OUT-1
    ip::sink $p_ip

    incr g_count
    return
}

proc process {inport p_ip} {
    set rc ""
    get_word
    return $rc
}

proc init {datalist} {
    global g_wordlist
    global g_count

    set g_count 0
    set g_wordlist ""
    set vocabfile [lindex $datalist 0]
    set fd [open $vocabfile r]
    # Ignore first line.
    gets $fd word
    while {[gets $fd word] > -1} {
	if {[string first "count =" $word] > -1} {
	    continue
	}
    	lappend g_wordlist $word
    }
    close $fd
    return
}

proc kicker {datalist} {
    get_word
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(COMP_HOME)/ip2/byRetry.tcl

package require Tk
button .msg -text OK
pack .msg

#------------------------------

#source $env(WEB_DRIVER)/loadall/loadall.tcl

