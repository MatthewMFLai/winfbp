proc update_db {table year date} {
    global g_db

    set line ""
    set vw g_db.$table
    set properties [mk::view layout $vw]
	# properties looks like
	#shares_outstanding	market_cap	pe	eps	pb	volume	price	symbol
	
	array set position {}
	set idx 0
    foreach property $properties {
        set position($property) $idx
		incr idx
    }

	# data looks like
	#305880218	2465394557	5.6	1.14	1.346	2407163	8.06	AAR.UN
	#96052282	16809149	1.5	0.12	0.357	62000	0.175	AAB
	array set data {}
    mk::loop c $vw {
    	set line ""
		set cmd {mk::get $c }
		append cmd $properties	
		set datalist [eval $cmd]
        set symbol [lindex $datalist $position(symbol)]
		set data(date) $date
		set data(volume) [lindex $datalist $position(volume)]
        set data(close) [lindex $datalist $position(price)]
        db_if::set_record $symbol $year data
    }
    return
}

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
		if {[lindex $token 0] == "stock"} {
			set datepattern "%Y-%m-%d"
			set datestr [clock format [clock seconds] -format $datepattern]
			set datepattern "%Y"
			set year [clock format [clock seconds] -format $datepattern]
		    update_db [lindex $token 0] $year $datestr
		}
    }
    mk::file close g_db
    return
}

lappend auto_path $env(DISK2)/tclkit/modules
package require Mk4tcl
source $env(DISK2)/web_driver/common/db_if.tcl
source $env(DISK2)/web_driver/common/get_history_range.tcl
source $env(WEB_DRIVER_HOME)/common/history_range.tcl
set dbpath $env(DISK2_DATA)/scratchpad/db/db
db_if::Init $dbpath

set datepattern "%Y%m%d"
set datestr [clock format [clock seconds] -format $datepattern] 

set dbfile $env(DISK2_DATA)/scratchpad/db/db_T_$datestr
gen_tables $dbfile T
set dbfile $env(DISK2_DATA)/scratchpad/db/db_V_$datestr
gen_tables $dbfile V

set datepattern "%Y-%m-%d"
set datestr [clock format [clock seconds] -format $datepattern]

gen_history_range close 1.00 1.00 $env(DISK2)/web_driver/common/history_range.cfg date 2017-01-01 $datestr $env(DISK2_DATA)/web_driver/common/stock_history.dat
gen_history_range volume 10000 10000 $env(DISK2)/web_driver/common/history_range.cfg date 2017-01-01 $datestr $env(DISK2_DATA)/web_driver/common/stock_history_vol.dat

db_if::Shutdown
