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
namespace eval company {

variable g_url_template

proc init {url_template} {
    variable g_url_template

    set g_url_template $url_template
    return 
}

proc doit {exchange symbol url_template p_outdata} {
    upvar $p_outdata outdata

    regsub "888" $url_template $symbol tmpurl
    # Quick check.
    if {$exchange == "V"} {
	set exchange "X"
    }
    regsub "999" $tmpurl $exchange url
    if {[catch {Url::get $url} data]} {
    	set outdata(ERROR) $data 
	return 
    }

    set argdata(data) $data
    Fsm::Run company_fsm argdata
    if {[Fsm::Is_In_Service dividend_fsm] == 1} {
    	array set tmpdata {}
    	company_fsm::Dump_Company tmpdata
    	array set outdata [array get tmpdata]
    } else {
    	 set outdata(ERROR) "$symbol FAIL [Fsm::Get_Error dividend_fsm]"
    }

    Fsm::Init_Fsm dividend_fsm
    Fsm::Set_State dividend_fsm ONE

    return
}

proc extract_data {exchange symbol p_data} {
    variable g_url_template
    upvar $p_data data

    array set tmpdata {}
    doit $exchange $symbol $g_url_template tmpdata
    if {[info exists tmpdata(ERROR)] == 0} {
	array set data [array get tmpdata]
	set data(urlerror) ""
	set data(symbol) $symbol
    } else {
	set data(urlerror) $tmpdata(ERROR)
    }
    return
}

}
