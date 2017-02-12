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
# srcdir should look like
# srcdir/comp_x/*.tcl, *.dat, ...; just files, no subdirs.
# srcdir/comp_y/*.tcl, *.dat, ...; just files, no subdirs.
# srcdir/comp_z/*.tcl, *.dat, ...; just files, no subdirs.
#
# targetdir should look like
# targetdir/comp_x/1.00/*.tcl, *.dat, ...; just files, no subdirs.
# targetdir/comp_x/1.01/*.tcl, *.dat, ...; just files, no subdirs.
# targetdir/comp_y/1.00/*.tcl, *.dat, ...; just files, no subdirs.
# targetdir/comp_z/1.00/*.tcl, *.dat, ...; just files, no subdirs.
#
source $env(PATTERN_HOME)/glob-r.tcl

namespace eval Updater {

variable m_version
variable m_version_incr
variable m_srcdir
variable m_targetdir
variable m_src_complist
variable m_target_comparray
variable c_FILEPATH
variable c_SUFFIX_BLK

# Add component to the new version subdir in targetdir.
proc add_comp_imp {compname version} {
    global tcl_platform 
    variable m_srcdir
    variable m_targetdir

    if {[string first "Windows" $tcl_platform(os)] > -1} {
	puts "rsync not supported in windows"
	return 0
    } else {
    	set subdir $m_targetdir$compname/$version

    	# Use rsync or file copy???
	catch {exec rsync -Ca $m_srcdir$compname/ $subdir/} rc
	update_blk_file $subdir $version
    	return 1
    }
}

proc get_subdir {dirname} {
    # dirname looks like /tmp/node
    # filename looks like /tmp/node/stock/source_table/source_table.tcl
    # node will then look like /stock/source_table
    set rc ""
    set filelist [runit $dirname]
    foreach filename $filelist {
	if {[string first ".tcl" $filename] == -1} {
	    continue
	}
	set idx [string last "/" $filename]
	incr idx -1
	regsub $dirname [string range $filename 0 $idx] "" node
	lappend rc $node 
    }
    return [lsort -unique $rc] 
}

proc update_blk_file {subdir version} {
    variable c_FILEPATH
    variable c_SUFFIX_BLK

    if {[catch {glob $subdir/*$c_SUFFIX_BLK} rc]} {
	return
    }
    foreach filename $rc {
	set fd [open $filename r]
	set fd2 [open $filename.new w]
	while {[gets $fd line] > -1} {
	    if {[string first $c_FILEPATH $line] == -1} {
		puts $fd2 $line
	    } else {
		puts $fd2 $line/$version
	    }
	}
	close $fd
	close $fd2
	file delete $filename
	file rename $filename.new $filename
    }
    return
}

proc Dump {} {
variable m_srcdir
variable m_targetdir
variable m_src_complist
variable m_target_comparray

    puts "srcdir = $m_srcdir"
    puts "targetdir = $m_targetdir"
    puts "src nodes = $m_src_complist"
    foreach idx [array names m_target_comparray] {
	puts "target node = $idx version = $m_target_comparray($idx)"
    }
    return
}

proc Init {srcdir targetdir} {
    variable m_version
    variable m_version_incr
    variable m_srcdir
    variable m_targetdir
    variable m_src_complist
    variable m_target_comparray
    variable c_FILEPATH
    variable c_SUFFIX_BLK

    set m_version 0.01
    set m_version_incr 0.01

    set c_FILEPATH "filepath"
    set c_SUFFIX_BLK ".blk"

    # srcdir looks like /tmp/node
    # targetdir looks like /tmp/factory

    set m_srcdir $srcdir
    set m_targetdir $targetdir

    set m_src_complist [get_subdir $m_srcdir]

    # Each target looks like /stock/source_table/0.0*
    # Need to remove the version number to get the target component
    # names only.
    set tmplist ""
    set targetlist [get_subdir $m_targetdir]
    foreach target $targetlist {
	set idx [string last "/" $target]
	incr idx -1
	lappend tmplist [string range $target 0 $idx]
    }
    set tmplist [lsort -unique $tmplist]
 
    foreach target_comp $tmplist {
	set m_target_comparray($target_comp) [Get_comp_version $target_comp] 
    }

    return
}
 
# Is the source component present in targetdir?
proc Is_comp_present {compname} {
    variable m_target_comparray

    # Each target looks like /stock/source_table
    return [info exists m_target_comparray($compname)] 
}

# Return the most recent version of component in the targetdir.
proc Get_comp_version {compname} {
    variable m_targetdir

    set versionlist [get_subdir $m_targetdir$compname/]
    return [lindex [lsort -dictionary $versionlist] end]
}

# Create initial component in targetdir with initial version.
proc Init_comp {compname version} {
    variable m_targetdir
    variable m_target_comparray

    # Each component looks like /stock/source_table
    # or /basic/sink
    if {[Is_comp_present $compname]} {
	return 0
    }

    file mkdir $m_targetdir$compname/$version
    set m_target_comparray($compname) $version
    return [add_comp_imp $compname $version] 
}

# Create new version subdir in targetdir for the given component.
proc Add_comp {compname ver_incr} {
    variable m_targetdir
    variable m_target_comparray

    if {![Is_comp_present $compname]} {
	return 0
    }

    set version [Get_comp_version $compname]
    set version [format %.2f [expr $version + $ver_incr]]
    file mkdir $m_targetdir$compname/$version
    set m_target_comparray($compname) $version

    return [add_comp_imp $compname $version]
}

# Is the source component different as the one in the targetdir
# under the given version subdir?
proc Is_comp_change {compname} {
    global tcl_platform 
    variable m_srcdir
    variable m_targetdir

    # Each component looks like /stock/source_table
    if {[string first "Windows" $tcl_platform(os)] > -1} {
	puts "rsync not supported in windows"
	return 0
    } else {
    	set version [Get_comp_version $compname]
    	set subdir $m_targetdir$compname/$version

    	# Use rsync
	# If there is difference between source and target dirs
	# the incremental file list will contain the component name.
	catch {exec rsync -Ccavn --exclude "*.blk" $m_srcdir$compname/ $subdir/} rc

	# Need to isolate the component name without any prefix at all.
	set idx [string last "/" $compname]
	incr idx
	set name [string range $compname $idx end]

	# The result from rsync looks like
	# ...
	# sending incremental file list
	# ./
	# name/module1
	# name/module2
	#...
	# If there is nothing after the first 
	# ./
        # line that there are no changes.	
	set idx [string first "sending incremental file list" $rc]
	if {$idx == -1} {
	    return 0
	}
	incr idx [string length "sending incremental file list"]
	set rc [string range $rc $idx end]
	if {[string first $name $rc] == -1} {
    	    return 0 
	} else {
	    return 1 
	}
    }
}

proc Update_All {} {
    variable m_version
    variable m_version_incr
    variable m_src_complist
   
    foreach compname $m_src_complist {
	if {[Is_comp_present $compname]} {
	    if {[Is_comp_change $compname]} {
		puts "Update component $compname"
		Add_comp $compname $m_version_incr
	    }
	} else {
	    puts "Add component $compname"
	    Init_comp $compname $m_version
	}
    }
    return
}  
}

