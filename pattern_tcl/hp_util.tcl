# Copyright (C) 2016 by Matthew Lai, email : mmlai@sympatico.ca
#
# The author  hereby grants permission to use,  copy, modify, distribute,
# and  license this  software  and its  documentation  for any  purpose,
# provided that  existing copyright notices  are retained in  all copies
# and that  this notice  is included verbatim  in any  distributions. No
# written agreement, license, or royalty  fee is required for any of the
# authorized uses.  Modifications to this software may be copyrighted by
# their authors and need not  follow the licensing terms described here,
# provided that the new terms are clearly indicated on the first page of
# each file where they apply.
#
# IN NO  EVENT SHALL THE AUTHOR  OR DISTRIBUTORS BE LIABLE  TO ANY PARTY
# FOR  DIRECT, INDIRECT, SPECIAL,  INCIDENTAL, OR  CONSEQUENTIAL DAMAGES
# ARISING OUT  OF THE  USE OF THIS  SOFTWARE, ITS DOCUMENTATION,  OR ANY
# DERIVATIVES  THEREOF, EVEN  IF THE  AUTHOR  HAVE BEEN  ADVISED OF  THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE  AUTHOR  AND DISTRIBUTORS  SPECIFICALLY  DISCLAIM ANY  WARRANTIES,
# INCLUDING,   BUT   NOT  LIMITED   TO,   THE   IMPLIED  WARRANTIES   OF
# MERCHANTABILITY,  FITNESS   FOR  A  PARTICULAR   PURPOSE,  AND
# NON-INFRINGEMENT.  THIS  SOFTWARE IS PROVIDED  ON AN "AS  IS" BASIS,
# AND  THE  AUTHOR  AND  DISTRIBUTORS  HAVE  NO  OBLIGATION  TO  PROVIDE
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
source $env(PATTERN_HOME)/time_util.tcl

