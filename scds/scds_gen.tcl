namespace eval Scds {

    variable object
    variable pattern
    variable concrete_pattern
    variable mapper
    variable mapper_complex
    variable obj_pattern_map
    variable pattern_operation

proc Init {} {
    variable object
    variable pattern
    variable concrete_pattern
    variable mapper
    variable mapper_complex
    variable obj_pattern_map
    variable pattern_operation

    set object ""
    set pattern ""
    set concrete_pattern ""
    array set mapper {}
    array set mapper_complex {}
    array set obj_pattern_map {}
    array set pattern_operation {}

    return
}
 
proc scan_pattern {line mode} {
    variable pattern
    variable concrete_pattern
    variable mapper
    variable mapper_complex

    set concrete_pattern_str [lindex $line 0]
    set pattern_str [lindex $line 1]

    if {[lsearch $pattern $pattern_str] == -1} {
	lappend pattern $pattern_str
    }

    if {[lsearch $concrete_pattern $concrete_pattern_str] == -1} {
	lappend concrete_pattern $concrete_pattern_str
    } else {
	# Concrete pattern cannot be mapped to two or more pattern.
	return "$concrete_pattern_str mapped to multiple generic patterns"
    }

    if {$mode == "SIMPLE"} {
    	if {[info exists mapper($pattern_str)] == -1} {
	    set mapper($pattern_str) ""
    	}
    	lappend mapper($pattern_str) $concrete_pattern_str
    } else {
    	if {[info exists mapper_complex($pattern_str)] == -1} {
	    set mapper_complex($pattern_str) ""
    	}
    	lappend mapper_complex($pattern_str) $concrete_pattern_str
    }
    return ""
}

proc scan_dynamic_type {line} {
    variable object
    variable concrete_pattern
    variable obj_pattern_map

    set concrete_pattern_str [lindex $line 1]
    set object_str [lindex $line 0]
    set operation_str [lindex $line 2]

    if {[lsearch $object $object_str] == -1} {
	lappend object $object_str
    }

    if {[lsearch $concrete_pattern $concrete_pattern_str] == -1} {
	return "$concrete_pattern_str not present"	
    }

    if {[validate_pattern_operation $concrete_pattern_str $operation_str] == 0} {
	return "operation_str not supported by $concrete_pattern_str"
    }

    if {[info exists obj_pattern_map($object_str,$concrete_pattern_str)] == 0} {
    	set obj_pattern_map($object_str,$concrete_pattern_str) "" 
    }
    set operations $obj_pattern_map($object_str,$concrete_pattern_str)
    if {[lsearch $operations $operation_str] > -1} {
	return "$object_str $concrete_pattern_str $operation_str already exists"
    }
    lappend obj_pattern_map($object_str,$concrete_pattern_str) $operation_str

    return ""
}

proc validate_pattern {pattern_str dirname} {
    variable pattern

    return 1
}

proc get_pattern_operations {pattern_str dirname} {
    variable pattern_operation

    return "" 
}

proc validate_pattern_operation {concrete_pattern_str operation} {
    variable concrete_pattern
    variable mapper
    variable pattern_operation

    return 1
}

proc Dump {} {
    variable object
    variable pattern
    variable concrete_pattern
    variable mapper
    variable mapper_complex
    variable obj_pattern_map
    variable pattern_operation

    puts "objects"
    foreach token $object {
	puts $token
    }
    puts ""

    puts "patterns"
    foreach token $pattern {
	puts $token
    }
    puts ""

    puts "concrete_patterns"
    foreach token $concrete_pattern {
	puts $token
    }
    puts ""

    puts "mapper"
    foreach idx [array names mapper] {
	puts "$idx $mapper($idx)"
    }
    puts ""

    puts "mapper_complex"
    foreach idx [array names mapper_complex] {
	puts "$idx $mapper_complex($idx)"
    }
    puts ""

    puts "obj_pattern_map"
    foreach idx [array names obj_pattern_map] {
	puts "$idx $obj_pattern_map($idx)"
    }
    puts ""

    return
}

proc Gen_graph {filename} {
    variable mapper
    variable mapper_complex
    variable obj_pattern_map

    set fd [open $filename w]
    puts $fd "digraph G \{"
    puts $fd "graph\[rankdir=LR];"

    foreach generic_pattern [array names mapper] {
	foreach pattern $mapper($generic_pattern) {
	    puts $fd "$pattern -> $generic_pattern;"
	}
    }
    foreach generic_pattern [array names mapper_complex] {
	foreach pattern $mapper_complex($generic_pattern) {
	    puts $fd "$pattern -> $generic_pattern;"
	}
    }
    foreach index [array names obj_pattern_map] {
	set object [lindex [split $index ","] 0]
	set pattern [lindex [split $index ","] 1]
	foreach operation $obj_pattern_map($index) {
	    puts $fd "$object -> $pattern \[label=\"$operation\",fontsize=8\];"
	}
    }
    puts $fd "\}"
    close $fd
    return
}

proc Buildit {configfile} {
    variable object
    variable pattern
    variable concrete_pattern
    variable mapper
    variable pattern_operation

    set state "FIND_BEGIN"
    set dirname ""
 
    set fd [open $configfile r]
    while {[gets $fd line] > -1} {
	set line [string trim $line]
	if {$line == ""} {
	    continue
	}
	switch -- $state \
	  FIND_BEGIN {
	    if {[string first "BEGIN simple" $line] == 0} {
		set state "SIMPLE_PROCESS"
		set dirname [lindex $line 2]
		continue
	    }
	    if {[string first "BEGIN complex" $line] == 0} {
		set state "COMPLEX_PROCESS"
		set dirname [lindex $line 2]
		continue
	    }
	    if {[string first "BEGIN dynamic_type" $line] == 0} {
		set state "DYNAMIC_TYPE_PROCESS"
		continue
	    }
	} SIMPLE_PROCESS {
	    if {[string first "END" $line] == 0} {
		set state "FIND_BEGIN"
		continue
	    }
	    set rc [scan_pattern $line SIMPLE]
	    if {$rc != ""} {
		puts "SIMPLE_PROCESS: $rc"
	    }
 
	} COMPLEX_PROCESS {
	    if {[string first "END" $line] == 0} {
		set state "FIND_BEGIN"
		continue
	    }
	    set rc [scan_pattern $line COMPLEX]
	    if {$rc != ""} {
		puts "COMPLEX_PROCESS: $rc"
	    }

	} DYNAMIC_TYPE_PROCESS {
	    if {[string first "END" $line] == 0} {
		set state "FIND_BEGIN"
		continue
	    }
	    set rc [scan_dynamic_type $line]
	    if {$rc != ""} {
		puts "DYNAMIC_TYPE_PROCESS: $rc"
	    }

	}
    }
    close $fd	
}

proc get_platform {} {
    global tcl_platform

    set rc 0
    if {$tcl_platform(platform) == "unix"} {
	set rc 1
    }
    return $rc
}
 
proc gen_pattern_makefile {p_mapper pattern_dir pattern_dir2 filename} {
    upvar $p_mapper mapper
    global env

    set isUnix [get_platform] 

    set fd [open $filename w]
    if {$isUnix} {
	puts $fd "TCL ="
	puts $fd "RM = rm"
    } else {
	puts $fd "TCL = tclsh"
	puts $fd "RM = erase"
    }

    set genprogram "genPattern.tcl"
    set tab "\t"
    set slash "/"
    set tcl_suffix ".tcl"
    array set inverse_map {}
    set patternlist ""

    foreach pattern [array names mapper] {
	set patternlist [concat $patternlist $mapper($pattern)]
	foreach concrete_pattern $mapper($pattern) {
	    set inverse_map($concrete_pattern) $pattern
	}
    }	
    set line "corepanel : "
    set cleanline "clean :\n$tab"
    append cleanline "\$(RM) "
    foreach concrete_pattern $patternlist {
	append line "$concrete_pattern$tcl_suffix "
	append cleanline "$concrete_pattern$tcl_suffix "
    }
    puts $fd $line
    puts $fd ""

    foreach concrete_pattern $patternlist {
		
	set line "$concrete_pattern$tcl_suffix : $pattern_dir$slash$inverse_map($concrete_pattern)$tcl_suffix"
	puts $fd $line 
	set line "$tab\$(TCL) $pattern_dir2$slash$genprogram $pattern_dir$slash$inverse_map($concrete_pattern) $concrete_pattern"
	puts $fd $line
	puts $fd ""
    }
    puts $fd $cleanline
    close $fd
}

proc gen_class_makefile {pattern_dir pattern_dir2 filename} {
    variable mapper
    global env

    set isUnix [get_platform] 

    set fd [open $filename w]
    if {$isUnix} {
	puts $fd "TCL ="
	puts $fd "RM = rm"
    } else {
	puts $fd "TCL = tclsh"
	puts $fd "RM = erase"
    }

    set genprogram "genclass.tcl"
    set tab "\t"
    set slash "/"
    set tcl_suffix ".tcl"
    set dat_suffix ".dat"
    set patternlist ""

    set line "target: "
    set cleanline "clean :\n$tab"
    append cleanline "\$(RM) "
    foreach pattern [array names mapper] {
	append line "$pattern$tcl_suffix "
	append cleanline "$pattern$tcl_suffix "
    }
    puts $fd $line
    puts $fd ""

    foreach pattern [array names mapper] {
	
	set line "$pattern$tcl_suffix : $pattern$dat_suffix"
	puts $fd $line
	set line "$tab\$(TCL) $pattern_dir2$slash$genprogram $pattern$dat_suffix"
	puts $fd $line
	puts $fd ""
    }
    puts $fd $cleanline
    close $fd
}

proc gen_dynamic_type {filename} {
    variable object
    variable obj_pattern_map

    set fd [open $filename w]
    foreach object_str $object {
	set line "proc init_$object_str "
	append line "\{p_node\} \{"
	puts $fd $line
	puts $fd ""
	foreach mapping [array names obj_pattern_map "$object_str,*"] {
	    set pattern [lindex [split $mapping ","] 1]
	    foreach operation $obj_pattern_map($mapping) { 
	    	set line "    $pattern\:\:$operation \$p_node" 
	    	puts $fd $line
	    }
	}
        puts $fd "\}"
        puts $fd ""
    }
    close $fd
}

proc Runit {mk_class mk_simple mk_complex dynamic_type_file dat_dir} {
    variable mapper
    variable mapper_complex

    gen_class_makefile {$(PWD)} {$(PATTERN_HOME)} $mk_class
    gen_pattern_makefile mapper $dat_dir {$(PATTERN_HOME)} $mk_simple
    gen_pattern_makefile mapper_complex {$(PATTERN_HOME)} {$(PATTERN_HOME)} $mk_complex
    gen_dynamic_type $dynamic_type_file
    return
}  
}
