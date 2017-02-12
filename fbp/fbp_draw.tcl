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
proc defaultfont {} {
    set f [[button ._] cget -font]
    destroy ._
    set f
 }
 proc ladd {_list what} {
    upvar $_list list
    if {![info exists list] || [lsearch $list $what] == -1} {
        lappend list $what
    }
 }

proc gen_portname {blockname porttype portname} {
    set rc $blockname:$porttype:$portname
    return $rc
}

proc inv_gen_portname {name p_blockname p_porttype p_portname} {
    upvar $p_blockname blockname
    upvar $p_porttype porttype
    upvar $p_portname portname
    foreach {blockname porttype portname} [split $name ":"] break
    return
}

proc is_portname {name} {
    return [string match "*:*:*" $name]
}

proc is_porttype {name porttype} {
    set block ""
    set type ""
    set portname ""
    inv_gen_portname $name block type portname
    if {$type == $porttype} {
	return 1
    } else {
	return 0
    }
}

proc gen_from_to {from to} {
    return "$from\%$to"
}

proc inv_gen_from_to {from_to p_from p_to} {
    upvar $p_from from
    upvar $p_to to

    foreach {from to} [split $from_to "%"] break
    return
}

proc is_from_to {from_to} {
    if {[string match "*%*" $from_to]} {
	return 1
    } else {
	return 0
    }
}

