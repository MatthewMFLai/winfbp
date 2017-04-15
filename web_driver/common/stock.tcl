namespace eval stock {

variable m_stockdb

proc init_file {filename} {

    variable m_stockdb

    set rc ""
    set fd [open $filename r]
    gets $fd col_desc

    while {[gets $fd line] > -1} {

	array set tmptable {}
	set line [split $line "\t"]
	set len [llength $line]
	for {set i 0} {$i < $len} {incr i} {
	    set col [lindex $col_desc $i]
	    set tmptable($col) [lindex $line $i]
	}

	set symbol $tmptable(symbol)
	lappend rc $symbol
	unset tmptable(symbol)

	foreach col [array names tmptable] {
	    set m_stockdb($symbol,$col) $tmptable($col) 
	}
	unset tmptable
    }
    close $fd
    return $rc
}

proc init {filenames} {
    variable m_stockdb
    variable m_symbols

    if {[info exists m_stockdb]} {
	unset m_stockdb
    }
    array set m_stockdb {}
    set m_symbols ""

    foreach filename $filenames {
	set m_symbols [concat $m_symbols [init_file $filename]]
    }
    set m_symbols [lsort -unique $m_symbols]
    return
}

proc search_str {col_name match_str p_rc} {
    upvar $p_rc rc
    variable m_stockdb

    foreach idx [array names m_stockdb "*,$col_name"] {
	if {[string first $match_str $m_stockdb($idx)] > -1} {
	    set symbol [lindex [split $idx ","] 0]
	    set rc($symbol) $m_stockdb($idx)
	}
    }
    return
}

proc search {col_name low high p_rc} {
    upvar $p_rc rc
    variable m_stockdb

    foreach idx [array names m_stockdb "*,$col_name"] {
	if {$m_stockdb($idx) < $high &&
            $m_stockdb($idx) > $low} {
	    set symbol [lindex [split $idx ","] 0]
	    set rc($symbol) $m_stockdb($idx)
	}
    }
    return
}
    # or
proc query {criteria} {
    # criteria should be of the form
    # {{<col_name> low high} {<col_name> low high} ... }

    variable m_symbols

    array set result {}
    foreach symbol $m_symbols {
	set result($symbol) 1
    }

    foreach tokens $criteria {
	array set rc {}
	set col_name [lindex $tokens 0]
	if {[llength $tokens] ==  3} {
	    set low [lindex $tokens 1]
	    set high [lindex $tokens 2]
	    search $col_name $low $high rc
	} elseif {[llength $tokens] == 2} {
	    set matchstr [lindex $tokens 1]
	    search_str $col_name $matchstr rc
	}
	foreach symbol [array names result] {
	    if {![info exists rc($symbol)]} {
		unset result($symbol)
	    }
	}
	unset rc
    }
    return [array names result]	
}

proc query_file_prepare {filename} {
    set criteria ""
    set fd [open $filename r]
    while {[gets $fd line] > -1} {
	if {[string index $line 0] == "#"} {
	    continue
	}
	if {[llength $line] < 2} {
	    continue
	}
	lappend criteria $line
    }
    close $fd
    return $criteria
}

proc query_file {filename} {
    if {![file exists $filename]} {
	puts "$filename does not exist!"
	return
    }
    set criteria [query_file_prepare $filename] 
    return [query $criteria]
}

proc query_file_symbol {symbol filename} {
    if {![file exists $filename]} {
	puts "$filename does not exist!"
	return
    }
    set rc ""

    # The returned criteria looks like {col low high} {col low high} ...
    # We need to extract all the col into a list.
    set collist ""
    foreach criteria [query_file_prepare $filename] {
	lappend collist [lindex $criteria 0]
    }
    set rc ""
    foreach token [get_info $symbol] {
	if {[lsearch $collist [lindex $token 0]] > -1} {
	    lappend rc $token
        }	    
    }
    return $rc
}
proc get_info {symbol} {
    variable m_symbols
    variable m_stockdb

    if {[lsearch $m_symbols $symbol] == -1} {
	return ""
    }
    set rc ""
    foreach idx [lsort [array names m_stockdb "$symbol,*"]] {
	set col [lindex [split $idx ","] 1]
	lappend rc "$col $m_stockdb($idx)"
    }
    return $rc
}

proc get_all_symbols {} {
    variable m_symbols

    return $m_symbols
}

}
