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
# A utility for allocating ids from a predefined sets of
# linear 1-dimension regions. Id is a list of one integer. 

# region is list of two integers. 
# {x1 x2}
proc idpool_add_region {p_member region} {
	upvar $p_member member

	# Do we need to check for overlapping regions?
	lappend member(&regionlist) $region
	lappend member(&org_regionlist) $region
}

# id is an integer
# Return a region if id is free
#        "" if id is already used
proc idpool_get_id_region {regionlist id} {

	foreach region $regionlist {
		set lowtuple [lindex $region 0]
		set hightuple [lindex $region 1]
			
		if {$id > $hightuple || $id < $lowtuple} {
			continue
		}
		# Find the containing region.
		return $region
	}
	# id is not in any region. Either it is used,
	# or it is not valid. Return 0 for either cases.
	return ""
}

proc idpool_split_region {region id p_newregionlist} {
	upvar $p_newregionlist newregionlist
	set newregionlist ""

	set x1 [lindex $region 0]
	set x2 [lindex $region 1]

	# Is the region a single point?
	if {$x1 == $x2} {
		return
	}

	set x [lindex $id 0]
	set x_minus [expr $x - 1]
	set x_plus [expr $x + 1]

	if {$x_minus >= $x1} {	
		lappend newregionlist [list $x1 $x_minus]
	}
	if {$x_plus <= $x2} {	
		lappend newregionlist [list $x_plus $x2]
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
		set region [idpool_get_id_region $member(&org_regionlist) $id]
		if {$region == ""} {
			# Cannot find a valid region for the id.
			# Just return -1.
			return -1 
		}
	}

	set idx [lsearch $member(&freedidlist) $id]
	if {$idx != -1} {
		set rc [lindex $member(&freedidlist) $idx]
		set member(&freedidlist) [lreplace $member(&freedidlist) $idx $idx]
		return 1
	}

	set region [idpool_get_id_region $member(&regionlist) $id]
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
	set idx [lsearch $member(&regionlist) $region]
	set tmpregionlist $member(&regionlist)
	set tmpregionlist [lreplace $tmpregionlist $idx $idx]
	foreach newregion $newregionlist {
		lappend tmpregionlist $newregion
	}
	set member(&regionlist) $tmpregionlist

	return 1
}

# id is a list of one or two integers
# Return 1 if id is freed okay 
#        0 if id is already freed.
#       -1 if id is not in any valid region 
proc idpool_free_id {p_member id} {
	upvar $p_member member

	set idx [lsearch $member(&freedidlist) $id]
	if {$idx >= 0} {
		return 0
	}

	set region [idpool_get_id_region $member(&org_regionlist) $id]
	if {$region == ""} {
		# Cannot find a region for the freed id.
		# Just return 0.
		return -1 
	}

	lappend member(&freedidlist) $id
	return 1
}

# Return the next available id.
# The returned id is a list of 1 or 2 integers.
# If no id is available, the returned list is 
# an empty list.
proc idpool_alloc_next_id {p_member} {
	upvar $p_member member

	set rc ""
	if {$member(&freedidlist) != ""} {
		set rc [lindex $member(&freedidlist) 0]
		if {[llength $member(&freedidlist)] > 1} {
			set member(&freedidlist) [lrange $member(&freedidlist) 1 end]
		} else {
			set member(&freedidlist) ""
		}
		return $rc
	}

	set region [lindex $member(&regionlist) 0]
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
	set member(&org_regionlist) ""
	set member(&regionlist) ""
	set member(&freedidlist) ""
}

proc idpool_reset_member {p_member} {
	upvar $p_member member
	# Use this procedure to quickly reset the
	# valid regions. 
	set member(&regionlist) $member(&org_regionlist) 
	set member(&freedidlist) ""
}

