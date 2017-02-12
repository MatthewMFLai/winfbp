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

variable gCompanylink
variable gSymbollink
variable gSymbollist

proc parseit {data} {
    set rc ""
    regsub -all "\"" $data "" data
    regsub -all "\{" $data "" data
    regsub -all "\}" $data "" data
    regsub -all {\[} $data "" data
    regsub -all {\]} $data "" data
    set search_str "symbol:"
    set str_len [string length $search_str]
    foreach token [split $data ","] {
	set idx [string last $search_str $token]
	if {$idx == -1} {
	    continue
	}
	incr idx $str_len
	set symbol [string range $token $idx end]
	lappend rc $symbol
    }
    return [lsort -unique $rc]
}

proc init {} {

    variable gCompanylink
    variable gSymbollink
    variable gSymbollist

    set gCompanylink ""
    set gSymbollink ""
    set gSymbollist ""
	return
}

proc process_generic {p_arg_array} {
    upvar $p_arg_array arg_array
    variable gSymbollist

    set gSymbollist [parseit $arg_array(data)]
    return
}

proc Dump {} {
    variable gCompanylink
    variable gSymbollist
    variable gSymbollink


    puts "company = $gCompanylink"
    puts "symbollist = $gSymbollist"
    puts "symbollink = $gSymbollink"

    return
}

proc Dump_Link {} {
    variable gCompanylink

    return $gCompanylink
}

proc Dump_Symbols {} {
    variable gSymbollist

    return $gSymbollist
}

proc Dump_Symbollink {} {
    variable gSymbollink

    return $gSymbollink
}

proc Dump_Page {} {
	return 1
}

}


