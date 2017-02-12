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
source fbp_draw_imp.tcl
source fbp_draw_util.tcl
source fbp_draw_block.tcl
source fbp_draw_genfile.tcl
source fbp_draw_load.tcl
source fbp_draw_launch.tcl
source fbp_draw_zig.tcl

namespace eval FbpDraw {
    variable m_a
    variable m_portmap
    variable m_portqueue
    variable m_canvParser
    variable m_block
    variable m_network
    # m_block looks like this
    # m_block(<systemid>,filename) = mux_out
    # m_block(<systemid>,filepath) = $DISK2/component/...
    # m_block(<systemid>,init) = {T {A B C}}
    # m_block(<systemid>,kicker) = red-ball 
    # m_block(<systemid>,inports) = {0 1 2}
    # m_block(<systemid>,outports) = {0 1 2 3 4}
    
    # m_graph looks like this
    # m_graph(graph_id) <graph instance name or id>
    # m_graph(graph_passwd) <graph password for termination purpose>
    # m_graph(graph_file) <graph file name>
    # Note: m_graph contains runtime data only. It does not need
    # to be saved into persistent storage. It does need to be initialized
    # whenever a new graph file is loaded.
    variable m_graph

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
    array set m_network {}
    array set m_graph {graph_id "" graph_passwd "1234" graph_file ""}
    set tmpid [clock format [clock seconds] -format "%Y%m%d%H%M%S"]
    set m_graph(graph_id) graph_$tmpid

    set fd [open $env(DISK2)/fbp_draw/fbp_draw.dat r]
    while {[gets $fd line] > -1} {
	array set m_network $line
    }
    close $fd

    init_zig

