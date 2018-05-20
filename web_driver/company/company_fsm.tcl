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
namespace eval company_fsm {

variable m_rx_list
variable m_data

proc init {} {
    variable m_rx_list
    variable m_data

	set m_rx_list {{description Description<.*?><.*?><.*?>(.*?)<.*?> nul} \
	               {name Mb\\(10px\\).*?>(.*?)</h3> nul} \
                   {sector Sector<.*?><.*?>:\\s<.*?><.*?>(.*?)<.*?> nul} \
                   {industry Industry<.*?><.*?>:\\s<.*?><.*?>(.*?)<.*?> nul} \
                   {employees Full\\sTime\\sEmployees<.*?><.*?>:\\s<.*?><.*?><.*?>(.*?)<.*?> nul} \
                  }
    if {[info exists m_data]} {
	unset m_data
    }
    array set m_data {}

    return
}

proc process_generic {p_data} {
    upvar $p_data argarray
    variable m_rx_list
    variable m_data

    set data $argarray(data)
    foreach rx_tokens $m_rx_list {
		set key [lindex $rx_tokens 0]
		set exp [lindex $rx_tokens 1]
		set default [lindex $rx_tokens 2]
		if {[regexp $exp $data -> s1]} {
			regsub -all "amp;" $s1 "" s1			
			set m_data($key) [string trim $s1]
		} else {
			set m_data($key) $default
		}
    }

    if {[info exists m_data(employees)]} {
		set number $m_data(employees)
		regsub -all "," $number "" number
		set m_data(employees) $number
    }

    if {[info exists m_data(description)]} {
		set desc $m_data(description)
		regsub -all "amp;" $desc "" desc
		regsub -all "&#x27;" $desc "'" desc
		set m_data(description) $desc
    }

    if {[info exists m_data(name)]} {
		set name $m_data(name)
		regsub -all "&#x27;" $name "'" name
		set m_data(name) $name
    }
	
    return
}
	    
proc Dump_Company {p_data} {
    upvar $p_data data
    variable m_data

    array set data [array get m_data]
    return
}

proc Dump {} {
    variable m_data

    foreach idx [lsort [array names m_data]] {
	puts "$idx $gCompany($idx)"
    }
    return
}

}
