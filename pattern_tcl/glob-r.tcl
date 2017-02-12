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
proc runit {dirname} {
    global tcl_platform

    set rc ""
    if {[string first "Windows" $tcl_platform(os)] != -1} {
    	set filelist [concat [glob -nocomplain $dirname/*] [glob -nocomplain -types hidden $dirname/*]]
    } else {
    	set filelist [glob -nocomplain $dirname/*]
    }
    foreach filename $filelist {
	if {[file isdirectory $filename] &&
	    [string first "cache" $filename] == -1} {
	    set rc [concat $rc [runit $filename]]
	} else {
	    lappend rc $filename
	}
    }
    return $rc
}

proc deleteCVS {dirname} {
    set dirlist ""
    foreach filename [runit $dirname] {
	set idx [string first "CVS" $filename]
	if {$idx == -1} {
	    continue
	}
	incr idx 2
	set dirname [string range $filename 0 $idx]
	if {[lsearch $dirlist $dirname] == -1} {
	    lappend dirlist $dirname
	}
    }
    foreach dir $dirlist {
	file delete -force $dir
    }
    return
}

proc change_CVS_root {dirname} {
    foreach filename [runit $dirname] {
	set idx [string first "Root" $filename]
	if {$idx == -1} {
	    continue
	}
	set fd [open $filename w]
	puts -nonewline $fd "\$CVSROOT"
	close $fd
    }
    return
}

proc change_CVS_root_ip {dirname new_ip} {
    foreach filename [runit $dirname] {
	set idx [string first "Root" $filename]
	if {$idx == -1} {
	    continue
	}
	set fd [open $filename r]
	gets $fd line
	close $fd
	# line should look like
	# :ssh:lai@192.168.2.10:/home/lai/sandbox
	set idx [string first "@" $line]
	set idx2 [string first ":" $line $idx]
	set newline [string range $line 0 $idx]$new_ip[string range $line $idx2 end]
	set fd [open $filename w]
	puts -nonewline $fd $newline 
	close $fd
	puts "Changed $filename"
    }
    return
}

proc gen_bat_from_sh {dirname} {
    global env

    if {![file exists $dirname/windows] ||  
	![file isdirectory $dirname/windows]} {
	return
    }
    set suffix ".bat"
    foreach filename [glob $dirname/*.sh] {
	puts $filename
	set curname $filename
	set filename [lindex [split $filename "/"] end]
	set idx [string last "." $filename]
	incr idx -1
	set filename [string range $filename 0 $idx]
	set filename $dirname/windows/$filename$suffix

	set fd [open $curname r]
	set fd2 [open $filename w]
	while {[gets $fd line] > -1} {
	    if {[string first "rm " $line] > -1 ||
		[string first "mv " $line] > -1} {
	        regsub -all "rm " $line "erase " line]
    	        regsub -all "mv " $line "move " line
		regsub -all "/" $line "\\" line
    	    } else {
		set curline $line
		set line "tclsh "
		append line $curline
	    }

	    # Change all environment variable from $XYZ to %XYZ%
	    foreach envvar [array names env] {
		regsub -all {\$} $line "#" line
		regsub -all "#$envvar" $line "%$envvar%" line
		regsub -all "#" $line {$} line
	    }
	    puts $fd2 $line
	}
	close $fd
	close $fd2
    }
}