    proc makeMovable c {
        variable m_a
        foreach i [$c find all] {
            if [regexp {system} [$c itemcget $i -tags]] {
                $c addtag mv withtag $i
            }
        }
	$c bind edge <Control-1> {
            foreach i [%W itemcget current -tags] {
                if {[is_from_to $i] == 0} {
		    continue
		}
		# Clear the zigzac control points.
		foreach id [::FbpDraw::dot_get [%W find withtag current]] {
		    %W delete $id
		}
		::FbpDraw::clear_zig [%W find withtag current]

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
	    set systemid [get_systemid_from_id %W $id]
	    array set controlpoints {}
	    foreach datalist [find_links_with_fromto %W $systemid] {
		# Keep the in between points for a multi-segment edge.
		set id [lindex $datalist 0]
		if {[lsearch [%W gettags $id] "deco"] == -1} {
		    set from_id [lindex $datalist 1]
		    set to_id [lindex $datalist 2]
		    set controlpoints($from_id,$to_id) [lrange [%W coords $id] 2 end-2]
		    %W delete $id
	    
	    	    # Clear the zigzac control points.
	    	    foreach control_id [::FbpDraw::dot_get $id] {
	                %W delete $control_id
	    	    }
	    	    ::FbpDraw::clear_zig $id
	        } else {
		    %W delete $id
	        }
	    }
 
          if {[array names ::FbpDraw::m_a -exact edges] != ""} {
            foreach i $::FbpDraw::m_a(edges) {
	      set from_id [lindex $i 1]
	      set to_id [lindex $i 2]
	      if {[string first $systemid [FbpDraw::get_portname $from_id]] > -1 ||
		  [string first $systemid [FbpDraw::get_portname $to_id]] > -1} {
	      	  set from [FbpDraw::get_portname $from_id]
		  set to [FbpDraw::get_portname $to_id]
                  eval FbpDraw::edge %W $i [list $controlpoints($from,$to)]
	      }
            }
          }
	  unset controlpoints

	  # Recompute the scroll region.
	  %W configure -scrollregion [%W bbox all] \
              -xscrollincrement 0.1i -yscrollincrement 0.1i 
        }
        $c bind mv <B1-ButtonRelease> {
	  set id [%W find withtag current]
	  set systemid [get_systemid_from_id %W $id]
	  array set controlpoints {}
	  foreach datalist [find_links_with_fromto %W $systemid] {
	      # Keep the in between points for a multi-segment edge.
	      set id [lindex $datalist 0]
	      if {[lsearch [%W gettags $id] "deco"] == -1} {
	          set from_id [lindex $datalist 1]
	          set to_id [lindex $datalist 2]
	          set controlpoints($from_id,$to_id) [lrange [%W coords $id] 2 end-2]
	          %W delete $id

	          # Clear the zigzac control points.
	          foreach control_id [::FbpDraw::dot_get $id] {
	              %W delete $control_id
	          }
	          ::FbpDraw::clear_zig $id
	      } else {
	          %W delete $id
	      }
	  }
          if {[array names ::FbpDraw::m_a -exact edges] != ""} {
            foreach i $::FbpDraw::m_a(edges) {
	      set from_id [lindex $i 1]
	      set to_id [lindex $i 2]
	      if {[string first $systemid [FbpDraw::get_portname $from_id]] > -1 ||
		  [string first $systemid [FbpDraw::get_portname $to_id]] > -1} {
	      	  set from [FbpDraw::get_portname $from_id]
		  set to [FbpDraw::get_portname $to_id]
                  eval FbpDraw::edge %W $i [list $controlpoints($from,$to)]
	      }
            }
          }
	  unset controlpoints
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
	    set systemid [get_systemid_from_id %W $id]
	    if {$systemid == ""} {
	    	error_dialog "Cannot find systemid!"
		return
	    }
	    FbpDraw::block_get $systemid aa bb init kicker \
              inports ee ipaddr timeout ff
	    array set data {}
	    set data(f1) [%W itemcget $id -text]
	    set data(f1_desc) "Name:" 
	    set data(f2) $init
	    set data(f2_desc) "Init:" 
	    set data(f3) $kicker
	    set data(f3_desc) "Kicker:"
	    if {$inports != ""} {
	    	custom_dialog_with_ip "Component customization" "f1 f2 f3" 40 \
                    data ipaddr [FbpMgr::getip]
	    } else {  
	    	set data(f4) $timeout
	    	set data(f4_desc) "Timeout:"
	    	custom_dialog_with_ip "Component customization" "f1 f2 f3 f4" \
                    40 data ipaddr [FbpMgr::getip]
	    }
	    if {$data(f1) != ""} {
		%W itemconfig $id -text $data(f1)
	    	if {$inports != ""} {
		    FbpDraw::block_set $systemid $data(f2) $data(f3) $ipaddr 0
		} else {
		    FbpDraw::block_set $systemid $data(f2) $data(f3) \
                        $ipaddr $data(f4)
		}
		return
	    }
	}
	$c bind BLOCK <Control-3> {
	    set id [%W find withtag current]
	    set systemid [get_systemid_from_id %W $id]
	    # Delete the GUI elements first.
	    foreach id [%W find withtag $systemid] {
		%W delete $id
	    }
	    foreach id [find_links %W $systemid] {
		# Clear the zigzac control points.
		foreach control_id [::FbpDraw::dot_get $id] {
		    %W delete $control_id
		}
		::FbpDraw::clear_zig $id 

		%W delete $id
	    }
	    # Remove the data from namespace variables.
	    FbpDraw::delete_block $systemid

	    # Recompute the scroll region.
	    %W configure -scrollregion [%W bbox all] \
                -xscrollincrement 0.1i -yscrollincrement 0.1i 
	}
        $c bind BLOCK <Alt-3> {
	    # Must store the id value before launching the dialog.
	    # The dialog will most likely change the current id
            # as the user needs to move the cursor to the dialog box!
	    set id [%W find withtag current]
	    set systemid [get_systemid_from_id %W $id]
	    if {$systemid == ""} {
	    	error_dialog "Cannot find systemid!"
		return
	    }
	    FbpDraw::clone_block %W $systemid \
	        [%W itemcget $id -text]\_c %x %y
	}
	$c bind bendtag <ButtonPress-1> [list FbpDraw::drag-start %W %x %y]
	$c bind bendtag <Control-1> [list FbpDraw::dot_delete %W %x %y]
    }
}

frame .mbar -borderwidth 1 -relief raised
pack .mbar -fill x
menubutton .mbar.file -text "File" -menu .mbar.file.m
pack .mbar.file -side left
menu .mbar.file.m
.mbar.file.m add command -label "Open" -command {
    set filename [tk_getOpenFile]
    if {$filename != ""} {
	set fd [open $filename r]
	set script [read $fd]
	close $fd
        ::FbpDraw::draw_open $c $script
    }
    unset filename
}	
.mbar.file.m add command -label "Save" -command {
    ::FbpDraw::draw_save $c
}	
.mbar.file.m add command -label "Reload" -command {
    set graphid ""
    array set tmpdata {}
    FbpMgr::get_graph_ids tmpdata
    Reset_IP [array names tmpdata]  graphid 
    set ipaddr [lindex $tmpdata($graphid) 0]
    set rc [::FbpDraw::Mgr_Query_Graph QUERY_GRAPH $ipaddr $graphid]
    if {$rc != ""} {
        ::FbpDraw::Graph_Set [list $graphid $FbpDraw::m_graph(graph_passwd) \
            $FbpDraw::m_network(first_port)]
	set script [lindex $rc 0]
        ::FbpDraw::draw_open $c $script 
    } 
    unset tmpdata
    unset graphid
}
.mbar.file.m add command -label "Load Agent Cfg" -command {
    ::FbpDraw::load_agent_ports $c
}	
.mbar.file.m add command -label "Exit" -command exit

menubutton .mbar.edit -text "Edit" -menu .mbar.edit.m
pack .mbar.edit -side left
menu .mbar.edit.m
.mbar.edit.m add command -label "Graph" -command {
    array set data {}
    set data(f1) $FbpDraw::m_graph(graph_id)
    set data(f1_desc) "Graph name:" 
    set data(f2) $FbpDraw::m_graph(graph_passwd)
    set data(f2_desc) "Password  :" 
    set data(f3) $FbpDraw::m_network(first_port)
    set data(f3_desc) "First port:" 
    custom_dialog "Graph parameters" "f1 f2 f3" 20 data
    ::FbpDraw::Graph_Set [list $data(f1) $data(f2) $data(f3)]
}
.mbar.edit.m add command -label "Clear" -command {
    ::FbpDraw::delete_all $c
}
.mbar.edit.m add command -label "Toggle Dot" -command {
    ::FbpDraw::dot_toggle $c
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

menubutton .mbar.ipaddr -text "IP Addr" -menu .mbar.ipaddr.m
pack .mbar.ipaddr -side left
menu .mbar.ipaddr.m
.mbar.ipaddr.m add command -label "Sweep" -command {
    array set data {}
    set data(f1) $FbpDraw::m_network(ip_prefix)
    set data(f1_desc) "IP address prefix:" 
    set data(f2) $FbpDraw::m_network(ip_min)
    set data(f2_desc) "IP address suffix min:" 
    set data(f3) $FbpDraw::m_network(ip_max)
    set data(f3_desc) "IP address suffix max:" 
    custom_dialog "Sweep parameters" "f1 f2 f3" 12 data
    ::FbpDraw::Mgr_Init $data(f1) $FbpDraw::m_network(service_port)
    ::FbpDraw::Mgr_Sweep $data(f2) $data(f3) 
    info_dialog "IP addr found: [::FbpMgr::getip]"     
}
.mbar.ipaddr.m add command -label "SetAll" -command {
    set ipaddr ""
    Reset_IP [FbpMgr::getip] ipaddr
    if {$ipaddr != ""} {
    	::FbpDraw::block_set_all_ipaddr $ipaddr
    } else {
    	error_dialog "IP address is empty!"
    }
}

menubutton .mbar.launch -text "Launch" -menu .mbar.launch.m
pack .mbar.launch -side left
menu .mbar.launch.m
.mbar.launch.m add command -label "Run" -command {
    ::FbpDraw::draw_save $c [::FbpDraw::Gen_Graphfile_Name]
    array set blockname_map {}
    get_blockname_map $c "BLOCK" blockname_map
    ::FbpDraw::launch_run blockname_map
    unset blockname_map 
}
.mbar.launch.m add command -label "Monitor queue" -command {
    ::FbpDraw::launch_monitor $c
}
.mbar.launch.m add command -label "Monitor cpu" -command {
    ::FbpDraw::launch_monitor_cpu $c
}
.mbar.launch.m add command -label "Reconnect" -command {
    ::FbpDraw::launch_reconnect $c
}
.mbar.launch.m add command -label "Disconnect" -command {
    ::FbpDraw::launch_disconnect $c
}
.mbar.launch.m add command -label "Stop" -command {
    ::FbpDraw::launch_stop $c
}
.mbar.launch.m add command -label "Scratchpad" -command {
    ::FbpDraw::launch_setdir
}

set c [canvas .c -bg khaki \
         -xscrollcommand {.xbar set} \
	 -yscrollcommand {.ybar set}]
scrollbar .xbar -ori hori -command {.c xview}
scrollbar .ybar -ori vert -command {.c yview}
pack .ybar -side right -fill y
pack .xbar -side bottom -fill both
pack .c -side left -fill both -expand 1
FbpDraw::makeMovable $c
FbpDraw::launch_init

