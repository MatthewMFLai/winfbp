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
proc set_tran_id {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&tran_id) $attr
}

proc get_tran_id {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&tran_id)
}

proc set_order_id {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&order_id) $attr
}

proc get_order_id {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&order_id)
}

proc set_event {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&event) $attr
}

proc get_event {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&event)
}

proc set_buy_sell {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&buy_sell) $attr
}

proc get_buy_sell {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&buy_sell)
}

proc set_symbol {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&symbol) $attr
}

proc get_symbol {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&symbol)
}

proc set_exchange {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&exchange) $attr
}

proc get_exchange {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&exchange)
}

proc set_shares {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&shares) $attr
}

proc get_shares {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&shares)
}

proc set_amount {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&amount) $attr
}

proc get_amount {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&amount)
}

proc set_amount_left {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&amount_left) $attr
}

proc get_amount_left {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&amount_left)
}

proc set_price {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&price) $attr
}

proc get_price {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&price)
}

proc set_commision {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&commision) $attr
}

proc get_commision {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&commision)
}

proc set_expiredate {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&expiredate) $attr
}

proc get_expiredate {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&expiredate)
}

proc set_timestamp {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&timestamp) $attr
}

proc get_timestamp {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&timestamp)
}

proc set_spare1 {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&spare1) $attr
}

proc get_spare1 {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&spare1)
}

proc set_spare2 {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&spare2) $attr
}

proc get_spare2 {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&spare2)
}

proc set_rc {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(&rc) $attr
}

proc get_rc {p_generic} {
    upvar #0 $p_generic generic

    return $generic(&rc)
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
    set generic(&tran_id) ""
    set generic(&order_id) ""
    set generic(&event) ""
    set generic(&buy_sell) ""
    set generic(&symbol) ""
    set generic(&exchange) ""
    set generic(&shares) ""
    set generic(&amount) ""
    set generic(&amount_left) ""
    set generic(&price) ""
    set generic(&commision) ""
    set generic(&expiredate) ""
    set generic(&timestamp) ""
    set generic(&spare1) ""
    set generic(&spare2) ""
    set generic(&rc) ""
}

proc remove {p_generic} {
    upvar #0 $p_generic generic
    unset generic(&tran_id)
    unset generic(&order_id)
    unset generic(&event)
    unset generic(&buy_sell)
    unset generic(&symbol)
    unset generic(&exchange)
    unset generic(&shares)
    unset generic(&amount)
    unset generic(&amount_left)
    unset generic(&price)
    unset generic(&commision)
    unset generic(&expiredate)
    unset generic(&timestamp)
    unset generic(&spare1)
    unset generic(&spare2)
    unset generic(&rc)
}

proc getattrname {} {
    return "tran_id order_id event buy_sell symbol exchange shares amount amount_left price commision expiredate timestamp spare1 spare2 rc"
}
