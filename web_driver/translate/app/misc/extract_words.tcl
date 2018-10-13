#!/bin/sh
# \
exec tclsh $0 "$@"

set src_file [lindex $argv 0]
set filter_file [lindex $argv 1]
set out_file [lindex $argv 2]

set fd [open $src_file "r"]
set data [read $fd]
close $fd
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

# Read in filter list.
set fd [open $filter_file "r"]
set filterlist ""
while {[gets $fd line] > -1} {
    foreach word $line {
	lappend filterlist $word
    }
}
close $fd

set finallist ""
foreach word $wordlist {
    if {[lsearch $filterlist $word] == -1} {
	lappend finallist $word
    }
}

set fd [open $out_file "w"]
foreach word $finallist {
    puts $fd $word
}
close $fd
exit 0
