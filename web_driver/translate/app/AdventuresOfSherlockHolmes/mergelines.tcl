proc runit_imp {filename g_paralist} {
    upvar $g_paralist paralist
    set paralist ""
    set state BUILD_PARAGRAPH
	set fd [open $filename r]
    while {[gets $fd line] > -1} {
	    if {$state == "BUILD_PARAGRAPH"} {
			if {$line != ""} {
				set paragraph $line
				set state FIND_SEPARATOR
			}
		} elseif {$state == "FIND_SEPARATOR"} {
			if {$line == ""} {
				lappend paralist $paragraph
				set paragraph ""
				set state BUILD_PARAGRAPH
			} else {
                append paragraph " $line"						
			}
		}
	}
	if {$paragraph != ""} {
	    lappend paralist $paragraph
	}
    close $fd	
}

proc runit {infile outfile} {
    if {![file exists $infile]} {
	    puts "$infile does not exist!"
		exit -1
	}
    set paralist ""
	runit_imp $infile paralist
	set fd [open $outfile w]
	set len [llength $paralist]
	incr len -1
	for {set i 0} {$i < $len} {incr i} {
	    puts $fd [lindex $paralist $i]
		puts $fd ""
	}
	puts $fd [lindex $paralist end]
	close $fd
}