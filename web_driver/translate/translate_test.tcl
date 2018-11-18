#!/bin/sh
# \
exec tclsh $0 "$@"
source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(WEB_DRIVER)/translate/translate_fsm.tcl
source $env(WEB_DRIVER)/translate/translate.tcl
package require htmlparse

Url::init
malloc::init
Fsm::Init
Fsm::Load_Fsm translate_fsm.dat
Fsm::Init_Fsm translate_fsm

set fd [open url.template r]
gets $fd url_template
close $fd
translate::init $url_template

set wordfile [lindex $argv 0]
set outfile [lindex $argv 1]

set fd [open $wordfile "r"]
set wordlist ""
while {[gets $fd line] > -1} {
    foreach token $line {
	lappend wordlist [string tolower $token]
    }
}
close $fd
#set wordlist [lsort -unique $wordlist]

set fd [open $outfile "w"]
foreach word $wordlist {
    puts "process $word ..."
    translate::extract_data $word tmpdata
    puts $fd "$tmpdata(symbol) $tmpdata(meanings)"
    unset tmpdata 
}
close $fd
exit 0
