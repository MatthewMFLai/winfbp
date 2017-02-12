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
namespace eval byInPort_OutPort {
# Substitue <assoc> with the name of the
# pattern instance.
# Substitue <whole> and <part> with the
# names of the application structures.
proc add_rel {p_entity p_entity2} {
    upvar #0 $p_entity entity
    upvar #0 $p_entity2 entity2 

    set idx [lsearch $entity(lattice:byInPort_OutPort:rel_list) $p_entity2]
    if {$idx == -1} {
    	lappend entity(lattice:byInPort_OutPort:rel_list) $p_entity2
    }

    set idx [lsearch $entity2(lattice:byInPort_OutPort:rel_list) $p_entity]
    if {$idx == -1} {
    	lappend entity2(lattice:byInPort_OutPort:rel_list) $p_entity
    }

    return 0
}

proc remove_rel {p_entity p_entity2} {
    upvar #0 $p_entity entity
    upvar #0 $p_entity2 entity2

    set idx [lsearch $entity(lattice:byInPort_OutPort:rel_list) $p_entity2]
    if {$idx > -1} {
	set entity(lattice:byInPort_OutPort:rel_list) [lreplace $entity(lattice:byInPort_OutPort:rel_list) $idx $idx]
    }

    set idx [lsearch $entity2(lattice:byInPort_OutPort:rel_list) $p_entity]
    if {$idx > -1} {
	set entity2(lattice:byInPort_OutPort:rel_list) [lreplace $entity2(lattice:byInPort_OutPort:rel_list) $idx $idx]
    }

    return 0
}

proc has_rel {p_entity p_entity2} {
    upvar #0 $p_entity entity
    upvar #0 $p_entity2 entity2 

    set rc 1
    set idx [lsearch $entity(lattice:byInPort_OutPort:rel_list) $p_entity2]
    set idx2 [lsearch $entity2(lattice:byInPort_OutPort:rel_list) $p_entity]
    if {$idx == -1 || $idx2 == -1} {
    	set rc 0
    }
    return $rc 
}

proc get_rel {p_entity} {
    upvar #0 $p_entity entity

    return $entity(lattice:byInPort_OutPort:rel_list)
}

proc init_entity {p_entity} {
    upvar #0 $p_entity entity
    set entity(lattice:byInPort_OutPort:rel_list) ""
}

}

