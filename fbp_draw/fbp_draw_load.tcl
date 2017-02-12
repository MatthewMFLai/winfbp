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

proc populate_zigzac {win} {

    # Delete all control points first.
    foreach it [$win find withtag bendtag] {
	$win delete $it
    }

    # Find all edges (that are not deco) and construct
    # control points for those with multi-segments.
    foreach it [$win find withtag edge] {
	if {[lsearch [$win gettags $it] deco] != -1} {
	    continue
    	}
	$win bind $it <ButtonPress-1> [list FbpDraw::zig %W %x %y]
	# Create control point for a multi segment line excluding the
	# start and end points.
	foreach {x y} [lrange [$win coords $it] 2 end-2] {
	    dot $win $x $y $it
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
proc draw_open {c script} {
    global env
    variable m_block
    variable m_portqueue

    unset m_block
    array set m_block {}
    unset m_portqueue
    array set m_portqueue {}
    if {$script != ""} {
        set cmd {
            canvas_load $c $script

	    # Load the m_block data and m_portqueue data.
	    set linelist [split $script "\n"]
	    foreach line $linelist {
		if {[string first "array set" $line] == 0} {
		    eval $line
		}
	    }
        }
        if {[catch $cmd err] != 0} {
            puts "Cannot open drawing:\n$err"
	    return
        }
        #draw_fix_menus
	populate_portmap $c
	populate_edges $c
	populate_zigzac $c

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
proc draw_save {c {filename ""}} {
    global env
    variable m_block
    variable m_portqueue

    if {$filename == ""} {
    	set filename [tk_getSaveFile]
    }
    if {$filename != ""} {
        $c addtag "canvas_save_ignore" withtag "marker"
        set selected [$c find withtag "selected"]
        $c dtag "selected"

        set cmd {
            set fid [open $filename w]
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

proc load_agent_ports {c} {
    variable m_network

    set file [tk_getOpenFile]
    if {$file != ""} {
    	set fd [open $file r]
    	while {[gets $fd line] > -1} {
	    array set m_network $line
    	}
    	close $fd
    }
    return
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
    set ipaddr ""
    set timeout 0
    set portset ""

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
	} ipaddr {
	    set ipaddr $value
	} timeout {
	    set timeout $value
	} portset {
	    # The portset line looks like
	    # portset {<port group name> <port number> <port init status>}
	    lappend portset $value
	} default {
	    puts "unsupported key: $key"
	} 
    }
    # Extract block name from selected filename.
    set displayname [lindex [split $file "/"] end]
    set displayname [lindex [split $filename "."] 0]

    set id [gen_systemid [get_systemid $c]]
    block_add $id $filename $filepath $init $kicker $inports $outports $ipaddr $timeout $portset

    box $c  50  50 [list $displayname $id $inports $outports]
    makeMovable_block $c $id

    # Recompute the scroll region.
    $c configure -scrollregion [$c bbox all] \
       -xscrollincrement 0.1i -yscrollincrement 0.1i 
}

proc clone_block {win cur_id displayname x y} {

    set id [gen_systemid [get_systemid $win]]
    block_clone $id $cur_id

    block_get $cur_id aa bb cc dd inports outports ee ff gg
    box $win $x $y [list $displayname $id $inports $outports]
    makeMovable_block $win $id

    # Recompute the scroll region.
    $win configure -scrollregion [$win bbox all] \
       -xscrollincrement 0.1i -yscrollincrement 0.1i 
}

}

