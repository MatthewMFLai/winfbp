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
 namespace eval FbpDraw {

    proc get_portid {blockname porttype portname} {
	variable m_portmap

	set rc ""
	set name [gen_portname $blockname $porttype $portname]
	if {[info exists m_portmap($name)]} {
	    set rc $m_portmap($name)
	} else {
	    puts "portid for $blockname:$porttype:$portname not found"
	}
	return $rc
    }

    proc get_portname {portid} {
	variable m_portmap

	foreach portname [array names m_portmap] {
	    if {$m_portmap($portname) == $portid} {
		return $portname
	    }
	}
	return "" 
    }

    proc box {c x y class {fill {light cyan}}} {
        variable m_a
    	variable m_portmap
        foreach {username name inports outports} $class break
	set id $name
        if {"$inports$outports"==""} {
	    error_dialog "All ports absent in $username!"
	}
        set id0 [$c create text $x $y -text $username -anchor nw\
                  -font $m_a(boldfont)]
        $c itemconfig $id0 -tag "$id BLOCK"
        set y1 [lindex [$c bbox $id] 3]
	set y1_tmp $y1
        if {$inports!=""} {
	    set x_max 0
	    foreach inport $inports {
                set id_inport [$c create text $x $y1 -text "$inport     "\
                  -anchor nw -font $m_a(font) -fill red\
		  -tag "$id [gen_portname $name INPORT $inport] PORT"]
		# Store id into portmap.
		set m_portmap([gen_portname $name INPORT $inport]) $id_inport
        	set y1 [lindex [$c bbox $id] 3]
		incr y1 5 
		set x_cur [lindex [$c bbox $id_inport] 2]
		if {$x_cur > $x_max} {
		    set x_max $x_cur 
		}
	    }
        }
        if {$inports!=""} {
            set x2 [expr $x_max + 5]
	    set y $y1_tmp
	} else {
	    set x_left [lindex [$c bbox $id] 0]
	    set x_right [lindex [$c bbox $id] 2]
	    set x2 [expr ($x_left + $x_right) / 2.0]
	    set y [lindex [$c bbox $id] 3]
	}
        if {$outports!=""} {
	    foreach outport $outports {
                set id_outport [$c create text $x2 $y -text $outport -anchor nw\
                    -font $m_a(font)\
		    -fill blue\
		    -justify right\
		    -tag "$id [gen_portname $name OUTPORT $outport] PORT"]
		# Store id into portmap.
		set m_portmap([gen_portname $name OUTPORT $outport]) $id_outport
        	set y [lindex [$c bbox $id_outport] 3]
		incr y 5 
	    }
        }
        foreach {x0 y0 x3 y3} [$c bbox $id] break
        set x0 [expr {$x0-2}]
        set x3 [expr {$x3+2}]
        if {$outports!=""} {set y3 [expr {$y3+2}]}
        set id2 [$c create rect $x0 $y0 $x3 $y3 -tag $id -fill $fill]
        $c lower $id2
        $c create line $x0 $y1_tmp $x3 $y1_tmp -tag $id
        foreach {x0 y0 x1 y1} [$c bbox $id] break
        $c move $id [expr {($x0-$x1)/2}] [expr {($y0-$y1)/2}]

        return $id
    }

    proc rawEdge {c from to controlpoints {dash ""}} {
        foreach {x0 y0 x2 y2} [$c bbox $from] break
        #set x1 [expr {($x0+$x2)/2.}]
        set x1 $x2 
        set y1 [expr {($y0+$y2)/2.}]
        if {$from==$to} {
            set x3 [expr {$x2+5}]
            set y4 [set y3 [expr {$y2+5}]]
            set x4 $x2
            $c create line $x2 $y1 $x3 $y1 $x3 $y3 $x1 $y3 $x1 $y2 \
                -tag edge -dash $dash
        } else {
            foreach {x3 y3 x5 y5} [$c bbox $to] break
            set x4 $x3
            set y4 [expr {($y3+$y5)/2.}]
	    set from_portid [get_portname $from]
	    set to_portid [get_portname $to]
	    if {$controlpoints == ""} {
            	set line_id [$c create line $x1 $y1 $x4 $y4 -tag \
	           "edge [gen_from_to $from_portid $to_portid]"\
	           -dash $dash]
	    } else {
		set points [concat [list $x1 $y1] $controlpoints [list $x4 $y4]]
                set line_id [$c create line $points -tag \
	           "edge [gen_from_to $from_portid $to_portid]"\
	           -dash $dash]
		foreach {x y} $controlpoints {
		    dot $c $x $y $line_id
		}
		set x1 [lindex $controlpoints end-1]
		set y1 [lindex $controlpoints end]
	    }
	    $c bind $line_id <ButtonPress-1> [list FbpDraw::zig %W %x %y]
        }
        return [decorationPoints $x1 $y1 $x4 $y4]
    }
    proc decorationPoints {x1 y1 x4 y4 {r 12}} {
        set a [expr {atan2($x4-$x1,$y4-$y1)}]
        set a1 [expr {$a-atan(1.)}]
        set x2 [expr {round($x4-cos($a1)*$r)}]
        set y2 [expr {round($y4+sin($a1)*$r)}]
        set a2 [expr {$a+atan(1.)}]
        set x3 [expr {round($x4+cos($a2)*$r)}]
        set y3 [expr {round($y4-sin($a2)*$r)}]
        set a3 [expr {$a+2*atan(1)}]
        set r2 [expr {$r*sqrt(2.)}]
        set x5 [expr {round($x4+cos($a3)*$r2)}]
        set y5 [expr {round($y4-sin($a3)*$r2)}]
        list $x2 $y2 $x4 $y4 $x3 $y3 $x5 $y5 ;# use 6 for a triangle
    }
    proc edge_delete {from_portname to_portname} {
        variable m_a
	variable m_portmap

	set from $m_portmap($from_portname)
	set to $m_portmap($to_portname)
        set edgelist $m_a(edges)
	set idx [lsearch $edgelist "* $from $to"]
	if {$idx != -1} {
	    set edgelist [lreplace $edgelist $idx $idx]
	    set m_a(edges) $edgelist
	}
	return
    }
    proc edge {c type from to {controlpoints ""}} {
        variable m_a
        ladd m_a(edges) [list $type $from $to]
        set deco [rawEdge $c $from $to $controlpoints ""]
        $c create line [lrange $deco 0 5] -tag "deco edge [gen_from_to \
	    [get_portname $from] [get_portname $to]]"
    }

    proc check_outport_conn {id} {
	variable m_a
	foreach conn $m_a(edges) {
	    if {$id == [lindex $conn 1]} {
		return 1 
	    }
	}
	return 0 
    }

    proc makeMovable_block {c tag} {
        foreach i [$c find all] {
            if {[lsearch [$c itemcget $i -tags] $tag] != -1} {
                $c addtag mv withtag $i
            }
        }
    }

proc delete_all {win} {
    variable m_portmap
    variable m_portqueue
    variable m_a

    unset m_portmap
    array set m_portmap {}
    unset m_portqueue
    array set m_portqueue {}
    block_clear
    $win delete all
    set m_a(edges) ""
    set m_a(INPORT) ""
    set m_a(OUTPORT) ""
    init_zig
    return
}

proc Graph_Set {data} {
    variable m_graph
    variable m_network

    set m_graph(graph_id) [lindex $data 0] 
    set m_graph(graph_passwd) [lindex $data 1]
    set m_network(first_port) [lindex $data 2] 
    return 
}

proc Gen_Graphfile_Name {} {
    variable m_tmpdir
    variable m_graph

    return "$m_tmpdir/$m_graph(graph_id)\.dat"
}

}

