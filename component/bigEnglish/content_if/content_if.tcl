proc forward_ip {p_ip outport} {

    set p_out [ip::clone $p_ip]
    server_send $p_out $outport
    ip::sink $p_out
    return
}

proc send_token_ip {cmd token outport} {

    set p_ip [ip::source]
    byList::init $p_ip
    byList::set_list $p_ip [list cmd $cmd data $token]
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc send_concordance_ip {title sentence nodeaddr outport} {

    set p_ip [ip::source]
    byList::init $p_ip
    set marker ""
    for {set i 0} {$i < [llength $sentence]} {incr i} {
	lappend marker "NUL"
    }
    byList::set_list $p_ip [list command "CHECK" title $title sentence $sentence marker $marker nodeaddr $nodeaddr]
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc process {inport p_ip} {
    global g_enable_save
    global g_to_save
    global g_max_lines
    global g_min_lines
    global g_cur_lines

    set rc ""

    array set tmpdata [byList::get_list $p_ip]
    set title $tmpdata(title)

    if {$inport == "IN-1"} {
	# Read
	set cmd $tmpdata(cmd)
	set depth $tmpdata(depth)

	if {$cmd == "Get_All_Token"} {
	    foreach token [Content::$cmd $title $depth] {
		send_token_ip $cmd $token "OUT-1"
	    }
	} elseif {$cmd == "Get_All_Title"} {
	    foreach token [Content::$cmd] {
		send_token_ip $cmd $token "OUT-1"
	    }
	} elseif {$cmd == "Get_Token_At_Level"} {
	    foreach token [Content::$cmd $title $depth] {
		send_token_ip $cmd $token "OUT-1"
	    }
	} elseif {$cmd == "Get_Token_Under_Addr"} {
	    set nodeaddr $tmpdata(addr)
	    foreach token [Content::$cmd $title $depth $nodeaddr] {
		send_token_ip $cmd $token "OUT-1"
	    }
	} elseif {$cmd == "Get_Concordance"} {
	    set nodeaddr $tmpdata(addr)
	    set token [Content::$cmd $title $depth $nodeaddr]
	    send_token_ip $cmd $token "OUT-1"
	} elseif {$cmd == "Get_ContextMeanings"} {
	    set nodeaddr $tmpdata(addr)
	    set token [Content::$cmd $title $nodeaddr]
	    send_token_ip $cmd $token "OUT-1"
	} else {

	}

    } elseif {$inport == "IN-2"} {

	if {$g_enable_save == 0} {
	    # TODO: need to mark some field to indicate not-saved?
	    forward_ip $p_ip "OUT-2"
	    return $rc
	}

	# Write
	set cmd $tmpdata(cmd)
	set data $tmpdata(data)
	set depth $tmpdata(depth)

	if {$cmd == "Add_Title_Author"} {
	    Content::$cmd $title $data
	    set g_to_save 1

	} elseif {$cmd == "Add_Token"} {
	    Content::$cmd $title $data $depth
	    set g_to_save 1

	} elseif {$cmd == "Add_Paragraph"} {
	    foreach linedata [Content::$cmd $data $depth $title] {
		set sentence [lindex $linedata 0]
		set nodeaddr [lindex $linedata 1]
		send_concordance_ip $title $sentence $nodeaddr "OUT-3"
		incr g_cur_lines
	    }
	    set g_to_save 1

	    # Block IP from port 2 if too many lines are being processed.
	    if {$g_cur_lines > $g_max_lines} {
		set rc [list IN-1 IN-3]
	    }
 
	} elseif {$cmd == "Add_ContextMeanings"} {
	    set nodeaddr $tmpdata(nodeaddr)
	    Content::$cmd $title $nodeaddr $data
	    set g_to_save 1

	} else {

	}
	forward_ip $p_ip "OUT-2"
  	
    } elseif {$inport == "IN-3"} {

	if {$g_enable_save == 0} {
	    # TODO: need to mark some field to indicate not-saved?
	    return $rc
	}

	# Write
	set sentence $tmpdata(sentence)
	set marker $tmpdata(marker)
	set nodeaddr $tmpdata(nodeaddr)
	Content::Add_Concordance $title $sentence $marker $nodeaddr
	set g_to_save 1

	# Unblock IP from port 2 if few lines are being processed.
	incr g_cur_lines -1
	if {$g_cur_lines == $g_min_lines} {
	    set rc [list IN-1 IN-2 IN-3]
	}
	
    } else {

    }

    return $rc
}

proc init {datalist} {
    global g_enable_save
    global g_filename
    global g_max_lines
    global g_min_lines
    global g_cur_lines
    global g_to_save

    set g_enable_save [lindex $datalist 0]
    set g_filename [lindex $datalist 1]
    set g_max_lines [lindex $datalist 2]
    set g_min_lines [lindex $datalist 3]
    if {$g_max_lines == ""} {
	set g_max_lines 100 
    }
    if {$g_min_lines == ""} {
	set g_max_lines 50 
    }
    set g_cur_lines 0
    set g_to_save 0

    Assert::Init
   
    if {[file exists $g_filename]} {
	malloc::restore $g_filename
	Content::Load $g_filename
    } else {
    	Content::Init
    }

    return
}

proc shutdown {} {
    global g_enable_save
    global g_filename
    global g_to_save

    if {$g_enable_save && $g_to_save} {
    	Content::Save xxx
    	malloc::save $g_filename
    }
    return
}

# Need to source in other tcl scripts in the same directory.
# The following trick to retrieve the current subdirectory
# should work.
#set scriptname [info script]
#regsub "mux.tcl" $scriptname "ZZZ" scriptname
#regsub "ZZZ" $scriptname "byMux.tcl" script2
#source $script2
source $env(CONTENT_HOME)/content.tcl
source $env(PATTERN_HOME)/assert.tcl
source $env(COMP_HOME)/ip2/byList.tcl
global g_enable_save
global g_filename
global g_to_save
