package require sha1

namespace eval db_if {

variable m_idx
variable m_dbptr
variable m_opendb

proc Init {dbpath} {
    variable m_idx
    variable m_dbptr
    variable m_opendb
	
    if {[info exists m_idx]} {
	    unset m_idx
	}
	array set m_idx {}
	set m_dbptr ""
	set m_opendb ""
	
	set yearlist [glob $dbpath/*]
	foreach yeardir $yearlist {
        set idx [string last "/" $yeardir]
        incr idx
        set year [string range $yeardir $idx end]
        foreach dbname [glob $yeardir/*] {
		    set hashname [sha1::sha1 $dbname]
			mk::file open tmpdb $dbname
			set infolist [mk::view layout tmpdb]
			foreach token $infolist {
			    set symbol [lindex $token 0]
				set m_idx($symbol,$year) "$dbname $hashname"
			}
			mk::file close tmpdb			
		}
	}
	return
}

# p_data is an array with index "date", "close" and "volume" and empty contents
# "date" is of the format YYYY-MM-DD
# symbol is <xxx>[.yy]
# year is YYYY
proc get_record {symbol year p_data} {
    variable m_idx
	variable m_dbptr
    variable m_opendb
	upvar $p_data data

    regsub -all {\.} $symbol "_" symbol_nodot
    if {![info exists m_idx($symbol_nodot,$year)]} {
    	reutrn "$symbol,$year not found in database!"
    }
	
	set tokens $m_idx($symbol_nodot,$year)
	set dbfile [lindex $tokens 0]
	set m_dbptr [lindex $tokens 1]
	set idx [lsearch $m_opendb $m_dbptr]
	if {$idx == -1} {
	    lappend m_opendb $m_dbptr
	    mk::file open $m_dbptr $dbfile
	}
    set view $m_dbptr.$symbol_nodot
	
	# Check table properties against pass in properties
	set properties [mk::view layout $view]
	foreach property [array names data] {
	    if {[lsearch $properties $property] == -1} {
		    set m_dbptr ""
		    return "$property not in database!"
        }
	}

	# Check row is present in table.
	set rownums [mk::select $view date $data(date)]
	if {$rownums == ""} {
	    set m_dbptr ""
	    return "Record with $data(date) does not exist for $symbol,$year"
	} elseif {[llength $rownums] > 1} {
	    set m_dbptr ""
	    return "More then one record with $data(date) exist for $symbol,$year"	
	}

	set row [lindex $rownums 0]
	foreach idx [array names data] {
	    set data($idx) [mk::get $view!$row $idx]
	}

    return ""
}

# p_data is an array with index "date", "close" and "volume"
# "date" is of the format YYYY-MM-DD
# symbol is <xxx>[.yy]
# year is YYYY
proc set_record {symbol year p_data} {
    variable m_idx
	variable m_dbptr
    variable m_opendb
	upvar $p_data data

    regsub -all {\.} $symbol "_" symbol_nodot
    if {![info exists m_idx($symbol_nodot,$year)]} {
    	return "$symbol,$year not found in database!"
    }
	
	set tokens $m_idx($symbol_nodot,$year)
	set dbfile [lindex $tokens 0]
	set m_dbptr [lindex $tokens 1]
	set idx [lsearch $m_opendb $m_dbptr]
	if {$idx == -1} {
	    lappend m_opendb $m_dbptr
	    mk::file open $m_dbptr $dbfile
	}
    set view $m_dbptr.$symbol_nodot
	
	# Check table properties against pass in properties
	set properties [mk::view layout $view]
	foreach property [array names data] {
	    if {[lsearch $properties $property] == -1} {
		    set m_dbptr ""
		    return "$property not in database!"
        }
	}

	# Check row is not already present in table.
	if {[mk::select $view date $data(date)] != ""} {
	    set m_dbptr ""
	    return "Record with $data(date) already exists for $symbol,$year"
	}
	set row [mk::row append $view]
	eval mk::set $row [array get data]
    mk::file commit $view

    return ""
}

proc Shutdown {} {
    variable m_opendb
	variable m_dbptr
	
	foreach dbhash $m_opendb {
	    set m_dbptr $dbhash
		mk::file close $m_dbptr
	}
    return
}

}