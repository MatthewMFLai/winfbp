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

#Copyright (c) 2000-2015  Matthew Lai (E-mail: mmlai@sympatico.ca)
#
#This module is free software; you can use, modify, and redistribute it
#for any purpose, provided that existing copyright notices are retained
#in all copies and that this notice is included verbatim in any
#distributions.
#
#This software is distributed WITHOUT ANY WARRANTY; without even the
#implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
proc compareAsSetOrg {item1 item2} {
    foreach {opt1 dbName1 dbClass1 default1 current1} $item1 \
	    {opt2 dbName2 dbClass2 default2 current2} $item2 {
	set changed1 [expr {[string compare $default1 $current1] != 0}]
	set changed2 [expr {[string compare $default2 $current2] != 0}]
	if {$changed1 == $changed2} {
	    return [string compare $opt1 $opt2]
	} elseif {$changed1} {
	    return -1
	} else {
	    return 1
	}
    }
}

proc compareAsSet {item1 item2} {
    if {[string is alpha $item1] || [string is alpha $item2]} {
	    return [string compare $item1 $item2]
    } else {
	if {$item1 > $item2} {
	    return 1
	} else {
	    return -1
	}
    }
}

proc process_template {filename p_keylist} {
    upvar $p_keylist keylist
    set rc ""
    set rclist ""

    if {![file exist $filename]} {
	puts "$filename does not exist"
	return
    }
    set fd [open $filename "r"] 
    while {[gets $fd line] > -1} {
	set lower [lindex $line end-1]
	set upper [lindex $line end]
	if {![string is integer $lower] || ![string is integer $upper]} {
	    lappend keylist $line
	    continue
	}
	set key [join [lrange $line 0 end-2]]
	puts "$key $lower $upper"
	set result [Dividend::search_db $key $lower $upper]
	set rc [UtilSet::lunion $rc $result]
	lappend rclist $result 
	lappend keylist $key
    }
    close $fd

    foreach result $rclist {
	set rc [UtilSet::lintersect $rc $result]
    }	
    return $rc
}

lappend auto_path $env(DISK2)/tclkit/modules
package require tablelist
source $env(PATTERN_HOME)/set.tcl
source dividend_db.tcl

set filename [lindex $argv 0]
Dividend::init $filename
set keylist "Symbol"
set symbollist [process_template [lindex $argv 1] keylist]
puts $symbollist

set keylist2 ""
set width 0 
foreach key $keylist {
    lappend keylist2 $width
    lappend keylist2 $key    
}

tablelist::tablelist .t -columns $keylist2 -stretch all -background white -xscrollcommand {.xbar set} -yscrollcommand {.ybar set} -titlecolumns 1 -labelcommand tablelist::sortByColumn -sortcommand compareAsSet -movablecolumns 1
# Enable column wrap
#set lst {}
#set colCount [.t columncount]
#for {set col 0} {$col < $colCount} {incr col} {
#    lappend lst $col -wrap true
#}
#.t configcolumnlist $lst
# Enable column wrap end
scrollbar .xbar -ori hori -command {.t xview}
scrollbar .ybar -ori vert -command {.t yview}
pack .ybar -side right -fill y
pack .xbar -side bottom -fill both
pack .t -fill both -expand 1 -side top

foreach symbol $symbollist {
    array set tmptable {}
    set tmptable(Symbol) $symbol
    set dataline ""
    Dividend::get_symbol $symbol tmptable
    foreach key $keylist {
	if {[info exists tmptable($key)]} {	
	    lappend dataline $tmptable($key)
    	} else {
	    lappend dataline "" 
	}
    }
    .t insert end $dataline 
    unset tmptable
}
