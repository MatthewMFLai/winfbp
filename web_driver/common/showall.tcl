set curdir [pwd]
# Generate fresh data
source $curdir/gen_data.tcl
source $curdir/stock_cli.tcl

set genericdir $curdir/generic

set fd [open $curdir/sector_industry.txt r]
while {[gets $fd line] > -1} {
    if {$line == ""} {
	    continue
	}
    set sector [lindex [split $line ","] 0]
	regsub -all "/" $sector "-" sector
    set industry [lindex [split $line ","] 1]
	regsub -all "/" $industry "-" industry
	set fd2 [open $genericdir/query.txt w]
	puts $fd2 "sector [list $sector]"
	puts $fd2 "industry [list $industry]"
	close $fd2
	
	set outdir {C:/winfbp/scratchpad/db/out}
	if {![file exists $outdir/$sector]} {
	    file mkdir $outdir/$sector
	}
	set fd2 [open $outdir/$sector/$industry w]
	
	puts "processing $sector: $industry"
	runit $genericdir
	foreach token [qdo::get_criterion_data MarketCapitalization] {
	    set marketCap [lindex $token 1]
		if {![string is integer $marketCap]} {
		    continue
		}
		
		array set tmptable {}
	    set symbol [lindex $token 0]
        foreach keyvalue [stock::get_info $symbol $genericdir/criteria.txt] {
		    set key [lindex $keyvalue 0]
		    set value [lindex $keyvalue 1]
			set tmptable($key) $value
		}
		if {![info exists tmptable(description)]} {
		    unset tmptable
		    continue
		}
		set description $tmptable(description)
		unset tmptable(description)
		puts $fd2 $description
		foreach idx [array names tmptable] {
		   puts $fd2 "$idx $tmptable($idx)"
		}
		puts $fd2 ""
		unset tmptable
	}
	close $fd2
}