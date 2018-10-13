#!/bin/sh
# \
exec tclsh $0 "$@"
source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(WEB_DRIVER)/translate/translate_fsm.tcl
package require htmlparse

proc fsm_if {tag slash param text} {
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    #regsub -all "\n" $text "" text
    set tmpdata(tag) $tag
    set tmpdata(slash) $slash
    set tmpdata(param) $param
    set tmpdata(text) $text
    set rc [Fsm::Run translate_fsm tmpdata]
    if {$rc < 0} {
	puts "rc = $rc"
	puts [Fsm::Get_Error translate_fsm]
	exit -1
    }
}

proc fsm {tag slash param text} {
    global g_fd
    # A simple state machine to extract company 
    # description data from globeinvestor.com
    regsub -all "\n" $text "" text
    puts $g_fd "tag = $tag"
    puts $g_fd "slash = $slash"
    puts $g_fd "param = $param"
    puts $g_fd "text = $text"
    puts $g_fd ""
}

# sanity mode 0: get real url data, parse with default fsm.
# sanity mode 1: get real url data, parse with custom fsm.
# sanity mode 2: get  url data from file, parse with custom fsm.
set sanity_mode 0 
Url::init
 
if {$sanity_mode} {
    malloc::init
    Fsm::Init

    Fsm::Load_Fsm translate_fsm.dat
    Fsm::Init_Fsm translate_fsm
}


set infile [lindex $argv 0]
set sanity [lindex $argv 1]

if {$sanity_mode != 2} { 
    set in_fd [open $infile r]
    gets $in_fd url
    close $in_fd
    set data [Url::get_no_retry $url]

    # Custom code...

} else {
    set fd [open raw.dat r]
    set data [read $fd]
    close $fd
    # Custom code...
}

if {$sanity_mode == 0} {
    set fd [open raw.dat w]
    puts $fd $data
    close $fd
}

if {$sanity_mode} {
    htmlparse::parse -cmd fsm_if $data
    # Retrieve data from translate_fsm...
    # ...
    # ...
    if {$sanity != "test"} {
    	# Display etrieved data...
    	# ...
    	# ...
        translate_fsm::Dump
    } else {
    	# Check retrieved data and return -1 if data invalid.
    	# ...
    	# ...
	# if ....
	# exit -1
    }
	 
	
} else {
    set g_fd [open out.dat w]
    htmlparse::parse -cmd fsm $data
    close $g_fd
}
exit 0
