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
proc lintersect {a b} {
   foreach e $a {
        set x($e) {}
   }
   set result {}
   foreach e $b {
       if {[info exists x($e)]} {
           lappend result $e
       }
   }
   return $result
}

proc add_plane {p_vertex_1 p_vertex_2 p_plane} {
    upvar #0 $p_vertex_1 vertex_1
    upvar #0 $p_vertex_2 vertex_2
    upvar #0 $p_plane plane

    set plane(&vertex_1) $p_vertex_1
    lappend vertex_1(&plane_list) $p_plane
    set plane(&vertex_2) $p_vertex_2
    lappend vertex_2(&plane_list) $p_plane
}

proc remove_plane {p_vertex_1 p_vertex_2 p_plane} {
    upvar #0 $p_vertex_1 vertex_1
    upvar #0 $p_vertex_2 vertex_2
    upvar #0 $p_plane plane

    # Robustness checks.
    if {$plane(&vertex_1) != $p_vertex_1} {
        return -1
    }

    if {$plane(&vertex_2) != $p_vertex_2} {
        return -1
    }

    set plane(&vertex_1) ""
    set plane(&vertex_2) ""
    set data $vertex_1(&plane_list)
    set idx [lsearch $data $p_plane]
    if {$idx > -1} {
        set vertex_1(&plane_list) [lreplace $data $idx $idx]
    } else {
        return -2
    }

    set data $vertex_2(&plane_list)
    set idx [lsearch $data $p_plane]
    if {$idx > -1} {
        set vertex_2(&plane_list) [lreplace $data $idx $idx]
    } else {
        return -2
    }

    return 0
}

proc get_plane {p_vertex_1 p_vertex_2} {
    upvar #0 $p_vertex_1 vertex_1
    upvar #0 $p_vertex_2 vertex_2

    set planelist1 $vertex_1(&plane_list)
    set planelist2 $vertex_2(&plane_list)

    set rc $planelist1
    set rc [lintersect $planelist2 $rc]
    return $rc
}

proc get_vertex_1 {p_plane} {
    upvar #0 $p_plane plane

    return $plane(&vertex_1)
}

proc get_vertex_2 {p_plane} {
    upvar #0 $p_plane plane

    return $plane(&vertex_2)
}

proc get_plane_iterator {p_vertex} {
    upvar #0 $p_vertex vertex

    return $vertex(&plane_list)
}

proc init_plane {p_plane} {
   upvar #0 $p_plane plane
   set plane(&vertex_1) "" 
   set plane(&vertex_2) "" 
}

proc init_vertex {p_vertex} {
    upvar #0 $p_vertex vertex
    set vertex(&plane_list) ""
}

