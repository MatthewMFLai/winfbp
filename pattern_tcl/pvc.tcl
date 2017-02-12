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
namespace eval pvc {
# A utility for allocating ids from a predefined sets of
# rectangular regions. Ids can be either a list of one or
# two integers.

# region is list of two tuples
# {{x1 y1} {x2 y2}} or
# {{x1} {x2}}
proc idpool_add_region {p_member region} {
	upvar $p_member member

	# Do we need to check for overlapping regions?
	lappend member(pvc_regionlist) $region
	lappend member(pvc_org_regionlist) $region
}

# id is a list of one or two integers
# Return a region if id is free
#        "" if id is already used
proc idpool_get_id_region {regionlist id} {

	foreach region $regionlist {
		set i 0
		foreach coordinate $id {
			set lowtuple [lindex $region 0]
			set lowcoordinate [lindex $lowtuple $i]
			set hightuple [lindex $region 1]
			set highcoordinate [lindex $hightuple $i]
			
			if {$coordinate > $highcoordinate || $coordinate < $lowcoordinate} {
				set i 0
				break
			}
			incr i
		}
		if {$i != 0} {
			# Find the containing region.
			return $region
		}
	}
	# id is not in any region. Either it is used,
	# or it is not valid. Return 0 for either cases.
	return ""
}

proc idpool_split_region {region id p_newregionlist} {
	upvar $p_newregionlist newregionlist
	set newregionlist ""

	set lowleft [lindex $region 0]
	set upright [lindex $region 1]

	# Is the region a single point?
	if {$lowleft == $upright} {
		return
	}

	set x1 [lindex $lowleft 0]
	set y1 [lindex $lowleft 1]

	set x2 [lindex $upright 0]
	set y2 [lindex $upright 1]

	set x [lindex $id 0]
	set y [lindex $id 1]

	set x_minus [expr $x - 1]
	set x_plus [expr $x + 1]
	# Is the region a horizontal line?
	if {$y1 == $y2} {
		if {$x_minus >= $x1} {	
			set token "$x_minus $y1"
			lappend newregionlist [list $lowleft $token]
		}
		if {$x_plus <= $x2} {	
			set token "$x_plus $y1"
			lappend newregionlist [list $token $upright]
		}
		return
	}

	set y_minus [expr $y - 1]
	set y_plus [expr $y + 1]
	# Is the region a vertical line?
	if {$x1 == $x2} {
		if {$y_minus >= $y1} {	
			set token "$x1 $y_minus"
			lappend newregionlist [list $lowleft $token]
		}
		if {$y_plus <= $y2} {	
			set token "$x1 $y_plus"
			lappend newregionlist [list $token $upright]
		}
		return
	}

	# Case for the rectangular block.
	if {$y_minus >= $y1} {
		set token "$x2 $y_minus"
		lappend newregionlist [list $lowleft $token]
	}

	if {$x_minus >= $x1} {
		set token "$x1 $y"
		set token2 "$x_minus $y"
		lappend newregionlist [list $token $token2]
	}

	if {$x_plus <= $x2} {
		set token "$x_plus $y"
		set token2 "$x2 $y"
		lappend newregionlist [list $token $token2]
	}

	if {$y_plus <= $y2} {
		set token "$x1 $y_plus"
		lappend newregionlist [list $token $upright]
	}
}

# id is a list of one or two integers
# Return 1 if id is free and thus is allocated
#          for the calling routine
#        0 if id is already used
#       -1 if id is not in any valid region.
proc idpool_alloc_id {p_member id {verify_id 1}} {
	upvar $p_member member

	if {$verify_id} {
		# Verify the id does reside in a valid region.
		set region [idpool_get_id_region $member(pvc_org_regionlist) $id]
		if {$region == ""} {
			# Cannot find a valid region for the id.
			# Just return -1.
			return -1 
		}
	}

	set idx [lsearch $member(pvc_freedidlist) $id]
	if {$idx != -1} {
		set rc [lindex $member(pvc_freedidlist) $idx]
		set member(pvc_freedidlist) [lreplace $member(pvc_freedidlist) $idx $idx]
		return 1
	}

	set region [idpool_get_id_region $member(pvc_regionlist) $id]
	if {$region == ""} {
		# Cannot find a free id.
		# Just return 0.
		return 0
	}

	# Invoke region splitting routine to split up the single region
	# into potentially two or more regions after removing the id
	# from the region.
	set newregionlist ""
	idpool_split_region $region $id newregionlist

	# Update the region list in the member.
	set idx [lsearch $member(pvc_regionlist) $region]
	set tmpregionlist $member(pvc_regionlist)
	set tmpregionlist [lreplace $tmpregionlist $idx $idx]
	foreach newregion $newregionlist {
		lappend tmpregionlist $newregion
	}
	set member(pvc_regionlist) $tmpregionlist

	return 1
}

# id is a list of one or two integers
# Return 1 if id is freed okay 
#        0 if id is already freed.
#       -1 if id is not in any valid region 
proc idpool_free_id {p_member id} {
	upvar $p_member member

	set idx [lsearch $member(pvc_freedidlist) $id]
	if {$idx >= 0} {
		return 0
	}

	set region [idpool_get_id_region $member(pvc_org_regionlist) $id]
	if {$region == ""} {
		# Cannot find a region for the freed id.
		# Just return 0.
		return -1 
	}

	lappend member(pvc_freedidlist) $id
	return 1
}

# Return the next available id.
# The returned id is a list of 1 or 2 integers.
# If no id is available, the returned list is 
# an empty list.
proc idpool_alloc_next_id {p_member} {
	upvar $p_member member

	set rc ""
	if {$member(pvc_freedidlist) != ""} {
		set rc [lindex $member(pvc_freedidlist) 0]
		if {[llength $member(pvc_freedidlist)] > 1} {
			set member(pvc_freedidlist) [lrange $member(pvc_freedidlist) 1 end]
		} else {
			set member(pvc_freedidlist) ""
		}
		return $rc
	}

	set region [lindex $member(pvc_regionlist) 0]
	set id [lindex $region 0]
	if {[idpool_alloc_id member $id 0]} {
		return $id
	} else {
		return ""
	}
}

proc idpool_init_member {p_member} {
	upvar $p_member member
	# The original regionlist is used to verify
	# - freed id does reside in a valid region
	# - id for the specific id allocation does
	#   reside in a valid region.
	set member(pvc_org_regionlist) ""
	set member(pvc_regionlist) ""
	set member(pvc_freedidlist) ""
}

proc idpool_reset_member {p_member} {
	upvar $p_member member
	# Use this procedure to quickly reset the
	# valid regions. 
	set member(pvc_regionlist) $member(pvc_org_regionlist) 
	set member(pvc_freedidlist) ""
}

}

