namespace eval txlate {

variable m_map
variable m_localmap

proc init {} {
    variable m_map
    variable m_localmap

    if {[info exists m_map]} {
	unset m_map
    }
    array set m_map {}
    if {[info exists m_localmap]} {
	unset m_localmap
    }
    array set m_localmap {}
    return
}

proc extract_words {data} {
    regsub -all "\n" $data " " data
    regsub -all "\"" $data " " data

    foreach word $data {
        set word [string tolower $word]
    	if {[string is alpha $word]} {
	    lappend wordlist $word
    	} else {
	    set newword ""
	    set max [string length $word]
	    set i 0
	    while {$i < $max} {
	    	set char [string index $word $i]
	    	if {[string is alpha $char] ||
		    $char == "-" ||
		    $char == "-"} {
		    append newword $char
	    	}
	        incr i
	    }
	    if {$newword != ""} {
	    	lappend wordlist $newword
	    }
    	}
    }
    set wordlist [lsort -unique $wordlist]
    return $wordlist
}

proc map_set {word meanings} {
    variable m_map

    if {$meanings == ""} {
	return
    }

    if {![info exists m_map($word)]} {
	set m_map($word) $meanings
    }
    return
}

proc map_get {word} {
    variable m_map

    set rc ""
    if {[info exists m_map($word)]} {
	set rc $m_map($word)
    }
    return $rc
}

proc map_get_words {} {
    variable m_map
    return [array names m_map] 
}

proc map_clear {word} {
    variable m_map
    if {[info exists m_map($word)]} {
	unset m_map($word)
    }
    return
}

proc localmap_default {word idxlist} {
    variable m_localmap

    foreach idx $idxlist {
	set m_localmap($word,$idx) 0
    }
    return
}

proc localmap_get {word idx} {
    variable m_localmap

    set rc ""
    if {[info exists m_localmap($word,$idx)]} {
	    set rc $m_localmap($word,$idx)
    }
    return $rc
}

proc localmap_get_all {} {
    variable m_localmap

    set rc ""
    foreach index [array names m_localmap] {
	set offset $m_localmap($index)
	set word [lindex [split $index ","] 0]
	set idx [lindex [split $index ","] 1]
	set meanings [map_get $word]
	if {$meanings == ""} {
	    continue
	}
	lappend rc [list $word $idx [lindex $meanings $offset]]
    }
    return $rc
}

# Similar to localmap_get_all except only return the words without
# the repeating meanings.
# i.e. if we have {woods,5.64 0} {woods,6.21 0} then return the
# first occurence, that is, {woods,5.64 0} only.

proc localmap_get_all_no_repeat {} {
    variable m_localmap

    set rc ""
    set indexlist ""
    array set tmptable {}
    foreach index [lsort [array names m_localmap]] {
	set offset $m_localmap($index)
	set word [lindex [split $index ","] 0]
	if {![info exists tmptable($word,$offset)]} {
	    set tmptable($word,$offset) 1
	    lappend indexlist $index
	}	
    }

    foreach index $indexlist {
	set offset $m_localmap($index)
	set word [lindex [split $index ","] 0]
	set idx [lindex [split $index ","] 1]
	set meanings [map_get $word]
	if {$meanings == ""} {
	    continue
	}
	lappend rc [list $word $idx [lindex $meanings $offset]]
    }
    return $rc
}

proc localmap_set {word idx offset} {
    variable m_localmap

    set m_localmap($word,$idx) $offset
    return
}

proc localmap_clear {word} {
    variable m_localmap

    foreach index [array names m_localmap "$word,*"] {
    	unset m_localmap($index)
    }
    return
}

proc map_save {mapfile} {
    variable m_map
    variable m_localmap

    set fd [open $mapfile w]
    puts $fd [array get m_map]
    puts $fd [array get m_localmap]
    close $fd 
    return
}

proc map_load {mapfile} {
    variable m_map
    variable m_localmap

    if {![file exists $mapfile]} {
	return
    }

    set fd [open $mapfile r]
    if {[gets $fd mapdata] > -1} {
    	if {[info exists m_map]} {
	    unset m_map
    	}
    	array set m_map $mapdata
    }

    if {[gets $fd mapdata] > -1} {
    	if {[info exists m_localmap]} {
	    unset m_localmap
    	}
    	array set m_localmap $mapdata
    }

    close $fd
    return
}

}
