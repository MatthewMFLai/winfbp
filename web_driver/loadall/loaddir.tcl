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
source $env(PATTERN_HOME)/sys_util.tcl

proc findfsm {dirname crawler p_data} {
    upvar $p_data data

    # From the files in the given directory, look for xxx_fsm.tcl and
    # xxx_fsm.dat.
    # Also look for $crawler.tcl
    set found_crawler 0
    if {[catch {glob $dirname/$crawler/*} filelist]} {
	return $found_crawler
    }

    set list_tcl ""
    set list_dat ""
    foreach token $filelist {
	if {[file isdir $token]} {
	    continue
	}
	regsub "$dirname/$crawler/" $token "" filename
	if {$filename == "$crawler\.tcl"} {
	    set found_crawler 1
	    continue
	}
	set idx [string first "_fsm.tcl" $filename]
	if {$idx > 0} {
	    incr idx -1
	    lappend list_tcl [string range $filename 0 $idx]
	    continue
	}	
	set idx [string first "_fsm.dat" $filename]
	if {$idx > 0} {
	    incr idx -1
	    lappend list_dat [string range $filename 0 $idx]
	    continue
	}
    }
   
    # In the runtime environment all the tcl module under the
    # WEB_DRIVER directory will be removed, hence the following
    # logic will not work. Thus we need to check for runtime
    # environment first.
    
    if {[UtilSys::Is_Runtime] == 0} { 
    	foreach fsm $list_tcl {
    	    if {[lsearch $list_dat $fsm] != -1} {
    	    	set data($fsm) 1
    	    }
    	}
    } else {
    	foreach fsm $list_dat {
            set data($fsm) 1
	    set found_crawler 1
    	}
    }
    return $found_crawler	
}

proc loadeach {rootdir symbol} {
    set tcl_suffix "_fsm.tcl"
    set dat_suffix "_fsm.dat"
    set fsm_suffix "_fsm"
    set just_tcl_suffix ".tcl"

    array set data {}
    if {![findfsm $rootdir $symbol data]} {
    	return 
    }
# DYNAMIC SOURCE BEGIN
    source $rootdir/$symbol/$symbol$just_tcl_suffix
# DYNAMIC SOURCE END 
    foreach fsm [array names data] {
# DYNAMIC SOURCE BEGIN
    	source $rootdir/$symbol/$fsm$tcl_suffix
# DYNAMIC SOURCE END 
    	Fsm::Load_Fsm $rootdir/$symbol/$fsm$dat_suffix
    	Fsm::Init_Fsm $symbol$fsm_suffix
    }
}

proc loadit {rootdir} {
    global env

    if {[catch {glob $rootdir/*} filelist]} {
	puts "loaddir: $rootdir is empty!"
	return
    }

# DYNAMIC SOURCE BEGIN
    source $env(FSM_HOME)/fsm.tcl
    source $env(PATTERN_HOME)/geturl.tcl
# DYNAMIC SOURCE END 

    foreach dirname $filelist {
	if {[file isdir $dirname] == 0} {
	    continue
	}
	if {[file exists $dirname/ignore]} {
	    continue
	}
	# Extract the symbol name.
	set idx [string last "/" $dirname]
	incr idx
	set symbol [string range $dirname $idx end]
	regsub -all {\.} $symbol "_" symbol
	loadeach $rootdir $symbol
    }
    package require htmlparse
}

