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
namespace eval Launcher_Obj {

variable m_template
variable m_mapper
variable m_count
variable m_name

proc Init {filename} {
    variable m_template
    variable m_mapper
    variable m_count
    variable m_name

    set rc ""
    if {![file exists $filename]} {
	set rc "Launcher_Obj - $filename does not exist!"
        return $rc
    }

    set fd [open $filename r]
    set m_template [read $fd]
    close $fd

    set m_name "::Launcher_"
    array set m_mapper {}
    set m_count 1
 
    return $rc
}

proc Create {id} {
    variable m_template
    variable m_mapper
    variable m_count
    variable m_name

    if {[lsearch [array names m_mapper] $id] != -1} {
	set rc "Launcher_Factory ERROR $id duplicate id"
	return $rc
    }
    regsub "%%%" $m_template $m_name$m_count template
    if {[catch {eval $template} rc]} {
	return "Launcher_Factory ERROR $rc"
    }
    set m_mapper($id) $m_name$m_count
    set rc $m_name$m_count
    incr m_count
    return $rc
}

proc Delete {id} {
    variable m_mapper

    set rc ""
    if {[info exists m_mapper($id)]} {
    	namespace delete $m_mapper($id)
	unset m_mapper($id)
    } else {
	set rc "Launcher_Factory ERROR graph $id not present."
    }
    return $rc
}

proc Get_Obj {id} {
    variable m_mapper

    set rc ""
    if {[info exists m_mapper($id)]} {
	set rc $m_mapper($id)
    }
    return $rc
}

proc Get_All_Id {} {
    variable m_mapper

    return [array names m_mapper] 
}

}

