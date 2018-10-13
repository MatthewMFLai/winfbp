namespace eval inet_if {

variable m_filter_list
variable m_words

proc init {filter} {
    variable m_filter_list
    variable m_words

    set m_filter_list $filter
    set m_words ""
 
    return
}

proc words_set {words} {
    variable m_words

    set m_words $words
    return
}

proc words_add {words} {
    variable m_words

    set m_words [concat $m_words $words]
    return
}

proc words_delete {words} {
    variable m_words

    foreach word $words {
	set idx [lsearch $m_words $word]
	if {$idx > -1} {
	    set m_words [lreplace $m_words $idx $idx]
	}
    }
    return
}

proc words_check {word} {
    variable m_words

    return [lsearch $m_words $word]
}

proc word_filter_check {word} {
    variable m_filter_list

    set firstchar [string index $word 0]
    return [lsearch $m_filter_list $firstchar]
}

}

###########################################################
# Framework proceudres
###########################################################
proc ldifference {a b} {
     foreach e $b {
        set x($e) {}
     }
     set result {}
     foreach e $a {
        if {![info exists x($e)]} {
            lappend result $e
        }
     }
     return $result
}

proc forward_ip {p_ip word outport} {

    set p_out [ip::clone $p_ip]
    if {[byList::get_crawler $p_out] != "stub"} {
    	byList::set_list $p_out [list word $word]
    }
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc forward_load_response {p_ip words outport} {

    set p_out [ip::clone $p_ip]
    if {[byList::get_crawler $p_out] != "stub"} {
    	byList::set_list $p_out [list words $words]
    }
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc process {inport p_ip} {

    set rc ""
	
    if {$inport == "IN-1"} {
    	array set tmpdata [byList::get_list $p_ip]
	set words $tmpdata(words)
	set tmplist ""
	foreach word $words {
    	    if {[inet_if::words_check $word] == -1 &&
		[inet_if::word_filter_check $word] > -1} {
		lappend tmplist $word
	    }    
	}
	forward_load_response $p_ip [ldifference $words $tmplist] "OUT-2"

	foreach word $tmplist {
	    forward_ip $p_ip $word "OUT-1"
	}
	#inet_if::words_add $tmplist

    } elseif {$inport == "IN-2"} {
    	array set tmpdata [byList::get_list $p_ip]
	set words $tmpdata(words)
	set mode $tmpdata(mode)
	if {$mode == "CACHE_SET"} {
	    inet_if::words_add $words
	} elseif {$mode == "CACHE_DEL"} {
	    inet_if::words_delete $words
	} else {

	}
    } else {

    }
    return $rc
}

proc init {datalist} {
    set filter [lindex $datalist 0]
    inet_if::init $filter
    return
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
