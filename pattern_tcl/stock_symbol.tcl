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
proc set_group {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&group) $attr
}

proc get_group {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&group)
}

proc set_exchange {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&exchange) $attr
}

proc get_exchange {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&exchange)
}

proc set_symbollist {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&symbollist) $attr
}

proc get_symbollist {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&symbollist)
}

proc set_url {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&url) $attr
}

proc get_url {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&url)
}

proc set_nexturl {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&nexturl) $attr
}

proc get_nexturl {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&nexturl)
}

proc init {p_generic} {
    upvar #0 $p_generic generic
    set generic(&group) ""
    set generic(&exchange) ""
    set generic(&symbollist) ""
    set generic(&url) ""
    set generic(&nexturl) ""
}

proc remove {p_generic} {
    upvar #0 $p_generic generic
    unset generic(&group)
    unset generic(&exchange)
    unset generic(&symbollist)
    unset generic(&url)
    unset generic(&nexturl)
}

proc getattrname {} {
    return "group exchange symbollist url nexturl"
}
