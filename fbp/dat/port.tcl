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
proc set_id {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&id) $attr
}

proc get_id {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&id)
}

proc set_socketport {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&socketport) $attr
}

proc get_socketport {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&socketport)
}

proc set_is_vport {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&is_vport) $attr
}

proc get_is_vport {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&is_vport)
}

proc set_hostipaddr {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&hostipaddr) $attr
}

proc get_hostipaddr {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&hostipaddr)
}

proc set_queuelen {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&queuelen) $attr
}

proc get_queuelen {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&queuelen)
}

proc set_def_grp_status {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&def_grp_status) $attr
}

proc get_def_grp_status {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&def_grp_status)
}

proc set_all {p_generic p_data} {
    upvar $p_data data

    set attrlist [getattrname]
    foreach attr [array names data] {
        if {[lsearch $attrlist $attr] > -1} {
           set_$attr $p_generic $data($attr)
        }
    }
    return
}

proc init {p_generic} {
    upvar #0 $p_generic generic
    set generic(&id) ""
    set generic(&socketport) ""
    set generic(&is_vport) ""
    set generic(&hostipaddr) ""
    set generic(&queuelen) ""
    set generic(&def_grp_status) ""
}

proc remove {p_generic} {
    upvar #0 $p_generic generic
    unset generic(&id)
    unset generic(&socketport)
    unset generic(&is_vport)
    unset generic(&hostipaddr)
    unset generic(&queuelen)
    unset generic(&def_grp_status)
}

proc getattrname {} {
    return "id socketport is_vport hostipaddr queuelen def_grp_status"
}
