namespace eval qdo {

variable m_symbols
variable m_criteria
variable m_data

proc init {} {
    variable m_symbols
    variable m_criteria
    variable m_data

    if {[info exists m_data]} {
	unset m_data
    }
    array set m_data {}
    set m_symbols ""
    set m_criteria ""
    return
}

proc set_value {symbol criterion value} {
    variable m_symbols
    variable m_criteria
    variable m_data

    if {[lsearch $m_symbols $symbol] == -1} {
	lappend m_symbols $symbol
    }
    if {[lsearch $m_criteria $criterion] == -1} {
	lappend m_criteria $criterion
    }
    set m_data($symbol,$criterion) $value
    return
}

proc get_symbols {} {
    variable m_symbols

    return $m_symbols
}

proc get_criteria {} {
    variable m_criteria

    return $m_criteria
}

proc get_criterion_data {criterion} {
    variable m_criteria
    variable m_data

    set rc ""
    if {[lsearch $m_criteria $criterion] == -1} {
	return $rc
    }

    set orderlist ""
    array set tmptable {}
    foreach idx [lsort [array names m_data "*,$criterion"]] {
	set symbol [lindex [split $idx ","] 0]
	set value $m_data($idx)
	if {[lsearch $orderlist $value] == -1} {
	    lappend orderlist $value
	    set tmptable($value) ""
	}
    	lappend tmptable($value) $symbol
    }

    set orderlist [lsort -dictionary -decreasing $orderlist]
    foreach value $orderlist {
	foreach symbol $tmptable($value) {
	    lappend rc [list $symbol $value]
	}
    }
    return $rc
}

}
