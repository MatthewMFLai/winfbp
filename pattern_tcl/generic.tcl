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
proc set_attr1 {p_generic attr} {
    upvar #0 $p_generic generic 

    set generic(&attr1) $attr
}

proc set_attr2 {p_generic attr} {
    upvar #0 $p_generic generic 

    set generic(&attr2) $attr
}

proc set_attr3 {p_generic attr} {
    upvar #0 $p_generic generic 

    set generic(&attr3) $attr
}

proc get_attr1 {p_generic} {
    upvar #0 $p_generic generic 

    return $generic(&attr1)
}

proc get_attr2 {p_generic} {
    upvar #0 $p_generic generic 

    return $generic(&attr2)
}

proc get_attr3 {p_generic} {
    upvar #0 $p_generic generic 

    return $generic(&attr3)
}

proc init {p_generic} {
    upvar #0 $p_generic generic 
    set generic(&attr1) ""
    set generic(&attr2) ""
    set generic(&attr3) ""
}

