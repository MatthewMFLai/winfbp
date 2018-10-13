###########################################################
# Framework proceudres
###########################################################

proc forward_ip {p_ip outport} {

    set p_out [ip::clone $p_ip]
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc forward_word_root_ip {p_ip word root outport} {

    set p_out [ip::clone $p_ip]
    byList::set_list $p_out [list symbol $word root $root]
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc send_request {word crawler outport} {

    set p_out [ip::source]
    byRetry::init $p_out
    byRetry::set_retry $p_out 0
    byList::init $p_out
    byList::set_list $p_out [list words $word]
    byList::set_crawler $p_out $crawler
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc log_word {word} {
    set fd [open /tmp/words.txt a]
    puts $fd "$word $word"
    close $fd
    return
}

proc process {inport p_ip} {
    global g_crawler_browse
    global g_crawler_translate

    set rc ""

    array set tmpdata [byList::get_list $p_ip]
    set crawler [byList::get_crawler $p_ip]
    if {$crawler == "translate"} {
        if {$tmpdata(meanings) != ""} {
    	    forward_ip $p_ip "OUT-1" 
    	} else {
	    send_request $tmpdata(symbol) $g_crawler_browse "OUT-2"
    	}

    } elseif {$crawler == "stub"} { 
    	forward_ip $p_ip "OUT-1"

    } elseif {$crawler == "gutenberg"} { 
    	forward_ip $p_ip "OUT-1"

    } elseif {$crawler == "browse"} { 

    	if {[info exists tmpdata(root)]} {
   	    set word $tmpdata(symbol)

    	    set rootlist $tmpdata(root)
    	    set discard 1
    	    foreach root $rootlist {
                # root must be one word and not a phrase
		if {$root != $word &&
                    [llength $root] == 1} {
	    	    set discard 0
	    	    break
	        }
    	    }

    	    if {!$discard} {
            	# The word and root must have the same first letter.
            	if {[string index $word 0] == [string index $root 0]} {
	    	    regsub -all {\-} $root "" root
                    # Double check to make sure root not equal to word!
                    if {$root != $word} {
	    	        send_request $root $g_crawler_translate "OUT-2"
	    	        forward_word_root_ip $p_ip $word $root "OUT-1"
                    }
	    	}
    	    } else {
	    	log_word $tmpdata(symbol)
	    }
    	} else {
	    log_word $tmpdata(symbol)
	}

    }
    return $rc
}

proc init {datalist} {
    global g_crawler_translate
    global g_crawler_browse

    set g_crawler_translate [lindex $datalist 0]
    set g_crawler_browse [lindex $datalist 1]
    return
}

proc shutdown {} {
    return
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(COMP_HOME)/ip2/byRetry.tcl
