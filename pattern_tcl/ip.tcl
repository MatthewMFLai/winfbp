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
# IP module to support operations on manipulating
# the IP (info pa]cket). 
# Assumption: the memory for the IP is allocated by
# malloc.tcl.

namespace eval ip {

    variable m_source_list
    variable m_sink_list
    variable m_malloc

    proc init {malloc_name} {
    	variable m_source_list
    	variable m_sink_list
	variable m_malloc

	set m_source_list ""	
	set m_sink_list ""
	set m_malloc $malloc_name
	${m_malloc}::init
    }
	
    proc source {} {
    	variable m_source_list
	variable m_malloc 

	set ip [${m_malloc}::getmem]
	lappend $m_source_list $ip
	return $ip
    }

    proc sink {p_ip} {
    	variable m_sink_list 
	variable m_malloc 

 	lappend $m_sink_list $p_ip
	${m_malloc}::freemem $p_ip
    }

    proc clone {p_ip} {
    	variable m_malloc

	set clone_ip [${m_malloc}::copymem $p_ip] 
	return $clone_ip
    }

    proc assemble {tokens} {
	variable m_malloc 

	set ip [${m_malloc}::getmem $tokens]
	
	return $ip
    }

    proc destroy {p_ip} {
	variable m_malloc 

	${m_malloc}::freemem $p_ip
    }

    proc serialize {p_ip} {
	variable m_malloc 

	return [${m_malloc}::flatmem $p_ip]
    }
}

