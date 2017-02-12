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
#!/bin/sh 
# \
exec tclsh $0 $@

# This script provides a backdoor access to update the version
# number of the factory components to the most recent version
# as specified in the passed in argument for the factory directory.
# Run this script right after 
# - make release is performed in the component directory.
# - update_all in update_production_nodes.tcl has been executed.
# - update all components to use the most recent version.

proc parseit {data p_prefix p_compname p_version} {
    upvar $p_prefix prefix
    upvar $p_compname compname
    upvar $p_version version

    # data should look like
    # $env(FACTORY)/basic/sink/0.01

    set idx [string first "/" $data]
    set idx2 [string last "/" $data]
    incr idx -1
    set prefix [string range $data 0 $idx]

    incr idx 1 
    incr idx2 -1
    set compname [string range $data $idx $idx2]

    incr idx2 2
    set version [string range $data $idx2 end]
    return
}

proc parseit2 {data p_prefix p_compname} {
    upvar $p_prefix prefix
    upvar $p_compname compname

    # data should look like
    # $env(DISK2)/component/basic/sink

    set idx [string first "/" $data]
    incr idx
    set idx2 [string first "/" $data $idx]
    incr idx2 -1
    set prefix [string range $data 0 $idx2]

    incr idx2
    set compname [string range $data $idx2 end]
    return
}

proc buildit {prefix compname version} {
    return $prefix$compname/$version
}

proc run_it {tmpdir factorydir infile outfile convert_all} {
    Updater::Init $tmpdir $factorydir
    set fd [open $infile r]
    set script [read $fd]
    close $fd

    set fd [open $outfile w]
    set linelist [split $script "\n"]
    foreach line $linelist {
	if {[string first "array set" $line] == 0} {
	    eval $line
	} else {
	    puts $fd $line
	}
    }
    foreach filepath [array names m_block "*,filepath"] {
	set token $m_block($filepath)
	if {[string first "FACTORY" $token] == -1} {
	    if {$convert_all != "yes"} {
	    	continue
	    }
	    # Only process components. 
	    if {[string first "/component" $token] == -1} {
	        continue
	    }
	    # Convert env(DISK2)/component to env(FACTORY)
	    parseit2 $token prefix compname
	    regsub "DISK2" $prefix "FACTORY" prefix
	    regsub "/component" $prefix "" prefix
	    set token [buildit $prefix $compname \
                       [Updater::Get_comp_version $compname]]
	    set m_block($filepath) $token
	    continue 
	}

	parseit $token prefix compname version
	if {[Updater::Get_comp_version $compname] != $version} {
	    set token [buildit $prefix $compname \
                       [Updater::Get_comp_version $compname]]
	    set m_block($filepath) $token
	}
    }
    set line "array set m_block \"[array get m_block]\""
    regsub -all {\$} $line "\\\$" line
    puts $fd $line 
    if {[array get m_portqueue] != ""} {
        set line "array set m_portqueue \"[array get m_portqueue]\""
    	puts $fd $line
    }
    close $fd
    return ""
}

source $env(PATTERN_HOME)/update_production_nodes.tcl

set tmpdir [lindex $argv 0]
set factorydir [lindex $argv 1]
set infile [lindex $argv 2]
if {![file exists $infile]} {
    puts "$infile does not exist."
    exit -1
}
set outfile [lindex $argv 3]
set convert_all [lindex $argv 4]

if {[catch {run_it $tmpdir $factorydir $infile $outfile $convert_all} rc]} {
    puts "rc = $rc"
    exit -1
}
exit 0