namespace eval UtilHp {

variable m_db
variable m_view
variable m_plotfd
variable m_animate1
variable m_animate2

# Helper functions.
proc dot_to_dash {symbol} {
    regsub -all {\.} $symbol "_" symbol_new
    return $symbol_new
}

proc dash_to_dot {symbol} {
    regsub -all "_" $symbol {.} symbol_new
    return $symbol_new
}

proc get_all_symbols {year} {
    variable m_db

    if {![info exists m_db($year)]} {
    	return ""
    }
    set rc ""
    foreach symbol [mk::file views $m_db($year)] {
	if {[string first "AUX" $symbol] == 0} {
	    continue
	}
	lappend rc [dash_to_dot $symbol]
    }
    return $rc    
}

proc Init {dbfile animate1 animate2} {
    global tcl_platform
    variable m_db
    variable m_view
    variable m_plotfd
    variable m_filelist
    variable m_animate1
    variable m_animate2

    if {![file exists $animate1]} {
	puts "$animate1 does not exist!"
	return	
    }
    if {![file exists $animate2]} {
	puts "$animate2 does not exist!"
	return	
    }
    set m_animate1 $animate1
    set m_animate2 $animate2
    array set m_db {}
    
    if {![file isdir $dbfile]} {
	puts "$dbfile does not exist!"
	return	
    }
    # Find all the files with the format hp*_*.dat
    if {[catch {glob "$dbfile/hp*_*.dat"} rc]} {
	puts "No hp*_*.dat found in $dbfile"
	return
    }
    foreach filename $rc {
	set idx [string last "_" $filename]
	incr idx
	set idx2 [string first "." $filename $idx]
	incr idx2 -1
	set year [string range $filename $idx $idx2]
	set m_db($year) M$year 
    	mk::file open $m_db($year) $filename
    }

    array set m_view {}
    if {[string first "Windows" $tcl_platform(os)] > -1} {
    	set m_plotfd [open "|gnuplot" r+]
    } else {
	set m_plotfd ""
    }
    set m_filelist ""

    UtilTime::Init

    return
}

proc Close {} {
    global tcl_platform
    variable m_db
    variable m_view
    variable m_plotfd
    variable m_filelist

    foreach year [array names m_db] {
    	mk::file close $m_db($year)
    }
    if {[string first "Windows" $tcl_platform(os)] > -1} {
        close $m_plotfd
    }
    foreach filename $m_filelist {
	file delete -force $filename
    }
    unset m_view
    array set m_view {}
    return
}

proc ResetPlot {} {
    variable m_plotfd
    global tcl_platform

    if {[string first "Windows" $tcl_platform(os)] > -1} {
        catch {close $m_plotfd}
    	set m_plotfd [open "|gnuplot" r+]
    }
    return 
}

proc GetData {symbol datestr_from datestr_to p_close p_volume year} {
    variable m_db
    variable m_view
    upvar $p_close close 
    upvar $p_volume volume 

    if {![info exists m_db($year)]} {
	puts "$year not found in database."
	return 0
    } 
    set rc 1
    set symbol_nodot [dot_to_dash $symbol]
    # Check if view is present in database.
    if {[mk::view info $m_db($year).$symbol_nodot] == ""} {
	#puts "$symbol not found in database."
	return 0
    }

    if {![info exists m_view($symbol]} {
    	set m_view($symbol) [mk::view layout $m_db($year).$symbol_nodot "date close volume"]
    }
    set view $m_view($symbol)
    set mindate [clock scan $datestr_from]
    set maxdate [clock scan $datestr_to]
    set rownums [mk::select $view -min date $mindate -max date $maxdate]
    foreach i $rownums {
	set tokens [mk::get $view!$i date close volume]
	set close([lindex $tokens 0]) [lindex $tokens 1] 
	set volume([lindex $tokens 0]) [lindex $tokens 2] 
    }
    return $rc
}

proc fill_data {symbol from to p_close p_volume} {
    upvar $p_close close
    upvar $p_volume volume

    array set splityears {}
    UtilTime::Split_Years $from $to splityears

    foreach year [lsort [array names splityears]] {
    	set from_str [lindex $splityears($year) 0]
    	set to_str [lindex $splityears($year) 1]
	set datafound 0
    	if {![GetData $symbol $from_str $to_str close volume $year]} {
	    continue 
    	}
	set datafound 1
    }
    return $datafound
}

proc Levelize {p_data p_result {interval 0.10}} {
    upvar $p_data data
    upvar $p_result result

    set tmplist ""
    foreach idx [array names data] {
	lappend tmplist $data($idx)
    }
    set vallist [lsort -dictionary $tmplist]
    set min [lindex $vallist 0]
    set max [lindex $vallist end]
    set cur $min
    while {$cur < $max} {
	set result($cur) 0
	set cur [format "%.2f" [expr $cur + $interval]]	
    }
    set result($max) 0

    set levellist [lsort -dictionary [array names result]]
    foreach idx [array names data] {
	set val $data($idx)
	foreach level $levellist {
	    if {$val < $level} {
		incr result($level) 1
		break
	    }
	}
    }
    return
}

proc Levelize_File {filename level p_data} {
    upvar $p_data data

    set fd [open $filename w]

    array set result {}
    Levelize data result $level
    #puts $fd "level count"
    foreach idx [lsort -dictionary [array names result]] {
	puts $fd "$idx $result($idx)"
    }
    close $fd
    return
}

proc DeltaPV {p_close p_volume} {
    upvar $p_close close
    upvar $p_volume volume

    set rc ""
    set close_prev 0
    set volume_prev 0

    foreach idx [lsort [array names close]] {
	set close_cur $close($idx)
	set volume_cur $volume($idx)
	set close_d [expr $close_cur - $close_prev]
	set volume_d [expr $volume_cur - $volume_prev]
	set close_d [format "%.2f" $close_d]
	lappend rc "$close_d $volume_d"
	set close_prev $close_cur
	set volume_prev $volume_cur
    }
    return [lrange $rc 1 end] 
}

proc DeltaPV_File {filename p_close p_volume} {
    upvar $p_close close
    upvar $p_volume volume

    set fd [open $filename w]

    set rc [DeltaPV close volume]
    #puts $fd "idx delta_p delta_v"
    set idx 1
    foreach token $rc {
	puts $fd "$idx [lindex $token 0] [lindex $token 1]"
	incr idx
    }
    close $fd
    return
}

proc Plot_Level {symbol datestr_from datestr_to {level 0.10}} {
    variable m_filelist
    variable m_plotfd

    array set close {}
    array set volume {}
    if {![fill_data $symbol $datestr_from $datestr_to close volume]} { 
	return
    }

    set tmpdir [pwd]
    set filename $tmpdir/$symbol\_level.dat
    Levelize_File $filename $level close
    lappend m_filelist $filename
    puts $m_plotfd "plot \"$filename\" with boxes"
    flush $m_plotfd
    return
}

proc Plot_PV {symbol datestr_from datestr_to} {
    variable m_filelist
    variable m_plotfd

    array set close {}
    array set volume {}
    if {![fill_data $symbol $datestr_from $datestr_to close volume]} {
	return
    }
    set tmpdir [pwd]
    set filename $tmpdir/$symbol\_pv.dat
    DeltaPV_File $filename close volume
    lappend m_filelist $filename
    puts $m_plotfd "set zeroaxis; set zzeroaxis; set border 0;splot \"$filename\" with linespoints"
    flush $m_plotfd
    return
}

proc Plot_Multi {symbollist from to row column title} {
    variable m_plotfd

    set rc ""
    set newlist ""
    set line "set multiplot title \"$title\" layout $row,$column;"
    puts $m_plotfd $line
    flush $m_plotfd

    foreach symbol $symbollist {
    	array set close {}
    	array set volume {}
    	if {![fill_data $symbol $from $to close volume]} {
	    puts "No data for $symbol"
   	    continue
	}
	set fd [open dat/$symbol.dat w]
	lappend rc $symbol.dat 
	set cnt 1
	foreach idx [lsort [array names close]] {
	    puts $fd "$cnt $close($idx)"
	    incr cnt
    	}
	close $fd
	lappend newlist $symbol
	unset close
	unset volume

	set line "unset tics;"
	append line "plot \"dat/$symbol.dat\" title \"$symbol\" with lines;"
    	puts $m_plotfd $line
    	flush $m_plotfd
    }
    set line "unset multiplot"
    puts $m_plotfd $line
    flush $m_plotfd

    return $rc
}

proc Plot_Multi_Pdf {symbollist from to row column title filename} {
    variable m_plotfd

    if {[file exists $filename]} {
	file delete $filename
    }
    puts "Generate $filename ..."
    set rc ""
    set newlist ""

    set line "set term push;"
    append line "set term pdf size 19,13;"
    append line "set output \"$filename\";"
    append line "set multiplot title \"$title\" layout $row,$column;"
    puts $m_plotfd $line
    flush $m_plotfd

    foreach symbol $symbollist {
    	array set close {}
    	array set volume {}
    	if {![fill_data $symbol $from $to close volume]} {
	    puts "No data for $symbol"
	    unset close
	    unset volume
   	    continue
	}
	set fd [open dat/$symbol.dat w]
	lappend rc $symbol.dat 
	set cnt 1
	foreach idx [lsort [array names close]] {
	    puts $fd "$cnt $close($idx)"
	    incr cnt
    	}
	close $fd
	lappend newlist $symbol
	unset close
	unset volume

	set line "unset tics;"
	append line "plot \"dat/$symbol.dat\" title \"$symbol\" with lines;"
    	puts $m_plotfd $line
    	flush $m_plotfd
    }
    set line "unset multiplot;"
    append line "set terminal pop"
    puts $m_plotfd $line
    flush $m_plotfd

    puts "Finish $filename"
    return $rc
}

proc Plot_Histo_Pdf {symbollist from to row column title filename} {
    variable m_plotfd

    if {[file exists $filename]} {
	file delete $filename
    }
    puts "Generate $filename ..."
    set rc ""
    set newlist ""

    set line "set term push;"
    append line "set term pdf size 19,13;"
    append line "set output \"$filename\";"
    append line "set multiplot title \"$title\" layout $row,$column;"
    puts $m_plotfd $line
    flush $m_plotfd

    foreach symbol $symbollist {
    	array set close {}
    	array set volume {}
    	if {![fill_data $symbol $from $to close volume]} {
	    puts "No data for $symbol"
	    unset close
	    unset volume
   	    continue
	}
	if {[llength [array names close]] <= 20} {
	    puts "Not enought data points for $symbol"
	    unset close
	    unset volume
   	    continue
	}
	set fd [open dat/$symbol.dat w]
	lappend rc $symbol.dat 
	set cnt 1
	foreach token [Gen_Histo_Data close] {
	    puts $fd "$cnt [lindex $token 0]"
	    incr cnt
    	}
	close $fd
	lappend newlist $symbol
	unset close
	unset volume

	set line "unset tics;"
	append line "set yrange \[0.00:100.00\];"
	append line "plot \"dat/$symbol.dat\" title \"$symbol\" with lines;"
	#append line "set style histogram rowstacked gap 0;"
	#append line "set style data histogram;"
	##append line "set style fill solid 1.0 border -1;"
	#append line "plot \"dat/$symbol.dat\" title \"$symbol\" using 2 notitle lt 2, \'\' using 3 notitle lt 1;"
    	puts $m_plotfd $line
    	flush $m_plotfd
    }
    set line "unset multiplot;"
    append line "set terminal pop"
    puts $m_plotfd $line
    flush $m_plotfd

    puts "Finish $filename"
    return $rc
}

proc wait_gif_ready {dirname symbol} {
    # Make sure the gif file for current symbol is generated 
    # before moving to the next symbol.
    set loop 1
    set cnt 0
    while {$loop && $cnt < 100} {
	if {[file exists $dirname/$symbol\.gif]} {
	    break
	}
	after 600
	incr cnt
    }
    if {$cnt == 100} {
	puts "wait_gif_ready ERR: $symbol"
	return 0
    }
    set size_prev 0
    set cnt 0
    while {$loop && $cnt < 100} {
	set size_cur [file size $dirname/$symbol.gif]
	if {$size_cur == $size_prev &&
	    $size_cur != 0} {
	    break 
	}
	after 100
	incr cnt
	set size_prev $size_cur
    }
    if {$cnt == 100} {
	puts "wait_gif_ready ERR2: $symbol"
	return 0
    }
    return 1
}

proc Plot_Gif_Imp {symbol from to dirname} {
    variable m_plotfd

    set rc 0
    array set close {}
    array set volume {}
    if {![fill_data $symbol $from $to close volume]} {
    	#puts "No data for $symbol"
    	return $rc  
    }
    if {[array names close] == ""} {
    	puts "No data points for $symbol"
    	return $rc  
    }
    set rc 1 
    puts "Generate $symbol gif file..."
    set fd [open dat/$symbol.dat w]
    set cnt 1
    foreach idx [lsort [array names close]] {
    	puts $fd "$cnt $close($idx) $volume($idx)"
    	incr cnt
    }
    close $fd
    unset close
    unset volume

    set line "unset tics;"
    append line "set term push;"
    append line "set term gif tiny size 160,120 crop;"
    append line "set output \"$dirname/$symbol.gif\";"
    append line "set label \"$symbol\" at graph 0.5, 0.9;"
    append line "set multiplot;"
    append line "set size 1, 0.7;"
    append line "set origin 0, 0.3;"
    append line "set bmargin 0;"

    append line "plot \"dat/$symbol.dat\" using 1:2 notitle with lines;"

    append line "set bmargin;"
    append line "set format x;"
    append line "set size 1.0, 0.3;"
    append line "set origin 0.0, 0.0;"
    append line "set tmargin 0;"
    append line "set autoscale y;"
    append line "set format y \"%1.0f\";"
    append line "unset label;"

    append line "plot \"dat/$symbol.dat\" using 1:3 notitle with impulses lt 3;" 
    append line "unset multiplot;"
    append line "set term pop;"
    puts $m_plotfd $line
    flush $m_plotfd
    if {![wait_gif_ready $dirname $symbol]} {
	set rc -1
    }
    file delete dat/$symbol.dat
    return $rc 
}

proc Plot_Gif {symbollist from to dirname} {
    foreach symbol $symbollist {
    	set rc [Plot_Gif_Imp $symbol $from $to $dirname]
    	if {$rc == -1} {
	    puts "Reset gnu plot..."
	    ResetPlot 
    	    set rc [Plot_Gif_Imp $symbol $from $to $dirname]
    	}
    }
    return "" 
}

proc percent_change {cur ref} {
    #return [expr 1.00*($cur - $ref)/$ref]
    return [expr 1.00*$cur/$ref]
} 

proc gen_cluster_data {symbollist from to filename} {
    array set result {}
    array set ref_close {}
    array set ref_volume {}
    set newlist ""
    set allidxlist ""

    foreach symbol $symbollist {
    	array set close {}
    	array set volume {}
    	if {![fill_data $symbol $from $to close volume]} {
	    puts "No data for $symbol"
	    unset close
	    unset volume
   	    continue
	}
	puts "$symbol [llength [array names close]]" 
	if {[llength [array names close]] == 0} {
	    puts "No valid data for $symbol"
	    unset close
	    unset volume
   	    continue
	}
	# Ignore symbol that has price 0.0
	set idxlist [lsort [array names close]]
	set idx0 [lindex $idxlist 0]
	if {$close($idx0) == "0.0" ||
	    $close($idx0) == "0.00"} {
	    puts "Close price 0.0 for $symbol"
	    unset close
	    unset volume
   	    continue
	}

	lappend newlist $symbol

	foreach idx $idxlist {
	    if {$volume($idx) == 0} {
	    	set volume($idx) 100 
	    }
	    set result($symbol,$idx) "$volume($idx) $close($idx)"
    	}
	# Set the reference volume and price.
	set ref_close($symbol) $close($idx0) 
	set ref_volume($symbol) $volume($idx0)

	unset close
	unset volume
	set allidxlist [lsort -unique [concat $allidxlist $idxlist]]
    }

    set cnt 1
    set idxlast [lindex $allidxlist end]
    set fd [open $filename w]
    foreach idx $allidxlist {
	if {[UtilTime::Is_Holiday $idx]} {
	    continue
	}
	foreach symbol $newlist {
	    if {![info exists result($symbol,$idx)]} {
		continue
	    }
	    set close [lindex $result($symbol,$idx) 1]
	    set volume [lindex $result($symbol,$idx) 0]
	    puts $fd "[percent_change $volume $ref_volume($symbol)] [percent_change $close $ref_close($symbol)]"
	}
	if {$idx != $idxlast} {
	    #puts $fd "$cnt---- [clock format $idx -format "%Y-%m-%d"]"
	    puts $fd ""
	    incr cnt
	}
    }
    close $fd
    unset result
    return [llength $allidxlist]
}

proc Plot_Cluster {symbollist from to filename printdir} {
    variable m_plotfd
    variable m_animate1
    variable m_animate2

    set frames [gen_cluster_data $symbollist $from $to $printdir/$filename\.dat]
    if {$frames == 0} {
	return
    }
    puts "Generating $filename\.gif"
    set fd [open $m_animate1 r]
    set data [read $fd]
    close $fd
    regsub -all "XXX" $data $filename data
    regsub -all "YYY" $data $frames data
    regsub -all "ZZZ" $data $printdir data
    set fd [open $printdir/animate.dem w]
    puts $fd $data
    close $fd

    set fd [open $m_animate2 r]
    set data [read $fd]
    close $fd
    regsub "XXX" $data $printdir/$filename data
    set fd [open $printdir/animate.gnuplot w]
    puts $fd $data
    close $fd

    puts $m_plotfd "load \"$printdir/animate.dem\";set output"
    flush $m_plotfd
    after 500
    set oldsize 0
    while {1} {
	if {![file exists $printdir/$filename\.gif]} {
	    continue
	}
	set newsize [file size $printdir/$filename\.gif]
	if {$oldsize == $newsize &&
	    $newsize > 0} {
	    break
	}
	set oldsize $newsize
	puts "size = $oldsize"
        after 500
    }
    file delete $printdir/animate.gnuplot
    file delete $printdir/aniamte.dem
    file delete $printdir/$filename\.dat
    #file rename -force $printdir\_$filename\.gif $printdir
    puts "Finish generating $filename\.gif"
    return    
}

proc Gen_Histo_Data {p_close} {
    upvar $p_close close

    set rc ""
    set idxlist [lsort [array names close]]
    set len [llength $idxlist]
    foreach idx $idxlist {
        set count 0
	set value $close($idx)
	foreach i $idxlist {
	    if {$i == $idx} {
		break
	    }
	    if {$close($i) < $value} {
		incr count
	    }
	}
	foreach i $idxlist {
	    if {$i <=  $idx} {
		continue	
	    }
	    if {$close($i) > $value} {
		incr count
	    }
	}
     	set x [format "%.2f" [expr $count * 100.00 / [expr $len - 1]]]
    	set y [format "%.2f" [expr 100.00 - $x]]
	lappend rc "$x $y"
    }
    return $rc 
}

}
global tcl_platform
if {[string first "Windows" $tcl_platform(os)] > -1} {
    package require Mk4tcl
} else {
    load Mk4tcl.so
}

