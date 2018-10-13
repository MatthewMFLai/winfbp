###########################################################
# Framework proceudres
###########################################################

proc forward_ip {p_ip outport} {

    set p_out [ip::clone $p_ip]
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc forward_check {p_ip marker outport} {

    set p_out [ip::clone $p_ip]
    array set tmpdata [byList::get_list $p_ip]
    set tmpdata(marker) $marker
    byList::set_list $p_out [array get tmpdata]
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc process {inport p_ip} {
    global g_filter

    set rc ""

    array set tmpdata [byList::get_list $p_ip]
    set cmd $tmpdata(command)
    switch -- $cmd \
      CHECK {
	set sentence $tmpdata(sentence)
	set marker $tmpdata(marker)
	set idx 0
	foreach word $sentence {
	    set val [lindex $marker $idx]
	    if {[info exists g_filter($word)] &&
                $val == "WORD"} {
		set marker [lreplace $marker $idx $idx "NUL"]
	    }
	    incr idx
	}
	forward_check $p_ip $marker "OUT-1"
    } default {
	forward_ip $p_ip "OUT-1"
    }

    return $rc
}

proc init {datalist} {
    global g_filter

    if {[info exists g_filter]} {
	unset g_filter
    }
    array set g_filter {}
    set filename [lindex $datalist 0]
    if {![file exists $filename]} {
	return
    }

    set fd [open $filename r]
    while {[gets $fd line] > -1} {
	set word [string trim $line]
	set g_filter($word) 1
    }
    close $fd    
    return
}

proc shutdown {} {
    return
}

source $env(COMP_HOME)/ip2/byList.tcl
