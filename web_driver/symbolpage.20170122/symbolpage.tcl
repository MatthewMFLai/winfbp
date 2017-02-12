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
namespace eval symbolpage {

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

proc doit {group page exchange p_symbollist p_symbollink} {
    upvar $p_symbollist symbollist
    upvar $p_symbollink symbollink

    set symbollist ""
    set symbollink ""

    set url_template "http://www.tmxmoney.com/TMX/HttpController?GetPage=ListedCompanyDirectory&SearchCriteria=Name&SearchKeyword=XXX&SearchType=StartWith&SearchIsMarket=Yes&Page=YYY&Market=$exchange&Language=en"

	regsub "XXX" $url_template $group url_temp
	regsub "YYY" $url_temp $page url
	#puts "Extracting group $group page $page..."
	set data [Url::get $url]
	htmlparse::parse -cmd symbolpage::fsm_if $data
	if {[Fsm::Is_In_Service symbolpage_fsm] == 1} {
	    set total_page [symbolpage_fsm::Dump_Page]
	    if {$total_page > 0} {
	    	#puts $fd [symbolpage_fsm::Dump_Symbols]
	    	#puts $fd2 [symbolpage_fsm::Dump_Link]
	    	#puts $fd3 [symbolpage_fsm::Dump_Symbollink]
	    	set symbollist [symbolpage_fsm::Dump_Symbols]
	    	set symbollink [symbolpage_fsm::Dump_Symbollink]
		regsub -all {tmx.quotemedia} $symbollink \
                    "web.tmxmoney" symbollink
	    }
	} else {
	    puts $fd "$group $page FAIL [Fsm::Get_Error symbolpage_fsm]"
	}
	Fsm::Init_Fsm symbolpage_fsm
	Fsm::Set_State symbolpage_fsm FIND_PAGE
	return $total_page
}

proc init {} {
    return
}
}

