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
    global g_freeze

    set data [ip::serialize $p_ip]
  
    global .msg
    .msg insert end $data\n
    server_send $p_ip OUT-1
    if {$g_freeze == 0} {
    	.msg see end
    }
}

proc init {datalist} {
}

proc shutdown {} {
}

global g_freeze
set g_freeze 0

package require Tk
button .button -text Clear -command {
    .msg delete 1.0 end
}
button .button2 -text F -command {
    global g_freeze
    if {$g_freeze} {
	set g_freeze 0
    } else {
	set g_freeze 1
    }
}

text .msg -width 40 -height 5 -wrap none \
    -xscrollcommand {.xsbar set} \
    -yscrollcommand {.ysbar set}
scrollbar .xsbar -orient horizontal -command {.msg xview}
scrollbar .ysbar -orient vertical -command {.msg yview}
grid .button .button2 -sticky nsew
grid .msg .ysbar -sticky nsew
grid .xsbar -sticky nsew
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

