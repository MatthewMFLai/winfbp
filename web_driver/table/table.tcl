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
namespace eval table {

proc fsm_if {tag slash param text} {
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    #regsub -all "\n" $text "" text
    set tmpdata(tag) $tag
    set tmpdata(slash) $slash
    set tmpdata(param) $param
    set tmpdata(text) $text
    Fsm::Run table_fsm tmpdata
}

proc doit {symbol p_data} {
    upvar $p_data web_data
    set rc 1
    # Extract web page with warrant or debenture data.
    set url "http://ca.dividendinvestor.com/?symbol=ZZZZ&submit=GO"
    regsub "ZZZZ" $url $symbol url 
    if {[catch {Url::get_no_retry $url} data]} {
        return -1
    }
    if {[catch {htmlparse::parse -cmd table::fsm_if $data}]} {
    	Fsm::Init_Fsm table_fsm
    	Fsm::Set_State table_fsm FIND_TABLE_END
	return -1
    }
    if {[Fsm::Is_In_Service table_fsm] == 1} {
        set tmpdata ""
        table_fsm::Dump_Tables tmpdata
	# tmpdata is just a list of records, so we need to add
	# artificial row index to the web_data array to preserve the
	# "ordering" of the records.
	set idx 0
	foreach row $tmpdata {
	    set web_data($idx) $row
	    incr idx
	}
    } else {
        set web_data(ERROR) "$symbol FAIL [Fsm::Get_Error table_fsm]"
    	Fsm::Init_Fsm table_fsm
    	Fsm::Set_State table_fsm FIND_TABLE_END
	set rc 0	
    }
    unset tmpdata
    Fsm::Init_Fsm table_fsm
    Fsm::Set_State table_fsm FIND_TABLE_END
    return $rc
}

}

