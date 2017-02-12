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
namespace eval byOrder {
proc set_tran_id {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:tran_id) $attr
}

proc get_tran_id {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:tran_id)
}

proc set_order_id {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:order_id) $attr
}

proc get_order_id {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:order_id)
}

proc set_event {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:event) $attr
}

proc get_event {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:event)
}

proc set_buy_sell {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:buy_sell) $attr
}

proc get_buy_sell {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:buy_sell)
}

proc set_symbol {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:symbol) $attr
}

proc get_symbol {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:symbol)
}

proc set_exchange {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:exchange) $attr
}

proc get_exchange {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:exchange)
}

proc set_shares {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:shares) $attr
}

proc get_shares {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:shares)
}

proc set_amount {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:amount) $attr
}

proc get_amount {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:amount)
}

proc set_amount_left {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:amount_left) $attr
}

proc get_amount_left {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:amount_left)
}

proc set_price {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:price) $attr
}

proc get_price {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:price)
}

proc set_commision {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:commision) $attr
}

proc get_commision {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:commision)
}

proc set_expiredate {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:expiredate) $attr
}

proc get_expiredate {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:expiredate)
}

proc set_timestamp {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:timestamp) $attr
}

proc get_timestamp {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:timestamp)
}

proc set_spare1 {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:spare1) $attr
}

proc get_spare1 {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:spare1)
}

proc set_spare2 {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:spare2) $attr
}

proc get_spare2 {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:spare2)
}

proc set_rc {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(order:byOrder:rc) $attr
}

proc get_rc {p_generic} {
    upvar #0 $p_generic generic

    return $generic(order:byOrder:rc)
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
    set generic(order:byOrder:tran_id) ""
    set generic(order:byOrder:order_id) ""
    set generic(order:byOrder:event) ""
    set generic(order:byOrder:buy_sell) ""
    set generic(order:byOrder:symbol) ""
    set generic(order:byOrder:exchange) ""
    set generic(order:byOrder:shares) ""
    set generic(order:byOrder:amount) ""
    set generic(order:byOrder:amount_left) ""
    set generic(order:byOrder:price) ""
    set generic(order:byOrder:commision) ""
    set generic(order:byOrder:expiredate) ""
    set generic(order:byOrder:timestamp) ""
    set generic(order:byOrder:spare1) ""
    set generic(order:byOrder:spare2) ""
    set generic(order:byOrder:rc) ""
}

proc remove {p_generic} {
    upvar #0 $p_generic generic
    unset generic(order:byOrder:tran_id)
    unset generic(order:byOrder:order_id)
    unset generic(order:byOrder:event)
    unset generic(order:byOrder:buy_sell)
    unset generic(order:byOrder:symbol)
    unset generic(order:byOrder:exchange)
    unset generic(order:byOrder:shares)
    unset generic(order:byOrder:amount)
    unset generic(order:byOrder:amount_left)
    unset generic(order:byOrder:price)
    unset generic(order:byOrder:commision)
    unset generic(order:byOrder:expiredate)
    unset generic(order:byOrder:timestamp)
    unset generic(order:byOrder:spare1)
    unset generic(order:byOrder:spare2)
    unset generic(order:byOrder:rc)
}

proc getattrname {} {
    return "tran_id order_id event buy_sell symbol exchange shares amount amount_left price commision expiredate timestamp spare1 spare2 rc"
}
}

