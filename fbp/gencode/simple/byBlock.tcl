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
namespace eval byBlock {
proc set_name {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:name) $attr
}

proc get_name {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:name)
}

proc set_is_subcircuit {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:is_subcircuit) $attr
}

proc get_is_subcircuit {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:is_subcircuit)
}

proc set_program_name {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:program_name) $attr
}

proc get_program_name {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:program_name)
}

proc set_mtc_port {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:mtc_port) $attr
}

proc get_mtc_port {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:mtc_port)
}

proc set_program_data {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:program_data) $attr
}

proc get_program_data {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:program_data)
}

proc set_program_testdata {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:program_testdata) $attr
}

proc get_program_testdata {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:program_testdata)
}

proc set_ip_addr {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:ip_addr) $attr
}

proc get_ip_addr {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:ip_addr)
}

proc set_timeout {p_generic attr} {
    upvar #0 $p_generic generic

    set generic(block:byBlock:timeout) $attr
}

proc get_timeout {p_generic} {
    upvar #0 $p_generic generic

    return $generic(block:byBlock:timeout)
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
    set generic(block:byBlock:name) ""
    set generic(block:byBlock:is_subcircuit) ""
    set generic(block:byBlock:program_name) ""
    set generic(block:byBlock:mtc_port) ""
    set generic(block:byBlock:program_data) ""
    set generic(block:byBlock:program_testdata) ""
    set generic(block:byBlock:ip_addr) ""
    set generic(block:byBlock:timeout) ""
}

proc remove {p_generic} {
    upvar #0 $p_generic generic
    unset generic(block:byBlock:name)
    unset generic(block:byBlock:is_subcircuit)
    unset generic(block:byBlock:program_name)
    unset generic(block:byBlock:mtc_port)
    unset generic(block:byBlock:program_data)
    unset generic(block:byBlock:program_testdata)
    unset generic(block:byBlock:ip_addr)
    unset generic(block:byBlock:timeout)
}

proc getattrname {} {
    return "name is_subcircuit program_name mtc_port program_data program_testdata ip_addr timeout"
}
}

