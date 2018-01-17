namespace eval histrange {

variable m_idx_list

proc init {filename} {
    variable m_idx_list
	
	set m_idx_list ""
	
	set fd [open $filename r]
	gets $fd line
	set low [string trim $line]
	while {[gets $fd line] > -1} {
	    set high [string trim $line]
		lappend m_idx_list "$low,$high"
		set low $high	    
	}

    return
}

proc get_range_idx {value} {
    variable m_idx_list
	
	if {$value < 0} {
	    set rc [lindex $m_idx_list 0]
	} else {
	    set rc [lindex $m_idx_list end]
	}
	
	foreach range $m_idx_list {
	    set low [lindex [split $range ","] 0]
	    set high [lindex [split $range ","] 1]
		
	    if {$low < $value && $value <= $high} {
		    set rc $range
			break
		}
	}
    return $rc
}

proc get_range {idx p_low p_high} {
    upvar $p_low low
	upvar $p_high high

	set low [lindex [split $idx ","] 0]
	set high [lindex [split $idx ","] 1]

    return
}

proc get_idx_all {} {
    variable m_idx_list
	return $m_idx_list
}
}
