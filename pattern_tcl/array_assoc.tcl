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
# Substitue <assoc> with the name of the
# pattern instance.
# Substitue <whole> and <part> with the
# names of the application structures.
proc add_part {p_whole p_part} {
    upvar #0 $p_whole whole
    upvar #0 $p_part part

    if {![Assert::Check $whole(&part_table)]} {
	set whole(&part_table) [malloc::getmem]
	Assert::Assert $whole(&part_table)
    }
    set part(&whole_ref) $p_whole

    set p_table $whole(&part_table)
    upvar #0 $p_table table
    set key $part(&key)
    if {![info exists table($key)]} {
    	set table($key) $p_part
	return 1
    }
    return 0
}

proc remove_part {p_whole p_part} {
    upvar #0 $p_whole whole
    upvar #0 $p_part part

    set key $part(&key)
    set p_table $whole(&part_table)
    if {![Assert::Check $p_table]} {
	return 0
    }
    upvar #0 $p_table table
    if {[info exists table($key)]} {
    	unset table($key) 
    	set part(&whole_ref) ""

	# Remove table if all parts are removed.
	if {![llength [array names table]]} {
	    malloc::freemem $p_table
	    set whole(&part_table) "NULL"
	}
    	return 1
    }

    return 0
}

proc get_part {p_whole key} {
    upvar #0 $p_whole whole

    set p_table $whole(&part_table)
    if {![Assert::Check $p_table]} {
	return NULL
    }
    upvar #0 $p_table table
    if {[info exists table($key)]} {
	return $table($key)
    } else {
	return NULL
    }
}

proc get_whole {p_part} {
    upvar #0 $p_part part

    return $part(&whole_ref)
}

proc get_key {p_part} {
    upvar #0 $p_part part

    return $part(&key)
}

proc set_key {p_part key} {
    upvar #0 $p_part part
    set part(&key) $key
}

proc get_iterator {p_whole} {
    upvar #0 $p_whole whole

    set p_table $whole(&part_table)
    if {![Assert::Check $p_table]} {
	return "" 
    }
    upvar #0 $p_table table
    set rc ""
    foreach idx [array names table] {
	lappend rc $table($idx)
    }
    return $rc
}

proc init_part_new {p_part} {
    upvar #0 $p_part part
    set part(&whole_ref) ""
    set part(&key) "" 
}

proc init_whole {p_whole} {
    upvar #0 $p_whole whole
    set whole(&part_table) "NULL"
}

