proc send_request {symbol exchange outport} {
    global g_crawler

    set p_ip [ip::source]
    byRetry::init $p_ip
    byRetry::set_retry $p_ip 0
    byList::init $p_ip
    byList::set_list $p_ip "Yield 0.0 fundamental_symbol $symbol exchange $exchange"
    byList::set_crawler $p_ip $g_crawler
    server_send $p_ip $outport 
    ip::sink $p_ip
    return
}

proc process {inport p_ip} {
    global g_request
    global g_delay

    set rc ""
    if {$inport == "IN-1"} {
    	set symbol [lindex [byList::get_list $p_ip] 0]
    	set exchange [lindex [byList::get_list $p_ip] 1]
	if {$g_delay !=0} {
	    # Put in a 10 seconds wait.
	    after [expr int(1000 * rand() * $g_delay)]
	}
	send_request $symbol $exchange OUT-1

    } else {

    }
    return $rc
}

proc init {datalist} {
    global g_crawler
    global g_delay

    set g_crawler [lindex $datalist 1]
    set g_delay [lindex $datalist 2]
    if {$g_delay == ""} {
	set g_delay 0
    }
    return
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(COMP_HOME)/ip2/byRetry.tcl
