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
proc set_filename {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&filename) $attr
}

proc get_filename {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&filename)
}

proc set_state {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&state) $attr
}

proc get_state {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&state)
}

proc set_high_52 {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&high_52) $attr
}

proc get_high_52 {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&high_52)
}

proc set_low_52 {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&low_52) $attr
}

proc get_low_52 {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&low_52)
}

proc set_shares_outstanding {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&shares_outstanding) $attr
}

proc get_shares_outstanding {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&shares_outstanding)
}

proc set_dividend_yield {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&dividend_yield) $attr
}

proc get_dividend_yield {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&dividend_yield)
}

proc set_market_value {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&market_value) $attr
}

proc get_market_value {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&market_value)
}

proc init {p_generic} {
    upvar #0 $p_generic generic
    set generic(&filename) ""
    set generic(&state) ""
    set generic(&high_52) ""
    set generic(&low_52) ""
    set generic(&shares_outstanding) ""
    set generic(&dividend_yield) ""
    set generic(&market_value) ""
}

proc remove {p_generic} {
    upvar #0 $p_generic generic
    unset generic(&filename)
    unset generic(&state)
    unset generic(&high_52)
    unset generic(&low_52)
    unset generic(&shares_outstanding)
    unset generic(&dividend_yield)
    unset generic(&market_value)
}

proc getattrname {} {
    return "filename state high_52 low_52 shares_outstanding dividend_yield market_value"
}
