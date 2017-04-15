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
namespace eval dividend {

variable g_url_template
variable g_mapper

proc star_to_value {datastr} {
	if {$datastr == "" || $datastr == "nul"} {
		return 0
	} elseif {$datastr == "*"} {
		return 1
	} elseif {$datastr == "* *"} {
		return 2
	} elseif {$datastr == "* * *"} {
		return 3
	} elseif {$datastr == "* * * *"} {
		return 4
	} elseif {$datastr == "* * * * *"} {
		return 5
	} else {
		return 0
	}
}

proc init {url_template p_mapper} {
    variable g_url_template
    variable g_mapper
    upvar $p_mapper mapper

    set g_url_template $url_template
    array set g_mapper [array get mapper]
    return 
}

proc fsm_if {tag slash param text} {
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    #regsub -all "\n" $text "" text
    set tmpdata(tag) $tag
    set tmpdata(slash) $slash
    set tmpdata(param) $param
    set tmpdata(text) $text
    Fsm::Run dividend_fsm tmpdata
}

proc doit {cur_symbol url_template p_mapper p_out_symbol p_outdata} {
    upvar $p_outdata outdata
    upvar $p_mapper mapper
    upvar $p_out_symbol out_symbol

    # This is kludgy code. Let me explain.
    # The dividend website does not map .UN to _U always.
    # Most of the time it is .UN to _U, but sometimes it is 
    # .UN to __U, or even to ___U. To handle the ambiguity,
    # the symbol.map is constructed as a map from say
    # .UN to {_U __U ___U}
    # and we just go through all the mappings and pick the one
    # that parses with the valid "paidsince" data.
    # Also, we need to handle the case where the symbol has no .UN,
    # so we just initialize suffix and suffixlist to "none", and
    # the foreach loop will simple just execute once there.
    set suffixlist "none"
    set suffix "none"
    foreach token [array names mapper] {
	if {[string first $token $cur_symbol] > -1} {
	    set suffixlist $mapper($token)
	    set suffix $token
	    break
	}
    }

    foreach newsuffix $suffixlist {

    	regsub $suffix $cur_symbol $newsuffix symbol
    	regsub "XXX" $url_template $symbol url
	if {[catch {Url::get $url} data]} {
	    puts "dividend error: $url"
	    continue
	}
    	htmlparse::parse -cmd dividend::fsm_if $data
    	set paidsince ""
    	if {[Fsm::Is_In_Service dividend_fsm] == 1} {
    	    array set tmpdata {} 
    	    dividend_fsm::Dump_Dividend tmpdata
    	    foreach idx [array names tmpdata] {
	    	if {[string first "Paid Since" $idx] > -1} {
	    	    set paidsince $tmpdata($idx)
		    break 
	    	}
	    }
	    if {$paidsince == "None"} {
    	    	Fsm::Init_Fsm dividend_fsm
    	    	Fsm::Set_State dividend_fsm FIND_TABLE_END
		unset tmpdata
	    	continue
	    }
	    array set outdata [array get tmpdata]
    	} else {
    	    set outdata(ERROR) "$symbol FAIL [Fsm::Get_Error dividend_fsm]"
	    break
    	}
    	Fsm::Init_Fsm dividend_fsm
    	Fsm::Set_State dividend_fsm FIND_TABLE_END
	set out_symbol $symbol
    	return
    }
    if {![info exists outdata(ERROR)]} {
    	set outdata(ERROR) "$symbol FAIL no dividend symbol found"
    }
    return
}

proc extract_data {cur_symbol p_data} {
    variable g_url_template
    variable g_mapper
    upvar $p_data data

    set symbol "" 
    array set tmpdata {}
    doit $cur_symbol $g_url_template g_mapper symbol tmpdata
    if {[info exists tmpdata(ERROR)] == 0} {
	array set data [array get tmpdata]
	
	# Kludge: convert the star * to value
	set idx "Dividend AllStar Ranking:"
	if {[info exists data($idx)]} {
		set data($idx) [star_to_value $data($idx)]
	}
	# Kludge: end
	
	set data(urlerror) ""
	set data(symbol) $cur_symbol
	set data(symbol_div) $symbol
    } else {
	set data(urlerror) $tmpdata(ERROR)
    }
    return
}

}

