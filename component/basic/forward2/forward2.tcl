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
proc process {inport p_ip} {
    global g_outportlist
    global g_listlen
   
    regsub "IN-" $inport "OUT-" not_port
    set idx [lsearch $g_outportlist $not_port]
    set outportlist [lreplace $g_outportlist $idx $idx]
 
    # Extract the ball colour information.
    set data [byBall::get_msg $p_ip]
    global .msg
    .msg configure -text $data -foreground $data -background black
    update
    after 500
    #after [expr int(rand() * 1000)]
    .msg configure -text "yellow" -background black -foreground black
    set outport [lindex $outportlist [expr int(rand() * 100) % $g_listlen]]
    #set p_ip [ip::source]
    #byBall::init $p_ip
    #byBall::set_msg $p_ip $data
    server_send $p_ip $outport
}

proc init {datalist} {
    global g_outportlist
    global g_listlen

    set g_outportlist [get_outports]
    set g_listlen [expr [llength $g_outportlist] - 1]
    set name [lindex $datalist 0]
    if {$name != ""} {
	wm title . $name
    }
    return
}

proc kicker {datalist} {
    foreach msg $datalist {
    	set p_ip [ip::source]
    	byBall::init $p_ip
    	byBall::set_msg $p_ip $msg 
    	server_send $p_ip OUT-E
    }
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip/byBall.tcl

package require Tk
button .msg -text "yellow" -background black -foreground black

pack .msg

