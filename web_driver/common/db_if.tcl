package require sha1

namespace eval db_if {

variable m_idx
variable m_dbptr
variable m_opendb
variable m_symbollist

proc Init {dbpath} {
    variable m_idx
    variable m_dbptr
    variable m_opendb
	variable m_symbollist
	
    if {[info exists m_idx]} {
	    unset m_idx
	}
	array set m_idx {}
	set m_dbptr ""
	set m_opendb ""
	
	set symbollist ""
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
				lappend symbollist $symbol
				set m_idx($symbol,$year) "$dbname $hashname"
			}
			mk::file close tmpdb			
		}
	}
	set m_symbollist [lsort -unique $symbollist]
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

# p_data is an array with index "date", "close" and "volume" and empty contents
# "date" is of the format YYYY-MM-DD
# symbol is <xxx>[.yy]
# year is YYYY
proc get_recordlist {symbol year collist colname min max p_rc} {
    variable m_idx
	variable m_dbptr
    variable m_opendb
	
    upvar $p_rc rc
	set rc ""

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
	if {[lsearch $properties $colname] == -1} {
		set m_dbptr ""
		return "$colname not in database!"
	}
	
	# Check table properties against pass in properties
	set properties [mk::view layout $view]
	foreach property $collist {
	    if {[lsearch $properties $property] == -1} {
		    set m_dbptr ""
		    return "$property not in database!"
        }
	}

	# Fetch records.
	set charnames ""
	foreach col $collist {
	    append charnames "$col "
	}
	set charnames [string range $charnames 0 end-1]
	foreach row [mk::select $view -min $colname $min -max $colname $max -sort $colname] {
	    set cmd "mk::get $view!$row "
		append cmd $charnames
	    lappend rc [eval $cmd]
	}
	
	if {$rc == ""} {
	    set m_dbptr ""
	    return "No records exist for $symbol,$year with characteristic $colname within $min and $max"
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

proc Get_Symbollist {} {
	variable m_symbollist

	return $m_symbollist
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