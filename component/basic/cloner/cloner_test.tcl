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
    global g_rx_ports

    set ball [byBall::get_BALL $p_ip]

    global g_test_socket
    puts $g_test_socket "ball received in port $inport"
    flush $g_test_socket

    set idx [lsearch $g_rx_ports $inport]
    if {$idx > -1} {
	set g_rx_ports [lreplace $g_rx_ports $idx $idx]
    }
    if {$g_rx_ports == ""} {
        puts $g_test_socket "TEST-DRIVER-FINISH"
        flush $g_test_socket
    }
    return
}

proc init {datalist} {
    global g_test_socket
    if {$datalist != ""} {
	set g_test_socket [socket localhost [lindex $datalist 0]]
    }
}

proc kicker {datalist} {
    global g_rx_ports
    set g_rx_ports [get_inports]

    set ball [lindex $datalist 0]
    set p_ip [ip::source]
    byBall::init $p_ip
    byBall::set_BALL $p_ip $ball 
    server_send $p_ip OUT-1
}

proc shutdown {} {
    global g_test_socket
    if {$g_test_socket != ""} {
	close $g_test_socket
	set g_test_socket ""
    }
}

source $env(COMP_HOME)/ip/byBall.tcl
set g_test_socket ""

