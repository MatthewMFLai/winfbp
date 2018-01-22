proc gen_content {fd table separator nul} {
    global g_db

    set line ""
    set vw g_db.$table
    set properties [mk::view layout $vw]
    foreach property $properties {
	append line $property$separator
    }
    puts $fd [string range $line 0 end-1]

    mk::loop c $vw {
    	set line ""
	set cmd {mk::get $c }
	append cmd $properties	
	set datalist [eval $cmd]
	foreach token $datalist {
	    if {$token != ""} {
		append line $token$separator
	    } else {
		append line $nul$separator
	    }
	}
	puts $fd [string range $line 0 end-1]
    }
    return
}

proc gen_table {table exchange} {
    global env

    set filename $env(DISK2_DATA)/web_driver/common/$table\_$exchange
    if {[file exists $filename]} {
	file delete $filename
    }
    set fd [open $filename w]
    set separator "\t"
    set nul "nul"
    gen_content $fd $table $separator $nul
    close $fd
    return
}

proc gen_tables {dbfile exchange} {
    global g_db

    if {![file exists $dbfile]} {
	puts "$dbfile not found"
	return
    }
    mk::file open g_db $dbfile
    set infolist [mk::view layout g_db]
    foreach token $infolist {
	gen_table [lindex $token 0] $exchange
    }
    mk::file close g_db
    return
}

package require Mk4tcl

set datepattern "%Y%m%d"
set datestr [clock format [clock seconds] -format $datepattern] 

set env(DISK2) $env(DISK2_BACKUP)
set dbfile $env(DISK2)/scratchpad/db/db_T_$datestr
gen_tables $dbfile T
set dbfile $env(DISK2)/scratchpad/db/db_V_$datestr
gen_tables $dbfile V 
