source stock.tcl
source qdo.tcl

proc pprint {data} {
    foreach token $data {
	puts $token
    }
}

proc checkit {dirname} {
    if {![file isdirectory $dirname]} {
		puts "invalid folder: $dirname"
		return
	}
    if {![file exists $dirname/query.txt]} {
		puts "query.txt not found"
		return
	}
    if {![file exists $dirname/criteria.txt]} {
		puts "criteria.txt"
	}	
}

proc runit {dirname} {
	checkit $dirname
    set symbols [stock::query_file $dirname/query.txt]
	foreach symbol $symbols {
		foreach token [stock::get_info $symbol $dirname/criteria.txt] {
			set criterion [lindex $token 0]
			set value [lindex $token 1]
			qdo::set_value $symbol $criterion $value
		}		
	}
}

stock::init {stock_T company_T dividend_T}
qdo::init