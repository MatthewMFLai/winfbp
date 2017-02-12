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
namespace eval symbolpage_fsm {

variable gSymbolpage
variable gCompany
variable gCompanylink
variable gSymbollink
variable gSymbollist

variable m_text
variable m_param
variable m_slash
variable m_tag

proc init {} {
    variable gSymbolpage
    variable gCompany
    variable gCompanylink
    variable gSymbollink
    variable gSymbollist
    
    variable m_text
    variable m_param
    variable m_slash
    variable m_tag

    if {[info exist gSymbolpage]} {
	unset gSymbolpage
    } 
    array set gSymbolpage {page 1}
    set gCompany ""
    set gCompanylink ""
    set gSymbollink ""
    set gSymbollist ""

    set m_text ""
    set m_param ""
    set m_slash ""
    set m_tag ""
}

proc process_generic {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_text
    variable m_param
    variable m_slash
    variable m_tag

    set m_text $arg_array(text)
    set m_param $arg_array(param)
    set m_slash $arg_array(slash)
    set m_tag $arg_array(tag)
    return
}

proc eval_page_to_exchange {} {
    variable gSymbolpage
    variable m_text
    if {[string match "Page * of *" $m_text]} {
	return 1
    }
    return 0
}

proc eval_to_company {} {
    variable m_text
    if {[string first "Exchange" $m_text] == 0} {
	return 1	
    }
    return 0
}

proc eval_company_to_symbol {} {
    variable m_param
    variable m_tag
    if {$m_tag == "a" &&
        [string first "company.php" $m_param] > 0} {
	return 1	
    }
    return 0
}

proc eval_symbol_to_symbol {} {
    variable m_param
    variable m_tag
    if {$m_tag == "a" &&
        [string first "quote.php" $m_param] > 0} {
	return 1	
    }
    return 0
}

proc eval_symbol_to_company {} {
    variable m_param
    variable m_tag
    if {$m_tag == "th" &&
        [string first "symbolGroup" $m_param] > 0} {
	return 1	
    }
    return 0
}

proc eval_symbol_to_terminate {} {
    variable m_text
    variable m_tag
    variable m_slash

    if {[string first "&nbsp;" $m_text] == 0} {
	return 1	
    }
    if {$m_tag == "table" &&
        $m_slash == "/"} {
	return 1	
    }
    return 0
}

proc act_page_to_exchange {} {
    variable m_text
    variable gSymbolpage

    set gSymbolpage(page) [lindex $m_text end]
    return
}

proc act_company_to_symbol {} {
    variable gSymbolpage
    variable gCompany
    variable gCompanylink
    variable gSymbollist
    variable m_text
    variable m_param

    regsub -all "amp;" $m_text "" m_text
    set gCompany $m_text
    regsub -all "amp;" $m_param "" m_param
    set idx [string first "\"" $m_param]
    incr idx
    set idx2 [string first "\"" $m_param $idx]
    incr idx2 -1 
    set gCompanylink [string range $m_param $idx $idx2] 
    return
}

proc act_symbol_to_symbol {} {
    variable gSymbollist
    variable gSymbollink
    variable m_text
    variable m_param

    lappend gSymbollist $m_text
    # Extract symbol link from m_param
    # param = href="http://tmx.quotemedia.com/quote.php?qm_symbol=AW.UN&amp;locale=EN" target="_blank"
    set idx [string first "http" $m_param]
    set idx2 [string first "\"" $m_param $idx]
    incr idx2 -1
    set link [string range $m_param $idx $idx2]
    regsub -all "amp;" $link "" link
    lappend gSymbollink $link
    return
}

proc act_symbol_save {} {
    variable gSymbolpage
    variable gCompany
    variable gCompanylink
    variable gSymbollist
    variable gSymbollink

    set gSymbolpage($gCompany:link) $gCompanylink
    set gSymbolpage($gCompany:symbollist) $gSymbollist
    set gSymbolpage($gCompany:symbollink) $gSymbollink
    
    set gCompany ""
    set gCompanylink ""
    set gSymbollist ""
    set gSymbollink ""
    return
}

proc Dump {} {
    variable gSymbolpage
    variable gCompany
    variable gSymbollist
    variable gSymbollink

    variable m_text
    variable m_param
    variable m_slash
    variable m_tag

    puts "company = $gCompany"
    puts "symbollist = $gSymbollist"
    puts "symbollink = $gSymbollink"
    foreach idx [lsort [array names gSymbolpage]] {
	puts "$idx $gSymbolpage($idx)"
    }
    puts "text = $m_text"
    puts "param = $m_param"
    puts "slash = $m_slash"
    puts "tag = $m_tag"
    return
}

proc Dump_Link {} {
    variable gSymbolpage

    set rc ""
    foreach idx [lsort [array names gSymbolpage *:link]] {
	lappend rc $gSymbolpage($idx)
    }
    return $rc
}

proc Dump_Symbols {} {
    variable gSymbolpage

    set rc ""
    foreach idx [lsort [array names gSymbolpage *:symbollist]] {
	set rc [concat $rc $gSymbolpage($idx)]
    }
    return $rc
}

proc Dump_Symbollink {} {
    variable gSymbolpage

    set rc ""
    foreach idx [lsort [array names gSymbolpage *:symbollink]] {
	set rc [concat $rc $gSymbolpage($idx)]
    }
    return $rc
}

proc Dump_Page {} {
    variable gSymbolpage
    if {[array names gSymbolpage *:symbollist] != ""} {
        return $gSymbolpage(page)
    } else {
	return 0
    }
}

}


