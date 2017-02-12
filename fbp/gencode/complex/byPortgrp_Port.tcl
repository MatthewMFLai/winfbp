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
namespace eval byPortgrp_Port {
# Substitue <assoc> with the name of the
# pattern instance.
# Substitue <whole> and <part> with the
# names of the application structures.
proc add_part {p_whole p_part} {
    upvar #0 $p_whole whole
    upvar #0 $p_part part

    set part(assoc:byPortgrp_Port:whole_ref) $p_whole
    lappend whole(assoc:byPortgrp_Port:part_list) $p_part
}

proc remove_part {p_whole p_part} {
    upvar #0 $p_whole whole
    upvar #0 $p_part part

    set idx 0
    set key $part(assoc:byPortgrp_Port:key)
    foreach p_part $whole(assoc:byPortgrp_Port:part_list) {
	upvar #0 $p_part cur_part
	if {$cur_part(assoc:byPortgrp_Port:key) == $key} {
	    set whole(assoc:byPortgrp_Port:part_list) [lreplace $whole(assoc:byPortgrp_Port:part_list) $idx $idx]
	    set part(assoc:byPortgrp_Port:whole_ref) ""
	    return 1
	}
	incr idx
    }
    return 0
}

proc get_part {p_whole key} {
    upvar #0 $p_whole whole

    foreach p_part $whole(assoc:byPortgrp_Port:part_list) {
	upvar #0 $p_part part
	if {$part(assoc:byPortgrp_Port:key) == $key} {
	    return $p_part
	}
    }
    return NULL
}

proc get_whole {p_part} {
    upvar #0 $p_part part

    return $part(assoc:byPortgrp_Port:whole_ref)
}

proc get_key {p_part} {
    upvar #0 $p_part part

    return $part(assoc:byPortgrp_Port:key)
}

proc set_key {p_part key} {
    upvar #0 $p_part part
    set part(assoc:byPortgrp_Port:key) $key
}

proc get_iterator {p_whole} {
    upvar #0 $p_whole whole

    return $whole(assoc:byPortgrp_Port:part_list)
}

proc init_part {p_part key} {
    upvar #0 $p_part part
    set part(assoc:byPortgrp_Port:whole_ref) ""
    set part(assoc:byPortgrp_Port:key) $key
}

proc init_part_new {p_part} {
    upvar #0 $p_part part
    set part(assoc:byPortgrp_Port:whole_ref) ""
    set part(assoc:byPortgrp_Port:key) "" 
}

proc init_whole {p_whole} {
    upvar #0 $p_whole whole
    set whole(assoc:byPortgrp_Port:part_list) ""
}

}

