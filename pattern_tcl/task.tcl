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
proc set_task {p_task script data} {
    upvar #0 $p_task task 

    set task(&script) $script
    set task(&script_data) $data
    set task(&script_status) "IDLE"
}

proc set_task_dispatched {p_task} {
    upvar #0 $p_task task 

    set task(&script_status) "DISPATCHED"
}

proc set_task_pass {p_task} {
    upvar #0 $p_task task 

    set task(&script_status) "PASS"
}

proc set_task_fail {p_task} {
    upvar #0 $p_task task 

    set task(&script_status) "FAIL"
}

proc get_task {p_task p_script p_data} {
    upvar #0 $p_task task 
    upvar $p_script script
    upvar $p_data data

    set script $task(&script)
    set data $task(&script_data)
}

proc is_task_pass {p_task} {
    upvar #0 $p_task task 

    if {$task(&script_status) == "PASS"} {
	return 1
    } else {
        return 0
    }
}

proc is_task_fail {p_task} {
    upvar #0 $p_task task 

    if {$task(&script_status) == "FAIL"} {
	return 1
    } else {
        return 0
    }
}

proc is_task_dispatched {p_task} {
    upvar #0 $p_task task 

    if {$task(&script_status) == "DISPATCHED"} {
	return 1
    } else {
        return 0
    }
}

proc is_task_idle {p_task} {
    upvar #0 $p_task task 

    if {$task(&script_status) == "IDLE"} {
	return 1
    } else {
        return 0
    }
}

proc init_task {p_task} {
    upvar #0 $p_task task 
    set task(&script) ""
    set task(&script_data) ""
    set task(&script_status) ""
}