proc find_links {win systemid} {
    set rc ""
    foreach id [$win find withtag edge] {
	foreach tag [$win itemcget $id -tags] {
	    if {[is_from_to $tag] == 0} {
		continue
	    }
	    inv_gen_from_to $tag from to
	    if {[string first $systemid $from] > -1 ||
		[string first $systemid $to] > -1} {
		lappend rc $id
		break	
	    }
	}
    }
    return $rc
}

 namespace eval FbpDraw {
    variable m_a
    variable m_portmap
    variable m_portqueue
    variable m_canvParser
    variable m_block
    # m_block looks like this
    # m_block(<systemid>,filename) = mux_out
    # m_block(<systemid>,filepath) = $DISK2/component/...
    # m_block(<systemid>,init) = {T {A B C}}
    # m_block(<systemid>,kicker) = red-ball 
    # m_block(<systemid>,inports) = {0 1 2}
    # m_block(<systemid>,outports) = {0 1 2 3 4}

    #set m_a(font)     [defaultfont]
    #set m_a(boldfont) [concat $m_a(font) bold]
    #  the following two are suggestions as more platform independent
    set m_a(font)     [eval font create fontNormal [font actual [defaultfont]]]
    set m_a(boldfont) [eval font create fontBold   [font actual [defaultfont]]\
                            -weight bold]
    set m_a(edges) ""
    array set m_portmap {}
    array set m_portqueue {}
    set ::FbpDraw::m_a(INPORT) "" 
    set ::FbpDraw::m_a(OUTPORT) "" 
    set m_canvParser [interp create -safe]
    array set m_block {}

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

    proc get_systemid_from_id {win id} {
	set taglist [$win itemcget $id -tags]
	set idx [lsearch $taglist "system*"]
	if {$idx != -1} {
	    return [lindex $taglist $idx]
	} else {
	    return ""
	}
    }

    proc box {c x y class {fill white}} {
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
                set id_inport [$c create text $x $y1 -text $inport\
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

    proc rawEdge {c from to {dash ""}} {
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
	    if {$x1 < $x4} {
            	$c create line $x1 $y1 $x4 $y4 -tag \
	           "edge [gen_from_to $from_portid $to_portid]"\
	           -dash $dash
	    } else {
		set x2 [expr $x1 + 5]
		set x3 [expr $x4 - 5]
		if {$y1 < $y4} {
		    set y2 [expr $y4 + 5]
		} else {
		    set y2 [expr $y1 + 5]
		}
                $c create line $x1 $y1 $x2 $y1 $x2 \
		   $y2 $x3 $y2 $x3 $y4 $x4 $y4 -tag \
	           "edge [gen_from_to $from_portid $to_portid]"\
	           -dash $dash
		set x1 $x3
		set y1 $y4
	    }
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
    proc edge {c type from to} {
        variable m_a
        ladd m_a(edges) [list $type $from $to]
        set deco [rawEdge $c $from $to ""]
        $c create line [lrange $deco 0 5] -tag "edge [gen_from_to \
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

    proc makeMovable c {
        variable m_a
        foreach i [$c find all] {
            if [regexp {system} [$c itemcget $i -tags]] {
                $c addtag mv withtag $i
            }
        }
	$c bind edge <1> {
            foreach i [%W itemcget current -tags] {
                if {[is_from_to $i] == 0} {
		    continue
		}
		inv_gen_from_to $i from to
		::FbpDraw::edge_delete $from $to
	    	%W delete withtag $i
	        break	
            }
	}
        $c bind mv <1> {
            set tag ""
            foreach i [%W itemcget current -tags] {
                if [regexp system $i] {set tag $i; break}
            }
            if {$tag!=""} {
                set ::FbpDraw::m_a(tag) $tag
                set ::FbpDraw::m_a(x) [%W canvasx %X]
                set ::FbpDraw::m_a(y) [%W canvasx %Y]
            }
        }
        $c bind mv <B1-Motion> {
            set x [%W canvasx %X]
            set y [%W canvasx %Y]
            %W move $::FbpDraw::m_a(tag) \
                [expr {$x-$::FbpDraw::m_a(x)}] [expr {$y-$::FbpDraw::m_a(y)}]
            set ::FbpDraw::m_a(x) $x
            set ::FbpDraw::m_a(y) $y

	    set id [%W find withtag current]
	    set systemid [FbpDraw::get_systemid_from_id %W $id]
	    foreach id [find_links %W $systemid] {
		%W delete $id
	    }
 
          if {[array names ::FbpDraw::m_a -exact edges] != ""} {
            foreach i $::FbpDraw::m_a(edges) {
	      set from_id [lindex $i 1]
	      set to_id [lindex $i 2]
	      if {[string first $systemid [FbpDraw::get_portname $from_id]] > -1 ||
		  [string first $systemid [FbpDraw::get_portname $to_id]] > -1} {
                  eval FbpDraw::edge %W $i
	      }
            }
          }
	  # Recompute the scroll region.
	  %W configure -scrollregion [%W bbox all] \
              -xscrollincrement 0.1i -yscrollincrement 0.1i 
        }
        $c bind mv <B1-ButtonRelease> {
	  set id [%W find withtag current]
	  set systemid [FbpDraw::get_systemid_from_id %W $id]
	  foreach id [find_links %W $systemid] {
	    %W delete $id
	  }
          if {[array names ::FbpDraw::m_a -exact edges] != ""} {
            foreach i $::FbpDraw::m_a(edges) {
	      set from_id [lindex $i 1]
	      set to_id [lindex $i 2]
	      if {[string first $systemid [FbpDraw::get_portname $from_id]] > -1 ||
		  [string first $systemid [FbpDraw::get_portname $to_id]] > -1} {
                  eval FbpDraw::edge %W $i
	      }
            }
          }
	  # Recompute the scroll region.
	  %W configure -scrollregion [%W bbox all] \
              -xscrollincrement 0.1i -yscrollincrement 0.1i 
        }
        $c bind PORT <3> {
            foreach tagname [%W itemcget current -tags] {
		if {![is_portname $tagname]} {
		    continue
		}
		if {[is_porttype $tagname INPORT]} {
		    if {$::FbpDraw::m_a(INPORT) != ""} {
			inv_gen_portname $::FbpDraw::m_a(INPORT) \
			    block type name
		        %W itemconfig [FbpDraw::get_portid $block $type $name]\
		          -fill red 
		    }
            	    set ::FbpDraw::m_a(INPORT) $tagname
		    inv_gen_portname $tagname block type name
		    %W itemconfig [FbpDraw::get_portid $block $type $name]\
		      -fill black
	        } elseif {[is_porttype $tagname OUTPORT]} {
		    # Quick check to verify outport does not have existing
		    # connection.
		    inv_gen_portname $tagname block type name
		    if {[::FbpDraw::check_outport_conn \
			[FbpDraw::get_portid $block $type $name]]} {
			break
		    }
		    if {$::FbpDraw::m_a(OUTPORT) != ""} {
			inv_gen_portname $::FbpDraw::m_a(OUTPORT) \
			    block type name
		        %W itemconfig [FbpDraw::get_portid $block $type $name]\
		          -fill blue 
		    }
            	    set ::FbpDraw::m_a(OUTPORT) $tagname
		    inv_gen_portname $tagname block type name
		    %W itemconfig [FbpDraw::get_portid $block $type $name]\
		      -fill black
		} else {
		    break
		}

		if {$::FbpDraw::m_a(INPORT) != "" &&
		    $::FbpDraw::m_a(OUTPORT) != ""} {
		    inv_gen_portname $::FbpDraw::m_a(OUTPORT) block1 type1 name1
		    inv_gen_portname $::FbpDraw::m_a(INPORT) block2 type2 name2
              	    eval FbpDraw::edge %W depend \
		         [FbpDraw::get_portid $block1 $type1 $name1] \
			 [FbpDraw::get_portid $block2 $type2 $name2] 
		    set ::FbpDraw::m_a(INPORT) "" 
		    set ::FbpDraw::m_a(OUTPORT) ""
		    %W itemconfig [FbpDraw::get_portid $block1 $type1 $name1]\
		      -fill blue 
		    %W itemconfig [FbpDraw::get_portid $block2 $type2 $name2]\
		      -fill red 
		    break
		}
	    }
        }
        $c bind PORT <Shift-3> {
            foreach tagname [%W itemcget current -tags] {
		if {![is_portname $tagname]} {
		    continue
		}
		if {[is_porttype $tagname OUTPORT]} {
		    return 
		}
		if {[is_porttype $tagname INPORT]} {
		    inv_gen_portname $tagname block type name
	    	    array set data {}
		    if {[info exists FbpDraw::m_portqueue($tagname)]} {
	    	    	set data(f1) $FbpDraw::m_portqueue($tagname)
		    } else {
			set data(f1) ""
		    } 
	    	    set data(f1_desc) "Queue length:" 
	    	    custom_dialog "Inport Queue" "f1" 5 data
		    if {$data(f1) != ""} {
			set FbpDraw::m_portqueue([gen_portname $block INPORT $name])\
                            $data(f1)
		    }
		    break
		}
	    }
	}
        $c bind BLOCK <Shift-3> {
	    # Must store the id value before launching the dialog.
	    # The dialog will most likely change the current id
            # as the user needs to move the cursor to the dialog box!
	    set id [%W find withtag current]
	    set systemid [FbpDraw::get_systemid_from_id %W $id]
	    if {$systemid == ""} {
	    	error_dialog "Cannot find systemid!"
		return
	    }
	    FbpDraw::block_get $systemid aa bb init kicker dd ee
	    array set data {}
	    set data(f1) [%W itemcget $id -text]
	    set data(f1_desc) "Name:" 
	    set data(f2) $init
	    set data(f2_desc) "Init:" 
	    set data(f3) $kicker
	    set data(f3_desc) "Kicker:" 
	    custom_dialog "Component customization" "f1 f2 f3" 40 data 
	    if {$data(f1) != ""} {
		%W itemconfig $id -text $data(f1)
		FbpDraw::block_set $systemid $data(f2) $data(f3)
		return
	    }
	}
	$c bind BLOCK <Control-3> {
	    set id [%W find withtag current]
	    set systemid [FbpDraw::get_systemid_from_id %W $id]
	    # Delete the GUI elements first.
	    foreach id [%W find withtag $systemid] {
		%W delete $id
	    }
	    foreach id [find_links %W $systemid] {
		%W delete $id
	    }
	    # Remove the data from namespace variables.
	    FbpDraw::delete_block $systemid

	    # Recompute the scroll region.
	    %W configure -scrollregion [%W bbox all] \
                -xscrollincrement 0.1i -yscrollincrement 0.1i 
	}
    }

proc get_blockname_map {c blocktag p_systemid_blockname_map} {
    upvar $p_systemid_blockname_map blockname_map
    foreach id [$c find all] {
	set taglist [$c itemcget $id -tags]
        if {[lsearch $taglist $blocktag] == -1} {
	    continue 
        }
	set idx [lsearch $taglist "system*"]
	set blockname_map([lindex $taglist $idx]) \
	  [$c itemcget $id -text]
    }
}

proc block_clear {} {
    variable m_block

    unset m_block
    array set m_block {}
    return
}

proc block_check {systemid} {
    variable m_block

    if {[info exists m_block($systemid,filename)]} {
	return 1
    } else {
    	return 0
    }
}

proc block_add {systemid filename filepath init kicker inports outports} {
    variable m_block

    if {[block_check $systemid]} {
	return
    }
    set m_block($systemid,filename) $filename
    set m_block($systemid,filepath) $filepath
    set m_block($systemid,init) $init
    set m_block($systemid,kicker) $kicker
    set m_block($systemid,inports) $inports
    set m_block($systemid,outports) $outports
    return
}

proc block_get {systemid p_filename p_filepath p_init p_kicker p_inports p_outports} {
    variable m_block

    upvar $p_filename filename
    upvar $p_filepath filepath
    upvar $p_init init 
    upvar $p_kicker kicker 
    upvar $p_inports inports 
    upvar $p_outports outports 
    if {![block_check $systemid]} {
    	set filename ""
	set filepath ""
    	set init ""
    	set kicker ""
    	set inports "" 
    	set outports ""
	return
    }
    set filename $m_block($systemid,filename)
    set filepath $m_block($systemid,filepath)
    set init $m_block($systemid,init)
    set kicker $m_block($systemid,kicker)
    set inports $m_block($systemid,inports)
    set outports $m_block($systemid,outports)
    return
}

proc block_set {systemid init kicker} {
    variable m_block

    if {![block_check $systemid]} {
	return
    }
    set m_block($systemid,init) $init
    set m_block($systemid,kicker) $kicker
    return
}

proc block_dump {} {
    variable m_block
	
    foreach idx [lsort [array names m_block]] {
	puts "$idx $m_block($idx)"
    }
    return
}

proc get_systemid {win} {
    set systemids ""
    foreach id [$win find all] {
   	set taglist [$win itemcget $id -tags]
	if {[lsearch $taglist "BLOCK"] == -1} {
	    continue
	}
	set idx [lsearch $taglist "system*"]
	if {$idx == -1} {
	    continue
	}
	lappend systemids [lindex $taglist $idx]
    }
    return $systemids
}

proc gen_systemid {idlist} {
    set toloop 1
    # Set the seed for rand() function
    expr (srand([clock seconds]))
    while {$toloop} {
	set id system[expr round(rand() * 10000)]
	if {[lsearch $idlist $id] == -1} {
	    break
	}
    }
    return $id
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
    return
}

proc delete_block {systemid} {
    variable m_a
    variable m_block
    variable m_portmap

    # Need to update the edges data first since
    # get_portname() depends on m_portmap and
    # if we modify m_portmap first we get incorrect
    # results with the edge data removal!
    if {[array names m_a -exact edges] != ""} {
        set linklist "" 
        foreach i $m_a(edges) {
	    set from_id [lindex $i 1]
	    set to_id [lindex $i 2]
	    if {[string first $systemid [get_portname $from_id]] == -1 && 
	        [string first $systemid [get_portname $to_id]] == -1} {
	        lappend linklist $i
	    }
        }
	set m_a(edges) $linklist
    }

    foreach idx [array names m_block] {
	if {[string first $systemid $idx] > -1} {
	    unset m_block($idx)
	}
    }

    foreach idx [array names m_portmap] {
	inv_gen_portname $idx blockname porttype portname
	if {$systemid == $blockname} {
	    unset m_portmap($idx)
	}
    }

    foreach idx [array names m_portqueue] {
	inv_gen_portname $idx blockname porttype portname
	if {$systemid == $blockname} {
	    unset m_portqueue($idx)
	}
    }

    return
}

proc populate_portmap {win} {
    variable m_portmap

    unset m_portmap
    array set m_portmap {}

    # To populate m_portmap()
    foreach id [$win find all] {
   	set taglist [$win itemcget $id -tags]
	if {[lsearch $taglist "PORT"] > -1} {
	    foreach tagname $taglist {
		if {[is_portname $tagname]} {
		    set name $tagname
		    break
		}
	    }
	    set m_portmap($name) $id
	}
    }
    return
}

proc populate_edges {win} {
    variable m_a
    variable m_portmap

    set m_a(edges) ""
    set m_a(INPORT) ""
    set m_a(OUTPORT) ""

    # To populate m_a(edges)
    foreach id [$win find all] {
   	set taglist [$win itemcget $id -tags]
	if {[lsearch $taglist "edge"] > -1} {
	    foreach tagname $taglist {
		if {[is_from_to $tagname]} {
		    inv_gen_from_to $tagname from to
		    ladd m_a(edges) [list depend $m_portmap($from) \
		                     $m_portmap($to)]
		    break
		}
	    }
	}
    }
    return
}
# ----------------------------------------------------------------------
# USAGE: canvas_save <canvas>
#
# Scans through the given <canvas> and produces a script that
# captures its contents.  Any items tagged with the name
# "canvas_save_ignore" are not returned in the script.  The
# script may be saved in a file, then later loaded and given
# to canvas_load to reproduce the original canvas.
# ----------------------------------------------------------------------
proc canvas_save {win} {
    set script "# contents of $win\n"
    foreach item [$win find all] {
        set tags [$win gettags $item]
        if {[lsearch $tags "canvas_save_ignore"] < 0} {
            set type   [$win type $item]
            set coords [$win coords $item]

            set opts ""
            foreach desc [$win itemconfigure $item] {
                set name [lindex $desc 0]
                set init [lindex $desc 3]
                set val  [lindex $desc 4]
                if {$val != $init} {
                    lappend opts $name $val
                }
            }
            append script "draw $type $coords $opts\n"
        }
    }
    return $script
}

# ----------------------------------------------------------------------
# USAGE: canvas_load <canvas> <script>
#
# Used to load a drawing produced by canvas_save.  The <script>
# string may contain commands like "draw rectangle ...", and the
# items will be created on the <canvas>.  If <script> contains
# anything unsafe like "exec rm *", it is flagged as an error.
# ----------------------------------------------------------------------
#set canvParser [interp create -safe]

proc canvas_load {win script} {
    variable m_canvParser

    $win delete all
    $m_canvParser alias draw FbpDraw::canvas_parser_cmd $win
    $m_canvParser eval $script
    #regsub -all "draw" $script "\$win create " script
    #eval $script
}
proc canvas_parser_cmd {win args} {
    eval $win create $args
}
# ----------------------------------------------------------------------
# USAGE: draw_open
#
# Prompts the user for a drawing file, then reads the file and
# attempts to load it into the drawing canvas.  If anything goes
# wrong, a notice dialog reports the error.
# ----------------------------------------------------------------------
proc draw_open {c} {
    global env
    variable m_block
    variable m_portqueue

    unset m_block
    array set m_block {}
    unset m_portqueue
    array set m_portqueue {}
    set file [tk_getOpenFile]
    if {$file != ""} {
        set cmd {
            set fid [open $file r]
            set script [read $fid]
            close $fid
            canvas_load $c $script

	    # Load the m_block data and m_portqueue data.
	    set fid [open $file r]
	    while {[gets $fid line] > -1} {
		if {[string first "array set" $line] == 0} {
		    eval $line
		}
	    }
	    close $fid
        }
        if {[catch $cmd err] != 0} {
            puts "Cannot open drawing:\n$err"
	    return
        }
        #draw_fix_menus
	populate_portmap $c
	populate_edges $c

	# Recompute the scroll region.
	$c configure -scrollregion [$c bbox all] \
            -xscrollincrement 0.1i -yscrollincrement 0.1i 
    }
}

# ----------------------------------------------------------------------
# USAGE: draw_save
#
# Prompts the user for a drawing file, then gets the contents of
# the drawing canvas and attempts to save it into the file.  If
# anything goes wrong, a notice dialog reports the error.
# ----------------------------------------------------------------------
proc draw_save {c} {
    global env
    variable m_block
    variable m_portqueue

    set file [tk_getSaveFile]
    if {$file != ""} {
        $c addtag "canvas_save_ignore" withtag "marker"
        set selected [$c find withtag "selected"]
        $c dtag "selected"

        set cmd {
            set fid [open $file w]
            puts $fid [canvas_save $c]
	    set line "array set m_block \"[array get m_block]\""
	    regsub -all {\$} $line "\\\$" line
	    puts $fid $line 
	    if {[array get m_portqueue] != ""} {
	        set line "array set m_portqueue \"[array get m_portqueue]\""
	    	puts $fid $line
	    }
            close $fid
        }
        if {[catch $cmd err] != 0} {
            puts "Cannot save drawing:\n$err"
        }

        $c dtag "canvas_save_ignore"
        foreach item $selected {
            $c addtag "selected" withtag $item
        }
    }
}

proc load_block {c} {
    global env

    set file [tk_getOpenFile]
    if {$file == ""} {
	return
    }
    set name "" 
    set filepath ""
    set init ""
    set kicker ""
    set inports ""
    set outports ""

    set fd [open $file r]
    while {[gets $fd line] > -1} {
	set key [lindex $line 0]
	set value [lindex $line 1]
	switch -- $key \
	    name {
	    set filename $value
	}    filepath {
	    set filepath $value
	}   init {
	    set init $value
	} kicker {
	    set kicker $value
	} inports {
	    set inports $value
	} outports {
	    set outports $value
	} default {
	    puts "unsupported key: $key"
	} 
    }
    # Extract block name from selected filename.
    set displayname [lindex [split $file "/"] end]
    set displayname [lindex [split $filename "."] 0]

    set id [gen_systemid [get_systemid $c]]
    block_add $id $filename $filepath $init $kicker $inports $outports

    box $c  50  50 [list $displayname $id $inports $outports]
    makeMovable_block $c $id

    # Recompute the scroll region.
    $c configure -scrollregion [$c bbox all] \
       -xscrollincrement 0.1i -yscrollincrement 0.1i 
}

proc gen_block_file {filename p_blockname_map} {
    variable m_block
    variable m_portqueue
    upvar $p_blockname_map blockname_map

    set fd [open $filename w]
    foreach systemid [array names blockname_map] {
	set displayname $blockname_map($systemid)
	block_get $systemid filename filepath init kicker inports outports
	set line "Block "
	append line "$displayname "
	append line $filepath/$filename\.tcl
	if {$init != "" || $kicker != ""} {
	    append line " "
	    append line "\{$init\} $kicker"
	}
	puts $fd $line
	if {$inports != ""} {
	    set line "InPort "
	    append line $inports
	    puts $fd $line
	} 
	if {$outports != ""} {
	    set line "OutPort "
	    append line $outports
	    puts $fd $line
	}
	foreach port $inports {
	    set portname [gen_portname $systemid INPORT $port]
	    if {[info exists m_portqueue($portname)]} {
		puts $fd "QueueLen $port $m_portqueue($portname)"	
	    }
	} 
    }
    close $fd
    return
}

proc gen_link_file {filename p_blockname_map} {
    variable m_a
    upvar $p_blockname_map blockname_map

    set fd [open $filename w]
    foreach link $m_a(edges) {
	set from_id [lindex $link 1]
	set to_id [lindex $link 2]
	
	set fromportname [get_portname $from_id]
	inv_gen_portname $fromportname fromsystemid fromporttype fromport

	set toportname [get_portname $to_id]
	inv_gen_portname $toportname tosystemid toporttype toport

	puts $fd "$blockname_map($fromsystemid) $fromport $blockname_map($tosystemid) $toport"
    }
    close $fd
    return
}

proc gen_file {win isblock} {
    global env

    set file [tk_getSaveFile]
    if {$file != ""} {
    	array set blockname_map {}
    	get_blockname_map $win "BLOCK" blockname_map
	if {$isblock} {
	    gen_block_file $file blockname_map
	} else {
	    gen_link_file $file blockname_map
	}
    }
    return
}

 }

proc error_dialog {string} {
    tk_dialog .foo "Error" $string "" 0 OK
    return
}

proc custom_dialog {string idxlist width p_data} {
    upvar $p_data data
    set w [toplevel .[clock seconds]]
    wm resizable $w 0 0

    wm title $w $string 
    wm iconname $w "form"
    set x [winfo pointerx .]
    set y [winfo pointery .]
    wm geometry $w "+$x+$y"

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text OK -command "set done 1"
    pack $w.buttons.ok -side left -expand 1

    foreach i $idxlist {
    	frame $w.$i -bd 2
    	entry $w.$i.entry -relief sunken -width $width 
    	$w.$i.entry insert 0 $data($i) 
    	label $w.$i.label
    	$w.$i.label config -text $data($i\_desc) 
    	pack $w.$i.entry -side right
    	pack $w.$i.label -side left
    }
    foreach i $idxlist {
    	pack $w.$i -side top -fill x
    }
    focus $w.f1.entry
    vwait done
    foreach i $idxlist {
        set data($i) [$w.$i.entry get]
    }
    destroy $w
 }

frame .mbar -borderwidth 1 -relief raised
pack .mbar -fill x
menubutton .mbar.file -text "File" -menu .mbar.file.m
pack .mbar.file -side left
menu .mbar.file.m
.mbar.file.m add command -label "Open" -command {
    ::FbpDraw::draw_open $c
}	
.mbar.file.m add command -label "Save" -command {
    ::FbpDraw::draw_save $c
}	
.mbar.file.m add command -label "Exit" -command exit

menubutton .mbar.edit -text "Edit" -menu .mbar.edit.m
pack .mbar.edit -side left
menu .mbar.edit.m
.mbar.edit.m add command -label "Clear" -command {
    ::FbpDraw::delete_all $c
}

menubutton .mbar.block -text "Block" -menu .mbar.block.m
pack .mbar.block -side left
menu .mbar.block.m
.mbar.block.m add command -label "Load" -command {
    ::FbpDraw::load_block $c
}
.mbar.block.m add command -label "GenBlock" -command {
    ::FbpDraw::gen_file $c 1
}
.mbar.block.m add command -label "GenLink" -command {
    ::FbpDraw::gen_file $c 0
}

set c [canvas .c -bg white \
         -xscrollcommand {.xbar set} \
	 -yscrollcommand {.ybar set}]
scrollbar .xbar -ori hori -command {.c xview}
scrollbar .ybar -ori vert -command {.c yview}
pack .ybar -side right -fill y
pack .xbar -side bottom -fill both
pack .c -side left -fill both -expand 1
FbpDraw::makeMovable $c

