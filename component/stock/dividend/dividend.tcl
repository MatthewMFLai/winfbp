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
proc process_dividend {url p_data} {
    upvar $p_data data

    array set tmpdata $url
    if {$tmpdata(Yield) == "N/A"} {
	set data(urlerror) "N/A"
	return
    }

    set cur_symbol $tmpdata(fundamental_symbol)
    dividend::extract_data $cur_symbol data

    if {$data(urlerror) != ""} {
	if {[string first "no dividend symbol found" $data(urlerror)] > 0} {
	    set data(urlerror) "N/A"
	}
	return
    }
}

proc init_dividend {arglist} {
    global env

    set filename [lindex $arglist 0]
    if {[UtilSys::Is_Runtime] == 0} {
    	set fd [open $env(WEB_DRIVER)/dividend/$filename r]
    } else {
    	set fd [open [UtilSys::Get_Path]/web_driver/dividend/$filename r]
    }	
    gets $fd url_template
    close $fd

    # Set up symbol suffix mapper.
    set filename [lindex $arglist 1]
    if {[UtilSys::Is_Runtime] == 0} {
    	set fd [open $env(WEB_DRIVER)/dividend/$filename r]
    } else {
    	set fd [open [UtilSys::Get_Path]/web_driver/dividend/$filename r]
    }	
    while {[gets $fd line] > -1} {
        set mapper([lindex $line 0]) [lrange $line 1 end]
    }
    close $fd

    dividend::init $url_template mapper
    return
}

proc shutdown_dividend {} {
}

